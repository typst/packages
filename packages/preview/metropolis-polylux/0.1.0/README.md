![Polylux logo](https://raw.githubusercontent.com/polylux-typ/polylux/ed1e70e74f2a525e80ace9144249c9537917731c/assets/polylux-logo.svg)

# Metropolis

A template for creating presentation slides with Typst and
[Polylux](https://github.com/polylux-typ/polylux/).

![thumbnail](thumbnail.png)


Use via
```sh
typst init @preview/metropolis-polylux your-cool-project
```

A `slides.typ` file will be created for you that you can directly edit and get
going.

At the top of the gnerated `slides.typ`, you will find the line
```typ
#show: metropolis.setup
```
which you can edit to configure the template with the following options:
```typ
#show: metropolis.setup.with(
  text-font: "Fira Sans",
  math-font: "Fira Math",
  code-font: "Fira Code",
  text-size: 23pt,
  footer: [My cool footer], // defaults to none
)
```
All of them are optional and the default values are shown above.

## Special syntax

Most of the template should be self explanatory but two things might be a bit
surprising:

Slide titles are created using level-one headings (`= A Slide Title`).
Headings of other levels are not affected.
A slide without such a level-one heading will not have a title.

Emphasized text (created like `_this_`) is not shown in italics but in a bright
color (in the original LaTeX version of Metropolis, you would use `\alert` for
this).

## Fonts

By default, the template uses the fonts
[Fira Sans](https://bboxtype.com/typefaces/FiraSans),
[Fira Math](https://github.com/firamath/firamath/releases),
and
[Fira Code](https://github.com/tonsky/FiraCode/releases).
Either make sure you have them installed or specify other fonts in the template.

## About

This theme is inspired by https://github.com/matze/mtheme

The Polylux-port was originally performed by https://github.com/Enivex

