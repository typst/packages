#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = ["pillow==12.3.0", "pymupdf==1.28.2"]
# ///
"""Shrink the raster images of a compiled thesis PDF for distribution"""

from __future__ import annotations

import argparse
import io
import json
import math
import sys
from dataclasses import dataclass, field
from pathlib import Path

import pymupdf
from PIL import Image

DEFAULT_MIN_BYTES = 8192
DEFAULT_MIN_GAIN = 0.05
JPEG_MAX_DIMENSION = 65535
PRESERVED_COLORSPACES = ("DeviceRGB", "DeviceGray", "ICCBased(RGB", "ICCBased(Gray")


class OptimizationError(RuntimeError):
    pass


@dataclass
class ImageReport:
    xref: int
    action: str
    reason: str = ""
    before: int = 0
    after: int = 0
    width: int = 0
    height: int = 0
    new_width: int = 0
    new_height: int = 0
    dpi: float = 0.0


@dataclass
class Report:
    source_bytes: int = 0
    output_bytes: int = 0
    target_dpi: int = 0
    quality: int = 0
    images: list[ImageReport] = field(default_factory=list)

    @property
    def rewritten(self) -> list[ImageReport]:
        return [image for image in self.images if image.action == "rewritten"]

    def to_dict(self) -> dict:
        return {
            "source_bytes": self.source_bytes,
            "output_bytes": self.output_bytes,
            "target_dpi": self.target_dpi,
            "quality": self.quality,
            "images_total": len(self.images),
            "images_rewritten": len(self.rewritten),
            "images": [vars(image) for image in self.images],
        }


def placement_dpi(doc: pymupdf.Document) -> dict[int, float]:
    dpi: dict[int, float] = {}
    for page in doc:
        for placement in page.get_image_info(xrefs=True):
            xref = placement.get("xref", 0)
            if not xref:
                continue
            a, b, c, d, _, _ = placement["transform"]
            width_pt, height_pt = math.hypot(a, b), math.hypot(c, d)
            if width_pt <= 0 or height_pt <= 0:
                continue
            horizontal = placement["width"] / (width_pt / 72.0)
            vertical = placement["height"] / (height_pt / 72.0)
            dpi[xref] = min(dpi.get(xref, math.inf), horizontal, vertical)
    return dpi


def image_xrefs(doc: pymupdf.Document) -> list[int]:
    xrefs = []
    for xref in range(1, doc.xref_length()):
        if not doc.xref_is_stream(xref):
            continue
        if doc.xref_get_key(xref, "Subtype")[1] == "/Image":
            xrefs.append(xref)
    return xrefs


def indirect_ref(doc: pymupdf.Document, xref: int, key: str) -> int:
    kind, value = doc.xref_get_key(xref, key)
    if kind != "xref":
        return 0
    try:
        return int(value.split()[0])
    except (IndexError, ValueError):
        return 0


def soft_mask_owners(doc: pymupdf.Document, xrefs: list[int]) -> dict[int, int]:
    owners: dict[int, int] = {}
    for xref in xrefs:
        mask = indirect_ref(doc, xref, "SMask")
        if mask:
            owners[mask] = xref
    return owners


def stream_bytes(doc: pymupdf.Document, xref: int) -> int:
    try:
        return len(doc.xref_stream_raw(xref))
    except Exception:
        return 0


def target_size(width: int, height: int, dpi: float, target: int) -> tuple[int, int]:
    if target <= 0 or dpi <= target:
        return width, height
    scale = target / dpi
    return min(width, math.ceil(width * scale)), min(height, math.ceil(height * scale))


def decode(doc: pymupdf.Document, xref: int) -> tuple[Image.Image, int, str]:
    extracted = doc.extract_image(xref)
    components = int(extracted.get("colorspace", 0))
    cs_name = str(extracted.get("cs-name", ""))
    image = Image.open(io.BytesIO(extracted["image"]))
    image.load()
    if cs_name.startswith("Indexed"):
        if image.mode == "P":
            image = image.convert("RGB")
        components = {"1": 1, "L": 1, "RGB": 3}.get(image.mode, 0)
    return image, components, cs_name


