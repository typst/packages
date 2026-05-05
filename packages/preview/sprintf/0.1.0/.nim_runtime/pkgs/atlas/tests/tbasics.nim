import std/[unittest, os, algorithm, dirs, files, strutils, importutils, terminal, json, jsonutils]
import basic/[context, pkgurls, deptypes, nimblecontext, compiledpatterns, osutils, versions, depgraphtypes]

suite "urls and naming":
  var 
    nc: NimbleContext
    ws: Path

  setup:
    nc = createUnfilledNimbleContext()
    # setAtlasVerbosity(Trace)
    setAtlasErrorsColor(fgMagenta)
    project(Path("tests/ws_basic").absolutePath())
    ws = absolutePath(project())
    nc.put("npeg", toPkgUriRaw(parseUri "https://github.com/zevv/npeg"))
    nc.put("sync", toPkgUriRaw(parseUri "https://github.com/planetis-m/sync"))
    nc.put("regex", toPkgUriRaw(parseUri "https://github.com/nitely/nim-regex"))
    nc.put("foobar", toPkgUriRaw(parseUri "https://example.com/bazz/foobar"))

  test "balls url":
    let upkg = nc.createUrl("https://github.com/disruptek/balls.git")
    check upkg.url.hostname == "github.com"
    check $upkg.url == "https://github.com/disruptek/balls"
    check $upkg.projectName == "balls.disruptek.github.com"
    check upkg.toDirectoryPath() == ws / Path"deps" / Path("balls")
    check upkg.toLinkPath() == ws / Path"deps" / Path("balls.nimble-link")
    expect ValueError:
      discard nc.createUrl("balls")
    check not upkg.isLinkPath()

  test "balls url using packageExtras":
    nc.put("balls", toPkgUriRaw(parseUri "https://github.com/disruptek/balls.git", true))
    check nc.lookup("balls").projectName == "balls"
    check $nc.lookup("balls").url == "https://github.com/disruptek/balls"

    let upkg = nc.createUrl("balls")
    check upkg.url.hostname == "github.com"
    check $upkg.url == "https://github.com/disruptek/balls"
    check $upkg.projectName == "balls"
    check upkg.toDirectoryPath() == ws / Path"deps" / Path("balls")
    check upkg.toLinkPath() == ws / Path"deps" / Path("balls.nimble-link")

  test "balls url using nameOverrides":
    discard nc.nameOverrides.addPattern("balls", "https://github.com/disruptek/balls.git")
    let upkg = nc.createUrl("balls")
    check upkg.url.hostname == "github.com"
    check $upkg.url == "https://github.com/disruptek/balls"
    check $upkg.projectName == "balls.disruptek.github.com"
    check upkg.toDirectoryPath() == ws / Path"deps" / Path("balls")
    check upkg.toLinkPath() == ws / Path"deps" / Path("balls.nimble-link")

  test "git url with colon":
    let upkg = nc.createUrl("git://github.com:disruptek/cutelog")
    check upkg.url.hostname == "github.com"
    check $upkg.url == "ssh://github.com/disruptek/cutelog"
    check $upkg.projectName == "cutelog.disruptek.github.com"
    check upkg.toDirectoryPath() == ws / Path"deps" / Path("cutelog")
    check upkg.toLinkPath() == ws / Path"deps" / Path("cutelog.nimble-link")

  test "git url with colon and port":
    let upkg = nc.createUrl("git://github.com:1234/disruptek/cutelog")
    check upkg.url.hostname == "github.com"
    check $upkg.url == "ssh://github.com:1234/disruptek/cutelog"
    check $upkg.projectName == "cutelog.disruptek.github.com"
    check upkg.toDirectoryPath() == ws / Path"deps" / Path("cutelog")
    check upkg.toLinkPath() == ws / Path"deps" / Path("cutelog.nimble-link")

  test "git url no colon":
    let upkg = nc.createUrl("git://github.com/disruptek/cutelog")
    check upkg.url.hostname == "github.com"
    check $upkg.url == "ssh://github.com/disruptek/cutelog"
    check $upkg.projectName == "cutelog.disruptek.github.com"
    check upkg.toDirectoryPath() == ws / Path"deps" / Path("cutelog")
    check upkg.toLinkPath() == ws / Path"deps" / Path("cutelog.nimble-link")

  test "npeg url":
    # setAtlasVerbosity(Trace)
    let upkg = nc.createUrl("https://github.com/zevv/npeg.git")
    check upkg.url.hostname == "github.com"
    check $upkg.url == "https://github.com/zevv/npeg"
    check $upkg.projectName == "npeg"
    check upkg.toDirectoryPath() == ws / Path"deps" / Path("npeg")
    check upkg.toLinkPath() == ws / Path"deps" / Path("npeg.nimble-link")
    let npkg = nc.createUrl("npeg")
    check npkg.url.hostname == "github.com"
    check $npkg.url == "https://github.com/zevv/npeg"

  test "npeg url fork":
    let upkg = nc.createUrl("https://github.com/elcritch/npeg.git")
    check upkg.url.hostname == "github.com"
    check $upkg.url == "https://github.com/elcritch/npeg"
    check $upkg.projectName == "npeg.elcritch.github.com"
    check upkg.toDirectoryPath() == ws / Path"deps" / Path("npeg")
    check upkg.toLinkPath() == ws / Path"deps" / Path("npeg.nimble-link")
    let npkg = nc.createUrl("npeg")
    check npkg.url.hostname == "github.com"
    check $npkg.url == "https://github.com/zevv/npeg"

  test "sync url":
    let upkg = nc.createUrl("https://github.com/planetis-m/sync")
    check upkg.url.hostname == "github.com"
    check $upkg.url == "https://github.com/planetis-m/sync"
    check $upkg.projectName == "sync"
    check upkg.toDirectoryPath() == ws / Path"deps" / Path("sync")
    check upkg.toLinkPath() == ws / Path"deps" / Path("sync.nimble-link")
    let npkg = nc.createUrl("sync")
    check npkg.url.hostname == "github.com"
    check $npkg.url == "https://github.com/planetis-m/sync"

  test "bytes2human url":
    let upkg = nc.createUrl("https://github.com/juancarlospaco/nim-bytes2human")
    check upkg.url.hostname == "github.com"
    check $upkg.url == "https://github.com/juancarlospaco/nim-bytes2human"
    check $upkg.projectName == "nim-bytes2human.juancarlospaco.github.com"
    check upkg.toDirectoryPath() == ws / Path"deps" / Path("nim-bytes2human")
    check upkg.toLinkPath() == ws / Path"deps" / Path("nim-bytes2human.nimble-link")
    expect ValueError:
      discard nc.createUrl("bytes2human")

  test "atlas ssh url":
    let upkg = nc.createUrl("git@github.com:elcritch/atlas.git")
    check upkg.url.hostname == "github.com"
    check $upkg.url == "ssh://git@github.com/elcritch/atlas"
    check $upkg.projectName == "atlas.elcritch.github.com"
    check upkg.toDirectoryPath() == ws / Path"deps" / Path("atlas")
    check upkg.toLinkPath() == ws / Path"deps" / Path("atlas.nimble-link")
    expect ValueError:
      discard nc.createUrl("atlas")

  test "proj_a file url":
    let pth = "file://" & "." & DirSep & "buildGraph" & DirSep & "proj_a"
    echo "PATH: ", pth
    let upkg = nc.createUrl(pth)
    check upkg.url.hostname == ""
    check $upkg.projectName == "proj_a"
    check upkg.toDirectoryPath() == ws / Path"deps" / Path("proj_a")
    check upkg.toLinkPath() == ws / Path"deps" / Path("proj_a.nimble-link")
    check not upkg.isLinkPath()

  test "link path":
    let upkg = nc.createUrl("link://" & $(ws / Path"ws_basic.nimble"))
    check upkg.url.scheme == "link"
    echo "LINK:UPKG: ", upkg.projectName, " url: ", $upkg.url
    check upkg.toDirectoryPath() == ws
    check upkg.projectName == "ws_basic"

    # we want this so we can follow the nimble-link just like a normal package
    # even though it's a link to another project
    check upkg.toLinkPath() == ws / Path"deps" / Path"ws_basic.nimble-link"
    check not upkg.isLinkPath()

  test "windows absolute file url basics":
    check isWindowsAbsoluteFile("D:\\a\\atlas\\atlas\\buildGraph\\proj_a")
    check isWindowsAbsoluteFile("file://D:\\a\\atlas\\atlas\\buildGraph\\proj_a")
    check isWindowsAbsoluteFile("D:/a/atlas/atlas/buildGraph/proj_a")
    check isWindowsAbsoluteFile("file://D:/a/atlas/atlas/buildGraph/proj_a")
    check isWindowsAbsoluteFile("link://D:/a/atlas/atlas/buildGraph/proj_a")

    let ua = fixFileRelativeUrl(parseUri("file://D:\\a\\atlas\\atlas\\buildGraph\\proj_a"), isWindowsTest = true)
    check ua.hostname == ""
    check ua.path == "/D:/a/atlas/atlas/buildGraph/proj_a"

    let ul = fixFileRelativeUrl(parseUri("link://D:\\a\\atlas\\atlas\\buildGraph\\proj_a"), isWindowsTest = true)
    check ul.hostname == ""
    check ul.path == "/D:/a/atlas/atlas/buildGraph/proj_a"

  test "proj_a windows path url with createUrlSkipPatterns":
    project(Path("D:\\a\\atlas\\atlas"))
    defer: project(ws)

    let upkg = createUrlSkipPatterns("D:\\a\\atlas\\atlas\\buildGraph\\proj_a", true, forceWindows = true)
    check upkg.url.hostname == ""
    check $upkg.url == "file:///D:/a/atlas/atlas/buildGraph/proj_a"
    check $upkg.projectName == "proj_a"
    check upkg.toOriginalPath(isWindowsTest = true) == Path($project() & "\\buildGraph\\proj_a")
    check toWindowsFileUrl("file://D:\\a\\atlas\\atlas") == "file:///D:/a/atlas/atlas"
    check toWindowsFileUrl("file://regular/unix/path") == "file://regular/unix/path"

  test "proj_a windows link url with toPkgUriRaw":
    project(Path("D:\\a\\atlas\\atlas"))
    defer: project(ws)

    let upkg = createUrlSkipPatterns("link://D:\\a\\atlas\\atlas\\buildGraph\\proj_a", true, forceWindows = true)
    check upkg.url.hostname == ""
    check $upkg.url == "link:///D:/a/atlas/atlas/buildGraph/proj_a"
    check $upkg.projectName == "proj_a"
    check upkg.toOriginalPath(isWindowsTest = true) == Path($project() & "\\buildGraph\\proj_a")
    check toWindowsFileUrl("link://D:\\a\\atlas\\atlas") == "link:///D:/a/atlas/atlas"
    check toWindowsFileUrl("link://regular/unix/path") == "link://regular/unix/path"

  test "proj_a windows atlas url with toPkgUriRaw":
    project(Path("D:\\a\\atlas\\atlas"))
    defer: project(ws)

    let upkg = createUrlSkipPatterns("atlas://D:\\a\\atlas\\atlas\\buildGraph\\proj_a\\proj_a.nimble", true, forceWindows = true)
    echo "UPKG: ", upkg.repr
    check upkg.url.hostname == ""
    check $upkg.url == "atlas:///D:/a/atlas/atlas/buildGraph/proj_a/proj_a.nimble"
    check $upkg.projectName == "proj_a"
    check upkg.toOriginalPath(isWindowsTest = true) == Path($project() & "\\buildGraph\\proj_a\\proj_a.nimble")
    check toWindowsFileUrl("atlas://D:\\a\\atlas\\atlas") == "atlas:///D:/a/atlas/atlas"
    check toWindowsFileUrl("atlas://regular/unix/path") == "atlas://regular/unix/path"

  test "proj_b file fixFileAbsoluteUrl":
    # setAtlasVerbosity(Trace)
    when not defined(windows):
      let uabs = fixFileRelativeUrl(parseUri("file://" & "." / "buildGraph" / "proj_b"), isWindowsTest = false)

  test "proj_b file url absolute path":

    let pth = ("file://" & "$1" / "buildGraph" / "proj_b")
    let upkg = nc.createUrl(pth % [ospaths2.getCurrentDir()])
    check upkg.url.hostname == ""
    when defined(windows):
      check $upkg.url == ("file:///$1/buildGraph/proj_b" % [ospaths2.getCurrentDir().replace("\\", "/")])
    else:
      check $upkg.url == pth % [ospaths2.getCurrentDir()]
    check $upkg.projectName == "proj_b"
    check upkg.toDirectoryPath() == ws / Path"deps" / Path("proj_b")
    check upkg.toLinkPath() == ws / Path"deps" / Path("proj_b.nimble-link")

  # test "project atlas url":
  #   let upkg = nc.createUrl("atlas://project/test.nimble")
  #   check upkg.url.hostname == "project"
  #   check $upkg.url == "atlas://project/test.nimble"
  #   check $upkg.projectName == "test"
  #   check upkg.toDirectoryPath() == ws
  #   check upkg.toLinkPath() == Path""
  #   check not upkg.isLinkPath()

  test "foobar link file":
    let upkg = nc.createUrl("foobar")
    check upkg.toLinkPath() == ws / Path"deps" / Path("foobar.nimble-link")
    check upkg.isLinkPath()
    check upkg.toDirectoryPath() == ws / Path"remote-deps" / Path("foobar")
    echo "LINKPATH: ", upkg.toLinkPath()
    check upkg.toLinkPath().fileExists()

  test "print names":
    let upkg = nc.createUrl("https://github.com/disruptek/balls.git")
    echo "\nNimbleContext:urlToNames: "
    privateAccess(nc.type)
    # for url, name in nc.urlToNames:
    #   echo "\t", url, " ".repeat(60 - len($(url))), name

    echo "\nNimbleContext:nameToUrl: "
    privateAccess(nc.type)
    for name, url in nc.nameToUrl:
      echo "\t", name, " ".repeat(50 - len($(name))), url

  test "createUrl with Path":
    setAtlasVerbosity(Trace)
    let nestedPath = Path"tests" / Path"ws_basic"
    createDir(nestedPath)
    let upkg = nc.createUrlFromPath(nestedPath)
    echo "UPKG: ", upkg
    echo "UPKG: ", upkg.repr
    check upkg.url.scheme == "atlas"
    check upkg.projectName == "ws_basic"

    let lpkg = nc.createUrlFromPath(nestedPath, isLinkPath = true)
    echo "LPKG: ", lpkg.url
    check lpkg.url.scheme == "link"
    check lpkg.projectName == "ws_basic"
    check lpkg.toOriginalPath() == Path("tests/ws_basic").absolutePath()

  # test "createUrl with Path":
  #   let testPath = Path(paths.getCurrentDir()) / Path"test_project"
  #   let upkg = nc.createUrlFromPath(testPath)
  #   check upkg.url.scheme == "file"
  #   check upkg.projectName == "test_project"
  #   check upkg.url.path.endsWith("test_project")
  #   check nc.lookup(upkg.projectName) == upkg
  #   # Test with a more complex path
  #   let nestedPath = Path"tests" / Path"ws_basic" / Path"parent" / Path"child_project"
  #   createDir(nestedPath)
  #   let nestedPkg = nc.createUrlFromPath(nestedPath)
  #   check nestedPkg.projectName == "child_project"
  #   check nestedPkg.url.path.endsWith("child_project")
  #   check nc.lookup(nestedPkg.projectName) == nestedPkg

