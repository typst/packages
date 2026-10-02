#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = ["numpy==2.5.3", "pymupdf==1.28.2"]
# ///
"""Prove that the optimized thesis PDF is still the document that was compiled"""

from __future__ import annotations

import argparse
import contextlib
import io
import math
import os
import sys
import tempfile
from dataclasses import dataclass
from pathlib import Path

import numpy as np
import pymupdf

CATALOG_KEYS = (
    "StructTreeRoot",
    "MarkInfo",
    "Lang",
    "Outlines",
    "Names",
    "PageLabels",
    "Metadata",
    "ViewerPreferences",
)


@dataclass
class Failure:
    check: str
    detail: str

    def __str__(self) -> str:
        return f"{self.check}: {self.detail}"


@contextlib.contextmanager
def captured_diagnostics():
    collected: list[str] = []
    handler = io.StringIO()
    with tempfile.TemporaryFile(mode="w+") as raw:
        pymupdf.set_messages(stream=handler)
        pymupdf.TOOLS.mupdf_display_warnings(True)
        sys.stderr.flush()
        saved = os.dup(2)
        try:
            os.dup2(raw.fileno(), 2)
            yield collected
        finally:
            sys.stderr.flush()
            os.dup2(saved, 2)
            os.close(saved)
            pymupdf.set_messages(stream=sys.stderr)
            raw.seek(0)
            collected.append(handler.getvalue())
            collected.append(raw.read())


def complaints_in(text: str) -> set[str]:
    return {
        line.strip()
        for line in text.splitlines()
        if "error" in line.lower() or "warning" in line.lower()
    }


def rendering_complaints(path: Path, dpi: int) -> set[str]:
    with captured_diagnostics() as collected:
        doc = pymupdf.open(path)
        try:
            for number in range(doc.page_count):
                doc[number].get_pixmap(dpi=dpi, colorspace=pymupdf.csRGB, alpha=False)
        finally:
            doc.close()
    return complaints_in("".join(collected))


def catalog_shape(doc: pymupdf.Document) -> dict[str, str]:
    catalog = doc.pdf_catalog()
    return {key: doc.xref_get_key(catalog, key)[0] for key in CATALOG_KEYS}


def link_summary(page: pymupdf.Page) -> list[tuple]:
    summary = []
    for link in page.get_links():
        rect = link["from"]
        summary.append((
            link.get("kind"),
            link.get("uri") or link.get("page"),
            round(rect.x0, 1),
            round(rect.y0, 1),
            round(rect.x1, 1),
            round(rect.y1, 1),
        ))
    return sorted(summary, key=repr)


def psnr(reference: np.ndarray, candidate: np.ndarray) -> float:
    error = np.mean((reference.astype(np.float64) - candidate.astype(np.float64)) ** 2)
    if error == 0.0:
        return math.inf
    return 10.0 * math.log10(255.0**2 / error)


def page_pixels(doc: pymupdf.Document, number: int, dpi: int) -> np.ndarray:
    pixmap = doc[number].get_pixmap(dpi=dpi, colorspace=pymupdf.csRGB, alpha=False)
    return np.frombuffer(pixmap.samples, dtype=np.uint8).reshape(
        pixmap.height, pixmap.width, 3
    )


def image_regions(page: pymupdf.Page, dpi: int, shape: tuple[int, ...]) -> list[tuple]:
    scale = dpi / 72
    regions = []
    for info in page.get_image_info():
        x0, y0, x1, y1 = info["bbox"]
        origin = page.rect.tl
        top = max(0, round((y0 - origin.y) * scale))
        bottom = min(shape[0], round((y1 - origin.y) * scale))
        left = max(0, round((x0 - origin.x) * scale))
        right = min(shape[1], round((x1 - origin.x) * scale))
        if bottom - top >= 8 and right - left >= 8:
            regions.append((slice(top, bottom), slice(left, right)))
    return regions


def placement_resolutions(page: pymupdf.Page) -> list[float]:
    resolutions = []
    for info in page.get_image_info():
        a, b, c, d, _, _ = info["transform"]
        width_pt, height_pt = math.hypot(a, b), math.hypot(c, d)
        if width_pt <= 0 or height_pt <= 0:
            resolutions.append(math.inf)
            continue
        resolutions.append(
            min(info["width"] * 72 / width_pt, info["height"] * 72 / height_pt)
        )
    return resolutions


