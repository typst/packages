# Package

version       = "0.2.1"
author        = "Nim Contributors"
description   = "Hash algorithms in Nim."
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 2.0.0"

task docs, "Generate documentaion":
  exec "nim doc --project --docroot --outdir:htmldocs --styleCheck:hint src/checksums/docutils.nim"
