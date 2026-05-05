import std / [sets, tables, sequtils, paths, files, os, strutils, json, jsonutils, algorithm]

import basic/[deptypes, versions, depgraphtypes, osutils, context, gitops, reporters, nimblecontext, pkgurls, deptypesjson, sattypes]
import dependencies, runners 

export depgraphtypes, deptypesjson

export sat

when not compiles(newSeq[int]().addUnique(1)):
  proc addUnique*[T](s: var seq[T]; item: T) =
    if item notin s:
      s.add(item)

iterator directDependencies*(graph: DepGraph; pkg: Package): lent Package =
  if pkg.activeNimbleRelease != nil:
    for (durl, _) in pkg.activeNimbleRelease.requirements:
      # let idx = findDependencyForDep(graph, dep[0])
      yield graph.pkgs[durl]

iterator validVersions*(pkg: Package): (PackageVersion, NimbleRelease) =
  for ver, rel in mpairs(pkg.versions):
    if rel.status == Normal:
      yield (ver, rel)

type
  SatVarInfo* = object # attached information for a SAT variable
    pkg*: Package
    version*: PackageVersion
    release*: NimbleRelease
    feature*: string

  Form* = object
    formula*: Formular
    mapping*: Table[VarId, SatVarInfo]
    idgen: int32

template withOpenBr(b, op, blk) =
  b.openOpr(op)
  `blk`
  b.closeOpr()

proc addAtMostOneOf(b: var Builder; vars: seq[VarId]) =
  for i in 0 ..< vars.len:
    for j in (i + 1) ..< vars.len:
      withOpenBr(b, OrForm):
        b.addNegated(vars[i])
        b.addNegated(vars[j])

proc addAtLeastOneOf(b: var Builder; vars: seq[VarId]) =
  withOpenBr(b, OrForm):
    for v in vars:
      b.add v

proc hasContextFeature(pkg: Package; feature: string): bool =
  if pkg.isRoot and feature in context().features:
    return true
  let scopedByShortName = "feature." & pkg.url.shortName & "." & feature
  let scopedByProjectName = "feature." & pkg.url.projectName & "." & feature
  result = scopedByShortName in context().features or scopedByProjectName in context().features

proc collectUnsatisfiedContextFeatures(graph: DepGraph): seq[string] =
  ## Compare requested `--feature` flags with SAT-selected package features.
  proc hasSatisfiedFeatureDeps(rel: NimbleRelease; featName: string): bool =
    if featName notin rel.features:
      return false

    let reqs = rel.features[featName]
    if reqs.len == 0:
      return true

    for depReq in items(reqs):
      let (depUrl, query) = depReq
      if depUrl notin graph.pkgs:
        return false
      let depPkg = graph.pkgs[depUrl]
      if not depPkg.active or depPkg.activeVersion.isNil:
        return false
      if not query.matches(depPkg.activeVersion):
        return false

    return true

  var requested = context().features.toSeq()
  requested.sort()
  for raw in requested:
    let qualified =
      if raw.startsWith("feature."):
        raw
      elif not graph.root.isNil:
        "feature." & graph.root.url.projectName & "." & raw
      else:
        "feature." & raw

    if not qualified.startsWith("feature."):
      continue

    let parts = qualified.split(".")
    if parts.len < 3:
      continue

    let pkgName = parts[1]
    let featName = parts[2 .. ^1].join(".")
    var matchedPkg = false
    var declaredInNimble = false
    var featureSatisfied = false
    for pkg in allActiveNodes(graph):
      if pkg.url.shortName == pkgName or pkg.url.projectName == pkgName:
        matchedPkg = true
        let rel = pkg.activeNimbleRelease()
        if rel.isNil:
          continue
        if featName in rel.features:
          declaredInNimble = true
          if featName in pkg.activeFeatures or hasSatisfiedFeatureDeps(rel, featName):
            featureSatisfied = true
            break

    # Ignore features that are not declared in the selected nimble release.
    if not matchedPkg:
      result.add(qualified & " (no active package matched '" & pkgName & "')")
    elif declaredInNimble and not featureSatisfied:
      result.add qualified

