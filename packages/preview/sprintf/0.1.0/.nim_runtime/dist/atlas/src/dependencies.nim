#
#           Atlas Package Cloner
#        (c) Copyright 2023 Andreas Rumpf
#
#    See the file "copying.txt", included in this
#    distribution, for details about the copyright.
#

import std / [os, strutils, uri, tables, sequtils, sets, hashes, algorithm, paths, dirs]
import basic/[context, deptypes, versions, osutils, nimbleparser, reporters, gitops, pkgurls, nimblecontext, deptypesjson]

export deptypes, versions, deptypesjson

proc collectNimbleVersions*(nc: NimbleContext; pkg: Package): seq[VersionTag] =
  let nimbleFiles = findNimbleFile(pkg)
  let dir = pkg.ondisk
  doAssert(pkg.ondisk.string != "", "Package ondisk must be set before collectNimbleVersions can be called! Package: " & $(pkg))
  result = @[]
  if nimbleFiles.len() == 1:
    result = collectFileCommits(dir, nimbleFiles[0], isLocalOnly = pkg.isLocalOnly)
    result.reverse()
    trace pkg, "collectNimbleVersions commits:", mapIt(result, it.c.short()).join(", "), "nimble:", $nimbleFiles[0]

type
  PackageAction* = enum
    DoNothing, DoClone

proc copyFromDisk*(pkg: Package, dest: Path): (CloneStatus, string) =
  let source = pkg.url.toOriginalPath()
  info pkg, "copyFromDisk cloning:", $dest, "from:", $source
  if dirExists(source) and not dirExists(dest):
    trace pkg, "copyFromDisk cloning:", $dest, "from:", $source
    copyDir(source.string, dest.string)
    result = (Ok, "")
  else:
    error pkg, "copyFromDisk not found:", $source
    result = (NotFound, $dest)

proc isForkUrl(nc: NimbleContext; url: PkgUrl): bool =
  let officialUrl = nc.lookup(url.shortName())
  let isGitUrl = url.url.scheme notin ["file", "link", "atlas"]
  result =
    isGitUrl and
    not officialUrl.isEmpty() and
    officialUrl.url.scheme notin ["file", "link", "atlas"] and
    officialUrl.url != url.url

proc childDependencyState(pkg: Package; deferChildDeps: bool): PackageState =
  ## Returns the initial state for newly discovered child dependencies.
  ## Non-root children are marked lazy when `deferChildDeps` is enabled.
  if deferChildDeps and not pkg.isRoot: LazyDeferred
  else: NotInitialized

