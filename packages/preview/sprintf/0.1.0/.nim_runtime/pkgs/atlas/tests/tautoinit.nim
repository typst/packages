import std/[os, paths, unittest]
import basic/context
import atlas

template withDir(dir: string; body: untyped) =
  let old = os.getCurrentDir()
  try:
    os.setCurrentDir(dir)
    body
  finally:
    os.setCurrentDir(old)

suite "autoinit":
  withDir "tests/ws_autoinit":
    if fileExists("atlas.config"):
      removeFile("atlas.config")
    if dirExists("deps"):
      removeDir("deps")
    test "detects project with nimble file":
      check autoProject(os.getCurrentDir().Path)
      check project() == os.getCurrentDir().Path
