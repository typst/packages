# Small program that runs the test cases

import std / [strutils, os, uri, jsonutils, json, tables, sequtils, sets, unittest]
import std/terminal

import basic/[sattypes, context, reporters, pkgurls, compiledpatterns, versions]
import basic/[deptypes, nimblecontext, deptypesjson]
import dependencies
import depgraphs
import integration_test_utils
import atlas, confighandler

ensureGitHttpServer()

proc setupProjTest() =
  withDir "deps" / "proj_a":
    writeFile("proj_a.nimble", dedent"""
    requires "proj_b >= 1.1.0"
    feature "testing":
      requires "proj_feature_dep >= 1.0.0"
    """)
    exec "git commit -a -m \"feat: add proj_a.nimble\""
    exec "git tag v1.2.0"

  removeDir "proj_feature_dep"
  createDir "proj_feature_dep"
  withDir "proj_feature_dep":
    writeFile("proj_feature_dep.nimble", dedent"""
    version "1.0.0"
    """)
    exec "git init"
    exec "git add proj_feature_dep.nimble"
    exec "git commit -m \"feat: add proj_feature_dep.nimble\""
    exec "git tag v1.0.0"

proc isProjFeatureDep(pkg: Package): bool =
  result =
    pkg.url.projectName == "proj_feature_dep" or
    pkg.url.shortName == "proj_feature_dep" or
    ($pkg.ondisk).splitPath().tail == "proj_feature_dep"

suite "test features":
  setup:
    # setAtlasVerbosity(Trace)
    context().nameOverrides = Patterns()
    context().urlOverrides = Patterns()
    context().proxy = parseUri "http://localhost:4242"
    context().flags.incl DumbProxy
    context().depsDir = Path "deps"
    setAtlasErrorsColor(fgMagenta)

  test "setup and test target project":
      # setAtlasVerbosity(Info)
      setAtlasVerbosity(Error)
      withDir "tests/ws_features":
        removeDir("deps")
        project(paths.getCurrentDir())
        context().flags = {ListVersions}
        context().defaultAlgo = SemVer

        expectedVersionWithGitTags()
        var nc = createNimbleContext()
        nc.put("proj_a", toPkgUriRaw(parseUri "https://example.com/buildGraph/proj_a", true))
        nc.put("proj_b", toPkgUriRaw(parseUri "https://example.com/buildGraph/proj_b", true))
        nc.put("proj_c", toPkgUriRaw(parseUri "https://example.com/buildGraph/proj_c", true))
        nc.put("proj_d", toPkgUriRaw(parseUri "https://example.com/buildGraph/proj_d", true))
        # nc.put("proj_feature_dep", toPkgUriRaw(parseUri "https://example.com/buildGraph/proj_feature_dep", true))
        nc.put("proj_feature_dep", toPkgUriRaw(parseUri(toWindowsFileUrl("file://" & $(ospaths2.getCurrentDir() / "proj_feature_dep").absolutePath)), true))

        check nc.lookup("proj_a").hasShortName
        check nc.lookup("proj_a").projectName == "proj_a"

        let dir = paths.getCurrentDir().absolutePath

        var graph0 = dir.loadWorkspace(nc, AllReleases, onClone=DoClone, doSolve=false)
        writeDepGraph(graph0)

        setupProjTest()

  test "setup and test target project":
      # setAtlasVerbosity(Info)
      setAtlasVerbosity(Trace)
      withDir "tests/ws_features":
        # removeDir("deps")
        project(paths.getCurrentDir())
        context().flags = {ListVersions}
        context().defaultAlgo = SemVer
        context().flags.incl DumpFormular

        expectedVersionWithGitTags()
        var nc = createNimbleContext()
        nc.put("proj_a", toPkgUriRaw(parseUri "https://example.com/buildGraph/proj_a", true))
        nc.put("proj_b", toPkgUriRaw(parseUri "https://example.com/buildGraph/proj_b", true))
        nc.put("proj_c", toPkgUriRaw(parseUri "https://example.com/buildGraph/proj_c", true))
        nc.put("proj_d", toPkgUriRaw(parseUri "https://example.com/buildGraph/proj_d", true))
        # nc.put("proj_feature_dep", toPkgUriRaw(parseUri "deps/proj_feature_dep_git", true))
        nc.put("proj_feature_dep", toPkgUriRaw(parseUri(toWindowsFileUrl("file://" & $(ospaths2.getCurrentDir() / "proj_feature_dep").absolutePath)), true))

        check nc.lookup("proj_a").hasShortName
        check nc.lookup("proj_a").projectName == "proj_a"

        let dir = paths.getCurrentDir().absolutePath

        var graph = dir.loadWorkspace(nc, AllReleases, onClone=DoClone, doSolve=true)
        writeDepGraph(graph)

        # checkpoint "\tgraph:\n" & $graph.toJson(ToJsonOptions(enumMode: joptEnumString))

        # check false

        # let form = graph.toFormular(SemVer)
        # context().flags.incl DumpGraphs
        # var sol: Solution
        # solve(graph, form)

        check graph.root.active
        check graph.pkgs[nc.createUrl("proj_a")].active
        check graph.pkgs[nc.createUrl("proj_b")].active
        check graph.pkgs[nc.createUrl("proj_c")].active
        check graph.pkgs[nc.createUrl("proj_d")].active
        check graph.pkgs[nc.createUrl("proj_feature_dep")].active

        check $graph.root.activeVersion == "#head@-"
        # check $graph.pkgs[nc.createUrl("proj_a")].activeVersion == $findCommit("proj_a", "1.1.0")
        check $graph.pkgs[nc.createUrl("proj_a")].activeVersion.vtag.version == "1.2.0"
        check $graph.pkgs[nc.createUrl("proj_b")].activeVersion == $findCommit("proj_b", "1.1.0")
        check $graph.pkgs[nc.createUrl("proj_c")].activeVersion == $findCommit("proj_c", "1.2.0")
        check $graph.pkgs[nc.createUrl("proj_d")].activeVersion == $findCommit("proj_d", "1.0.0")
        check $graph.pkgs[nc.createUrl("proj_feature_dep")].activeVersion.vtag.version == "1.0.0"

        # let graph2 = loadJson("graph-solved.json")

        let jnRoot = toJson(graph.root)
        var graphRoot: Package
        graphRoot.fromJson(jnRoot)
        echo "graphRoot: ", $graphRoot.toJson(ToJsonOptions(enumMode: joptEnumString))

        # check graph.toJson(ToJsonOptions(enumMode: joptEnumString)) == graph2.toJson(ToJsonOptions(enumMode: joptEnumString))