proc addVersionConstraints(b: var Builder; graph: var DepGraph, pkg: Package) =
  var anyReleaseSatisfied = false

  proc checkDeps(graph: var DepGraph, ver: PackageVersion, reqs: seq[(PkgUrl, VersionInterval)]): tuple[allDepsCompatible: bool, unmatchedDeps: seq[string]] =
    result.allDepsCompatible = true

    # First check if all dependencies can be satisfied
    for dep, query in items(reqs):
      if dep notin graph.pkgs:
        debug pkg.url.projectName, "checking dependency for ", $ver, "not found:", $dep
        result.allDepsCompatible = false
        result.unmatchedDeps.add($dep.projectName & " " & $query & " (not found)")
        continue
      debug pkg.url.projectName, "checking dependency for ", $ver, ":", $dep.projectName, "query:", $query
      let depNode = graph.pkgs[dep]

      if depNode.state == LazyDeferred:
        debug pkg.url.projectName, "dependency:", $dep.projectName, "is lazily deferred and not loaded"
        continue

      var hasCompatible = false
      for depVer, relVer in depNode.validVersions():
        trace pkg.url.projectName, "checking dependency version:", $depVer, "query:", $query, "matches:", $query.matches(depVer)
        if query.matches(depVer):
          hasCompatible = true
          trace pkg.url.projectName, "version matched requirements for the dependency version:", $depVer
          break

      if not hasCompatible:
        result.allDepsCompatible = false
        result.unmatchedDeps.add($dep.projectName & " " & $query)
        warn pkg.url.projectName, "no versions matched requirements for the dependency:", $dep.projectName
      else:
        debug pkg.url.projectName, "a compatible version matched requirements for the dependency version:", $depNode.url.projectName

  for ver, rel in validVersions(pkg):
    let depCheck = checkDeps(graph, ver, rel.requirements)

    # If any dependency can't be satisfied, make this version unsatisfiable
    if not depCheck.allDepsCompatible:
      warn pkg.url.projectName, "all requirements needed for nimble release:", $ver, "were not able to be satisfied:", $rel.requirements.mapIt(it[0].projectName & " " & $it[1]).join("; ")
      if depCheck.unmatchedDeps.len > 0:
        warn pkg.url.projectName, "deps with no matching releases:", depCheck.unmatchedDeps.join("; ")
      b.addNegated(ver.vid)
      continue

    anyReleaseSatisfied = true

    # Add implications for each dependency
    for dep, query in items(rel.requirements):
      if dep notin graph.pkgs:
        info pkg.url.projectName, "requirement depdendency not found:", $dep.projectName, "query:", $query
        continue
      let depNode = graph.pkgs[dep]
      if depNode.state == LazyDeferred:
        debug pkg.url.projectName, "skipping deferred dependency implication:", $dep.projectName
        continue
        
      var flags: seq[string]
      if dep in rel.reqsByFeatures:
        flags = rel.reqsByFeatures[dep].toSeq()
      
      debug pkg.url.projectName, "version constraints for requirement depdendency", "dep:", $dep, "flags:", flags.mapIt($it).join(", "), "reqsByFeatures:", rel.reqsByFeatures.values().toSeq().mapIt($it).join(", ")

      var compatibleVersions: seq[VarId]
      var featureVersions: Table[VarId, seq[VarId]]
      for depVer, nimbleRelease in depNode.validVersions():
        trace pkg.url.projectName, "checking dependency:", depNode.url.projectName, "version:", $depVer, "query:", $query, "matches:", $query.matches(depVer)
        if query.matches(depVer):
          compatibleVersions.add(depVer.vid)
        for feature in flags:
          if feature in nimbleRelease.features:
            let featureVarId = nimbleRelease.featureVars[feature]
            featureVersions.mgetOrPut(depVer.vid, @[]).add(featureVarId)

      # Add implication: if this version is selected, one of its compatible deps must be selected
      withOpenBr(b, OrForm):
        b.addNegated(ver.vid)  # not this version
        withOpenBr(b, OrForm):
          for compatVer in compatibleVersions:
            if featureVersions.hasKey(compatVer):
              withOpenBr(b, AndForm):
                debug pkg.url.projectName, "adding compatVer requirement:", $compatVer, "featureVersions:", $featureVersions[compatVer].mapIt($it).join(", ")
                b.add(compatVer)
                for featureVer in featureVersions[compatVer]:
                  b.add(featureVer)
            else:
              b.add(compatVer)

    # Add implications for each feature requirement
    for feature, reqs in rel.features:
      let featureVarId = rel.featureVars[feature]
      let featDepCheck = checkDeps(graph, ver, reqs)
      let qualifiedFeature = "feature." & pkg.url.projectName & "." & feature

      debug pkg.url.projectName, "checking feature dep:", $feature, "query:", $reqs, "compat versions:", $featDepCheck.allDepsCompatible
      if not featDepCheck.allDepsCompatible:
        warn pkg.url.projectName, "all requirements needed for feature:", qualifiedFeature, "were not able to be satisfied:", $reqs.mapIt(it[0].projectName & " " & $it[1]).join("; "), "deps with no matching releases:", featDepCheck.unmatchedDeps.join("; ")
        b.addNegated(featureVarId)
        continue

      for dep, query in items(reqs):
        if dep notin graph.pkgs:
          info pkg.url.projectName, "feature depdendency not found:", $dep.projectName, "query:", $query
          continue
        let depNode = graph.pkgs[dep]
        if depNode.state == LazyDeferred:
          debug pkg.url.projectName, "skipping deferred feature dependency implication:", $dep.projectName, "feature:", $feature
          continue

        var compatibleVersions: seq[VarId] = @[]
        for depVer, relVer in depNode.validVersions():
          if query.matches(depVer):
            compatibleVersions.add(depVer.vid)
          elif depVer == toVersionTag("*@head").toPkgVer:
            compatibleVersions.add(depVer.vid)
        debug pkg.url.projectName, "checking feature req:", $dep.projectName, "query:", $query, "compat versions:", $compatibleVersions.mapIt($it).join(", "), "from versions:", $depNode.validVersions().toSeq().mapIt(it[0].version()).join(", ")

        withOpenBr(b, OrForm):
          b.addNegated(featureVarId) # not this feature
          withOpenBr(b, OrForm):
            for compatVer in compatibleVersions:
              b.add(compatVer)
          debug pkg.url.projectName, "added compatVer feature dep variables:", $compatibleVersions.mapIt($it).join(", ")
        
        # Add implictations for globally set features
        if hasContextFeature(pkg, feature):
          debug pkg.url.projectName, "checking global feature:", $feature, "in version:", $ver, "context().features:", $context().features.toSeq().mapIt($it).join(", ")
          var featureVersions: Table[VarId, seq[VarId]]
          for depVer, nimbleRelease in depNode.validVersions():
            trace pkg.url.projectName, "checking global feature dependency:", depNode.url.projectName, "version:", $depVer
            if feature in nimbleRelease.features:
              let featureVarId = nimbleRelease.featureVars[feature]
              featureVersions.mgetOrPut(depVer.vid, @[]).add(featureVarId)

          # Add implication: if this version is selected, one of its compatible deps must be selected
          if true:
            withOpenBr(b, OrForm):
              b.addNegated(ver.vid)  # not this version
              withOpenBr(b, OrForm):
                for compatVer in compatibleVersions:
                  if featureVersions.hasKey(compatVer):
                    withOpenBr(b, AndForm):
                      debug pkg.url.projectName, "adding compatVer requirement:", $compatVer, "featureVersions:", $featureVersions[compatVer].mapIt($it).join(", ")
                      b.add(compatVer)
                      for featureVer in featureVersions[compatVer]:
                        b.add(featureVer)
                  else:
                    b.add(compatVer)

  if not anyReleaseSatisfied:
    warn pkg.url.projectName, "no versions satisfied for this package:", $pkg.url

