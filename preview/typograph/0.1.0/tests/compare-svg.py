#!/usr/bin/env python3
"""Compare two SVGs for the documentation staleness check.

Tolerant of cross-platform rendering jitter: the same Typst version, run as
a different build (different OS/architecture/libm), can render identical
source with sub-percent numeric differences in glyph or curve coordinates
even with font resolution pinned via --ignore-system-fonts. Every decimal
number is rounded to 2 places (0.01pt) before comparing -- far finer than
anything visible, but coarse enough to absorb that jitter. A real content
change (moved node, different color, different shape) shifts coordinates by
far more than that, so it still fails the check.

Exit 0 if the two files match after normalizing, 1 otherwise -- a drop-in
replacement for `cmp -s`.
"""
import re
import sys


def normalize(path):
    with open(path, encoding="utf-8") as f:
        text = f.read()
    return re.sub(r"-?\d+\.\d+", lambda m: f"{float(m.group(0)):.2f}", text)


def main():
    if len(sys.argv) != 3:
        print("usage: compare-svg.py <a.svg> <b.svg>", file=sys.stderr)
        return 2
    return 0 if normalize(sys.argv[1]) == normalize(sys.argv[2]) else 1


if __name__ == "__main__":
    sys.exit(main())
