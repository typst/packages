#
#           Atlas Package Cloner
#        (c) Copyright 2021 Andreas Rumpf
#
#    See the file "copying.txt", included in this
#    distribution, for details about the copyright.
#

import std / [strutils, uri, parseutils, algorithm, hashes, tables, sets]

type
  Version* = distinct string

  VersionRelation* = enum
    verGe, # >= V -- Equal or later
    verGt, # > V
    verLe, # <= V -- Equal or earlier
    verLt, # < V
    verEq, # V
    verAny, # *
    verSpecial # #head

  VersionReq* = object
    r: VersionRelation
    v: Version

  VersionInterval* = object
    a: VersionReq
    b: VersionReq
    isInterval: bool

  ResolutionAlgorithm* = enum
    MinVer, SemVer, MaxVer

  CommitHash* = object
    h*: string
    orig*: CommitOrigin

  VersionTag* = object
    c*: CommitHash
    v*: Version
    isTip*: bool

  CommitOrigin* = enum
    FromNone, FromHead, FromGitTag, FromDep, FromNimbleFile, FromLockfile

const
  InvalidCommit* = "<invalid commit>"

proc `$`*(v: Version): string =
  result = v.string
  if result == "":
    result = "~"
proc `$`*(c: CommitHash): string =
  result = c.h
  if result == "":
    result = "-"

const ValidChars = {'a'..'f', '0'..'9'}

proc isLowerAlphaNum*(s: string): bool =
  for c in s:
    if c notin ValidChars:
      return false
  return true

proc initCommitHash*(raw: string, origin: CommitOrigin): CommitHash = 
  result = CommitHash(h: raw.toLower(), orig: origin)
  if not result.h.isLowerAlphaNum():
    result = CommitHash(h: "", orig: FromNone)
  # doAssert result.h.isLowerAlphaNum(), "hash must hexdecimal but got: " & $raw

proc initCommitHash*(c: CommitHash, origin: CommitOrigin): CommitHash = 
  result = c
  result.orig = origin

proc isEmpty*(c: CommitHash): bool =
  c.h.len() == 0
proc isFull*(c: CommitHash): bool =
  c.h.len() == 40
proc isShort*(c: CommitHash): bool =
  5 < c.h.len() and c.h.len() < 12

proc short*(c: CommitHash): string =
  if c.h.len() == 40: c.h[0..7]
  elif c.h.len() == 0: "-"
  else: "!"&c.h[0..<c.h.len()]

proc `$`*(vt: VersionTag): string =
  if vt.v.string != "":
    result = $vt.v
  else: result = "~"
  result &= "@" & vt.c.short()
  if vt.isTip:
    result &= "^"

proc repr*(vt: VersionTag): string =
  if vt.v.string != "":
    result = $vt.v
  else: result = "~" 
  result &= "@" & $vt.c
  if vt.isTip:
    result &= "^"

proc commit*(vt: VersionTag): CommitHash = vt.c
proc version*(vt: VersionTag): Version = vt.v

template versionKey*(i: VersionInterval): string = i.a.v.string

proc createQueryEq*(v: Version): VersionInterval =
  VersionInterval(a: VersionReq(r: verEq, v: v))

proc extractGeQuery*(i: VersionInterval): Version =
  if i.a.r in {verGe, verGt, verEq}:
    result = i.a.v
  else:
    result = Version""

proc isSpecial(v: Version): bool {.inline.} =
  result = v.string.len > 1 and v.string[0] == '#'

proc isValidVersion*(v: string): bool {.inline.} =
  result = v.len > 0 and v[0] in {'#'} + Digits

proc isHead*(v: Version): bool {.inline.} = cmpIgnoreCase(v.string, "#head") == 0

template next(l, p, s: untyped) =
  if l > 0:
    inc p, l
    if p < s.len and s[p] == '.':
      inc p
    else:
      p = s.len
  else:
    p = s.len

proc lt(a, b: string): bool {.inline.} =
  var i = 0
  var j = 0
  while i < a.len or j < b.len:
    var x = 0
    let l1 = parseSaturatedNatural(a, x, i)

    var y = 0
    let l2 = parseSaturatedNatural(b, y, j)

    if x < y:
      return true
    elif x == y:
      discard "continue"
    else:
      return false
    next l1, i, a
    next l2, j, b

  result = false

