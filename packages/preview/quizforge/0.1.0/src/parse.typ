// Plain-markup front-end: `#show: quiz.with(...)` turns an ordinary Typst
// document into a randomizable exam by walking its content tree.
//
//   = Part heading            → section (content before the first question
//                               becomes the section's instructions)
//   + question body           → question (enum item)
//     - option                → MCQ option (list item); ✓ or #yes marks correct
//   #blank[ans] in the body   → fill-in-the-blank question
//   #answer(6cm)[model]       → subjective question
//   #m(2) #qid(..) #opts(..) #explain[..] #pin — invisible markers
//
// Question type is inferred: options present → mcq; blanks present → fib;
// otherwise subjective. "None/All/Both of the above" options auto-pin last;
// two or more ✓ options auto-enable multi-select.

#import "rng.typ": fnv1a
#import "base.typ": plaintext
#import "model.typ": mcq, fib, subj, opt
#import "render.typ": make-exam

// Accepted correct-option prefixes (plain ✓ and heavy ✔).
#let _CHECKS = ("✓", "✔")

// If t starts with a checkmark, return the remainder (trimmed); else none.
#let _strip-prefix(t) = {
  for c in _CHECKS {
    if t.starts-with(c) { return t.slice(c.len()).trim(at: start) }
  }
  none
}

// The value dict of a quizforge marker, or none.
#let _marker(c) = {
  if type(c) == content and c.func() == metadata and type(c.value) == dictionary and "qf" in c.value {
    c.value
  } else {
    none
  }
}

#let _children(c) = if c.has("children") { c.children } else { (c,) }

// Flatten the top-level stream: unwrap nested sequences (produced by
// #include, letting large quizzes span multiple files) and reject styled
// wrappers (a #set/#show inside the body would silently swallow everything
// after it — set rules belong above the `#show: quiz` line, where they
// apply to the whole rendered paper).
#let _flat-children(body) = {
  let out = ()
  for c in _children(body) {
    if type(c) != content {
      out.push(c)
    } else if repr(c.func()) == "sequence" {
      out += _flat-children(c)
    } else if repr(c.func()) == "styled" {
      assert(
        false,
        message: "quizforge: #set/#show rules inside the quiz body are not supported — move them above the '#show: quiz' line (they will then style the whole paper)",
      )
    } else {
      out.push(c)
    }
  }
  out
}

#let _is-blankish(c) = repr(c.func()) in ("space", "parbreak", "linebreak")

// Recursively collect quizforge markers, without descending into list/enum
// items (those belong to nested scopes). Walks EVERY content-valued field —
// not just body/children — so markers survive inside equations (attach
// scripts, fractions), figures, tables, styled wrappers, etc.
#let _collect-markers(c, out) = {
  let mk = _marker(c)
  if mk != none { out.push(mk); return out }
  if type(c) != content or c.func() in (list.item, enum.item) { return out }
  for pair in c.fields().pairs() {
    let v = pair.at(1)
    if type(v) == content {
      out = _collect-markers(v, out)
    } else if type(v) == array {
      for x in v {
        if type(x) == content { out = _collect-markers(x, out) }
      }
    }
  }
  out
}

// Detect and strip a leading ✓/✔ from an option body. Returns (found, body).
#let _strip-check(body) = {
  if body.has("text") {
    let rest = _strip-prefix(body.text)
    if rest != none { return (true, text(rest)) }
    return (false, body)
  }
  if body.has("children") {
    let ch = body.children
    let i = 0
    // scan past whitespace AND invisible markers (#pin ✓ Foo must still work)
    while i < ch.len() and (_is-blankish(ch.at(i)) or ch.at(i).func() == metadata) { i += 1 }
    if i < ch.len() and ch.at(i).has("text") {
      let rest = _strip-prefix(ch.at(i).text)
      if rest != none {
        let head = ch.slice(0, i)
        let tail = ch.slice(i + 1)
        if rest == "" {
          // the ✓ was its own word — also swallow the following space
          if tail.len() > 0 and _is-blankish(tail.first()) { tail = tail.slice(1) }
          return (true, (head + tail).join())
        }
        return (true, (head + (text(rest),) + tail).join())
      }
    }
  }
  (false, body)
}

