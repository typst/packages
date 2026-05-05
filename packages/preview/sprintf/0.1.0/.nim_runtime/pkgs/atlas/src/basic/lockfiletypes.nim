import std / [strutils, tables, json, jsonutils]
export tables

import reporters

type
  LockFileEntry* = object
    dir*: Path
    url*: string
    commit*: string
    version*: string

  LockedNimbleFile* = object
    filename*: Path
    content*: seq[string]

  LockFile* = object # serialized as JSON
    items*: OrderedTable[string, LockFileEntry]
    nimcfg*: seq[string]
    nimbleFile*: LockedNimbleFile
    hostOS*, hostCPU*: string
    nimVersion*, gccVersion*, clangVersion*: string

proc convertKeyToArray(jsonTree: var JsonNode, path: varargs[string]) =
  var parent: JsonNode
  var content: JsonNode = jsonTree
  for key in path:
    if content.hasKey(key):
      parent = content
      content = parent[key]
    else:
      return

  if content.kind == JString:
    var contents = newJArray()
    for line in content.getStr.split("\n"):
      contents.add(% line)
    parent[path[^1]] = contents

proc readLockFile*(filename: Path): LockFile =
  let jsonAsStr = readFile($filename)
  var jsonTree = parseJson(jsonAsStr)

  # convert older non-array file contents to JArray
  jsonTree.convertKeyToArray("nimcfg")
  jsonTree.convertKeyToArray("nimbleFile", "content")
  result = jsonTo(jsonTree, LockFile,
    Joptions(allowExtraKeys: true, allowMissingKeys: true))

proc write*(lock: LockFile; lockFilePath: string) =
  writeFile lockFilePath, toJson(lock).pretty
