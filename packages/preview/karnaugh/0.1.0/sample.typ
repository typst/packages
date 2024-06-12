#import "./lib.typ": karnaugh


#set text(font: "New Computer Modern")
#show math.equation: set text(font: "New Computer Modern Math")

=== Samples

#let descriptions = (
  "Karnaugh map with don’t-care",
  "Zeros are not ignored",
  "Crossing implicant"
)

#let samples = (
  ```
  import "./lib.typ": karnaugh
  let x = -1
  karnaugh(("CD", "AB"),  // Labels in string
    implicants: (
      // (x, y, length/width, optional height)
      (0, 1, 2),
      (1, 0, 2),
      (2, 2, 2),
    ),
    (
      // Any number that is neither 0 or 1 will
      // be treated as don't-care.
      (0, 1, x, 0),
      (1, x, 1, 0),
      (1, 1, x, 1),
      (0, 0, 1, x),
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
