$pkg_name="class-diagram"
$version=0.1.0

$source=$PSScriptRoot
$destinations=("${env:LOCALAPPDATA}\typst\packages\preview\$pkg_name\", "${env:APPDATA}\typst\packages\local\$pkg_name\")

foreach ($destination in $destinations)
{
    if (Test-Path -Path $destination) {
        Remove-Item -Path $destination -Recurse
    }
    New-Item -ItemType Directory -Path $destination
    New-Item -ItemType SymbolicLink -Path $source -Target "$destination\$version"
}
