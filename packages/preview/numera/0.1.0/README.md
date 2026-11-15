# numera

Numera adds flexible figure and equation numbering to Typst. It supports numbering by chapter or heading, subfigures, different styles on numbered elements and in references, and compatibility with the Equate package.

Requires Typst 0.15.0 or newer.

## Quick start

Import `numera`, apply its show rule, and use `heading-dependent` wherever a counter should include the current heading:

```typst
#import "@preview/numera:0.1.0": heading-dependent, normal-figure, numera

#let level = 1
#show: numera(level: level)

#set heading(numbering: "1.1")
#set math.equation(numbering: heading-dependent(level, "1"))
#show normal-figure: set figure(numbering: heading-dependent(level, "1"))

= Introduction

$ E = m c^2 $ <energy>

#figure([A result], caption: [A numbered figure]) <result>

See @energy and @result.
```

Here, `level: 1` resets the equation and figure counters at every level-one heading, producing numbers such as `1.1` and `1.2`. Set `level: 0` if you prefer document-wide counters without a heading prefix.

## API overview

Numera can format a number differently on the numbered element and in a reference. Its numbering functions receive a named `ref` argument: `false` for the element itself and `true` for a reference.

For all available functions and parameters, build the API reference in [`docs.typ`](docs.typ). It is generated from the source comments with [Tidy](https://typst.app/universe/package/tidy/):

```bash
typst compile --package-path "$PWD/packages" docs.typ
```

Building the reference also runs its documentation tests and checks that every parameter is documented. CI builds it as part of the test suite. Like the examples, `docs.typ` uses the normal `@preview/numera:0.1.0` import.

| Function | Purpose |
| --- | --- |
| `numera(level: 0)` | Installs the counter resets, subfigure handling, and reference rendering. Apply it with `#show: numera(level: ...)`. |
| `heading-dependent(max-level, numbering, separator: ".", heading-format: "reference")` | Prefixes a numbering with the current heading counter, truncated to `max-level`. |
| `ref-dependent(inline-numbering, ref-numbering)` | Uses one numbering on the element and another in references. |
| `subfigure-dependent(subfigure-numbering, figure-numbering: none)` | Selects numbering for subfigures and, optionally, normal figures. It does not add the parent figure number. |
| `subfigure-counter-dependent(subfigure-numbering, figure-numbering: none)` | Selects figure or subfigure numbering and prepends the parent figure counter to subfigures. Pass `figure-numbering: auto` to reuse the subfigure pattern for normal figures. |
| `concat(..numberings)` | Concatenates multiple Numera numbering functions into one numbering. |
| `non-ref(string)` | Emits `string` on the numbered element and nothing in references. Useful for inline-only punctuation. |
| `ref-only(string)` | Emits `string` only in references. |

For example, this renders equation numbers with parentheses on the equation but without them in references:

```typst
#import "@preview/numera:0.1.0": concat, heading-dependent, non-ref, numera

#show: numera(level: 1)
#set heading(numbering: "1")
#set math.equation(numbering: concat(
  non-ref("("),
  heading-dependent(1, "1"),
  non-ref(")"),
))
```

### Heading punctuation

With `#set heading(numbering: "1.")`, choose the heading's reference format
when embedding its number in figures or equations:

```typst
#show normal-figure: set figure(numbering: heading-dependent(
  level,
  "1",
  heading-format: "reference",
))
```

Headings retain their trailing dot, while figure captions and references use
numbers such as `2.1`. Put the joining dot in `separator` (which defaults to
`"."`), rather than passing `".1"` as the figure pattern. The element pattern
still controls its own decoration: `"(1)"` produces `2.(1)` on the element and
`2.1` in references.

The default `heading-format: "reference"` uses the heading's reference numbering.
Use `heading-format: "display"` to preserve heading punctuation on numbered
elements while trimming it in references. For custom heading numbering
functions, `"reference"` passes `ref: true`.

### Subfigure supplements

Numera resets the subfigure counter for each normal figure. Subfigures keep
their configured supplement; they do not automatically inherit the parent
figure's supplement. Since `"subfigure"` is a custom Typst figure kind, specify
its supplement explicitly:

```typst
#import "@preview/numera:0.1.0": numera, subfigure-counter-dependent

#show: numera()
#show figure.where(kind: "subfigure"): set figure(
  supplement: [Figure],
  numbering: subfigure-counter-dependent("1a"),
)

#figure(
  [#figure([A panel], caption: [First panel], kind: "subfigure") <panel>],
  caption: [A grouped figure],
) <group>

See @panel and @group.
```

The filtered show-set rule gives subfigures the supplement `Figure`.
Change it to `[Panel]` to use a different subfigure supplement.
Use `supplement: none` for captions and references without a supplement.
A supplement passed directly to a figure takes precedence over these rules.

## Examples

The examples below cover the most common setups:

- [Equate](./tests/example-equate/test.typ)
- [Equate with sub-numbering](./tests/example-equate-sub-numbering/test.typ)
- [Per-heading numbering](./tests/example-per-heading-level-1-numbering/test.typ)
- [Per-heading subfigures](./tests/example-per-heading-subfigures/test.typ)
- [Involved Equate compatibility](./tests/involved-example-compatibility-equate/test.typ)

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development setup, testing, and release instructions.