suite "test global features":
  setup:
    # setAtlasVerbosity(Trace)
    context().nameOverrides = Patterns()
    context().urlOverrides = Patterns()
    context().proxy = parseUri "http://localhost:4242"
    context().flags.incl DumbProxy
    context().depsDir = Path "deps"
    setAtlasErrorsColor(fgMagenta)

  test "setup and test target project":
      # setAtlasVerbosity(Info)
      setAtlasVerbosity(Error)
      withDir "tests/ws_features_global":
        removeDir("deps")
        project(paths.getCurrentDir())
        context().flags = {ListVersions}
        context().defaultAlgo = SemVer

        expectedVersionWithGitTags()
        var nc = createNimbleContext()
        nc.put("proj_a", toPkgUriRaw(parseUri "https://example.com/buildGraph/proj_a", true))
        nc.put("proj_b", toPkgUriRaw(parseUri "https://example.com/buildGraph/proj_b", true))
        nc.put("proj_c", toPkgUriRaw(parseUri "https://example.com/buildGraph/proj_c", true))
        nc.put("proj_d", toPkgUriRaw(parseUri "https://example.com/buildGraph/proj_d", true))
        # nc.put("proj_feature_dep", toPkgUriRaw(parseUri "https://example.com/buildGraph/proj_feature_dep", true))
        nc.put("proj_feature_dep", toPkgUriRaw(parseUri(toWindowsFileUrl("file://" & $(ospaths2.getCurrentDir() / "proj_feature_dep").absolutePath)), true))

        check nc.lookup("proj_a").hasShortName
        check nc.lookup("proj_a").projectName == "proj_a"

        let dir = paths.getCurrentDir().absolutePath

        var graph0 = dir.loadWorkspace(nc, AllReleases, onClone=DoClone, doSolve=false)
        writeDepGraph(graph0)

        setupProjTest()

  test "setup and test target project":
      # setAtlasVerbosity(Info)
      setAtlasVerbosity(Trace)
      withDir "tests/ws_features_global":
        # removeDir("deps")
        project(paths.getCurrentDir())
        context().flags = {ListVersions}
        context().defaultAlgo = SemVer
        context().flags.incl DumpFormular
        context().features.incl "feature.proj_a.testing"

        expectedVersionWithGitTags()
        var nc = createNimbleContext()
        nc.put("proj_a", toPkgUriRaw(parseUri "https://example.com/buildGraph/proj_a", true))
        nc.put("proj_b", toPkgUriRaw(parseUri "https://example.com/buildGraph/proj_b", true))
        nc.put("proj_c", toPkgUriRaw(parseUri "https://example.com/buildGraph/proj_c", true))
        nc.put("proj_d", toPkgUriRaw(parseUri "https://example.com/buildGraph/proj_d", true))
        # nc.put("proj_feature_dep", toPkgUriRaw(parseUri "deps/proj_feature_dep_git", true))
        nc.put("proj_feature_dep", toPkgUriRaw(parseUri(toWindowsFileUrl("file://" & $(ospaths2.getCurrentDir() / "proj_feature_dep").absolutePath)), true))

        check nc.lookup("proj_a").hasShortName
        check nc.lookup("proj_a").projectName == "proj_a"

        let dir = paths.getCurrentDir().absolutePath

        var graph = dir.loadWorkspace(nc, AllReleases, onClone=DoClone, doSolve=true)
        writeDepGraph(graph)

        # checkpoint "\tgraph:\n" & $graph.toJson(ToJsonOptions(enumMode: joptEnumString))

        # check false

        # let form = graph.toFormular(SemVer)
        # context().flags.incl DumpGraphs
        # var sol: Solution
        # solve(graph, form)

        check graph.root.active
        check graph.pkgs[nc.createUrl("proj_a")].active
        check graph.pkgs[nc.createUrl("proj_b")].active
        check graph.pkgs[nc.createUrl("proj_c")].active
        check graph.pkgs[nc.createUrl("proj_d")].active
        check nc.createUrl("proj_feature_dep") in graph.pkgs 
        check graph.pkgs[nc.createUrl("proj_feature_dep")].active

        check $graph.root.activeVersion == "#head@-"
        # check $graph.pkgs[nc.createUrl("proj_a")].activeVersion == $findCommit("proj_a", "1.1.0")
        check $graph.pkgs[nc.createUrl("proj_a")].activeVersion.vtag.version == "1.2.0"
        check $graph.pkgs[nc.createUrl("proj_b")].activeVersion == $findCommit("proj_b", "1.1.0")
        check $graph.pkgs[nc.createUrl("proj_c")].activeVersion == $findCommit("proj_c", "1.2.0")
        check $graph.pkgs[nc.createUrl("proj_d")].activeVersion == $findCommit("proj_d", "1.0.0")
        check $graph.pkgs[nc.createUrl("proj_feature_dep")].activeVersion.vtag.version == "1.0.0"

        # let graph2 = loadJson("graph-solved.json")

        let jnRoot = toJson(graph.root)
        var graphRoot: Package
        graphRoot.fromJson(jnRoot)
        echo "graphRoot: ", $graphRoot.toJson(ToJsonOptions(enumMode: joptEnumString))

        # check graph.toJson(ToJsonOptions(enumMode: joptEnumString)) == graph2.toJson(ToJsonOptions(enumMode: joptEnumString))

  test "atlasRun install activates package feature deps from --feature":
      setAtlasVerbosity(Error)
      withDir "tests/ws_features_global":
        removeDir("deps")
        removeDir("proj_feature_dep")

        setContext(AtlasContext())
        context().nameOverrides = Patterns()
        context().urlOverrides = Patterns()
        context().proxy = parseUri "http://localhost:4242"
        context().flags = {DumbProxy}
        context().depsDir = Path "deps"
        context().defaultAlgo = SemVer
        project(paths.getCurrentDir())

        expectedVersionWithGitTags()
        var nc = createNimbleContext()
        nc.put("proj_a", toPkgUriRaw(parseUri "https://example.com/buildGraph/proj_a", true))
        nc.put("proj_b", toPkgUriRaw(parseUri "https://example.com/buildGraph/proj_b", true))
        nc.put("proj_c", toPkgUriRaw(parseUri "https://example.com/buildGraph/proj_c", true))
        nc.put("proj_d", toPkgUriRaw(parseUri "https://example.com/buildGraph/proj_d", true))

        let dir = paths.getCurrentDir().absolutePath
        discard dir.loadWorkspace(nc, AllReleases, onClone=DoClone, doSolve=false)

        let featureDepPath = (paths.getCurrentDir() / Path"proj_feature_dep").absolutePath
        createDir($featureDepPath)
        withDir $featureDepPath:
          writeFile("proj_feature_dep.nimble", dedent"""
          version "1.0.0"
          """)
          exec "git init"
          exec "git add proj_feature_dep.nimble"
          exec "git commit -m \"feat: add proj_feature_dep.nimble\""
          exec "git tag v1.0.0"

        withDir "deps" / "proj_a":
          writeFile("proj_a.nimble", dedent"""
          requires "proj_b >= 1.1.0"
          feature "testing":
            requires "$1 >= 1.0.0"
          """ % [toWindowsFileUrl("file://" & $featureDepPath)])
          exec "git add proj_a.nimble"
          exec "git commit -m \"feat: add proj_a feature dep for atlasRun test\""
          exec "git tag v1.2.0"

        setContext(AtlasContext())
        atlasRun(@[
          "--deps=deps",
          "--proxy=http://localhost:4242/",
          "--dumbproxy",
          "--feature:proj_a.testing",
          "install"
        ])

        check dirExists("deps" / "proj_feature_dep")
        check "deps/proj_feature_dep" in readFile("nim.cfg")

        var nc2 = createNimbleContext()
        let graph = loadDepGraph(nc2, (paths.getCurrentDir() / Path"ws_features_global.nimble").absolutePath)
        let featurePkgs = graph.pkgs.values().toSeq().filterIt(it.isProjFeatureDep())
        check featurePkgs.len == 1
        if featurePkgs.len == 1:
          check featurePkgs[0].active
          check not featurePkgs[0].activeVersion.isNil
          check $featurePkgs[0].activeVersion.vtag.version == "1.0.0"

  test "broken feature does not block other selected features":
      setAtlasVerbosity(Error)
      withDir "tests/ws_features_global":
        removeDir("deps")
        removeDir("proj_feature_dep")

        setContext(AtlasContext())
        context().nameOverrides = Patterns()
        context().urlOverrides = Patterns()
        context().proxy = parseUri "http://localhost:4242"
        context().flags = {DumbProxy, ListVersions}
        context().depsDir = Path "deps"
        context().defaultAlgo = SemVer
        project(paths.getCurrentDir())

        expectedVersionWithGitTags()
        var nc = createNimbleContext()
        nc.put("proj_a", toPkgUriRaw(parseUri "https://example.com/buildGraph/proj_a", true))
        nc.put("proj_b", toPkgUriRaw(parseUri "https://example.com/buildGraph/proj_b", true))
        nc.put("proj_c", toPkgUriRaw(parseUri "https://example.com/buildGraph/proj_c", true))
        nc.put("proj_d", toPkgUriRaw(parseUri "https://example.com/buildGraph/proj_d", true))

        let dir = paths.getCurrentDir().absolutePath
        discard dir.loadWorkspace(nc, AllReleases, onClone=DoClone, doSolve=false)

        let featureDepPath = (paths.getCurrentDir() / Path"proj_feature_dep").absolutePath
        createDir($featureDepPath)
        withDir $featureDepPath:
          writeFile("proj_feature_dep.nimble", dedent"""
          version "1.0.0"
          """)
          exec "git init"
          exec "git add proj_feature_dep.nimble"
          exec "git commit -m \"feat: add proj_feature_dep.nimble\""
          exec "git tag v1.0.0"

        withDir "deps" / "proj_a":
          writeFile("proj_a.nimble", dedent"""
          requires "proj_b >= 1.1.0"
          feature "testing":
            requires "$1 >= 1.0.0"
          feature "broken":
            requires "proj_b >= 9.9.9"
          """ % [toWindowsFileUrl("file://" & $featureDepPath)])
          exec "git add proj_a.nimble"
          exec "git commit -m \"feat: add mixed valid/broken features for solver test\""
          exec "git tag v1.2.0"

        setContext(AtlasContext())
        context().nameOverrides = Patterns()
        context().urlOverrides = Patterns()
        context().proxy = parseUri "http://localhost:4242"
        context().flags = {DumbProxy, ListVersions}
        context().depsDir = Path "deps"
        context().defaultAlgo = SemVer
        context().features.incl "feature.proj_a.testing"
        context().features.incl "feature.proj_a.broken"
        project(paths.getCurrentDir())

        var nc2 = createNimbleContext()
        nc2.put("proj_a", toPkgUriRaw(parseUri "https://example.com/buildGraph/proj_a", true))
        nc2.put("proj_b", toPkgUriRaw(parseUri "https://example.com/buildGraph/proj_b", true))
        nc2.put("proj_c", toPkgUriRaw(parseUri "https://example.com/buildGraph/proj_c", true))
        nc2.put("proj_d", toPkgUriRaw(parseUri "https://example.com/buildGraph/proj_d", true))

        let graph = dir.loadWorkspace(nc2, AllReleases, onClone=DoClone, doSolve=true)
        let featurePkgs = graph.pkgs.values().toSeq().filterIt(it.isProjFeatureDep())
        check featurePkgs.len == 1
        if featurePkgs.len == 1:
          check featurePkgs[0].active
          check not featurePkgs[0].activeVersion.isNil
          check $featurePkgs[0].activeVersion.vtag.version == "1.0.0"

  test "feature requested states: missing, satisfiable, unsatisfiable":
    setAtlasVerbosity(Error)
    withDir "tests/ws_features_global":
      let rootNimble = "ws_features_global.nimble"
      let originalRootNimble = readFile(rootNimble)
      defer:
        writeFile(rootNimble, originalRootNimble)

      proc resetFeatureTestContext() =
        setContext(AtlasContext())
        context().nameOverrides = Patterns()
        context().urlOverrides = Patterns()
        context().proxy = parseUri "http://localhost:4242"
        context().flags = {DumbProxy}
        context().depsDir = Path "deps"
        context().defaultAlgo = SemVer
        project(paths.getCurrentDir())

      proc runInstallWithFeature(featureArg: string): int =
        resetFeatureTestContext()
        let errorsBefore = atlasErrors()
        atlasRun(@[
          "--deps=deps",
          "--proxy=http://localhost:4242/",
          "--dumbproxy",
          "--feature:" & featureArg,
          "install"
        ])
        atlasErrors() - errorsBefore

      # 1) Feature missing from selected root nimble release: no error.
      if dirExists("deps"):
        removeDir("deps")
      writeFile(rootNimble, dedent"""
      requires "proj_a"
      """)
      check runInstallWithFeature("siwin") == 0

      # 2) Feature declared and satisfiable: no error.
      if dirExists("deps"):
        removeDir("deps")
      writeFile(rootNimble, dedent"""
      requires "proj_a"
      feature "siwin":
        requires "proj_a >= 1.1.0"
      """)
      check runInstallWithFeature("siwin") == 0

      # 3) Feature declared but unsatisfiable: must produce an error.
      if dirExists("deps"):
        removeDir("deps")
      writeFile(rootNimble, dedent"""
      requires "proj_a"
      feature "siwin":
        requires "proj_a >= 9.9.9"
      """)
      check runInstallWithFeature("siwin") > 0

  test "unsat root dependency should not trigger lazy historical retry":
    ## Expected behavior:
    ## - root unsat for a non-lazy requirement should error immediately
    ## - lazy deps should remain deferred (retrying them cannot satisfy root)
    ##
    ## This test currently fails and documents the desired fix.
    setAtlasVerbosity(Error)
    withDir "tests/ws_features_global":
      removeDir("deps")

      let rootNimble = "ws_features_global.nimble"
      let originalRootNimble = readFile(rootNimble)
      defer:
        writeFile(rootNimble, originalRootNimble)

      setContext(AtlasContext())
      context().nameOverrides = Patterns()
      context().urlOverrides = Patterns()
      context().proxy = parseUri "http://localhost:4242"
      context().flags = {DumbProxy}
      context().depsDir = Path "deps"
      context().defaultAlgo = SemVer
      project(paths.getCurrentDir())

      expectedVersionWithGitTags()
      var nc = createNimbleContext()
      nc.put("proj_a", toPkgUriRaw(parseUri "https://example.com/buildGraph/proj_a", true))
      nc.put("proj_b", toPkgUriRaw(parseUri "https://example.com/buildGraph/proj_b", true))
      nc.put("proj_c", toPkgUriRaw(parseUri "https://example.com/buildGraph/proj_c", true))
      nc.put("proj_d", toPkgUriRaw(parseUri "https://example.com/buildGraph/proj_d", true))

      # Force an unsatisfiable non-lazy root requirement.
      writeFile(rootNimble, "requires \"proj_a >= 9.9.9\"\n")

      let dir = paths.getCurrentDir().absolutePath
      let errorsBefore = atlasErrors()
      let graph = dir.loadWorkspace(nc, AllReleases, onClone=DoClone, doSolve=true)
      let errorsAfter = atlasErrors()

      check errorsAfter > errorsBefore
      check not graph.root.active

      # Desired behavior: keep lazy deps deferred on UNSAT caused by non-lazy deps.
      let projBUrl = nc.createUrl("proj_b")
      check projBUrl in graph.pkgs
      if projBUrl in graph.pkgs:
        check graph.pkgs[projBUrl].state == LazyDeferred

  test "unsat retry should not load feature deps for unselected features":
    setAtlasVerbosity(Error)
    withDir "tests/ws_features_global":
      removeDir("deps")
      removeDir("proj_feature_dep")

      let rootNimble = "ws_features_global.nimble"
      let originalRootNimble = readFile(rootNimble)
      defer:
        writeFile(rootNimble, originalRootNimble)

      setContext(AtlasContext())
      context().nameOverrides = Patterns()
      context().urlOverrides = Patterns()
      context().proxy = parseUri "http://localhost:4242"
      context().flags = {DumbProxy}
      context().depsDir = Path "deps"
      context().defaultAlgo = SemVer
      project(paths.getCurrentDir())

      expectedVersionWithGitTags()
      var nc = createNimbleContext()
      nc.put("proj_a", toPkgUriRaw(parseUri "https://example.com/buildGraph/proj_a", true))
      nc.put("proj_b", toPkgUriRaw(parseUri "https://example.com/buildGraph/proj_b", true))
      nc.put("proj_c", toPkgUriRaw(parseUri "https://example.com/buildGraph/proj_c", true))
      nc.put("proj_d", toPkgUriRaw(parseUri "https://example.com/buildGraph/proj_d", true))
      nc.put("proj_feature_dep", toPkgUriRaw(parseUri(toWindowsFileUrl("file://" & $(ospaths2.getCurrentDir() / "proj_feature_dep").absolutePath)), true))

      let dir = paths.getCurrentDir().absolutePath
      discard dir.loadWorkspace(nc, AllReleases, onClone=DoClone, doSolve=false)
      setupProjTest()

      # Force a global version conflict (not a hard non-lazy "no matching release").
      writeFile(rootNimble, dedent"""
      requires "proj_a >= 1.1.0"
      requires "proj_b <= 1.0.0"
      """)

      setContext(AtlasContext())
      context().nameOverrides = Patterns()
      context().urlOverrides = Patterns()
      context().proxy = parseUri "http://localhost:4242"
      context().flags = {DumbProxy}
      context().depsDir = Path "deps"
      context().defaultAlgo = SemVer
      project(paths.getCurrentDir())

      var nc2 = createNimbleContext()
      nc2.put("proj_a", toPkgUriRaw(parseUri "https://example.com/buildGraph/proj_a", true))
      nc2.put("proj_b", toPkgUriRaw(parseUri "https://example.com/buildGraph/proj_b", true))
      nc2.put("proj_c", toPkgUriRaw(parseUri "https://example.com/buildGraph/proj_c", true))
      nc2.put("proj_d", toPkgUriRaw(parseUri "https://example.com/buildGraph/proj_d", true))
      nc2.put("proj_feature_dep", toPkgUriRaw(parseUri(toWindowsFileUrl("file://" & $(ospaths2.getCurrentDir() / "proj_feature_dep").absolutePath)), true))

      let errorsBefore = atlasErrors()
      let graph = dir.loadWorkspace(nc2, AllReleases, onClone=DoClone, doSolve=true)
      let errorsAfter = atlasErrors()

      check errorsAfter > errorsBefore
      check not graph.root.active
      check not dirExists("deps" / "proj_feature_dep")

      let featureDepUrl = nc2.createUrl("proj_feature_dep")
      check featureDepUrl in graph.pkgs
      if featureDepUrl in graph.pkgs:
        check graph.pkgs[featureDepUrl].state == LazyDeferred
