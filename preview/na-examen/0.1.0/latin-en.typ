// Latin (LTR) template: an English test
#import "../lib.typ": *

#show: examen.with(
  lang: "en",                              // or: #show: examen-en.with(...)
  school: "Emir Abdelkader Middle School — Tlemcen",
  year: "2026-2027",
  level: "4th year middle school",
  term: "Second Term",
  kind: "Tests of the",                    // "Tests of the Second Term"; none to remove
  exam: "Test",
  subject: "English",                      // title line: "English Test"
  duration: "1 h 30",
  code: "test 2 term 2-4AM",
  size: 11pt,
)

#exercise(points: 7)[
  Read the text, then answer the questions.

  #q[1] Choose the correct title for the text.

  #q[2] Say whether the statements are true or false.
]

#exercise(points: 6)[
  #part(points: 3)[Put the verbs between brackets in the correct tense.]
  #part(points: 3)[Rewrite the sentences in the passive voice.]
]

// Whole lines can be replaced, and the duration or barcode removed
#exercise(points: 7, title: [Written Expression])[
  Write a paragraph of about eight lines on one of the following topics.
]
