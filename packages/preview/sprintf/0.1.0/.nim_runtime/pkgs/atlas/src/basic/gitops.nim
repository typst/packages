#
#           Atlas Package Cloner
#        (c) Copyright 2021 Andreas Rumpf
#
#    See the file "copying.txt", included in this
#    distribution, for details about the copyright.
#

import std/[os, files, paths, osproc, options, sequtils, strutils, uri, sets, tables]
import reporters, osutils, versions, context

type
  Command* = enum
    GitClone = "git clone",
    GitRemoteUrl = "git -C $DIR config --get remote.$REMOTE.url",
    GitRemotesShow = "git -C $DIR remote",
    GitRemoteAdd = "git -C $DIR remote add",
    GitRemoteSetUrl = "git -C $DIR remote set-url",
    GitRemoteRename = "git -C $DIR remote rename",
    GitDiff = "git -C $DIR diff",
    GitFetch = "git -C $DIR fetch",
    GitFetchHeads = "git -C $DIR fetch $REMOTE " &
      quoteShell("+refs/heads/*:refs/remotes/$REMOTE/*"),
    GitTag = "git -C $DIR tag",
    GitTags = "git -C $DIR show-ref --tags",
    GitShowRef = "git -C $DIR show-ref",
    GitLastTaggedRef = "git -C $DIR rev-list --tags --max-count=1",
    GitDescribe = "git -C $DIR describe",
    GitRevParse = "git -C $DIR rev-parse",
    GitCheckout = "git -C $DIR checkout",
    GitSubModUpdate = "git -C $DIR submodule update --init",
    GitPush = "git -C $DIR push $REMOTE",
    GitPull = "git -C $DIR pull",
    GitCurrentCommit = "git -C $DIR log -n1 --format=%H"
    GitMergeBase = "git -C $DIR merge-base"
    GitLsFiles = "git -C $DIR ls-files"
    GitLog = "git -C $DIR log --format=%H $REMOTE"
    GitLogLocal = "git -C $DIR log --format=%H HEAD"
    GitCurrentBranch = "git -C $DIR rev-parse --abbrev-ref HEAD"
    GitLsRemote = "git -C $DIR ls-remote --quiet --tags"
    GitShowFiles = "git -C $DIR show"
    GitListFiles = "git -C $DIR ls-tree --name-only -r"
    GitForEachRef = "git -C $DIR for-each-ref"

proc fetchRemoteTags*(path: Path; origin = "origin"; errorReportLevel: MsgKind = Warning): bool
proc fetchRemoteTagsByName(path: Path; remote: string; errorReportLevel: MsgKind = Warning): bool
proc resolveRemoteName*(path: Path; origin = "origin"; errorReportLevel: MsgKind = Warning): string
proc maybeUrlProxy*(url: Uri): Uri
proc syncRemoteRefs(path: Path; srcRemote, dstRemote: string; errorReportLevel: MsgKind = Warning): bool
proc exec*(gitCmd: Command;
           path: Path;
           args: openArray[string],
           errorReportLevel: MsgKind = Error,
           subs: openArray[string] = [],
           requireRepo: bool = true,
           streamOutput: bool = false,
           ): (string, ResultCode)

proc execQuiet(gitCmd: Command;
               path: Path;
               args: openArray[string],
               subs: openArray[string] = [],
               ): (string, ResultCode) =
  result = exec(gitCmd, path, args, Debug, subs = subs)

proc resolveRemoteTipRef*(path: Path; remote: string): string =
  ## Returns a local ref to the remote's tip without querying the network.
  if remote.len == 0: return ""
  let base = "refs/remotes/" & remote & "/"
  let (outp, status) = execQuiet(GitShowRef, path, [])
  if status != RES_OK: return ""

  var hasHead, hasMain, hasMaster = false
  for line in outp.splitLines():
    let parts = line.splitWhitespace()
    if parts.len < 2:
      continue
    let refName = parts[^1]
    if not refName.startsWith(base):
      continue
    case refName.substr(base.len)
    of "HEAD": hasHead = true
    of "main": hasMain = true
    of "master": hasMaster = true
    else: discard
  if hasHead: remote & "/HEAD"
  elif hasMain: remote & "/main"
  elif hasMaster: remote & "/master"
  else: ""

