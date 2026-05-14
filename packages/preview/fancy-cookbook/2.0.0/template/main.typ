#import "@preview/fancy-cookbook:2.0.0": *

#show: cookbook.with(
  title: "My Cookbook",
  subtitle: "little subtitle",
  book-author: "Myself"
)

#chapter(change-palette: palette.coral)[Here it is]

#recipe(
  [Simple Recipe],
  description: [Not really a recipe],
  authors: [Myself],
  servings: 6,
  prep-time: [2 min],
  cook-time: [10 min],
  ingredients:[
    - *1 l* of water
    - *350 ml* of fruit juice
  ],
  instructions: [
    + put all together
    + shake well
    + reserve in fridge
  ]
)

#recipe(
  [Recipe With Groups],
  description: [Not really a recipe],
  authors: [Myself],
  servings: 6,
  prep-time: [2 min],
  cook-time: [10 min],
  ingredients:(
    (
      title: [Liquid],
      items: [
        - *1 l* of water
        - *350 ml* of fruit juice
      ]
    ),
    (
      title: [Solid],
      items: [
        - *300 mg* of wheat flour
        - *12 g* of butter
        - *150 g* of sugar
      ]
    )
  ),
  instructions: (
    (
      title: [Liquid],
      steps: [
        + put all together
        + shake well
        + reserve in fridge
      ]
    ),
    (
      title: [Solid],
      steps: [
        + Put all together
        + Mix well
        + Put everything in the garbage
        + Call for a pizza
      ]
    )
  )
)  








