"""Bake original illustrated instruments and metal inlays at 2× logical size."""
import io
import subprocess
from pathlib import Path

from PIL import Image

OUT = Path(__file__).resolve().parents[2] / "game/art/hud"
OUT.mkdir(parents=True, exist_ok=True)
DEFS = """
<linearGradient id="bronze" x2=".38" y2="1" gradientUnits="objectBoundingBox">
<stop stop-color="#fff0bd"/><stop offset=".12" stop-color="#d4ae6e"/><stop offset=".35" stop-color="#795435"/>
<stop offset=".58" stop-color="#9f7247"/><stop offset=".67" stop-color="#4d392b"/><stop offset="1" stop-color="#a98455"/></linearGradient>
<linearGradient id="steel" x2="0.18" y2="1"><stop stop-color="#71838a"/><stop offset=".28" stop-color="#384854"/>
<stop offset=".7" stop-color="#212b33"/><stop offset="1" stop-color="#161b23"/></linearGradient>
<linearGradient id="enamel" x2="0" y2="1"><stop stop-color="#26333c"/><stop offset=".18" stop-color="#1e2931"/>
<stop offset=".7" stop-color="#151c25"/><stop offset="1" stop-color="#0a1018"/></linearGradient>
<linearGradient id="blade" x2="1" y2=".65"><stop stop-color="#536477"/><stop offset=".45" stop-color="#e4e8e5"/>
<stop offset=".6" stop-color="#b7cfcc"/><stop offset="1" stop-color="#7896a8"/></linearGradient>
<radialGradient id="well" cx=".50" cy=".70" r=".72"><stop stop-color="#805132"/><stop offset=".62" stop-color="#47342a"/>
<stop offset="1" stop-color="#161820"/></radialGradient>
<radialGradient id="ruby" cx=".32" cy=".23" r=".85"><stop stop-color="#fa8271"/><stop offset=".12" stop-color="#db4d48"/>
<stop offset=".35" stop-color="#b22a32"/><stop offset=".67" stop-color="#871b2b"/><stop offset=".86" stop-color="#681825"/><stop offset="1" stop-color="#360f1d"/></radialGradient>
<radialGradient id="glass" cx=".33" cy=".22" r=".92"><stop stop-color="#374350"/><stop offset=".45" stop-color="#202937"/><stop offset="1" stop-color="#0c151e"/></radialGradient>
<linearGradient id="vial" x2="1" y2=".1"><stop stop-color="#731e28"/><stop offset=".3" stop-color="#df4b4c"/>
<stop offset=".45" stop-color="#ee8d75"/><stop offset=".5" stop-color="#c04242"/><stop offset="1" stop-color="#6c2028"/></linearGradient>
"""


def write(name, w, h, body, density=2):
    svg = f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}"><defs>{DEFS}</defs>{body}</svg>'
    stream = subprocess.run(
        ["inkscape", "--pipe", "--export-type=png", "--export-filename=-",
         f"--export-width={w*3}", f"--export-height={h*3}"],
        input=svg.encode(), capture_output=True, check=True,
    ).stdout
    image = Image.open(io.BytesIO(stream)).convert("RGBA").resize((round(w*density), round(h*density)), Image.Resampling.LANCZOS)
    image.save(OUT / f"{name}.webp", lossless=True, method=5)


def path(d, fill, stroke="none", width=1):
    return f'<path d="{d}" fill="{fill}" stroke="{stroke}" stroke-width="{width}" stroke-linejoin="round"/>'


def circle(x, y, r, fill, stroke="none", width=1):
    return f'<circle cx="{x}" cy="{y}" r="{r}" fill="{fill}" stroke="{stroke}" stroke-width="{width}"/>'


def bolt(x, y, rad=2.2):
    return (circle(x, y+.4, rad, "#141518") + circle(x, y-.25, rad*.86, "url(#bronze)")
            + path(f"M{x-rad*.52} {y+rad*.3}l{rad:.2f} {-rad*.75:.2f}", "none", "#3a342c", .65))


def cut_rect(x, y, w, h, c):
    return f"M{x+c} {y}h{w-2*c}l{c} {c}v{h-2*c}l{-c} {c}h{-w+2*c}l{-c} {-c}v{-h+2*c}Z"


def bezel(x, y, w, h):
    body = path(cut_rect(x, y, w, h, 6), "url(#steel)", "#181a1a", 1.5)
    body += path(cut_rect(x+2, y+2, w-4, h-4, 4), "url(#bronze)")
    body += path(cut_rect(x+3.25, y+3.25, w-6.5, h-6.5, 4), "url(#enamel)", "#0b1119")
    return body


def socket(x, y, icon):
    body = bezel(x, y, 50, 46)
    body += path(cut_rect(x+5, y+5, 40, 36, 2), "url(#well)")
    body += f'<g transform="translate({x+2} {y+1})">{icon}</g>'
    return body


