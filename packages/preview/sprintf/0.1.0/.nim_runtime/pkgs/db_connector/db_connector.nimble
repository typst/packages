# Package

version       = "0.1.0"
author        = "Nim contributors"
description   = "Unified database connector."
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 1.7.3"

task tests, "Run all tests":
  exec "nim c tests/all/tdb.nim"
  exec "nim c tests/all/tsqlitebindatas.nim"
  exec "nim c tests/all/tpostgres.nim"
  exec "nim c tests/all/tdb_mysql.nim"
