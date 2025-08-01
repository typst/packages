# touying-quick

A quick-start slide template based on touying for academic reports.

## Get Started

Import `touying-quick` from the `@preview` namespace.

```typst
#import "@preview/touying-quick:0.2.1": *
#show: touying-quick.with(
  title: "",
  subtilte: none,
  // following arguments are optional
  // bgimg: none,
  // info: default-info,
  // styles: default-styles,
  // names: default-names,
  // lang: "en",
)
```

The toml file should look like this

```toml
[key-you-like]
    institution = "Your Institution"
    author = "Your Name"
    footer = "Some Info You Would Like to Show"
    ending = "Thanks for Your Attention"
    lang = "en"
```

![example](thumbnail.png)

## Tweaking the Params

### Names

touying-quick's section names support English and Chinese by default. If you are not neither English speaker nor Chinese speaker, assume you are a French speaker, you can create a toml like

```toml
[sections.fr]
    outline = "Contents"

[blocks.fr]
    algorithm = "Algorithme"
    table = "Tableau"
    figure = "Figure"
    equation = " Eq."
    rule = "Règle"
    law = "Loi"
```

after reading this file by `toml()`, assign its value to the argument `names` in function `touying-quick()`.

### Styles

If you are not satisfied with the default styles such as font-family, font-size, you can create a toml like

```toml
[fonts.en]
    title = "Palatino"
    author = "Times New Roman"
    footer = "Georgia"
    contents = "Georgia"
    context = "Georgia"
    math = "Times New Roman"
    ending = "Palatino"

[sizes]
    author = 14
    title = 40
    context = 10.5
    footer = 10
    ending = 50

[spaces]
    par-indent = 2
    par-leading = 1
    par-spacing = 1
    list-indent = 1.2
    block-above = 1
    block-below = 1
    contents-indent = 2
```

after reading this file by `toml()`, assign its value to the `styles` argument in function `touying-quick()`.

Don't forget to change the key `lang` in your info toml metioned above.

## Clone the Repository

Clone the [touying-quick](https://github.com/ivaquero/touying-quick) repository to your `@local` workspace:

- Linux：
  - `$XDG_DATA_HOME/typst/packages/local`
  - `~/.local/share/typst/packages/local`
- macOS：`~/Library/Application\ Support/typst/packages/local`
- Windows：`%APPDATA%/typst/packages/local`

Import `touying-quick` in the document

```typst
#import "@local/touying-quick:0.1.0": *
```

> For developement convinience, local repo never changes the version

## Credits

Thanks @OrangeX4 for his [touying](https://github.com/touying-typ) framework as well as his [theorion](https://github.com/OrangeX4/typst-theorion) package.

Also thanks the creators of the following packages

- @Dherse: [codly](https://github.com/Dherse/codly)
- @swaits: [codly-languages](https://github.com/swaits/typst-collection)
- @Leedehai: [physica](https://github.com/Leedehai/typst-physics)
