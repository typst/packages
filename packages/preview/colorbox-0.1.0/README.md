# Colorbox (v0.1.0)

**Colorbox** is a package for creating colorful and customizable boxes.

## Usage

To use this library through the Typst package manager (for Typst 0.6.0 or greater), write `#import "@preview/colorbox:0.1.0": colorbox` at the beginning of your Typst file.

Once imported, you can create an empty colorbox by using the function `colorbox()` and giving a default body content inside the parenthesis or outside them using squared brackets `[]`.

By default, a box with no title, black borders, and white background will be created.

```java
#import "@preview/colorbox:0.1.0": colorbox

#colorbox()[
  Hello world!
]
```
<h3 align="center">
  <img alt="Hello world! example" src="https://i.ibb.co/C5NnfRs/Captura-de-pantalla-2023-06-30-184809.png" style="max-width: 100%; padding: 10px 10px; box-shadow: 1pt 1pt 10pt 0pt #AAAAAA; border-radius: 4pt">
</h3>

Looks quite simple, but the "magic" starts when adding a title and color. The following code creates two "unique" boxes with defined colors and custom borders:
```java
// First colorbox
#colorbox(
  frame: (
    upper-color: red.darken(40%),
    lower-color: red.lighten(90%),
    border-color: black,
    width: 2pt
  ),
  title: "Hello world! - An example"
)[
  Hello world!
]

// Second colorbox
#colorbox(
  frame: (
    dash: "dotted",
    border-color: red.darken(40%)
  ),
  body-style: (
    align: center
  )
)[
  This is an important message!

  Be careful outside. There are dangerous bananas!
]
```
<h3 align="center">
  <img alt="Further examples" src="https://i.ibb.co/dKgdQ7x/Captura-de-pantalla-2023-06-30-185210.png" style="max-width: 100%; padding: 10px 10px; box-shadow: 1pt 1pt 10pt 0pt #AAAAAA; border-radius: 4pt">
</h3>

## Reference

The `colorbox()` function can recieve the following parameters:
- `frame`: A dictionary containing the frame's properties
- `title-style`: A dictionary containing the title's styles
- `body-styles`: A dictionary containing the body's styles
- `title`: A string used as the title of the colorbox
- `body`: The content of the colorbox

### Frame properties
- `upper-color`: Color used as background color where the title goes (default is `black`)
- `lower-color`: Color used as background color where the body goes (default is `white`)
- `border-color`: Color used for the colorbox's border (default is `black`)
- `radius`: Colorbox's radius (default is `5pt`)
- `width`: Border width of the colorbox (default is `2pt`)
- `dash`: Colorbox's border style (default is `solid`)

### Title styles
- `color`: Text color (default is `white`)
- `weight`: Text weight (default is `bold`)
- `align`: Text align (default is `left`)

### Body styles
- `color`: Text color (default is `black`)
- `align`: Text align (default is `left`)

## Known issues
- A `break` property and/or `autobreak` functionality is needed to avoid colorboxes' overflow (when they occupy a full page and there's lots of text inside them).
- A `boxseparator` (a horizontal line inside the colorbox) will be needed to split a colorbox content in two sections inside the same box.
- There's a slightly thin line in colorboxes that have no borders or dashed borders, instead of white spaces or nothing.

## Gallery
<h3 align="center">
  <img alt="Gallery 1" src="https://i.ibb.co/7Yrzx4K/Captura-de-pantalla-2023-06-30-192922.png" style="max-width: 100%; padding: 10px 10px; box-shadow: 1pt 1pt 10pt 0pt #AAAAAA; border-radius: 4pt">
</h3>
<h3 align="center">
  <img alt="Gallery 2" src="https://i.ibb.co/gyY9C67/Captura-de-pantalla-2023-06-30-192910.png" style="max-width: 100%; padding: 10px 10px; box-shadow: 1pt 1pt 10pt 0pt #AAAAAA; border-radius: 4pt">
</h3>