proc hasVersionSatisfiableByLoadedDeps(graph: DepGraph; pkg: Package): bool =
  ## Returns true when at least one normal release can satisfy all currently
  ## loaded non-lazy dependencies. If false, lazy retry cannot help this pkg.
  for ver, rel in validVersions(pkg):
    var allDepsCompatible = true

    for dep, query in items(rel.requirements):
      if dep notin graph.pkgs:
        allDepsCompatible = false
        break

      let depNode = graph.pkgs[dep]
      if depNode.state == LazyDeferred:
        continue

      var hasCompatible = false
      for depVer, _ in depNode.validVersions():
        if query.matches(depVer):
          hasCompatible = true
          break

      if not hasCompatible:
        allDepsCompatible = false
        break

    if allDepsCompatible:
      return true

  false

proc collectHardUnsatNonLazyPackages(graph: DepGraph): seq[string] =
  ## Only retry lazy deferred packages when they could change SAT.
  ## If already-loaded non-lazy packages have no satisfiable versions, lazy
  ## retry cannot fix the conflict and should be skipped.
  for pkg in graph.pkgs.values():
    if pkg.state == LazyDeferred or pkg.versions.len == 0:
      continue
    if not hasVersionSatisfiableByLoadedDeps(graph, pkg):
      result.add(pkg.url.projectName)