proc sameVersionAs*(tag, ver: string): bool =
  const VersionChars = {'0'..'9', '.'}

  proc safeCharAt(s: string; i: int): char {.inline.} =
    if i >= 0 and i < s.len: s[i] else: '\0'

  let idx = find(tag, ver)
  if idx >= 0:
    # we found the version as a substring inside the `tag`. But we
    # need to watch out the the boundaries are not part of a
    # larger/different version number:
    result = safeCharAt(tag, idx-1) notin VersionChars and
      safeCharAt(tag, idx+ver.len) notin VersionChars

proc extractVersion*(s: string): string =
  var i = 0
  while i < s.len and s[i] notin {'0'..'9'}: inc i
  result = s.substr(i)

proc exec*(gitCmd: Command;
           path: Path;
           args: openArray[string],
           errorReportLevel: MsgKind = Error,
           subs: openArray[string] = [],
           requireRepo: bool = true,
           streamOutput: bool = false,
           ): (string, ResultCode) =
  var repl: seq[string] = @["DIR", $path]
  for s in subs:
    repl.add s
  let cmd = $gitCmd % repl
  if requireRepo and not isGitDir(path):
    result = ("Not a git repo", ResultCode(1))
  elif streamOutput:
    var cmdLine = cmd
    for i in 0..<args.len:
      cmdLine.add ' '
      if args[i].len > 0:
        cmdLine.add quoteShell(args[i])
    result = ("", ResultCode(execShellCmd(cmdLine)))
  else:
    result = silentExec(cmd, args)
  if result[1] != RES_OK:
    message errorReportLevel, "gitops", "Running Git failed:", $(int(result[1])), "command:", "`$1 $2`" % [cmd, join(args, " ")]

proc checkGitDiffStatus*(path: Path): string =
  let (outp, status) = exec(GitDiff, path, [])
  if outp.len != 0:
    "'git diff' not empty"
  elif status != RES_OK:
    "'git diff' returned non-zero"
  else:
    ""

proc listRemotes(path: Path): seq[string] =
  let (outp, status) = exec(GitRemotesShow, path, [], Debug)
  if status == RES_OK:
    outp.splitLines().mapIt(it.strip()).filterIt(it.len > 0)
  else:
    @[]

proc remoteNameFromGitUrl*(rawUrl: string): string =
  if rawUrl.len == 0:
    return ""

  var u: Uri
  try:
    if rawUrl.startsWith("git@"):
      u = parseUri("ssh://" & rawUrl.replace(":", "/"))
    else:
      u = parseUri(rawUrl)
  except CatchableError:
    return ""

  if u.hostname.len == 0:
    return ""

  var p = u.path
  p.removePrefix("/")
  p.removeSuffix("/")
  p.removeSuffix(".git")
  let parts = p.split("/")
  if parts.len < 2:
    return ""

  let user = parts[^2]
  let repo = parts[^1]
  if user.len == 0:
    repo
  else:
    repo & "." & user & "." & u.hostname

proc getRemoteUrlFor(path: Path; remote: string): string =
  let (outp, status) = exec(
    GitRemoteUrl,
    path,
    [],
    Debug,
    subs = ["REMOTE", remote]
  )
  if status != RES_OK:
    return ""
  outp.strip()

proc getCanonicalUrl*(path: Path; origin = "origin"): string =
  ## Returns the canonical URL stored in the `origin` remote.
  getRemoteUrlFor(path, origin)

proc ensureRemoteUrl(path: Path; remote, url: string; errorReportLevel: MsgKind = Warning): bool =
  if remote.len == 0 or url.len == 0 or not isGitDir(path):
    return false

  let remotes = listRemotes(path)
  if remote notin remotes:
    let (_, status) = exec(GitRemoteAdd, path, [remote, url], Debug)
    if status == RES_OK:
      return true
    message(errorReportLevel, path, "could not add remote '" & remote & "'")
    return false

  let (_, status) = exec(GitRemoteSetUrl, path, [remote, url], Debug)
  if status == RES_OK:
    return true
  message(errorReportLevel, path, "could not set URL for remote '" & remote & "'")
  false

proc ensureCanonicalOrigin*(path: Path; url: Uri; origin = "origin"; errorReportLevel: MsgKind = Warning): bool =
  ## Ensures `origin` exists and points to the canonical URL.
  ensureRemoteUrl(path, origin, $url, errorReportLevel)

