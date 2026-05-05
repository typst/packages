import std / [os, strutils, sequtils]
from std/private/gitutils import diffFiles
import basic/versions
export diffFiles
import githttpserver

let atlasExe* = absolutePath("bin" / "atlas".addFileExt(ExeExt))

proc exec*(cmd: string) =
  if execShellCmd(cmd) != 0:
    quit "FAILURE RUNNING: " & cmd

template withDir*(dir: string; body: untyped) =
  let old = getCurrentDir()
  try:
    setCurrentDir(dir)
    # echo "WITHDIR: ", dir, " at: ", getCurrentDir()
    body
  finally:
    setCurrentDir(old)

template sameDirContents*(expected, given: string) =
  # result = true
  for _, e in walkDir(expected):
    let g = given / splitPath(e).tail
    if fileExists(g):
      let edata  = readFile(e)
      let gdata = readFile(g)
      check gdata == edata
      if gdata != edata:
        echo "FAILURE: files differ: ", e.absolutePath, " to: ", g.absolutePath
        echo diffFiles(e, g).output
      else:
        echo "SUCCESS: files match: ", e.absolutePath
    else:
      echo "FAILURE: file does not exist: ", g
      check fileExists(g)
      # result = false

proc ensureGitHttpServer*() =
  try:
    if checkHttpReadme():
      return
  except CatchableError:
    echo "Starting Tester git http server"
    runGitHttpServerThread([
      "atlas-tests/ws_integration",
      "atlas-tests/ws_generated"
    ])
    for count in 1..10:
      os.sleep(1000)
      if checkHttpReadme():
        return

    quit "Error accessing git-http server.\n" &
        "Check that tests/githttpserver server is running on port 4242.\n" &
        "To start it run in another terminal:\n" &
        "  nim c -r tests/githttpserver test-repos/generated"

template expectedVersionWithGitTags*() =
    # These will change if atlas-tests is regnerated!
    # To update run and use commits not adding a proj_x.nim file
    #    curl http://localhost:4242/buildGraph/ws_generated-logs.txt

    # note: the middle commit is where nimble file comment is changed but the version is the same
    let projAnimbles {.inject.} = dedent"""
    b62ef0ae3e5d888e28f432d87645ee945ced6f19 1.1.0
    7f5302d5ea45c5c040d2939ef59449e801d59054
    58ea44fb5cf98b7d333fd482dbccea9dd82050ff 1.0.0
    """.parseTaggedVersions(false)
    let projAtags {.inject.} = projAnimbles.filterIt(it.v.string != "")

    # note: the middle commit is where nimble file comment is changed but the version is the same
    let projBnimbles {.inject.} = dedent"""
    423774bee431e28321989eb50a9ca70650986088 1.1.0
    fa97674802701849b4ec488aeb20019b5e843510
    1f2221a7186c65d588e4cdf46dba7bb46a1c90a5 1.0.0
    """.parseTaggedVersions(false)
    let projBtags {.inject.} = projBnimbles.filterIt(it.v.string != "")

    let projCnimbles {.inject.} = dedent"""
    7538587e7e6d7c50f6533d0d226d5ae73b91d045 1.2.0
    8ba310d7c4931fc2b8ffba8d2e4c52fd0646ad73
    """.parseTaggedVersions(false)
    let projCtags {.inject.} = projCnimbles.filterIt(it.v.string != "")

    let projDnimbles {.inject.} = dedent"""
    db336b9131bde8adf4b58513b9589e89b6590893 2.0.0
    1dcdfddd2aa193804286681f6ebd09e8b8b398fc 1.0.0
    """.parseTaggedVersions(false)
    let projDtags {.inject.} = projDnimbles.filterIt(it.v.string != "")

