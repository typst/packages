# touying-quick

A quick-start slide template based on touying for academic reports.

## Get Started

Import `touying-quick` from the `@preview` namespace.

```typst
#import "@preview/touying-quick:0.2.0": *
#show: touying-quick.with(
  title: "",
  subtilte: none,
  // following arguments are optional
  // author-size: 14pt,
  // footer-size: 14pt,
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

## Clone Official Repository

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
