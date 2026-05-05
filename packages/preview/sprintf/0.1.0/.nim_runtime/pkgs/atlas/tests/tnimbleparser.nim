import std/[unittest, os, algorithm, strutils, importutils, terminal]
import basic/[context, pkgurls, deptypes, nimblecontext, compiledpatterns, osutils, versions]
import basic/nimbleparser
import basic/parse_requires

import integration_test_utils

proc doesContain(res: NimbleFileInfo, name: string): bool =
  for req in res.requires:
    if req.contains(name):
      result = true

suite "nimbleparser":
  test "parse nimble file when not defined(windows)":
    let nimbleFile = Path("tests" / "test_data" / "jester.nimble")
    var res = extractRequiresInfo(nimbleFile)
    echo "Nimble release: ", repr res
    when defined(windows):
      check not doesContain(res, "httpbeast")
    else:
      check doesContain(res, "httpbeast")

  test "parse nimble file when defined(linux or macosx)":
    let nimbleFile = Path("tests" / "test_data" / "jester_inverted.nimble")
    var res = extractRequiresInfo(nimbleFile)
    echo "Nimble release: ", repr res
    when defined(linux) or defined(macosx):
      check doesContain(res, "httpbeast")
    else:
      check not doesContain(res, "httpbeast")

  test "parse nimble file when macos or linux":
    let nimbleFile = Path("tests" / "test_data" / "jester_combined.nimble")
    var res = extractRequiresInfo(nimbleFile)
    echo "Nimble release: ", repr res
    when defined(macosx) or defined(linux):
      check doesContain(res, "httpbeast")
    else:
      check not doesContain(res, "httpbeast")

  test "parse nimble file with features":
    setAtlasVerbosity(Trace)
    let nimbleFile = Path("tests" / "test_data" / "jester_feature.nimble")
    var res = extractRequiresInfo(nimbleFile)
    echo "Nimble release: ", $res
    check res.requires.len == 1
    check res.features.len == 3
    check res.features.hasKey("useHttpbeast")
    check res.features["useHttpbeast"].len == 1
    check res.features["useHttpbeast"][0] == "httpbeast >= 0.4.0"
    check res.features.hasKey("useAsyncTools")
    check res.features["useAsyncTools"].len == 1
    check res.features["useAsyncTools"][0] == "asynctools >= 0.1.0"
    check res.features.hasKey("useOldAsyncTools")
    check res.features["useOldAsyncTools"].len == 1
    check res.features["useOldAsyncTools"][0] == "asynctools >= 0.1.0"

  test "parse nimble file with when statements":
    let nimbleFile = Path("tests" / "test_data" / "jester_boolean.nimble")
    var res = extractRequiresInfo(nimbleFile)
    echo "Nimble release: ", $res
    
    # Check basic package info is parsed correctly
    check res.version == "0.6.0"
    
    # Should always have the base requirement
    check doesContain(res, "nim >= 1.0.0")
    
    # Count how many httpbeast requirements we expect based on platform
    var expectedHttpbeastCount = 0
    
    # when defined(linux): -> only true on Linux
    when defined(linux):
      expectedHttpbeastCount += 1
    
    # when defined(linux) or defined(macosx): -> true on Linux or macOS
    when defined(linux) or defined(macosx):
      expectedHttpbeastCount += 1
    
    # when not defined(linux) or defined(macosx): -> true when NOT Linux OR when macOS
    # This is true on macOS, Windows, and other non-Linux platforms
    when not defined(linux) or defined(macosx):
      expectedHttpbeastCount += 1
    
    # when not (defined(linux) or defined(macosx)): -> true when neither Linux nor macOS
    when not (defined(linux) or defined(macosx)):
      expectedHttpbeastCount += 1
    
    # when defined(windows) and (defined(linux) or defined(macosx)): -> impossible, always false
    when defined(windows) and (defined(linux) or defined(macosx)):
      expectedHttpbeastCount += 1
    
    # Count actual httpbeast requirements in the result
    var actualHttpbeastCount = 0
    for req in res.requires:
      if req.contains("httpbeast"):
        actualHttpbeastCount += 1
    
    echo "Expected httpbeast count: ", expectedHttpbeastCount
    echo "Actual httpbeast count: ", actualHttpbeastCount
    check actualHttpbeastCount == expectedHttpbeastCount
    
    # Verify no errors occurred during parsing
    check not res.hasErrors

  test "parse nimble file with when statements runtime defines":
    let nimbleFile = Path("tests" / "test_data" / "jester_boolean.nimble")

    setBasicDefines("linux", true)
    setBasicDefines("macosx", true)
    setBasicDefines("windows", true)
    setBasicDefines("posix", true)
    setBasicDefines("freebsd", false)
    setBasicDefines("openbsd", false)
    setBasicDefines("netbsd", false)

    var res = extractRequiresInfo(nimbleFile)
    echo "Nimble release: ", $res
    
    # Check basic package info is parsed correctly
    check res.version == "0.6.0"
    
    # Should always have the base requirement
    check doesContain(res, "nim >= 1.0.0")
    
    # Count how many httpbeast requirements we expect based on platform
    var expectedHttpbeastCount = 4
    
    var actualHttpbeastCount = 0
    for req in res.requires:
      echo "got req: ", req
      if req.contains("httpbeast"):
        actualHttpbeastCount += 1
    
    echo "Expected httpbeast count: ", expectedHttpbeastCount
    echo "Actual httpbeast count: ", actualHttpbeastCount
    check actualHttpbeastCount == expectedHttpbeastCount