template v(x): untyped = Version(x)

suite "versions":

  setup:
    let lines {.used.} = dedent"""
    24870f48c40da2146ce12ff1e675e6e7b9748355 1.6.12
    b54236aaee2fc90200cb3a4e7070820ced9ce605 1.6.10
    f06dc8ee3baf8f64cce67a28a6e6e8a8cd9bf04b 1.6.8
    2f85924354af35278a801079b7ff3f8805ff1f5a 1.6.6
    007bf1cb52eac412bc88b3ca2283127ad578ec04 1.6.4
    ee18eda86eef2db0a49788bf0fc8e35996ba7f0d 1.6.2
    1a2a82e94269741b0d8ba012994dd85a53f36f2d 1.6.0
    074f7159752b0da5306bdedb3a4e0470af1f85c0 1.4.8
    4eb05ebab2b4d8b0cd00b19a72af35a2d767819a 1.4.6
    944c8e6d04a044611ed723391272f3c86781eadd 1.4.4
    cd090a6151b452b99d65c5173400d4685916f970 1.4.2
    01dd8c7a959adac4aa4d73abdf62cbc53ffed11b 1.4.0
    1420d508dc4a3e51137647926d4db2f3fa62f43c 1.2.18
    726e3bb1ffc6bacfaab0a0abf0209640acbac807 1.2.16
    80d2206e68cd74020f61e23065c7a22376af8de5 1.2.14
    ddfe3905964fe3db33d7798c6c6c4a493cbda6a3 1.2.12
    6d914b7e6edc29c3b8ab8c0e255bd3622bc58bba 1.2.10
    0d1a9f5933eab686ab3b527b36d0cebd3949a503 1.2.8
    a5a0a9e3cb14e79d572ba377b6116053fc621f6d 1.2.6
    f9829089b36806ac0129c421bf601cbb30c2842c 1.2.4
    8b03d39fd387f6a59c97c2acdec2518f0b18a230 1.2.2
    a8a4725850c443158f9cab38eae3e54a78a523fb 1.2.0
    8b5888e0545ee3d931b7dd45d15a1d8f3d6426ef 1.0.10
    7282e53cad6664d09e8c9efd0d7f263521eda238 1.0.8
    283a4137b6868f1c5bbf0dd9c36d850d086fa007 1.0.6
    e826ff9b48af376fdc65ba22f7aa1c56dc169b94 1.0.4
    4c33037ef9d01905130b22a37ddb13748e27bb7c 1.0.2
    0b6866c0dc48b5ba06a4ce57758932fbc71fe4c2 1.0.0
    a202715d182ce6c47e19b3202e0c4011bece65d8 0.20.2
    8ea451196bd8d77b3592b8b34e7a2c49eed784c9 0.20.0
    1b512cc259b262d06143c4b34d20ebe220d7fb5c 0.19.6
    be22a1f4e04b0fec14f7a668cbaf4e6d0be313cb 0.19.4
    5cbc7f6322de8460cc4d395ed0df6486ae68004e 0.19.2
    79934561e8dde609332239fbc8b410633e490c61 0.19.0
    9c53787087e36b1c38ffd670a077903640d988a8 0.18.0
    a713ffd346c376cc30f8cc13efaee7be1b8dfab9 0.17.2
    2084650f7bf6f0db6003920f085e1a86f1ea2d11 0.17.0
    f7f68de78e9f286b704304836ed8f20d65acc906 0.16.0
    48bd4d72c45f0f0202a0ab5ad9d851b05d363988 0.15.2
    dbee7d55bc107b2624ecb6acde7cabe4cb3f5de4 0.15.0
    0a4854a0b7bcef184f060632f756f83454e9f9de 0.14.2
    5333f2e4cb073f9102f30aacc7b894c279393318 0.14.0
    7e50c5b56d5b5b7b96e56b6c7ab5e104124ae81b 0.13.0
    49bce0ebe941aafe19314438fb724c081ae891aa 0.12.0
    70789ef9c8c4a0541ba24927f2d99e106a6fe6cc 0.11.2
    79cc0cc6e501c8984aeb5b217a274877ec5726bc 0.11.0
    46d829f65086b487c08d522b8d0d3ad36f9a2197 0.10.2
    9354d3de2e1ecc1747d6c42fbfa209fb824837c0 0.9.6
    6bf5b3d78c97ce4212e2dd4cf827d40800650c48 0.9.4
    220d35d9e19b0eae9e7cd1f1cac6e77e798dbc72 0.9.2
    7a70058005c6c76c92addd5fc21b9706717c75e3 0.9.0
    32b4192b3f0771af11e9d850046e5f3dd42a9a5f 0.8.14
    """

    let onlyCommits {.used.} = dedent"""
    24870f48c40da2146ce12ff1e675e6e7b9748355
    b54236aaee2fc90200cb3a4e7070820ced9ce605
    f06dc8ee3baf8f64cce67a28a6e6e8a8cd9bf04b

    """

  test "basics":
    check v"1.0" < v"1.0.1"
    check v"1.0" < v"1.1"
    check v"1.2.3" < v"1.2.4"
    check v"2.0.0" < v"2.0.0.1"
    check v"2.0.0" < v"20.0"
    check not (v"1.10.0" < v"1.2.0")

  test "hashes":
    check v"1.0" < v"#head"
    check v"#branch" < v"#head"
    check v"#branch" < v"1.0"
    check not (v"#head" < v"#head")
    check not (v"#head" < v"10.0")

  test "version expressions":

    proc p(s: string): VersionInterval =
      var err = false
      result = parseVersionInterval(s, 0, err)
      assert not err

    let tags = parseTaggedVersions(lines)
    let query = p">= 1.2 & < 1.4"
    let queryStr = $(query)
    check queryStr == ">= 1.2 & < 1.4"
    echo "QUERY STR: ", queryStr
    check selectBestCommitMinVer(tags, query).h == "a8a4725850c443158f9cab38eae3e54a78a523fb"

    let query2 = p">= 1.2 & < 1.4"
    let queryStr2 = $(query2)
    check queryStr2 == ">= 1.2 & < 1.4"
    check selectBestCommitMaxVer(tags, query2).h == "1420d508dc4a3e51137647926d4db2f3fa62f43c"

    let query3 = p">= 0.20.0"
    let queryStr3 = $(query3)
    check queryStr3 == ">= 0.20.0"
    check selectBestCommitSemVer(tags, query3).h == "a202715d182ce6c47e19b3202e0c4011bece65d8"

    # let query4 = p"#head"
    # let queryStr4 = $(query4)
    # check queryStr4 == "#head"
    # check selectBestCommitSemVer(tags, query4).h == "24870f48c40da2146ce12ff1e675e6e7b9748355"

  test "lastPathComponent":
    check lastPathComponent("/a/bc///") == "bc"
    check lastPathComponent("a/b") == "b"
    check lastPathComponent("meh/longer/here/") == "here"
    check lastPathComponent("meh/longer/here") == "here"

  test "extractRequirementName":
    # Test basic package names
    check extractRequirementName("mypackage") == ("mypackage", @[], 9)
    check extractRequirementName("mypackage >= 1.0") == ("mypackage", @[], 9)
    check extractRequirementName("mypackage <= 2.0") == ("mypackage", @[], 9)
    check extractRequirementName("mypackage == 1.5") == ("mypackage", @[], 9)
    check extractRequirementName("mypackage > 1.0") == ("mypackage", @[], 9)
    check extractRequirementName("mypackage < 2.0") == ("mypackage", @[], 9)

    check extractRequirementName("mypackage[feature1]") == ("mypackage", @["feature1"], 19)

    check extractRequirementName("mypackage[feature1, feature2]") == ("mypackage", @["feature1", "feature2"], 29)
    check extractRequirementName("mypackage[feature1, feature2] >= 1.0") == ("mypackage", @["feature1", "feature2"], 29)
    check extractRequirementName("mypackage[feature1, feature2] <= 2.0") == ("mypackage", @["feature1", "feature2"], 29)
    check extractRequirementName("mypackage[feature1, feature2] == 1.5") == ("mypackage", @["feature1", "feature2"], 29)
    check extractRequirementName("mypackage[feature1, feature2] > 1.0") == ("mypackage", @["feature1", "feature2"], 29)
    check extractRequirementName("mypackage[feature1, feature2] < 2.0") == ("mypackage", @["feature1", "feature2"], 29)

  test "onlyCommits with parseTaggedVersions":
    let tags = parseTaggedVersions(onlyCommits, false)
    echo "TAGS: ", $tags
    check tags.len() == 3
    check tags[0].c.h == "24870f48c40da2146ce12ff1e675e6e7b9748355"
    check tags[1].c.h == "b54236aaee2fc90200cb3a4e7070820ced9ce605"
    check tags[2].c.h == "f06dc8ee3baf8f64cce67a28a6e6e8a8cd9bf04b"

  test "test version tag and commit hash str":
    let c1 = initCommitHash("24870f48c40da2146ce12ff1e675e6e7b9748355", FromNone)
    let v1 = VersionTag(v: Version"#head", c: c1)

    check $c1 == "24870f48c40da2146ce12ff1e675e6e7b9748355"
    check $v1 == "#head@24870f48"

    let v2 = toVersionTag("#head@24870f48c40da2146ce12ff1e675e6e7b9748355")
    check $v2 == "#head@24870f48"
    check repr(v2) == "#head@24870f48c40da2146ce12ff1e675e6e7b9748355"

    let v3 = toVersionTag("#head@-")
    check v3.v.string == "#head"
    check v3.c.h == ""
    check $v3 == "#head@-"
    # check repr(v3) == "#head@-"

    let v4 = VersionTag(v: Version"#head", c: initCommitHash("", FromGitTag))
    check v4 == v3


