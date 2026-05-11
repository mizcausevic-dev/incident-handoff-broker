from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "screenshots"
OUT.mkdir(exist_ok=True)

BG = "#09121f"
SHELL = "#131d30"
CARD = "#1a2740"
BORDER = "#294164"
TEXT = "#f3eee1"
MUTED = "#b7c2d7"
ACCENT = "#86c4ff"
GOLD = "#f4e4a2"
GREEN = "#89e9ae"
PINK = "#ffb5df"


def font(name: str, size: int):
    return ImageFont.truetype(str(Path("C:/Windows/Fonts") / name), size)


DISPLAY = font("georgiab.ttf", 42)
TITLE = font("segoeuib.ttf", 24)
BODY = font("segoeui.ttf", 18)
SMALL = font("segoeui.ttf", 14)
LABEL = font("consola.ttf", 14)


def wrap(draw: ImageDraw.ImageDraw, text: str, face, width: int):
    words = text.split()
    lines = []
    line = ""
    for word in words:
      trial = word if not line else f"{line} {word}"
      if draw.textlength(trial, font=face) <= width:
          line = trial
      else:
          if line:
              lines.append(line)
          line = word
    if line:
        lines.append(line)
    return lines


def shell():
    img = Image.new("RGB", (1400, 900), BG)
    draw = ImageDraw.Draw(img)
    draw.rounded_rectangle((28, 28, 1372, 872), 28, fill=SHELL, outline=BORDER, width=2)
    return img, draw


def text_block(draw, x, y, text, face, fill, width, line_gap=8):
    lines = wrap(draw, text, face, width)
    cursor = y
    for line in lines:
        draw.text((x, cursor), line, font=face, fill=fill)
        cursor += face.size + line_gap
    return cursor


def chip(draw, x, y, text):
    w = int(draw.textlength(text, font=BODY)) + 34
    draw.rounded_rectangle((x, y, x + w, y + 38), 19, fill="#24385b")
    draw.text((x + 16, y + 8), text, font=BODY, fill=TEXT)


def metric_card(draw, x, y, w, h, label, value, subtitle):
    draw.rounded_rectangle((x, y, x + w, y + h), 22, fill=CARD, outline=BORDER, width=2)
    draw.text((x + 18, y + 18), label.upper(), font=LABEL, fill=ACCENT)
    draw.text((x + 18, y + 54), value, font=DISPLAY, fill=GOLD)
    text_block(draw, x + 18, y + 120, subtitle, BODY, MUTED, w - 36, 6)


def lane_card(draw, x, y, w, h, label, title, body, footer):
    draw.rounded_rectangle((x, y, x + w, y + h), 22, fill=CARD, outline=BORDER, width=2)
    draw.text((x + 18, y + 18), label.upper(), font=LABEL, fill=ACCENT)
    text_block(draw, x + 18, y + 56, title, TITLE, TEXT, w - 36, 6)
    text_block(draw, x + 18, y + 120, body, BODY, MUTED, w - 36, 6)
    text_block(draw, x + 18, y + h - 84, footer, TITLE, GOLD, w - 36, 6)


def hero():
    img, draw = shell()
    draw.text((62, 74), "INCIDENT HANDOFF BROKER", font=LABEL, fill=ACCENT)
    text_block(
        draw,
        62,
        122,
        "Turn noisy incident ownership into a handoff order teams can actually follow.",
        DISPLAY,
        TEXT,
        1220,
        10,
    )
    text_block(
        draw,
        62,
        270,
        "Elixir is carrying live incident intake, SLA pressure, blocker stacking, and owner routing in one supervision-friendly service surface.",
        BODY,
        MUTED,
        1180,
        8,
    )
    metric_card(draw, 62, 396, 290, 180, "active handoffs", "3", "Growth, security, and platform incidents currently crossing team boundaries.")
    metric_card(draw, 376, 396, 290, 180, "escalated paths", "2", "Two transfers are already above acceptable coordination drag.")
    metric_card(draw, 690, 396, 290, 180, "owner gaps", "1", "One thread still lacks a pinned downstream owner.")
    metric_card(draw, 1004, 396, 290, 180, "avg confidence", "0.76", "Signal quality is usable, but not clean enough to coast.")
    draw.rounded_rectangle((62, 626, 1294, 786), 26, fill=CARD, outline=BORDER, width=2)
    draw.text((92, 654), "CURRENT DECISION LANE", font=LABEL, fill=PINK)
    text_block(draw, 92, 694, "Redirect the checkout incident into a governed recovery bridge before support load spikes harder.", TITLE, TEXT, 1130, 6)
    text_block(draw, 92, 750, "This service treats incident transfer as an operating decision, not just an afterthought in chat.", BODY, MUTED, 1100, 6)
    img.save(OUT / "01-hero.png")


