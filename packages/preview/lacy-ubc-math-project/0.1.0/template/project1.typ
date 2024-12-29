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
  Hey there's a cool math problem, let's solve it!
  // Encapsulate important visuals in figures,
  // so that they can be referenced later.
  #figure(
    // Include images from the assets folder.
    image(
      "assets/madeline-math.jpg",
      width: 90%,
      height: 30%,
      fit: "stretch",
    ),
    // Give descriptions and credits.
    caption: [
      #link("https://preview.redd.it/madeline-has-math-homework-v0-8eaw2g1k2p191.png?auto=webp&s=8bffecf0548fb5e0ddb39eceb3e3cd933f5997c7")["Madeline has math homework"]
      (#link("https://www.reddit.com/r/celestegame/comments/uxsb6t/madeline_has_math_homework/")[r/celestegame])
    ],
  )

  #solution[
    You can do it.
  ]
]

// Use help.<section> to get help.
#help.getting-started
// #help.setup
// #help.math
// #help.drawing
// #help.caveats
