"""Synthesize original station room tone, a switch clank and the departure bell."""
from pathlib import Path
from tempfile import TemporaryDirectory
import subprocess
import numpy as np
from scipy.io import wavfile
from scipy.signal import butter,sosfilt

rate = 24000
out = Path(__file__).resolve().parents[2]/"game/transit"
rng = np.random.default_rng(211)
def noise(n, low, high):
    return sosfilt(butter(3,(low,high),fs=rate,btype="bandpass",output="sos"),rng.normal(size=n))
def write(name, wave):
    with TemporaryDirectory() as temp:
        pcm=Path(temp)/"sound.wav"
        wavfile.write(pcm,rate,np.int16(np.clip(wave,-.98,.98)*32767))
        subprocess.run(["ffmpeg","-loglevel","error","-y","-i",str(pcm),"-c:a","libvorbis","-q:a","4",str(out/(name+".ogg"))],check=True)
def bell(t, freq):
    return sum(gain*np.sin(2*np.pi*freq*ratio*t)*np.exp(-t*decay) for ratio,gain,decay in [(1,.40,2.7),(2.73,.14,4.0),(4.18,.075,5.6)]) * np.minimum(t*125,1)
t=np.arange(rate*7)/rate
air=noise(len(t),160,1150)*.16
air+=np.sin(2*np.pi*t*57)*.09+np.sin(2*np.pi*t*114)*.03
air+=noise(len(t),38,120)*np.exp(-np.maximum(t-2.1,0)*1.7)*(t>2.1)*.60
fade=np.minimum(np.minimum(t/.15,(7-t)/.15),1)
write("station_air",air*fade)
t=np.arange(int(rate*.72))/rate
write("switch",noise(len(t),220,4200)*np.exp(-t*19)*.8 + np.sin(2*np.pi*153*t)*np.exp(-t*12)*.32)
t=np.arange(rate*5)/rate
gong=bell(t,670)+bell(np.maximum(t-.33,0),823)*.79
roll=(.09*np.sin(2*np.pi*(41*t+3.1*t*t))+.20*noise(len(t),110,1600)) * np.minimum(t,1) * np.clip((5-t)/2,0,1)
pulses=np.maximum(0,np.sin(2*np.pi*(1.8*t+.62*t*t)))**14
write("departure",gong+roll+noise(len(t),200,1100)*pulses*.25*np.clip((5-t),0,1))
