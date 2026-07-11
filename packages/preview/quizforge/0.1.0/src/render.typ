// Rendering: exam and answer-key modes, cover page, answer grid, and the
// make-exam() entry point shared by both authoring front-ends.

#import "base.typ": LETTERS, key-color, mode-state, q-state, blank-counter, plaintext
#import "realize.typ": realize, meta-of

#let marks-tag(m) = text(
  size: 9pt,
  style: "italic",
  fill: gray.darken(40%),
  "[" + str(m) + " " + (if m == 1 { "mark" } else { "marks" }) + "]",
)

#let key-note(title, body, fill-c, stroke-c) = block(
  width: 100%,
  fill: fill-c,
  stroke: (left: 2pt + stroke-c),
  inset: (x: 8pt, y: 6pt),
  radius: 2pt,
  text(size: 9.5pt, strong(title + ". ") + body),
)

#let _render-options(entry, key) = {
  let deco-of = o => {
    let mark = key and o.correct
    t => if mark { text(fill: key-color, weight: "bold", t) } else { t }
  }
  if entry.q.at("compact", default: false) {
    // space-saving layout: options flow inline, breaking between (not inside)
    return entry.options.enumerate().map(p => {
      let deco = deco-of(p.at(1))
      box({
        deco("(" + LETTERS.at(p.at(0)) + ") ")
        deco(p.at(1).body)
        if key and p.at(1).correct { text(fill: key-color, weight: "bold", " ✓") }
      })
    }).join(h(1.6em, weak: true))
  }
  let cells = entry.options.enumerate().map(p => {
    let j = p.at(0)
    let o = p.at(1)
    let deco = deco-of(o)
    grid(
      columns: (1.8em, 1fr),
      column-gutter: 0.3em,
      deco("(" + LETTERS.at(j) + ")"),
      {
        deco(o.body)
        if key and o.correct { text(fill: key-color, weight: "bold", " ✓") }
      },
    )
  })
  grid(
    columns: (1fr,) * entry.q.columns,
    row-gutter: 0.6em,
    column-gutter: 1em,
    ..cells,
  )
}

#let _render-question(entry, key) = {
  let q = entry.q
  let inner = {
    // Arm the bank-style blank() machinery for this question (and disarm it
    // otherwise, so a stray answer-less blank() fails loudly).
    if q.type == "fill_blank" {
      blank-counter.update(0)
      q-state.update((id: q.id, answers: q.answers, width: q.blank-width, key: key))
    } else {
      blank-counter.update(0)
      q-state.update(none)
    }
    grid(
      columns: (2.4em, 1fr, auto),
      column-gutter: 0.6em,
      strong("Q" + str(entry.qno) + "."),
      {
        q.body
        if q.type == "mcq" and q.multiple {
          h(0.35em)
          text(size: 10pt, emph[(Select all that apply.)])
        }
      },
      marks-tag(q.marks),
    )
    if q.type == "fill_blank" {
      context {
        let n = blank-counter.get().first()
        assert(
          n == q.answers.len(),
          message: q.id + ": body has " + str(n) + " blank marker(s) but "
            + str(q.answers.len()) + " answer(s)",
        )
      }
    }
    if q.type == "mcq" {
      block(inset: (left: 2.4em), above: 0.7em, _render-options(entry, key))
      if key and q.explanation != none {
        block(inset: (left: 2.4em), above: 0.8em, key-note("Explanation", q.explanation, rgb("#eef7f0"), key-color))
      }
    } else if q.type == "subjective" {
      if key {
        if q.model-answer != none {
          block(inset: (left: 2.4em), above: 0.8em, key-note("Model answer", q.model-answer, rgb("#eef7f0"), key-color))
        }
        if q.rubric != none {
          block(inset: (left: 2.4em), above: 0.8em, key-note("Rubric", q.rubric, luma(246), luma(120)))
        }
      } else if q.answer-space != none {
        v(q.answer-space)
      }
    }
  }
  // Subjective questions may break across pages (large answer space); MCQ and
  // fill-in-the-blank questions must stay whole.
  if q.type == "subjective" { inner } else { block(breakable: false, inner) }
}

#let _answer-grid(mcqs, key) = {
  for chunk in mcqs.chunks(12) {
    block(
      above: 0.7em,
      table(
        columns: (auto,) + (2.3em,) * chunk.len(),
        align: center + horizon,
        stroke: 0.6pt,
        inset: 4pt,
        text(size: 9pt, weight: "bold", "Q"),
        ..chunk.map(e => text(size: 9pt, str(e.qno))),
        text(size: 9pt, weight: "bold", "Ans"),
        ..chunk.map(e => if key {
          // multi-select answers can be 3+ letters; shrink to fit the cell
          text(fill: key-color, weight: "bold", size: if e.answer.len() > 2 { 7pt } else { 9pt }, e.answer)
        } else {
          v(1.3em)
        }),
      ),
    )
  }
}

