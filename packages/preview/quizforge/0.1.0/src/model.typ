// Question constructors (bank/constructor authoring) and inline markers
// (plain-markup authoring). All structural validation lives here as asserts,
// so an invalid quiz fails to COMPILE with a message naming the fix.

#import "base.typ": key-color, mode-state, q-state, blank-counter, plaintext

// ------------------------------------------------------------------- checks

#let _check-id(id) = {
  assert(
    type(id) == str and id.match(regex("^[A-Za-z0-9._-]+$")) != none,
    message: "question id must be a slug of letters/digits/._- , got: " + repr(id),
  )
}

#let _check-marks(id, marks) = {
  assert(
    (type(marks) == int or type(marks) == float) and marks > 0,
    message: id + ": marks must be a positive number, got " + repr(marks),
  )
}

#let _check-fixed(id, fixed) = {
  assert(
    fixed in (none, "first", "last"),
    message: id + ": fixed must be \"first\" or \"last\", got " + repr(fixed),
  )
}

// ------------------------------------------------------------- constructors

// An MCQ option. Plain content in `options:` is shorthand for opt(<content>);
// `ans` marks the correct option: ans[...] or ans(fixed: "last")[...].
#let opt(correct: false, fixed: none, body) = (body: body, correct: correct, fixed: fixed)
#let ans = opt.with(correct: true)

// Multiple-choice question. Exactly one correct option unless multiple: true.
#let mcq(
  id,
  body,
  options: (),
  marks: 1,
  topic: none,
  difficulty: none,
  multiple: false,
  shuffle: true,
  columns: 1,
  compact: false,
  explanation: none,
) = {
  _check-id(id)
  _check-marks(id, marks)
  assert(type(options) == array, message: id + ": options must be an array — beware (x) is not a 1-tuple, write (x,)")
  let opts = options.map(o => if type(o) == dictionary { o } else { opt(o) })
  assert(opts.len() >= 2, message: id + ": needs at least 2 options")
  assert(opts.len() <= 26, message: id + ": at most 26 options (A–Z) are supported, got " + str(opts.len()))
  for o in opts { _check-fixed(id, o.fixed) }
  let ncorrect = opts.filter(o => o.correct).len()
  if multiple {
    assert(ncorrect >= 1, message: id + ": multi-select needs at least one option marked with ans[...]")
  } else {
    assert(
      ncorrect == 1,
      message: id + ": exactly one option must be correct (got " + str(ncorrect)
        + "); mark it with ans[...] or ✓, or set multiple: true for multi-select",
    )
  }
  (
    type: "mcq", id: id, body: body, options: opts, marks: marks,
    topic: topic, difficulty: difficulty, multiple: multiple,
    shuffle: shuffle, columns: columns, compact: compact, explanation: explanation,
  )
}

// Fill-in-the-blank question (bank style). Put a #blank() marker in the body
// for each entry of `answers` (consumed in order).
#let fib(
  id,
  body,
  answers: (),
  marks: 1,
  topic: none,
  difficulty: none,
  blank-width: 2.5cm,
) = {
  _check-id(id)
  _check-marks(id, marks)
  let anss = if type(answers) == array { answers } else { (answers,) }
  assert(anss.len() > 0, message: id + ": needs at least one answer, e.g. answers: (\"ReLU\",)")
  for a in anss {
    assert(
      a != [] and (type(a) != str or plaintext(a).trim() != ""),
      message: id + ": a blank's answer is empty",
    )
  }
  assert(type(blank-width) == length, message: id + ": blank-width must be a length, e.g. 2.5cm")
  (
    type: "fill_blank", id: id, body: body, answers: anss, marks: marks,
    topic: topic, difficulty: difficulty, blank-width: blank-width,
  )
}

// Subjective question. answer-space is printed on the student paper;
// model-answer and rubric appear only in the answer key.
#let subj(
  id,
  body,
  marks: 1,
  topic: none,
  difficulty: none,
  answer-space: 5cm,
  model-answer: none,
  rubric: none,
) = {
  _check-id(id)
  _check-marks(id, marks)
  assert(
    answer-space == none or type(answer-space) == length,
    message: id + ": answer-space must be a length (e.g. 8cm) or none for no space",
  )
  (
    type: "subjective", id: id, body: body, marks: marks,
    topic: topic, difficulty: difficulty,
    answer-space: answer-space, model-answer: model-answer, rubric: rubric,
  )
}

