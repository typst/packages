#import "@preview/bamdone-rebuttal:0.1.0": *

// Configure text colors for points, responses, and new text
#let (point, response, new) = configure(
  point-color: blue.darken(30%),
  response-color: black,
  new-color: green.darken(30%)
)

// Setup the rebuttal
#show: rebuttal.with(
  authors: [First A. Author and Second B. Author],
  // date: ,
  // paper-size: ,
)

We thank the reviewers...
#lorem(60)
We hope it is now suitable for inclusion in...

#reviewer()
This reviewers' feedback was...

#point[
  There appears to be an error...
]<p1>

#response[
  #lorem(20).

  The revised text now reads:
  #quote[
    #lorem(10) #new[#lorem(2)].
  ]
]

#point[
  #lorem(10).
]

#response[
  See response to @pt-p1.
  Similar to the `i-figured` package, references to labeled `point`s must be prefixed by `pt-` as in `@pt-p1` which refers to the `point` labeled `<p1>`.
]

#reviewer()
We generally agree with this reviewer...

#point[
  Have you considered...
]

#response[
  We will address this in a future work...
]
