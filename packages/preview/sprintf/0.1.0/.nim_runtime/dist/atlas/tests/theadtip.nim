import std/unittest
import basic/versions

template v(x): untyped = Version(x)

proc p(s: string): VersionInterval =
  var err = false
  result = parseVersionInterval(s, 0, err)

suite "#head matching against tip":
  test "#head matches VersionTag at tip":
    let interval = p"#head"
    let commit = initCommitHash("88f634b9", FromGitTag)
    var tag = VersionTag(c: commit, v: v"0.26.3")
    tag.isTip = true
    check interval.matches(tag) == true

  test "#head does not match non-tip":
    let interval = p"#head"
    let commit = initCommitHash("88f634b9", FromGitTag)
    let tag = VersionTag(c: commit, v: v"0.26.3")
    check interval.matches(tag) == false

