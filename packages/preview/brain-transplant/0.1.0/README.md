# <img src="./assets/logo.svg" alt="The logo of the package, which features a minimalist icon of a brain with < on the left hemisphere and > on the right, in a turquoise square" width="48px" /> <span style="font-variant: small-caps; color: #239dad">Brain transplant</span>: A Brainfuck-to-Typst transpiler written in Typst

[![Package on the Typst Universe](https://img.shields.io/badge/Typst_Universe-fdfdfd?logo=typst)](https://typst.app/universe/package/brain-transplant)
[![Git repository](https://img.shields.io/badge/%F0%9F%91%BE%20Git_repo-fdfdfd)](https://app.radicle.xyz/nodes/seed.radicle.garden/rad:z3bYXx6FurPtAURke7sUV8ktrtFNt)
[![A precompiled PDF file of the manual](https://img.shields.io/badge/%F0%9F%93%96%20manual-.pdf-239dad?labelColor=fdfdfd)](./docs/manual.pdf)
[![Licence: MIT-0](https://img.shields.io/badge/licence-MIT0-239dad?labelColor=fdfdfd)](./LICENSE)

This package provides a Brainfuck-to-Typst transpiler.
Let’s unpack this mouthful gibberish.
_Brainfuck_ is a minimalist esoteric programming language that consists of only eight simple instructions yet is Turing-complete (which essentially  means everything computable by a fully-fledged language on a computer is in principle computable by it and vice versa).
A _transpiler_ is a program that translates a program given in a certain programming language to an equivalent program in another language.
In our case the package takes a program written in Brainfuck and translates it into Typst code, which can then be displayed or run (evaluated); for example:

```typ
#import "@preview/brain-transplant:0.1.0": *

#raw(brain-transplant("+++++++[->,.<]", input: "Hi Mom!", evaluate: true))
```

The output is:

```
Hi Mom!
```

All this has no real practical use, but it’s very amusing (mindbogglingly so even 🤯) if you’re into programming, minimalism, recreational and artistic use of math and technology, formal rules, meta and the like.

## 📖 The manual

Using <span style="font-variant: small-caps; color: #239dad">brain transplant</span> is quite straightforward.
A [**comprehensive manual**](./docs/manual.pdf) covers:

- Introductory background.
- How to use the provided function (`brain-transplant()`).
- Example Brainfuck programs and their outputs.

## 📦 Other Typst packages by me

I really like Typst, its structure, its community and the freedom and accessibility it brings to writing packages (compared to LaTeX). Another package I wrote is:

- 🗼 [<span style="font-variant: small-caps; color: #239dad">Babel</span>](https://typst.app/universe/package/babel): Redact text by replacing it with random characters
