#import "@preview/lacy-ubc-math-project:0.1.0": *
// Import the common content.
#import "common.typ": *
#show: setup.with(
  number: 1,
  flavor: [A],
  group: group-name,
  authors.jane-doe,
  // If you just want all authors, instead write:
  // ..authors.values(),
)

// Here is your project content.
= The Problem

#question(5)[
  Hey, there's a cool math problem, let's solve it!
  // Encapsulate important visuals in figures,
  // so that they can be referenced later.
  #figure(
    // Include images from the assets folder.
    image(
      "assets/madeline-math.jpg",
      width: 80%,
      height: 25%,
      fit: "stretch",
    ),
    // Description.
    // Don't forget to give credit while using others' work.
    caption: [
      Madeline's math problem (image credit: #link("https://example.com")[Badeline]).
    ],
  )

  #solution[
    You can do it.
  ]
]

There is also a #link("https://github.com/lace-wing/lacy-ubc-math-project")[manual] for this project.

