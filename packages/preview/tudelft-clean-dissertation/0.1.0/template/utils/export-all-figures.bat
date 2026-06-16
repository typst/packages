::recurse down from the parent directory (the repo root) and find and dir with "figure-source.svg" and then export to a plain svg with name "fig.svg"
powershell.exe -Command "Get-ChildItem -Path .. -Recurse -Filter "figure-source.svg" | ForEach-Object {Push-Location -Path $_.DirectoryName;inkscape figure-source.svg --actions='export-filename:fig.pdf;export-do;file-close';Pop-location }"
pause