proc ensureRemoteForUrl*(path: Path; url: Uri; errorReportLevel: MsgKind = Warning): string =
  ## Ensures a named remote exists for `url` (derived from `repo.user.host`).
  result = remoteNameFromGitUrl($url)
  if result.len == 0:
    return ""
  let fetchUrl =
    if $context().proxy != "":
      maybeUrlProxy(url)
    else:
      url
  discard ensureRemoteUrl(path, result, $fetchUrl, errorReportLevel)

proc fetchRemoteHeadsByName(path: Path; remote: string; errorReportLevel: MsgKind = Warning): bool =
  ## Fetch heads into refs/remotes/<remote>/ so branch names can be resolved.
  if remote.len == 0:
    return false

  var args: seq[string] = @[]
  if ShallowClones in context().flags:
    args.add "--depth=1"
  let (outp, status) = exec(GitFetchHeads, path, args, errorReportLevel, subs = ["REMOTE", remote])
  if status != RES_OK:
    message(errorReportLevel, path, "could not fetch remote heads:", outp)
  status == RES_OK

proc fetchRemoteHeadsAndTagsByName(path: Path; remote: string; errorReportLevel: MsgKind = Warning): bool =
  ## Fetch heads and tags in a single network round-trip.
  if remote.len == 0:
    return false

  var args: seq[string] = @[]
  if ShallowClones in context().flags:
    args.add "--depth=1"
  args.add remote
  args.add "+refs/heads/*:refs/remotes/" & remote & "/*"
  args.add "+refs/tags/*:refs/remotes/" & remote & "/tags/*"

  let (outp, status) = exec(GitFetch, path, args, errorReportLevel)
  if status != RES_OK:
    message(errorReportLevel, path, "could not fetch remote heads/tags:", outp)
  status == RES_OK

proc fetchRemoteHeads*(path: Path; origin = "origin"; errorReportLevel: MsgKind = Warning): bool =
  let remote = resolveRemoteName(path, origin, errorReportLevel)
  if remote.len == 0:
    return false
  fetchRemoteHeadsByName(path, remote, errorReportLevel)

proc resolveRemoteName*(path: Path; origin = "origin"; errorReportLevel: MsgKind = Warning): string =
  ## Resolves the operational remote name from the canonical URL stored in `origin`.
  ## Ensures that remote exists (adding it from `origin` if needed).
  let canonicalUrl = getCanonicalUrl(path, origin)
  if canonicalUrl.len == 0:
    message(errorReportLevel, path, "missing canonical remote '" & origin & "'")
    return ""

  result = remoteNameFromGitUrl(canonicalUrl)
  if result.len == 0:
    message(errorReportLevel, path, "could not derive remote name from canonical URL: " & canonicalUrl)
    return ""

  let remotes = listRemotes(path)
  if result notin remotes:
    if origin in remotes:
      let (_, status) = exec(GitRemoteRename, path, [origin, result], Debug)
      if status != RES_OK:
        message(errorReportLevel, path, "could not rename remote '" & origin & "' to '" & result & "'")
        return ""
      discard ensureRemoteUrl(path, origin, canonicalUrl, errorReportLevel)
    else:
      discard ensureRemoteUrl(path, result, canonicalUrl, errorReportLevel)

  if $context().proxy != "":
    try:
      discard ensureRemoteUrl(path, result, $maybeUrlProxy(canonicalUrl.parseUri()), errorReportLevel)
    except CatchableError:
      discard

proc maybeUrlProxy*(url: Uri): Uri =
  result = url
  if $context().proxy != "":
    result = context().proxy
    result.path = url.path
    result.query = url.query
    result.anchor = url.anchor

  if url.scheme == "git":
    if ForceGitToHttps in context().flags:
      result.scheme = "https"
    else:
      result.scheme = ""

  if result.hostname == "github.com":
    result.path = result.path.strip(leading=false, trailing=true, {'/'})

