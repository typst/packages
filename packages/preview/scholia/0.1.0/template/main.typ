#import "@preview/scholia:0.1.0": *

#show: scholia.with(
  // theme: "dark",   // light (default) | dark (slate)
  // prose: "book",   // notes (default, no indent) | book (first-line indent)
)

#cover(
  "Your Notebook",
  subtitle: "A one-line subtitle",
  author: "Your Name",
  date: "2026",
)

= First Course

#keyword[The big idea], in a sentence, before the machinery.

#note[
Intuition first: say what this is really about, in your own words. This layer is
written to be *read* — the formal layer below is written to be *filled*.
]

#definition[a term][
State the object, but leave the key clause blank: closed under #fillin(width: 2.5cm).
] <def:thing>

#theorem[attribution][source][
State the result in full; later you can refer back to @def:thing.
] <thm:main>

#proof[
Sketch the moves: (i) the first; (ii) the second. Leave the crux as
#TODO[the step that makes it work].
]

#example[a worked instance][
Show the computation once, so the reader has a model to imitate.
]

#yourturn[
Now restage the example as your own computation.
#workspace(n: 3)
]

#recall[A question to park in the margin.]
#remark[An aside that doesn't need a box.]
