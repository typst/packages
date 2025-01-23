#import "env.typ": *
#import "question.typ": *

#let reference_fromQuestion(it, qst-number-level2: none) = {
  let idRef = idQuestion.at(it.target)
  let idCrt = idQuestion.at(here())
  idRef = idRef.slice(1, idRef.last() + 1)
  idCrt = idCrt.slice(1, idCrt.last() + 1)
  let idShow = counter(question).at(it.target)
  let level2-index = none
  if qst-number-level2 == auto {
    level2-index = counterQuestionL2.at(it.target).first()
    if idShow.len() > 2 + 0 {
      // could cause bug, need tested
      // don't know why but it works
      // to get the correct level2-index
      level2-index -= 1
    }
  }

  let refStyle = envGet("ref-style")
  let numArray = question_getNumber(
    level2-index: level2-index,
    numbers: idShow,
  )
  let body = numArray.join()
  if refStyle == auto {
    while idCrt.len() > idRef.len() {
      idCrt.pop()
    }
    while idCrt.len() < idRef.len() {
      idCrt.push(0)
    }
    let i = 0
    while i < idRef.len() {
      if (idRef.at(i) != idCrt.at(i)) { break }
      i += 1
    }
    body = numArray.slice(i).join()
  } else if type(refStyle) == int {
    body = numArray.slice(refStyle).join()
  }
  return link(it.target)[#body]
}
