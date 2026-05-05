# Package

version       = "0.1.0"
author        = "Nim Contributors"
description   = "Parse a HTML document in Nim."
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 1.6.0"

task docs, "Generate documentaion":
  exec "nim doc --project --docroot --outdir:htmldocs --styleCheck:hint src/htmlparser.nim"
