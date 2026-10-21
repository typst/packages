#import "@preview/modern-class-presentation:0.1.0": *

#show: deck.with(
  title: "Introduction to Linear Models",
  subtitle: "From observations to predictions",
  author: "Dr. Ada Lovelace",
  date: "Spring 2026",
)

#slide(title: "Course Overview")[
  - We will explore linear relationships in empirical datasets.
  - Learn how to fit lines and evaluate prediction accuracy.
]

#section-slide(
  title: "The central question",
  description: "How can a line help us make useful predictions?",
)

#slide(title: "Start with a familiar pattern")[
  #columns(
    [
      - Study hours and exam scores often move together.
      - We want a model that describes this relationship clearly.
      - The model should also help estimate an unseen score.
    ],
    [
      #callout(title: "Learning objective", accent: teal)[
        By the end of class, you will interpret the slope and intercept of a
        simple linear model.
      ]
    ],
  )
]

#slide(title: "A model is a useful simplification", eyebrow: "Key idea", accent: coral)[
  #callout(title: "Linear model", accent: coral)[
    $ y = beta_0 + beta_1 x $
  ]

  #v(0.26in)
  The intercept $beta_0$ is the predicted outcome at $x = 0$. The slope
  $beta_1$ describes how the prediction changes as $x$ increases by one unit.
]

#focus-slide(
  [All models are wrong, but some are useful.],
  title: "Core Takeaway",
  accent: primary,
)