proc processNimbleRelease(
    nc: var NimbleContext;
    pkg: Package,
    release: VersionTag;
    deferChildDeps: bool
): NimbleRelease =
  trace pkg.url.projectName, "Processing release:", $release

  var nimbleFiles: seq[Path]
  if release.version == Version"#head":
    trace pkg.url.projectName, "processRelease using current commit"
    nimbleFiles = findNimbleFile(pkg)
  elif release.commit.isEmpty():
    warn pkg.url.projectName, "processRelease missing commit ", $release, "at:", $pkg.ondisk
    result = NimbleRelease(status: HasBrokenRelease, err: "no commit")
    return
  else:
    nimbleFiles = cacheNimbleFilesFromGit(pkg, release.commit)

    # warn pkg.url.projectName, "processRelease unable to checkout commit ", $release, "at:", $pkg.ondisk
    # result = NimbleRelease(status: HasBrokenRelease, err: "error checking out release")

  if nimbleFiles.len() == 0:
    info "processRelease", "skipping release: missing nimble file:", $release
    result = NimbleRelease(status: HasUnknownNimbleFile, err: "missing nimble file")
  elif nimbleFiles.len() > 1:
    info "processRelease", "skipping release: ambiguous nimble file:", $release, "files:", $(nimbleFiles.mapIt(it.splitPath().tail).join(", "))
    result = NimbleRelease(status: HasUnknownNimbleFile, err: "ambiguous nimble file")
  else:
    let nimbleFile = nimbleFiles[0]
    result = nc.parseNimbleFile(nimbleFile)

    if result.status == Normal:
      for pkgUrl, interval in items(result.requirements):
        # debug pkg.url.projectName, "INTERVAL: ", $interval, "isSpecial:", $interval.isSpecial, "explicit:", $interval.extractSpecificCommit()
        if interval.isSpecial:
          let commit = interval.extractSpecificCommit()
          nc.explicitVersions.mgetOrPut(pkgUrl, initHashSet[VersionTag]()).incl(VersionTag(v: Version($(interval)), c: commit))

        let state = childDependencyState(pkg, deferChildDeps)
        if pkgUrl notin nc.packageToDependency:
          debug pkg.url.projectName, "Found new pkg:", pkgUrl.projectName, "url:", $pkgUrl.url, "projectName:", $pkgUrl.projectName, "state:", $state
          # debug pkg.url.projectName, "Found new pkg:", pkgUrl.projectName, "repr:", $pkgUrl.repr
          let pkgDep = Package(url: pkgUrl, state: state, isFork: isForkUrl(nc, pkgUrl))
          nc.packageToDependency[pkgUrl] = pkgDep
        else:
          if nc.packageToDependency[pkgUrl].state == LazyDeferred and state != LazyDeferred:
            warn pkg.url.projectName, "Changing LazyDeferred pkg to DoLoad:", $pkgUrl.url
            nc.packageToDependency[pkgUrl].state = DoLoad

      for feature, rq in result.features:
        for pkgUrl, interval in items(rq):
          if interval.isSpecial:
            let commit = interval.extractSpecificCommit()
            nc.explicitVersions.mgetOrPut(pkgUrl, initHashSet[VersionTag]()).incl(VersionTag(v: Version($(interval)), c: commit))
          if pkgUrl notin nc.packageToDependency:
            let state =
              if feature notin context().features: LazyDeferred
              else: childDependencyState(pkg, deferChildDeps)
            debug pkg.url.projectName, "Found new feature pkg:", pkgUrl.projectName, "url:", $pkgUrl.url, "projectName:", $pkgUrl.projectName, "state:", $state
            let pkgDep = Package(url: pkgUrl, state: state, isFork: isForkUrl(nc, pkgUrl))
            nc.packageToDependency[pkgUrl] = pkgDep
          elif feature in context().features and nc.packageToDependency[pkgUrl].state == LazyDeferred and childDependencyState(pkg, deferChildDeps) != LazyDeferred:
            warn pkg.url.projectName, "Changing LazyDeferred feature pkg to DoLoad:", $pkgUrl.url
            nc.packageToDependency[pkgUrl].state = DoLoad

proc addFeatureDependencies(pkg: Package) =

  var featuresAdded = false
  warn pkg.url.projectName, "adding feature dependencies for root package; features:", $(context().features.toSeq().join(", ")), "versions:", $(pkg.versions.keys().toSeq().mapIt($it).join(", "))
  for flag in items(context().features):
    for ver, rel in pkg.versions:
      info pkg.url.projectName, "checking feature:", $flag, "in version:", $rel.version
      if flag in rel.features:
        let fdep = rel.features[flag]
        for pkgUrl, interval in items(fdep):
          info pkg.url.projectName, "adding feature reqsByFeatures:", $flag, "for:", $pkgUrl.url
          withValue(rel.reqsByFeatures, pkgUrl, reqsByFeatures):
            if flag notin reqsByFeatures[]:
              reqsByFeatures[].incl(flag)
              featuresAdded = true
          do:
            rel.reqsByFeatures[pkgUrl] = initHashSet[string]()
            rel.reqsByFeatures[pkgUrl].incl(flag)
      else:
        info pkg.url.projectName, "feature:", $flag, "not found for:", $rel.version
  
  if featuresAdded:
    warn pkg.url.projectName, "feature dependencies added"
    pkg.state = Found

proc addRelease(
    versions: var seq[(PackageVersion, NimbleRelease)],
    # pkg: var Package,
    nc: var NimbleContext;
    pkg: Package,
    vtag: VersionTag;
    deferChildDeps: bool
): bool =
  var pkgver = vtag.toPkgVer()
  trace pkg.url.projectName, "Adding Nimble version:", $vtag
  try:
    let release = nc.processNimbleRelease(pkg, vtag, deferChildDeps)

    if vtag.v.string == "":
      pkgver.vtag.v = release.version
      trace pkg.url.projectName, "updating release tag information:", $pkgver.vtag
    elif release.version.string == "":
      warn pkg.url.projectName, "nimble file missing version information:", $pkgver.vtag
      release.version = vtag.version
    elif vtag.v != release.version and not pkg.isRoot:
      info pkg.url.projectName, "version mismatch between version tag:", $vtag.v, "and nimble version:", $release.version
    
    versions.add((pkgver, release))

    result = true
  except CatchableError as e:
    info pkg.url.projectName, "error processing nimble release:", $vtag, "error:", $e.msg
    return false

