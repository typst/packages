# Package

version       = "0.6.0" # Be sure to update jester.jesterVer too!
author        = "Dominik Picheta"
description   = "A sinatra-like web framework for Nim."
license       = "MIT"

skipFiles = @["todo.markdown"]
skipDirs = @["tests"]

# Deps

requires "nim >= 1.0.0"

feature "useHttpbeast":
  requires "httpbeast >= 0.4.0"

feature "useAsyncTools", "useOldAsyncTools":
  requires "asynctools >= 0.1.0"

task test, "Runs the test suite.":
  exec "nimble install -y asynctools@#0e6bdc3ed5bae8c7cc9"
  exec "nim c -r tests/tester"
