# The `gridlock` Package (v0.4.0)

Grid typesetting in Typst.
Use this package if you want to line up your body text across columns and pages.

## Example

![An example image showing a two-column page with headings, a block quote, a footnote, a figure, a display formula, and a bulleted list. All body text in both columns lines up.](docs/assets/example-lines.png)

## Getting Started

```typ
#import "@preview/gridlock:0.4.0": *

#show: gridlock.with()

#lock[= This is a heading]

#lorem(30)

#figure(
  placement: auto,
  caption: [a caption],
  rect()
)

#lorem(30)
```

## Usage

Check out [the manual](docs/gridlock-manual.pdf) for a detailed description.

To get started, import the package into your document:

```typ
#import "@preview/gridlock:0.4.0": *
```

Set up the basic parameters:

```typ
#show: gridlock.with(
  paper: "a4",
  margin: (y: 76.445pt),
  font-size: 11pt,
  line-height: 13pt
)
```

You can now use the `lock()` function to align any block to the text grid.
Block quotes bulleted/numbered lists, and floating figures do _not_ need to be wrapped in `lock()`.
Their spacing is handled fully automatically.

```typ
#lock[= Heading]

#lorem(50)

#lock(figure(
  rect(),
  caption: [An example figure aligned to the grid.]
))

#lorem(50)

#lock[$ a^2 = b^2 + c^2 $]

#lorem(50)
```
