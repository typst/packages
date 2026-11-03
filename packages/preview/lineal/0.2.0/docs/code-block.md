# Code blocks and file labels

`code-block` renders selectable source text with a filename header, syntax
highlighting, line numbers and optional emphasis. It works inside a Lineal slide
or an ordinary Typst document. Existing calls with a positional source string and
`filename`, `language` or `theme` options continue to work.

```typst
#import "@preview/lineal:0.2.0": code-block

#code-block(
  read("counter.svelte"),
  filename: "components/counter.svelte",
  start-line: 20,
  emphasize: (22, (25, 27)),
  caption: [The input and derived label share the same state.],
)
```

## Common settings

| Option | Default | Purpose |
| --- | --- | --- |
| `filename` | `"app.py"` | Display the path and infer the syntax language. |
| `language` | `auto` | Override inference with a Typst language tag or familiar alias such as `"typescript"`. |
| `style` | `"dark"` | Use `"dark"`, `"light"`, or a complete custom palette. |
| `theme` | `auto` | Select the style's bundled syntax theme, disable colouring with `none`, or supply a tmTheme file. |
| `size`, `font` | `12pt`, `"DejaVu Sans Mono"` | Source typography. The default code font ships with Typst. |
| `body-font` | `none` | Header and caption font; `none` inherits the document font. |
| `width` | `100%` | An absolute or container-relative width, including `100% - 12pt`. |
| `height` | `none` | Fix the panel height to align neighbouring examples. |
| `max-height` | `none` | Limit the combined height of the panel and caption. |
| `show-header` | `true` | Hide filename chrome for compact comparison rows. Syntax inference still uses `filename`. |
| `line-numbers` | `true` | Show one number per original logical source line. |
| `start-line` | `1` | Set the first displayed source number. |
| `emphasize` | `()` | Highlight displayed line numbers or inclusive `(first, last)` ranges. |
| `wrap` | `true` | Wrap at natural text breakpoints while retaining the original line number. |
| `caption` | `none` | Supporting content below the panel. |

Additional controls are `padding: 12pt`, `line-gap: 0pt`, `radius: 7pt`,
`header-size: 10.5pt`, `caption-size: 11pt`, `caption-fill: auto` and
`tab-size: 2`. Caption colour inherits the surrounding text unless overridden.

The component measures content before applying a fixed height. Source that does
not fit raises an actionable error; it is never silently clipped or reduced to a
smaller font. An unbreakable token wider than the source column fails even with
wrapping enabled. Captions participate in `max-height` checks.

Source strings retain indentation, interior blank lines and spaces. CRLF becomes
LF, and only initial or final newline characters are trimmed. Highlighting uses
native Typst raw text, so source remains selectable in exported PDFs.

## Compact comparisons

Use the same explicit height in both columns. No manual source padding or blank
lines are needed to align panel bottoms.

```typst
#grid(columns: (1fr, 1fr), gutter: 16pt,
  code-block(
    "const label = useMemo(() => `${count}`, [count]);",
    filename: "counter.tsx", show-header: false, height: 90pt,
  ),
  code-block(
    "const label = $derived(`${count}`);",
    filename: "counter.svelte.ts", show-header: false, height: 90pt,
  ),
)
```

## Light and custom themes

`style: "light"` selects a matching light syntax theme and surface palette.
`theme: none` disables syntax colouring without removing the header or emphasis.

For a custom syntax theme, pass bytes read in your document. This preserves the
location of your asset when importing Lineal as a package:

```typst
#code-block(
  read("example.ts"), filename: "example.ts",
  theme: read("assets/my-theme.tmTheme", encoding: none),
)
```

Theme paths remain accepted for compatibility with native `raw` options. Byte
input avoids ambiguity over a relative path's base directory.

A custom surface palette has seven semantic colour roles. With `theme: auto`, a
custom palette renders source in its `ink` colour. Supply `theme` explicitly when
you also want syntax colouring.

```typst
#let green = (
  ground: rgb("#eaf2ee"), raised: rgb("#f7fbf9"),
  ink: rgb("#173f34"), muted: rgb("#527365"),
  wire: rgb("#b9d2c7"), accent: rgb("#006b4b"),
  "accent-text": rgb("#00543b"),
)
#code-block("let ready = true;", filename: "state.ts", style: green)
```

## File icons and labels

These helpers can be used in diagrams, headers, file lists and comparison tables.

```typst
#import "@preview/lineal:0.2.0": file-icon, file-label

#file-icon("state.svelte.ts", size: 18pt)
#file-label("src/routes/+layout.server.ts", size: 15pt)
```

`file-icon(filename, size: 14pt, tint: ...)` uses local SVG assets. `.svelte`
uses orange, `.svelte.ts` uses TypeScript blue, `.tsx`/`.jsx` use the React mark,
and `.ts` uses the TypeScript mark. Other files use a generic icon in the requested
tint. `file-label` distinguishes the directory from the basename and accepts
`size`, `icon-size`, `font`, `fill`, `muted` and `gap` options. Its font inherits
the document unless specified.

Svelte syntax includes markup, directives, runes, embedded TypeScript and CSS.
Multiline strings, comments and template interpolation retain their scope across
lines. The grammars provide lexical highlighting, not type checking. Other common
languages use Typst's bundled syntax definitions.

## Checks and assets

Compile `tests/code-block.typ` to inspect named styles, custom colours, wrapping,
multiline syntax, icons, captions, start numbers and headerless panels.
`tests/code-block-errors.typ` exercises explicit failure conditions with
`--input case=height`, `range`, `nowrap` and the other cases listed in that file.

All themes and syntax definitions are bundled and require no network requests.
The Lineal themes and grammars use this project's MIT licence. SVG asset origins,
exact commits and their CC0 or ISC licences are recorded under
`src/static/icons/code/`.