proc clone*(url: Uri, dest: Path; retries = 5): (CloneStatus, string) =
  ## clone git repo.
  ##
  ## note clones don't use `--recursive` but rely in the `checkoutCommit`
  ## stage to setup submodules as this is less fragile on brRES_OKen submodules.
  ##

  # retry multiple times to avoid annoying github timeouts:
  let extraArgs =
    if $context().proxy != "" and DumbProxy in context().flags: ""
    elif ShallowClones in context().flags: "--depth=1"
    else: ""

  let canonicalUrl = url
  var url = maybeUrlProxy(url)

  let remote = remoteNameFromGitUrl($canonicalUrl)

  # Try first clone with git output directly to the terminal
  # primarily to give the user feedback for clones that take a while
  var args: seq[string] = @[]
  if extraArgs.len > 0:
    args.add extraArgs
  if remote.len > 0:
    args.add "--origin"
    args.add remote
  args.add "--no-tags"
  args.add $url
  args.add $dest
  let (_, status) = exec(GitClone, dest, args, Debug, requireRepo = false, streamOutput = true)
  if status == RES_OK:
    discard ensureCanonicalOrigin(dest, canonicalUrl)
    return (Ok, "")

  const Pauses = [0, 1000, 2000, 3000, 4000, 6000]
  for i in 1..retries:
    os.sleep(Pauses[min(i, Pauses.len()-1)])
    let (outp, status) = exec(GitClone, dest, args, Debug, requireRepo = false)
    if status == RES_OK:
      discard ensureCanonicalOrigin(dest, canonicalUrl)
      return (Ok, "")
    elif "not found" in outp or "Not a git repo" in outp:
      return (NotFound, "not found")
    else:
      result[1] = outp

  result[0] = NotFound

proc gitDescribeRefTag*(path: Path, commit: string): string =
  let (lt, status) = exec(GitDescribe, path, ["--tags", commit])
  result = if status == RES_OK: strutils.strip(lt) else: ""

proc findOriginTip*(path: Path; origin = "origin"; errorReportLevel: MsgKind = Warning, isLocalOnly = false): VersionTag =
  let remoteName =
    if isLocalOnly: ""
    else: resolveRemoteName(path, origin, errorReportLevel)
  var remoteRef =
    if isLocalOnly: ""
    else: resolveRemoteTipRef(path, remoteName)
  if not isLocalOnly and remoteRef.len == 0:
    # Ensure we have remote heads available for branch resolution.
    if fetchRemoteHeads(path, origin, errorReportLevel):
      remoteRef = resolveRemoteTipRef(path, remoteName)
  let cmd = if isLocalOnly: GitLogLocal else: GitLog
  let subs =
    if isLocalOnly or remoteRef.len == 0:
      @[]
    else:
      @["REMOTE", remoteRef]
  let cmd2 =
    if isLocalOnly or remoteRef.len == 0:
      GitLogLocal
    else:
      cmd
  if not isLocalOnly and remoteRef.len == 0:
    message(errorReportLevel, path, "could not find remote head for '" & remoteName & "'; using local HEAD at:", $path)
  let (outp1, status1) = exec(cmd2, path, ["-n1"], Warning, subs = subs)
  var allVersions: seq[VersionTag]
  if status1 == RES_OK:
    allVersions = parseTaggedVersions(outp1, requireVersions = false)
    if allVersions.len > 0:
      result = allVersions[0]
      result.isTip = true

proc collectTaggedVersions*(path: Path; origin = "origin"; errorReportLevel: MsgKind = Debug, isLocalOnly = false): seq[VersionTag] =
  let remote =
    if isLocalOnly: ""
    else: resolveRemoteName(path, origin, errorReportLevel)
  let tip = findOriginTip(path, origin, errorReportLevel, isLocalOnly)

  let localTags = "refs/tags"
  var refs: seq[string] = @["--format=%(objectname) %(refname)", localTags]
  if remote.len > 0:
    refs.add "refs/remotes/" & remote & "/tags"
  let (outp, status) = exec(GitForEachRef, path, refs, errorReportLevel)
  if status == RES_OK:
    result = parseTaggedVersions(outp)
    if result.len > 0 and tip.isTip:
      if result[0].c == tip.c:
        result[0].isTip = true
  else:
    message(errorReportLevel, path, "could not collect tagged commits at:", $path)

proc collectFileCommits*(path, file: Path; origin = "origin"; errorReportLevel: MsgKind = Warning, isLocalOnly = false): seq[VersionTag] =
  let remote =
    if isLocalOnly: ""
    else: resolveRemoteName(path, origin, errorReportLevel)
  let tip = findOriginTip(path, origin, errorReportLevel, isLocalOnly)

  if not isLocalOnly and remote.len == 0:
    return @[]
  let remoteRef =
    if isLocalOnly: ""
    else: resolveRemoteTipRef(path, remote)
  let cmd =
    if isLocalOnly or remoteRef.len == 0:
      GitLogLocal
    else:
      GitLog
  let subs =
    if isLocalOnly or remoteRef.len == 0:
      @[]
    else:
      @["REMOTE", remoteRef]
  let (outp, status) = exec(cmd, path, ["--", $file], Warning, subs = subs)
  if status == RES_OK:
    result = parseTaggedVersions(outp, requireVersions = false)
    if result.len > 0 and tip.isTip:
      if result[0].c == tip.c:
        result[0].isTip = true
  else:
    message(errorReportLevel, file, "could not collect file commits at:", $file)

