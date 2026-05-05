
from std/os import `/`, parentDir, `/../`, moveFile
import pkg/wasm_minimal_protocol/main

proc buildTypst* =
  let typSrc = currentSourcePath().parentDir /../ "../src"
  compile("lib.nim")
  template mv(src, dst) = moveFile(src, dst/src)
  mv("lib.typ", typSrc)
  mv("lib.wasm", typSrc)

when isMainModule:
  buildTypst()