#let _NOTA = regex("^\s*(none|all|both) of the above")

// Marker kind → the function the author typed, for error messages.
#let _MARKER-NAMES = (
  marks: "m(...)", id: "qid(...)", opts: "opts(...)", explain: "explain[...]",
  answer: "answer(...)", blank: "blank[...]", sec: "section(...)",
  correct: "yes", fixed: "pin",
)

#let _parse-option(li, where) = {
  let correct = false
  let fixed = none
  for mk in _collect-markers(li.body, ()) {
    if mk.qf == "correct" { correct = true }
    else if mk.qf == "fixed" { fixed = mk.v }
    else {
      assert(
        false,
        message: where + ": #" + _MARKER-NAMES.at(mk.qf, default: mk.qf)
          + " cannot appear inside an option — only ✓ / #yes / #pin belong there",
      )
    }
  }
  let stripped = _strip-check(li.body)
  if stripped.at(0) { correct = true }
  let body = stripped.at(1)
  // Reject truly empty options ("- ✓" alone) but allow content whose text is
  // statically opaque (context-based package output such as unify's qty()).
  let is-empty = (
    body == none or body == []
      or (type(body) == content and body.has("text") and body.text.trim() == "")
  )
  assert(not is-empty, message: where + ": an option is empty")
  if fixed == none and lower(plaintext(body)).match(_NOTA) != none {
    fixed = "last" // "None of the above" and friends auto-pin to the end
  }
  opt(correct: correct, fixed: fixed, body)
}