proc versionToCommit*(path: Path; origin = "origin"; algo: ResolutionAlgorithm; query: VersionInterval): CommitHash =
  let allVersions = collectTaggedVersions(path, origin)
  case algo
  of MinVer:
    result = selectBestCommitMinVer(allVersions, query)
  of SemVer:
    result = selectBestCommitSemVer(allVersions, query)
  of MaxVer:
    result = selectBestCommitMaxVer(allVersions, query)

proc shortToCommit*(path: Path, short: CommitHash): CommitHash =
  let (cc, status) = exec(GitRevParse, path, [short.h])
  info path, "shortToCommit: ", $short, "result:", cc
  result = initCommitHash("", FromHead)
  if status == RES_OK:
    let vtags = parseTaggedVersions(cc, requireVersions = false)
    if vtags.len() == 1:
      result = vtags[0].c

proc expandSpecial*(path: Path; origin = "origin"; vtag: VersionTag, errorReportLevel: MsgKind = Warning): VersionTag =
  if vtag.version.isHead():
    return findOriginTip(path, origin, errorReportLevel, false)

  let remote = resolveRemoteName(path, origin, errorReportLevel)
  let (cc, status) = exec(GitRevParse, path, [vtag.version.string.substr(1)], errorReportLevel)

  template processSpecial(cc: string) =
    let vtags = parseTaggedVersions(cc, requireVersions = false)
    if vtags.len() == 1:
      result.c = vtags[0].c
      if vtag.version.string.substr(1) in result.c.h: # expand short commit hash to full hash
        result.v = Version("#" & $(result.c))
    info path, "expandSpecial: ", $vtag, "result:", repr result

  result = VersionTag(v: vtag.version, c: initCommitHash("", FromHead))
  if status == RES_OK:
    processSpecial(cc)
  else:
    if remote.len == 0:
      message(errorReportLevel, path, "could not resolve remote from canonical '" & origin & "'")
      return
    let remoteRef = remote & "/" & vtag.version.string.substr(1)
    var (ccRemote, statusRemote) = exec(GitRevParse, path, [remoteRef], errorReportLevel)
    if statusRemote != RES_OK and fetchRemoteHeads(path, origin, errorReportLevel):
      (ccRemote, statusRemote) = exec(GitRevParse, path, [remoteRef], errorReportLevel)
    if statusRemote == RES_OK:
      processSpecial(ccRemote)
    else:
      message(errorReportLevel, path, "could not expand special version:", $vtag)

proc listFiles*(path: Path): seq[string] =
  let (outp, status) = exec(GitLsFiles, path, [])
  if status == RES_OK:
    result = outp.splitLines().mapIt(it.strip())
  else:
    result = @[]

proc showFile*(path: Path, commit: CommitHash, file: string): string =
  let (outp, status) = exec(GitShowFiles, path, [commit.h & ":" & $file])
  if status == RES_OK:
    result = outp
  else:
    result = ""

proc listFiles*(path: Path, commit: CommitHash): seq[string] =
  let (outp, status) = exec(GitListFiles, path, [commit.h])
  if status == RES_OK:
    result = outp.splitLines().mapIt(it.strip())
  else:
    result = @[]

proc listRemoteTags*(path: Path, url: string, errorReportLevel: MsgKind = Debug): (seq[VersionTag], bool) =
  var url = maybeUrlProxy(url.parseUri())

  let (outp, status) = exec(GitLsRemote, path, [$url], errorReportLevel)
  if status == RES_OK:
    result = (parseTaggedVersions(outp), true)
  else:
    result = (@[], false)

proc currentGitCommit*(path: Path, errorReportLevel: MsgKind = Info): CommitHash =
  let (currentCommit, status) = exec(GitCurrentCommit, path, [], errorReportLevel)
  if status == RES_OK:
    return initCommitHash(currentCommit.strip(), FromGitTag)
  else:
    return initCommitHash("", FromNone)

