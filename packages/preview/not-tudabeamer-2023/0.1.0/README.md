# not-tudabeamer-2023

A [touying](https://github.com/touying-typ/touying) presentation template matching the TU Darmstadt Beamer Template 2023.

## Usage

Install Roboto font for your system or download them from https://github.com/googlefonts/roboto/releases/download/v2.138/roboto-unhinted.zip.

Run `typst init @preview/not-tudabeamer-2023:0.1.0`

Download https://download.hrz.tu-darmstadt.de/protected/ULB/tuda_logo.pdf.

Run `pdf2svg tuda_logo.pdf tuda_logo.svg` or convert to `.svg` using e.g. Inkscape.

### Examples

```typst
#import "@preview/not-tudabeamer-2023:0.1.0": *

#show: not-tudabeamer-2023-theme.with(
  config-info(
    title: [Title],
    short-title: [Title],
    subtitle: [Subtitle],
    author: "Author",
    short-author: "Author",
    date: datetime.today(),
    department: [Department],
    institute: [Institute],
    logo: text(fallback: true, size: 0.75in, emoji.cat.face)
    //logo: image("tuda_logo.svg", height: 100%)
  )
)

#title-slide()

#outline-slide()

= Section

== Subsection

- Some text
```

## Development

This template currently only follows the TU Darmstadt Beamer template in spirit but not pixel-perfect. As the PowerPoint template uses non-free fonts a goal of this project is to more closely match the LaTeX TU Darmstadt Beamer 2023 template. Pull requests to improve this are really welcome.

```
mkdir -p ~/.cache/typst/packages/preview/not-tudabeamer-2023
ln -s $PWD ~/.cache/typst/packages/preview/not-tudabeamer-2023/0.1.0
```