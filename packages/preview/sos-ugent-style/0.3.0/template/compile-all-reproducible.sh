#!/usr/bin/env -S guix time-machine --channels=.guix/channels-lock.scm -- shell --manifest=.guix/manifest.scm --container bash -- bash

# This script compiles all top-level documents in a reproducible way.

# Usage:
# `./compile-template.sh`
for file in *.typ; do
  if [ "$file" != "abbreviations.typ" ]; then
    # Ensure the date is set reproducibly
    typst compile "$file" --creation-timestamp 1
  fi
done

# While writing you can use:
# `guix time-machine -C .guix/channels-lock.scm -- shell -m .guix/manifest.scm -C --preserve="^TERM$" -- typst w doc.typ`
# There might be a bug that `guix time-machine` does not register your ctrl-C when you want to stop watching...

# Alternative:
# a single command line command for a single file
#guix time-machine --channels=.guix/channels-lock.scm -- shell --manifest=../.guix/manifest.scm --container -- typst compile doc.typ
