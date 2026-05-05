# Package

version       = "0.1.0"
author        = "litlighilit"
description   = "src of typst plugin"
license       = "MIT"
srcDir        = "."
bin           = @["lib/main"]  # use `nimble run` to build typst plugin


# Dependencies

requires "nim > 2.0.8"

var pylibPre = "https://github.com/nimpylib"
let envVal = getEnv("NIMPYLIB_PKGS_BARE_PREFIX")
if envVal != "": pylibPre = ""
elif pylibPre[^1] != '/':
  pylibPre.add '/'
template pylib(x, ver) =
  requires if pylibPre == "": x & ver
           else: pylibPre & x

pylib "pyformats", " ^= 0.1.0"
pylib "wasm-minimal-protocol", " ^= 0.1.3"
