# Qooklet

A quick start template for scientific booklets.

## Features

### Modularization

- Mode Switch
  - the default mode is note mode
  - when `cover()` is called the booklet mode will be activated
- Styles
  - call `cover()`, `epigraph()`, `preface()`, `contents()` and `part-page()` to generate corresponding page
  - call `chapter-style()` and `appendix-style()` to change to customized layout

### Automation

- Math Equation
  - auto numbering based on chapter
  - link quote to source
- Figure
  - auto numbering based on chapter
- Table
  - read as three-line table
- Code Block
  - stylized by (using [codly](https://github.com/Dherse/codly))
  - read code block

### Useful Functions

#### Tables

- `tableq(data, k, stroke: table-three-line(rgb("000")), inset: 0.3em)`: reading .csv, where `k` is the number of columns, and for stroke, `qooklet` provide 2 predefined styles
  - `table-three-line(stroke-color)`: default style, for three-line table
  - `table-no-left-right(stroke-color)`: for grid without left border and right border

```typst
#let data = csv("data.csv")
#figure(
  tableq(data, 5),
  // stroke: table-three-line(rgb("000")),
  // caption: ""
  // supplement: "",
  kind: table,
)
```

#### Codes

- `code(text, lang: "python", breakable: true, width: 100%)`: read stylized code blocks

```typst
#let compose = read("docker-compose.yml")
#code(compose, lang: "yaml")
```

### Environments

- Theorem
  - theorems enviroment is implemented by using [theorion](https://github.com/OrangeX4/typst-theorion) (the counters still needs tweaking in the booklet mode)
- Shorthands
  - scientific shorthands are provided by [physica](https://github.com/Leedehai/typst-physics)

## Get Started

Import `qooklet` from the `@preview` namespace.

### Note Mode

```typst
#import "@preview/qooklet:0.6.1": *
#show: chapter-style.with(
  title: "Chapter Title",
  // the following are optional arguments
  // title: "",
  // info: default-info,
  // styles: default-styles,
  // names: default-names,
  // outline-on: false,
)
```

where `info` is an argument that let you customize the information of your booklet using a toml file (if you leave it alone, the following info will be empty).

You can read you info file by the following sentence

```typst
#let info = toml("your path").key-you-like
```

The toml file should look like this

```toml
[key-you-like]
    title = "Your Booklet Name"
    author = "Your Name"
    footer = "Some Info You Want to Show"
    header = "Some Info You Want to Show"
    lang = "en" # or "zh"
```

![example](https://raw.githubusercontent.com/ivaquero/typst-qooklet/refs/heads/main/example.png)

### Booklet Mode

The booklet mode will be activated after calling `cover()`

```typst
#import "@preview/qooklet:0.6.1": *

#let info = toml(your-info-file-path).key-you-like
// for example: #let info = toml("config/info.toml").global

// add a cover
#cover(
  info,
  date: datetime.today(),
)

#epigraph(info: info)[
  // Add an epigraph to the document.
]

#preface(info: info)[
  // Add a preface to the document.
]

#contents

// body
#show: chapter-style.with(
  title: "chapter-title 1",
  info: info,
)

#show: chapter-style.with(
  title: "chapter-title 2",
  info: info,
)
...

// appendix
#part-page(info: info)[Appendix]

#show: appendix-style.with(
  title: "Appendix-title 1",
  info: info,
)

#show: appendix-style.with(
  title: "Appendix-title 2",
  info: info,
)
...
```

![example-book](https://raw.githubusercontent.com/ivaquero/typst-qooklet/refs/heads/main/example-book.png)

## Tweaking the Params

### Names

Qooklet's section names support English and Chinese by default. If you are not neither English speaker nor Chinese speaker, assume you are a French speaker, you can create a toml like

```toml
[sections.fr]
    preface = "Préface"
    chapter = "Chapitre"
    content = "Table Des Matières"
    bibliography = "Bibliographie"

[blocks.fr]
    algorithm = "Algorithme"
    table = "Tableau"
    figure = "Figure"
    equation = " Eq."
    rule = "Règle"
    law = "Loi"
```

after reading this file by `toml()`, assign its value to the argument `names` in style functions, such as `chapter-style()`, `appendix-style()`.

### Styles

If you are not satisfied with the default styles such as font-family, font-size, you can create a toml like

```toml
[paper]
    note = "a4"
    booklet = "iso-b5"

[spaces]
    par-indent = 2
    par-leading = 1
    par-spacing = 1
    list-indent = 1.2
    block-above = 1
    block-below = 1
    contents-indent = 1.2

[sizes]
    chapter = 24
    chapter-index = 50
    cover = 36
    author = 24
    date = 18
    epigraph = 16
    preface = 22
    contents = 22
    part = 36
    heading-1 = 16
    heading-2 = 14
    heading-3 = 12
    heading-4 = 10.5
    context = 10.5
    header = 8
    footer = 8

[fonts.en]
    chapter = "Palatino"
    chapter-index = "Palatino"
    cover = "Palatino"
    author = "Times New Roman"
    date = "Times New Roman"
    epigraph = "Georgia"
    preface = "Georgia"
    contents = "Georgia"
    part = "Georgia"
    context = "Georgia"
    math = "Times New Roman"
```

after reading this file by `toml()`, assign its value to the argument in style functions, such as `chapter-style()`, `appendix-style()`.

Don't forget to change the key `lang` in your info toml metioned above.

For more details, see [examples.typ](https://github.com/ivaquero/typst-qooklet/blob/main/examples/example.pdf) and [examples-book.typ](https://github.com/ivaquero/typst-qooklet/blob/main/examples/example-book.pdf).

## Clone the Repository

Clone the [qooklet](https://github.com/ivaquero/typst-qooklet) repository to your `@local` workspace:

- Linux：
  - `$XDG_DATA_HOME/typst/packages/local`
  - `~/.local/share/typst/packages/local`
- macOS：`~/Library/Application\ Support/typst/packages/local`
- Windows：`%APPDATA%/typst/packages/local`

Import `qooklet` in the document

```typst
#import "@local/qooklet:0.1.0": *
```

> For developement convinience, local repo never changes the version

## Credits

Thanks @ParaN3xus for his [haobook](https://github.com/ParaN3xus/haobook) which offers much inspiration of the rewriting of this template.

Also thanks the creators of the following packages

- @tingerrr: [hydra](https://github.com/tingerrr/hydra)
- @Leedehai: [physica](https://github.com/Leedehai/typst-physics)
- @Dherse: [codly](https://github.com/Dherse/codly)
- @swaits: [codly-languages](https://github.com/swaits/typst-collection)
- @OrangeX4: [theorion](https://github.com/OrangeX4/typst-theorion)