proc commitPrefixMatches(a, b: CommitHash): bool =
  ## Returns true when two commit hashes refer to the same commit prefix.
  ## This allows explicit short hashes and full hashes to match each other.
  if a.isEmpty() or b.isEmpty():
    return false
  result = a.h.startsWith(b.h) or b.h.startsWith(a.h)

proc explicitVersionMatches(explicit, candidate: VersionTag): bool =
  ## Checks whether a candidate version tag matches an explicit SAT-selected
  ## version request, supporting #head, commit-based, and semver equality cases.
  if explicit.version.isHead():
    return candidate.isTip

  if commitPrefixMatches(explicit.commit, candidate.commit):
    return true

  if explicit.version.string.len > 1 and explicit.version.string[0] == '#':
    if explicit.version.string.len > 1 and not candidate.commit.isEmpty():
      return candidate.commit.h.startsWith(explicit.version.string.substr(1))
    return false

  if explicit.version != Version"":
    return explicit.version == candidate.version

  return false

proc filterToExplicitVersions(pkg: var Package, explicitVersions: seq[VersionTag]) =
  ## Narrows pkg.versions to only versions that match explicit SAT-selected
  ## versions. Used in lazy deferred resolution to avoid unrelated historical
  ## versions after explicit pin expansion.
  if explicitVersions.len == 0:
    return

  var filtered = initOrderedTable[PackageVersion, NimbleRelease]()
  for ver, rel in pkg.versions:
    for explicit in explicitVersions:
      if explicitVersionMatches(explicit, ver.vtag):
        filtered[ver] = rel
        break

  if filtered.len > 0 and filtered.len < pkg.versions.len:
    info pkg.url.projectName, "filtering to explicit versions:", filtered.values().toSeq().mapIt($it.version).join(", ")
    pkg.versions = filtered

