# Assets

## Licensing

Use the assets accordingly with [École polytechnique corporate identity](https://www.polytechnique.edu/en/press-room).

## Generation

Typst currently only supports `svg` integration. I generated `svg` assets using inkscape to convert `eps` files to `svg`, and remplaced colors to use colors from École polytechnique corporate identity.

```bash
for f in *.eps; do inkscape --export-type=svg $f; done
sed -i 's/2e6886/00677f/' filet-court.svg
sed -i 's/a62125/ce0037/' filet-long.svg
sed -i 's/dae0e5/ccd8df/' armes.svg
sed -i 's/0d355c/01426a/' logo-x.svg
sed -i 's/1e3f6a/01426a/' logo-x-ip-paris.svg
```

Note : macOS users need to add an empty string `''` after `-i` flag : `sed -i '' 's/.../.../' file.svg'` or install `gnu-sed` and use it instead of macOS provided `sed`.
