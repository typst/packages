# toffee-tufte

This template was inspired by the style of Edward Tufte's handouts and books.
By keeping the large right margin for sidenotes, but changing the design language, this template aims to maintain the practicality of a sidenote-centric document, while having a more familiar look for scientific and engineering fields.

# Usage

Refer to the [usage guide](https://codeberg.org/jianweicheong/toffee-tufte/src/branch/main/template/main.pdf) for more information.

```typst
#import "@preview/toffee-tufte:0.1.0": *

#show: template.with(
  title: [This is a title],
  authors: "John Doe",
)
```

These are the 11 options and their default values:

+ `title: content | none = none`,
+ `authors: array | none | str = none`,
+ `date: str =` <todays date>,
+ `abstract: none = none`,
+ `toc: bool = false`,
+ `full: bool | state = false`,
+ `header: bool | true`,
+ `footer: bool | true`,
+ `header-content: none = none`,
+ `footer-content: none = none`,
+ `bibfile: [bib] | array | none = none`,

## Full width mode

In addition to the default Tufte-style format as shown in this document, this template also provides the option to become a full width document by setting `full: true`.
Doing so will turn all contents placed in the right margin to footnotes automatically.

## Sidenote

> Places a sidenote at the right margin.
> If `full` template option is set to `true`, becomes a footnote instead.
>
>  - `dy: auto | length = auto` Vertical offset.
>  - `numbered: bool = true` Insert a superscript number.
>  - `body: content` Required. The content of the sidenote.

Sidenotes can be placed easily with

```typst
#sidenote[This is a sidenote content.]
```

## Sidenote citation

> Places a sidenote at the right margin.
> If `full` template option is set to `true`, becomes a footnote instead.
> Only display when `bibliography` is defined.
>
>  - `dy: auto | length = auto` Vertical offset.
>  - `form: none | str = "normal"` Form of in-text citation.
>  - `style: [csl] | auto | bytes | str = auto` Citation style.
>  - `supplement: content | none = none` Citation supplement.
>  - `key: cite-label` Required. The citation key.

Sidenote citations can be placed easily with

```typst
#sidecite(<EinsteinEPR1935>)
```

## Wideblock

> Wrapped content will span the full width of the page.
>
>  - `content: content | none` Required. The content to span the full width.

Wideblocks can be used with

```typst
#wideblock[This content spans the entire width of the document.]
```
