#import "env.typ": *
#import "question.typ": *

#let sxj-ref-question(it, qst-number-level2: none) = {
  let id-ref = id-question.at(it.target)
  let id-crt = id-question.at(here())
  id-ref = id-ref.slice(1, id-ref.last() + 1)
  id-crt = id-crt.slice(1, id-crt.last() + 1)
  let id-show = counter(question).at(it.target)
  let level2-index = none
  if qst-number-level2 == auto {
    level2-index = counter-question-l2.at(it.target).first()
    if id-show.len() > 2 + 0 {
      // Note: don't know why but it manages
      // to get the correct level2-index
      level2-index -= 1
    }
  }

  let ref-style = env-get("ref-style")
  let qst-numbering = _get-question-numbering(
    level2-index: level2-index,
    numbers: id-show,
  )
  let body = qst-numbering.join()
  if ref-style == auto {
    let i = id-ref.zip(id-crt).position(x => { x.at(0) != x.at(1) })
    if i == none {
      i = -1
    }
    body = qst-numbering.slice(i).join()
  } else if type(ref-style) == int {
    body = qst-numbering.slice(ref-style).join()
  }
  return link(it.target)[#body]
}
