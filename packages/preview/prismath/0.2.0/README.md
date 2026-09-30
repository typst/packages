# prismath

A mathematical brackets colorizer for Typst.

## Usage

```typst
#import "@preview/prismath:0.2.0": *

#colorize-equation($ A + (B + (C + (D + E))) + F $)

#colorize-equation(
  $ A + (B + (C + (D + E))) + F $,
  bracket-colors: (rgb("#ffd700"), rgb("#da70d6"), rgb("#179fff")),
)
```

<div align="center">
  <img src="https://raw.githubusercontent.com/3w36zj6/typst-prismath/refs/tags/v0.2.0/examples/color-palettes.svg" width="540" height="150" alt="Nested parentheses colored by depth using the default and custom palettes"/>
</div>
