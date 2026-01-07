# Theoretic

> Opinionated tool to typeset theorems, lemmas and such

Example Usage:
```typ
  #import "@preview/theoretic:0.3.0"
  #import theoretic.presets.basic: * // this will automatically load predefined styled environments
  #show ref: theoretic.show-ref      // this is necessary for references to theorems to work

  // Example Usage:
  #theorem(<label>)[Title][Body]
  #theorem(label: <label>, title: [Title], [Body]) // this is equivalent to the above

  #proposition(variant: "important")[This proposition has a frame around it!]
  #proof[...]
  #example[...]
  // ..etc

```

## Features: Overview
- It is easy to create single-use variants of environments, as all parameters can be changed on use.
  (All configuration is achieved via parameters on the `theorem` function, the presets are only preset pramaters.)
  - There are multiple preset styles available, and it should be easy to add your own.
- Automatic QED placement!
  - Even if the proof ends with a list or a block equation, the QED will be perfectly aligned.
  - Nested proofs are supported.
  - You can add a suffix (e.g. `∎`) to any environment.
- Flexible References via specific supplements. E.g. a reference without the title using `@label[-]`; or one with only title and number using `@label[!!]`.
- Any theorem can be restated.
- Automatic numbering & ability to use anything as a number. (E.g. "Proposition F")
- Custom outlines: Outline for headings _and/or_ theorems.
  - Filter for specific kinds of theorem to create e.g. a list of definitions.
  - Optionally sorted alphabetically!
  - Theorems can have a different title for outlines and can even have multiple entries in a sorted outline.
- Exercise solutions


[Please see the PDF manual for more information][manual], e.g. on how to define your own styles and environments.

## Manual

[Full Manual →][manual]

[![first page of the documentation][manual-preview]][manual]


### Preset styles

[![Overview over preset styles][preset-preview]][manual]

## Feedback
Do you have questions or need help? [I may be able to help you in the Typst forum, feel free to `@nleanba` to get my attention.](https://forum.typst.app/)

Have you encountered a bug? [Please report it as an issue in my github repository.](https://github.com/nleanba/typst-theoretic/issues)
<small>(You are also welcome to add feature requests there, but I give no guarantees of implementing them.)</small>

Has this package been useful to you? [I am always happy when someone gives me a ~~sticker~~ star⭐](https://github.com/nleanba/typst-theoretic)



<!-- [manual]: https://github.com/nleanba/typst-theoretic/blob/main/main.pdf?raw=true
[manual-preview]: https://github.com/nleanba/typst-theoretic/raw/refs/heads/main/preview.svg
[preset-preview]: https://github.com/nleanba/typst-theoretic/raw/refs/heads/main/preset-preview.svg -->

[manual]: https://github.com/nleanba/typst-theoretic/blob/v0.3.0/main.pdf?raw=true
[manual-preview]: https://github.com/nleanba/typst-theoretic/raw/refs/tags/v0.3.0/preview.svg
[preset-preview]: https://github.com/nleanba/typst-theoretic/raw/refs/tags/v0.3.0/preset-preview.svg