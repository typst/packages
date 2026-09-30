#let render-answer-key(q, num: none) = {
  let prefix = if num == none { if q.id == none { [Câu] } else { [#q.id] } } else { [Câu #num] }
  let value = if q.kind == "mcq" {
    let index = q.choices.position(c => c.correct)
    if index == none { [?] } else { ("A", "B", "C", "D", "E", "F").at(index, default: [?]) }
  } else if q.kind == "true-false" {
    q.choices.map(c => if c.correct { "Đ" } else { "S" }).join("-")
  } else if q.kind == "short-answer" {
    if type(q.answer) == dictionary { q.answer.at("value", default: [?]) } else { q.answer }
  } else { [—] }
  [#prefix: #value]
}