proc `<`*(a, b: Version): bool =
  # Handling for special versions such as "#head" or "#branch".
  if a.isSpecial or b.isSpecial:
    if a.isHead: return false
    if b.isHead: return true
    # any order will do as long as the "sort" operation moves #thing
    # to the bottom:
    if a.isSpecial and b.isSpecial:
      return a.string < b.string
  return lt(a.string, b.string)

proc eq(a, b: string): bool {.inline.} =
  var i = 0
  var j = 0
  while i < a.len or j < b.len:
    var x = 0
    let l1 = parseSaturatedNatural(a, x, i)

    var y = 0
    let l2 = parseSaturatedNatural(b, y, j)

    if x == y:
      discard "continue"
    else:
      return false
    next l1, i, a
    next l2, j, b

  result = true

proc `==`*(a, b: Version): bool =
  if a.isSpecial or b.isSpecial:
    result = a.string == b.string
  else:
    result = eq(a.string, b.string)

proc sortVersionsAsc*(a, b: VersionTag): int =
  (if a.v < b.v: -1
  elif a.v == b.v: 0
  else: 1)

proc sortVersionsDesc*(a, b: VersionTag): int =
  (if a.v < b.v: 1
  elif a.v == b.v: 0
  else: -1)

proc hash*(a: Version): Hash {.borrow.}

proc `==`*(a, b: VersionInterval): bool {.inline.} = system.`==`(a, b)
proc hash*(a: VersionInterval): Hash {.inline.} = hashes.hash(a)

proc isHead*(a: VersionInterval): bool {.inline.} = a.a.v.isHead
proc isSpecial*(a: VersionInterval): bool {.inline.} = a.a.v.isSpecial
proc isInterval*(a: VersionInterval): bool {.inline.} = a.isInterval

proc parseVer(s: string; start: var int): Version =
  if start < s.len and s[start] == '#':
    var i = start
    while i < s.len and s[i] notin Whitespace: inc i
    result = Version s.substr(start, i-1)
    start = i
  elif start < s.len and s[start] in Digits:
    var i = start
    while i < s.len and s[i] in Digits+{'.'}: inc i
    result = Version s.substr(start, i-1)
    start = i
  elif start == s.len(): # we're at the end
    result = Version""
  elif s[start..^1].strip() == "": # we got whitespace at end
    result = Version""
  elif s[start..^1].strip() == "*": # we got whitespace at end
    result = Version""
  else:
    raise newException(ValueError, "Invalid or incomplete version: " & s[start..^1])

proc parseVersion*(s: string; start: int): Version =
  var i = start
  while i < s.len and s[i] in Whitespace: inc i
  if i < s.len and s[i] == 'v': inc i
  result = parseVer(s, i)

proc parseExplicitVersion*(s: string): Version =
  const start = 0
  if start < s.len and s[start] in Digits:
    var i = start
    while i < s.len and s[i] in Digits+{'.'}: inc i
    result = Version s.substr(start, i-1)
  else:
    result = Version""

proc parseSuffix(s: string; start: int; result: var VersionInterval; err: var bool) =
  # >= 1.5 & <= 1.8
  #        ^ we are here
  var i = start
  while i < s.len and s[i] in Whitespace: inc i
  # Nimble doesn't use the syntax `>= 1.5, < 1.6` but we do:
  if i < s.len and s[i] in {'&', ','}:
    inc i
    while i < s.len and s[i] in Whitespace: inc i
    if s[i] == '<':
      inc i
      var r = verLt
      if s[i] == '=':
        inc i
        r = verLe
      while i < s.len and s[i] in Whitespace: inc i
      result.b = VersionReq(r: r, v: parseVer(s, i))
      result.isInterval = true
      while i < s.len and s[i] in Whitespace: inc i
      # we must have parsed everything:
      if i < s.len:
        err = true

