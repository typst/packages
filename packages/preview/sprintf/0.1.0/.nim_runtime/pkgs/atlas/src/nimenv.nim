#
#           Atlas Package Cloner
#        (c) Copyright 2023 Andreas Rumpf
#
#    See the file "copying.txt", included in this
#    distribution, for details about the copyright.
#

## Implementation of the "Nim virtual environment" (`atlas env`) feature.
import std/[files, dirs, strscans, os, strutils, uri]
import basic/[context, osutils, versions, gitops]

when defined(windows):
  const
    BatchFile = """
@echo off
if not defined _OLD_NIM_PATH set "_OLD_NIM_PATH=%PATH%"
if not defined _OLD_NIM_PROMPT set "_OLD_NIM_PROMPT=%PROMPT%"
set "PATH=$1;%PATH%"
set "PROMPT=(nim $2) %PROMPT%"
doskey deactivate=if defined _OLD_NIM_PATH (set "PATH=%%_OLD_NIM_PATH%%" ^& set "PROMPT=%%_OLD_NIM_PROMPT%%" ^& set "_OLD_NIM_PATH=" ^& set "_OLD_NIM_PROMPT=") else (echo Not in an activated Nim environment)
"""
    PowerShellFile = """
# Save original PATH and prompt if not already in a nim env
if (-not $$env:_OLD_NIM_PATH) {
    $$env:_OLD_NIM_PATH = $$env:PATH
    $$global:_OLD_NIM_PROMPT = (Get-Item Function:\prompt).ScriptBlock
}

$$env:PATH = "$1;$$env:PATH"

function global:prompt {
    "(nim $2) " + (& $$global:_OLD_NIM_PROMPT)
}

function global:deactivate {
    if ($$env:_OLD_NIM_PATH) {
        $$env:PATH = $$env:_OLD_NIM_PATH
        Remove-Item Env:\_OLD_NIM_PATH
        Set-Item Function:\prompt $$global:_OLD_NIM_PROMPT
        Remove-Variable -Name _OLD_NIM_PROMPT -Scope Global
        Remove-Item Function:\deactivate
    } else {
        Write-Host "Not in an activated Nim environment"
    }
}
"""
else:
  const
    ShellFile* = """
# Save original PATH and PS1 if not already in a nim env
if [ -z "$${_OLD_NIM_PATH+x}" ]; then
    export _OLD_NIM_PATH="$$PATH"
    export _OLD_NIM_PS1="$${PS1:-}"
fi

export PATH=$1:$$PATH
export PS1="(nim $2) $${PS1:-}"

deactivate() {
    if [ -n "$${_OLD_NIM_PATH+x}" ]; then
        export PATH="$$_OLD_NIM_PATH"
        export PS1="$$_OLD_NIM_PS1"
        unset _OLD_NIM_PATH
        unset _OLD_NIM_PS1
        unset -f deactivate
    else
        echo "Not in an activated Nim environment"
    fi
}
"""

const
  ActivationFile* = when defined(windows): Path "activate.bat" else: Path "activate.sh"

template withDir*(dir: string; body: untyped) =
  let old = paths.getCurrentDir()
  try:
    setCurrentDir(dir)
    # echo "WITHDIR: ", dir, " at: ", getCurrentDir()
    body
  finally:
    setCurrentDir(old)

proc infoAboutActivation(nimDest: Path, nimVersion: string) =
  when defined(windows):
    info nimDest, "RUN (cmd)\nnim-" & nimVersion & "\\activate.bat\nRUN (PowerShell)\n. nim-" & nimVersion & "\\activate.ps1"
  else:
    info nimDest, "RUN\nsource nim-" & nimVersion & "/activate.sh"

proc setupNimEnv*(nimVersion: string; keepCsources: bool) =
    template isDevel(nimVersion: string): bool = nimVersion == "devel"

    template exec(command: string) =
      let cmd = command # eval once
      if os.execShellCmd(cmd) != 0:
        error ("nim-" & nimVersion), "failed: " & cmd
        return

    let nimDest = Path("nim-" & nimVersion)
    if dirExists(depsDir() / nimDest):
      if not fileExists(depsDir() / nimDest / ActivationFile):
        info nimDest, "already exists; remove or rename and try again"
      else:
        infoAboutActivation nimDest, nimVersion
      return

    var major, minor, patch: int
    if nimVersion != "devel":
      if not scanf(nimVersion, "$i.$i.$i", major, minor, patch):
        error "nim", "cannot parse version requirement"
        return
    let csourcesVersion =
      if nimVersion.isDevel or (major == 1 and minor >= 9) or major >= 2:
        # already uses csources_v2
        "csources_v2"
      elif major == 0:
        "csources" # has some chance of working
      else:
        "csources_v1"

    proc cloneOrReturn(url: string; dest: Path; fetchTags = false): bool =
      let (status, msg) = gitops.clone(url.parseUri(), dest)
      if status != Ok:
        error dest, "failed to clone: " & url & " (" & $status & "): " & msg
        return false
      if fetchTags:
        discard gitops.fetchRemoteTags(dest)
      true

    withDir $depsDir():
      if not dirExists(csourcesVersion):
        if not cloneOrReturn("https://github.com/nim-lang/" & csourcesVersion, Path(csourcesVersion)):
          return
      if not cloneOrReturn("https://github.com/nim-lang/nim", nimDest, fetchTags = true):
        return
    withDir $depsDir() / csourcesVersion:
      when defined(windows):
        exec "build.bat"
      else:
        let makeExe = findExe("make")
        if makeExe.len == 0:
          exec "sh build.sh"
        else:
          exec "make"
    let nimExe0 = ".." / csourcesVersion / "bin" / "nim".addFileExt(ExeExt)
    let dir = depsDir() / nimDest
    withDir $(depsDir() / nimDest):
      let nimExe = "bin" / "nim".addFileExt(ExeExt)
      copyFileWithPermissions nimExe0, nimExe
      let query = createQueryEq(if nimVersion.isDevel: Version"#head" else: Version(nimVersion))
      if not nimVersion.isDevel:
        let commit = versionToCommit(dir, algo = SemVer, query = query)
        if commit.isEmpty():
          error nimDest, "cannot resolve version to a commit"
          return
        discard checkoutGitCommit(dir, commit)
      exec nimExe & " c --noNimblePath --skipUserCfg --skipParentCfg --hints:off koch"
      let kochExe = when defined(windows): "koch.exe" else: "./koch"
      exec kochExe & " boot -d:release --skipUserCfg --skipParentCfg --hints:off"
      exec kochExe & " tools --skipUserCfg --skipParentCfg --hints:off"
      # remove any old atlas binary that we now would end up using:
      if cmpPaths(getAppDir(), $(depsDir() / nimDest / "bin".Path)) != 0:
        removeFile "bin" / "atlas".addFileExt(ExeExt)
      # unless --keep is used delete the csources because it takes up about 2GB and
      # is not necessary afterwards:
      if not keepCsources:
        removeDir $depsDir() / csourcesVersion / "c_code"
      let pathEntry = depsDir() / nimDest / "bin".Path
      when defined(windows):
        let winPath = replace($pathEntry, '/', '\\')
        writeFile "activate.bat", BatchFile % [winPath, nimVersion]
        writeFile "activate.ps1", PowerShellFile % [winPath, nimVersion]
      else:
        writeFile "activate.sh", ShellFile % [$pathEntry, nimVersion]
      infoAboutActivation nimDest, nimVersion
