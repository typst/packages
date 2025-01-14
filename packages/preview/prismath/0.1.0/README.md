# prismath

A mathematical brackets colorizer for Typst.

## Usage

```typst
#import "@preview/prismath:0.1.0": *

#colorize-equation($ A + (B + (C + (D + E))) + F $)

#colorize-equation(
  $ A + (B + (C + (D + E))) + F $,
  bracket-colors: (rgb("#ffd700"), rgb("#da70d6"), rgb("#179fff")),
)
```

<div align="center">
  <img src="https://github.com/user-attachments/assets/60af8c71-9bf1-4ad0-a201-22a0640881cb" width="540" height="150" alt="sample"/>
</div>
