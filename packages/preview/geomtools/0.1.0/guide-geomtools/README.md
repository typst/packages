# geomtools — user guide / دليل المستعمل

The four centres of a triangle, drawn with the `geomtools` instruments
(compass, ruler, set square) and their geometric markings.

## Compile

```bash
typst compile --root /home/user guide-geomtools/guide.typ    guide-geomtools/guide.pdf     # Français
typst compile --root /home/user guide-geomtools/guide-en.typ guide-geomtools/guide-en.pdf  # English
typst compile --root /home/user guide-geomtools/guide-ar.typ guide-geomtools/guide-ar.pdf  # العربية
```

The package is imported from `../goemtools-src/package/lib.typ`.
`--root /home/user` is required so Typst accepts that path.

## Files

- `guide.pdf` — French
- `guide-en.pdf` — English
- `guide-ar.pdf` — Arabic (RTL)
- `guide.typ` / `guide-en.typ` / `guide-ar.typ` — sources
- `helpers.typ` — midpoints, intersections, centres, ticks, set-square placement
