#!/usr/bin/env python3
from pathlib import Path
import os
import shutil
import tomllib
import sys

with open("typst.toml", "rb") as f:
    data = tomllib.load(f)

name = data["package"]["name"]
version = data["package"]["version"]

source = "."
home = Path(os.path.expanduser("~"))
destination = home / ".cache" / "typst" / "packages" / "local" / name / version

if destination.is_dir():
    print(f"ERROR: Directory {destination} already exists. Remove it with the following command and run this script again")
    print(f"rm -r \"{destination}\"")
    sys.exit(1)

print(f"Creating local package installation at {destination}.")
shutil.copytree(source, destination, ignore=shutil.ignore_patterns(".git"))
print("Installation successful. You can now import the package with")
print(f"#import @local/{name}:{version}")
