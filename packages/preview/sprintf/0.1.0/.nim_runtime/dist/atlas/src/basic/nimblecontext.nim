import std/[paths, tables, files, os, uri, dirs, sets, strutils, unicode]
import context, packageinfos, reporters, pkgurls, gitops, compiledpatterns, deptypes, versions

type
  NimbleContext* = object
    packageToDependency*: OrderedTable[PkgUrl, Package]
    packageExtras*: OrderedTable[string, PkgUrl]
    nameToUrl: OrderedTable[string, PkgUrl]
    explicitVersions*: OrderedTable[PkgUrl, HashSet[VersionTag]]
    nameOverrides*: Patterns
    urlOverrides*: Patterns
    hasPackageList*: bool
    notFoundNames: HashSet[string]

proc findNimbleFile*(dir: Path, projectName: string = ""): seq[Path] =
  if dir.splitFile().ext == "nimble":
    let nimbleFile = dir
    if fileExists(nimbleFile):
      return @[nimbleFile]
  else:
    let nimbleFile = dir / Path(projectName & ".nimble")
    if fileExists(nimbleFile):
      return @[nimbleFile]

  if result.len() == 0:
    for file in walkFiles($dir / "*.nimble"):
      result.add Path(file)
  debug dir, "finding nimble file searching by name:", projectName, "found:", result.join(", ")

proc findNimbleFile*(info: Package): seq[Path] =
  doAssert(info.ondisk.string != "", "Package ondisk must be set before findNimbleFile can be called! Package: " & $(info))
  # Prefer the repository's short name (e.g. 'figuro') and let the helper add '.nimble'.
  # Using projectName (which may include host/user) leads to mismatches.
  result = findNimbleFile(info.ondisk, info.url.shortName())

proc cacheNimbleFilesFromGit*(pkg: Package, commit: CommitHash): seq[Path] =
  proc cachedNimbleBase(p: Path): string =
    let tail = $p.splitPath().tail
    let dash = tail.find('-')
    if dash >= 0 and dash+1 < tail.len: tail.substr(dash+1) else: tail

  proc preferShortNameNimble(paths: seq[Path]; shortName: string): seq[Path] =
    ## Disambiguate a list of cached nimble files by preferring the entry whose
    ## base name matches `<shortName>.nimble`. If multiple such entries exist,
    ## return the first; otherwise return the original list.
    let want = shortName & ".nimble"
    var prefer: seq[Path]
    for p in paths:
      if cachedNimbleBase(p) == want:
        prefer.add p
    if prefer.len == 1:
      result = prefer
    elif prefer.len > 1:
      result = @[prefer[0]]
    else:
      result = paths

  # First check if we already have cached nimble files for this commit
  for file in walkFiles($nimbleCachesDirectory() / (commit.h & "-*.nimble")):
    let path = Path(file)
    let base = cachedNimbleBase(path)
    # If we find the exact matching short-name nimble, return it immediately
    if base == pkg.url.shortName() & ".nimble":
      return @[path]
    result.add path
  
  if result.len > 0:
    # Disambiguate cached entries if possible
    return preferShortNameNimble(result, pkg.url.shortName())

  let files = listFiles(pkg.ondisk, commit)
  var nimbleFiles: seq[Path]
  for file in files:
    if file.endsWith(".nimble"):
      let tail = Path(file).splitPath().tail
      # Prefer the nimble named after the repo's short name (e.g. 'figuro.nimble')
      if tail == Path(pkg.url.shortName() & ".nimble"):
        nimbleFiles = @[Path(file)]
        break
      nimbleFiles.add Path(file)

  createDir(nimbleCachesDirectory())
  for nimbleFile in nimbleFiles:
    let cachePath = nimbleCachesDirectory() / Path(commit.h & "-" & $nimbleFile.splitPath().tail)
    if not fileExists(cachePath):
      let contents = showFile(pkg.ondisk, commit, $nimbleFile)
      writeFile($cachePath, contents)
    result.add cachePath
  
  # If multiple nimble files were found, try to disambiguate by preferring the
  # one that matches the repository short name (e.g. 'figuro.nimble').
  if result.len > 1:
    result = preferShortNameNimble(result, pkg.url.shortName())

proc lookup*(nc: NimbleContext, name: string): PkgUrl =
  let lname = unicode.toLower(name)
  if lname in nc.packageExtras:
    result = nc.packageExtras[lname]
  elif lname in nc.nameToUrl:
    result = nc.nameToUrl[lname]

proc putImpl(nc: var NimbleContext, name: string, url: PkgUrl, isFromPath = false): bool =
  let name = unicode.toLower(name)
  if name in nc.nameToUrl:
    result = false
  elif name notin nc.packageExtras:
    nc.packageExtras[name] = url
    result = true
  else:
    let existingPkg = nc.packageExtras[name]
    let existingUrl = existingPkg.url
    let url = url.url
    if existingUrl != url:
      if existingUrl.scheme != url.scheme and existingUrl.port == url.port and
          existingUrl.path == url.path and existingUrl.hostname == url.hostname:
        info "atlas:nimblecontext", "different url schemes for the same package:", $name, "existing:", $existingUrl, "new:", $url
      else:
        # this is handled in the solver which checks for conflicts
        # but users should be aware that this is happening as they can override stuff
        warn "atlas:nimblecontext", "name already exists in packageExtras:", $name, "isFromPath:", $isFromPath, "with different url:", $nc.packageExtras[name], "and url:", $url
        result = false

