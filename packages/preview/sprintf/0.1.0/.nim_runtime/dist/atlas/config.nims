import std/[os, strformat, strutils]

when defined(nimPreviewSlimSystem):
  import std/syncio

when defined(nimAtlasBootstrap):
  --path:"../dist/sat/src"
elif dirExists("../sat/src"):
  --path:"../sat/src"
else:
  --path:"deps/sat"

--path:"$nim"
--nimcache:".nimcache"
--d:ssl

task installSat, "install sat if needed":
  if not dirExists("../sat/src") and not defined(nimAtlasBootstrap):
    exec "git clone https://github.com/nim-lang/sat deps/sat"

task build, "Build local atlas":
  installSatTask()
  exec "nim c -d:debug -o:bin/atlas src/atlas.nim"

task unitTests, "Runs unit tests":
  installSatTask()
  for kind, path in walkDir("tests/"):
    if kind == pcFile and path.endsWith(".nim"):
      let name = splitFile(path).name
      if not name.startsWith("t"): continue # run only t*.nim files
      echo fmt"[sigils] Running {path}"
      exec fmt"nim c -r {path}"

task tester, "Runs integration tests":
  installSatTask()
  exec "nim c -d:debug -r tests/run_tester.nim"

task buildRelease, "Build release":
  installSatTask()
  when defined(macosx):
    let x86Args = "\"-target x86_64-apple-macos11 -arch x86_64 -DARCH=x86_64\""
    exec "nim c -d:release --passC:" & x86args & " --passL:" & x86args & " -o:./atlas_x86_64 src/atlas.nim"
    let armArgs = "\"-target arm64-apple-macos11 -arch arm64 -DARCH=arm64\""
    exec "nim c -d:release --passC:" & armArgs & " --passL:" & armArgs & " -o:./atlas_arm64 src/atlas.nim"
    exec "lipo -create -output atlas atlas_x86_64 atlas_arm64"
    rmFile("atlas_x86_64")
    rmFile("atlas_arm64")
  else:
    let os = getEnv("OS")
    let arch = getEnv("ARCH")
    if os != "" and arch != "":
      if os == "windows":
        exec "nim c -d:release -d:mingw -o:./atlas src/atlas.nim"
      else:
        exec "nim c -d:release --cpu:" & arch & " --os:" & os & " -o:./atlas src/atlas.nim"
    else:
      exec "nim c -d:release -o:./atlas src/atlas.nim"

task cleanTests, "Clean tests":
  echo "Stashing any changes to tests"
  exec "git stash -- tests"
  echo "Removing tests"
  rmDir("tests")
  echo "Checking out tests for a clean slate"
  exec "git checkout -- tests"

task testReposSetup, "Setup atlas-tests from a cached zip":
  let version = "0.1.5"
  let repo = "https://github.com/nim-lang/atlas-tests/"
  let file = "atlas-tests.zip"
  let url = fmt"{repo}/releases/download/v{version}/{file}"
  if not dirExists("atlas-tests"):
    cleanTestsTask()
    echo "Downloading Test Repos zip"
    exec(fmt"curl -L -o {file} {url}")
    echo "Unzipping Test Repos"
    exec(fmt"unzip -o {file}")
  else:
    let actualver =
      if fileExists("atlas-tests/atlas_tests.nimble"):
        readFile("atlas-tests/atlas_tests.nimble").split("=")[^1].replace("\"","").strip()
      else:
        "0.0.0"
    echo "Atlas Tests: got version: ", actualver , " expected: ", version
    if version notin actualver:
      echo fmt"Atlas Tests Outdated; Updating..."
      echo "Downloading Test Repos zip"
      exec(fmt"curl -L -o {file} {url}")
      echo "Deleting Atlas Test Repos"
      exec(fmt"mv atlas-tests atlas-tests-old-{actualver}")
      echo "Unzipping Test Repos"
      exec(fmt"unzip -o {file}")

task runGitHttpServer, "Run test http server":
  testReposSetupTask()
  exec "nim c -r tests/githttpserver.nim atlas-tests/ws_integration atlas-tests/ws_generated"

task test, "Runs all tests":
  testReposSetupTask() # download atlas-tests
  unitTestsTask() # tester runs both
  testerTask()

task docs, "build Atlas's docs":
  exec "nim rst2html --putenv:atlasversion=$1 --d:nimPreviewSlimSystem doc/atlas.md" % version

