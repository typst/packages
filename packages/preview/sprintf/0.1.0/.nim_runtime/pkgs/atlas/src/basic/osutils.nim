## OS utilities like 'withDir'.
## (c) 2021 Andreas Rumpf

import std / [os, paths, strutils, osproc, uri]
import reporters

export paths

type
  PackageUrl* = Uri

type
  ResultCode* = distinct int
const
  RES_OK* = ResultCode(0)

proc `==`*(a,b: ResultCode): bool {.borrow.}
proc `$`*(a: ResultCode): string =
  "ResultCode($1)" % [$(int(a))]

proc lastPathComponent*(s: string): string =
  var last = s.len - 1
  while last >= 0 and s[last] in {DirSep, AltSep}: dec last
  var first = last - 1
  while first >= 0 and s[first] notin {DirSep, AltSep}: dec first
  result = s.substr(first+1, last)

proc getFilePath*(x: PackageUrl): string =
  assert x.scheme == "file"
  result = x.hostname
  if x.port.len() > 0:
    result &= ":"
    result &= x.port
  result &= x.path
  result &= x.query

proc isUrl*(x: string): bool =
  x.startsWith("git://") or
  x.startsWith("https://") or
  x.startsWith("http://") or
  x.startsWith("file://")

proc readableFile*(s: Path, path: Path): Path =
  if s.isRelativeTo(path):
    relativePath(s, path)
  else:
    s


proc absoluteDepsDir*(project, value: Path): Path =
  if value == Path ".":
    result = project
  elif isAbsolute(value):
    result = value
  else:
    result = project / value


proc silentExec*(cmd: string; args: openArray[string]): (string, ResultCode) =
  var cmdLine = cmd
  for i in 0..<args.len:
    cmdLine.add ' '
    if args[i].len > 0:
      cmdLine.add quoteShell(args[i])
  let (res, code) = osproc.execCmdEx(cmdLine)
  result = (res, ResultCode(code))

proc nimbleExec*(cmd: string; args: openArray[string]) =
  var cmdLine = "nimble " & cmd
  for i in 0..<args.len:
    cmdLine.add ' '
    cmdLine.add quoteShell(args[i])
  discard os.execShellCmd(cmdLine)

template withDir*(dir: Path; body: untyped) =
  let oldDir = paths.getCurrentDir()
  trace dir, "Current directory is now: " & $dir
  try:
    setCurrentDir($dir)
    body
  finally:
    setCurrentDir($oldDir)

template tryWithDir*(dir: Path; body: untyped) =
  let oldDir = paths.getCurrentDir()
  try:
    if dirExists($dir):
      setCurrentDir($dir)
      trace dir, "Current directory is now: " & $dir
      body
  finally:
    setCurrentDir($oldDir)
