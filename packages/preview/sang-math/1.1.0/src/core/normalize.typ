#import "question.typ": question, choice, QUESTION_MC, QUESTION_TF, QUESTION_SA, QUESTION_WRITTEN

#let normalize-choice(value, correct: false) = {
  if type(value) == dictionary {
    choice(
      value.at("content", default: value.at("body", default: none)),
      // Legacy dictionaries ignore the separate `correct:` index tuple.
      correct: value.at("correct", default: false),
      metadata: value.at("metadata", default: (:)),
    )
  } else {
    choice(value, correct: correct)
  }
}

#let normalize-question(q) = {
  if type(q) != dictionary { panic("sang-math: question must be a dictionary") }
  let choices = q.at("choices", default: ())
  (
    ..q,
    choices: choices.enumerate().map(((i, value)) => normalize-choice(value)),
  )
}

#let legacy-mcq-to-question(stem, options, correct: (), loigiai: none, id: none, tags: ()) = {
  question(
    id: id,
    kind: QUESTION_MC,
    prompt: stem,
    choices: options.enumerate().map(((i, value)) => normalize-choice(value, correct: correct.contains(i + 1))),
    solution: loigiai,
    tags: tags,
  )
}

#let legacy-tf-to-question(stem, statements, loigiai: none, id: none, tags: ()) = {
  question(
    id: id,
    kind: QUESTION_TF,
    prompt: stem,
    choices: statements.map(normalize-choice),
    solution: loigiai,
    tags: tags,
  )
}

#let legacy-short-to-question(stem, value, loigiai: none, id: none, tags: ()) = question(
  id: id,
  kind: QUESTION_SA,
  prompt: stem,
  answer: value,
  solution: loigiai,
  tags: tags,
)

#let legacy-written-to-question(stem, loigiai: none, id: none) = question(
  id: id,
  kind: QUESTION_WRITTEN,
  prompt: stem,
  solution: loigiai,
)
