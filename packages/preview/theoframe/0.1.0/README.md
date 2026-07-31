# theoframe

A lightweight and easy-to-use [Typst](https://typst.app/) package that provides beautifully styled theorem-like environments for academic writing. It offers `Definition`, `Lemma`, `Proof`, `Theorem`, and `Example` blocks with automatic numbering, customizable colors, and multi-language support.


## Basic Usage

To use, simply import the package:

```typst
#import "@preview/theoframe:0.1.0": *
```

# Example

```typst
#import "@preview/theoframe:0.1.0": *

#set page(height:auto, margin: 2em)
#set heading(numbering: "1.1")
#show heading: set text(fill: rgb(0, 0, 200))

= #lorem(1)
#lorem(20)
#Definition(name: [Definition name])[#lorem(20) $1 = 1$]
#Lemma(name: [Lemma name])[#lorem(20)$1 = 1$]
#Proof(name: [Proof name])[#lorem(20)$2 < 3$]
#Theorem(name: [Theorem name])[#lorem(20)$1 = 1$]
#Example(name: [Example name])[#lorem(20)$2 < 3$]
== #lorem(3)
#lorem(20)
#Definition(name: [Definition name])[#lorem(20) $1 = 1$]
= #lorem(1)
#lorem(20)
#Theorem(name: [Theorem name])[#lorem(20)$1 = 1$]

```

![](./assets/example1.png)

# Customization

Each environment accepts a `color` parameter to customize its appearance:

```typst
#Theorem(name: [Pythagorean theorem], color: rgb("#005eff"))[
  $a^2 + b^2 = c^2$
]
```
![](./assets/customization1.png)

The `color` affects both the left border stroke and the header background tint. The content area uses a lighter transparent variant of the same color.


# Changelog

## Version: 0.1.0

- Initial release with five theorem-like environments: `Definition`, `Lemma`, `Proof`, `Theorem`, and `Example`.
- Auto-numbering counters tied to level-1 headings for organized referencing.
- Customizable frame colors per environment.
- Multi-language support: English, French, Korean, Japanese, and Chinese.