# Typeset linguistic examples with the Simplest Syntax possible

This is a [Typst](https://github.com/typst/typst) package that provides linguistic examples and interlinear glossing. It is a heavily modified fork of [neunenak's typst-leipzig-glossing](https://github.com/neunenak/typst-leipzig-glossing).

## Usage

Below is an example of how to typeset an example.

```typst
#import "@preview/eggs:0.1.0": *
#import abbreviations: pl, ins
#show: eggs

#example[
  + - primer   s     gloss-ami
    - example  with  gloss-#pl.#ins
    'an/the example with glosses' #ex-label(<gl>)
  + #judge[\*]example without glosses
  #ex-label(<pex>)
]
```

<img src="https://github.com/retroflexivity/typst-eggs/blob/main/assets/example.svg" alt="an example with subexamples and glosses" width="450"/>

### Basic

Start with applying the global show rule. The central function is `#example()`, which typesets an example. Inside it, numbered lists are treated as subexamples, and bullet lists — as glosses. Separate words in glosses with **two or more** spaces.

This automatic conversion can be toggled off by passing `auto-subexamples: false` and `auto-glosses: false` to `example`, like this:

```typst
#example(auto-subexamples: false, auto-glosses: false)[
  + This is a proper numbered item
  - And this is a proper bullet item
]
```

Additionally, `#subexample()` typesets a subexample and `#gloss()` typesets glosses.

### Labels and refs

Examples (and subexamples) can be labeled by putting `#ex-label(<label-name>)` somewhere inside them or passing a `label: <label-name>` argument. Automatic codly-style labels are added to subexamples, too.

For cool smart references, use `#ex-ref()` (`ref` and `@`-refs work too, though).

```typst
#ex-ref(<pex:a>, <gl>) // (1a-b)
#ex-ref(left: "e.g. ", <pex>, right: "etc.") // (e.g. 1 etc.)
#ex-ref(1) // (2) --- relative numbering like expex's nextx
```

### Misc stuff

`#judge()` typesets text without taking up space.

The `abbreviations` submodule provides `leipzig`-style abbreviation commands. They are kept track of and can be printed with `#print-abbreviations()`

Customization is done via the global show rule: `#show eggs.with()`.

See [documentation.pdf](https://github.com/retroflexivity/typst-eggs/blob/main/documentation.pdf) for more info.
