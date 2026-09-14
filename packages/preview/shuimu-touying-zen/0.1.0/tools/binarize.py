#!/usr/bin/env python3
"""Binarize an image into pure black and white.

The script converts the input to black-and-white (1-bit) *by default*: every
pixel becomes either the ink color (black) or the paper color (white), and the
default output is a real 1-bit image, i.e. an image with a two-entry palette.

Ink and paper are told apart by luminance (ITU-R BT.601 weights, the same ones
Typst uses in ``luma()``), so a threshold chosen here can be reasoned about in a
Typst document as well.

Usage
-----
    python binarize.py INPUT [INPUT ...] [options]

Examples
--------
    # hard threshold at mid grey, 1-bit PNG next to the input (campus-bw.png)
    python binarize.py campus.png

    # explicit output file and threshold
    python binarize.py campus.png --out campus-bw.png --threshold 180

    # Otsu's method picks the threshold from the histogram
    python binarize.py campus.png --threshold auto

    # smoother, anti-aliased result (grayscale PNG, still only one ink color)
    python binarize.py campus.png --antialias

    # keep the shape but force the ink to a specific color (RGB or RGBA)
    python binarize.py campus.png --ink "#660874"
    python binarize.py campus.png --ink "#66087480"     # 50% opaque ink -> RGBA
    python binarize.py campus.png --ink transparent --paper "#f2edf6"

    # RGBA input: transparency is composited onto opaque paper by default
    python binarize.py logo.png --alpha-threshold 1

    # RGBA input, keeping the transparency in the output
    python binarize.py logo.png --rgba

    # RGBA input, soft edges and transparency preserved
    python binarize.py logo.png --antialias

    # batch mode: several inputs need --output-dir (and optionally --suffix)
    python binarize.py assets/*.png --output-dir out --suffix "-bw"

    # inspect the histogram before choosing a threshold
    python binarize.py campus.png --analyze

Output colors
-------------
``--ink`` and ``--paper`` accept an alpha channel: ``#rgb``, ``#rgba``,
``#rrggbb``, ``#rrggbbaa``, ``rgb(...)``, ``rgba(...)``, ``r,g,b[,a]``, and the
keywords ``black``/``white``/``transparent``/``none``. A fractional alpha such
as ``rgba(0,0,0,0.5)`` is a 0..1 fraction; ``0`` and ``1`` are read as a 0..1
fraction too, and larger integers as 0..255. If either color is not fully
opaque the output is RGBA rather than 1-bit, since a palette cannot express it.

Alpha handling
--------------
Transparency is decided by the luminance of the stored RGB, exactly as Typst's
``luma()`` does, so a fully transparent pixel can still count as ink if its RGB
is dark. Use ``--alpha-threshold 1`` to send transparent pixels to paper, and
``--rgba`` (or ``--antialias``) to carry the source alpha into the output.

Exit status is 0 on success, 1 on error.
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

try:
    import numpy as np
    from PIL import Image, UnidentifiedImageError
except ImportError as exc:  # pragma: no cover - depends on the environment
    sys.stderr.write(
        "error: this script needs Pillow and NumPy.\n"
        "       install them with:  pip install pillow numpy\n"
        f"       ({exc})\n"
    )
    raise SystemExit(1)


# ITU-R BT.601 weights, matching Typst's `luma()`.
LUMA_WEIGHTS = np.array([0.299, 0.587, 0.114], dtype=np.float64)

# Modes whose samples are already brightness values rather than colors.
GRAYSCALE_MODES = ("1", "L", "I;16", "I", "F")


"""A color with an alpha channel, each component an int in 0..255."""

RGBA = tuple[int, int, int, int]

# CSS color keywords that are useful for ink/paper.
NAMED_COLORS: dict[str, RGBA] = {
    "black": (0, 0, 0, 255),
    "white": (255, 255, 255, 255),
    "transparent": (0, 0, 0, 0),
    "none": (0, 0, 0, 0),
}

COLOR_HELP = (
    "a color: 'black', 'white', 'transparent', '#rgb', '#rgba', '#rrggbb', "
    "'#rrggbbaa', or 'rgb(r,g,b)' / 'rgba(r,g,b,a)' / 'r,g,b[,a]'"
)


def parse_color(value: str) -> RGBA:
    """Parse a color with optional alpha into ``(r, g, b, a)``.

    Accepted forms (alpha defaults to fully opaque):

    * ``black``, ``white``, ``transparent``, ``none``
    * ``#rgb``, ``#rgba``, ``#rrggbb``, ``#rrggbbaa``
    * ``rgb(r,g,b)``, ``rgba(r,g,b,a)`` -- ``a`` is 0..255 or a 0..1 fraction
    * ``r,g,b``, ``r,g,b,a`` -- same rule for ``a``
    """
    key = value.strip().lower().replace(" ", "")
    if key in NAMED_COLORS:
        return NAMED_COLORS[key]

    def bad(reason: str) -> argparse.ArgumentTypeError:
        return argparse.ArgumentTypeError(f"invalid color {value!r}: {reason}; {COLOR_HELP}")

    # rgb(...) / rgba(...)
    if key.startswith("rgb"):
        open_paren = key.find("(")
        if open_paren == -1 or not key.endswith(")"):
            raise bad("expected rgb(...) or rgba(...)")
        parts = key[open_paren + 1 : -1].split(",")
    elif key.startswith("#"):
        parts = _hex_parts(key[1:], bad)
    elif "," not in key and len(key) in (3, 4, 6, 8):
        # Bare hex digits, e.g. `660874` or `660874ff`.
        parts = _hex_parts(key, bad)
    else:
        parts = key.split(",")

    if len(parts) not in (3, 4):
        raise bad(f"expected 3 or 4 components, got {len(parts)}")

    try:
        rgb = [int(round(float(p))) for p in parts[:3]]
    except ValueError:
        raise bad("channels must be numbers") from None
    if any(c < 0 or c > 255 for c in rgb):
        raise bad("color channels must be within 0..255")

    alpha = 255
    if len(parts) == 4:
        try:
            raw = float(parts[3])
        except ValueError:
            raise bad("alpha must be a number") from None
        if 0.0 <= raw <= 1.0 and "." in parts[3]:
            # A fractional alpha such as 0.5 is a 0..1 fraction, not 0..255.
            alpha = int(round(raw * 255))
        elif 0.0 <= raw <= 1.0:
            alpha = int(round(raw * 255))
        elif raw.is_integer() and 0 <= raw <= 255:
            alpha = int(raw)
        else:
            raise bad("alpha must be within 0..1 or 0..255")

    return (rgb[0], rgb[1], rgb[2], alpha)


def _hex_parts(digits: str, bad) -> list[str]:
    """Expand a hex color (3/4/6/8 digits) into decimal component strings."""
    if len(digits) in (3, 4):
        digits = "".join(c * 2 for c in digits)
    if len(digits) not in (6, 8):
        raise bad("hex colors need 3, 4, 6, or 8 digits")
    try:
        channel = [int(digits[i : i + 2], 16) for i in range(0, len(digits), 2)]
    except ValueError:
        raise bad("not valid hexadecimal") from None
    return [str(c) for c in channel]


def load_plane(path: Path) -> tuple[np.ndarray, np.ndarray]:
    """Return ``(luma, alpha)`` as float arrays in 0..255, luma unmultiplied.

    Luma is computed from the color channels only, ignoring alpha, so a pixel
    that is fully transparent still reports its stored color.
    """
    try:
        with Image.open(path) as handle:
            handle.load()
            has_alpha = (
                "A" in handle.getbands()
                or (handle.mode == "P" and "transparency" in handle.info)
            )
            if handle.mode in GRAYSCALE_MODES:
                # Single-channel data: use it as luminance directly.
                data = np.asarray(handle.convert("F"), dtype=np.float64)
                alpha = np.full(data.shape, 255.0)
                # `convert("F")` on a mode "1" image yields 0/1, not 0/255.
                if handle.mode == "1":
                    data = data * 255.0
                return data, alpha

            rgba = handle.convert("RGBA")
            data = np.asarray(rgba, dtype=np.float64)
            alpha = data[..., 3]
            luma = data[..., :3] @ LUMA_WEIGHTS
            if not has_alpha:
                # No transparency in the source; treat every pixel as opaque.
                alpha = np.full(luma.shape, 255.0)
            return luma, alpha
    except UnidentifiedImageError:
        raise SystemExit(
            f"error: {path} is not a bitmap image Pillow can read. "
            "Convert vector sources (SVG, PDF) to PNG first, for example:\n"
            f"  typst compile --format png {path} {path.with_suffix('.png')}"
        ) from None
    except OSError as exc:
        raise SystemExit(f"error: could not read {path}: {exc}") from None


def otsu_threshold(luma: np.ndarray, bins: int = 256) -> int:
    """Return the threshold that maximizes between-class variance (Otsu)."""
    hist, _ = np.histogram(luma, bins=bins, range=(0.0, 256.0))
    hist = hist.astype(np.float64)
    total = hist.sum()
    if total == 0:
        return 128

    levels = np.arange(bins, dtype=np.float64)
    weight_bg = np.cumsum(hist)
    weight_fg = total - weight_bg
    sum_total = float((hist * levels).sum())
    sum_bg = np.cumsum(hist * levels)

    valid = (weight_bg > 0) & (weight_fg > 0)
    if not valid.any():
        return 128

    mean_bg = np.divide(sum_bg, weight_bg, out=np.zeros(bins), where=weight_bg > 0)
    mean_fg = np.divide(
        sum_total - sum_bg, weight_fg, out=np.zeros(bins), where=weight_fg > 0
    )
    variance = weight_bg * weight_fg * (mean_bg - mean_fg) ** 2
    variance[~valid] = -1.0
    return int(np.argmax(variance))


def coverage_curve(luma: np.ndarray, steps: int = 17) -> str:
    """Describe how much ink each threshold would produce."""
    rows = ["    threshold   ink coverage", "    ---------   ------------"]
    for threshold in np.linspace(0, 255, steps):
        ink = float((luma < threshold).mean() * 100.0)
        rows.append(f"    {threshold:9.1f}   {ink:11.2f}%")
    return "\n".join(rows)


def binarize(
    luma: np.ndarray,
    alpha: np.ndarray,
    threshold: float,
    ink: RGBA,
    paper: RGBA,
    alpha_threshold: int | None,
    antialias: bool,
    keep_alpha: bool = False,
) -> tuple[Image.Image, float]:
    """Build the binary output image and report the resulting ink coverage.

    ``ink`` and ``paper`` are RGBA. When either is not fully opaque the result
    is RGBA as well, because a palette entry is a single flat color and PNG
    would render a transparent entry as invisible.

    With ``antialias`` the result is a single ink color whose alpha carries the
    coverage; otherwise the result is a palette image indexed so that every
    pixel is exactly the ink or the paper color. ``keep_alpha`` forces the RGBA
    shape even for a hard threshold, so the transparency of the *source*
    survives alongside the colors.
    """
    is_ink = luma < threshold
    if alpha_threshold is not None:
        is_ink &= alpha >= alpha_threshold

    ink_rgb = np.array(ink[:3], dtype=np.uint8)
    paper_rgb = np.array(paper[:3], dtype=np.uint8)
    ink_alpha = ink[3]
    paper_alpha = paper[3]

    # A palette entry is one flat color and PNG treats a transparent entry as
    # invisible, so any visible transparency in ink or paper forces RGBA output.
    needs_rgba = keep_alpha or antialias or ink_alpha != 255 or paper_alpha != 255

    if antialias:
        # Ink coverage in 0..1, later used as the alpha of a flat ink layer.
        coverage = np.clip((threshold - luma) / 255.0, 0.0, 1.0)
        if alpha_threshold is not None:
            coverage = np.where(alpha >= alpha_threshold, coverage, 0.0)
        else:
            # Without an explicit alpha rule, a pixel that is transparent in the
            # source cannot become opaque ink, however dark its stored RGB is.
            coverage = coverage * (alpha / 255.0)
        # The requested ink alpha scales the coverage the mask produces.
        coverage = coverage * (ink_alpha / 255.0)
        rgba = np.empty((*luma.shape, 4), dtype=np.uint8)
        rgba[..., :3] = ink_rgb
        rgba[..., 3] = np.rint(coverage * 255.0).astype(np.uint8)
        return Image.fromarray(rgba), float(coverage.mean() * 100.0)

    if needs_rgba:
        rgba = np.empty((*luma.shape, 4), dtype=np.uint8)
        rgba[..., :3] = np.where(is_ink[..., None], ink_rgb, paper_rgb)
        out_alpha = np.where(is_ink, ink_alpha, paper_alpha).astype(np.uint8)
        if keep_alpha:
            # Also carry the transparency of the source, without ever letting a
            # fully transparent source pixel become visible.
            out_alpha = np.minimum(out_alpha, alpha.astype(np.uint8))
        rgba[..., 3] = out_alpha
        return Image.fromarray(rgba), float(is_ink.mean() * 100.0)

    # Both colors are opaque, so a semi-transparent ink would have been
    # composited already; anything reaching here is flat and palette-safe.

    # Hard 1-bit image. Two flat colors are built explicitly and the palette is
    # indexed by the mask, which keeps the shape exact and stores 1 bit per
    # pixel in PNG (and in WebP/GIF, which support two-entry palettes too).
    indices = np.where(is_ink, 0, 1).astype(np.uint8)
    out = Image.frombytes("P", (luma.shape[1], luma.shape[0]), indices.tobytes())
    out.putpalette(ink_rgb.tolist() + paper_rgb.tolist() + [0] * 762)
    return out, float(is_ink.mean() * 100.0)


# Formats that cannot carry a palette entry, so a 1-bit image has to be stored
# as two-tone luminance instead. The second set stores luminance losslessly.
FORMATS_WITHOUT_PALETTE = {
    ".jpg", ".jpeg", ".jpe", ".bmp", ".tif", ".tiff", ".pcx", ".ppm",
}
LOSSLESS_WITHOUT_PALETTE = {".bmp", ".tif", ".tiff", ".pcx", ".ppm"}

# Formats with no alpha channel at all.
FORMATS_WITHOUT_ALPHA = {".jpg", ".jpeg", ".jpe", ".bmp", ".pcx", ".ppm"}


def save_image(result: Image.Image, target: Path) -> str:
    """Write ``result`` to ``target`` and return a note about what was written.

    A one-bit image is only meaningful for formats that keep a palette or a
    bilevel sample depth, and JPEG keeps neither a palette nor an alpha
    channel. Where a format cannot represent the result exactly, the image is
    converted to the closest lossless form and the change is reported.
    """
    suffix = target.suffix.lower()
    note = ""

    if result.mode == "P" and suffix in FORMATS_WITHOUT_PALETTE:
        result = result.convert("L")
        if suffix in LOSSLESS_WITHOUT_PALETTE:
            note = f" (two-tone grey; {suffix} has no palette)"
        else:
            note = (
                f" (two-tone grey; {suffix} cannot store 1-bit, "
                "use PNG for a truly binary file)"
            )
    elif result.mode == "RGBA" and suffix in FORMATS_WITHOUT_ALPHA:
        # JPEG flattens onto white; anything else keeps the colors without alpha.
        if suffix in {".jpg", ".jpeg", ".jpe"}:
            background = Image.new("RGB", result.size, (255, 255, 255))
            background.paste(result, mask=result.getchannel("A"))
            result = background
            note = f" ({suffix} has no alpha channel; flattened onto white)"
        else:
            result = result.convert("RGB")
            note = f" ({suffix} has no alpha channel; alpha dropped)"
    elif result.mode == "P" and suffix == ".png":
        # Store one bit per pixel instead of one byte per pixel.
        result.encoderinfo = {"bits": 1}

    if suffix in {".jpg", ".jpeg", ".jpe"}:
        result.save(target, quality=95, subsampling=0)
    else:
        result.save(target, optimize=True)
    return note


def output_path_for(
    source: Path,
    output: Path | None,
    suffix: str,
    directory: Path | None,
) -> Path:
    """Decide where one result is written.

    ``--out`` wins over ``--output-dir``/``--suffix``; ``--output-dir`` always
    means "a directory", so there is never any guessing about intent.
    """
    if output is not None:
        return output
    if not suffix:
        raise SystemExit("error: --suffix must not be empty")
    target_dir = directory if directory is not None else source.parent
    candidate = target_dir / f"{source.stem}{suffix}{source.suffix}"
    if candidate.resolve() == source.resolve():
        raise SystemExit(
            f"error: the output path {candidate} is the input file; "
            "choose another --suffix/--output-dir or pass --out."
        )
    return candidate


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="binarize.py",
        description="Convert images to pure black and white (1-bit by default).",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__.split("Usage\n-----\n", 1)[-1],
    )
    parser.add_argument(
        "input",
        nargs="+",
        type=Path,
        help="input image file(s); with more than one, use --output-dir and --suffix",
    )
    parser.add_argument(
        "-O",
        "--out",
        type=Path,
        metavar="FILE",
        help="output file (single input only)",
    )
    parser.add_argument(
        "-d",
        "--output-dir",
        "--outdir",
        type=Path,
        metavar="DIR",
        help="directory for the results (default: next to each input)",
    )
    parser.add_argument(
        "--suffix",
        default="-bw",
        help="suffix added to the input stem when no --out is given (default: -bw)",
    )
    parser.add_argument(
        "--threshold",
        default="128",
        help="luma threshold in 0..255, or 'auto' for Otsu (default: 128)",
    )
    parser.add_argument(
        "--alpha-threshold",
        type=int,
        default=None,
        metavar="N",
        help="treat pixels with alpha below N as paper (default: off)",
    )
    parser.add_argument(
        "--ink",
        type=parse_color,
        default=(0, 0, 0, 255),
        metavar="COLOR",
        help=f"ink color, RGBA allowed (default: black). {COLOR_HELP}",
    )
    parser.add_argument(
        "--paper",
        type=parse_color,
        default=(255, 255, 255, 255),
        metavar="COLOR",
        help=f"paper color, RGBA allowed (default: white). {COLOR_HELP}",
    )
    parser.add_argument(
        "--antialias",
        action="store_true",
        help="keep soft edges (RGBA output instead of 1-bit)",
    )
    parser.add_argument(
        "--rgba",
        action="store_true",
        help=(
            "write RGBA: hard ink/paper colors, but keep the transparency of the "
            "source instead of compositing it onto opaque paper"
        ),
    )
    parser.add_argument(
        "--invert",
        action="store_true",
        help="swap ink and paper",
    )
    parser.add_argument(
        "--analyze",
        action="store_true",
        help="print a luminance histogram and an ink-coverage table, then stop",
    )
    parser.add_argument(
        "--overwrite", action="store_true", help="allow overwriting existing output files"
    )
    parser.add_argument("-q", "--quiet", action="store_true", help="print nothing on success")
    return parser


def resolve_threshold(spec: str, luma: np.ndarray, quiet: bool) -> tuple[float, str]:
    if spec.strip().lower() in {"auto", "otsu"}:
        value = float(otsu_threshold(luma))
        return value, "Otsu"
    try:
        value = float(spec)
    except ValueError:
        raise SystemExit(f"error: --threshold expects a number or 'auto', got {spec!r}")
    if not 0 <= value <= 255:
        raise SystemExit("error: --threshold must be within 0..255")
    return value, "fixed"


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)

    for source in args.input:
        if not source.is_file():
            raise SystemExit(f"error: no such file: {source}")

    if len(args.input) > 1 and args.out is not None:
        raise SystemExit(
            "error: --out takes a single input; "
            "use --output-dir plus --suffix for several files"
        )

    if args.alpha_threshold is not None and not 0 <= args.alpha_threshold <= 255:
        raise SystemExit("error: --alpha-threshold must be within 0..255")

    for source in args.input:
        luma, alpha = load_plane(source)

        if args.analyze:
            print(f"{source}  ({luma.shape[1]}x{luma.shape[0]})")
            counts, edges = np.histogram(luma, bins=8, range=(0.0, 256.0))
            for i, count in enumerate(counts):
                share = count / luma.size * 100.0
                print(f"    luma {edges[i]:5.0f}-{edges[i + 1]:5.0f}: {share:6.2f}%")
            print(coverage_curve(luma))
            continue

        threshold, how = resolve_threshold(args.threshold, luma, args.quiet)

        ink, paper = args.ink, args.paper
        if args.invert:
            ink, paper = paper, ink

        result, ink_share = binarize(
            luma,
            alpha,
            threshold,
            ink=ink,
            paper=paper,
            alpha_threshold=args.alpha_threshold,
            antialias=args.antialias,
            keep_alpha=args.rgba,
        )

        target = output_path_for(
            source,
            args.out if len(args.input) == 1 else None,
            args.suffix,
            args.output_dir,
        )
        target.parent.mkdir(parents=True, exist_ok=True)
        if target.exists() and not args.overwrite:
            raise SystemExit(f"error: {target} already exists; pass --overwrite")
        note = save_image(result, target)

        if not args.quiet:
            if result.mode == "RGBA":
                label = "RGBA (anti-aliased)" if args.antialias else "RGBA (keeps alpha)"
            else:
                label = "1-bit"
            alpha_note = (
                f", alpha>={args.alpha_threshold}" if args.alpha_threshold is not None else ""
            )
            print(
                f"{source} -> {target}  [{label}, threshold {threshold:g} ({how}), "
                f"{luma.shape[1]}x{luma.shape[0]}, ink {ink_share:.2f}%"
                f"{alpha_note}]{note}"
            )

    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except BrokenPipeError:  # pragma: no cover
        raise SystemExit(0)
