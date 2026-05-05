import std/[json, jsonutils, paths, tables, sets, strutils]
import sattypes, deptypes, pkgurls, versions, nimblecontext

export json, jsonutils

proc toJsonHook*(v: VersionInterval): JsonNode = toJson($(v))
proc toJsonHook*(v: Version): JsonNode = toJson($v)
proc toJsonHook*(v: VersionTag): JsonNode = toJson(repr(v))

proc fromJsonHook*(a: var VersionInterval; b: JsonNode; opt = Joptions()) =
  var err = false
  a = parseVersionInterval(b.getStr(), 0, err)


proc fromJsonHook*(a: var Version; b: JsonNode; opt = Joptions()) =
  a = toVersion(b.getStr())

proc fromJsonHook*(a: var VersionTag; b: JsonNode; opt = Joptions()) =
  var raw = b.getStr()
  var isTip = false
  if raw.endsWith("^"):
    isTip = true
    raw = raw[0..^2]
  a = toVersionTag(raw)
  a.isTip = isTip
proc toJsonHook*(v: PkgUrl): JsonNode = %($(v))

proc fromJsonHook*(a: var PkgUrl; b: JsonNode; opt = Joptions()) =
  a = toPkgUriRaw(parseUri(b.getStr()))

proc toJsonHook*(vid: VarId): JsonNode = toJson(int(vid))

proc fromJsonHook*(a: var VarId; b: JsonNode; opt = Joptions()) =
  a = VarId(int(b.getInt()))

proc toJsonHook*(p: Path): JsonNode = toJson($(p))

proc fromJsonHook*(a: var Path; b: JsonNode; opt = Joptions()) =
  a = Path(b.getStr())

proc toJsonHook*(v: (PkgUrl, VersionInterval), opt: ToJsonOptions): JsonNode =
  result = newJObject()
  result["url"] = toJsonHook(v[0])
  result["version"] = toJsonHook(v[1])

proc fromJsonHook*(a: var (PkgUrl, VersionInterval); b: JsonNode; opt = Joptions()) =
  a[0].fromJson(b["url"])
  a[1].fromJson(b["version"])

proc toJsonHook*(v: Table[PkgUrl, HashSet[string]], opt: ToJsonOptions): JsonNode =
  result = newJObject()
  for k, v in v:
    result[$(k)] = toJson(v, opt)

proc fromJsonHook*(a: var Table[PkgUrl, HashSet[string]]; b: JsonNode; opt = Joptions()) =
  for k, v in b:
    var url: PkgUrl
    url.fromJson(toJson(k))
    var flags: HashSet[string]
    flags.fromJson(toJson(v))
    a[url] = flags

proc toJsonHook*(t: OrderedTable[PackageVersion, NimbleRelease], opt: ToJsonOptions): JsonNode =
  result = newJArray()
  for k, v in t:
    var tpl = newJArray()
    tpl.add toJson(k, opt)
    tpl.add toJson(v, opt)
    result.add tpl
    # result[repr(k.vtag)] = toJson(v, opt)

proc fromJsonHook*(t: var OrderedTable[PackageVersion, NimbleRelease]; b: JsonNode; opt = Joptions()) =
  for item in b:
    var pv: PackageVersion
    pv.fromJson(item[0])
    var release: NimbleRelease
    release.fromJson(item[1])
    t[pv] = release

proc toJsonHook*(t: OrderedTable[PkgUrl, Package], opt: ToJsonOptions): JsonNode =
  result = newJObject()
  for k, v in t:
    result[$(k)] = toJson(v, opt)

proc fromJsonHook*(t: var OrderedTable[PkgUrl, Package]; b: JsonNode; opt = Joptions()) =
  for k, v in b:
    var url: PkgUrl
    url.fromJson(toJson(k))
    var pkg: Package
    pkg.fromJson(v)
    t[url] = pkg

proc toJsonHook*(r: NimbleRelease, opt: ToJsonOptions = ToJsonOptions()): JsonNode =
  if r == nil:
    return newJNull()
  result = newJObject()
  result["requirements"] = toJson(r.requirements, opt)
  if r.hasInstallHooks:
    result["hasInstallHooks"] = toJson(r.hasInstallHooks, opt)
  if r.srcDir != Path "":
    result["srcDir"] = toJson(r.srcDir, opt)
  result["version"] = toJson(r.version, opt)
  result["status"] = toJson(r.status, opt)
  if r.err != "":
    result["err"] = toJson(r.err, opt)

proc fromJsonHook*(r: var NimbleRelease; b: JsonNode; opt = Joptions()) =
  if r.isNil:
    r = new(NimbleRelease)
  r.version.fromJson(b["version"])
  r.requirements.fromJson(b["requirements"])
  r.status.fromJson(b["status"])
  if b.hasKey("hasInstallHooks"):
    r.hasInstallHooks = b["hasInstallHooks"].getBool()
  if b.hasKey("srcDir"):
    r.srcDir.fromJson(b["srcDir"])
  if b.hasKey("err"):
    r.err = b["err"].getStr()

proc toJsonGraph*(d: DepGraph): JsonNode =
  result = toJson(d, ToJsonOptions(enumMode: joptEnumString))

proc dumpJson*(d: DepGraph, filename: string, pretty = true) =
  let jn = toJsonGraph(d)
  if pretty:
    writeFile(filename, pretty(jn))
  else:
    writeFile(filename, $(jn))

proc loadJson*(nc: var NimbleContext, json: JsonNode): DepGraph =
  result.fromJson(json, Joptions(allowMissingKeys: true, allowExtraKeys: true))
  var pkgs = result.pkgs
  result.pkgs.clear()

  for url, pkg in pkgs:
    let url2 = nc.createUrl($pkg.url)
    pkg.url = url2
    result.pkgs[url2] = pkg
  
  let rootUrl = nc.createUrl($result.root.url)
  result.root = result.pkgs[rootUrl]

proc loadJson*(nc: var NimbleContext, filename: string): DepGraph =
  let jn = parseFile(filename)
  result = loadJson(nc, jn)
