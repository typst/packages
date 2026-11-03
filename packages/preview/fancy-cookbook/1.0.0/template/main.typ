#import "@preview/fancy-cookbook:1.0.0": *

#show: cookbook.with(
  title: "My Cookbook",
  subtitle: "With all good recipes",
  style: style.gradient,
  chapter-start-right: true,
  theme: themes.blue,
  book-author: "Me"
)

= Meal

#recipe(
  [Good food],
  description: [with spices],
  tags:("Whisky"),
  servings: 6,
  prep-time: [2 min],
  cook-time: [10 min],
  ingredients: [
    - *1* chili pepper
    - *2* tomatoes
  ],
  instructions: [
    + Mix all together.
    + Eat it.
  ]
)