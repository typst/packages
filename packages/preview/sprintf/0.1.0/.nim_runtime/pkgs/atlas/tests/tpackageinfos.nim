import std/[unittest, os, times, files, paths]
import basic/packageinfos

suite "packages list":
  test "updatePackages downloads packages.json":
    let pkgsDir = Path(getTempDir()) / Path("atlas_pkgs_" & $int(epochTime()))
    let pkgsFile = pkgsDir / Path"packages.json"
    defer:
      if fileExists($pkgsFile):
        removeFile($pkgsFile)
      if dirExists($pkgsDir):
        removeDir($pkgsDir)
    updatePackages(pkgsDir)
    check fileExists($pkgsFile)
    check getFileSize($pkgsFile) > 0