#let _build-question(item, where, default-space) = {
  let markers = ()
  let option-items = ()
  let body-parts = ()
  for c in _children(item.body) {
    if type(c) == content and c.func() == list.item {
      option-items.push(c)
    } else {
      markers = _collect-markers(c, markers)
      body-parts.push(c)
    }
  }
  while body-parts.len() > 0 and _is-blankish(body-parts.last()) {
    let _ = body-parts.pop() // discard: pop's return value must not join the result
  }
  let body = body-parts.join()
  assert(body != none and plaintext(body).trim() != "", message: where + ": question has no body text")

  // Word-habit blanks: `____` parses as emph(body: []) and renders as NOTHING.
  let has-empty-em(c) = {
    let rec(c, self) = {
      if type(c) != content { return false }
      if repr(c.func()) in ("emph", "strong") and c.at("body", default: none) == [] { return true }
      for pair in c.fields().pairs() {
        let v = pair.at(1)
        if type(v) == content and self(v, self) { return true }
        if type(v) == array {
          for x in v { if type(x) == content and self(x, self) { return true } }
        }
      }
      false
    }
    rec(c, rec)
  }
  assert(
    not has-empty-em(body),
    message: where + ": found underscore-style blanks (____) — in Typst, underscores "
      + "toggle italics and render as nothing; write blanks as #blank[the answer]",
  )

  let marks = 1
  let id = none
  let explanation = none
  let ans-mk = none
  let blanks = ()
  let over = (:)
  let seen-mk = ()
  for mk in markers {
    if mk.qf in ("marks", "id", "explain", "answer", "opts") {
      // repeated #m / #qid / #answer / #opts / #explain on one question is
      // always an authoring accident — the loser would win silently
      assert(
        mk.qf not in seen-mk,
        message: where + ": #" + _MARKER-NAMES.at(mk.qf) + " appears more than once",
      )
      seen-mk.push(mk.qf)
    }
    if mk.qf == "marks" { marks = mk.v }
    else if mk.qf == "id" { id = mk.v }
    else if mk.qf == "explain" { explanation = mk.v }
    else if mk.qf == "answer" { ans-mk = mk }
    else if mk.qf == "blank" { blanks.push(mk.answer) }
    else if mk.qf == "opts" { over = mk.v }
    else if mk.qf == "correct" or mk.qf == "fixed" {
      assert(false, message: where + ": ✓ / #yes / #pin belong on options (- lines), not in the question body")
    }
    else if mk.qf == "sec" {
      assert(false, message: where + ": #section(...) belongs in a part heading, not in a question")
    }
  }
  if id == none {
    // Stable identity from the question's own text: reordering/inserting
    // questions never reshuffles others; editing THIS question's wording
    // reshuffles only its own options. Freeze with #qid("...") if needed.
    id = "q" + str(fnv1a(plaintext(body)))
  }

  if option-items.len() > 0 {
    assert(blanks.len() == 0, message: where + ": a question cannot have both options and #blank[...]")
    assert(
      ans-mk == none,
      message: where + ": #answer(...) is for subjective questions — use #explain[...] on an MCQ",
    )
    assert(option-items.len() >= 2, message: where + ": needs at least 2 options")
    let options = option-items.map(li => _parse-option(li, where))
    let ncorrect = options.filter(o => o.correct).len()
    assert(
      ncorrect > 0,
      message: where + ": no option is marked correct — prefix one with ✓ or #yes"
        + " (if these '-' items are prose rather than options, build them with the #list() function instead)",
    )
    mcq(
      id,
      body,
      options: options,
      marks: marks,
      multiple: over.at("multiple", default: ncorrect > 1),
      shuffle: over.at("shuffle", default: true),
      columns: over.at("columns", default: 1),
      compact: over.at("compact", default: false),
      explanation: explanation,
    )
  } else if blanks.len() > 0 {
    assert(
      ans-mk == none,
      message: where + ": #answer(...) cannot be combined with #blank[...] — blanks carry their own answers",
    )
    assert(explanation == none, message: where + ": #explain[...] is only supported on MCQs")
    fib(id, body, answers: blanks, marks: marks)
  } else {
    // A ✓ in a question that has NO options usually means the options were
    // written markdown-style (`* item`) or dedented — and were silently
    // absorbed into the body. Refuse rather than print a wrong paper.
    let ptext = plaintext(body)
    assert(
      not ptext.contains("✓") and not ptext.contains("✔"),
      message: where + ": a ✓ appears in the question text but the question has no options — "
        + "options are '- ' list items indented two spaces under the '+ ' question",
    )
    assert(explanation == none, message: where + ": #explain[...] is only supported on MCQs")
    let space = if ans-mk != none { ans-mk.space } else { default-space }
    subj(
      id,
      body,
      marks: marks,
      answer-space: space,
      model-answer: if ans-mk != none { ans-mk.model } else { none },
      rubric: if ans-mk != none { ans-mk.rubric } else { none },
    )
  }
}

