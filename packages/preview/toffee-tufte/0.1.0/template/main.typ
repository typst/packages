#import "@preview/toffee-tufte:0.1.0": *

#show: template.with(
  title: [`toffee-tufte 0.1.0`: An opinionated Tufte-inspired template for scientific reports],
  authors: "Jian Wei Cheong",
  // date: none,
  // toc: true,
  // full: true,
  abstract: [
    This template was inspired by the style of Edward Tufte's handouts and books.
    By keeping the large right margin for sidenotes, but changing the design language, this template aims to maintain the practicality of a sidenote-centric document, while having a more familiar look for scientific and engineering fields.
    This document covers the usage guide of this template.
  ],
  bib: bibliography("main.bib"),
)

#sidenote(dy: 1.5em, numbered: false)[#outline(depth: 2)]

= Usage Guide <sec:usage-guide>
== Motivation

Famous for his works on information design and data visualization, #link("https://en.wikipedia.org/wiki/Edward_Tufte")[Edward Tufte]'s handout design is lauded for having well-set typography with a clean and elegant look.
Its design and style is a favorite of many, and has been replicated in various typesetting programs#sidenote[See #link("https://www.overleaf.com/latex/templates/example-of-the-tufte-handout-style/ysjghcrgdrnz")[LaTeX], #link("https://bookdown.org/yihui/rmarkdown/tufte-handouts.html")[R Markdown], #link("https://github.com/fredguth/tufte-inspired")[Quarto], and #link("https://typst.app/universe/package/tufte-memo")[Typst itself].].

However, some design choices, _in my opinion_, lead to less information clarity#sidenote[E.g., the use of _italics_ instead of *bold* for section headings.] and density.
Furthermore, its design language might be atypical and unfamiliar to scientists and engineers, different from those in published literature, or those in common LaTeX or Typst templates.

This template aims to provide the practical advantages of the Tufte-inspired layout, while keeping the more familiar design language for scientific documents with a focus on information clarity and density.

== Options

To use this template, simply import it and set the options with a `show` rule:

```typst
#import "@preview/toffee-tufte:0.1.0": *
#show: template.with(
  title: [This is a title],
  authors: "John Doe",
)
```

These are the 11 options#sidenote[All of which are optional.] and their default values:
+ `title: content | none = none`,
+ `authors: array | none | str = none`,
+ `date: str =` \<todays date\>#sidenote[The date is automatically set to be the current date in "21 September 2025" format.],
+ `abstract: none = none`,
+ `toc: bool = false`,
+ `full: bool | state = false`,
+ `header: bool | true`,
+ `footer: bool | true`,
+ `header-content: none = none`,
+ `footer-content: none = none`,
+ `bib: [bib content] | none = none`,

=== Title block

An example of the title block is shown at the start of this document.
`title`, `author`, `date`, `abstract`, and table of contents will be shown in the title block.
Keeping the default options means that only `date` will be printed, which can be overwritten or disabled by setting for example `date: "01-02-06"` or `date: none`, respectively.

For multiple authors, they must be placed in an `array`, e.g., `authors: ("John Doe", "Jane Doe")`, which will result in "John Doe and Jane Doe"#sidenote[For 3 or more authors, the #link("https://en.wikipedia.org/wiki/Serial_comma")[serial/Oxford comma] will be used.].
If this formatting is not desired, one can combine the names in a single string in the desired format, e.g., `authors: "John Doe & Jane Doe"`.

Note that any missing options#sidenote[Or `date: none` for `date`.] will not create a blank line in the title block, but setting them as an empty string `""` would.

=== Table of contents --- `toc`

Table of contents is disabled by default, but can be activated with `toc: true`.
It will be placed right after the abstract in the title block, with up till `depth: 2`.

One can also place the table of contents at the side margin as shown at the first page with#sidenote[Here, we used the function `sidenote` that comes with this template. Refer to Sec.~@sec:sidenote for details on this function.]:

```typst
#sidenote(numbered: false)[#outline(depth: 3)]
```

=== Full width --- `full`

In addition to the default Tufte-style format as shown in this document, this template also provides the option to become a full width document by setting `full: true`.
Doing so will turn all contents placed in the right margin to footnotes automatically.

=== Headers and footers

By default, as shown in this document, the page header contains the title, author, and date, while the footer contains just the page number.
These can be turned off with `header: false` and `footer: false`.
Custom header and footer contents can also be provided with `header-content` and `footer-content`.

=== Bibliography --- `bib`

The `bib` option takes a `bibliography("file.bib")` function for citations and is simply for convenience.
It creates a "Bibliography" section at the end of the document in full width.

== Functions

