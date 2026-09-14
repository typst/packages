#import "@preview/itemize:0.2.0": item
#import "clear-answers.typ": clear-answers

#let display-answers = (clear: true) => {
  context {
    let answer-list = state("__answers-list__", ()).get()
    grid(
      columns: (auto, 1fr),
      row-gutter: 0.5em,
      column-gutter: 0.5em,
      ..answer-list.map(entry => (entry.label, entry.answer)).flatten(),
    )

    if (clear) {
      clear-answers()
    }
  }
}