proc traverseDependency*(
    nc: var NimbleContext;
    pkg: var Package,
    mode: TraversalMode;
    explicitVersions: seq[VersionTag];
    deferChildDeps = false;
) =
  doAssert pkg.ondisk.dirExists() and pkg.state != NotInitialized, "Package should've been found or cloned at this point. Package: " & $pkg.url & " on disk: " & $pkg.ondisk

  var versions: seq[(PackageVersion, NimbleRelease)]
  var expandedExplicitVersions = explicitVersions

  let currentCommit = currentGitCommit(pkg.ondisk, Warning)
  if not pkg.isLocalOnly:
    discard gitops.ensureCanonicalOrigin(pkg.ondisk, pkg.url.toUri)
  pkg.originHead = gitops.findOriginTip(pkg.ondisk, errorReportLevel = Warning, isLocalOnly = pkg.isLocalOnly).commit()

  if mode == CurrentCommit and currentCommit.isEmpty():
    discard
  elif currentCommit.isEmpty():
    warn pkg.url.projectName, "traversing dependency unable to find git current version at ", $pkg.ondisk
    let vtag = VersionTag(v: Version"#head", c: initCommitHash("", FromHead))
    versions.add((vtag.toPkgVer, NimbleRelease(version: vtag.version, status: HasBrokenRepo)))
    pkg.state = Error
    return
  else:
    trace pkg.url.projectName, "traversing dependency current commit:", $currentCommit

  case mode
  of CurrentCommit:
    trace pkg.url.projectName, "traversing dependency for only current commit"
    let vtag = VersionTag(v: Version"#head", c: initCommitHash(currentCommit, FromHead))
    discard versions.addRelease(nc, pkg, vtag, deferChildDeps)

  of ExplicitVersions:
    debug pkg.url.projectName, "traversing dependency found explicit versions:", $expandedExplicitVersions
    # for ver, rel in pkg.versions:
    #   versions.add((ver, rel))

    var uniqueCommits: HashSet[CommitHash]
    for ver in pkg.versions.keys():
      uniqueCommits.incl(ver.vtag.c)

    # get full hash from short hashes
    # TODO: handle shallow clones here?
    for version in mitems(expandedExplicitVersions):
      let vtag = gitops.expandSpecial(pkg.ondisk, vtag = version)
      version = vtag
      debug pkg.url.projectName, "explicit version:", $version, "vtag:", repr vtag

    for version in expandedExplicitVersions:
      debug pkg.url.projectName, "check explicit version:", repr version
      if version.commit.isEmpty():
        warn pkg.url.projectName, "explicit version has empty commit:", $version
      elif not uniqueCommits.containsOrIncl(version.commit):
        debug pkg.url.projectName, "add explicit version:", $version
        discard versions.addRelease(nc, pkg, version, deferChildDeps)

  of AllReleases:
    try:
      var uniqueCommits: HashSet[CommitHash]
      var nimbleVersions: HashSet[Version]
      var nimbleCommits = nc.collectNimbleVersions(pkg)

      debug pkg.url.projectName, "nimble explicit versions:", $explicitVersions
      for version in explicitVersions:
        if version.version == Version"" and
            not version.commit.isEmpty() and
            not uniqueCommits.containsOrIncl(version.commit):
            let vtag = VersionTag(v: Version"", c: version.commit)
            assert vtag.commit.orig == FromDep, "maybe this needs to be overriden like before: " & $vtag.commit.orig
            discard versions.addRelease(nc, pkg, vtag, deferChildDeps)

      ## Note: always prefer tagged versions
      let tags = collectTaggedVersions(pkg.ondisk, isLocalOnly = pkg.isLocalOnly)
      debug pkg.url.projectName, "nimble tags:", $tags
      for tag in tags:
        if not uniqueCommits.containsOrIncl(tag.c):
          discard versions.addRelease(nc, pkg, tag, deferChildDeps)
          assert tag.commit.orig == FromGitTag, "maybe this needs to be overriden like before: " & $tag.commit.orig

      if tags.len() == 0 or IncludeTagsAndNimbleCommits in context().flags:
        ## Note: skip nimble commit versions unless explicitly enabled
        ## package maintainers may delete a tag to skip a versions, which we'd override here
        if NimbleCommitsMax in context().flags:
          # reverse the order so the newest commit is preferred for new versions
          nimbleCommits.reverse()

        debug pkg.url.projectName, "nimble commits:", $nimbleCommits
        for tag in nimbleCommits:
          if not uniqueCommits.containsOrIncl(tag.c):
            # trace pkg.url.projectName, "traverseDependency adding nimble commit:", $tag
            var vers: seq[(PackageVersion, NimbleRelease)]
            let added = vers.addRelease(nc, pkg, tag, deferChildDeps)
            if added and not nimbleVersions.containsOrIncl(vers[0][0].vtag.v):
              versions.add(vers)
          else:
            error pkg.url.projectName, "traverseDependency skipping nimble commit:", $tag, "uniqueCommits:", $(tag.c in uniqueCommits), "nimbleVersions:", $(tag.v in nimbleVersions)

      if versions.len() == 0:
        let vtag = VersionTag(v: Version"#head", c: initCommitHash(currentCommit, FromHead))
        debug pkg.url.projectName, "traverseDependency no versions found, using default #head", "at", $pkg.ondisk
        discard versions.addRelease(nc, pkg, vtag, deferChildDeps)

    finally:
      if not checkoutGitCommit(pkg.ondisk, currentCommit, Warning):
        info pkg.url.projectName, "traverseDependency error loading versions reverting to ", $currentCommit

  # make sure identicle NimbleReleases refer to the same ref
  var uniqueReleases: Table[NimbleRelease, NimbleRelease]
  for (ver, rel) in versions:
    if rel notin uniqueReleases:
      # trace pkg.url.projectName, "found unique release requirements at:", $ver.vtag
      uniqueReleases[rel] = rel
    else:
      trace pkg.url.projectName, "found duplicate release requirements at:", $ver.vtag

  info pkg.url.projectName, "unique versions found:", uniqueReleases.values().toSeq().mapIt($it.version).join(", ")
  for (ver, rel) in versions:
    if mode != ExplicitVersions and ver in pkg.versions:
      error pkg.url.projectName, "duplicate release found:", $ver.vtag, "new:", repr(rel)
      error pkg.url.projectName, "... existing: ", repr(pkg.versions[ver])
      error pkg.url.projectName, "duplicate release found:", $ver.vtag, "new:", repr(rel), " existing: ", repr(pkg.versions[ver])
      error pkg.url.projectName, "versions table:", $pkg.versions.keys().toSeq()
    pkg.versions[ver] = uniqueReleases[rel]

  # Keep non-explicit versions for non-lazy traversals (used by tests and graph
  # exploration), but narrow in lazy SAT mode to avoid selecting unrelated
  # historical versions after explicit pin expansion.
  if mode == ExplicitVersions and deferChildDeps:
    filterToExplicitVersions(pkg, expandedExplicitVersions)

  # TODO: filter by unique versions first?
  pkg.state = Processed

  if pkg.isRoot and context().features.len > 0:
    addFeatureDependencies(pkg)


