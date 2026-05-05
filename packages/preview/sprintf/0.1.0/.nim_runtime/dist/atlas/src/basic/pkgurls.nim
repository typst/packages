#
#           Atlas Package Cloner
#        (c) Copyright 2024 Andreas Rumpf
#
#    See the file "copying.txt", included in this
#    distribution, for details about the copyright.
#

import std / [hashes, uri, os, strutils, files, dirs, sequtils, pegs]
import gitops, reporters, context

export uri

const
  GitSuffix = ".git"

type
  PkgUrl* = object
    qualifiedName*: tuple[name: string, user: string, host: string]
    hasShortName*: bool
    u: Uri

proc isFileProtocol*(s: PkgUrl): bool = s.u.scheme == "file"
proc isEmpty*(s: PkgUrl): bool = s.qualifiedName[0].len() == 0 or $s.u == ""
proc isUrl*(s: string): bool = s.startsWith("git@") or "://" in s

proc fullName*(u: PkgUrl): string =
  if u.qualifiedName.host.len() > 0 or u.qualifiedName.user.len() > 0:  
    result = u.qualifiedName.name & "." & u.qualifiedName.user & "." & u.qualifiedName.host
  else:
    result = u.qualifiedName.name

proc shortName*(u: PkgUrl): string =
  u.qualifiedName.name

proc projectName*(u: PkgUrl): string =
  if u.hasShortName or u.qualifiedName.host == "":
    u.qualifiedName.name
  else:
    u.qualifiedName.name & "." & u.qualifiedName.user & "." & u.qualifiedName.host

proc requiresName*(u: PkgUrl): string =
  if u.hasShortName:
    u.qualifiedName.name
  else:
    $u.u

proc toUri*(u: PkgUrl): Uri = result = u.u
proc url*(p: PkgUrl): Uri = p.u
proc `$`*(u: PkgUrl): string = $u.u
proc hash*(a: PkgUrl): Hash {.inline.} = hash(a.u)
proc `==`*(a, b: PkgUrl): bool {.inline.} = a.u == b.u

proc toReporterName(u: PkgUrl): string = u.projectName()

proc extractProjectName*(url: Uri): tuple[name: string, user: string, host: string] =
  var u = url
  var (p, n, e) = u.path.splitFile()
  p.removePrefix(DirSep)
  p.removePrefix(AltSep)
  if u.scheme in ["http", "https"] and e == GitSuffix:
    e = ""

  if u.scheme == "atlas":
    result = (n, "", "")
  elif u.scheme == "file":
    result = (n & e, "", "")
  elif u.scheme == "link":
    result = (n, "", "")
  else:
    result = (n & e, p, u.hostname)

proc toOriginalPath*(pkgUrl: PkgUrl, isWindowsTest: bool = false): Path =
  if pkgUrl.url.scheme in ["file", "link", "atlas"]:
    result = Path(pkgUrl.url.hostname & pkgUrl.url.path)
    if defined(windows) or isWindowsTest:
      var p = result.string.replace('/', '\\')
      p.removePrefix('\\')
      result = p.Path
  else:
    raise newException(ValueError, "Invalid file path: " & $pkgUrl.url)

proc linkPath*(path: Path): Path =
  result = Path(path.string & ".nimble-link")

proc toDirectoryPath(pkgUrl: PkgUrl, isLinkFile: bool): Path =
  trace pkgUrl, "directory path from:", $pkgUrl.url

  if pkgUrl.url.scheme == "atlas":
    result = project()
  elif pkgUrl.url.scheme == "link":
    result = pkgUrl.toOriginalPath().parentDir()
  elif pkgUrl.url.scheme == "file":
    # file:// urls are used for local source paths, not dependency paths
    result = depsDir() / Path(pkgUrl.projectName())
  else:
    # Always clone git deps into shortName-based folders so switching remotes
    # doesn't affect the on-disk location.
    result = depsDir() / Path(pkgUrl.shortName())
  
  if not isLinkFile and not dirExists(result) and fileExists(result.linkPath()):
    # prefer the directory path if it exists (?)
    let linkPath = result.linkPath()
    let link = readFile($linkPath)
    let lines = link.split("\n")
    if lines.len != 2:
      warn pkgUrl.projectName(), "invalid link file:", $linkPath
    else:
      let nimble = Path(lines[0])
      result = nimble.splitFile().dir
      if not result.isAbsolute():
        result = linkPath.parentDir() / result
      debug pkgUrl.projectName(), "link file to:", $result

  result = result.absolutePath
  trace pkgUrl, "found directory path:", $result
  doAssert result.len() > 0

proc toDirectoryPath*(pkgUrl: PkgUrl): Path =
  toDirectoryPath(pkgUrl, false)

