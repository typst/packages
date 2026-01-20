# Helios

Helios is a minimal theme for creating academic presentations with
[Typst](https://typst.app) and
[Polylux](https://typst.app/universe/package/polylux).

The package is an early stage and future version may make adjustments
that break functionality without warning.

The Helios theme is inspired by the [`metropolis-polylux`
theme](https://github.com/polylux-typ/metropolis) and the [Metropolis
theme for Beamer](https://github.com/matze/mtheme). Code for the
`outline` and `focus` functions was taken from the `metropolis-polylux`
theme.

## Installation

The package is not (yet) available in the Typst package repository.

Via the Typst documentation, the template can be installed by
downloading or cloning this repository into
`{data-dir}/typst/packages/local/helios-polylux/0.0.1`, where the
`{data-dir}` depends on the operating system: 

- `$XDG_DATA_HOME` or `~/.local/share` on Linux
- `~/Library/Application Support` on macOS
- `%APPDATA%` on Windows

For example, on Linux, you could clone the repository directly into the
local Typst package folder:

`git clone https://codeberg.org/dschoenig/helios-polylux.git ~/.local/share/typst/packages/local/helios-polylux/0.1.0/`

For more information, see the Typst documentation on [local
packages](https://github.com/typst/packages/blob/main/README.md#local-packages).

By default, the package uses IBM Plex fonts (Sans, Sans Condensed, Mono and Math),
which you can download here:

- [IBM Plex Sans](https://github.com/IBM/plex/releases/tag/%40ibm%2Fplex-sans%401.1.0)
- [IBM Plex Sans Condensed](https://github.com/IBM/plex/releases/tag/%40ibm%2Fplex-sans-condensed%402.0.0)
- [IBM Plex Mono](https://github.com/IBM/plex/releases/tag/%40ibm%2Fplex-mono%401.1.0)
- [IBM Plex Math](https://github.com/IBM/plex/releases/tag/%40ibm%2Fplex-math%401.1.0)

Feel free to use other typefaces as described in the Customization
section. Just keep in mind that the spacing and whitespace have been
determined based on the properties of the Plex fonts, which potentially
leads to subpar results (or requiring additional adjustments) for
alternative typefaces. For example, slides are by default set in a
condensed font (if available).


## Create a new presentation

Use the `typst init` functionality to create a new presentation based on
the Helios template:

```
typst init @preview/metropolis-polylux new-presentation
```

This will create a folder called `new-presentation` containing a
`presentation.typ` file that can be used a starting point for your
presentation.

## Setup

To use the default settings (e.g. orange accent colour), simply call

`#show: setup`

before your presentation content.


### Customization

The setup function accepts the following arguments for customization:

- `text-font`, `math-font`, `code-font`: Specify the fonts to be used.
Defaults are, respectively, `"IBM Plex Sans"`, `"IBM Plex Math"`, `"IBM
Plex Mono"`.
- `colour-fg`: The colour to be used in foreground elements (i.e. text).
The default is `rgb(21,20,26)`.
- `colour-bg`: The colour to be used in background elements (i.e. slide
background). The default is `white`.
- colour-accent: Accent colour to be used for emphasis (i.e. text inside
`_ … _`), by default `rgb("#D45E00")`. Also used by `hypothesis` blocks
(see below).
- `text-size`: Sets the text size for slide content. Other elements are
adjusted accordingly. The default is `16pt`. Any changes are likely to
negatively affect spacing and whitespace without further adjustments.
- `section` (boolean or string): Set to `true` (default) will include
the current section title in the footer. Alternatively, provide a string
to set the footer text directly.
- `number`: Whether to number standard slides (defaults to `true`). Some
slide types (i.e. *focus* slides, *image* slides, and *section* slides)
are not numbered by default. Numbering can also be specified with the
`slide` function for each slide individually.
- `lang`: Provide a string with the ISO language code (e.g. `"fr"`,
`"es"`, etc.) to set the language of the presentation. Defaults to `"en"`.

To set up a presentation in French with a different accent colour, for
example, you can use following setup call:

`#show: setup.with(colour-accent: rgb("#099D72"), lang: "fr")`


## Usage

As a Polylux template, you can take advantage of the functionality
explained in the corresponding [documentation](https://polylux.dev/book/polylux.html). The following sections focus on utilities provided by the Helios template specifically.


### Colour emphasis and italics

As italic text is typically less readable in a presentation setting,
emphasis (delimited by `_ … _`) is generally provided by coloured text
(according to the accent colour). To explicitly produce italics, you can
pass content to the `it[]` function instead.

```typst
This will produce _text highlighted in the accent colour_.

This will produce #it[italic text instead].
```

### Hypothesis blocks

The `hypothesis` function provides a shaded block with a title and
further content, set apart with a coloured border on the left side.
The accent and background colours can be further customized:

- `accent`: Sets the colour of the left border. Default to the `colour-accent`
argument provided in the setup function (and thus `rgb("#D45E00")` if not
provided there).
- `fill`: Background fill of the content block. Defaults to `luma(245)`.

A standard hypothesis block can produced like this:

```typst
#hypothesis[
  H#sub[1] -- An interesting hypothesis
][
  #lorem(25)
]
```
Or with different accent colour and white background:

```typst
#hypothesis(accent: rgb("#099D72"), fill: white)[
  H#sub[1] -- An interesting hypothesis
][
  #lorem(25)
]
```

### Inverted slides

Foreground and background colour of slides can be inverted by placing `#show: invert-slide` at the beginning of the slide content:

```typst
#slide[
  #show: invert-slide

  = Inverted content slide

  The foreground and background colours can generally be inverted with
  `#show: invert-slide`.

]
```

### Focus slides

Focus slides use a larger font and different spacing to communicate
short key messages. This is set by placing `#show: focus` before the
slide content:

```typst
#slide[
  #show: invert-slide
  #show: focus

  *A particularly important aspect*

  Focus slides can be used to _emphasize_ a short but important message.
]
```

This functionality also works for inverted slides:

```typst
#slide[
  #show: invert-slide
  #show: focus
  *A particularly important aspect*

  Focus slides can be used to _emphasize_ a short but important message.
]
```


### Image slides

The `img-slide` function can be used to produce fullscreen image slides,
optionally with inverted background and foreground colours. By default,
image slides do not include a footer. Text and other elements can be
placed on the slide as needed. The `img-slide` function accepts the
following arguments:

- `img`: The image to be shown on the slide, as passed with the `image`
function.
- `invert`: Whether to invert background and foreground colours (see
above). Defaults to `false`.
- `section`: Whether to include the section in the footer (default
`false`).
- `number`: Whether to include the slide number in the footer (default
`false`).
- `foreground`: Any content to be placed in the foreground (i.e. "above" the
image).
- `slide-fill`: Changes the background colour of the slide. Useful to
match the colour of an image that is smaller than the slide. Defaults to
`none` (i.e. the background colour specified at setup).

A fullscreen image slide with a black background colour and with text
set in a colour that corresponds the slide background of a standard
slide can be produced like this:

```typst
#img-slide(
  image("img_helios_example.jpg"), 
  invert: true,
  slide-fill: black
)[
  #place(bottom+right, text(size: 0.5em)[Image: NASA/Goddard/SDO])
]
```

### Sections and outline

A section slide can be produced with the `make-section` function. By
default, the section title (or a short version) will appear in the footer
of the following slides, and in the presentation outline. `make-section`
accepts the following arguments:

- `name`: The title of the section
- `shortname`: A short version of the section title to be used in
footers and outlines.
- `caps`: Whether the section slide should be set in all capitals
(default `true`). This does not affect footers and outlines.

A simple section slide can be produced with:

```typst
#make-section[Introduction]
```

Short names are helpful for longer section titles:

```typst
#make-section[
  Helios, a minimal theme for academic presentation using Typst and Polylux
][
  Helios theme
]
```

The `outline` function can be used to produce an overview of all
sections:

```typst
#slide[
  = Overview

  #set text(size: 1.25em)

  #outline
]
```

### Footer (sections and slide numbers)

The make-footer function can be called directly to customize the slide
footer. By default it will contain the (short version) of the section
and the slide number. The function accepts the following arguments:

- `section` (boolean or string): Set to `true` (default) will include
the (short) title of the current section title in the footer.
Alternatively, you can set the footer text explicitly by providing a string.
- `number`: Whether the slide number should be included in the footer
(default `true`).

For example, to remove section title and page numbers you can use a show
rule:

```typst
#slide[
  #show: page.with(footer: make-footer(section: false, number: false))

  = Content slide
  
  #lorem(50)
]
```

Or you can provide alternative text in the footer:

```typst
#slide[
  #show: page.with(footer: make-footer(section: [Alternative footer text]))

  = Content slide
  
  #lorem(50)
]
```