rifle = f'''<g transform="rotate(-19 24 24)">
{path("M3 24l3 -7 4 1 6 -2 0 -3h15v3h11v2h4v4h-16l-3 2 -1 4h-5l-2 -4h-4l-3 5 -4 -1 2 -6 -5 5z", "url(#steel)", "#0b0e14", 1.5)}
{path("M5 23l2 -5 6 1 -2 2z M15 17h16v4h-16z M32 17h10v2H32z", "url(#bronze)")}
{path("M17 13h9v2h-9z M21 22h5l-2 4h-3z", "#748287")}
{path("M29 17v4m3 -4v3m3 -3v3m3 -3v3", "none", "#121e28", 1)}
{path("M16 16l5 -1h9 M31 16h10", "none", "#d0d8cc", .7)}
{circle(19,18.5,1,"#cde7d8")}</g>'''
sword = path("M10 33L31 9l9 -5 -4 10 -22 23z", "url(#blade)", "#151721", 1.2)
sword += path("M13 34L37 8l-4 7-19 20z", "#53667c")
sword += path("M10 34l24 -25", "none", "#fff4dc", .9)
sword += path("M7 29l5 1 8 6 1 3 -4 -1 -6 -5 -4 -1z", "url(#bronze)", "#211c1c")
sword += path("M11 33l3 3 -8 8 -3 -3z", "#77544a", "#1c1920")
sword += path("M7 35l4 4m-7 -1l4 4", "none", "#c18e64")
sword += circle(4,42,2.3,"url(#bronze)","#372921",.7)
medical = path("M16 15l4 -4h9l3 4v21l-3 4H18l-4 -4V18z", "url(#blade)", "#14151a", 1.4)
medical += path("M17 19h12v15l-2 3h-7l-3 -2z", "url(#vial)", "#713039", .8)
medical += path("M17 14h14v4H17z M17 34h13v4H17z M20 8h8v6h-8z M19 7h10v3H19z", "url(#bronze)", "#29272a", .85)
medical += path("M19 21v9m4 -18h5", "none", "#f2b89d", 1)
medical += path("M21 22h3v3h3v3h-3v3h-3v-3h-3v-3h3z", "#e6d9b8")

# Main plate with layered steel, engraved separators, mounting pins and icon reliefs.
plate = path("M29 26h603l16 13v41l-12 12H69L20 75V44z", "#060a10", "#080b10", 2)
plate += bezel(24, 22, 622, 67)
plate += path("M72 27h547l13 0m-540 36h534", "none", "#887155", .65)
plate += path("M91 68h540", "none", "#101318", 1.4)
for x in (276, 440):
    plate += path(f"M{x} 30v31", "none", "#071018", 2)
    plate += path(f"M{x+1.4} 31v29", "none", "#5b5348", .8)
for x in (634, 84):
    for y in (32, 79):
        plate += bolt(x, y)
for x, icon in ((94, rifle), (285, sword), (449, medical)):
    plate += socket(x, 22, icon)

# Physically scaled shielded dial. The liquid face is blitted separately by the HUD.
plate += circle(48, 46, 43, "#080d12","#101417",2)
for radius, color in ((41.6,"url(#bronze)"), (39.3,"#352d28"), (37.4,"url(#steel)"),
                      (35.8,"url(#bronze)"), (33.3,"#171920"), (31.0,"url(#glass)")):
    plate += circle(48, 45, radius, color)
for angle in range(0,360,45):
    plate += f'<g transform="rotate({angle} 48 45)">'
    plate += path("M44 11L43 8 45 4l3 -4 3 4 2 4 -1 3 -4 -2z", "url(#bronze)", "#312a26", .7)
    plate += path("M45 7l3 -5 -1 5z", "#f6d5a5")
    plate += circle(48,8.2,1.2,"#2c2927")
    plate += "</g>"
write("field_instruments", 649, 95, plate, density=1.5)
face = circle(32,32,31,"url(#ruby)")
face += path("M9 23Q14 9 30 7Q18 8 12 23Z", "#f2a69a")
face += path("M42 56Q53 52 56 42", "none", "#c24a4e", 1.2)
face += '<ellipse cx="21" cy="14" rx="3.9" ry="2.2" fill="#fbd4c3" transform="rotate(-22 21 14)"/>'
write("vitality_glass", 64, 64, face)
# A stretchable machined frame keeps large modal and compact brass panels consistent.
plate = bezel(1, 1, 71, 57)
for x in (7.5,65.5):
    for y in (7.5,51.5):
        plate += bolt(x, y, 1.9)
write("frame", 74, 60, plate)

# The fleet's four-leaf device, stamped directly into metal without an icon tile.
crest = path("M21 1l4 13 -4 10 -4 -10z M5 8l8 6 5 11 -9 -7z M37 8l-8 6 -5 11 9 -7z M10 23l7 5 4 9 4 -9 7 -5 -5 11 -6 7 -6 -7z",
             "url(#bronze)", "#362a22", .65)
crest += path("M21 3v17l-2 -6z M7 10l8 10 -3 -6z", "#f1d2ab")
write("fleet_crest", 42, 42, crest)
