#import "@preview/dudi-colorful-template:0.1.0": *

#set page(
  paper: "presentation-16-9",
  margin: 0cm
)
#set text(
  font: "Helvetica",
  size: 24pt
)

#let my-color1 = rgb("#1a5276")
#let my-color2 = rgb("#2ecc71")

#title_slide([Генерация синтетических данных], 42pt, [Иванов Иван], [АС-24-05], color1: my-color1, color2: my-color2)

#slide([Постановка задачи], [Левый столбец], [Правый столбец], color1: my-color1, color2: my-color2)

#slide([Заключение], [Итоги], [Выводы], color1: my-color1, color2: my-color2, is_last: true)
