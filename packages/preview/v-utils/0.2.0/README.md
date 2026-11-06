# v-utils

Presets for writing math notes: math shorthands and functions, auto-generated hierarchical heading labels, and markdown-style sugar.

```typst
#import "@preview/v-utils:0.2.0": *
#show: prelude

= Ex I
== 1.
=== a)
$x ..= 2$ -- see @ex-i.1.a

> quoted, [with a link](https://typst.app)
```

## Presets

### `prelude(doc, img: none)` - `lib.typ`
Everything below, plus auto-generated hierarchical heading labels (`= Ex I` / `== 1.` / `=== a)` → `@ex-i.1.a`) and a trailing blank page.

### `math_notes_prelude(doc)` - `math.typ`
Math shorthands, breakable equations, multi-line inline math on its first row's baseline. Custom math functions live in the same file.

### `md_parity_prelude(doc, img: none)` - `md.typ`
Markdown-style sugar: `> ` quotes, `---` rules, `[label](url)` links, `![alt](path)` images (needs `img: p => image(p)`).

## Scripts

[`scripts/list_titles.py FILE.typ...`](https://github.com/valeratrades/typ_utils/blob/v0.2.0/scripts/list_titles.py): show rules can't tell a newline from a space, so this rewrites source in place: a list item's first line gets a trailing `\` when indented content follows it, keeping the title on its own line.

## License

MIT, see [LICENSE](LICENSE).
