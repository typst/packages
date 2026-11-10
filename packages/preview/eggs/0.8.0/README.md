# Typeset linguistic examples with the Simplest Syntax possible

This is a [Typst](https://github.com/typst/typst) package that provides linguistic examples and interlinear glossing. It is a heavily modified fork of [neunenak's typst-leipzig-glossing](https://github.com/neunenak/typst-leipzig-glossing).

See it on [Typst Universe](https://typst.app/universe/package/eggs).

## Usage

Below is an example of how to typeset an example.

```typst
#import "@preview/eggs:0.8.0": *
#import abbreviations: pl, ins
#show: eggs

#example[
  + - primer   s     gloss-ami
    - example  with  gloss-#pl.#ins
    'an/the example with glosses' #ex-label(<gl>)
  + \*example without glosses
  #ex-label(<pex>)
]
```

<img src="assets/example.svg" alt="an example with subexamples and glosses" width="450"/>

### Basics

Start with applying the global show rule. The central function is `example`, which typesets an example. Inside it, auto-numbered lists (`+`) are treated as subexamples, and bullet lists (`-`) as interlinear gloss lines. **Words in glosses must be separated by two or more spaces**.

This automatic conversion can be toggled off by passing `auto-subexamples: false` and `auto-glosses: false` to `example`, like this:

```typst
#example(auto-subexamples: false, auto-glosses: false)[
  + This is a proper numbered item
  - And this is a proper bullet item
]
```

Additionally, `subexample` explicitly typesets a subexample and `gloss` explicitly typesets glosses.

### Numbering

Examples are numbered following [a counter](https://typst.app/docs/reference/introspection/counter/) `counter("eggsample")`. Individual exceptions to the numbering can be made by passing `number: ` to `example` or `subexample`.

### Labels and refs

Examples (and subexamples) can be labeled by putting `#ex-label(<label-name>)` somewhere inside them or passing a `label: <label-name>` argument. Automatic codly-style labels are added to subexamples, too.

References are clever, bracketed and with support for two-example references via supplements. `ex-ref` is even more powerful.

```typst
@gl[@pex:b] // (1a-b)
#ex-ref(<gl>, <pex:b>) // same
#ex-ref(left: "e.g. ", <pex>, right: " etc.") // (e.g. 1 etc.)
#ex-ref(1) // (2) --- relative numbering like expex's nextx
```

### Misc stuff

Common judges are recognized automatically. `judge` typesets text without taking up space.

The `abbreviations` submodule provides `leipzig`-style abbreviation commands. They are kept track of and can be printed with `print-abbreviations`.

Customization is done via the global show rule: `#show eggs.with()`.

### More stuff

See [documentation.pdf](documentation.pdf) for more info.

