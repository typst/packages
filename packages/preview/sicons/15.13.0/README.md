<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://github.com/cscnk52/typst-sicons/raw/refs/heads/main/assets/img/typst-dark.png" />
  <source media="(prefers-color-scheme: light)" srcset="https://github.com/cscnk52/typst-sicons/raw/refs/heads/main/assets/img/typst-light.png" />
  <img alt="simpleicons-rs banner" src="https://github.com/cscnk52/typst-sicons/raw/refs/heads/main/assets/img/typst-light.png" />
</picture>

<div align="center">

# sicons

Access High quality [Simple Icons](https://simpleicons.org) SVGs from Typst.

</div>

## Usage

Function:

- sicon: return icon in SVG format
- stitle: return icon name
- sicon-label: return icon and name
- sicon-raw: return Icon SVG code

Parameters:

- slug: icon slug, can be found at <https://simpleicons.org>
- size: the icon size
- icon-color: icons hex color, default is "default", representation Simple Icons Color
- text-color: text color, default to `#000000`

# Example

```typst
#import "@preview/sicons:15.13.0": *

= typst sicons package Example

#sicon(slug: "typst", size: 1em, icon-color: "default")

#stitle(slug: "typst", size: 1em, text-color: "#000000")

#sicon-label(slug: "typst", size: 1em,icon-color: "default", text-color: "#000000")

#sicon-raw(slug: "typst")
```

![Example page of sicons](https://github.com/cscnk52/typst-sicons/raw/refs/heads/main/test/test.svg)

# License

This package is under MIT LICENSE

Simple Icons is under CC0-1.0 and additional [legal disclaimer](https://github.com/simple-icons/simple-icons/blob/develop/DISCLAIMER.md)
