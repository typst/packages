--nimcache:".nimcache/"

import std/[algorithm, sequtils, strutils, os]

task test, "run unit test":
  for testFile in listFiles("tests/"):
    if testFile.endsWith(".nim") and testFile.splitPath.tail.startsWith("t"):
      echo "TEST: ", testFile
      exec("nim c -r " & testFile)