// ------------------------------------------------------------------- blanks

#let _render-blank(ans, width, key) = {
  if key {
    box(
      stroke: (bottom: 0.6pt),
      inset: (x: 3pt, bottom: 1.5pt),
      text(fill: key-color, weight: "bold", ans),
    )
  } else {
    box(width: width, height: 0.7em, stroke: (bottom: 0.6pt))
  }
}

// A blank. Two forms:
//   #blank()        bank style — consumes the next entry of fib(answers: ...)
//   #blank[ReLU]    markup style — the answer lives right in the blank
// Markup-style blanks render from the document mode (exam: underline of
// `width`; key: the answer) and emit an invisible marker so the parser can
// collect answers for the grading CSV.
#let blank(width: 2.5cm, ..a) = {
  assert(a.pos().len() <= 1, message: "blank() takes at most one answer, e.g. #blank[ReLU]")
  if a.pos().len() == 1 {
    let answer = a.pos().first()
    let ptext = plaintext(answer).trim()
    assert(
      answer != [] and (type(answer) != str or ptext != ""),
      message: "blank[] answer must not be empty",
    )
    // Content whose text cannot be extracted statically (e.g. context-based
    // package output like unify's qty()) still renders in the key PDF; the
    // grading CSV gets a placeholder instead of an empty cell.
    metadata((qf: "blank", answer: if ptext == "" { "(see key)" } else { plaintext(answer) }))
    blank-counter.step()
    context _render-blank(answer, width, mode-state.get() == "key")
  } else {
    blank-counter.step()
    context {
      let s = q-state.get()
      assert(
        s != none,
        message: "blank() without an answer is only valid inside a fib() question body; in markup mode write #blank[the answer]",
      )
      let i = blank-counter.get().first() - 1
      assert(
        i < s.answers.len(),
        message: s.id + ": more blank() markers than declared answers (" + str(s.answers.len()) + ")",
      )
      _render-blank(s.answers.at(i), s.width, s.key)
    }
  }
}

// ------------------------------------------- markers for plain-markup mode
// All of these render as nothing (metadata); the parser reads them.

// Marks for a question: #m(2)
#let m(marks) = {
  assert(
    (type(marks) == int or type(marks) == float) and marks > 0,
    message: "m(): marks must be a positive number, got " + repr(marks),
  )
  metadata((qf: "marks", v: marks))
}

// Mark an option correct without typing ✓: `- #yes because reasons`
#let yes = metadata((qf: "correct",))

// Pin an option to an end of the list: `- #pin None of these`
// ("None/All/Both of the above" options are pinned last automatically.)
#let pin = metadata((qf: "fixed", v: "last"))
#let pin-first = metadata((qf: "fixed", v: "first"))

// Freeze a question's identity (seeds its option shuffle): #qid("conv-output")
#let qid(id) = {
  _check-id(id)
  metadata((qf: "id", v: id))
}

// Per-question overrides: #opts(shuffle: false, columns: 2, multiple: true)
#let opts(shuffle: auto, columns: auto, multiple: auto, compact: auto) = {
  let v = (:)
  if shuffle != auto { v.insert("shuffle", shuffle) }
  if columns != auto { v.insert("columns", columns) }
  if multiple != auto { v.insert("multiple", multiple) }
  if compact != auto { v.insert("compact", compact) }
  metadata((qf: "opts", v: v))
}

// MCQ explanation, shown only in the answer key: #explain[...]
#let explain(body) = metadata((qf: "explain", v: body))

// Subjective answer block: #answer(6cm)[model answer] or
// #answer(6cm, rubric: [...])[...] or just #answer(6cm) for space only.
#let answer(space, rubric: none, ..body) = {
  assert(
    space == none or type(space) == length,
    message: "answer(): first argument is the answer space (e.g. 6cm), or none for no space on the paper",
  )
  assert(body.pos().len() <= 1, message: "answer() takes at most one model-answer body")
  metadata((qf: "answer", space: space, model: body.pos().at(0, default: none), rubric: rubric))
}

// Section options, placed in or right after a heading: = Part C #section(shuffle: false)
#let section(shuffle: true) = metadata((qf: "sec", v: (shuffle: shuffle)))