proc put*(nc: var NimbleContext, name: string, url: PkgUrl): bool {.discardable.} =
  nc.putImpl(name, url, false)

proc putFromPath*(nc: var NimbleContext, name: string, url: PkgUrl): bool =
  nc.putImpl(name, url, true)

proc createUrl*(nc: var NimbleContext, nameOrig: string): PkgUrl =
  ## primary point to createUrl's from a name or argument
  doAssert not nameOrig.isAbsolute(), "createUrl does not support relative paths: " & $nameOrig

  var didReplace = false
  var name = nameOrig
  let origWasUrl = nameOrig.isUrl()
  
  # First try URL overrides if it looks like a URL
  if nameOrig.isUrl():
    name = substitute(nc.urlOverrides, nameOrig, didReplace)
  else:
    name = substitute(nc.nameOverrides, nameOrig, didReplace)
  
  if name.isUrl():
    result = createUrlSkipPatterns(name)

    # Keep explicit URLs stable. Name overrides are for package-name lookups,
    # not for remapping already explicit URL requirements (especially file://).
    if not origWasUrl:
      var didReplace = false
      name = substitute(nc.nameOverrides, result.shortName(), didReplace)
      if didReplace:
        result = createUrlSkipPatterns(name)
  else:
    let lname = nc.lookup(name)
    if not lname.isEmpty():
      result = lname
    else:
      let lname = unicode.toLower(name)
      if lname notin nc.notFoundNames:
        warn "atlas:nimblecontext", "name not found in packages database:", $name
        nc.notFoundNames.incl lname
      raise newException(ValueError, "project name not found in packages database: " & $lname & " original: " & $nameOrig)
  
  let officialPkg = nc.lookup(result.shortName())
  if not officialPkg.isEmpty() and officialPkg.url == result.url:
    result.hasShortName = true

  if not result.isEmpty():
    if nc.put(result.projectName, result):
      debug "atlas:createUrl", "created url with name:", name, "orig:",
            nameOrig, "projectName:", $result.projectName,
            "hasShortName:", $result.hasShortName, "url:", $result.url

proc createUrlFromPath*(nc: var NimbleContext, orig: Path, isLinkPath = false): PkgUrl =
  let absPath = absolutePath(orig)
  # Check if this is an Atlas project or if it's the current project
  let prefix = if isLinkPath: "link://" else: "atlas://"
  if isMainProject(absPath) or absPath == absolutePath(project()):
    if isLinkPath:
      let url = parseUri(prefix & $absPath)
      result = toPkgUriRaw(url)
    else:
      # Find nimble files in the project directory
      let nimbleFiles = findNimbleFile(absPath, "")
      if nimbleFiles.len > 0:
        # Use the first nimble file found as the project identifier
        trace "atlas:nimblecontext", "createUrlFromPath: found nimble file: ", $nimbleFiles[0]
        let url = parseUri(prefix & $nimbleFiles[0])
        result = toPkgUriRaw(url)
      else:
        # Fallback to directory name if no nimble file found
        let nimble = $(absPath.splitPath().tail) & ".nimble"
        trace "atlas:nimblecontext", "createUrlFromPath: no nimble file found, trying directory name: ", $nimble
        let url = parseUri(prefix & $absPath / nimble)
        result = toPkgUriRaw(url)
  else:
    error "atlas:nimblecontext", "createUrlFromPath: not a project: " & $absPath
    # let fileUrl = "file://" & $absPath
    # result = createUrlSkipPatterns(fileUrl)
  if not result.isEmpty():
    discard nc.putFromPath(result.projectName, result)

proc fillPackageLookupTable(c: var NimbleContext) =
  let pkgsDir = packagesDirectory()
  if not c.hasPackageList:
    c.hasPackageList = true
    if not fileExists(pkgsDir / Path"packages.json"):
      updatePackages(pkgsDir)
    let packages = getPackageInfos(pkgsDir)
    var aliases: seq[PackageInfo] = @[]

    # add all packages to the lookup table
    for pkgInfo in packages:
      if pkgInfo.kind == pkAlias:
        aliases.add(pkgInfo)
      else:
        var pkgUrl = createUrlSkipPatterns(pkgInfo.url, skipDirTest=true)
        pkgUrl.hasShortName = true
        pkgUrl.qualifiedName.name = pkgInfo.name
        c.nameToUrl[unicode.toLower(pkgInfo.name)] = pkgUrl
        # c.urlToNames[pkgUrl.url] = pkgInfo.name

    # now we add aliases to the lookup table
    for pkgAlias in aliases:
      # first lookup the alias name
      let aliasName = unicode.toLower(pkgAlias.alias)
      let url = c.nameToUrl[aliasName]
      if url.isEmpty():
        warn "atlas:nimblecontext", "alias name not found in nameToUrl: " & $pkgAlias, "lname:", $aliasName
      else:
        c.nameToUrl[pkgAlias.name] = url

proc createUnfilledNimbleContext*(): NimbleContext =
  result = NimbleContext()
  result.nameOverrides = context().nameOverrides
  result.urlOverrides = context().urlOverrides
  # for key, val in context().packageNameOverrides: 
  #   let url = createUrlSkipPatterns($val)
  #   result.packageExtras[key] = url
  #   result.urlToNames[url.url()] = key

proc createNimbleContext*(): NimbleContext =
  result = createUnfilledNimbleContext()
  fillPackageLookupTable(result)
