#import "@preview/quizst:0.3.2": quiz

#let json_data = json("input/example.json")

#show: quiz.with(
  highlight-answer: true,
  json-data: json_data,
)