proc collectLazyDeferredPackagesForUnsatRetry(graph: DepGraph): seq[Package] =
  ## If SAT fails, collect lazy deferred packages that are reachable from the
  ## currently loaded graph and could change satisfiability on one retry pass.
  var lazyDeferUrls: HashSet[PkgUrl]

  template includeLazyDeps(reqs: untyped, reason: string) =
    for req in reqs:
      let depUrl = req[0]
      if depUrl in graph.pkgs and graph.pkgs[depUrl].state == LazyDeferred:
        if not lazyDeferUrls.containsOrIncl(depUrl):
          result.add graph.pkgs[depUrl]
          debug graph.pkgs[depUrl].url.projectName, "lazy deferred package selected for load after UNSAT:", reason

  for pkg in graph.pkgs.values():
    if pkg.state == LazyDeferred:
      continue

    var hasSpecialVersions = false
    for ver, rel in validVersions(pkg):
      let verStr = ver.version().string
      if verStr.len > 1 and verStr[0] == '#':
        hasSpecialVersions = true
        break

    for ver, rel in validVersions(pkg):
      if hasSpecialVersions:
        let verStr = ver.version().string
        if verStr.len <= 1 or verStr[0] != '#':
          continue

      includeLazyDeps(rel.requirements, $pkg.url.projectName & ":" & $ver)
      for feature, reqs in rel.features:
        if hasContextFeature(pkg, feature):
          includeLazyDeps(reqs, $pkg.url.projectName & ":" & feature)