import basic/[versions]

template v(x): untyped = Version(x)

suite "version interval matches":

  proc p(s: string): VersionInterval =
    var err = false
    result = parseVersionInterval(s, 0, err)
    # assert not err

  test "simple equality match":
    let interval = p"1.0.0"
    check interval.matches(v"1.0.0") == true
    check interval.matches(v"1.0.1") == false
    check interval.matches(v"0.9.9") == false
  
  test "greater than or equal":
    let interval = p">= 1.0.0"
    check interval.matches(v"1.0.0") == true
    check interval.matches(v"1.0.1") == true
    check interval.matches(v"2.0.0") == true
    check interval.matches(v"0.9.9") == false
  
  test "greater than":
    let interval = p"> 1.0.0"
    check interval.matches(v"1.0.0") == false
    check interval.matches(v"1.0.1") == true
    check interval.matches(v"2.0.0") == true
    check interval.matches(v"0.9.9") == false
  
  test "less than or equal":
    let interval = p"<= 1.0.0"
    check interval.matches(v"1.0.0") == true
    check interval.matches(v"0.9.9") == true
    check interval.matches(v"0.1.0") == true
    check interval.matches(v"1.0.1") == false
  
  test "less than":
    let interval = p"< 1.0.0"
    check interval.matches(v"1.0.0") == false
    check interval.matches(v"0.9.9") == true
    check interval.matches(v"0.1.0") == true
    check interval.matches(v"1.0.1") == false
  
  test "any version":
    let interval = p"*"
    check interval.matches(v"1.0.0") == true
    check interval.matches(v"0.0.1") == true
    check interval.matches(v"99.99.99") == true
  
  test "version range with ampersand":
    let interval = p">= 1.0.0 & <= 2.0.0"
    check interval.matches(v"0.9.9") == false
    check interval.matches(v"1.0.0") == true
    check interval.matches(v"1.5.0") == true
    check interval.matches(v"2.0.0") == true
    check interval.matches(v"2.0.1") == false
  
  test "version range with comma":
    # The code notes that Nimble doesn't use this syntax, but it's supported
    let interval = p">= 1.0.0, < 2.0.0"
    check interval.matches(v"0.9.9") == false
    check interval.matches(v"1.0.0") == true
    check interval.matches(v"1.5.0") == true
    check interval.matches(v"2.0.0") == false
  
  test "tight version range":
    let interval = p"> 1.0.0 & < 1.1.0"
    check interval.matches(v"1.0.0") == false
    check interval.matches(v"1.0.1") == true
    check interval.matches(v"1.0.9") == true
    check interval.matches(v"1.1.0") == false
  
  test "special version #head":
    let interval = p"#head"
    echo "special: ", interval.repr
    check interval.matches(v"#head") == true
    check interval.isSpecial == true
    check interval.matches(v"1.0.0") == false
  
  test "special version with and without hash":
    let specialInterval = p"#branch"
    check specialInterval.matches(v"#branch") == true
    # check specialInterval.matches(v"branch") == true  # According to the matching logic
    
    let noHashInterval = p"branch"
    check noHashInterval.matches(v"#branch") == true  # According to the matching logic
  
  test "commit hash matching":
    # Create version tags for testing
    let commit1 = initCommitHash("abcdef123456", FromGitTag)
    let commit2 = initCommitHash("123456abcdef", FromGitTag)
    
    let tag1 = VersionTag(c: commit1, v: v"1.0.0")
    let tag2 = VersionTag(c: commit2, v: v"2.0.0")
    
    # Test commit matching with version intervals
    let specificCommit = p"#abcdef"
    check specificCommit.matches(tag1) == true
    check specificCommit.matches(tag2) == false
    
    # Test regular version matching with tags
    let regularVersion = p"1.0.0"
    check regularVersion.matches(tag1) == true
    check regularVersion.matches(tag2) == false
  
  test "invalid interval":
    # Test >= 2.0.0 & <= 1.0.0 (invalid interval, should match nothing)
    let invalidInterval = p">= 2.0.0 & <= 1.0.0"
    check invalidInterval.matches(v"1.5.0") == false
    check invalidInterval.matches(v"0.5.0") == false
    check invalidInterval.matches(v"2.5.0") == false
  
  test "semver-style matching":
    # Testing how toSemVer works with matches
    let interval = p">= 1.0.0"
    let semVerInterval = interval.toSemVer()
    
    # SemVer should convert >= 1.0.0 to >= 1.0.0 & < 2.0.0
    check semVerInterval.isInterval == true
    check semVerInterval.matches(v"1.0.0") == true
    check semVerInterval.matches(v"1.9.9") == true
    check semVerInterval.matches(v"2.0.0") == false
  
  test "special version comparison":
    # Special versions should be sorted below regular versions
    check not (v"#head" < v"#head")
    check not (v"#head" < v"1.0")
    check v"1.0" < v"#head"
    check v"#branch" < v"#head"
    check v"#branch" < v"1.0" # This is expected behavior based on existing tests
    
  test "version matching with extractSpecificCommit":
    let specificCommitInterval = p"#abcdef"
    let extractedCommit = extractSpecificCommit(specificCommitInterval)
    check extractedCommit.h == "abcdef"
    
    # Test a non-specific commit interval
    let regularInterval = p">= 1.0.0"
    let noCommit = extractSpecificCommit(regularInterval)
    check noCommit.h == ""

  test "version matching with full commit to short":
    var err = false
    # this is what nimbleparser does
    let v1 = parseVersionInterval("proj_a#abcdef123456", 6, err)
    checkpoint "v1: " & v1.repr
    check not v1.matches(v"#abcdef")

    echo "V1: ", v1.repr

    let v2 = parseVersionInterval("proj_a#some-branch", 6, err)
    checkpoint "v2: " & v2.repr
    check v2.matches(v"#some-branch")

    let v3 = parseVersionInterval("proj_a#aac5ff8533150478a85", 6, err)
    checkpoint "v3: " & v3.repr
    check not v3.matches(v"#aac5ff8533150478a85ae6e34e9093997b3a8f76")

    let v4 = parseVersionInterval("proj_b#aac5ff8533150478a85ae6e34e9093997b3a8f76", 6, err)
    checkpoint "v4: " & v4.repr
    check v4.matches(VersionTag(v: v"#aac5ff8533150478a85ae6e34e9093997b3a8f76", c: initCommitHash("aac5ff8533150478a85ae6e34e9093997b3a8f76", FromNone)))

    let v5 = parseVersionInterval("proj_b#some_branch", 6, err)
    checkpoint "v5: " & v5.repr
    let v5tgt = VersionTag(v: v"#some_branch", c: initCommitHash("aac5ff8533150478a85ae6e34e9093997b3a8f76", FromNone))
    echo "v5:isinterval: ", v5.isInterval
    check v5.matches(v5tgt)