proc parseVersionInterval*(s: string; start: int; err: var bool): VersionInterval =
  var i = start
  # Skip whitespace before the version spec
  while i < s.len and s[i] in Whitespace: inc i

  # let invalidChars = PunctuationChars - {'*', '#', ',', '.', '&', '=', '<', '>'} - IdentChars

  result = VersionInterval(a: VersionReq(r: verAny, v: Version""))
  if i < s.len:
    case s[i]
    of '*': result = VersionInterval(a: VersionReq(r: verAny, v: Version""))
    of '#', '0'..'9':
      result = VersionInterval(a: VersionReq(r: verEq, v: parseVer(s, i)))
      # if result.a.v.isHead: result.a.r = verAny
      err = i < s.len
    of '=':
      inc i
      if i < s.len and s[i] == '=': inc i
      while i < s.len and s[i] in Whitespace: inc i
      result = VersionInterval(a: VersionReq(r: verEq, v: parseVer(s, i)))
      err = i < s.len
    of '<':
      inc i
      var r = verLt
      if i < s.len and s[i] == '=':
        r = verLe
        inc i
      while i < s.len and s[i] in Whitespace: inc i
      result = VersionInterval(a: VersionReq(r: r, v: parseVer(s, i)))
      parseSuffix(s, i, result, err)
    of '>':
      inc i
      var r = verGt
      if i < s.len and s[i] == '=':
        r = verGe
        inc i
      while i < s.len and s[i] in Whitespace: inc i
      result = VersionInterval(a: VersionReq(r: r, v: parseVer(s, i)))
      parseSuffix(s, i, result, err)
    else:
      err = true
  else:
    result = VersionInterval(a: VersionReq(r: verAny, v: Version""))

proc parseTaggedVersions*(outp: string, requireVersions = true): seq[VersionTag] =
  result = @[]
  var tagsByRef: OrderedTable[string, VersionTag]
  var peeledRefs: HashSet[string]

  for line in splitLines(outp):
    var i = 0
    while i < line.len and line[i] notin Whitespace: inc i
    let commitEnd = i
    while i < line.len and line[i] in Whitespace: inc i
    let refStart = i

    # fast path for `git log --format=%H` / `rev-parse` style output:
    if refStart >= line.len:
      var j = refStart
      while j < line.len and line[j] notin Digits: inc j
      let v = parseVersion(line, j)
      let c = initCommitHash(line.substr(0, commitEnd-1), FromGitTag)
      if not c.isEmpty() and (v != Version("") or not requireVersions):
        result.add VersionTag(c: c, v: v)
      continue

    var refName = line.substr(refStart).strip()
    var peeled = false
    if refName.endsWith("^{}"):
      peeled = true
      refName = refName[0..^4]

    var j = 0
    while j < refName.len and refName[j] notin Digits: inc j
    let v = parseVersion(refName, j)
    let c = initCommitHash(line.substr(0, commitEnd-1), FromGitTag)
    if c.isEmpty() or (v == Version("") and requireVersions):
      continue

    if peeled:
      peeledRefs.incl(refName)
      tagsByRef[refName] = VersionTag(c: c, v: v)
    elif refName notin peeledRefs and refName notin tagsByRef:
      tagsByRef[refName] = VersionTag(c: c, v: v)

  for t in tagsByRef.values:
    result.add t

  result.sort proc (a, b: VersionTag): int =
    (if a.v < b.v: 1
    elif a.v == b.v: 0
    else: -1)

proc matches(pattern: VersionReq; v: Version): bool =
  case pattern.r
  of verGe:
    result = pattern.v < v or pattern.v == v
  of verGt:
    result = pattern.v < v
  of verLe:
    result = v < pattern.v or pattern.v == v
  of verLt:
    result = v < pattern.v
  of verEq, verSpecial:
    if pattern.v.string.startsWith('#'):
      if v.string.startsWith('#'):
        result = pattern.v == v
      else:
        result = pattern.v.string.substr(1) == v.string
    elif v.string.startsWith('#'):
      result = pattern.v.string == v.string.substr(1)
    else:
      result = pattern.v == v
  of verAny:
    result = true

proc matches*(pattern: VersionInterval; v: Version): bool =
  if pattern.isInterval:
    result = matches(pattern.a, v) and matches(pattern.b, v)
  else:
    result = matches(pattern.a, v)

proc extractRequirementName*(req: string): (string, seq[string], int) =
  const verChars = {'#', '<', '=', '>', '['}
  var i = 0
  while i < req.len and req[i] notin verChars + Whitespace:
    inc i
  let name = req.substr(0, i-1)

  let url = parseUri(name)
  if not validIdentifier(name) and
      (url.scheme == "" or url.path.endsWith('@')):
    # note: somtimes this gets added: `requires "xyx@#branch"`
    #       which is a mixup of using `nimble install xyx@#branch` from the CLI
    #       so it occurs rarely but breaks things for atlas
    raise newException(ValueError, "Invalid requirements name: " & req)

  if i < req.len and req[i] == '[':
    inc i
    var features: seq[string]
    while i < req.len and req[i] notin verChars + {']'}:
      while i < req.len and req[i] in verChars + {','} + Whitespace:
        inc i
      let start = i
      while i < req.len and req[i] notin verChars + {',', ']'} + Whitespace:
        inc i
      features.add req.substr(start, i-1)
    result = (name, features, i+1)
  else:
    result = (name, @[], i)

