# Assets

## Licensing

Use the assets accordingly with [École polytechnique corporate identity](https://www.polytechnique.edu/en/press-room).

## Generation

```bash
sed -i 's/ce0037/a58b4d/' filet-long.svg
sed -i 's/ccd8df/ece8dc/' armes.svg
sed -i 's/01426a/ffffff/' logo-x-ip-paris.svg
```

Note : macOS users need to add an empty string `''` after `-i` flag : `sed -i '' 's/.../.../' file.svg'` or install `gnu-sed` and use it instead of macOS provided `sed`.