proc loadDependency*(
    nc: NimbleContext,
    pkg: var Package,
    onClone: PackageAction = DoClone,
) = 
  if pkg.isRoot:
    pkg.ondisk = project()
    pkg.isAtlasProject = true
    pkg.isLocalOnly = true
    if pkg.state != Found:
      pkg.state = Found
    return

  doAssert pkg.ondisk.string == ""

  let officialUrl = nc.lookup(pkg.url.shortName())
  let isFork = pkg.isFork

  if isFork:
    info pkg.url.projectName, "package is unofficial or forked"
    let canonicalDir = officialUrl.toDirectoryPath()
    let forkDir = pkg.url.toDirectoryPath()
    if dirExists(forkDir) and not dirExists(canonicalDir) and
        forkDir.isRelativeTo(depsDir()) and canonicalDir.isRelativeTo(depsDir()):
      try:
        moveDir(forkDir.string, canonicalDir.string)
      except OSError:
        discard
    pkg.ondisk = canonicalDir
  else:
    pkg.ondisk = pkg.url.toDirectoryPath()

  var todo = if dirExists(pkg.ondisk): DoNothing else: DoClone
  pkg.isAtlasProject = pkg.url.isAtlasProject()
  pkg.isLocalOnly = pkg.url.isNimbleLink()
  if pkg.isLocalOnly:
    todo = DoNothing
  if pkg.state == LazyDeferred:
    todo = DoNothing

  debug pkg.url.projectName, "loading dependency todo:", $todo, "ondisk:", $pkg.ondisk, "isLinked:", $pkg.url.isFileProtocol, "isLazyDeferred:", $(pkg.state == LazyDeferred)
  case todo
  of DoClone:
    if onClone == DoNothing:
      pkg.state = Error
      pkg.errors.add "Not found"
    else:
      let (status, msg) =
        if pkg.url.isFileProtocol:
          pkg.isLocalOnly = true
          copyFromDisk(pkg, pkg.ondisk)
        else:
          gitops.clone(pkg.url.toUri, pkg.ondisk)
      if status == Ok:
        if not pkg.isLocalOnly:
          discard gitops.ensureCanonicalOrigin(pkg.ondisk, pkg.url.toUri)
          discard gitops.resolveRemoteName(pkg.ondisk)
          if isFork:
            discard gitops.ensureRemoteForUrl(pkg.ondisk, officialUrl.toUri)
          discard gitops.fetchRemoteTags(pkg.ondisk)
        pkg.state = Found
      else:
        pkg.state = Error
        pkg.errors.add $status & ": " & msg
  of DoNothing:
    if pkg.ondisk.dirExists():
      pkg.state = Found
      if not pkg.isLocalOnly:
        discard gitops.ensureCanonicalOrigin(pkg.ondisk, pkg.url.toUri)
        discard gitops.resolveRemoteName(pkg.ondisk)
        if isFork:
          discard gitops.ensureRemoteForUrl(pkg.ondisk, officialUrl.toUri)
      if UpdateRepos in context().flags:
        gitops.updateRepo(pkg.ondisk)
        if not pkg.isLocalOnly:
          discard gitops.fetchRemoteTags(pkg.ondisk)
        
    else:
      pkg.state = Error
      pkg.errors.add "ondisk location missing"

