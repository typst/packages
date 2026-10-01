// Data-only implementations for bank-mode's tn/ds/tln/tl functions.
// The familiar function name supplies the kind; bank.json ID supplies taxonomy.
#import "normalize.typ": legacy-mcq-to-question, legacy-tf-to-question, legacy-short-to-question, legacy-written-to-question
#import "validate.typ": validate-question

#let _decode-id(id) = {
  let digits = "0123456789"
  if (type(id) != str or id.len() != 7 or not "012".contains(id.at(0)) or
    not ("D", "H", "C").contains(id.at(1)) or not digits.contains(id.at(2)) or
    not ("N", "H", "V", "C").contains(id.at(3)) or not digits.contains(id.at(4)) or
    id.at(5) != "-" or not digits.contains(id.at(6))) {
    panic("sang-math: compact question ID must follow bank.json, e.g. 2D1N1-1")
  }
  let level = id.at(3)
  (
    grade: 10 + int(id.at(0)),
    chapter: id.slice(0, 3),
    topic: id.slice(0, 3) + "-" + id.at(4) + "-" + id.at(6),
    difficulty: if level == "N" { 1 } else if level == "H" { 2 } else if level == "V" { 3 } else { 4 },
    metadata: (
      bank-id: id,
      branch: id.at(1),
      level: level,
      lesson: int(id.at(4)),
      form: int(id.at(6)),
    ),
  )
}

#let _finish(q, id, fields) = {
  let allowed = (
    "subject", "tags", "estimated-time", "points", "source", "metadata", "hints",
  )
  for name in fields.keys() {
    if not allowed.contains(name) {
      panic("sang-math: compact question has unknown field " + name)
    }
  }
  let decoded = _decode-id(id)
  let extra-metadata = fields.at("metadata", default: (:))
  if type(extra-metadata) != dictionary { panic("sang-math: compact question metadata must be a dictionary") }
  validate-question((
    ..q, id: id,
    grade: decoded.grade, chapter: decoded.chapter, topic: decoded.topic,
    difficulty: decoded.difficulty,
    ..fields,
    metadata: (..decoded.metadata, ..extra-metadata, bank-id: id),
  ))
}

// True([option]) works exactly as in #tn. `correct: (2,)` is also supported.
#let _bank-tn(stem, options, id: none, correct: (), loigiai: none, ..fields) = _finish(
  legacy-mcq-to-question(stem, options, correct: correct, loigiai: loigiai),
  id,
  fields.named(),
)

#let _bank-ds(stem, statements, id: none, loigiai: none, ..fields) = _finish(
  legacy-tf-to-question(stem, statements, loigiai: loigiai),
  id,
  fields.named(),
)

#let _bank-tln(stem, value, id: none, loigiai: none, ..fields) = _finish(
  legacy-short-to-question(stem, value, loigiai: loigiai),
  id,
  fields.named(),
)

#let _bank-tl(stem, id: none, loigiai: none, ..fields) = _finish(
  legacy-written-to-question(stem, loigiai: loigiai),
  id,
  fields.named(),
)

// Bind once inside the bank section: the calls keep the 1.0.6 names and
// stem/options order, while returning data for seeded selection.
#let bank-mode() = (_bank-tn, _bank-ds, _bank-tln, _bank-tl)