// Split the document body into sections of questions.
// Returns (questions: (..), sections: (..)) ready for make-exam.
#let _parse(body, default-space) = {
  let sections = ()
  let cur = (title: none, shuffle: true, pre: (), items: ())

  let flush(cur, sections) = {
    if cur.items.len() == 0 {
      assert(
        cur.title == none,
        message: "quizforge: part '" + plaintext(cur.title).trim() + "' has no questions (+ items)",
      )
      assert(
        cur.pre.len() == 0,
        message: "quizforge: content before the first part heading or question is not supported — "
          + "put instructions after a part heading, or pass instructions: (...) to quiz()",
      )
      return sections
    }
    sections.push(cur)
    sections
  }

  for c in _flat-children(body) {
    if type(c) != content or _is-blankish(c) { continue }
    let mk = _marker(c)
    if mk != none {
      if mk.qf == "sec" {
        cur.shuffle = mk.v.at("shuffle", default: true)
      } else {
        // A #m(2) drifting between questions would silently change nothing
        // (the question would keep its default marks) — refuse loudly.
        assert(
          false,
          message: "quizforge: found #" + _MARKER-NAMES.at(mk.qf, default: mk.qf)
            + " outside any question (in instructions or between questions) — markers belong inside a question's + item",
        )
      }
      continue
    }
    if c.func() == heading {
      assert(c.depth == 1, message: "quizforge: only level-1 headings (= Part) are supported")
      sections = flush(cur, sections)
      let title = c.body
      for hm in _collect-markers(c.body, ()) {
        if hm.qf == "sec" { title = c.body } // markers are invisible; keep body as-is
      }
      cur = (title: title, shuffle: true, pre: (), items: ())
      for hm in _collect-markers(c.body, ()) {
        if hm.qf == "sec" { cur.shuffle = hm.v.at("shuffle", default: true) }
      }
    } else if c.func() == enum.item {
      cur.items.push(c)
    } else {
      // A bare '- item' at part level is almost always a dedented (or
      // swapped +/-) option — silently treating it as prose would be cruel.
      assert(
        c.func() != list.item,
        message: "quizforge: a '- option' appears outside any question — indent options two spaces "
          + "under their '+ question' (questions start with '+', options with '-'; "
          + "for a real bullet list in instructions, use the #list(..) function instead)",
      )
      assert(
        cur.items.len() == 0,
        message: "quizforge: free content between questions is not supported (it cannot move with "
          + "shuffled questions) — fold it into a question body, start it with '+ ' if it is a new "
          + "question, or put it right after the part heading (where it becomes the part's instructions)",
      )
      cur.pre.push(c)
    }
  }
  sections = flush(cur, sections)
  assert(sections.len() > 0, message: "quizforge: no questions found — write questions as + items")

  let questions = ()
  let out-sections = ()
  let seen = (:) // id → where, to explain hash collisions from identical text
  for (si, sec) in sections.enumerate() {
    let ids = ()
    for (qi, item) in sec.items.enumerate() {
      let where = (
        if sec.title == none { "question " + str(qi + 1) }
        else { "question " + str(qi + 1) + " of part '" + plaintext(sec.title).trim() + "'" }
      )
      let q = _build-question(item, where, default-space)
      assert(
        q.id not in seen,
        message: "quizforge: " + where + " and " + seen.at(q.id, default: "?")
          + " are identical (same text or same #qid) — reword one or give it a distinct #qid(...)",
      )
      seen.insert(q.id, where)
      questions.push(q)
      ids.push(q.id)
    }
    out-sections.push((
      title: sec.title,
      instructions: if sec.pre.len() > 0 { sec.pre.join() } else { none },
      use: ids,
      shuffle: sec.shuffle,
    ))
  }
  (questions: questions, sections: out-sections)
}

// The plain-markup entry point:
//
//   #show: quiz.with(id: "dl-quiz-2", course: "...", sets: ("A", "B"))
//
// Compiled as-is, the master renders the ANSWER KEY (what you wrote, ✓ visible);
// pass --input mode=exam --input set=B for a randomized student paper.
#let quiz(
  id: none,
  course: "",
  title: "",
  date: none,
  duration: none,
  sets: ("A",),
  answer-grid: false,
  instructions: (),
  answer-space: 5cm, // default space for subjective questions without #answer(...); none = no space
  header: auto, // auto = generated | none = off | content | (info) => content
  footer: auto, // ditto; info = (exam, set, mode, total)
  body,
) = {
  assert(
    id != none,
    message: "quizforge: give the quiz an id — #show: quiz.with(id: \"my-quiz-1\", ...)",
  )
  let parsed = _parse(body, answer-space)
  let exam = (
    id: id,
    course: course,
    title: if title == "" { id } else { title },
    sets: sets,
    "answer-grid": answer-grid,
    instructions: instructions,
    header: header,
    footer: footer,
  )
  if date != none { exam.insert("date", date) }
  if duration != none { exam.insert("duration", duration) }
  make-exam(
    exam: exam,
    questions: parsed.questions,
    sections: parsed.sections,
    default-mode: "key", // the master IS the key; --input mode=exam for papers
  )
}