#let exam-doc(config, set-id, mode) = {
  assert(mode == "exam" or mode == "key", message: "mode must be 'exam' or 'key', got: " + mode)
  let key = mode == "key"
  let exam = config.exam
  let R = realize(config, set-id)
  let all-qs = R.sections.map(s => s.questions).flatten()
  let mcqs = all-qs.filter(e => e.type == "mcq")
  let show-grid = exam.at("answer-grid", default: false) and mcqs.len() > 0

  let instr = (
    [Write your name and roll number before starting.],
    [This paper has #all-qs.len() questions#if R.sections.len() > 1 [ in #R.sections.len() parts], for a total of #R.total marks.],
  )
  if show-grid and not key {
    instr.push([Record your final MCQ answers in the answer grid below — the grid is what gets graded.])
  }
  for s in exam.at("instructions", default: ()) { instr.push(s) }

  let info = ()
  if "date" in exam { info.push([Date: #exam.date]) }
  if "duration" in exam { info.push([Duration: #exam.duration]) }
  info.push([Maximum marks: #R.total])

  // Default page furniture; both are overridable via exam.header / exam.footer
  // (auto = these defaults, none = off, content = fixed, function = called
  // with (exam, set, mode, total) and may itself use `context`).
  let default-header = context {
    if counter(page).get().first() > 1 {
      grid(
        columns: (1fr, auto),
        text(size: 9pt, fill: gray.darken(30%), {
          exam.at("course", default: "")
          " — "
          exam.at("title", default: "")
        }),
        text(size: 9pt, weight: "bold", "SET " + set-id),
      )
      v(-4pt)
      line(length: 100%, stroke: 0.4pt + gray)
    }
  }
  let default-footer = context {
    let p = counter(page).get().first()
    let t = counter(page).final().first()
    align(
      center,
      text(size: 9pt, fill: gray.darken(30%), "Set " + set-id + "  ·  Page " + str(p) + " of " + str(t)),
    )
  }
  let resolve = (v, default) => {
    if v == auto { default } else if type(v) == function {
      v((exam: exam, "set": set-id, mode: mode, total: R.total))
    } else { v }
  }

  [
    #set document(title: plaintext(exam.at("title", default: exam.id)) + " — Set " + set-id + (if key { " (Answer Key)" } else { "" }))
    #set page(
      paper: "a4",
      margin: (x: 2cm, top: 2.3cm, bottom: 2.3cm),
      header: resolve(exam.at("header", default: auto), default-header),
      footer: resolve(exam.at("footer", default: auto), default-footer),
    )
    #set text(font: "New Computer Modern", size: 11pt)
    #set par(justify: true)
    #mode-state.update(mode)
    #metadata(meta-of(R)) <answerkey>

    #align(center)[
      #text(size: 13pt, weight: "bold", exam.at("course", default: "")) \
      #v(1pt)
      #text(size: 16pt, weight: "bold")[#exam.at("title", default: exam.id)#if key [#text(fill: rgb("#b3261e"))[ — ANSWER KEY]]] \
      #v(4pt)
      #text(size: 10.5pt, info.join(h(2.2em)))
      #v(6pt)
      #box(stroke: 1.2pt, inset: (x: 14pt, y: 7pt), radius: 2pt, text(size: 14pt, weight: "bold", "SET " + set-id))
    ]

    #if not key {
      v(8pt)
      grid(
        columns: (auto, 1fr, auto, 0.45fr),
        column-gutter: 8pt,
        align: bottom,
        [Name:], line(length: 100%, stroke: 0.7pt),
        [Roll No.:], line(length: 100%, stroke: 0.7pt),
      )
    }

    #block(
      width: 100%,
      stroke: 0.6pt + gray.darken(20%),
      inset: 9pt,
      radius: 2pt,
      above: 1em,
      {
        text(size: 10.5pt, weight: "bold", "Instructions")
        v(3pt)
        set text(size: 10pt)
        list(spacing: 0.55em, ..instr)
      },
    )

    #if show-grid {
      block(above: 1em, {
        text(size: 10.5pt, weight: "bold", "MCQ Answer Grid")
        _answer-grid(mcqs, key)
      })
    }

    #for (si, s) in R.sections.enumerate() {
      if s.title != none {
        block(above: 1.6em, below: 0.4em, {
          grid(
            columns: (1fr, auto),
            text(size: 12.5pt, weight: "bold")[Part #numbering("A", si + 1) — #s.title],
            text(size: 10pt, style: "italic", fill: gray.darken(40%))[#s.marks marks],
          )
          if s.instructions != none {
            v(2pt)
            text(size: 10pt, style: "italic", s.instructions)
          }
          v(3pt)
          line(length: 100%, stroke: 0.5pt)
        })
      } else if s.instructions != none {
        block(above: 1.2em, below: 0.4em, text(size: 10pt, style: "italic", s.instructions))
      }
      for e in s.questions {
        block(above: 1.1em, _render-question(e, key))
      }
    }

    #v(1.5em)
    #align(center, text(size: 10pt, style: "italic", "— End of paper —"))
  ]
}

// Entry point shared by both authoring styles. Reads set + mode from --input
// so one source file serves every set:
//
//   typst compile exam.typ set-B.pdf --root . --input set=B --input mode=key
//
#let make-exam(exam: none, questions: (), sections: (), default-mode: "exam") = {
  assert(type(exam) == dictionary and "id" in exam, message: "make-exam needs exam: (id: \"...\", ...)")
  let sets = exam.at("sets", default: ("A",))
  if type(sets) == str { sets = (sets,) }
  assert(sets.len() > 0, message: "exam.sets must not be empty")
  assert(sets.dedup().len() == sets.len(), message: "exam.sets contains duplicates")
  let exam = exam
  exam.insert("sets", sets)
  let set-id = sys.inputs.at("set", default: str(sets.first()))
  assert(str(set-id) in sets.map(str), message: "unknown set '" + set-id + "'; exam.sets = " + repr(sets))
  exam-doc(
    (exam: exam, questions: questions, sections: sections),
    set-id,
    sys.inputs.at("mode", default: default-mode),
  )
}