def encode_jpeg(image: Image.Image, components: int, quality: int) -> tuple[bytes, str]:
    mode, colorspace = ("L", "/DeviceGray") if components == 1 else ("RGB", "/DeviceRGB")
    if image.mode != mode:
        image = image.convert(mode)
    buffer = io.BytesIO()
    image.save(buffer, format="JPEG", quality=quality, optimize=True, progressive=False)
    return buffer.getvalue(), colorspace


def encode_samples(image: Image.Image) -> tuple[bytes, str, int]:
    if image.mode != "L":
        image = image.convert("L")
    return image.tobytes(), "/DeviceGray", 8


def rewrite_soft_mask(
    doc: pymupdf.Document,
    xref: int,
    new_width: int,
    new_height: int,
    report: Report,
) -> None:
    before = stream_bytes(doc, xref)
    try:
        mask, _, _ = decode(doc, xref)
    except Exception as error:
        report.images.append(
            ImageReport(xref=xref, action="skipped", reason=f"undecodable mask: {error}")
        )
        return
    if (mask.width, mask.height) == (new_width, new_height):
        report.images.append(ImageReport(xref=xref, action="skipped", reason="mask already sized"))
        return
    resized = mask.resize((new_width, new_height), Image.LANCZOS)
    data, colorspace, bpc = encode_samples(resized)
    doc.update_stream(xref, data, new=True, compress=True)
    doc.xref_set_key(xref, "Width", str(new_width))
    doc.xref_set_key(xref, "Height", str(new_height))
    doc.xref_set_key(xref, "ColorSpace", colorspace)
    doc.xref_set_key(xref, "BitsPerComponent", str(bpc))
    doc.xref_set_key(xref, "DecodeParms", "null")
    doc.xref_set_key(xref, "Decode", "null")
    report.images.append(
        ImageReport(
            xref=xref,
            action="rewritten",
            reason="soft mask",
            before=before,
            after=stream_bytes(doc, xref),
            width=mask.width,
            height=mask.height,
            new_width=new_width,
            new_height=new_height,
        )
    )