suite "sortVersions":
  
  test "patches and minor versions":
    var versions = @[
       VersionTag(v: v"1.2.3", c: initCommitHash("b1", FromNone)),
       VersionTag(v: v"1.2.4", c: initCommitHash("b2", FromNone)),
       VersionTag(v: v"1.3.0", c: initCommitHash("b3", FromNone)),
    ]

    versions.sort(sortVersionsDesc)
    check versions[0].v == v"1.3.0"
    check versions[1].v == v"1.2.4"
    check versions[2].v == v"1.2.3"
  
    versions.sort(sortVersionsAsc)
    check versions[0].v == v"1.2.3"
    check versions[1].v == v"1.2.4"
    check versions[2].v == v"1.3.0"

  test "different commit hashes but same version":
    let v1 = VersionTag(v: v"1.0.0", c: initCommitHash("c1", FromNone))
    let v2 = VersionTag(v: v"1.0.0", c: initCommitHash("c2", FromNone))
    
    check sortVersionsDesc(v1, v2) == 0  # Versions are equal, ignoring commit
    check sortVersionsAsc(v1, v2) == 0  # Versions are equal, ignoring commit
  
  test "special versions":
    let v1 = VersionTag(v: v"1.0.0", c: initCommitHash("d1", FromNone))
    let v2 = VersionTag(v: v"#head", c: initCommitHash("d2", FromNone))
    let v3 = VersionTag(v: v"#branch", c: initCommitHash("d3", FromNone))
    
    # Based on the existing Version comparison tests:
    # v"1.0" < v"#head"
    # v"#branch" < v"#head"
    # v"#branch" < v"1.0"
    
    check sortVersionsDesc(v1, v2) == 1  # 1.0.0 should come after #head
    check sortVersionsDesc(v3, v2) == 1  # #branch should come after #head
    check sortVersionsDesc(v3, v1) == 1 # #branch should come before 1.0.0
    check sortVersionsAsc(v1, v2) == -1  # 1.0.0 should come after #head
    check sortVersionsAsc(v3, v2) == -1  # #branch should come after #head
    check sortVersionsAsc(v3, v1) == -1 # #branch should come before 1.0.0
  
  test "sort a sequence of version tags":
    var versions = @[
      VersionTag(v: v"1.2.0", c: initCommitHash("e1", FromNone)),
      VersionTag(v: v"1.0.0", c: initCommitHash("e2", FromNone)),
      VersionTag(v: v"2.0.0", c: initCommitHash("e3", FromNone)),
      VersionTag(v: v"#head", c: initCommitHash("e4", FromNone)),
      VersionTag(v: v"1.1.0", c: initCommitHash("e5", FromNone))
    ]
    
    versions.sort(sortVersionsDesc)
    # Expected order (descending): #head, 2.0.0, 1.2.0, 1.1.0, 1.0.0
    check versions[0].v == v"#head"
    check versions[1].v == v"2.0.0"
    check versions[2].v == v"1.2.0"
    check versions[3].v == v"1.1.0"
    check versions[4].v == v"1.0.0"

    versions.sort(sortVersionsAsc)
    # Expected order (ascending)
    check versions[0].v == v"1.0.0"
    check versions[1].v == v"1.1.0"
    check versions[2].v == v"1.2.0"
    check versions[3].v == v"2.0.0"
    check versions[4].v == v"#head"
