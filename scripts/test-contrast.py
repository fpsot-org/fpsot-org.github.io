#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0
"""Checks that each code colour (--hl-*) in public/assets/spec.css reaches a WCAG
contrast ratio of 4.5:1 against the code background (--wash in style.css), in the
light theme and in the dark theme. Exits 1 if one does not."""
import re
import sys
from pathlib import Path

root = Path(__file__).resolve().parent.parent
spec = (root / "public/assets/spec.css").read_text(encoding="utf-8")
style = (root / "public/assets/style.css").read_text(encoding="utf-8")


def block(css, selector):
    """The declarations of the first rule whose selector is exactly `selector`."""
    m = re.search(re.escape(selector) + r"\s*\{([^}]*)\}", css)
    return dict(re.findall(r"(--[\w-]+):\s*(#[0-9a-fA-F]{6})", m.group(1))) if m else {}


def luminance(hex_colour):
    def channel(c):
        c = int(c, 16) / 255
        return c / 12.92 if c <= 0.03928 else ((c + 0.055) / 1.055) ** 2.4
    r, g, b = (channel(hex_colour[i:i + 2]) for i in (1, 3, 5))
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


def ratio(a, b):
    la, lb = sorted((luminance(a), luminance(b)), reverse=True)
    return (la + 0.05) / (lb + 0.05)


themes = {
    "light": (block(spec, ":root"), block(style, ":root").get("--wash")),
    "dark": (block(spec, ':root[data-theme="dark"]'), block(style, ':root[data-theme="dark"]').get("--wash")),
}
fail = False
for name, (colours, background) in themes.items():
    tokens = {k: v for k, v in colours.items() if k.startswith("--hl-")}
    if len(tokens) < 7 or not background:
        print(f"FAIL: {name}: expected 7 --hl-* colours and a --wash background, got {sorted(tokens)} / {background}")
        fail = True
        continue
    for token, colour in sorted(tokens.items()):
        r = ratio(colour, background)
        if r < 4.5:
            print(f"FAIL: {name}: {token} {colour} on {background} is {r:.2f}:1 (needs 4.5:1)")
            fail = True
# The automatic dark theme must use the same colours as the forced one.
auto = re.search(r'@media \(prefers-color-scheme: dark\)\s*\{\s*:root:not\(\[data-theme="light"\]\)\s*\{([^}]*)\}', spec)
if not auto or dict(re.findall(r"(--hl-[\w-]+):\s*(#[0-9a-fA-F]{6})", auto.group(1))) != {k: v for k, v in themes["dark"][0].items() if k.startswith("--hl-")}:
    print("FAIL: the prefers-color-scheme dark colours differ from the data-theme dark colours")
    fail = True
print("FAIL" if fail else "PASS")
sys.exit(1 if fail else 0)