proc toFormular*(graph: var DepGraph; algo: ResolutionAlgorithm): Form =
  result = Form()
  var b = Builder()

  withOpenBr(b, AndForm):

    # First pass: Assign variables and encode version selection constraints
    for p in mvalues(graph.pkgs):
      if p.versions.len == 0:
        debug p.url.projectName, "skipping adding package variable as it has no versions"
        continue

      # # Sort versions in descending order (newer versions first)

      case algo
      of MinVer: p.versions.sort(sortVersionsDesc)
      of SemVer, MaxVer: p.versions.sort(sortVersionsAsc)

      # Assign a unique SAT variable to each version of the package
      for ver, rel in p.validVersions():
        ver.vid = VarId(result.idgen)
        # Map the SAT variable to package information for result interpretation
        result.mapping[ver.vid] = SatVarInfo(pkg: p, version: ver, release: rel)
        inc result.idgen
      
        # Add feature VarIds - these are not version variables, but are used to track feature selection
        for feature in rel.features.keys():
          if feature notin rel.featureVars:
            let featureVarId = VarId(result.idgen)
            rel.featureVars[feature] = featureVarId
            # Map the SAT variable to package information for result interpretation
            result.mapping[featureVarId] = SatVarInfo(pkg: p, version: ver, release: rel, feature: feature)
            debug p.url.projectName, "adding feature var:", feature, "id:", $(featureVarId), " result: ", $result.mapping[featureVarId]
            inc result.idgen

      doAssert p.state != NotInitialized, "package not initialized: " & $p.toJson(ToJsonOptions(enumMode: joptEnumString))

      # Add constraints based on the package status
      var versionVars: seq[VarId]
      for ver, rel in p.validVersions():
        versionVars.add ver.vid

      if p.state == Error:
        # If package is broken, enforce that none of its versions can be selected
        for vid in versionVars:
          b.addNegated vid
      elif p.isRoot:
        # If it's a root package, enforce exactly one selected version:
        # (v1 OR v2 OR ...) AND pairwise-not-both.
        if versionVars.len == 0:
          b.add falseLit()
        else:
          for ver, rel in p.validVersions():
            debug p.url.projectName, "adding root package version:", $ver, "vid:", $ver.vid
          b.addAtLeastOneOf(versionVars)
          b.addAtMostOneOf(versionVars)
      else:
        # For non-root packages, at most one version can be selected.
        b.addAtMostOneOf(versionVars)
      
    # This simpler deps loop was copied from Nimble after it was first ported from Atlas :)
    # It appears to acheive the same results, but it's a lot simpler
    for pkg in graph.pkgs.mvalues():
      b.addVersionConstraints(graph, pkg)

  result.formula = toForm(b)


proc toString(info: SatVarInfo): string =
  "(" & info.pkg.url.projectName & ", " & $info.version & ")"

proc debugFormular*(graph: var DepGraph; form: Form; solution: Solution) =
  echo "FORM:\n\t", form.formula
  var keys = form.mapping.keys().toSeq()
  keys.sort(proc (a, b: VarId): int = cmp(a.int, b.int))
  for key in keys:
    let value = form.mapping[key]
    echo "\tv", key.int, ": ", value.pkg.url.projectName, ", ", $value.version, ", f: ", value.feature
  let maxVar = maxVariable(form.formula)
  echo "solutions:"
  for varIdx in 0 ..< maxVar:
    if solution.isTrue(VarId(varIdx)):
      echo "\tv", varIdx, ": T"
  echo ""

proc toPretty*(v: uint64): string = 
  if v == DontCare: "X"
  elif v == SetToTrue: "T"
  elif v == SetToFalse: "F"
  elif v == IsInvalid: "!"
  else: ""

proc checkDuplicateModules(graph: var DepGraph) =
  # Check for duplicate module names
  var moduleNames: Table[string, HashSet[Package]]
  for pkg in values(graph.pkgs):
    if pkg.active:
      moduleNames.mgetOrPut(pkg.url.shortName(), initHashSet[Package]()).incl(pkg)
  moduleNames = moduleNames.pairs().toSeq().filterIt(it[1].len > 1).toTable()

  var unhandledDuplicates: seq[string]
  for name, dupePkgs in moduleNames:
    if not context().pkgOverrides.hasKey(name):
      error "atlas:resolved", "duplicate module name:", name, "with pkgs:", dupePkgs.mapIt(it.url.projectName).join(", ")
      notice "atlas:resolved", "please add an entry to `pkgOverrides` to the current project config to select one of: "
      for pkg in dupePkgs:
        notice "...", "   \"$1\": \"$2\", " % [$pkg.url.shortName(), $pkg.url]
    
      unhandledDuplicates.add name
    else:
      let pkgUrl = context().pkgOverrides[name].toPkgUriRaw()
      notice "atlas:resolved", "overriding package:", name, "with:", $pkgUrl
      for pkg in dupePkgs:
        if pkg.url != pkgUrl:
          notice "atlas:resolved", "deactivating duplicate package:", pkg.url.projectName
          pkg.active = false
        else:
          notice "atlas:resolved", "activating duplicate package:", pkg.url.projectName
  
  if unhandledDuplicates.len > 0:
    error "Invalid solution requiring duplicate module names found: " & unhandledDuplicates.join(", ")
    fatal "unhandled duplicate module names found: " & unhandledDuplicates.join(", ")

