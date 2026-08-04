# theoframe

A lightweight and easy-to-use [Typst](https://typst.app/) package that provides beautifully styled theorem-like environments for academic writing. It offers `Definition`, `Postulate`, `Assumption`, `Conjecture`, `Proposition`, `Lemma`, `Proof`, `Theorem`, `Corollary`, `Example`, `Problem`, `Solution`, and `Conclusion` blocks with automatic numbering, customizable colors, and multi-language support.

## Basic Usage

To use, simply import the package:

```typst
#import "@preview/theoframe:0.2.0": *
#show: reset
```

# Example

**Note on numbering:** The `theorems-counter` resets to `0` only when a level-1 heading (`= Heading`) is encountered. Each time a theorem-like environment (e.g., `#definition`, `#theorem`) is called, the counter increments by `1` and is displayed as a letter starting from `"a"`.

```typst
#import "@preview/theoframe:0.2.0":*
#show: reset

#set page(width: 210mm, height: auto, margin: 1cm)
#set heading(numbering: "1.1")
#show heading: set text(fill: rgb("#040404"))

= Preliminaries
#lorem(20)

#definition(name: "Even Integer")[
  An integer $n$ is called *even* if it is divisible by $2$, i.e., there exists an integer $k$ such that $n = 2k$.
]<def:even>

#definition(name: "Odd Integer")[
  An integer $n$ is called *odd* if it is not divisible by $2$, i.e., there exists an integer $k$ such that $n = 2k + 1$.
]<def:odd>

= Main Results
#lorem(20)

#theorem(name: "Sum of Two Even Integers")[
  The sum of any two even integers is even.
]<thm:sum-even>

#proof(name: "Proof of @thm:sum-even")[
  Let $a$ and $b$ be two even integers. By @def:even, there exist integers $k$ and $m$ such that $a = 2k$ and $b = 2m$. Then
  $a + b = 2k + 2m = 2(k + m)$,
  which shows that $a + b$ is divisible by $2$, hence even by @def:even.
]<pf:sum-even>

#corollary(name: "Sum of Multiple Even Integers")[
  The sum of any finite number of even integers is even.
]<cor:sum-multiple>

#proof[
  This follows directly from @thm:sum-even by induction on the number of terms.
]

= Additional Examples
#lorem(20)

#example(name: "Concrete Even Numbers")[
  The integers $4$, $10$, and $16$ are even since $4 = 2 times 2$, $10 = 2 times 5$, and $16 = 2 times 8$.
]<ex:even-numbers>

#problem(name: "Sum of Two Odd Integers")[
  Show that the sum of two odd integers is even.
]<prob:sum-odd>

#solution(name: "Solution to @prob:sum-odd")[
  Let $a$ and $b$ be odd integers. By @def:odd, there exist integers $k$ and $m$ such that $a = 2k + 1$ and $b = 2m + 1$. Then
  $a + b = (2k + 1) + (2m + 1) = 2k + 2m + 2 = 2(k + m + 1)$,
  which is even by @def:even.
]<sol:sum-odd>

```

<p align="center">
  <img src="./assets/example1.svg" alt="Example of theorem-like environments including Definition and Theorem with colored headers and borders.">
</p>

# Outline for theorems

```typst
#show outline: it => {
  show heading: set text(fill: rgb("#000000"))
  it
}

#outline(title:"Definitions", target: figure.where(kind:"Definition"))
#outline(title:"Theorems", target: figure.where(kind:"Theorem"))
#outline(title:"Corollaries", target: figure.where(kind:"Corollary"))
```
<p align="center">
  <img src="./assets/example2.svg" alt="Example of theorem-like environments including Definition and Theorem with colored headers and borders.">
</p>

# Customization

Each environment accepts a `color` parameter to customize its appearance:

```typst
#definition(name:"prime number",color: rgb("#005eff"))[ A natural number is called a _prime number_ if it is greater than 1 and cannot be written as the product of two smaller natural numbers. ]
```

<p align="center">
  <img src="./assets/customization1.svg" alt="Customizing a theorem frame with a custom blue color for the left border and header background.">
</p>

The `color` affects both the left border stroke and the header background tint. The content area uses a lighter transparent variant of the same color.

# Changelog

## Version: 0.1.0

- Initial release with thirteen theorem-like environments: `Definition`, `Postulate`, `Assumption`, `Conjecture`, `Proposition`, `Lemma`, `Proof`, `Theorem`, `Corollary`, `Example`, `Problem`, `Solution`, and `Conclusion`.
- Auto-numbering counters tied to level-1 headings for organized referencing.
- Customizable frame colors per environment.
- Multi-language support: English, French, Korean, Japanese, and Chinese.

## Version: 0.2.0

- Add: Cross-reference support.
- Fix: Counter not resetting when encountering a level-1 heading (= heading).
- Root Cause Analysis: In Typst, #import only brings in variable bindings (functions and variables defined with #let) from a module. Meanwhile, #show rules are document-level directives, meaning their scope is strictly confined to the module where they are defined.