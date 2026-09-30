// Data only. Rendering and document state live outside this module.
#let QUESTION_MC = "mcq"
#let QUESTION_TF = "true-false"
#let QUESTION_SA = "short-answer"
#let QUESTION_WRITTEN = "written-response"

#let choice(content, correct: false, metadata: (:)) = (
  content: content,
  correct: correct,
  metadata: metadata,
)

#let answer(kind, value, ..fields) = (kind: kind, value: value, ..fields.named())

#let solution-step(content, title: none) = (title: title, content: content)

#let question(
  id: none,
  kind: none,
  prompt: none,
  choices: (),
  answer: none,
  solution: none,
  hints: (),
  points: none,
  subject: "math",
  grade: none,
  chapter: none,
  topic: none,
  difficulty: none,
  cognitive-level: none,
  tags: (),
  estimated-time: none,
  source: none,
  metadata: (:),
) = (
  id: id,
  kind: kind,
  prompt: prompt,
  choices: choices,
  answer: answer,
  solution: solution,
  hints: hints,
  points: points,
  subject: subject,
  grade: grade,
  chapter: chapter,
  topic: topic,
  difficulty: difficulty,
  cognitive-level: cognitive-level,
  tags: tags,
  estimated-time: estimated-time,
  source: source,
  metadata: metadata,
)