This template provides three functions: `#sidenote()`, `#sidecite()`, and `#wideblock()`, which are modifications of functions made by #link("https://noahgula.com/")[Noah Gula] for his `tufte-memo` template #sidecite(<tufte-memo2024>).
These functions rely on the `drafting` package by Nathan Jessurun and #link("https://t1ng.dk/")[Jens Tinggaard] #sidecite(<drafting2025>).

=== Sidenote --- `#sidenote()` <sec:sidenote>

#block(fill: luma(95%), radius: 4pt, inset: 5pt, [
  A sidenote.

  Places a sidenote at the right margin.
  If `full` template option is set to `true`, becomes a footnote instead.

  - `dy: auto | length = auto` Vertical offset.
  - `numbered: bool = true` Insert a superscript number.
  - `body: content` Required. The content of the sidenote.
])

Sidenotes can be placed easily with

```typst
#sidenote[This is a sidenote content.]
```

For example, this sidenote#sidenote(dy: -2em)[This is an example sidenote.] was placed as follows:

```typst
For example, this sidenote#sidenote(dy: -2em)[This is an example sidenote.] was placed as follows:
```

Different types of content can also be placed in with the `#sidenote()` function, e.g., figures, tables, or code blocks.

#sidenote(dy: -10em, numbered: false)[
  Likewise, this sidenote without numbering can be placed by:

  ```typst
  #sidenote(numbered: false)[Likewise, this sidenote without numbering can be placed by:]
  ```
]

#v(-1.5em)
For example, this is a sidenote figure:

```typst
#sidenote(numbered: false)[
  #figure(
    rect(width: 100%, height: 10em, fill: aqua),
    caption: [This is an example sidenote figure.],
  )
]
```

#sidenote(dy: -12.5em, numbered: false)[
  #figure(
    rect(width: 100%, height: 10em, fill: aqua, [
      #align(horizon, "This is a sidenote figure.")
    ]),
    caption: [This is an example sidenote figure.],
  )
]

For figures in the main text, it is also possible to position their caption as a sidenote with

```typst
#set figure.caption(position: top)
#show figure.caption.where(position: top): sidenote.with(numbered: false)
```
#set figure.caption(position: top)
#show figure.caption.where(position: top): sidenote.with(numbered: false)

#set figure.caption(position: top)
#figure(
  rect(width: 50%, height: 7em, fill: teal, [
    #align(horizon, "This is a figure with its caption as a sidenote.")
  ]),
  caption: [This is an example sidenote figure caption.],
)
#set figure.caption(position: bottom)

=== Sidenote citation --- `#sidecite()` <sec:sidecite>

#block(fill: luma(95%), radius: 4pt, inset: 5pt, [
  A sidenote citation.

  Places a sidenote at the right margin.
  If `full` template option is set to `true`, becomes a footnote instead.
  Only display when `bibliography` is defined.

  - `dy: auto | length = auto` Vertical offset.
  - `form: none | str = "normal"` Form of in-text citation.
  - `style: [csl] | auto | bytes | str = auto` Citation style.
  - `supplement: content | none = none` Citation supplement.
  - `key: cite-label` Required. The citation key.
])

We have already seen some of the sidenote citations above.
For example, here we cite the famous EPR paper #sidecite(<EinsteinEPR1935>) as a sidenote.

Which is cited simply by

```typst
For example, here we cite the famous EPR paper #sidecite(<EinsteinEPR1935>) as a sidenote.
```

The citations will automatically be added to the Bibliography at the end of the document, and of course, `bibliography` must be defined for this function to work#sidenote[Recall that it can also be defined with the `bibfile` template option.].

The usual `form`, `style`, and `supplement` for citations can be fed to the function for more customizability.

=== Wideblock --- `#wideblock()` <sec:wideblock>

#block(fill: luma(95%), radius: 4pt, inset: 5pt, [
  Wideblock

  Wrapped content will span the full width of the page.

  - `content: content | none` Required. The content to span the full width.
])

#wideblock[
  The `#wideblock()` function simply ensures that the wrapped content span the full width of the document, spilling over to the right margin, e.g., this paragraph.
  It is not affected by the `full` template option; both `full: true` and `full: false` gives the same result.
  Though of course, in the case of `full: true`, there is no need to use `#wideblock()`.

  `#wideblock()` can also be used on figures.
  For example,

  ```typst
  #wideblock[
    #figure(
      rect(width: 100%, height: 10em, fill: eastern),
      caption: [This is a full width figure.],
    )
  ]
  ```
  #figure(
    rect(width: 100%, height: 10em, fill: eastern, [
      #align(horizon, "This is a full width figure.")
    ]),
    caption: [This is a full width figure.],
  )
]
