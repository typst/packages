# v-utils

Presets for writing math notes: math shorthands and functions, auto-generated hierarchical heading labels, and markdown-style sugar.

```typst
#import "@preview/v-utils:0.4.0": *
#show: prelude

= Ex I
== 1.
=== a)
$x ..= 2$ -- see @ex-i.1.a

> quoted, [with a link](https://typst.app)
```

## Installation (nix)

Outside Typst Universe, [v_flakes](https://github.com/valeratrades/v_flakes)' typ module vendors it from source:

```nix
inputs.typ_utils = { url = "github:valeratrades/typ_utils?ref=v0.4.0"; flake = false; };

typ = v_flakes.typ { inherit pkgs; src = ./.; extraPackages = [ typ_utils ]; };
```

## Presets

### `prelude(doc, img: none)` - `lib.typ`
Everything below, plus auto-generated hierarchical heading labels (`= Ex I` / `== 1.` / `=== a)` → `@ex-i.1.a`) and a trailing blank page.

### `math-notes-prelude(doc)` - `math.typ`
Math shorthands, breakable equations, multi-line inline math on its first row's baseline. Custom math functions live in the same file.
Notation lints from `style.typ` render the offending math in red, e.g. a relation's point written above it (`in^0` instead of `in_0`).

### `md-parity-prelude(doc, img: none)` - `md.typ`
Markdown-style sugar: `> ` quotes, `---` rules, `[label](url)` links, `![alt](path)` images (needs `img: p => image(p)`).

### `html-paper(template, style: auto, ..args, body)` - `html.typ`
HTML export for a paper template (e.g. `charged-ieee`), whose floated title block and run-in headings HTML export drops: emits `<h1>` title, authors, and `<h2>`..`<h6>` numbered headings on the HTML target; paged output is the template's own. `style`: `auto` for the bundled `paper.css` (one reading measure, follows `prefers-color-scheme`), a css string, or `none`.

```typst
#show: html-paper.with(ieee, title: [..], authors: (..), abstract: [..])
```

### `framed(body)` - `html.typ`
Renders `body` (cetz, plots) to inline SVG on the HTML target, as-is on paged.

## Scripts

[`scripts/list_titles.py FILE.typ...`](https://github.com/valeratrades/typ_utils/blob/v0.4.0/scripts/list_titles.py): show rules can't tell a newline from a space, so this rewrites source in place: a list item's first line gets a trailing `\` when indented content follows it, keeping the title on its own line.

## License

MIT, see [LICENSE](LICENSE).