def compare(
    source: Path,
    candidate: Path,
    *,
    render_dpi: int,
    min_psnr: float,
    min_image_psnr: float,
    max_bytes: int,
    min_dpi: int,
) -> list[Failure]:
    failures: list[Failure] = []

    size = candidate.stat().st_size
    if max_bytes and size > max_bytes:
        failures.append(
            Failure(
                "size budget",
                f"{size / 1e6:.1f} MB exceeds the {max_bytes / 1e6:.1f} MB budget",
            )
        )

    inherited = rendering_complaints(source, render_dpi)

    with captured_diagnostics() as diagnostics:
        original = pymupdf.open(source)
        optimized = pymupdf.open(candidate)
        try:
            if original.page_count != optimized.page_count:
                failures.append(
                    Failure(
                        "page count",
                        f"{original.page_count} became {optimized.page_count}",
                    )
                )
                return failures

            before, after = catalog_shape(original), catalog_shape(optimized)
            for key in CATALOG_KEYS:
                if before[key] != "null" and after[key] == "null":
                    failures.append(Failure("catalog", f"/{key} was dropped"))

            if original.get_toc(simple=False) != optimized.get_toc(simple=False):
                failures.append(Failure("outline", "the bookmark tree changed"))

            for field in ("title", "author", "subject", "keywords"):
                if original.metadata.get(field) != optimized.metadata.get(field):
                    failures.append(Failure("metadata", f"{field} changed"))

            text_changed, links_changed, coarse, compared = [], [], [], 0
            worst, worst_image = (math.inf, 0), (math.inf, 0)
            for number in range(original.page_count):
                if original[number].get_text("text") != optimized[number].get_text(
                    "text"
                ):
                    text_changed.append(number + 1)
                if link_summary(original[number]) != link_summary(optimized[number]):
                    links_changed.append(number + 1)
                if min_dpi:
                    before = placement_resolutions(original[number])
                    after = placement_resolutions(optimized[number])
                    if len(before) != len(after) or any(
                        new < min(old, min_dpi) * 0.99 - 1.0
                        for old, new in zip(before, after, strict=True)
                    ):
                        coarse.append(number + 1)

                reference = page_pixels(original, number, render_dpi)
                rendered = page_pixels(optimized, number, render_dpi)
                if reference.shape != rendered.shape:
                    failures.append(
                        Failure("page size", f"page {number + 1} changed size")
                    )
                    continue
                compared += 1
                score = psnr(reference, rendered)
                if score < worst[0]:
                    worst = (score, number + 1)
                for region in image_regions(
                    original[number], render_dpi, reference.shape
                ):
                    score = psnr(reference[region], rendered[region])
                    if score < worst_image[0]:
                        worst_image = (score, number + 1)

            if text_changed:
                failures.append(
                    Failure("text", f"differs on pages {summarize(text_changed)}")
                )
            if links_changed:
                failures.append(
                    Failure("links", f"differ on pages {summarize(links_changed)}")
                )
            if coarse:
                failures.append(
                    Failure(
                        "resolution",
                        f"images fall below {min_dpi} dpi on pages {summarize(coarse)}",
                    )
                )
            if worst[0] < min_psnr:
                failures.append(
                    Failure(
                        "fidelity",
                        f"page {worst[1]} renders at {worst[0]:.1f} dB,"
                        f" below the {min_psnr:.1f} dB floor",
                    )
                )
            if worst_image[0] < min_image_psnr:
                failures.append(
                    Failure(
                        "fidelity",
                        f"an image on page {worst_image[1]} renders at {worst_image[0]:.1f} dB,"
                        f" below the {min_image_psnr:.1f} dB floor for images",
                    )
                )
            if compared and math.isinf(worst[0]):
                print(f"  fidelity: every page renders identically at {render_dpi} dpi")
            elif compared:
                print(
                    f"  fidelity: worst page {worst[1]} at {worst[0]:.1f} dB"
                    f" (floor {min_psnr:.1f} dB), worst image at {worst_image[0]:.1f} dB"
                    f" (floor {min_image_psnr:.1f} dB), rendered at {render_dpi} dpi"
                )
        finally:
            original.close()
            optimized.close()

    complaints = sorted(complaints_in("".join(diagnostics)) - inherited)
    if complaints:
        failures.append(
            Failure(
                "interpreter",
                "; ".join(complaints[:5]) + (" ..." if len(complaints) > 5 else ""),
            )
        )

    if max_bytes:
        print(f"  size:     {size / 1e6:.1f} MB of the {max_bytes / 1e6:.1f} MB budget")
    else:
        print(f"  size:     {size / 1e6:.1f} MB, no budget")
    return failures


def summarize(numbers: list[int]) -> str:
    shown = ", ".join(str(number) for number in numbers[:10])
    return shown + (f" (+{len(numbers) - 10} more)" if len(numbers) > 10 else "")


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("source", type=Path, help="PDF as compiled by Typst")
    parser.add_argument(
        "candidate", type=Path, help="PDF that is about to be published"
    )
    parser.add_argument(
        "--max-bytes",
        type=int,
        default=25_000_000,
        help="largest acceptable published file, 0 for no limit (default: 25000000)",
    )
    parser.add_argument(
        "--render-dpi",
        type=int,
        default=110,
        help="resolution the pages are compared at (default: 110)",
    )
    parser.add_argument(
        "--min-psnr",
        type=float,
        default=30.0,
        help="lowest acceptable per-page PSNR in dB (default: 30)",
    )
    parser.add_argument(
        "--min-dpi",
        type=int,
        default=0,
        help="lowest acceptable resolution of an image as placed, unless it was"
        " compiled lower; 0 for no check (default: 0)",
    )
    parser.add_argument(
        "--min-image-psnr",
        type=float,
        default=20.0,
        help="lowest acceptable PSNR in dB of each image as placed on its page (default: 20)",
    )
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv)
    for path in (args.source, args.candidate):
        if not path.is_file():
            print(f"error: no such file: {path}", file=sys.stderr)
            return 1
    print(f"checking {args.candidate} against {args.source}")
    failures = compare(
        args.source,
        args.candidate,
        render_dpi=args.render_dpi,
        min_psnr=args.min_psnr,
        min_image_psnr=args.min_image_psnr,
        max_bytes=args.max_bytes,
        min_dpi=args.min_dpi,
    )
    if failures:
        print(f"{len(failures)} check(s) failed:", file=sys.stderr)
        for failure in failures:
            print(f"  - {failure}", file=sys.stderr)
        return 1
    print("all checks passed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
