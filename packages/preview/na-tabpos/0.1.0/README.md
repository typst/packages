# na-tabpos

English · [العربية](#العربية)
## Documentation / التوثيق

You can read the full documentation files here:
* English: [English Documentation](documentationEN.typ)
* Arabic: [التوثيق باللغة العربية](documentationAR.typ)
## English

`na-tabpos` is a Typst package (Typst ≥ 0.13) for math documents, Arabic ones in particular. It is built on [vartable](https://typst.app/universe/package/vartable) by Le_Foucheur and adds **one thing**: a *relative-position* row (curve vs line, or curve vs curve) with the two arcs at each intersection, like `\tkzTabPos`.

Everything else is vartable: sign rows, variation rows, hatched undefined areas, `"||"` bars, `"0"` bars, added values, styles… See the vartable documentation for the full syntax; it is unchanged.

The code in `lib.typ` is derived from vartable 0.2.5 (MIT). The `LICENSE` file carries both copyrights.

**Examples:**
- [`all-cases.typ`](all-cases.typ)
- [`custom-names.typ`](custom-names.typ)
### Main features

- The **difference row** `f(x) - g(x)` (a sign row placed right before a `"p"` row) is **1 cm high by default**. Change it with `diff-height`, or write `diff-height: none` for automatic height.
- The words of the `"p"` row **follow the language of the document** (`#set text(lang: ...)`): ar, fr, en, es, de, it, pt, nl, tr, ru. Any other language uses English. You can give your own words.
- The whole package is **one file**: `lib.typ`.

### Row types in `label`

| Type | Meaning |
|------|---------|
| `"s"` | sign row. The **difference row** `f(x) - g(x)` is just a sign row. |
| `"v"` | variation row |
| `"p"` | **relative-position row** (new) |

### Usage

```typst
#import "@preview/na-tabpos:0.1.0": *

#tabpos(
  variable: $x$,
  label: (
    ([$f(x) - y$], "s"),        // difference row: 1 cm
    ([الوضع النسبي], "p"),
  ),
  domain: ($-oo$, $-1$, $1$, $+oo$),
  contents: (
    ($+$, ("0", $-$), ("0", $+$)),
    ("+", ($A(-1 ; 0)$, "-"), ($B(1 ; 0)$, "+")),
  ),
)
