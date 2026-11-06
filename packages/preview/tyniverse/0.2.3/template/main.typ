#import "@preview/tyniverse:0.2.3": homework

#show: homework.template.with(
  course: "tyniverse Example",
  number: 1,
  student-infos: ((name: "Author of tyniverse", id: "GitHub: @Fr4nk1inCs"),),
)

#let question = homework.complex-question

#question[
  What is tyniverse?
]

tyniverse is a collection of #link("https://typst.app")[Typst] presets to provide a starting point for your writing. As of now, it provides presets for:
/ `set-font()`: Chinese & English font support.
/ `typesetting`: A typesetting preset.
/ `template`: A template for writing a document.
/ `homework`: Homework template with `simple-question` and `complex-question` frame to write your homework.
/ `cheatpaper`: A cheatpaper template.

#question[
  How to use tyniverse?
]

Simply import it from #link("https://typst.app/universe")[Typst Universe]:
```typst
#import "@preview/tyniverse:0.2.3": homework
```
