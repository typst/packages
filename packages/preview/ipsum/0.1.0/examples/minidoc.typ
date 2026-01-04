#import "@preview/ipsum:0.1.0": *

= Ipsum
_Create placeholder text to suit your design, layout and style._
#linebreak()
== Usage

#rect(width: 100%, inset: 1em, stroke: 0.1pt, radius: 4pt)[
  ```typ
  #import "@preview/ipsum:0.1.0": *
  #ipsum(/*args*/)
  ```
]
#linebreak()
== Need Help?
Turn on the `hint` to see a list of values you can change to tweak the generation style for each mode.

#rect(width: 100%, inset: 1em, stroke: 0.1pt, radius: 4pt)[
  #ipsum(mode: "natural", pars: 1, hint: true)
]
// #v(1em) #line(length: 100%, stroke: 0.5pt + gray) #v(1em)
#linebreak()
== Writing Styles

=== Natural
The default mode. Simulates the flow of human writing. It randomly alternates between standard, long, and short paragraphs.
#rect(width: 100%, inset: 1em, stroke: 0.1pt, radius: 4pt)[
  #rect(width: 100%, inset: 1em, stroke: 0.1pt, radius: 4pt)[
    ```typ
    #ipsum(mode: "natural", pars: 3, average: 40, var: 15)
    ```
  ]
  #ipsum(mode: "natural", pars: 3, average: 40, var: 15)
]
=== Dialogue
Generates a mix of narrative prose and spoken dialogue enclosed in quotation marks.
#rect(width: 100%, inset: 1em, stroke: 0.1pt, radius: 4pt)[
  #rect(width: 100%, inset: 1em, stroke: 0.1pt, radius: 4pt)[
    ```typ
    #ipsum(mode: "dialogue", events: 6, ratio: 0.9, seed: 3128)
    ```
  ]
  #ipsum(mode: "dialogue", events: 6, ratio: 0.9, seed: 3128)
]
// #v(1em) #line(length: 100%, stroke: 0.5pt + gray) #v(1em)
#linebreak()
== Structural Shapes and Patterns

=== Fade
Starts with a big paragraph and gets smaller and smaller. Great for testing visual flow.
#rect(width: 100%, inset: 1em, stroke: 0.1pt, radius: 4pt)[
  #rect(width: 100%, inset: 1em, stroke: 0.1pt, radius: 4pt)[
    ```typ
    #ipsum(mode: "fade", start: 60, pars: 8, ratio: 0.6)
    ```
  ]
  #ipsum(mode: "fade", start: 60, pars: 8, ratio: 0.6)
]

=== Grow
The opposite of a fade. Starts with a short sentence and slowly builds up into longer, denser blocks of text.
#rect(width: 100%, inset: 1em, stroke: 0.1pt, radius: 4pt)[
  #rect(width: 100%, inset: 1em, stroke: 0.1pt, radius: 4pt)[
    ```typ
    #ipsum(mode: "grow", pars: 4, base: 8, factor: 60)
    ```
  ]
  #ipsum(mode: "grow", pars: 4, base: 8, factor: 60)
]

=== Fit
Copywriting. Specify exactly how many words you need in total (e.g., 200 words), and it will be divided up across your paragraphs.
#rect(width: 100%, inset: 1em, stroke: 0.1pt, radius: 4pt)[
  #rect(width: 100%, inset: 1em, stroke: 0.1pt, radius: 4pt)[
    ```typ
    #ipsum(mode: "fit", total: 200, pars: 4, ratio: 0.8)
    ```
  ]
  #ipsum(mode: "fit", total: 200, pars: 4, ratio: 0.8)
]

=== Fibonacci
Generates paragraph lengths following the Fibonacci sequence ($1, 1, 2, 3, 5...$).
#rect(width: 100%, inset: 1em, stroke: 0.1pt, radius: 4pt)[
  #rect(width: 100%, inset: 1em, stroke: 0.1pt, radius: 4pt)[
    ```typ
    #ipsum(mode: "fibonacci", steps: 7, reverse: true, spacing: 0.5em, word-count: true)
    ```
  ]
  #ipsum(mode: "fibonacci", steps: 7, reverse: true, spacing: 0.5em, word-count: true)
]

// #v(1em) #line(length: 100%, stroke: 0.5pt + gray) #v(1em)
#linebreak()
== Safety & Validation

=== Example: Division by Zero
The `fit` mode cannot have a ratio of exactly 1.0.
#ipsum(mode: "fit", total: 300, pars: 4, ratio: 1.0)

=== Example: Negative Lengths
Preventing variability from exceeding average length.
#ipsum(mode: "natural", average: 20, var: 50)

=== Example: Invalid Parameter
#ipsum(mode: "dialogue", ratio: 1.5)

#linebreak()

== Statistics
If you need to know exactly how much text was generated, turn on `stats`. It gives you a clean breakdown at the bottom.
#rect(width: 100%, inset: 1em, stroke: 0.1pt, radius: 4pt)[
  #ipsum(mode: "natural", pars: 2, seed: 982389, stats: true)
]
