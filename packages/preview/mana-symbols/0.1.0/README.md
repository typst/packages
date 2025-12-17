# Mana Symbols
This package allows you to display [Magic the Gathering][wp:mtg] [mana symbols][mw:ms] in Typst documents.

# Usage
This library exports a single function, `mana`, which allows you to display mana symbols. First you import it:
```typ
#import "@preview/mana-symbols:0.1.0": mana
```

then you write `#mana[X]`, where `X` is the sequence of mana symbols.

# Examples

| Mana type                             | Typst code                |
| ------------------------------------- | ------------------------- |
| Green                                 | `mana[g]`                 |
| Green or white hybrid                 | `mana[g/w]`               |
| 5 generic and 1 blue                  | `mana[5u]`                |
| 5 generic or blue hybrid              | `mana[5/u]`               |
| Cost of [Ajani, Sleeper Agent][ajani] | `mana[1g{g/w/p}w]`        |
| Red and snow                          | `mana[rs]`                |
| Snow and red                          | `mana([sr], sort: false)` |

# Options
`mana` has a number of options:
- `sort`: for consecutive mana symbols, should they become sorted. (default: true)
- `normalize_hybrid`: for hybrid mana symbols, should they be normalized, i.e. should the halves be sorted. (default: true)
- `shadow`: whether to draw drop-shadows (default: true)
- `size`: size of the mana symbols. (default: 1em)

[wp:mtg]: https://en.wikipedia.org/wiki/Magic:_The_Gathering
[mw:ms]:  https://mtg.wiki/page/Numbers_and_symbols#Mana_symbols
[ajani]:  https://scryfall.com/card/dmu/192/ajani-sleeper-agent