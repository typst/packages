# homework-template

A minimal Typst package for math homework with styled boxes for questions, parts, answers, proofs, definitions, and theorems.

## Usage

```typst
#import "@preview/homework-template:0.1.0": *

#header(
  name: "Your Name",
  course: "Math 110 — Linear Algebra",
  hw: "3",
  date: "March 4, 2026",
  professor: "Prof. Smith",   // optional
)

#qs(title: [Prove that the additive identity is unique.])[
  #pt(title: [Uniqueness of zero])[
    #prf[
      Suppose $0$ and $0'$ are both identities. Then $0 = 0 + 0' = 0'$.
    ]
  ]
]
```

See [`example.typ`](example.typ) for a full working document.

## Functions

| Function | Description |
|----------|-------------|
| `header(name, course, hw, date, professor?, topic?)` | Page header with rule |
| `qs(title?)[ ]` | Numbered question box |
| `pt(title?)[ ]` | Lettered part (a., b., …); nests to i., ii., … |
| `ans[ ]` | Answer/solution block |
| `prf[ ]` | Proof block with flush-right QED mark |
| `defn(title?)[ ]` | Definition box |
| `thm(title?)[ ]` | Theorem box |
| `eg(title?)[ ]` | Example box |
| `notn(title?)[ ]` | Notation box |
| `note[ ]` | Left-ruled remark |
| `vc(sym)` | Vector arrow shorthand: `vc(v)` → $\vec{v}$ |

## License

MIT