proc checkoutGitCommit*(path: Path, commit: CommitHash, errorReportLevel: MsgKind = Warning): bool =
  let currentCommit = currentGitCommit(path)
  if currentCommit.isFull() and currentCommit == commit:
    return true

  let (_, statusB) = exec(GitCheckout, path, [commit.h], errorReportLevel)
  if statusB != RES_OK:
    message(errorReportLevel, path, "could not checkout commit " & $commit)
    result = false
  else:
    trace path, "updated package to ", $commit
    result = true

proc checkoutGitCommitFull*(path: Path; commit: CommitHash; origin = "origin";
                            errorReportLevel: MsgKind = Warning): bool =
  var smExtraArgs: seq[string] = @[]
  result = true
  if ShallowClones in context().flags and commit.isFull():
    smExtraArgs.add "--depth=1"

    let remote = resolveRemoteName(path, origin, errorReportLevel)
    if remote.len == 0:
      message(errorReportLevel, $path, "could not resolve remote from canonical '" & origin & "'")
      return false
    let extraArgs =
      if DumbProxy in context().flags: ""
      elif ShallowClones notin context().flags: "--update-shallow"
      else: ""
    let (_, status) = exec(GitFetch, path, [extraArgs, "--no-tags", remote, commit.h], errorReportLevel)
    if status != RES_OK:
      message(errorReportLevel, $path, "could not fetch commit " & $commit)
      result = false
    else:
      trace($path, "fetched package commit " & $commit)
  elif commit.isShort():
    info($path, "found short commit id; doing full fetch to resolve " & $commit)
    let (outp, status) = exec(GitFetch, path, ["--unshallow", "--no-tags"])
    if status != RES_OK:
      message(errorReportLevel, $path, "could not fetch: " & outp)
      result = false
    else:
      trace($path, "fetched package updates ")

  let (_, status) = exec(GitCheckout, path, [commit.h], errorReportLevel)
  if status != RES_OK:
    message(errorReportLevel, $path, "could not checkout commit " & $commit)
    result = false
  else:
    trace $path, "updated package to:", $commit

  if fileExists(path / Path".gitmodules"):
    notice relativeToWorkspace(path), "Found submodules; Updating..."
    let (_, subModStatus) = exec(GitSubModUpdate, path, smExtraArgs)
    if subModstatus != RES_OK:
      message(errorReportLevel, $path, "could not update submodules")
      result = false
    else:
      debug($path, "updated submodules")

proc gitPull*(path: Path) =
  let (outp, status) = exec(GitPull, path, [])
  if status != RES_OK:
    debug path, "git pull error: \n" & outp.splitLines().mapIt("\n>>> " & it).join("")
    error(path, "could not 'git pull'")

proc gitTag*(path: Path, tag: string) =
  let (_, status) = exec(GitTag, path, [tag])
  if status != RES_OK:
    error(path, "could not 'git tag " & tag & "'")

proc pushTag*(path: Path; origin = "origin"; tag: string) =
  let remote = resolveRemoteName(path, origin)
  if remote.len == 0:
    error(path, "could not resolve remote from canonical '" & origin & "'")
    return
  let (outp, status) = exec(GitPush, path, [tag], subs = ["REMOTE", remote])
  if status != RES_OK:
    error(path, "could not 'git push " & remote & " " & tag & "'")
  elif outp.strip() == "Everything up-to-date":
    info(path, "is up-to-date")
  else:
    info(path, "successfully pushed tag: " & tag)

proc incrementTag*(displayName, lastTag: string; field: Natural): string =
  var startPos =
    if lastTag[0] in {'0'..'9'}: 0
    else: 1
  var endPos = lastTag.find('.', startPos)
  if field >= 1:
    for i in 1 .. field:
      if endPos == -1:
        error displayName, "the last tag '" & lastTag & "' is missing . periods"
        return ""
      startPos = endPos + 1
      endPos = lastTag.find('.', startPos)
  if endPos == -1:
    endPos = len(lastTag)
  let patchNumber = parseInt(lastTag[startPos..<endPos])
  lastTag[0..<startPos] & $(patchNumber + 1) & lastTag[endPos..^1]

