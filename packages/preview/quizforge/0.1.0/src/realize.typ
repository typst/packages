// realize() turns (config, set-id) into pure data — questions in final order,
// options permuted, correct letters computed. Both the rendered paper and the
// queryable <answerkey> metadata derive from this one structure, so the
// printed paper and the grading key cannot disagree.

#import "rng.typ": shuffle, sample
#import "base.typ": LETTERS, plaintext

#let _index-questions(questions) = {
  let bank = (:)
  for q in questions {
    assert(
      type(q) == dictionary and "id" in q and "type" in q,
      message: "every question must be built with mcq() / fib() / subj()",
    )
    assert(q.id not in bank, message: "duplicate question id: " + q.id)
    bank.insert(q.id, q)
  }
  bank
}

#let _matches(q, filter) = {
  for pair in filter.pairs() {
    assert(
      pair.at(0) in ("type", "topic", "difficulty"),
      message: "unknown filter key: " + pair.at(0) + " (use type / topic / difficulty)",
    )
    let allowed = if type(pair.at(1)) == array { pair.at(1) } else { (pair.at(1),) }
    if q.at(pair.at(0), default: none) not in allowed { return false }
  }
  true
}

// Which questions a section uses. Questions listed in `use` are guaranteed;
// `pick: N` is the section total, so N - |use| are sampled from the filter
// pool. Never depends on the set id: sampling is seeded by exam id + section
// index only, so every set gets exactly the same questions.
#let _select-ids(bank, section, exam-id, si) = {
  let inc-src = section.at("use", default: ())
  if type(inc-src) == str { inc-src = (inc-src,) }
  let inc = ()
  for id in inc-src {
    assert(id in bank, message: "unknown question id in use: " + id)
    if id not in inc { inc.push(id) }
  }
  let pool = ()
  if "filter" in section {
    for pair in bank.pairs() {
      if _matches(pair.at(1), section.filter) and pair.at(0) not in inc {
        pool.push(pair.at(0))
      }
    }
  }
  let n = section.at("pick", default: none)
  if n != none {
    assert(
      n >= inc.len() and n <= inc.len() + pool.len(),
      message: "pick " + str(n) + " out of range: " + str(inc.len())
        + " included + filter pool of " + str(pool.len()),
    )
    let picked = sample(pool, n - inc.len(), exam-id + "|sample|" + str(si))
    pool = pool.filter(id => id in picked) // keep author order; per-set shuffle comes later
  }
  inc + pool
}

// Permute a question's options for one set. Returns array of (original-index, option).
#let _permute-options(q, exam-id, set-id) = {
  let opts = q.options.enumerate()
  if not q.shuffle { return opts }
  let fixed-of = p => p.at(1).fixed
  let firsts = opts.filter(p => fixed-of(p) == "first")
  let lasts = opts.filter(p => fixed-of(p) == "last")
  let free = opts.filter(p => fixed-of(p) == none)
  firsts + shuffle(free, exam-id + "|" + set-id + "|o|" + q.id) + lasts
}

#let realize(config, set-id) = {
  let exam = config.exam
  let bank = _index-questions(config.questions)
  let qno = 0
  let total = 0
  let sections = ()
  for (si, sec) in config.sections.enumerate() {
    let ids = _select-ids(bank, sec, exam.id, si)
    assert(
      ids.len() > 0,
      message: "section selects no questions: " + plaintext(sec.at("title", default: "(untitled)")),
    )
    if sec.at("shuffle", default: true) {
      ids = shuffle(ids, exam.id + "|" + set-id + "|q|" + str(si))
    }
    let qs = ()
    let sec-marks = 0
    for id in ids {
      let q = bank.at(id)
      qno += 1
      sec-marks += q.marks
      let entry = (qno: qno, id: id, type: q.type, marks: q.marks, q: q)
      if q.type == "mcq" {
        let perm = _permute-options(q, exam.id, set-id)
        entry.insert("options", perm.map(p => p.at(1)))
        entry.insert("order", perm.map(p => p.at(0) + 1)) // 1-based original indices
        entry.insert(
          "correct_orig",
          q.options.enumerate().filter(p => p.at(1).correct).map(p => p.at(0) + 1),
        )
        let letters = ""
        for (j, p) in perm.enumerate() {
          if p.at(1).correct { letters += LETTERS.at(j) }
        }
        entry.insert("answer", letters)
      } else if q.type == "fill_blank" {
        entry.insert(
          "answer",
          q.answers.map(a => {
            let p = plaintext(a)
            if p.trim() == "" { "(see key)" } else { p }
          }).join("; "),
        )
      } else {
        entry.insert("answer", "MANUAL")
      }
      qs.push(entry)
    }
    total += sec-marks
    sections.push((
      title: sec.at("title", default: none),
      instructions: sec.at("instructions", default: none),
      marks: sec-marks,
      questions: qs,
    ))
  }
  (exam: exam, "set": set-id, total: total, sections: sections)
}

// Pure-data view of a realized exam — this is what <answerkey> holds and what
// `typst query` exports for the build tooling (content values are stripped).
#let meta-of(R) = (
  exam_id: R.exam.id,
  course: plaintext(R.exam.at("course", default: "")),
  title: plaintext(R.exam.at("title", default: "")),
  "set": R.at("set"),
  sets: R.exam.at("sets", default: ("A",)).map(str),
  total: R.total,
  sections: R.sections.map(s => (
    title: plaintext(s.title),
    marks: s.marks,
    questions: s.questions.map(e => {
      let m = (
        qno: e.qno, id: e.id, type: e.type, marks: e.marks,
        topic: e.q.topic, difficulty: e.q.difficulty, answer: e.answer,
      )
      if e.type == "mcq" {
        m.insert("order", e.order)
        m.insert("correct_orig", e.correct_orig)
      }
      m
    }),
  )),
)
