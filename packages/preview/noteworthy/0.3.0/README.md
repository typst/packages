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
typst init @preview/noteworthy:0.3.0
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

### `paper-size`

**Purpose:** It sets page size for layout and printing.
**Default:** `"a4"`
**Optional:** Yes

---

### `font`

**Purpose:** It sets the primary font for your document. You may set any font available in your system.
**Default:** `"New Computer Modern"`
**Optional:** Yes

---

### `language`

**Purpose:** Controls localization and hyphenation rules.
**Default:** `"EN"`
**Optional:** If the language is English, you don't need to set it explicitly.
Otherwise, it is recommended to set the language according to the
[typst documentation](https://typst.app/docs/reference/text/text/#parameters-lang)

---

### `title`

**Purpose:** It is the title of the document.
**Default:** `none`
**Optional:** No

---

### `header-title`

**Purpose:** If the `title` is long enough, you should set a shorter `header-title`. It
will be used at the header of each page (except the first one).
**Default:** `none`
**Optional:** Yes

---

### `date`

**Purpose:** It controls the date displayed at the header of each page (except the first one).
If it is absent, the current system date will be used.
**Default:** `none`
**Optional:** Yes

---

### `author`

**Purpose:** It sets the author name.
**Default:** `none`
**Optional:** No

---

### `contact-details`

**Purpose:** It sets the contact details of the author. It may be a website url or a phone number.
**Default:** `none`
**Optional:** Yes

---

### `toc-title`

**Purpose:** It sets the Table of Contents title.
**Default:** `"Table of Contents"`
**Optional:** Yes

---

### `watermark`

**Purpose:** It sets the watermark text.
**Default:** `none`
**Optional:** Yes

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