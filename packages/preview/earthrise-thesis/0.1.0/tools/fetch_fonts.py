#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
"""Collect the fonts Typst does not ship with"""

from __future__ import annotations

import argparse
import hashlib
import http.client
import io
import os
import sys
import time
import urllib.request
import zipfile
from dataclasses import dataclass, field
from pathlib import Path

DOWNLOAD_ATTEMPTS = 3
DOWNLOAD_TIMEOUT = 120
FONT_SUFFIXES = {".otf", ".otc", ".ttf", ".ttc"}


@dataclass(frozen=True)
class Source:
    name: str
    url: str
    sha256: str
    files: dict[str, str] = field(default_factory=dict)
    is_archive: bool = False


SOURCES = (
    Source(
        name="EB Garamond 1.003",
        url=(
            "https://raw.githubusercontent.com/google/fonts/"
            "f8c1d3d6cc75e30d77130bdcbfbff27e3b6233fe/ofl/ebgaramond/EBGaramond%5Bwght%5D.ttf"
        ),
        sha256="ef9512f92f6d579e5dc75af59a5a4b1b8b47d2eda89e00b954d44520e5369027",
        files={
            "EBGaramond[wght].ttf": (
                "ef9512f92f6d579e5dc75af59a5a4b1b8b47d2eda89e00b954d44520e5369027"
            )
        },
    ),
    Source(
        name="EB Garamond Italic 1.003",
        url=(
            "https://raw.githubusercontent.com/google/fonts/"
            "f8c1d3d6cc75e30d77130bdcbfbff27e3b6233fe/ofl/ebgaramond/"
            "EBGaramond-Italic%5Bwght%5D.ttf"
        ),
        sha256="bba2c4499c93c9612b90b9825d32b07da52fce2fe57562a1eb6b833553f93c4e",
        files={
            "EBGaramond-Italic[wght].ttf": (
                "bba2c4499c93c9612b90b9825d32b07da52fce2fe57562a1eb6b833553f93c4e"
            )
        },
    ),
    Source(
        name="Monaspace Argon 1.400",
        url=(
            "https://github.com/githubnext/monaspace/releases/download/"
            "v1.400/monaspace-static-v1.400.zip"
        ),
        sha256="ab66d71be751495f679727332a3345597943bd4d7beebca03f5cde04bf994de7",
        files={
            "MonaspaceArgon-Regular.otf": (
                "a7e654dc999fc368bf9721f9c1369606503b3ce278874b1aa161e6ee6c1706ad"
            ),
            "MonaspaceArgon-Italic.otf": (
                "9f4627d78cbeb800e683e898b006e1dfb658bf07d72778cc084746e53f4ce5b1"
            ),
            "MonaspaceArgon-Bold.otf": (
                "62346369af981fc7ebc7e6b26dbb7e5d5d3f5ad59aebf845a6912078576b1c5b"
            ),
            "MonaspaceArgon-BoldItalic.otf": (
                "33b4a80454343bca56a6cd687be8d282e72bdf53eb7c62b8ee06bd70d72f10f5"
            ),
        },
        is_archive=True,
    ),
    Source(
        name="GNU FreeFont 20120503",
        url="https://ftp.gnu.org/gnu/freefont/freefont-ttf-20120503.zip",
        sha256="7c85baf1bf82a1a1845d1322112bc6ca982221b484e3b3925022e25b5cae89af",
        files={
            "FreeMono.ttf": "0517b67f1e50bbcde4e54834a5fa597be2526cf3cbb69487a9fbdb0de1a83b4c",
        },
        is_archive=True,
    ),
)


class FontError(RuntimeError):
    pass


def digest(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def already_satisfied(source: Source, destination: Path) -> bool:
    return all(
        (destination / name).is_file()
        and digest((destination / name).read_bytes()) == sha
        for name, sha in source.files.items()
    )


def download(source: Source) -> bytes:
    last_error: Exception | None = None
    for attempt in range(1, DOWNLOAD_ATTEMPTS + 1):
        try:
            with urllib.request.urlopen(
                source.url, timeout=DOWNLOAD_TIMEOUT
            ) as response:
                return response.read()
        except (OSError, http.client.HTTPException) as error:
            last_error = error
            print(
                f"  attempt {attempt}/{DOWNLOAD_ATTEMPTS} failed: {error}",
                file=sys.stderr,
            )
            if attempt < DOWNLOAD_ATTEMPTS:
                time.sleep(5 * attempt)
    raise FontError(
        f"could not download {source.name} from {source.url}: {last_error};"
        " check the network connection and rerun"
    )


def members(payload: bytes, source: Source) -> dict[str, bytes]:
    if not source.is_archive:
        (name,) = source.files
        return {name: payload}

    extracted: dict[str, bytes] = {}
    with zipfile.ZipFile(io.BytesIO(payload)) as archive:
        by_basename = {Path(item).name: item for item in archive.namelist()}
        for name in source.files:
            member = by_basename.get(name)
            if member is None:
                raise FontError(f"{source.name}: {name} is not in the archive")
            extracted[name] = archive.read(member)
    return extracted


def install(source: Source, destination: Path) -> list[str]:
    print(f"fetching {source.name}")
    payload = download(source)
    found = digest(payload)
    if found != source.sha256:
        raise FontError(
            f"{source.name}: download digest {found} does not match the pinned {source.sha256}."
            " Upstream changed the file, or the download was tampered with;"
            " verify the new file by hand before updating the digest."
        )

    installed = []
    for name, content in members(payload, source).items():
        found = digest(content)
        if found != source.files[name]:
            raise FontError(
                f"{source.name}: {name} has digest {found}, expected {source.files[name]}"
            )
        (destination / name).write_bytes(content)
        installed.append(name)
    return installed


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    default_destination = Path.cwd() / ".fonts"
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument(
        "--dest",
        type=Path,
        default=default_destination,
        help=f"directory the fonts are written to (default: {default_destination})",
    )
    parser.add_argument(
        "--clean",
        action="store_true",
        help="delete the pinned font files first instead of reusing them",
    )
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv)
    args.dest.mkdir(parents=True, exist_ok=True)
    if args.clean:
        for source in SOURCES:
            for name in source.files:
                (args.dest / name).unlink(missing_ok=True)

    installed, reused = [], []
    for source in SOURCES:
        if already_satisfied(source, args.dest):
            reused.extend(source.files)
            continue
        installed.extend(install(source, args.dest))

    if reused:
        print(f"reused {len(reused)} verified font file(s) in {args.dest}")
    if installed:
        print(f"installed {len(installed)} font file(s) in {args.dest}")
    pinned = {name for source in SOURCES for name in source.files}
    unpinned = sorted(
        str(Path(folder, name).relative_to(args.dest))
        for folder, _, names in os.walk(args.dest, followlinks=True)
        for name in names
        if Path(name).suffix.lower() in FONT_SUFFIXES
        and not (Path(folder) == args.dest and name in pinned)
    )
    if unpinned:
        print(
            f"note: Typst also loads these font files in {args.dest}, which are not pinned:"
            f" {', '.join(unpinned)}",
            file=sys.stderr,
        )
    print(f"font path: {args.dest}")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (FontError, OSError) as error:
        print(f"error: {error}", file=sys.stderr)
        sys.exit(1)
