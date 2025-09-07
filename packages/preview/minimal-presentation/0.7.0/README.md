# minimal presentation
A modern minimalistic presentation template ready to use.

## Usage
You can use this template in the Typst web app by clicking "Start from template"
on the dashboard and searching for `minimal-presentation`.

Alternatively, you can use the CLI to kick this project off using the command
```
typst init @preview/minimal-presentation
```

Typst will create a new directory with all the files needed to get you started.

## Configuration
This template exports the `project` function with the following named arguments:

- `title`: The book's title as content.
- `sub-title`: The book's subtitle as content.
- `author`: Content or an array of content to specify the author.
- `main-color`: The main color of the template.
- `lang`: The language of the presentation.
- `aspect-ratio`: Defaults to `16-9`. Can be also `4-3`.
- `text-size`: Text font size. Defaults to `20pt`
- `heading-1-size`: Heading 1 font size. Defaults to `2.9em`
- `heading-2-size`: Heading 2 font size. Defaults to `1.9em`
- `caption-size`: Caption font size. Defaults to `0.75em`
- `cover-title-size`: Cover title font size. Defaults to `3.1em`
- `cover-subtitle-size`: Cover subtitle font size. Defaults to `1.5em`

The function also accepts a single, positional argument for the body of the
book.

The template will initialize your package with a sample call to the `project`
function in a show rule. If you, however, want to change an existing project to
use this template, you can add a show rule like this at the top of your file:

```typ
#import "@preview/minimal-presentation:0.7.0": *

#set text(font: "Lato")
#show math.equation: set text(font: "Lato Math")
#show raw: set text(font: "Fira Code")

#show: project.with(
  title: "Minimalist presentation template",
  sub-title: "This is where your presentation begins",
  author: "Flavio Barisi",
  date: "10/08/2023",
  index-title: "Contents",
  logo: image("./logo.svg"),
  logo-light: image("./logo_light.svg"),
  cover: image("./image_3.jpg"),
  main-color: rgb("#E30512"),
  lang: "it",
)

= This is a section

== This is a slide title

#lorem(10)

- #lorem(10)
  - #lorem(10)
  - #lorem(10)
  - #lorem(10)

== One column image

#figure(
  image("image_1.jpg", height: 10.5cm),
  caption: [An image],
) <image_label>

== Two columns image

#columns-content()[
  #figure(
    image("image_1.jpg", width: 100%),
    caption: [An image],
  ) <image_label_1>
][
  #figure(
    image("image_1.jpg", width: 100%),
    caption: [An image],
  ) <image_label_2>
]

== Two columns

#columns-content()[
  - #lorem(10)
  - #lorem(10)
  - #lorem(10)
][
  #figure(
    image("image_3.jpg", width: 100%),
    caption: [An image],
  ) <image_label_3>
]

= This is a section

== This is a slide title

#lorem(10)

= This is a section

== This is a slide title

#lorem(10)

= This is a section

== This is a slide title

#lorem(10)

= This is a very v v v v v v v v v v v v v v v v v v v v  long section

== This is a very v v v v v v v v v v v v v v v v v v v v  long slide title

= sub-title test

== Slide title

#lorem(50)

=== Slide sub-title 1

#lorem(50)

=== Slide sub-title 2

#lorem(50)


```

## Fonts
You can use the font selected by the author of this plugin, by download theme at the following link:

https://github.com/flavio20002/typst-presentation-minimal-template/tree/main/fonts

You can then import thme in your system, import them in the typst web app or just put them in a folder and launch the compilation with the following argoument:

```
typst watch main.typ --root . --font-path fonts
```
