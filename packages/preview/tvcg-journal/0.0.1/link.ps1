$version_line = Select-String -Pattern "^version\s*=" -Path "typst.toml"
$version = $version_line.Line.Split('"')[1]

$target = "$env:APPDATA\typst\packages\preview\tvcg-journal\"
New-Item -ItemType Directory -Force -Path $target | Out-Null

Remove-Item -Path "$target$version" -Force -Recurse -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path "$target" | Out-Null
cmd /c mklink /D "$target$version" (Get-Location).Path

Write-Host "Created lib.typ symlink in ""$target$version"". To unlink, delete the symlink."