proc incrementLastTag*(path: Path, field: Natural): string =
  let (ltr, status) = exec(GitLastTaggedRef, path, [])
  if status != RES_OK or ltr == "":
    "v0.0.1" # assuming no tags have been made yet
  else:
    let
      lastTaggedRef = ltr.strip()
      lastTag = gitDescribeRefTag(path, lastTaggedRef)
      currentCommit = exec(GitCurrentCommit, path, [])[0].strip()

    if lastTaggedRef == "":
      "v0.0.1" # assuming no tags have been made yet
    elif lastTaggedRef == "" or lastTaggedRef == currentCommit:
      info path, "the current commit '" & currentCommit & "' is already tagged '" & lastTag & "'"
      lastTag
    else:
      incrementTag($path, lastTag, field)

# proc needsCommitLookup*(commit: string): bool {.inline.} =
#   '.' in commit or commit == InvalidCommit

proc isShortCommitHash*(commit: string): bool {.inline.} =
  commit.len >= 4 and commit.len < 40

proc getRemoteUrl*(path: Path; origin = "origin"; errorReportLevel: MsgKind = Warning): string =
  ## Returns the URL for the operational remote (derived from the canonical URL stored in `origin`).
  let remote = resolveRemoteName(path, origin, errorReportLevel)
  if remote.len == 0:
    return ""
  getRemoteUrlFor(path, remote)

proc hasNewTags*(path: Path; origin = "origin"): Option[tuple[outdated: bool, newTags: int]] =
  ## determine if the given git repo `f` is updateable
  ## returns an option tuple with the outdated flag and the number of new tags
  ## the option is none if the repo doesn't have remote url or remote tags

  info path, "checking is package is up to date..."

  # TODO: does --update-shallow fetch tags on a shallow repo?
  let localTags = collectTaggedVersions(path, origin, isLocalOnly = true).toHashSet()

  let url = getRemoteUrl(path, origin)
  if url.len == 0:
    return none(tuple[outdated: bool, newTags: int])
  let (remoteTagsList, lsStatus) = listRemoteTags(path, url)
  let remoteTags = remoteTagsList.toHashSet()

  if not lsStatus:
    warn path, "git list remote tags failed, skipping"
    return none(tuple[outdated: bool, newTags: int])

  if remoteTags > localTags:
    warn path, "got new versions:", $(remoteTags - localTags)
    return some((true, remoteTags.len() - localTags.len()))
  elif remoteTags.len() == 0:
    info path, "no local tags found, checking for new commits"
    return none(tuple[outdated: bool, newTags: int])

  return some((false, 0))

proc remoteRefsSnapshot(path: Path; remote: string; onlyTags: bool): tuple[ok: bool, refs: string] =
  let refsPrefix =
    if onlyTags:
      "refs/remotes/" & remote & "/tags"
    else:
      "refs/remotes/" & remote
  let (outp, status) = exec(
    GitForEachRef,
    path,
    ["--format=%(objectname) %(refname)", refsPrefix],
    Debug
  )
  if status != RES_OK:
    return (false, "")
  (true, outp.strip())

proc countUpdatedRefs(beforeRefs, afterRefs: string): int =
  var beforeByRef = initTable[string, string]()

  for line in beforeRefs.splitLines():
    let parts = line.splitWhitespace()
    if parts.len >= 2:
      beforeByRef[parts[1]] = parts[0]

  for line in afterRefs.splitLines():
    let parts = line.splitWhitespace()
    if parts.len < 2:
      continue
    let refName = parts[1]
    let refCommit = parts[0]
    if refName notin beforeByRef or beforeByRef[refName] != refCommit:
      inc result

proc updateRemote*(path: Path; remote: string; onlyTags = false): bool =
  if remote.len == 0:
    warn path, "no remote found; cannot update"
    return false

  let beforeFetch = remoteRefsSnapshot(path, remote, onlyTags)

  if onlyTags:
    if not fetchRemoteTagsByName(path, remote):
      error(path, "could not update remote tags: " & remote)
      return false
    let afterFetch = remoteRefsSnapshot(path, remote, onlyTags)
    if beforeFetch.ok and afterFetch.ok:
      if beforeFetch.refs == afterFetch.refs:
        notice(path, "tags already up to date: " & remote)
      else:
        let updatedRefs = countUpdatedRefs(beforeFetch.refs, afterFetch.refs)
        let refLabel = if updatedRefs == 1: " ref" else: " refs"
        warn(path, "updated remote tags: " & remote & " (" &
          $updatedRefs & refLabel & " updated)")
    else:
      warn(path, "updated remote tags: " & remote)
    return true
  else:
    if not fetchRemoteHeadsAndTagsByName(path, remote):
      error(path, "could not update remote heads/tags: " & remote)
      return false
    let afterFetch = remoteRefsSnapshot(path, remote, onlyTags)
    if beforeFetch.ok and afterFetch.ok:
      if beforeFetch.refs == afterFetch.refs:
        notice(path, "up to date: " & remote)
      else:
        let updatedRefs = countUpdatedRefs(beforeFetch.refs, afterFetch.refs)
        let refLabel = if updatedRefs == 1: " ref" else: " refs"
        warn(path, "updated remote: " & remote & " (" &
          $updatedRefs & refLabel & " updated)")
    else:
      warn(path, "updated remote: " & remote)
    return true

