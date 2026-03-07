# bidi-flow

Automatic RTL/LTR direction detection for mixed-direction Typst documents.

Sets `text.dir` per block using the **first strong character** rule — the same heuristic used by most editors and the Unicode Bidi Algorithm. No manual tagging needed for most content.

## Import

```typst
// Published package import
#import "@preview/bidi-flow:0.1.1": *
```

## Quick start

```typst
#import "@preview/bidi-flow:0.1.1": *
#show: bidi-flow

= Hello        // → LTR heading
= שלום         // → RTL heading automatically

English paragraph here.

פסקה בעברית מופיעה אוטומטית מימין לשמאל.

- English list
- items here

- רשימה בעברית
- מוצגת מימין לשמאל
```

![Example output](assets/image.png)

## API

### `bidi-flow`

Document-level show rule. Detects direction for `par`, `heading`, `list`, `enum`, and `table` automatically.

```typst
#show: bidi-flow
```

### `detect-dir(body)`

Inspect a content block and return its detected direction (`ltr` or `rtl`).
Useful for building your own show rules or templates.

```typst
let d = detect-dir(heading.body)
// d == rtl  or  d == ltr
set text(dir: d)
```

### Fonts

Choosing fonts for multilingual documents can be tedious, so `bidi-flow`
provides a small high-level API for script-aware font selection.

```typst
#show: bidi-flow.with(
  latin-font: "New Computer Modern",
  hebrew-font: "Noto Serif Hebrew",
  font: "Libertinus Serif",
)
```

In this example, Latin text uses _New Computer Modern_ and Hebrew text uses
_Noto Serif Hebrew_. The `font` argument acts as the generic fallback or base
font for scripts that were not explicitly overridden and for any missing glyphs.

If you do not pass any font arguments, Typst's default font resolution is used.
Passing only `font` applies it as the document's base font. When both `font`
and script-specific overrides are present, the script-specific fonts win for
their matching codepoints.

### Inline spans — `#rl[...]` / `#lr[...]`

Force direction for a mixed-direction fragment:

```typst
The price is #rl[₪ 100] today.       // force RTL around the price
בסוף המשפט יש מילה #lr[inline] כך.  // force LTR inside Hebrew
```

### Directional seeds — `#r` / `#l`

Zero-width invisible characters that seed the bidi shaping context.
Useful for fixing punctuation and number alignment in mixed runs:

```typst
המחיר הוא 100 #r ₪     // nudge shekel sign to correct side
```

## Local installation

```sh
mkdir -p ~/.local/share/typst/packages/local/bidi-flow/0.1.1
cp -r . ~/.local/share/typst/packages/local/bidi-flow/0.1.1/
```

Then import with `@local/bidi-flow:0.1.1`.

## Notes

- Requires Typst ≥ 0.14.0
- Direction detection ignores `math.equation` and `raw` blocks
- Works with `strong`, `emph`, `link`, and other inline wrappers
- `#r` / `#l` are content values, not functions — do not call them with brackets

## Changes in 0.1.1 (Non-Breaking)

- Added optional font overrides to `bidi-flow` (existing usage continues to work unchanged):
  - `font`
  - `latin-font`
  - `arab-font`
  - `hebrew-font`

## Repository

See [original source repository](https://github.com/manemajef/bidi-flow)