proc printVersionSelections(graph: DepGraph, solution: Solution, form: Form) =
  var inactives: seq[string]
  for pkg in values(graph.pkgs):
    if not pkg.isRoot and not pkg.active:
      inactives.add pkg.url.projectName

  if inactives.len > 0:
    notice "atlas:resolved", "inactive packages:", inactives.join(", ")

  notice "atlas:resolved", "selected:"
  var selections: seq[(string, string)]
  for pkg in allActiveNodes(graph):
    if not pkg.isRoot:
      var versions = pkg.versions.pairs().toSeq()
      versions.sort(sortVersionsAsc)
      var selectedIdx = -1
      for idx, (ver, rel) in versions:
        if ver.vid in form.mapping:
          if solution.isTrue(ver.vid):
            selectedIdx = idx
            break
      if selectedIdx == -1:
        continue

      let startIdx = max(0, selectedIdx - 1)
      let endIdx = min(versions.len - 1, selectedIdx + 1)
      var idxs = (startIdx .. endIdx).toSeq() 
      idxs.addUnique(0)
      idxs.addUnique(versions.len - 1)

      for idx in idxs:
        if idx < 0 or idx >= versions.len: continue
        let (ver, rel) = versions[idx]
        if ver.vid in form.mapping:
          let item = form.mapping[ver.vid]
          doAssert pkg.url == item.pkg.url
          if solution.isTrue(ver.vid):
            selections.add((item.pkg.url.projectName, "[x] " & toString item))
          else:
            selections.add((item.pkg.url.projectName, "[ ] " & toString item))
        else:
          selections.add((pkg.url.projectName, "[!] " & "(" & $rel.status & "; pkg: " & pkg.url.projectName & ", " & $ver & ")"))
  var longestPkgName = 0
  for (pkg, str) in selections:
    longestPkgName = max(longestPkgName, pkg.len)
  for (pkg, str) in selections:
    notice "atlas:resolved", str
  notice "atlas:resolved", "end of selection"

