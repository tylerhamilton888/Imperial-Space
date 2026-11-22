import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from PIL import Image

TOOLS = Path(__file__).resolve().parents[1]

class AssetToolsTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
    def tearDown(self):
        self.temp.cleanup()
    def run_tool(self, name, *args):
        return subprocess.run([sys.executable, str(TOOLS/name), *map(str,args)], capture_output=True, text=True)
    def image(self, name='valid.png', size=(64,64), mode='RGB'):
        path = self.root/name
        Image.new(mode,size,(200,100,50,128) if mode=='RGBA' else (200,100,50)).save(path)
        return path
    def test_valid_and_report(self):
        image = self.image()
        report = self.root/'report.json'
        result = self.run_tool('check_assets.py', image, '--profile', 'preview', '--report', report)
        self.assertEqual(result.returncode,0,result.stdout+result.stderr)
        self.assertTrue(json.loads(report.read_text())['passed'])
    def test_dimension_failure(self):
        result = self.run_tool('check_assets.py', self.image(size=(1300,30)), '--profile','preview')
        self.assertEqual(result.returncode,1)
        self.assertIn('Dimensions',result.stdout)
    def test_encoded_byte_failure(self):
        image = self.image()
        with image.open('ab') as out:
            out.write(b'x'*(601*1024))
        result = self.run_tool('check_assets.py', image,'--profile','preview')
        self.assertEqual(result.returncode,1)
        self.assertIn('Size',result.stdout)
    def test_corrupt_and_missing(self):
        corrupt=self.root/'broken.jpg'
        corrupt.write_bytes(b'not an image')
        for path in (corrupt,self.root/'missing.png'):
            result=self.run_tool('check_assets.py',path,'--profile','preview')
            self.assertEqual(result.returncode,1)
    def test_runtime_kinds(self):
        image=self.image(size=(1100,1100))
        frame=self.run_tool('check_assets.py',image,'--profile','runtime','--kind','frame')
        atlas=self.run_tool('check_assets.py',image,'--profile','runtime','--kind','atlas')
        missing_kind=self.run_tool('check_assets.py',image,'--profile','runtime')
        self.assertEqual(frame.returncode,1)
        self.assertEqual(atlas.returncode,0)
        self.assertEqual(missing_kind.returncode,2)
    def test_preview_preserves_source_and_limits(self):
        source=self.image(size=(2000,1000))
        original=hashlib.sha256(source.read_bytes()).hexdigest()
        output=self.root/'small.jpg'
        result=self.run_tool('make_preview.py',source,output,'--max-side','500','--max-kib','20')
        self.assertEqual(result.returncode,0,result.stderr)
        self.assertEqual(original,hashlib.sha256(source.read_bytes()).hexdigest())
        with Image.open(output) as im:
            self.assertLessEqual(max(im.size),500)
        self.assertLessEqual(output.stat().st_size,20*1024)
        refused=self.run_tool('make_preview.py',source,output)
        self.assertEqual(refused.returncode,2)
        refused_source=self.run_tool('make_preview.py',source,source)
        self.assertEqual(refused_source.returncode,2)
    def test_transparency_requires_explicit_flattening(self):
        source=self.image(mode='RGBA')
        denied=self.run_tool('make_preview.py',source,self.root/'bad.jpg')
        self.assertEqual(denied.returncode,1)
        self.assertFalse((self.root/'bad.jpg').exists())
        png=self.root/'alpha.png'
        result=self.run_tool('make_preview.py',source,png)
        self.assertEqual(result.returncode,0,result.stderr)
        with Image.open(png) as im:
            self.assertEqual(im.mode,'RGBA')
            self.assertEqual(im.getextrema()[3],(128,128))
        flat=self.run_tool('make_preview.py',source,self.root/'flat.jpg','--background','#20252A')
        self.assertEqual(flat.returncode,0,flat.stderr)
    def test_truncated_jpeg_fails(self):
        source=self.image(name='truncated.jpg')
        source.write_bytes(source.read_bytes()[:-20])
        result=self.run_tool('check_assets.py',source,'--profile','preview')
        self.assertEqual(result.returncode,1)
        self.assertIn('Unreadable',result.stdout)
    def test_alpha_background_color_is_handled(self):
        source=self.image(mode='RGBA')
        result=self.run_tool('make_preview.py',source,self.root/'flat_alpha_color.jpg','--background','#20252A80')
        self.assertEqual(result.returncode,0,result.stderr)
    def test_symlink_alias_and_directory_cycle(self):
        source=self.image()
        alias=self.root/'alias.png'
        cycle=self.root/'cycle'
        try:
            alias.symlink_to(source)
            cycle.symlink_to(self.root, target_is_directory=True)
        except OSError:
            self.skipTest('Symlink creation unavailable on this platform')
        result=self.run_tool('make_preview.py',source,alias)
        self.assertEqual(result.returncode,2)
        report=self.root/'cycle_report.json'
        result=self.run_tool('check_assets.py',self.root,'--profile','preview','--report',report)
        self.assertEqual(result.returncode,0,result.stdout+result.stderr)
        self.assertEqual(json.loads(report.read_text())['images_checked'],1)
    def test_empty_directory_fails(self):
        result=self.run_tool('check_assets.py',self.root,'--profile','preview')
        self.assertEqual(result.returncode,1)

if __name__=='__main__':
    unittest.main(verbosity=2)
