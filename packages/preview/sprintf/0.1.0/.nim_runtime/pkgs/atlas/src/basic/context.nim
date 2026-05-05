#
#           Atlas Package Cloner
#        (c) Copyright 2023 Andreas Rumpf
#
#    See the file "copying.txt", included in this
#    distribution, for details about the copyright.
#

import std / [os, uri, paths, files, tables, sets]
import versions, parse_requires, compiledpatterns, reporters

export reporters

const
  UnitTests* = defined(atlasUnitTests)
  TestsDir* = "atlas/tests"

const
  AtlasProjectConfig = Path"atlas.config"
  DefaultPackagesSubDir* = Path"_packages"
  DefaultCachesSubDir* = Path"_caches"
  DefaultNimbleCachesSubDir* = Path"_nimbles"


type
  CfgPath* = distinct string # put into a config `--path:"../x"`

  SemVerField* = enum
    major, minor, patch

  CloneStatus* = enum
    Ok, NotFound, OtherError

  Flag* = enum
    KeepCommits
    CfgHere
    KeepNimEnv
    KeepWorkspace
    ShowGraph
    AutoEnv
    NoExec
    UpdateRepos
    PackagesGit
    ListVersions
    ListVersionsOff
    GlobalWorkspace
    ManualProjectArg
    ShallowClones
    IgnoreGitRemoteUrls
    IgnoreErrors
    DumpFormular
    DumpGraphs
    DumbProxy
    ForceGitToHttps
    NoLazyDeps
    IncludeTagsAndNimbleCommits # include nimble commits and tags in the solver
    NimbleCommitsMax # takes the newest commit for each version

  AtlasContext* = object
    projectDir*: Path = Path"."
    depsDir*: Path = Path"deps"
    confDirOverride*: Path = Path""
    flags*: set[Flag] = {}
    nameOverrides*: Patterns
    urlOverrides*: Patterns
    pkgOverrides*: Table[string, Uri]
    defaultAlgo*: ResolutionAlgorithm = SemVer
    plugins*: PluginInfo
    overridesFile*: Path
    pluginsFile*: Path
    proxy*: Uri
    features*: HashSet[string]

var atlasContext = AtlasContext()

proc setContext*(ctx: AtlasContext) =
  atlasContext = ctx
proc context*(): var AtlasContext =
  atlasContext

proc project*(): Path =
  atlasContext.projectDir

proc project*(ws: Path) =
  atlasContext.projectDir = ws

proc depsDir*(ctx: AtlasContext, relative = false): Path =
  if ctx.depsDir == Path"":
    result = Path""
  elif relative or ctx.depsDir.isAbsolute:
    result = ctx.depsDir
  else:
    result = ctx.projectDir / ctx.depsDir

proc depsDir*(relative = false): Path =
  depsDir(atlasContext, relative)

proc packagesDirectory*(): Path =
  depsDir() / DefaultPackagesSubDir

proc cachesDirectory*(): Path =
  depsDir() / DefaultCachesSubDir

proc nimbleCachesDirectory*(): Path =
  depsDir() / DefaultNimbleCachesSubDir

proc depGraphCacheFile*(ctx: AtlasContext): Path =
  ctx.depsDir() / Path"atlas.cache.json"

proc relativeToWorkspace*(path: Path): string =
  result = "$project/" & $path.relativePath(project())

proc getProjectConfig*(dir = project()): Path =
  ## prefer project atlas.config if found
  ## otherwise default to one in deps/
  ## the deps path will be the default for auto-created ones
  if context().confDirOverride.len() > 0:
    return context().confDirOverride / AtlasProjectConfig
  result = dir / AtlasProjectConfig
  if fileExists(result): return
  result = depsDir() / AtlasProjectConfig

proc isMainProject*(dir: Path): bool =
  fileExists(getProjectConfig(dir))

proc `==`*(a, b: CfgPath): bool {.borrow.}

proc isGitDir*(path: string): bool =
  let gitPath = path / ".git"
  dirExists(gitPath) or fileExists(gitPath)

proc isGitDir*(path: Path): bool =
  isGitDir($(path))