def optimize(
    doc: pymupdf.Document,
    *,
    target_dpi: int,
    quality: int,
    min_bytes: int,
    min_gain: float,
) -> Report:
    report = Report(target_dpi=target_dpi, quality=quality)
    dpi_by_xref = placement_dpi(doc)
    xrefs = image_xrefs(doc)
    masks = soft_mask_owners(doc, xrefs)
    resampled_masks: set[int] = set()

    for xref in xrefs:
        if xref in masks:
            continue
        before = stream_bytes(doc, xref)
        entry = ImageReport(xref=xref, action="skipped", before=before)

        if doc.xref_get_key(xref, "ImageMask")[1] == "true":
            entry.reason = "stencil mask"
            report.images.append(entry)
            continue
        if doc.xref_get_key(xref, "Mask")[0] != "null":
            entry.reason = "carries an explicit mask"
            report.images.append(entry)
            continue
        if doc.xref_get_key(xref, "Decode")[0] != "null":
            entry.reason = "carries a decode array"
            report.images.append(entry)
            continue
        if before < min_bytes:
            entry.reason = "below size threshold"
            report.images.append(entry)
            continue

        dpi = dpi_by_xref.get(xref, 0.0)
        if dpi <= 0.0:
            entry.reason = "no placement found"
            report.images.append(entry)
            continue
        entry.dpi = round(dpi, 1)

        try:
            image, components, cs_name = decode(doc, xref)
        except Exception as error:
            entry.reason = f"undecodable: {error}"
            report.images.append(entry)
            continue

        entry.width, entry.height = image.width, image.height
        if components not in (1, 3):
            entry.reason = f"unsupported component count: {components}"
            report.images.append(entry)
            continue
        if max(image.width, image.height) > JPEG_MAX_DIMENSION:
            entry.reason = "exceeds JPEG dimension limit"
            report.images.append(entry)
            continue

        new_width, new_height = target_size(image.width, image.height, dpi, target_dpi)
        entry.new_width, entry.new_height = new_width, new_height
        resized = image
        if (new_width, new_height) != (image.width, image.height):
            resized = image.resize((new_width, new_height), Image.LANCZOS)

        data, colorspace = encode_jpeg(resized, components, quality)
        if len(data) > before * (1.0 - min_gain):
            entry.reason = "rewrite would not pay off"
            report.images.append(entry)
            continue

        doc.update_stream(xref, data, new=True, compress=False)
        doc.xref_set_key(xref, "Width", str(new_width))
        doc.xref_set_key(xref, "Height", str(new_height))
        if not cs_name.startswith(PRESERVED_COLORSPACES):
            doc.xref_set_key(xref, "ColorSpace", colorspace)
        doc.xref_set_key(xref, "BitsPerComponent", "8")
        doc.xref_set_key(xref, "Filter", "/DCTDecode")
        doc.xref_set_key(xref, "DecodeParms", "null")
        doc.xref_set_key(xref, "Decode", "null")

        entry.action = "rewritten"
        entry.reason = ""
        entry.after = stream_bytes(doc, xref)
        report.images.append(entry)

        mask_xref = indirect_ref(doc, xref, "SMask")
        resized_image = (new_width, new_height) != (image.width, image.height)
        if resized_image and mask_xref and mask_xref not in resampled_masks:
            resampled_masks.add(mask_xref)
            rewrite_soft_mask(doc, mask_xref, new_width, new_height, report)

    return report


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("source", type=Path, help="compiled PDF to read")
    parser.add_argument("output", type=Path, help="optimized PDF to write")
    parser.add_argument(
        "--dpi",
        type=int,
        default=300,
        help="resolution images are downsampled to, measured at their placed size (default: 300)",
    )
    parser.add_argument("--quality", type=int, default=90, help="JPEG quality, 1-100 (default: 90)")
    parser.add_argument(
        "--min-bytes",
        type=int,
        default=DEFAULT_MIN_BYTES,
        help=f"leave images whose stream is smaller than this alone (default: {DEFAULT_MIN_BYTES})",
    )
    parser.add_argument(
        "--min-gain",
        type=float,
        default=DEFAULT_MIN_GAIN,
        help=f"least fraction of a stream a rewrite must save (default: {DEFAULT_MIN_GAIN})",
    )
    parser.add_argument("--report", type=Path, help="write the per-image report here as JSON")
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv)
    if not 1 <= args.quality <= 100:
        raise OptimizationError("--quality must be between 1 and 100")
    if not args.source.is_file():
        raise OptimizationError(f"no such file: {args.source}")
    if args.source.resolve() == args.output.resolve():
        raise OptimizationError("refusing to optimize a PDF onto itself")

    doc = pymupdf.open(args.source)
    try:
        if not doc.is_pdf:
            raise OptimizationError(f"not a PDF: {args.source}")
        report = optimize(
            doc,
            target_dpi=args.dpi,
            quality=args.quality,
            min_bytes=args.min_bytes,
            min_gain=args.min_gain,
        )
        report.source_bytes = args.source.stat().st_size
        args.output.parent.mkdir(parents=True, exist_ok=True)
        doc.save(args.output, garbage=3, deflate=True, use_objstms=1, no_new_id=True)
    finally:
        doc.close()

    report.output_bytes = args.output.stat().st_size
    if args.report:
        args.report.write_text(json.dumps(report.to_dict(), indent=2) + "\n")

    saved = report.source_bytes - report.output_bytes
    ratio = saved / report.source_bytes if report.source_bytes else 0.0
    print(
        f"optimized {args.source} -> {args.output}\n"
        f"  images: {len(report.rewritten)} rewritten of {len(report.images)} inspected"
        f" at {args.dpi} dpi, JPEG quality {args.quality}\n"
        f"  size:   {report.source_bytes / 1e6:.1f} MB -> {report.output_bytes / 1e6:.1f} MB"
        f" ({ratio:.1%} smaller)"
    )
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except OptimizationError as error:
        print(f"error: {error}", file=sys.stderr)
        sys.exit(1)
