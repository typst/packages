#let _solution-content(value) = {
  if type(value) != array { return value }
  [
    #for item in value {
      if type(item) == dictionary and "content" in item {
        if item.at("title", default: none) != none { strong(item.title) }
        item.content
        parbreak()
      } else {
        item
        parbreak()
      }
    }
  ]
}

#let render-solution(q, mcq, tf, short, written, ..args) = {
  let named = args.named()
  let solution = _solution-content(q.solution)
  if q.kind == "mcq" {
    mcq(q.prompt, q.choices.map(c => (body: c.content, correct: c.correct)), mode: "loigiai", loigiai: solution, id: q.id, tags: q.tags, ..named)
  } else if q.kind == "true-false" {
    tf(q.prompt, q.choices.map(c => (body: c.content, correct: c.correct)), mode: "loigiai", loigiai: solution, id: q.id, tags: q.tags, ..named)
  } else if q.kind == "short-answer" {
    let value = if type(q.answer) == dictionary { q.answer.at("value", default: none) } else { q.answer }
    short(q.prompt, value, mode: "loigiai", loigiai: solution, id: q.id, tags: q.tags, ..named)
  } else {
    written(q.prompt, mode: "loigiai", loigiai: solution, id: q.id, ..named)
  }
}