const
  MinCommitLen = len("#baca3")

proc extractSpecificCommit*(pattern: VersionInterval): CommitHash =
  if not pattern.isInterval and pattern.a.r == verEq and pattern.a.v.isSpecial: # and pattern.a.v.string.len >= MinCommitLen:
    result = initCommitHash(pattern.a.v.string.substr(1), FromNimbleFile)
  else:
    result = initCommitHash("", FromNimbleFile)

proc matches*(pattern: VersionInterval; x: VersionTag): bool =
  if pattern.isInterval:
    return matches(pattern.a, x.v) and matches(pattern.b, x.v)

  # Special-case: query "#head" should match the repository tip.
  if pattern.a.r == verEq and pattern.a.v.isHead:
    return x.isTip

  if not result and pattern.a.r == verEq and pattern.a.v.isSpecial and pattern.a.v.string.len >= MinCommitLen:
    result = x.c.h.startsWith(pattern.a.v.string.substr(1))
  
  if not result:
    result = matches(pattern.a, x.v)

proc selectBestCommitMinVer*(data: openArray[VersionTag]; elem: VersionInterval): CommitHash =
  for i in countdown(data.len-1, 0):
    if elem.matches(data[i]):
      return data[i].c
  return CommitHash(h: "")

proc selectBestCommitMaxVer*(data: openArray[VersionTag]; elem: VersionInterval): CommitHash =
  for i in countup(0, data.len-1):
    if elem.matches(data[i]): return data[i].c
  return CommitHash(h: "")

proc toSemVer*(i: VersionInterval): VersionInterval =
  result = i
  if not result.isInterval and result.a.r in {verGe, verGt}:
    var major = 0
    let l1 = parseSaturatedNatural(result.a.v.string, major, 0)
    if l1 > 0:
      result.isInterval = true
      result.b = VersionReq(r: verLt, v: Version($(major+1)))

proc selectBestCommitSemVer*(data: openArray[VersionTag]; elem: VersionInterval): CommitHash =
  result = selectBestCommitMaxVer(data, elem.toSemVer)

proc `$`*(i: VersionInterval): string =
  ## Returns a string representation of a version interval
  ## that matches the parser's format.
  if i.isInterval:
    # Handle interval case like ">= 1.2 & < 1.4"
    result = case i.a.r
      of verGe: ">="
      of verGt: ">"
      of verLe: "<="
      of verLt: "<"
      of verEq: "=="
      of verAny: "*"
      of verSpecial: "#"
    result &= " " & $i.a.v
    result &= " & "
    case i.b.r
    of verGe: result &= ">="
    of verGt: result &= ">"
    of verLe: result &= "<="
    of verLt: result &= "<"
    of verEq: result &= "=="
    of verAny: result &= "*"
    of verSpecial: result &= "#"
    result &= " " & $i.b.v
  else:
    # Handle single version requirement
    case i.a.r
    of verAny:
      if i.a.v.string == "#head":
        result = "#head"
      else:
        result = "*"
    of verEq:
      if i.a.v.isSpecial:
        result = $i.a.v
      else:
        result = $i.a.v
    of verGe:
      result = ">= " & $i.a.v
    of verGt:
      result = "> " & $i.a.v
    of verLe:
      result = "<= " & $i.a.v
    of verLt:
      result = "< " & $i.a.v
    of verSpecial:
      result = $i.a.v

proc toVersion*(str: string): Version =
  if str == "~": result = Version("")
  else: result = parseVersion(str, 0)


proc toCommitHash*(str: string, origin = FromNone): CommitHash =
  if str == "-": result = initCommitHash("", origin)
  else: result = initCommitHash(str, origin)

proc toVersionTag*(str: string, origin = FromNone): VersionTag =
  let res = str.split("@")
  doAssert res.len() == 2, "version tag string format is `version@commit` but got: " & $str

  result.v = toVersion(res[0])
  result.c = toCommitHash(res[1], origin)

proc `==`*(a, b: CommitHash): bool =
  result = a.h == b.h

proc hash*(c: CommitHash): Hash =
  result = c.h.hash()

proc hash*(v: VersionTag): Hash =
  var h: Hash = 0
  h = h !& hash(v.v)
  h = h !& hash(v.c)
  result = !$h

proc `==`*(a, b: VersionTag): bool =
  result = a.v == b.v and a.c == b.c
