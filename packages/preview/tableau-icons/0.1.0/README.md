
<img src="docs/banner.png">

### The package documentation can be found at [/docs/tableau-icons-doc.pdf](./docs/tableau-icons-doc.pdf)

> [!warning]
> This package contains the symbols from Tabler Icons v3.29.0, but has no association with the Tabler.io team themselves.

Despite the bad naming (the name is translated Table icons, which is only one character away from Tabler icons), this package implements a couple of functions to allow the use of Tabler.io Icons (https://tabler.io/icons) in your documents.

## Usage

For the use, I highly recommend to not wildcard include the package (`...0.1.0": *`), but to give it a name, such as tbl or similar. This way, the function writing is a bit more readable.

```typst
#import "@preview/tableau-icons:0.1.0" as tbl

#tbl.draw-icon("hammer", fill: blue) //..args is for #box 
```

## Changelog
- **v0.1.0**
  - initial version
  - added Tabler Icons version v3.29.0
  - added `#draw-icon()`
