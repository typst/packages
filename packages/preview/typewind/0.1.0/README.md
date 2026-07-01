# The `typewind` Package

<div align="center">Version 0.1.0</div>

All tailwind colors in typst, easily accessible via their default tailwind names.

## Usage

```typ
#import "@preview/typewind:0.1.0": *

#box(height: 18pt, width: 18pt, fill: emerald-700, radius: 1mm)
#text(fill: neutral-600)[_emerald-700_]
#box(height: 18pt, width: 18pt, fill: rose-300, radius: 1mm)
#text(fill: neutral-600)[_rose-300_]
```

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="./thumbnail-dark.svg">
  <img src="./thumbnail-light.svg">
</picture>

You can also access the colors via a prefix, if you don't want to pollute your namespace with all the colors:

```typ
#import "@preview/typewind:0.1.0" as tw

#box(height: 18pt, width: 18pt, fill: tw.emerald-700, radius: 1mm)
#text(fill: tw.neutral-600)[_emerald-700_]
#box(height: 18pt, width: 18pt, fill: tw.rose-300, radius: 1mm)
#text(fill: tw.neutral-600)[_rose-300_]
```

See [tailwindcss.com/docs/colors](https://tailwindcss.com/docs/colors) for a complete list of colors.
