# Assets

## Licensing

TODO

## Generation

Typst currently only supports `svg` integration. I generated `svg` assets using inkscape to convert `eps` files to `svg` :

```bash
for f in *.eps; do inkscape --export-type=svg $f; done
```
