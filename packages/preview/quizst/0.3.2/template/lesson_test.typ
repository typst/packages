#import "../lib.typ": quiz

#let json_data = json("input/lesson_mode.json")

#show: quiz.with(
  highlight-answer: true,
  json_data: json_data,
) 