proc solve*(graph: var DepGraph; form: Form, rerun: var bool) =
  for pkg in graph.pkgs.mvalues():
    pkg.activeVersion = nil
    pkg.activeFeatures = @[]
    pkg.active = false

  let maxVar = form.idgen
  if DumpGraphs in context().flags:
    dumpJson(graph, "graph-solve-input.json")

  var solution = createSolution(maxVar)

  if DumpFormular in context().flags:
    debugFormular graph, form, solution

  if satisfiable(form.formula, solution):
    graph.root.active = true

    for varIdx in 0 ..< maxVar:
      let vid = VarId varIdx
      if vid in form.mapping:
        let mapInfo = form.mapping[vid]
        trace mapInfo.pkg.projectName, "v" & $varIdx & " sat var: " & $solution.getVar(vid).toPretty()

      if solution.isTrue(VarId(varIdx)) and form.mapping.hasKey(VarId varIdx):
        let mapInfo = form.mapping[VarId varIdx]
        let pkg = mapInfo.pkg
        pkg.active = true
        assert not pkg.isNil, "too bad: " & $pkg.url
        assert not mapInfo.release.isNil, "too bad: " & $pkg.url
        pkg.activeVersion = mapInfo.version
        if mapInfo.feature.len > 0:
          pkg.activeFeatures.add(mapInfo.feature)
          debug pkg.url.projectName, "package satisfiable", "feature: ", mapInfo.feature
        else:
          debug pkg.url.projectName, "package satisfiable"

    checkDuplicateModules(graph)

    var lazyDefersNeeded: seq[Package]
    var lazyDeferUrls: HashSet[PkgUrl]

    template includeLazyDeps(reqs: untyped, reason: string) =
      for req in reqs:
        let depUrl = req[0]
        if depUrl in graph.pkgs and graph.pkgs[depUrl].state == LazyDeferred:
          if not lazyDeferUrls.containsOrIncl(depUrl):
            lazyDefersNeeded.add graph.pkgs[depUrl]
            debug graph.pkgs[depUrl].url.projectName, "lazy deferred package selected for load:", reason

    for pkg in graph.pkgs.values():
      if not pkg.active or pkg.activeVersion.isNil or pkg.activeVersion notin pkg.versions:
        continue
      let rel = pkg.versions[pkg.activeVersion]
      includeLazyDeps(rel.requirements, $pkg.url.projectName & ":" & $pkg.activeVersion)

      for feature, reqs in rel.features:
        var isFeatureEnabled = false
        if hasContextFeature(pkg, feature):
          isFeatureEnabled = true
        elif feature in rel.featureVars and solution.isTrue(rel.featureVars[feature]):
          isFeatureEnabled = true

        if isFeatureEnabled:
          includeLazyDeps(reqs, $pkg.url.projectName & ":" & feature)

    if lazyDefersNeeded.len > 0:
      notice "atlas:resolved", "rerunning SAT; found lazy deferred packages:", lazyDefersNeeded.mapIt(it.url.projectName).join(", ")
      for pkg in lazyDefersNeeded:
        pkg.state = DoLoad
        pkg.versions.clear()

      rerun = true
      return

    if ListVersions in context().flags and ListVersionsOff notin context().flags:
      printVersionSelections(graph, solution, form)

  else:
    var notFoundCount = 0
    for pkg in values(graph.pkgs):
      if pkg.isRoot and pkg.state != Processed:
        error project(), "invalid find package: " & pkg.url.projectName & " in state: " & $pkg.state & " error: " & $pkg.errors
        inc notFoundCount
    if notFoundCount > 0:
      return

    let hardUnsatPkgs = collectHardUnsatNonLazyPackages(graph)

    if hardUnsatPkgs.len == 0:
      let lazyDefersNeeded = collectLazyDeferredPackagesForUnsatRetry(graph)

      if lazyDefersNeeded.len > 0:
        notice "atlas:resolved", "rerunning SAT after conflict; loading lazy deferred packages:", lazyDefersNeeded.mapIt(it.url.projectName).join(", ")
        for pkg in lazyDefersNeeded:
          pkg.state = DoLoad
          pkg.versions.clear()
        rerun = true
        return
    else:
      error "atlas:resolved", "not retrying lazy deferred packages; non-lazy dependencies are unsatisfiable for:", hardUnsatPkgs.join(", ")

    error project(), "version conflict; for more information use --showGraph"
    for pkg in mvalues(graph.pkgs):
      var usedVersionCount = 0
      for (ver, rel) in validVersions(pkg):
        if solution.isTrue(ver.vid): inc usedVersionCount
      if usedVersionCount > 1:
        for (ver, rel) in validVersions(pkg):
          if solution.isTrue(ver.vid):
            error pkg.url.projectName, string(ver.version()) & " required"

  if DumpGraphs in context().flags:
    info "atlas:graph", "dumping graph after solving"
    dumpJson(graph, "graph-solved.json")

proc solve*(graph: var DepGraph; form: Form) =
  var rerun = false
  solve(graph, form, rerun)

proc loadWorkspace*(path: Path, nc: var NimbleContext, mode: TraversalMode, onClone: PackageAction, doSolve: bool): DepGraph =
  let deferChildDeps = doSolve and mode == AllReleases and NoLazyDeps notin context().flags
  result = path.expandGraph(nc, mode, onClone, deferChildDeps=deferChildDeps)

  if doSolve:
    let form = result.toFormular(context().defaultAlgo)
    var rerun = false
    solve(result, form, rerun)

    if rerun:
      for pkg in result.pkgs.values():
        for ver, rel in pkg.validVersions():
          ver.vid = NoVar
          rel.featureVars.clear()

      result = loadWorkspace(path, nc, mode, onClone, doSolve)


