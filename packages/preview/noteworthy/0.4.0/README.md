# Noteworthy

Noteworthy is a Typst template designed for creating class notes, especially for mathematics. This 
template provides a structured and visually appealing format for documenting mathematical concepts, 
theorems, proofs, and examples.

---

## Features

- Customizable document metadata (title, author, date, contact details, and more)
- Automatic table of contents generation
- Support for various mathematical environments (theorems, proofs, definitions, examples, notes, exercises, solutions, and more)
- Configurable page settings (header, footer, paper size)
- Customizable text settings (font, size, language)

---

## Installation

You can use this template in the Typst web app by clicking "Start from template" on the dashboard
and searching for noteworthy.

Alternatively, you can use the CLI to kick this project off using the command:

```bash
typst init @preview/noteworthy:0.4.0
```

---

## Usage

1. Open the `main.typ` file and customize the content as needed.
2. Run the Typst compiler to generate the PDF:
```bash
typst compile main.typ
```

---

## Configuration

Noteworthy provides the following configuration options:

| Configuration Option | Purpose | Default Value | Optional |
|---|---|---|---|
| `paper-size` | Sets page size for layout and printing. | `"a4"` | Yes |
| `font` | Sets the primary font for your document. You may set any font available in your system. | `"New Computer Modern"` | Yes |
| `language` | Controls localization and hyphenation rules. | `"EN"` | Yes* |
| `title` | Sets the title of the document. | `none` | No |
| `header-title` | If the title is long, this shorter version is used in the header of each page (except the first one). | `none` | Yes |
| `date` | Controls the date displayed in the header of each page (except the first one). If absent, the current system date is used. | `none` | Yes |
| `author` | Sets the author name. | `none` | No |
| `contact-details` | Sets the contact details of the author. It may be a website URL or a phone number. | `none` | Yes |
| `toc-title` | Sets the Table of Contents title. | `"Table of Contents"` | Yes |
| `toc-depth` | Sets the Table of Contents depth. Recommended value is `2` | `none` | Yes |
| `watermark` | Sets the watermark text. | `none` | Yes |

---

## Environments

This template provides built-in environments via the [theoretic](https://github.com/nleanba/typst-theoretic) package.

See the sample code below for usage.

```typst
#algorithm[
  Step-by-step procedure to compute the shortest path
  in a weighted graph.
]

#axiom[
  Through any two distinct points, there exists exactly
  one straight line.
]

#claim[
  This statement follows directly from the previous lemma.
]

#corollary[
  Every continuous function on a closed interval
  attains a maximum.
]

#counter-example[
  This function is differentiable but not continuously differentiable.
]

#definition[
  A prime number is a natural number greater than 1
  that has no positive divisors other than 1 and itself.
]

#example[
  The number 7 is a prime number.
]

#exercise(
  solution: [
    Substitute the given values and simplify the equation
    to obtain the final result.
  ]
)[
  Solve the equation $2x + 5 = 17$.
]

#lemma[
  The sum of two even integers is always even.
]

#note[
  Remember to check boundary conditions when applying
  this theorem.
]

#proof[
  Assume the opposite and derive a contradiction
  to complete the proof.
]

#proposition[
  The product of two rational numbers is rational.
]

#remark[
  This result can be extended to higher dimensions.
]

#theorem(title: "Pythagoras Theorem")[
  For a right-angled triangle:
  $a^2 + b^2 = c^2$
]
```

---

## Acknowledgements

- [Typst](https://typst.app/)
- [theoretic](https://github.com/nleanba/typst-theoretic)
- [Showybox](https://github.com/Pablo-Gonzalez-Calderon/showybox-package)