def lanes():
    img, draw = shell()
    draw.text((62, 74), "HANDOFF LANES", font=LABEL, fill=ACCENT)
    text_block(draw, 62, 122, "Three response lanes. One broker deciding who owns the next move.", DISPLAY, TEXT, 1220, 10)
    lane_card(draw, 62, 270, 390, 254, "PLATFORM TO REVENUE", "Stabilize checkout before the ownership baton drops again.", "Critical latency, cache invalidation drift, and support complaints are hitting the same transfer lane.", "Shift traffic into recovery bridge.")
    lane_card(draw, 505, 270, 390, 254, "AI TO SECURITY", "Route policy evidence into a governed investigation lane.", "Owner gaps and stale contractor keys mean the handoff cannot stay informal.", "Pin the security lead and freeze exceptions.")
    lane_card(draw, 948, 270, 346, 254, "DEMAND TO PARTNER", "Keep partner routing warm.", "Taxonomy drift exists, but recovery remains controlled.", "Hold in watch mode.")
    draw.rounded_rectangle((62, 566, 1294, 808), 22, fill=CARD, outline=BORDER, width=2)
    draw.text((92, 594), "WHY ELIXIR FITS", font=LABEL, fill=PINK)
    text_block(draw, 92, 632, "This repo uses Elixir where it actually makes sense: live handoff pressure, lightweight routing, and process-friendly operational logic.", TITLE, TEXT, 1120, 6)
    img.save(OUT / "02-lanes.png")


def escalation():
    img, draw = shell()
    draw.text((62, 74), "ESCALATION THREAD", font=LABEL, fill=ACCENT)
    text_block(draw, 62, 122, "A single incident, broken into pressure, ownership, and next action.", DISPLAY, TEXT, 1220, 10)
    draw.rounded_rectangle((62, 248, 520, 790), 22, fill=CARD, outline=BORDER, width=2)
    draw.text((90, 278), "INC-4102", font=LABEL, fill=PINK)
    text_block(draw, 90, 318, "Checkout latency spike is bouncing between platform and revenue ops.", TITLE, TEXT, 460, 6)
    text_block(draw, 90, 394, "Timeline", TITLE, ACCENT, 200, 4)
    for idx, item in enumerate([
        "19:05 ET - Cart drop alerts fired.",
        "19:18 ET - Edge controls tightened in the EU lane.",
        "19:34 ET - Support escalated three strategic account complaints."
    ]):
        text_block(draw, 90, 438 + idx * 74, item, BODY, MUTED, 440, 6)
    draw.rounded_rectangle((566, 248, 728, 248), 22, fill=CARD, outline=BORDER, width=2)
    draw.text((594, 278), "STATUS", font=LABEL, fill=ACCENT)
    draw.text((594, 320), "ESCALATE", font=DISPLAY, fill=GOLD)
    draw.text((594, 404), "RISK SCORE 92", font=TITLE, fill=TEXT)
    draw.text((594, 450), "OWNER Revenue Systems lead", font=BODY, fill=MUTED)
    draw.text((594, 492), "LANE executive-war-room", font=BODY, fill=MUTED)
    draw.text((594, 546), "NEXT ACTION", font=LABEL, fill=PINK)
    text_block(draw, 594, 584, "Shift checkout traffic to the hardened recovery lane and pin cache invalidation ownership now.", TITLE, TEXT, 660, 6)
    img.save(OUT / "03-escalation.png")


def proof():
    img, draw = shell()
    draw.text((62, 74), "VALIDATION PROOF", font=LABEL, fill=ACCENT)
    text_block(draw, 62, 122, "Real routes. Real analysis output. Real test validation.", DISPLAY, TEXT, 1220, 10)
    draw.rounded_rectangle((62, 262, 760, 780), 22, fill="#0c1628", outline=BORDER, width=2)
    draw.text((92, 292), "> POST /api/analyze/handoff", font=TITLE, fill=GREEN)
    code = [
        "{",
        '  "severity": "critical",',
        '  "sla_hours": 2,',
        '  "elapsed_hours": 3.4,',
        '  "bridge_state": "war-room-active"',
        "}"
    ]
    y = 338
    for line in code:
        draw.text((92, y), line, font=BODY, fill=TEXT)
        y += 34
    draw.rounded_rectangle((810, 262, 1294, 780), 22, fill=CARD, outline=BORDER, width=2)
    draw.text((838, 292), "PROOF POINTS", font=LABEL, fill=ACCENT)
    text_block(draw, 838, 336, "mix test is green, root/docs load cleanly, and the sample analysis returns an escalation lane with a concrete next action.", TITLE, TEXT, 420, 8)
    text_block(draw, 838, 492, "Beam runtime", BODY, GREEN, 200, 4)
    text_block(draw, 838, 526, "Elixir 1.19.5 / OTP 28", BODY, MUTED, 320, 4)
    text_block(draw, 838, 590, "API routes", BODY, GREEN, 200, 4)
    text_block(draw, 838, 624, "/, /docs, /api/dashboard/summary, /api/sample, /api/analyze/handoff", BODY, MUTED, 400, 6)
    img.save(OUT / "04-proof.png")


if __name__ == "__main__":
    hero()
    lanes()
    escalation()
    proof()
