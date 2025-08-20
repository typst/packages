# minideck themes

A theme is implemented through a configuration function that has the following positional input:

  - `minideck.slide` function

and must accept at least the following named input:

  - `page-size`: a dictionary with absolute lengths `width` and `height`

and return as output a dictionary of theme functions including at least

  - `template`: a template for the whole document
  - `slide`: the input `slide` function or a wrapper for it
  - `title-slide`: the input `slide` function or a wrapper for it

The configuration function can accept additional parameters and return additional values in the output dictionary.
The theme functions in the output dictionary can also accept non-standard parameters.

The theme functions that make slides (`slide`, `title-slide` and possibly others) should be wrappers around the `slide` function given as input.

For example an `ocean` theme from a `fancy-themes` package could be used like this:

```typst
#import "@preview/minideck:0.2.1"
#import "@preview/fancy-themes:0.1.0" // hypothetical package
#let (template, slide, title-slide) = minideck.config(theme: fancy-themes.ocean)
#show: template
```

or when theme configuration is required:

```typst
#import "@preview/minideck:0.2.1"
#import "@preview/fancy-themes:0.1.0" // hypothetical package
#let (template, slide, title-slide) = minideck.config(
  theme: fancy-themes.ocean.with(variant: "dark"),
)
#show: template
```
