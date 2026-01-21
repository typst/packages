# Wrap-It: Wrapping text around figures & content

Until <u><https://github.com/typst/typst/issues/553></u> is resolved,
`typst` doesn’t natively support wrapping text around figures or other
content. However, you can use `wrap-it` to mimic much of this
functionality:

- Wrapping images left or right of their text

- Specifying margins

- And more

Detailed descriptions of each parameter are available in the <u>[wrap-it
documentation](https://github.com/ntjess/wrap-it/blob/main/docs/manual.pdf)</u>.

# Installation

The easiest method is to import `wrap-it: wrap-content` from the
`@preview` package:

``` typ
#import "@preview/wrap-it:0.1.0": wrap-content
```

# Sample use:

## Vanilla

``` typst
#set par(justify: true)
#let fig = figure(
  rect(fill: teal, radius: 0.5em, width: 8em),
  caption: [A figure],
)
#let body = lorem(40)
#wrap-content(fig, body)
```
![Example 1](https://www.github.com/ntjess/wrap-it/raw/v0.1.0/assets/example-1.png)

## Changing alignment and margin

``` typst
#wrap-content(
  fig,
  body,
  align: bottom + right,
  column-gutter: 2em
)
```
![Example 2](https://www.github.com/ntjess/wrap-it/raw/v0.1.0/assets/example-2.png)

## Uniform margin around the image

The easiest way to get a uniform, highly-customizable margin is through
boxing your image:

``` typst
#let boxed = box(fig, inset: 0.5em)
#wrap-content(boxed)[
  #lorem(40)
]
```
![Example 3](https://www.github.com/ntjess/wrap-it/raw/v0.1.0/assets/example-3.png)

## Wrapping two images in the same paragraph

``` typst
#let fig2 = figure(
  rect(fill: lime, radius: 0.5em),
  caption: [Another figure],
)
#wrap-top-bottom(boxed, fig2, lorem(60))
```
![Example 4](https://www.github.com/ntjess/wrap-it/raw/v0.1.0/assets/example-4.png)