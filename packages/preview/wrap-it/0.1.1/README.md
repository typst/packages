# Wrap-It: Wrapping text around figures & content

Until <u><u><https://github.com/typst/typst/issues/553></u></u> is
resolved, `typst` doesn’t natively support wrapping text around figures
or other content. However, you can use `wrap-it` to mimic much of this
functionality:

- Wrapping images left or right of their text

- Specifying margins

- And more

Detailed descriptions of each parameter are available in the
<u><u>[wrap-it
documentation](https://github.com/ntjess/wrap-it/blob/main/docs/manual.pdf)</u></u>.

# Installation

The easiest method is to import `wrap-it: wrap-content` from the
`@preview` package:

`#import "@preview/wrap-it:0.1.1": wrap-content`

# Sample use:

## Vanilla

``` typst
#let fig = figure(
rect(fill: teal, radius: 0.5em, width: 8em),
caption: [A figure],
)
#let body = lorem(30)
#wrap-content(fig, body)
```
![Example 1](https://www.github.com/ntjess/wrap-it/raw/v0.1.1/assets/example-1.png)

## Changing alignment and margin

``` typst
#wrap-content(
fig,
body,
align: bottom + right,
column-gutter: 2em
)
```
![Example 2](https://www.github.com/ntjess/wrap-it/raw/v0.1.1/assets/example-2.png)

## Uniform margin around the image

The easiest way to get a uniform, highly-customizable margin is through
boxing your image:

``` typst
#let boxed = box(fig, inset: 0.25em)
#wrap-content(boxed)[
#lorem(30)
]
```
![Example 3](https://www.github.com/ntjess/wrap-it/raw/v0.1.1/assets/example-3.png)

## Wrapping two images in the same paragraph

Note that for longer captions (as is the case in the bottom figure
below), providing an explicit `columns` parameter is necessary to inform
caption text of where to wrap.

``` typst
#let fig2 = figure(
rect(fill: lime, radius: 0.5em),
caption: [#lorem(10)],
)
#wrap-top-bottom(
bottom-kwargs: (columns: (1fr, 2fr)),
box(fig, inset: 0.25em),
fig2,
lorem(50),
)
```
![Example 4](https://www.github.com/ntjess/wrap-it/raw/v0.1.1/assets/example-4.png)

## Adding a label to a wrapped figure

Typst can only append labels to figures in content mode. So, when
wrapping text around a figure that needs a label, you must first place
your figure in a content block with its label, then wrap it:

``` typst
#show ref: it => underline(text(blue, it))
#let fig = [
  #figure(
    rect(fill: red, radius: 0.5em, width: 8em),
    caption:[Labeled]
  )<fig:lbl>
]
#wrap-content(fig, [Fortunately, @fig:lbl's label can be referenced within the wrapped text. #lorem(15)])
```
![Example 5](https://www.github.com/ntjess/wrap-it/raw/v0.1.1/assets/example-5.png)