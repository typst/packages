#requires -Version 5.1

[CmdletBinding()]
param(
  [Parameter(Position = 0)]
  [string]$Target,

  [Parameter(Position = 1)]
  [string]$BlindLevel,

  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$Rest
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $ProjectRoot

if ($null -eq $Rest) {
  $Rest = @()
}

function Show-Usage {
  [Console]::Error.WriteLine(@'
Usage:
  scripts\build.ps1 final
  scripts\build.ps1 blind <single|double>
  scripts\build.ps1 for-check
  scripts\build.ps1 for-print
  scripts\build.ps1 all
  scripts\build.ps1 clean
'@)
}

function Invoke-TypstCompile {
  param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Arguments
  )

  New-Item -ItemType Directory -Force -Path out | Out-Null
  & typst compile --root . @Arguments
  if ($LASTEXITCODE -ne 0) {
    throw "typst compile failed with exit code $LASTEXITCODE"
  }
}

function Get-LabelPage {
  param([string]$Label)

  $Result = & typst eval --root . --in template/thesis.typ "query(<$Label>).first().location().page()"
  if ($LASTEXITCODE -ne 0) {
    throw "typst eval failed with exit code $LASTEXITCODE"
  }

  return [int]($Result | Select-Object -First 1)
}

function Build-Final {
  Invoke-TypstCompile -Arguments @("template/thesis.typ", "out/thesis.pdf")
}

function Build-Blind {
  param([string]$Level)

  if ($Level -ne "single" -and $Level -ne "double") {
    Show-Usage
    exit 2
  }

  Invoke-TypstCompile -Arguments @(
    "--input", "profile=blind",
    "--input", "blind=$Level",
    "template/thesis.typ", "out/thesis-blind-$Level.pdf"
  )
}

function Build-ForCheck {
  $Start = Get-LabelPage "mainmatter-start"
  $End = (Get-LabelPage "backmatter-start") - 1

  Invoke-TypstCompile -Arguments @(
    "--no-pdf-tags",
    "--pages", "$Start-$End",
    "template/thesis.typ", "out/thesis-for-check.pdf"
  )
}

function Build-ForPrint {
  Invoke-TypstCompile -Arguments @(
    "--input", "profile=for-print",
    "template/thesis.typ", "out/thesis-for-print.pdf"
  )
}

if ($Rest.Count -ne 0) {
  Show-Usage
  exit 2
}

switch ($Target) {
  "final" {
    Build-Final
  }
  "blind" {
    Build-Blind $BlindLevel
  }
  "for-check" {
    Build-ForCheck
  }
  "for-print" {
    Build-ForPrint
  }
  "all" {
    Build-Final
    Build-Blind "single"
    Build-Blind "double"
    Build-ForCheck
    Build-ForPrint
  }
  "clean" {
    Remove-Item -Path "out/thesis*.pdf" -Force -ErrorAction SilentlyContinue
  }
  default {
    Show-Usage
    exit 2
  }
}
