# polymath

A Typst package for the Renaissance man. Write like Montaigne, typeset math like Axler — structured boxes for theorems, proofs, definitions, conjectures, essays, and notes.

## Usage

```typst
#import "@preview/polymath:0.1.0": *

#show: template

#header(
  name: "Your Name",
  course: "Math 110 — Linear Algebra",
  hw: "3",
  date: "March 4, 2026",
  professor: "Prof. Smith",
)

#qs(title: [Prove that the additive identity is unique.])[
  #prf[
    Suppose $0$ and $0'$ are both identities. Then $0 = 0 + 0' = 0'$.
  ]
]
```

See [`example.typ`](example.typ) for a full working document.

## Functions

### Setup

| Function | Description |
|----------|-------------|
| `template` | Apply page, text, and math styling. Use with `#show: template`. |
| `header(name?, course?, hw?, date?, professor?, topic?)` | Page header with horizontal rule. |

### Problem layer

| Function | Description |
|----------|-------------|
| `qs(title?)[ ]` | Numbered question: **1.**, **2.**, … |
| `ex(num?, loc?)[ ]` | Exercise with optional number and location. `#ex(num: 3, loc: [section 2.1])` → *Exercise 3, section 2.1* |
| `eg(title?)[ ]` | Example box. |
| `pt(title?)[ ]` | Lettered part: **a.**, **b.**, …; nests to **i.**, **ii.**, … |
| `ans[ ]` | Answer / solution block. |

### Knowledge layer

| Function | Description |
|----------|-------------|
| `defn(title?)[ ]` | Definition — yellow. |
| `notn(title?)[ ]` | Notation — yellow. |
| `axiom(title?)[ ]` | Axiom — yellow. |
| `postulate(title?)[ ]` | Postulate — yellow. |
| `thm(title?)[ ]` | Theorem — blue. |
| `lemma(title?)[ ]` | Lemma — blue. |
| `prop(title?)[ ]` | Proposition — blue. |
| `cor(title?)[ ]` | Corollary — blue. |
| `conj(title?)[ ]` | Conjecture — amber (unproven). |
| `prf[ ]` | Proof block with flush-right QED mark — green. |
| `note[ ]` | Remark with blue left rule. |

### Essay / Montaigne layer

| Function | Description |
|----------|-------------|
| `aside[ ]` | Tangential digression with grey left rule. |
| `epigraph(attribution?)[ ]` | Centered opening quote, italic, with optional attribution. |
| `blockquote(attribution?)[ ]` | Left-ruled block quote with optional attribution. |

## License

MIT
