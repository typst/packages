# Theorem-like environments

[Back to README](../README.md)

The package exports 16 pre-styled environments for definitions, theorems,
proofs, exercises, and notes. Fifteen are color-coded boxes; `proof` is an
unboxed variant. The boxes are built on
[`ctheorems`](https://typst.app/universe/package/ctheorems) and
[`showybox`](https://typst.app/universe/package/showybox), and can break across
pages.

This page documents **v0.3.0**. All environments are exported by the package
entry point, so a single `#import "@preview/non-boring-notes:0.3.0": *` is enough.

## Quick example

```typst
#import "@preview/non-boring-notes:0.3.0": *

#show: template.with(title: [Real Analysis])

= Metric spaces

#definition("Metric space")[
  A metric space is a set $M$ together with a metric $d: M times M -> RR$.
] <def-metric>

#theorem("Banach fixed-point theorem")[
  Let $(X, d)$ be a complete metric space and $T: X -> X$ a contraction.
  Then $T$ has a unique fixed point.
]

#proof[
  The proof proceeds by iterating $T$ from any starting point.
]

By @def-metric, every convergent sequence is Cauchy.
```

- The first positional argument is an optional **name**. It is printed in
  parentheses after the environment label, for example
  `Theorem 1.1.1 (Banach fixed-point theorem).`
- The body is passed in square brackets.
- A label placed after the closing bracket (`<def-metric>`) makes the box
  referenceable with `@def-metric`.
- Omitting the name is valid: `#exercise[...]` prints `Exercise 1.1.1.` without a
  parenthetical name.

## Available environments

| Environment | Printed label | Color | Numbered |
| :--- | :--- | :--- | :--- |
| `theorem` | Theorem | purple `#9a77cf` | yes |
| `lemma` | Lemma | purple `#9a77cf` | yes |
| `corollary` | Corollary | purple `#9a77cf` | yes |
| `proposition` | Proposition | purple `#9a77cf` | yes |
| `hypothesis` | Hypothesis | pink `#ff71ce` | yes |
| `definition` | Definition | blue `#118dc3` | yes |
| `question` | Question | blue `#118dc3` | yes |
| `example` | Example | green `#1da912` | yes |
| `note` | Note | yellow `#eea825` | yes |
| `attention` | Attention | red `#e05661` | yes |
| `important` | Important | red `#e05661` | yes |
| `exercise` | Exercise | orange `#ee9025` | yes |
| `solution` | Solution | cyan `#56b6c2` | no |
| `tip` | Tip | pink `#ff71ce` | no |
| `remark` | Remark | gray `#9b9fa6` | no |
| `proof` | Proof. | no frame | no |

All numbered boxes have their own counter. Two theorems in the same section
become `1.1.1` and `1.1.2`, while the first definition in that section is
`1.1.1` again.

## Numbering

Numbered environments use the current heading levels followed by their own
counter:

- under `Lecture 1` and `Section 1.1`, the first definition is
  `Definition 1.1.1`;
- directly under `Lecture 1`, with no subsection, an exercise is
  `Exercise 1.1`;
- a new subsection resets the environment counter, so the first theorem in
  section 1.2 is `Theorem 1.2.1`.

The numbering is independent of the `show_numbering` option. Setting
`show_numbering: false` hides heading numbers but theorem-like boxes keep their
heading-based numbers.

Numbering depends on heading counters. `minimal_template` keeps headings
unnumbered but still advances those counters, so its boxes number normally. If
you build a document without `template` or `minimal_template`, either number
your headings or step the heading counter yourself. See the
[template reference](template.md#minimal-template).

In 0.3.0 the numbering is fixed per environment: there is no per-call
`numbered: false` switch. Use the unnumbered environments (`solution`, `tip`,
`remark`, `proof`) when a number is not wanted.

## The theorem family

These four share the purple color and are numbered:

```typst
#theorem("Pythagoras")[
  In a right triangle, $a^2 + b^2 = c^2$.
]

#lemma[
  A useful intermediate result.
]

#corollary("Area formula")[
  The area of a circle is $pi r^2$.
]

#proposition[
  A statement that is proved alongside the main theorem.
]
```

Use `lemma` and `corollary` for supporting results, and `proposition` for
standalone statements that are less central than a theorem.

## Definitions, examples, and questions

These are blue (`definition`, `question`) or green (`example`):

```typst
#definition("Continuous function")[
  A function $f: RR -> RR$ is continuous at $a$ if
  $ lim_(x -> a) f(x) = f(a) $.
] <def-continuous>

#example[
  Every polynomial is continuous at every point.
]

#question[
  Is every continuous function differentiable?
]
```

`question` is useful for open-ended prompts in exercise sheets. `example` is
numbered, unlike many theorem templates where examples are unnumbered.

## Notes, warnings, and hypotheses

These use yellow (`note`), red (`attention`, `important`), or pink
(`hypothesis`):

```typst
#note[
  The proof of @def-continuous is left as an exercise.
]

#important("Do not forget")[
  Check the domain before applying the theorem.
]

#attention[
  This operation is not commutative.
]

#hypothesis[
  Assume the sample is drawn from a normal distribution.
]
```

`attention` and `important` are visually similar and share a color. Use
`attention` for hazards and `important` for results or instructions that must not
be missed. `hypothesis` is intended for assumptions in proofs or experiments.

## Exercises and solutions

Exercises are orange and numbered; solutions are cyan and unnumbered:

```typst
#exercise[
  Compute $integral_0^1 x^n dif x$ for $n >= 0$.
] <ex-integral>

#solution[
  $ integral_0^1 x^n dif x = 1/(n + 1) $ for $n >= 0$.
]
```

A common pattern is to put the solution after the exercise, or on a separate
page with a page break. Because `solution` is unnumbered, it does not disturb the
exercise counter.

## Tips and remarks

Tips are pink and remarks are gray. Both are unnumbered:

```typst
#tip[
  Substitute $u = 1 - x$ before integrating by parts.
]

#remark[
  The converse of @def-continuous is false in general.
]
```

## Proofs

`proof` is not a colored box. It prints an italic "Proof." label, the body, and
a right-aligned QED symbol:

```typst
#proof[
  Let $epsilon > 0$. Choose $delta = epsilon / 2$. Then ...
]
```

Proofs are unnumbered and can break across pages. The QED symbol is pushed to the
right edge of the proof's last line.

## References and labels

Place a label immediately after the closing bracket to reference the box later:

```typst
#definition("Compact set")[
  A set is compact if every open cover has a finite subcover.
] <def-compact>

A compact set is closed; see @def-compact.
```

`@def-compact` renders as `Definition 1.1.1` (the label plus the number, without
the optional name).

## Colors and customization

In 0.3.0 the palette is fixed in [`src/boxes.typ`](../src/boxes.typ):

| Name | Hex |
| :--- | :--- |
| purple | `#9a77cf` |
| pink | `#ff71ce` |
| blue | `#118dc3` |
| cyan | `#56b6c2` |
| green | `#1da912` |
| orange | `#ee9025` |
| yellow | `#eea825` |
| red | `#e05661` |
| gray | `#9b9fa6` |

The `accent` option of `template` does **not** change these colors; it only
affects the page header, links, and the header rule. There is no public option
to recolor an individual environment in 0.3.0. `box_thm`, the internal helper
that builds the boxes, is not exported from the package entry point. If you need
a different palette, change the color constants in `src/boxes.typ` in a local
copy of the template.

## See also

- [Template reference](template.md)
- [Utilities](utilities.md)
- [Examples showcase](../examples/showcase.typ)
