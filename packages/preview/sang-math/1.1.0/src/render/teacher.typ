#let render-teacher(q, mcq, tf, short, written, ..args) = {
  let named = args.named()
  if q.kind == "mcq" {
    mcq(q.prompt, q.choices.map(c => (body: c.content, correct: c.correct)), mode: "solcolor", id: q.id, tags: q.tags, ..named)
  } else if q.kind == "true-false" {
    tf(q.prompt, q.choices.map(c => (body: c.content, correct: c.correct)), mode: "solcolor", id: q.id, tags: q.tags, ..named)
  } else if q.kind == "short-answer" {
    let value = if type(q.answer) == dictionary { q.answer.at("value", default: none) } else { q.answer }
    short(q.prompt, value, mode: "solcolor", id: q.id, tags: q.tags, ..named)
  } else {
    written(q.prompt, mode: "solcolor", id: q.id, ..named)
  }
}