proc toLinkPath*(pkgUrl: PkgUrl): Path =
  if pkgUrl.url.scheme == "atlas":
    result = Path("")
  elif pkgUrl.url.scheme == "link":
    result = depsDir() / Path(pkgUrl.projectName() & ".nimble-link")
  else:
    result = Path(toDirectoryPath(pkgUrl, true).string & ".nimble-link")

proc isLinkPath*(pkgUrl: PkgUrl): bool =
  result = fileExists(toLinkPath(pkgUrl))

proc isAtlasProject*(pkgUrl: PkgUrl): bool =
  result = pkgUrl.url.scheme == "link"

proc isNimbleLink*(pkgUrl: PkgUrl): bool =
  pkgUrl.url.scheme == "link" or pkgUrl.isLinkPath()

proc createNimbleLink*(pkgUrl: PkgUrl, nimblePath: Path, cfgPath: CfgPath) =
  let nimbleLink = toLinkPath(pkgUrl)
  trace "nimble:link", "creating link at:", $nimbleLink, "from:", $nimblePath
  if nimbleLink.len() == 0:
    raise newException(ValueError, "Invalid link path: " & $nimbleLink)

  if nimbleLink.fileExists():
    return

  let nimblePath = nimblePath.absolutePath()
  let cfgPath = cfgPath.Path.absolutePath()

  writeFile($nimbleLink, "$1\n$2" % [$nimblePath, $cfgPath])

proc isWindowsAbsoluteFile*(raw: string): bool =
  raw.match(peg"^ {'file://'?} {[A-Z] ':' ['/'\\]} .*") or
  raw.match(peg"^ {'link://'?} {[A-Z] ':' ['/'\\]} .*") or
  raw.match(peg"^ {'atlas://'?} {[A-Z] ':' ['/'\\]} .*")

proc toWindowsFileUrl*(raw: string): string =
  let rawPath = raw.replace('\\', '/')
  if rawPath.isWindowsAbsoluteFile():
    result = rawPath
    result = result.replace("file://", "file:///")
    result = result.replace("link://", "link:///")
    result = result.replace("atlas://", "atlas:///")
  else:
    result = rawPath

proc fixFileRelativeUrl*(u: Uri, isWindowsTest: bool = false): Uri =
  if isWindowsTest or defined(windows) and u.scheme in ["file", "link", "atlas"] and u.hostname.len() > 0:
    result = parseUri(toWindowsFileUrl($u))
  else:
    result = u

  if result.scheme in ["file", "link", "atlas"] and result.hostname.len() > 0:
    # fix relative paths
    var url = (project().string / (result.hostname & result.path)).absolutePath
    url = result.scheme & "://" & url
    if isWindowsTest or defined(windows):
      url = toWindowsFileUrl(url)
    result = parseUri(url)

proc createUrlSkipPatterns*(raw: string, skipDirTest = false, forceWindows: bool = false): PkgUrl =
  template cleanupUrl(u: Uri) =
    if u.path.endsWith(".git") and (u.scheme in ["http", "https"] or u.hostname in ["github.com", "gitlab.com", "bitbucket.org"]):
      u.path.removeSuffix(".git")

    u.path = u.path.strip(leading=false, trailing=true, {'/'})

  if not raw.isUrl():
    if dirExists(raw) or skipDirTest:
      var raw: string = raw
      if isGitDir(raw):
        raw = getCanonicalUrl(Path(raw))
      else:
        if not forceWindows:
          raw = raw.absolutePath()
        if forceWindows or defined(windows) or defined(atlasUnitTests):
          raw = toWindowsFileUrl("file:///" & raw)
        else:
          raw = "file://" & raw
      let u = parseUri(raw)
      result = PkgUrl(qualifiedName: extractProjectName(u), u: u, hasShortName: true)
    else:
      raise newException(ValueError, "Invalid name or URL: " & raw)
  elif raw.startsWith("git@"): # special case git@server.com
    var u = parseUri("ssh://" & raw.replace(":", "/"))
    cleanupUrl(u)
    result = PkgUrl(qualifiedName: extractProjectName(u), u: u, hasShortName: false)
  else:
    var u = parseUri(raw)
    var hasShortName = false

    if u.scheme == "git":
      if u.port.anyIt(not it.isDigit()):
        u.path = "/" & u.port & u.path
        u.port = ""

      u.scheme = "ssh"

    if u.scheme in ["file", "link", "atlas"]:
      # fix missing absolute paths
      u = fixFileRelativeUrl(u, isWindowsTest = forceWindows)
      hasShortName = true

    cleanupUrl(u)
    result = PkgUrl(qualifiedName: extractProjectName(u), u: u, hasShortName: hasShortName)
  # trace result, "created url raw:", repr(raw), "url:", repr(result)

proc toPkgUriRaw*(u: Uri, hasShortName: bool = false): PkgUrl =
  result = createUrlSkipPatterns($u, true)
  result.hasShortName = hasShortName
