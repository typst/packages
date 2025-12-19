# exercism

A Typst package to organise exercises and defer their solutions.

## Example usage

See the [manual](https://github.com/mkorje/typst-exercism/releases/download/v1.0.0/manual.pdf) for more details.

```typ
#import "@preview/exercism:1.0.0"

#show ref: exercism.show-ref

#let exercise = exercism.new(
  "exercise",
  supplement: [Exercise],
)

#exercise[Fermat's Last Theorem][
  Prove that $x^n + y^n = z^n$, where $n >= 3$, has no non-trivial solutions $x, y, z in ZZ$.
][
  The truly marvelous proof of this is unable to be contained within this small document.
] <fermat>

See @fermat.

#context exercism.questions("exercise", (
  body,
  supplement,
  number,
  title,
  _,
) => {
  let title = if title != none [(#title)] else []
  block[
    *#supplement #number.* #title
    #body
  ]
})

#exercise[
  Do you love Typst?
][
  Yes!
]

#context exercism.solutions("exercise", (body, _, number, _, _) => {
  block[
    *Exercise #number.*
    #body
  ]
})
```

![example](https://github.com/user-attachments/assets/95efbaa2-8c93-421f-80af-c2a045065dbf)
