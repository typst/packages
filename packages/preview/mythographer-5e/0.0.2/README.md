# D&D 5e Typst Template

This is a Typst template for typsetting documents in the style of the fifth edition of Dungeon&Dragons.
This package has been heavily inspired by the awesome work done by the _rpgTex_ team on their [DND-5e-LaTeX-Template](https://github.com/rpgtex/DND-5e-LaTeX-Template).

## Features

- Color schemes, fonts, and layouts are close to the core books (2014, while 2025 style may be added in the future)

> [!NOTE]
> Fonts need to be installed on the system to be correctly used. Instructions are on the [template repo](github.com/sa1g/dnd-typst-template).

## Quick Start

Before you begin, make sure you have installed the Typst environment and the default fonts. If not, you can use the [Web App](https://typst.app/) or the [Tinymist LSP extension](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist) for VSCode.

```typst
#import "@preview/mythographer-5e:0.0.2": *
#show: dnd-template
```

A more comprehensive example can be found in `TheDarkTypst.typ` and in the documentation (`docs.typ`) where most of the core functionalities are covered.

## Languages

Multiple languages are supported using [transl](https://github.com/mayconfmelo/transl).
Languages are referred to by [ISO 639-1](https://en.wikipedia.org/wiki/ISO_639).
Translations are used to correctly typeset class names, spell levels, and other D&D specific terms. The template is designed to be easily extended to support new languages, so if you want to contribute a translation, feel free to open a PR.

| Supported Languages | Code |
| ------------------- | ---- |
| English             | `en` |
| Italian             | `it` |

## Custom Themes

The template supports custom themes, they can be easily setup by overriding the default config. An example can be found in `lib/config`, at the `toa-config`.

# Fonts

They can be found in [/fonts](https://github.com/sa1g/dnd-typst-template/tree/master/fonts) folder of the repository.

- [Tex Gyre Bonum](https://www.gust.org.pl/projects/e-foundry/tex-gyre)
- [Gillius ADF No2](https://ctan.org/tex-archive/fonts/gillius)
- [Royal Initialen](https://www.ctan.org/tex-archive/fonts/initials/)

# Possibly useful packages

- [meander](https://typst.app/universe/package/meander/): segment pages and wrap content around images

# Credits

- Background image (`img/paper.jpg`) from [Lost and Taken](https://lostandtaken.com/)
- Config injection inspired by [touying](https://github.com/touying-typ/touying)

# Similar Projects

- [Owlbear](https://typst.app/universe/package/owlbear/)
- [Dragonling](https://typst.app/universe/package/dragonling/)
- [wenyuan-campaign](https://typst.app/universe/package/wenyuan-campaign/)

## Not similar, but related projects

- [5e-spellbooks](https://codeberg.org/boondoc/5e-spellbooks): Generate PDF reference tables and lists of spell descriptions for spellcasting characters made for the fifth edition of “that” tabletop roleplaying game.

# Thanks

To all the people who contributed directly or indirectly to this project!

- @boondoc - providing some regex used in the monster parsing