proc runBuildSteps*(graph: DepGraph) =
  ## execute build steps for the dependency graph
  ##
  for pkg in toposorted(graph):
    if pkg.active:
      doAssert pkg != nil
      block:
        # check for install hooks
        if not pkg.activeNimbleRelease.isNil and
            pkg.activeNimbleRelease.hasInstallHooks:
          tryWithDir pkg.ondisk:
            let nimbleFiles = findNimbleFile(pkg)
            if nimbleFiles.len() == 1:
              notice pkg.url.projectName, "Running installHook"
              runNimScriptInstallHook nimbleFiles[0], pkg.projectName
        # check for nim script bs
        for pattern in mitems context().plugins.builderPatterns:
          let bFile = pkg.ondisk / Path(pattern[0] % pkg.projectName)
          if fileExists(bFile):
            tryWithDir pkg.ondisk:
              runNimScriptBuilder pattern, pkg.projectName

proc activateGraph*(graph: DepGraph): tuple[paths: seq[CfgPath], features: seq[string]] =
  notice "atlas:graph", "Activating project deps for resolved dependency graph"
  for pkg in allActiveNodes(graph):
    if pkg.isRoot: continue
    if not pkg.activeVersion.commit().isEmpty():
      if pkg.ondisk.string.len == 0:
        error pkg.url.projectName, "Missing ondisk location for:", $(pkg.url)
      else:
        if pkg.url.isNimbleLink():
          continue
        let pkgUri = pkg.url.toUri
        if pkgUri.scheme notin ["file", "link", "atlas"]:
          discard gitops.ensureCanonicalOrigin(pkg.ondisk, pkgUri)
        notice pkg.url.projectName, "Checked out to:", $pkg.activeVersion.commit().short(), "at:", pkg.ondisk.relativeToWorkspace()
        discard checkoutGitCommitFull(pkg.ondisk, pkg.activeVersion.commit())

  let unsatisfiedFeatures = collectUnsatisfiedContextFeatures(graph)
  if unsatisfiedFeatures.len > 0:
    error "atlas:graph", "requested feature(s) were not able to be satisfied:", unsatisfiedFeatures.join(", ")

  if NoExec notin context().flags:
    notice "atlas:graph", "Running build steps"
    runBuildSteps(graph)

  notice "atlas:graph", "Wrote nim.cfg!"

  # Add feature defines for --feature:FOO flags (root project features without prefix)
  for feature in context().features:
    if feature.startsWith("feature."):
      # Already in full format: feature.$PKG.$FEATURE
      result.features.addUnique feature
    else:
      # Short format: FOO -> feature.$ROOT.FOO
      result.features.addUnique "feature." & graph.root.url.projectName & "." & feature

  # Apply global feature flags to activeFeatures for introspection/tests.
  for feature in context().features:
    if feature.startsWith("feature."):
      let parts = feature.split(".")
      if parts.len >= 3:
        let pkgName = parts[1]
        let featName = parts[2 .. ^1].join(".")
        for pkg in graph.pkgs.values():
          if pkg.active and (pkg.url.shortName == pkgName or pkg.url.projectName == pkgName):
            pkg.activeFeatures.addUnique(featName)
    else:
      if not graph.root.isNil and graph.root.active:
        graph.root.activeFeatures.addUnique(feature)

  for pkg in allActiveNodes(graph):
    if pkg.isRoot: continue
    trace pkg.url.projectName, "adding CfgPath:", $relativeToWorkspace(toDestDir(graph, pkg) / getCfgPath(graph, pkg).Path)
    result.paths.add CfgPath(toDestDir(graph, pkg) / getCfgPath(graph, pkg).Path)
    for feature in pkg.activeFeatures:
      result.features.addUnique "feature." & pkg.url.shortName & "." & feature
