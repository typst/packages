# Showybox (v1.0.0)

**Showybox** is a Typst package for creating colorful and customizable boxes.

## Usage

To use this library through the Typst package manager (for Typst 0.6.0 or greater), write `#import "@preview/showybox:1.0.0": showybox` at the beginning of your Typst file.

Once imported, you can create an empty showybox by using the function `showybox()` and giving a default body content inside the parenthesis or outside them using squared brackets `[]`.

By default a `showybox` with these properties will be created:

- No title
- No shadow
- Not breakable
- Black borders
- White background
- `5pt` of border radius
- `1pt` of border thickness

```java
#import "@preview/showybox:1.0.0": showybox

#showybox(
  [Hello world!]
)
```
<h3 align="center">
  <img alt="Hello world! example" src="assets/hello-world-example.png" style="max-width: 100%; background-color: #FFFFFF; padding: 10px 10px; box-shadow: 1pt 1pt 10pt 0pt #AAAAAA; border-radius: 4pt">
</h3>

Looks quite simple, but the "magic" starts when adding a title, color and shadows. The following code creates two "unique" boxes with defined colors and custom borders:
```java
// First showybox
#showybox(
  frame: (
    title-color: red.darken(40%),
    body-color: red.lighten(90%),
    border-color: black,
    thickness: 2pt
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
  shadow: (
	offset: 3pt
  ),
  [This is an important message!],
  [Be careful outside. There are dangerous bananas!]
)
```
<h3 align="center">
  <img alt="Further examples" src="assets/further-examples.png" style="max-width: 100%; background-color: #FFFFFF; padding: 10px 10px; box-shadow: 1pt 1pt 10pt 0pt #AAAAAA; border-radius: 4pt">
</h3>

## Reference

The `showybox()` function can receive the following parameters:
- `title`: A string used as the title of the showybox
- `footer`: A string used as the footer of the showybox
- `frame`: A dictionary containing the frame's properties
- `title-style`: A dictionary containing the title's styles
- `body-style`: A dictionary containing the body's styles
- `footer-style`: A dictionary containing the footer's styles
- `sep`: A dictionary containing the separator's properties
- `shadow`: A dictionary containing the shadow's properties
- `width`: A relative length indicating the showybox's width
- `align`: An unidimensional alignement for the showybox in the page
- `breakable`: A boolean indicating whether a showybox can break if it reached an end of page
- `spacing`: Space above and below the showybox
- `above`: Space above the showybox
- `below`: Space below the showybox
- `body`: The content of the showybox

### Frame properties
- `title-color`: Color used as background color where the title goes (default is `black`)
- `body-color`: Color used as background color where the body goes (default is `white`)
- `footer-color`: Color used as background color where the footer goes (default is `luma(85)`)
- `border-color`: Color used for the showybox's border (default is `black`)
- `radius`: Showybox's radius (default is `5pt`)
- `thickness`: Border thickness of the showybox (default is `1pt`)
- `dash`: Showybox's border style (default is `solid`)

### Title styles
- `color`: Text color (default is `white`)
- `weight`: Text weight (default is `bold`)
- `align`: Text align (default is `left`)

### Body styles
- `color`: Text color (default is `black`)
- `align`: Text align (default is `left`)

### Footer styles
- `color`: Text color (default is `luma(85)`)
- `weight`: Text weight (default is `regular`)
- `align`: Text align (default is `left`)

### Separator properties
- `thickness`: Separator's thickness (default is `1pt`)
- `dash`: Separator's style (as a `line` dash style, default is `"solid"`)
- `gutter`: Separator's space above and below

### Shadow properties
- `color`: Shadow color (default is `black`)
- `offset`: How much to offset the shadow in x and y direction either as a length or a dictionary with keys `x` and `y` (default is `4pt`)


## Gallery

### Encapsulation

May have some bugs
<h3 align="center">
  <img alt="Encapsulation" src="assets/encapsulation.png" style="max-width: 100%; background-color: #FFFFFF; padding: 10px 10px; box-shadow: 1pt 1pt 10pt 0pt #AAAAAA; border-radius: 4pt">
</h3>

### Enabling breaking
<h3 align="center">
  <img alt="Enabling breakable" src="assets/enabling-breakable.png" style="max-width: 100%; padding: 10px 10px; background-color: #E4E5EA; box-shadow: 1pt 1pt 10pt 0pt #AAAAAA; border-radius: 4pt">
</h3>

### Custom radius
<h3 align="center">
  <img alt="Custom radius" src="assets/custom-radius.png" style="max-width: 100%; background: #FFFFFF; padding: 10px 10px; box-shadow: 1pt 1pt 10pt 0pt #AAAAAA; border-radius: 4pt">
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

### Version 0.2.1

_All changes listed here were performed by Jonas Neugebauer (<https://github.com/jneug>)_

- Added the `shadow` option 
- Enabled auto-break (`breakable`) functionality for titled showyboxes
- Removed a thin line that appears in showyboxes with no borders or dashed borders

### Version 1.0.0

- Fixed shadow displacement
  - **Details:** Instead of displacing the showybox's body from the shadow, now the shadow is displaced from the body.

_Changes below were performed by Jonas Neugebauer (<https://github.com/jneug>)_

- Added `title-inset`, `body-inset`, `footer-inset` and `inset` options
	- **Details:** `title-inset`, `body-inset` and `footer-inset` will set the inset of the title, body and footer area respectively. `inset` is a fallback for those areas.
- Added a `sep.gutter` option to set the spacing around separator lines 
- Added option `width` to set the width of a showybox
- Added option `align` to move a showybox with `width` < 100% along the x-axis
	- **Details:** A showybox is now wrapped in another block to allow alignment. This also makes it possible to pass the spacing options `spacing`, `above` and `below` to `#showybox()`.
- Added `footer` and `footer-style` options
	- **Details:** The optional footer is added at the bottom of the box.
