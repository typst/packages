#
#           Atlas Package Cloner
#        (c) Copyright 2023 Andreas Rumpf
#
#    See the file "copying.txt", included in this
#    distribution, for details about the copyright.
#

## Configuration handling.

import std / [strutils, os, streams, json, tables, jsonutils, uri, sequtils]
import basic/[versions, nimblecontext, deptypesjson, context, reporters, compiledpatterns, parse_requires, deptypes]

proc readPluginsDir(dir: Path) =
  for k, f in walkDir($(project() / dir)):
    if k == pcFile and f.endsWith(".nims"):
      extractPluginInfo f, context().plugins

type
  JsonConfig* = object
    deps*: string
    nameOverrides*: Table[string, string]
    urlOverrides*: Table[string, string]
    pkgOverrides*: Table[string, string]
    plugins*: string
    resolver*: string
    graph*: JsonNode

proc writeDefaultConfigFile*() =
  let config = JsonConfig(
    deps: $depsDir(relative=true),
    nameOverrides: initTable[string, string](),
    urlOverrides: initTable[string, string](),
    pkgOverrides: initTable[string, string](),
    resolver: $SemVer,
    graph: newJNull()
  )
  let configFile = getProjectConfig()
  writeFile($configFile, pretty %*config)

proc readConfigFile*(configFile: Path): JsonConfig =
  var f = newFileStream($configFile, fmRead)
  if f == nil:
    warn "atlas:config", "could not read project config:", $configFile
    return

  try:
    let j = parseJson(f, $configFile)
    result = j.jsonTo(JsonConfig, Joptions(allowExtraKeys: true, allowMissingKeys: true))

  finally:
    close f

proc readAtlasContext*(ctx: var AtlasContext, projectDir: Path) =
  let configFile = projectDir.getProjectConfig()
  info "atlas:config", "Reading config file: ", $configFile
  let m = readConfigFile(configFile)

  ctx.projectDir = projectDir

  if m.deps.len > 0:
    ctx.depsDir = m.deps.Path.expandTilde()
  
  # Handle package name overrides
  for key, val in m.nameOverrides:
    let err = ctx.nameOverrides.addPattern(key, val)
    if err.len > 0:
      error configFile, "invalid name override pattern: " & err

  # Handle URL overrides  
  for key, val in m.urlOverrides:
    let err = ctx.urlOverrides.addPattern(key, val)
    if err.len > 0:
      error configFile, "invalid URL override pattern: " & err

  # Handle package overrides
  for key, val in m.pkgOverrides:
    ctx.pkgOverrides[key] = parseUri(val)
  if m.resolver.len > 0:
    try:
      ctx.defaultAlgo = parseEnum[ResolutionAlgorithm](m.resolver)
    except ValueError:
      warn configFile, "ignored unknown resolver: " & m.resolver
  if m.plugins.len > 0:
    ctx.pluginsFile = m.plugins.Path
    readPluginsDir(m.plugins.Path)
  

proc readConfig*() =
  readAtlasContext(context(), project())
  # trace "atlas:config", "read config file: ", repr context()

proc writeConfig*() =
  # TODO: serialize graph in a smarter way

  let config = JsonConfig(
    deps: $depsDir(relative=true),
    nameOverrides: context().nameOverrides.toTable(),
    urlOverrides: context().urlOverrides.toTable(),
    pkgOverrides: context().pkgOverrides.pairs().toSeq().mapIt((it[0], $it[1])).toTable(),
    plugins: $context().pluginsFile,
    resolver: $context().defaultAlgo,
    graph: newJNull()
  )

  let jcfg = toJson(config)
  doAssert not jcfg.isNil()
  let configFile = getProjectConfig()
  debug "atlas", "writing config file: ", $configFile
  writeFile($configFile, pretty(jcfg))

proc writeDepGraph*(g: DepGraph, debug: bool = false) =
  var configFile = depGraphCacheFile(context())
  if debug:
    configFile = configFile.changeFileExt("debug.json")
  debug "atlas", "writing dep graph to: ", $configFile
  dumpJson(g, $configFile, pretty = true)

proc loadDepGraph*(nc: var NimbleContext, nimbleFile: Path): DepGraph =
  doAssert nimbleFile.isAbsolute() and endsWith($nimbleFile, ".nimble") and fileExists($nimbleFile)
  let projectDir = nimbleFile.parentDir()
  var ctx = AtlasContext(projectDir: projectDir)
  readAtlasContext(ctx, projectDir)
  let configFile = depGraphCacheFile(ctx)
  debug "atlas", "reading dep graph from: ", $configFile
  result = loadJson(nc, $configFile)
