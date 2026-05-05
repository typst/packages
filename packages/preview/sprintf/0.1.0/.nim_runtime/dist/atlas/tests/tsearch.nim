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

suite "search":
  withDir "tests":
    if fileExists("atlas.config"):
      removeFile("atlas.config")
    if dirExists("deps"):
      removeDir("deps")
    test "runs without project":
      setContext AtlasContext()
      atlasRun(@["search", "balls"])
      check project() == Path("")
      check not fileExists("atlas.config")
      check not dirExists("deps")
