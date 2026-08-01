# theoframe

A lightweight and easy-to-use [Typst](https://typst.app/) package that provides beautifully styled theorem-like environments for academic writing. It offers `Definition`, `Postulate`, `Assumption`, `Conjecture`, `Proposition`, `Lemma`, `Proof`, `Theorem`, `Corollary`, `Example`, `Problem`, `Solution`, and `Conclusion` blocks with automatic numbering, customizable colors, and multi-language support.

## Basic Usage

To use, simply import the package:

```typst
#import "@preview/theoframe:0.2.0": *
#show: reset
```

# Example

```typst
#import "@preview/theoframe:0.2.0":*
#show: reset

#set page(width: 210mm, height: auto, margin: 1cm)
#set heading(numbering: "1.1")
#show heading: set text(fill: rgb(0, 0, 200))

#outline()

= Basic Definitions
#lorem(20)
#definition("even number")[An integer is called an _even number_ if it is divisible by $2$.]

== More Definitions
#lorem(20)
#definition("odd number")[An integer is called an _odd number_ if it is not divisible by $2$.]

= A Simple Proof
#lorem(20)
#proof("sum of two even numbers")[Let $a$ and $b$ be two even numbers. Then $a = 2k$ and $b = 2m$ for some integers $k$ and $m$. Their sum is $a + b = 2k + 2m = 2(k + m)$, which is also even.]

= A Practice Problem
#lorem(20)
#problem("sum of odd numbers")[Prove that the sum of two odd numbers is always even.]

== Solution
#lorem(20)
#solution("sum of odd numbers")[Let $a$ and $b$ be two odd numbers. Then $a = 2k + 1$ and $b = 2m + 1$ for some integers $k$ and $m$. Their sum is $a + b = (2k + 1) + (2m + 1) = 2k + 2m + 2 = 2(k + m + 1)$, which is even.]

== Worked Example
#lorem(20)
#example("checking even numbers")[Consider the numbers $4$ and $10$. Both are even because $4 = 2 times 2$ and $10 = 2 times 5$. Their sum is $14$, and indeed $14 = 2 times 7$, so it is also even.]

```

<p align="center">
  <img src="./assets/example1.svg" alt="Example of theorem-like environments including Definition and Theorem with colored headers and borders.">
</p>

# Customization

Each environment accepts a `color` parameter to customize its appearance:

```typst
#definition("prime number",color: rgb("#005eff"))[ A natural number is called a _prime number_ if it is greater than 1 and cannot be written as the product of two smaller natural numbers. ]
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

- Fix: Counter not resetting when encountering a level-1 heading (= heading).
- Root Cause Analysis: In Typst, #import only brings in variable bindings (functions and variables defined with #let) from a module. Meanwhile, #show rules are document-level directives, meaning their scope is strictly confined to the module where they are defined.
