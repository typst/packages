#import "@preview/Quizst": quiz

#let json_data = json("input/example.json")

#show: quiz.with(
  highlight-answer: true,
  json-data: json_data,
)

