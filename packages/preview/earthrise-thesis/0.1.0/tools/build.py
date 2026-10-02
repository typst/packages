#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = ["pymupdf==1.28.2"]
# ///
"""Compile the print and digital editions of a thesis"""

from __future__ import annotations

import argparse
import hashlib
import os
import shlex
import shutil
import signal
import subprocess
import sys
import tempfile
import tomllib
from contextlib import ExitStack
from dataclasses import dataclass
from pathlib import Path

import pymupdf

TOOLS = Path(__file__).resolve().parent
EDITIONS = ("print", "digital")
TESTED_TYPST = "0.15.1"


@dataclass(frozen=True)
class Budget:
    dpi: int
    quality: int
    max_bytes: int


BUDGETS = {
    "print": Budget(dpi=300, quality=95, max_bytes=30_000_000),
    "digital": Budget(dpi=300, quality=90, max_bytes=25_000_000),
}
MIN_PSNR = 30.0

LAYOUT_HEADER = """\
# Layout fingerprint of the print edition: one SHA-256 per page over every word
# and image together with its position, rounded to 0.1 pt. The build fails when
# the compiled print edition differs from it. After an intended change to the
# printed layout, regenerate it by rerunning build.py with --update-layout.
"""


class BuildError(RuntimeError):
    pass


RUNNING: list[subprocess.Popen] = []


