#import "@preview/fancy-cookbook:3.0.0": *

#show: cookbook.with(
  title: "Test Rescipes"
)

#recipe(
  "test",
  description: "test",
  // ingredients: "", // error
  // ingredients: [], // content
  ingredients : (
    (
     title: "Test",
     items: [
       - first
       - second
     ] 
    ), // array OK with good dictionary
  ),
  // instructions: [] // content OK
  instructions: (
    (
      title: "Test",
      steps: [
        + first
        + second
      ]
    ), // array OK with good dictionary
  ),
  image: []
)