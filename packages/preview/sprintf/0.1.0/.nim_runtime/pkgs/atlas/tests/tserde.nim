import std/[unittest, json, jsonutils]
import basic/[context, sattypes, pkgurls, deptypes, nimblecontext, depgraphtypes]
import basic/[deptypesjson, versions]

proc p(s: string): VersionInterval =
  var err = false
  result = parseVersionInterval(s, 0, err)
  # assert not err

suite "json serde":
  setup:
    var nc = createUnfilledNimbleContext()
    nc.put("foobar", toPkgUriRaw(parseUri "https://github.com/nimble-test/foobar.git"))
    nc.put("proj_a", toPkgUriRaw(parseUri "https://example.com/buildGraph/proj_a"))

  test "pkg url":
    let upkg = nc.createUrl("foobar")
    let jn = toJson(upkg)
    var upkg2: PkgUrl
    upkg2.fromJson(jn)
    check upkg == upkg2
    echo "upkg2: ", $(upkg2)

    let url2 = nc.createUrl("https://github.com/nimble-test/foobar")
    check url2.projectName() == "foobar"


  test "pkg url, version interval":
    let upkg = nc.createUrl("foobar")
    let jn = toJson((upkg, p"1.0.0"))
    var upkg2: (PkgUrl, VersionInterval)
    upkg2.fromJson(jn)
    check upkg2[0] == upkg

  test "json serde ordered table":
    var table: OrderedTable[PkgUrl, Package]
    let url = nc.createUrl("foobar")
    var pkg = Package(url: url)
    table[url] = pkg
    let jn = toJson(table)
    var table2: OrderedTable[PkgUrl, Package]
    table2.fromJson(jn)
    # note this will fail because the url doesn't use nimble context
    # check table == table2

  test "json dep graph":
    var graph = DepGraph()
    let url = nc.createUrl("foobar")
    var pkg = Package(url: url)
    graph.root = pkg
    graph.pkgs[url] = pkg
    let url2 = nc.createUrl("proj_a")
    var pkg2 = Package(url: url2)
    graph.pkgs[url2] = pkg2

    let jn = toJsonGraph(graph)
    var graph2 = loadJson(nc, jn)

    echo "root: ", graph.root.repr
    echo "root2: ", graph2.root.repr

    echo "root2.url: ", $(graph2.root.url), " project name: ", graph2.root.url.projectName()

    check graph.root.hash() == graph2.root.hash()

    check graph.pkgs[url].hash() == graph2.pkgs[url].hash()
    check graph.pkgs[url2].hash() == graph2.pkgs[url2].hash()

  test "json serde nimble release":
    let release = NimbleRelease(version: Version"1.0.0", requirements: @[(nc.createUrl("foobar"), p"1.0.0")])
    let jnRelease = toJson(release)
    echo "jnRelease: ", pretty(jnRelease)
    var release2: NimbleRelease
    release2.fromJson(jnRelease)
    check release == release2

  test "json serde version interval":

    let interval = p"1.0.0"
    let jn = toJson(interval)
    var interval2 = VersionInterval()
    interval2.fromJson(jn)
    check interval == interval2

    let query = p">= 1.2 & < 1.4"
    let jn2 = toJson(query)
    var query2 = VersionInterval()
    query2.fromJson(jn2)
    check query == query2

  test "var ids":
    let var1 = VarId(1)
    let jn = toJson(var1)
    var var2 = VarId(0)
    var2.fromJson(jn)
    check var1.int == var2.int

  test "path":
    let path1 = Path("test.nim")
    let jn = toJson(path1)
    var path2: Path
    path2.fromJson(jn)
    check path1 == path2

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

    let v4 = VersionTag(v: Version"#head", c: initCommitHash("", FromGitTag))
    check v4 == v3

    let jn = toJson(v1)
    var v5 = VersionTag()
    v5.fromJson(jn)
    check v5 == v1
    echo "v5: ", repr(v5)

    let jn2 = toJson(c1)
    var c2 = CommitHash()
    c2.fromJson(jn2)
    check c2 == c1
    echo "c2: ", repr(c2)

    let jn3 = toJson(v3)
    var v6 = VersionTag()
    v6.fromJson(jn3)
    check v6 == v3
    echo "v6: ", repr(v6)

    let jn4 = toJson(v4)
    var v7 = VersionTag()
    v7.fromJson(jn4)
    check v7 == v4
    echo "v7: ", repr(v7)

  test "test empty version tag":
    let v8 = VersionTag()
    echo "v8: ", repr(v8)
    let jn = toJson(v8)

    var v9 = VersionTag()
    v9.fromJson(jn)
    check v9 == v8
    echo "v9: ", repr(v9)
    
  