proc syncRemoteRefs(path: Path; srcRemote, dstRemote: string; errorReportLevel: MsgKind = Warning): bool =
  if srcRemote.len == 0 or dstRemote.len == 0:
    return false
  if srcRemote == dstRemote:
    return true

  let refspec = "+refs/remotes/" & srcRemote & "/*:refs/remotes/" & dstRemote & "/*"
  let (outp, status) = exec(GitFetch, path, [".", refspec], errorReportLevel)
  if status != RES_OK:
    message(errorReportLevel, path,
      "could not sync remote refs from '" & srcRemote & "' to '" & dstRemote & "':", outp)
  status == RES_OK

proc updateRepo*(path: Path; origin = "origin"; onlyTags = false) =
  ## updates all remotes for the repo
  if not isGitDir(path):
    info path, "not a git repo; cannot update"
    return

  # Keep canonical remote setup in sync before iterating all remotes.
  let canonicalUrl = getCanonicalUrl(path, origin)
  let canonicalRemote =
    if canonicalUrl.len > 0:
      resolveRemoteName(path, origin)
    else:
      ""

  let remotes = listRemotes(path)
  if remotes.len == 0:
    info path, "no remotes found; cannot update"
    return

  # Prefer canonical qualified remote first so aliases like `origin`
  # can sync from it without additional network fetches.
  var orderedRemotes: seq[string] = @[]
  if canonicalRemote.len > 0 and canonicalRemote in remotes:
    orderedRemotes.add canonicalRemote
  for remote in remotes:
    if remote != canonicalRemote:
      orderedRemotes.add remote

  var hasErrors = false
  var updatedByUrl: seq[tuple[url: string, remote: string]] = @[]
  for remote in orderedRemotes:
    let remoteUrl = getRemoteUrlFor(path, remote)

    if remoteUrl.len > 0:
      var syncedFrom = ""
      for it in updatedByUrl:
        if it.url == remoteUrl:
          syncedFrom = it.remote
          break
      if syncedFrom.len > 0:
        info path, "skipping remote '" & remote & "'; same URL as '" & syncedFrom & "'"
        if not syncRemoteRefs(path, syncedFrom, remote, Debug):
          warn path, "could not sync remote alias refs '" & syncedFrom & "' -> '" & remote & "'"
        continue
      updatedByUrl.add (remoteUrl, remote)

    if not updateRemote(path, remote, onlyTags):
      hasErrors = true

  if hasErrors:
    if onlyTags:
      error(path, "could not update repo tags across remotes")
    else:
      error(path, "could not update repo remotes")
  else:
    if onlyTags:
      info(path, "successfully updated repo tags")
    else:
      info(path, "successfully updated repo")

proc fetchRemoteTagsByName(path: Path; remote: string; errorReportLevel: MsgKind = Warning): bool =
  ## Fetch tags into refs/remotes/<remote>/tags/ instead of refs/tags/.
  if remote.len == 0:
    return false
  var args: seq[string] = @[]
  if ShallowClones in context().flags:
    args.add "--depth=1"
  args.add remote
  args.add "+refs/tags/*:refs/remotes/" & remote & "/tags/*"
  let (outp, status) = exec(GitFetch, path, args, errorReportLevel)
  if status != RES_OK:
    message(errorReportLevel, path, "could not fetch remote tags:", outp)
  result = status == RES_OK

proc fetchRemoteTags*(path: Path; origin = "origin"; errorReportLevel: MsgKind = Warning): bool =
  let remote = resolveRemoteName(path, origin, errorReportLevel)
  if remote.len == 0:
    return false
  fetchRemoteTagsByName(path, remote, errorReportLevel)
