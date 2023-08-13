# Showybox (v0.2.0)

**Showybox** is a Typst package for creating colorful and customizable boxes.

## Usage

To use this library through the Typst package manager (for Typst 0.6.0 or greater), write `#import "@preview/showybox:0.2.0": showybox` at the beginning of your Typst file.

Once imported, you can create an empty showybox by using the function `showybox()` and giving a default body content inside the parenthesis or outside them using squared brackets `[]`.

By default, a box with no title, black borders, white background, and `5pt` border radius will be created.

```java
#import "@preview/showybox:0.2.0": showybox

#showybox(
  [Hello world!]
)
```
<h3 align="center">
  <img alt="Hello world! example" src="https://i.ibb.co/5FZ5Q32/Captura-de-pantalla-2023-07-01-152146.png" style="max-width: 100%; padding: 10px 10px; box-shadow: 1pt 1pt 10pt 0pt #AAAAAA; border-radius: 4pt">
</h3>

Looks quite simple, but the "magic" starts when adding a title and color. The following code creates two "unique" boxes with defined colors and custom borders:
```java
// First showybox
#showybox(
  frame: (
    upper-color: red.darken(40%),
    lower-color: red.lighten(90%),
    border-color: black,
    width: 2pt
  ),
  title: "Hello world! - An example",
  [
    Hello world!
  ]
)

// Second showybox
#showybox(
  frame: (
    dash: "dotted",
    border-color: red.darken(40%)
  ),
  body-style: (
    align: center
  ),
  sep: (
    dash: "dashed"
  ),
  [This is an important message!],
  [Be careful outside. There are dangerous bananas!]
)
```
<h3 align="center">
  <img alt="Further examples" src="https://i.ibb.co/n1z856C/Captura-de-pantalla-2023-07-09-003648.png" style="max-width: 100%; padding: 10px 10px; box-shadow: 1pt 1pt 10pt 0pt #AAAAAA; border-radius: 4pt">
</h3>

## Reference

The `showybox()` function can receive the following parameters:
- `frame`: A dictionary containing the frame's properties
- `title-style`: A dictionary containing the title's styles
- `body-styles`: A dictionary containing the body's styles
- `title`: A string used as the title of the showybox
- `body`: The content of the showybox
- `sep`: A dictionary containing the separator's properties
- `breakable`: A boolean indicating whether a no-title showybox can break

### Frame properties
- `upper-color`: Color used as background color where the title goes (default is `black`)
- `lower-color`: Color used as background color where the body goes (default is `white`)
- `border-color`: Color used for the showybox's border (default is `black`)
- `radius`: Showybox's radius (default is `5pt`)
- `width`: Border width of the showybox (default is `2pt`)
- `dash`: Showybox's border style (default is `solid`)

### Title styles
- `color`: Text color (default is `white`)
- `weight`: Text weight (default is `bold`)
- `align`: Text align (default is `left`)

### Body styles
- `color`: Text color (default is `black`)
- `align`: Text align (default is `left`)

### Separator properties
- `width`: Separator's width
- `dash`: Separator's style (as a `line` dash style)

## Known issues
- A `break` property for showyboxes with a title would be great
- There's a slightly thin line in showyboxes that have no borders or dashed borders, instead of white spaces or nothing.

## Gallery

### Encapsulation

May have some bugs
<h3 align="center">
  <img alt="Encapsulation" src="https://i.ibb.co/rmFYWhq/Captura-de-pantalla-2023-07-01-152511.png" style="max-width: 100%; padding: 10px 10px; box-shadow: 1pt 1pt 10pt 0pt #AAAAAA; border-radius: 4pt">
</h3>

### Enabling breaking
<h3 align="center">
  <img alt="Enabling breakable" src="https://i.ibb.co/2kNqZ2G/Captura-de-pantalla-2023-07-09-010052.png" style="max-width: 100%; padding: 10px 10px; background-color: #E4E5EA; box-shadow: 1pt 1pt 10pt 0pt #AAAAAA; border-radius: 4pt">
</h3>

### Custom radius
<h3 align="center">
  <img alt="Custom radius" src="https://i.ibb.co/23xvrHt/Captura-de-pantalla-2023-07-01-152528.png" style="max-width: 100%; padding: 10px 10px; box-shadow: 1pt 1pt 10pt 0pt #AAAAAA; border-radius: 4pt">
</h3>

## Changelog

### Version 0.1.0
- Initial release

### Version 0.1.1
- Changed package name from colorbox to showybox
- Fixed a spacing bug in encapsulated showyboxes
  - **Details:** When a showybox was encapsulated inside another, the spacing after that showybox was `0pt`, probably due to some "fixes" improved to manage default spacing between `rect` elements. The issue was solved by avoiding `#set` statements and adding a `#v(-1.1em)` to correct extra spacing between the title `rect` and the body `rect`.

### Version 0.2.0
- Improved code documentation
- Enabled an auto-break functionality for non-titled showyboxes
- Created a separator functionality to separate content inside a showybox with a horizontal line