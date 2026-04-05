#import "./lib.typ": karnaugh


#set text(font: "Kabel", weight: "bold")
#show raw: set text(weight: "regular")
#show math.equation: set text(font: "New Computer Modern Math")

#align(center)[
  = Samples of Karnaugh–Veitch Maps
]

#let descriptions = (
  "Fig. 1. Map of an incompletely specified function",
  "Fig. 2. Zeros are not ignored",
  "Fig. 3. Crossing implicant"
)

#set figure(supplement: none)

#let samples = (
  ```
  import "./lib.typ": karnaugh
  let x = -1
  karnaugh(("AB", "CD"),  // Labels in string
    implicants: (
      // (x, y, length/width, optional height)
      (1, 1, 2),
      (2, 0, 2)
    ),
    (
      // Any number that is neither 0 or 1 will
      // be treated as don't-care.
      (0, 0, 0, x),
      (0, 1, x, 0),
      (1, 1, 1, 0),
      (x, 1, 0, x),
    )
  )
  ```,
  ```
  import "./lib.typ": karnaugh
  karnaugh(("C", "AB"),
    implicants: (
      (0, 1, 1, 2),
      (1, 2, 2, 1),
    ),
    (
      (0, 1, 0, 0),
      (0, 1, 1, 1),
    ),
    // Allow zero to appear
    show-zero: true
  )
  ```,
  ```
  import "./lib.typ": karnaugh
  karnaugh(
    (
      // Labels in math mode
      ($I_2$,), ($I_1$, $I_0$)
    ),
    implicants: (
      // `(0, 3, 2)` moves outside the frame
      // but will come back
      (0, 3, 2),
      (1, 0, 4, 1),
    ),
    (
      (1, 0, 0, 1),
      (1, 1, 1, 1),
    )
  )
  ```
)

#for i in range(samples.len()) [
  #grid(
    columns: (1fr, auto),
    align: horizon,
    raw(lang: "typc", samples.at(i).text.split("\n").slice(1).join("\n")),
    figure(
      eval(samples.at(i).text),
      caption: descriptions.at(i)
    )
  )
]