template expectedVersionWithNoGitTags*() =
    # These will change if atlas-tests is regnerated!
    # To update run and use commits not adding a proj_x.nim file
    #    curl http://localhost:4242/buildGraphNoGitTags/ws_generated-logs.txt

    # note: the middle commit is where nimble file comment is changed but the version is the same
    let projAnimbles {.inject.} = dedent"""
    2a630f98c20f54b828f95e824e2a1b2da50fe687 1.1.0
    62fca4fd4062087d937146fd5d8f9ab7e1e5c22b
    4d2bb051f45a3a4612f9b461401982f48e6637d7 1.0.0
    """.parseTaggedVersions(false)
    let projAtags {.inject.} = projAnimbles.filterIt(it.v.string != "")

    # note: the middle commit is where nimble file comment is changed but the version is the same
    let projBnimbles {.inject.} = dedent"""
    05b2f46caf8ae7322c855a482ad297c399b5d185 1.1.0
    4cee9aed9623f4142a7b15bb96a1d582c8b87250
    60c3613e16d54f170e991eed3f5b23dbf1c03cf4 1.0.0
    """.parseTaggedVersions(false)
    let projBtags {.inject.} = projBnimbles.filterIt(it.v.string != "")

    let projCnimbles {.inject.} = dedent"""
    d2056e869dfcea4ed6a5fbf905e6e1922f0637c3 1.2.0
    07d8c752b1810542f6e72a12eb2d26b81ee09041 1.0.0
    """.parseTaggedVersions(false)
    let projCtags {.inject.} = projCnimbles.filterIt(it.v.string != "")

    let projDnimbles {.inject.} = dedent"""
    e60f0846cc949055dc5ed4b1e65ff8bd61d17fc3 2.0.0
    4ec5f558465498358096dbc6d7dd3bbedf1ef2bc 1.0.0
    """.parseTaggedVersions(false)
    let projDtags {.inject.} = projDnimbles.filterIt(it.v.string != "")

template expectedVersionWithNoGitTagsMaxVer*() =
    # These will change if atlas-tests is regnerated!
    # To update run and use commits not adding a proj_x.nim file
    #    curl http://localhost:4242/buildGraphNoGitTags/ws_generated-logs.txt

    # note: this variant uses the last commit where a given nimble version was found
    #       when the nimble file was changed, the version was the same

    let projAnimbles {.inject.} = dedent"""
    2a630f98c20f54b828f95e824e2a1b2da50fe687 1.1.0
    62fca4fd4062087d937146fd5d8f9ab7e1e5c22b 1.0.0
    """.parseTaggedVersions(false)
    let projAtags {.inject.} = projAnimbles.filterIt(it.v.string != "")

    let projBnimbles {.inject.} = dedent"""
    05b2f46caf8ae7322c855a482ad297c399b5d185 1.1.0
    4cee9aed9623f4142a7b15bb96a1d582c8b87250 1.0.0
    """.parseTaggedVersions(false)
    let projBtags {.inject.} = projBnimbles.filterIt(it.v.string != "")

    let projCnimbles {.inject.} = dedent"""
    d2056e869dfcea4ed6a5fbf905e6e1922f0637c3 1.2.0
    07d8c752b1810542f6e72a12eb2d26b81ee09041 1.0.0
    """.parseTaggedVersions(false)
    let projCtags {.inject.} = projCnimbles.filterIt(it.v.string != "")

    let projDnimbles {.inject.} = dedent"""
    e60f0846cc949055dc5ed4b1e65ff8bd61d17fc3 2.0.0
    4ec5f558465498358096dbc6d7dd3bbedf1ef2bc 1.0.0
    """.parseTaggedVersions(false)
    let projDtags {.inject.} = projDnimbles.filterIt(it.v.string != "")

template findCommit*(proj: string, version: string): VersionTag =
  block:
    var res: VersionTag
    case proj:
      of "proj_a":
        for idx, vt in projAnimbles:
          if $vt.v == version:
            res = vt
            if idx == 0: res.isTip = true 
      of "proj_b":
        for idx, vt in projBnimbles:
          if $vt.v == version:
            res = vt
            if idx == 0: res.isTip = true 
      of "proj_c":
        for idx, vt in projCnimbles:
          if $vt.v == version:
            res = vt
            if idx == 0: res.isTip = true 
      of "proj_d":
        for idx, vt in projDnimbles:
          if $vt.v == version:
            res = vt
            if idx == 0: res.isTip = true 
      else:
        discard
    res


when isMainModule:
  expectedVersionWithGitTags()
  echo findCommit("proj_a", "1.1.0")
  echo findCommit("proj_a", "1.0.0")
  assert findCommit("proj_a", "1.1.0").isTip
  assert not findCommit("proj_a", "1.0.0").isTip