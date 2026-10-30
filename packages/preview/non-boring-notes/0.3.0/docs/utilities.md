# Utilities

[Back to README](../README.md)

Besides `template` and the [theorem-like environments](theorem-like-envs.md),
the package exports a handful of small helpers from
[`src/utils.typ`](../src/utils.typ). All of them are available through the
package entry point:

```typst
#import "@preview/non-boring-notes:0.3.0": *
```

This page documents **v0.3.0**.

## `indent`

```typst
#indent(body)
```

Narrows a block to 90% width and adds a 1.5em inset on the left. It is meant for
digressions, side remarks, or secondary explanations that should stand apart from
the main flow without becoming a colored box.

```typst
#indent[
  This paragraph is narrower and pushed to the right. It reads as an aside
  rather than as part of the main argument.
]
```

`indent` takes content, so it can contain several paragraphs, lists, or
equations.

## `quote-box`

```typst
#quote-box(body)
```

A light gray block with a thick left border. It is useful for quotations,
excerpts, or short passages that should not be mistaken for your own prose.

```typst
#quote-box[
  The purpose of computing is insight, not numbers.
]
```

The function also accepts a `cite` argument, but it is currently unused and does
not render anything.

## `horizontalrule`

```typst
#horizontalrule(color: gray, dashed: false)
```

A full-width horizontal line, 1pt thick.

```typst
#horizontalrule()

#horizontalrule(color: blue, dashed: true)
```

`color` accepts any Typst color value, such as `blue`, `rgb("#0f766e")`, or
`gray`. The dashed variant uses a dot-and-dash pattern.

## `maketitle`

```typst
#maketitle(title, subtitle: "", position: center)
```

A small manual title block: a 22pt bold title with an optional 13pt italic
subtitle. It is intended for documents that do not use `template` or
`minimal_template`, or for adding a second title inside a document.

```typst
#maketitle(
  [Solutions to the Midterm],
  subtitle: [Course 101],
  position: left,
)
```

`position` accepts an alignment such as `center`, `left`, or `right`.

## `mathbox`

```typst
#mathbox(content, higher: false)
```

Draws a thin border around a piece of math. It is handy for boxing a final
result or a formula that should stand out from the surrounding derivation.

```typst
#align(center)[
  #mathbox($ sum_(i=1)^n i = frac(n (n + 1), 2) $)
]
```

Set `higher: true` to use display math and add more vertical clearance, which is
useful for fractions, integrals, and limits:

```typst
#align(center)[
  #mathbox(
    $ integral_0^1 frac(x^2, 1 + x^4) dif x $,
    higher: true,
  )
]
```

## `mathnote`

```typst
#mathnote(content)
```

A centered note in parentheses, usually placed directly under an equation.

```typst
$ e^(i pi) + 1 = 0 $

#mathnote[Euler's identity]
```

## `smash`

```typst
#smash(body, side: center)
```

An advanced helper for labels that should hang off the edge of a formula. It
places script-size content in a zero-width box, so the annotation does not take
up horizontal space or shift the equation. `side` controls the direction in
which the content grows (`left`, `center`, or `right`).

```typst
f(x) = x^2 #smash("parabola", side: right) $
```

Because the box has zero width, the annotation can overlap neighboring material.
Use it deliberately, typically at the end of a formula or in display math.

## `minimal_template`

```typst
#minimal_template(
  title: "",
  subtitle: "",
  text_lang: "en",
  text_font: (...),
  code_font: (...),
  math_font: (...),
  font_size: 11.5pt,
  list_numbering: "1.a.i.",
  paragraph_indent: 1em,
  body,
)
```

A lightweight document setup for assignments and short notes. It styles fonts,
theorem-like environments, lists, and paragraphs, but does not add a page
header, table of contents, author list, abstract, dates, or bibliography. See
the [template reference](template.md#minimal-template) for the full description.

## Bundled packages

The package entry point also re-exports three drawing and typesetting packages,
so you can use them without separate imports:

| Package | What is exported | Version |
| :--- | :--- | :--- |
| [fletcher](https://typst.app/universe/package/fletcher) | `diagram`, `edge`, `node` | 0.5.8 |
| [cetz](https://typst.app/universe/package/cetz) | the `cetz` module | 0.5.2 |
| [unify](https://typst.app/universe/package/unify) | all public functions (`num`, `qty`, `numrange`, `qtyrange`, ...) | 0.8.1 |

### Fletcher diagrams

`diagram`, `edge`, and `node` are available directly:

```typst
#align(center)[
  #diagram(
    node((0, 0), $X$, radius: 2em),
    node((2, 0), $Y$, radius: 2em),
    edge((0, 0), (2, 0), [f], "->", bend: 20deg),
    edge((0, 0), (2, 0), [g], "->", bend: -20deg),
  )
]
```

### CeTZ drawings

The whole `cetz` module is re-exported, so `cetz.canvas` and its libraries are
available under the `cetz` namespace:

```typst
#cetz.canvas({
  import cetz.draw: *
  line((0, 0), (2, 1))
  circle((1, 1), radius: 0.5)
})
```

See the [CeTZ manual](https://cetz-package.github.io/docs) for the drawing API.

### Unify numbers and units

All public `unify` functions are imported:

```typst
num("-1.32865 +- 0.50273e-6") $

qty("1.3 + 1.2 - 0.3e3", "erg/cm^2/s") $
```

See the [unify documentation](https://typst.app/universe/package/unify) for
number ranges, units, prefixes, and custom units.

## See also

- [Template reference](template.md)
- [Theorem-like environments](theorem-like-envs.md)
- [Examples showcase](../examples/showcase.typ)