proc processPendingPackages(
    graph: var DepGraph;
    nc: var NimbleContext;
    root: Package;
    traversalMode: TraversalMode;
    onClone: PackageAction;
    deferChildDeps: bool
) =
  var processing = true
  while processing:
    processing = false
    let pkgUrls = nc.packageToDependency.keys().toSeq()

    # just for more concise logging
    var initializingPkgs: seq[string]
    var processingPkgs: seq[string]
    for pkgUrl in pkgUrls:
      var pkg = nc.packageToDependency[pkgUrl]
      case pkg.state:
      of NotInitialized:
        initializingPkgs.add pkg.projectName
      of Found:
        processingPkgs.add pkg.projectName
      else:
        discard
    if initializingPkgs.len() > 0:
      notice root.projectName, "Initializing packages:", initializingPkgs.join(", ")
    if processingPkgs.len() > 0:
      notice root.projectName, "Processing packages:", processingPkgs.join(", ")

    # process packages
    debug "atlas:expandGraph", "Processing package count: ", $pkgUrls.len()
    for pkgUrl in pkgUrls:
      var pkg = nc.packageToDependency[pkgUrl]
      case pkg.state:
      of NotInitialized, DoLoad:
        info pkg.projectName, "Initializing package:", $pkg.url
        nc.loadDependency(pkg, onClone)
        trace pkg.projectName, "expanded pkg:", pkg.repr
        processing = true
      of LazyDeferred:
        if pkgUrl notin graph.pkgs:
          graph.pkgs[pkgUrl] = pkg
          pkg.versions[VersionTag(v: Version"*", c: initCommitHash("#head", FromHead)).toPkgVer] = NimbleRelease(version: Version"#head", status: Normal)
          graph.pkgs[pkgUrl] = pkg
          info pkg.projectName, "Adding lazy deferred package to pkgs list:", $pkg.url
        else:
          trace pkg.projectName, "Skipping lazy deferred package:", $pkg.url
        pkg.state = LazyDeferred
      of Found:
        info pkg.projectName, "Processing package at:", pkg.ondisk.relativeToWorkspace()
        let effectiveMode =
          if pkg.isRoot or pkg.isAtlasProject or pkg.url.isNimbleLink():
            CurrentCommit
          else:
            traversalMode
        nc.traverseDependency(pkg, effectiveMode, @[], deferChildDeps=deferChildDeps)
        trace pkg.projectName, "processed pkg:", $pkg
        processing = true
        if pkgUrl notin graph.pkgs:
          graph.pkgs[pkgUrl] = pkg
      of Processed:
        if pkgUrl notin graph.pkgs:
          graph.pkgs[pkgUrl] = pkg
      else:
        discard
        info pkg.projectName, "Skipping package:", $pkg.url, "state:", $pkg.state

proc expandGraph*(
    path: Path,
    nc: var NimbleContext;
    mode: TraversalMode,
    onClone: PackageAction,
    isLinkPath = false,
    deferChildDeps = false
): DepGraph =
  ## Expand the graph by adding all dependencies.
  
  doAssert path.string != "."
  let url = nc.createUrlFromPath(path, isLinkPath)
  notice url.projectName, "expanding root package at:", $path, "url:", $url
  var root = Package(url: url, isRoot: true, isFork: isForkUrl(nc, url))
  # nc.loadDependency(pkg)

  result = DepGraph(root: root, mode: mode)
  nc.packageToDependency[root.url] = root

  notice "atlas:expand", "Expanding packages for:", $root.projectName

  # Explicit-version traversal can discover additional dependencies.
  # Re-run package processing until no new packages are introduced.
  var graphChanged = true
  while graphChanged:
    graphChanged = false
    result.processPendingPackages(nc, root, mode, onClone, deferChildDeps)

    let pkgCountBeforeExplicit = nc.packageToDependency.len
    let explicitCountBeforeExplicit = nc.explicitVersions.len
    debug "atlas:expandGraph", "Processing explicit versions count: ", $nc.explicitVersions.len()
    for pkgUrl in nc.explicitVersions.keys().toSeq():
      let versions = nc.explicitVersions[pkgUrl]
      info pkgUrl.projectName, "explicit versions: ", versions.toSeq().mapIt($it).join(", ")
      if pkgUrl in nc.packageToDependency:
        var pkg = nc.packageToDependency[pkgUrl]
        if pkg.state == Processed:
          nc.traverseDependency(pkg, ExplicitVersions, versions.toSeq(), deferChildDeps=deferChildDeps)

    graphChanged = nc.packageToDependency.len != pkgCountBeforeExplicit or
      nc.explicitVersions.len != explicitCountBeforeExplicit

  info "atlas:expand", "Finished expanding packages for:", $root.projectName

proc findProjects*(path: Path): seq[Path] =
  result = @[]
  for k, f in walkDir(path):
    if k == pcDir and dirExists(f / Path".git"):
      result.add(f)
