# based-schemes

`based-schemes` is a [Typst](https://typst.app) package that lets you use 
[Base16](https://github.com/tinted-theming/home/blob/main/styling.md) and
[Base24](https://github.com/tinted-theming/base24) schemes in your documents.

```typ
#import "@preview/based-schemes:0.1.0": scheme

#let palette = scheme("scheme.yaml")
#page(
  fill: palette.base00.rgb.full,
  [
    #set text(fill: palette.base05.rgb.full)
    = #palette.scheme
    By: #palette.author
    #table(
      columns: (1fr,2fr)*4,
      stroke: palette.base05.rgb.full,
      ..for color in palette.keys().filter(it => it.contains("base")) {
        (table.cell(color),
        table.cell("", fill: palette.at(color).rgb.full))
      }
    )
  ]
)
```

There are also many aliases for colors to make using colors easier.
Example: `red` is an alias for `base08`.

## Caveats

- Only able to read from a file
- Does not support [Tinted8](https://github.com/tinted-theming/home/blob/main/specs/tinted8/styling.md)
- Rather leniant parsing (although this may be a good thing in some cases)
- The code kinda sucks

## FAQ

### Why?

I recently switched to Base24 from [Catppuccin](http://catppuccin.com/), and
I maintain [Asciimplicity](https://tangled.hashcube.dev/asciimplicity) which
uses Catppuccin's Typst modules to generate Steam Grids. Naturally, I wanted
to start using my Base24 palette there. Unfortunately, there was no Base24
package for Typst. Fortunately, I am good enough at Typst to write a Base24
package myself. So that's exactly what I did.

### Does this support legacy Base16 files?

Yes! It actually supports using the legacy Base16 format with Base24 keys

### Will this ever support Tinted8?

Probably not. From what I can tell, Tinted8 is vastly different than Base16
and Base24, which were the main foci, so there probably won't be Tinted8 support
in this repo. Unless there is some way to translate from Tinted8 to Base24, I
personally won't add it. If you see some way to add support in a way that is
works with Base24, feel free to send a PR.

### Why `palette.baseXX.rgb.full`?

I tried to follow the Base24 builder spec as close as possible,
and it has the individual RGB colors accessible. Unfortunately,
you cannot get the indiviual RGB Values from an RGB object (afaik.
send a PR if this is wrong), so unfortunately we have to do this
rather silly workaround