def run(
    command: list[str], *, capture_output: bool = False, **kwargs
) -> subprocess.CompletedProcess:
    print("+ " + shlex.join(str(part) for part in command), flush=True)
    if capture_output:
        kwargs.update(stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    try:
        process = subprocess.Popen(command, **kwargs)
    except FileNotFoundError as error:
        raise BuildError(
            f"{command[0]} is not on PATH; install it as the README describes"
        ) from error
    with process:
        RUNNING.append(process)
        try:
            stdout, stderr = process.communicate()
        finally:
            RUNNING.remove(process)
    return subprocess.CompletedProcess(command, process.returncode, stdout, stderr)


def terminate(*_) -> None:
    for process in RUNNING:
        process.terminate()
    sys.exit(143)


def uv_script(script: str, *args: object) -> None:
    result = run(
        [
            "uv",
            "run",
            "--quiet",
            "--no-project",
            "--script",
            TOOLS / script,
            *map(str, args),
        ],
        env={**os.environ, "PYTHONUNBUFFERED": "1"},
    )
    if result.returncode != 0:
        raise BuildError(
            f"{script} failed with exit code {result.returncode};"
            " its output above names the cause"
        )


def compile_edition(
    source: Path,
    root: Path,
    fonts: Path,
    edition: str,
    output: Path,
    package_path: Path | None = None,
) -> None:
    packages = ["--package-path", package_path] if package_path else []
    result = run(
        [
            "typst",
            "compile",
            "--root",
            root,
            "--font-path",
            fonts,
            "--ignore-system-fonts",
            *packages,
            "--input",
            f"edition={edition}",
            source,
            output,
        ],
        capture_output=True,
        encoding="utf-8",
        errors="replace",
        env={**os.environ, "NO_COLOR": "1"},
    )
    sys.stderr.write(result.stderr)
    if result.returncode != 0:
        raise BuildError(
            f"typst failed on the {edition} edition with exit code {result.returncode};"
            " fix the error printed above and rebuild"
        )
    warnings = [
        line for line in result.stderr.splitlines() if line.startswith("warning:")
    ]
    if warnings:
        raise BuildError(
            f"typst reported {len(warnings)} warning(s) on the {edition} edition;"
            " fix the warnings printed above and rebuild"
        )
    if not output.is_file() or output.read_bytes()[:5] != b"%PDF-":
        raise BuildError(f"typst did not write a PDF for the {edition} edition")


def add_print_preferences(path: Path) -> None:
    with pymupdf.open(path) as document:
        catalog = document.pdf_catalog()
        document.xref_set_key(catalog, "ViewerPreferences/PrintScaling", "/None")
        document.xref_set_key(
            catalog, "ViewerPreferences/Duplex", "/DuplexFlipLongEdge"
        )
        document.save(
            path, incremental=True, encryption=pymupdf.PDF_ENCRYPT_KEEP, no_new_id=True
        )


def serve_local_package(package: Path, packages: Path) -> None:
    manifest = package / "typst.toml"
    try:
        info = tomllib.loads(manifest.read_text())["package"]
        name, version = info["name"], info["version"]
    except (OSError, tomllib.TOMLDecodeError, KeyError, TypeError) as error:
        raise BuildError(
            f"--local-package needs a typst.toml with a package name and version: {manifest}"
        ) from error
    link = packages / "preview" / name / version
    link.parent.mkdir(parents=True)
    link.symlink_to(package, target_is_directory=True)
    print(f"serving {package} as @preview/{name}:{version}", flush=True)


def layout_fingerprint(path: Path) -> list[str]:
    lines = []
    with pymupdf.open(path) as document:
        for page in document:
            parts = [f"{page.rect.width:.1f}x{page.rect.height:.1f}"]
            parts += [
                f"{word[4]}@{word[0]:.1f},{word[1]:.1f}"
                for word in page.get_text("words", sort=False)
            ]
            parts += [
                "img@" + ",".join(f"{value:.1f}" for value in image["bbox"])
                for image in page.get_image_info()
            ]
            digest = hashlib.sha256("|".join(parts).encode()).hexdigest()
            lines.append(f"{page.number + 1} {digest}")
    return lines


def check_layout(path: Path, layout: Path, update: bool) -> list[str] | None:
    found = layout_fingerprint(path)
    if update:
        return found
    if not layout.is_file():
        raise BuildError(
            f"no layout fingerprint at {layout}; create it with --update-layout"
        )
    expected = [
        line
        for line in layout.read_text().splitlines()
        if line.strip() and not line.startswith("#")
    ]
    if len(found) != len(expected):
        raise BuildError(
            f"the print edition has {len(found)} pages, the fingerprint {len(expected)};"
            " if that is intended, rerun with --update-layout"
        )
    changed = [
        line.split()[0]
        for line, want in zip(found, expected, strict=True)
        if line != want
    ]
    if changed:
        raise BuildError(
            f"the print layout changed on page(s) {', '.join(changed)} of {len(found)};"
            " if that is intended, rerun with --update-layout"
        )
    print(f"print layout matches {layout} on all {len(found)} pages")
    return None


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=__doc__.splitlines()[0],
        epilog="Budgets: "
        + "; ".join(
            f"{name} {b.dpi} dpi, JPEG quality {b.quality}, at most {b.max_bytes / 1e6:.0f} MB"
            for name, b in BUDGETS.items()
        ),
    )
    parser.add_argument("source", type=Path, help="Typst file of the thesis")
    parser.add_argument(
        "--root", type=Path, help="Typst project root (default: the source's directory)"
    )
    parser.add_argument(
        "--edition",
        choices=EDITIONS,
        action="append",
        help="edition to build; repeat for several (default: both)",
    )
    parser.add_argument(
        "--out-dir",
        type=Path,
        help="where the PDFs are written (default: the project root)",
    )
    parser.add_argument(
        "--name", help="file name stem of the PDFs (default: the source's stem)"
    )
    parser.add_argument(
        "--fonts", type=Path, help="pinned font directory (default: <root>/.fonts)"
    )
    parser.add_argument(
        "--optimize",
        action="store_true",
        help="also write and verify downsampled copies under the plain names",
    )
    parser.add_argument(
        "--layout", type=Path, help="layout fingerprint the print edition must match"
    )
    parser.add_argument(
        "--local-package",
        type=Path,
        help="serve the Typst package in this directory under the name and version in its"
        " typst.toml, to build a template's example before publishing it",
    )
    parser.add_argument(
        "--update-layout",
        action="store_true",
        help="rewrite the --layout fingerprint from this build instead of checking it",
    )
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv)
    source = args.source.resolve()
    if not source.is_file():
        raise BuildError(f"no such file: {args.source}")
    root = (args.root or source.parent).resolve()
    out_dir = (args.out_dir or root).resolve()
    fonts = (args.fonts or root / ".fonts").resolve()
    name = args.name or source.stem
    if Path(name).name != name or name in ("", ".", ".."):
        raise BuildError(f"--name must be a file name stem, not a path: {name}")
    editions = list(dict.fromkeys(args.edition or EDITIONS))
    if args.update_layout and not args.layout:
        raise BuildError("--update-layout needs --layout")
    if args.layout and "print" not in editions:
        raise BuildError("--layout checks the print edition; build it too")
    layout = args.layout.resolve() if args.layout else None
    local_package = args.local_package.resolve() if args.local_package else None
    if local_package and not local_package.is_dir():
        raise BuildError(f"no such directory: {args.local_package}")
    if out_dir.exists() and not out_dir.is_dir():
        raise BuildError(f"--out-dir is not a directory: {out_dir}")
    if layout and layout.exists() and not layout.is_file():
        raise BuildError(f"--layout is not a file: {layout}")

    version = run(["typst", "--version"], capture_output=True, text=True)
    if version.returncode != 0:
        raise BuildError(f"typst --version failed; reinstall Typst {TESTED_TYPST}")
    print(version.stdout.strip())
    if not version.stdout.startswith(f"typst {TESTED_TYPST} "):
        print(
            f"note: the template is tested with Typst {TESTED_TYPST}; other versions may"
            f" lay out the document differently, so install {TESTED_TYPST} to match",
            flush=True,
        )
    uv_script("fetch_fonts.py", "--dest", fonts)

    out_dir.mkdir(parents=True, exist_ok=True)
    with ExitStack() as stack:
        package_path = None
        if local_package:
            package_path = Path(stack.enter_context(tempfile.TemporaryDirectory()))
            serve_local_package(local_package, package_path)
        staging = Path(
            stack.enter_context(
                tempfile.TemporaryDirectory(prefix=f".{name}-build.", dir=out_dir)
            )
        )
        produced = []
        new_layout = None
        for edition in editions:
            stem = name if edition == "digital" else f"{name}_{edition}"
            master = staging / f"{stem}_full.pdf"
            compile_edition(source, root, fonts, edition, master, package_path)
            if edition == "print":
                add_print_preferences(master)
                if layout:
                    new_layout = check_layout(master, layout, args.update_layout)
            produced.append(master)

            if args.optimize:
                budget = BUDGETS[edition]
                small = staging / f"{stem}.pdf"
                uv_script(
                    "optimize_pdf.py",
                    master,
                    small,
                    "--dpi",
                    budget.dpi,
                    "--quality",
                    budget.quality,
                )
                uv_script(
                    "check_pdf.py",
                    master,
                    small,
                    "--max-bytes",
                    budget.max_bytes,
                    "--min-psnr",
                    MIN_PSNR,
                    "--min-dpi",
                    budget.dpi,
                )
                produced.append(small)

        for path in produced:
            destination = out_dir / path.name
            if destination.exists() and not destination.is_file():
                raise BuildError(f"cannot replace a non-file output: {destination}")
        for path in produced:
            destination = out_dir / path.name
            shutil.move(path, destination)
            print(f"wrote {destination} ({destination.stat().st_size / 1e6:.1f} MB)")
        if not args.optimize:
            for edition in editions:
                stem = name if edition == "digital" else f"{name}_{edition}"
                stale = out_dir / f"{stem}.pdf"
                if stale.exists():
                    print(
                        f"note: {stale} is left from an earlier build with --optimize and"
                        " does not reflect this build",
                        flush=True,
                    )
    if new_layout is not None:
        layout.parent.mkdir(parents=True, exist_ok=True)
        layout.write_text(LAYOUT_HEADER + "\n".join(new_layout) + "\n")
        print(f"wrote the layout fingerprint of {len(new_layout)} pages to {layout}")
    return 0


if __name__ == "__main__":
    signal.signal(signal.SIGTERM, terminate)
    try:
        sys.exit(main())
    except (BuildError, OSError) as error:
        print(f"error: {error}", file=sys.stderr)
        sys.exit(1)
