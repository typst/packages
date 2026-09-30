#import "core/validate.typ": validate-question
#import "core/question.typ": QUESTION_MC, QUESTION_TF, QUESTION_SA, QUESTION_WRITTEN

#let question-bank(..questions) = questions.pos()

#let bank-filter(bank, grade: none, topic: none, difficulty: none, kind: none, tags: ()) = {
  if type(bank) != array { panic("sang-math: bank must be an array of questions") }
  if type(tags) != array or tags.any(tag => type(tag) != str) {
    panic("sang-math: bank-filter tags must be an array of strings")
  }
  if kind != none and not (QUESTION_MC, QUESTION_TF, QUESTION_SA, QUESTION_WRITTEN).contains(kind) {
    panic("sang-math: bank-filter kind is unsupported")
  }
  if difficulty != none {
    let values = if type(difficulty) == array { difficulty } else { (difficulty,) }
    if values.any(value => type(value) != int or value < 1 or value > 5) {
      panic("sang-math: bank-filter difficulty must contain integers from 1 to 5")
    }
  }
  for q in bank { let _ = validate-question(q) }
  bank.filter(q => {
    let grade-ok = grade == none or q.at("grade", default: none) == grade
    let topic-ok = topic == none or q.at("topic", default: none) == topic
    let kind-ok = kind == none or q.at("kind", default: none) == kind
    let difficulty-ok = difficulty == none or (if type(difficulty) == array { difficulty.contains(q.at("difficulty", default: none)) } else { q.at("difficulty", default: none) == difficulty })
    let tags-ok = tags.all(tag => q.at("tags", default: ()).contains(tag))
    grade-ok and topic-ok and kind-ok and difficulty-ok and tags-ok
  })
}

// Park–Miller LCG; arithmetic stays in signed 64-bit range on Typst 0.14.
#let _next-seed(seed) = calc.rem(seed * 48271, 2147483647)

#let bank-select(bank, count: none, seed: 1) = {
  if type(bank) != array { panic("sang-math: bank-select bank must be an array") }
  if type(seed) != int { panic("sang-math: bank-select seed must be an integer") }
  if count != none and (type(count) != int or count < 0 or count > bank.len()) {
    panic("sang-math: bank-select count must be between 0 and the bank size")
  }
  let n = if count == none { bank.len() } else { count }
  let state = calc.rem(calc.abs(seed), 2147483646) + 1
  let remaining = bank
  let selected = ()
  for _ in range(n) {
    state = _next-seed(state)
    let index = calc.rem(state, remaining.len())
    selected.push(remaining.at(index))
    remaining = remaining.enumerate().filter(((i, _)) => i != index).map(((_, q)) => q)
  }
  selected
}

#let bank-shuffle-choices(q, seed: 1) = {
  let _ = validate-question(q)
  let choices = q.choices
  if choices.len() == 0 { return q }
  let indexed = choices.enumerate().map(((i, item)) => (index: i + 1, choice: item))
  let shuffled = bank-select(indexed, seed: seed)
  let old-answer = q.at("answer", default: none)
  let new-answer = if type(old-answer) == dictionary and old-answer.at("kind", default: none) == "choice" {
    let matching = shuffled.enumerate().filter(((i, item)) => item.index == old-answer.value)
    if matching.len() > 0 { (..old-answer, value: matching.first().at(0) + 1) } else { old-answer }
  } else if q.kind == QUESTION_TF and type(old-answer) == array {
    shuffled.map(item => old-answer.at(item.index - 1))
  } else { old-answer }
  (..q, choices: shuffled.map(item => item.choice), answer: new-answer)
}

#let _balanced-select(pool, count, seed, usage) = {
  if usage == none { return bank-select(pool, count: count, seed: seed) }
  let rest = pool
  let result = ()
  let tier = 0
  while result.len() < count {
    let least = rest.fold(2147483647, (minimum, q) => calc.min(minimum, usage.at(repr(q.id), default: 0)))
    let eligible = rest.filter(q => usage.at(repr(q.id), default: 0) == least)
    let take = calc.min(count - result.len(), eligible.len())
    result += bank-select(eligible, count: take, seed: seed + tier * 1543)
    rest = rest.filter(q => usage.at(repr(q.id), default: 0) > least)
    tier += 1
  }
  result
}

// A small blueprint engine: exact section quotas, explicit filters, no reuse
// within one variant, and stable selection for a given seed.
#let exam-variant(bank, blueprint, seed: 1, ma-de: none, shuffle-choices: true, usage: none) = {
  if type(bank) != array { panic("sang-math: exam bank must be an array") }
  if type(seed) != int { panic("sang-math: exam seed must be an integer") }
  if type(shuffle-choices) != bool { panic("sang-math: shuffle-choices must be a boolean") }
  if usage != none and type(usage) != dictionary { panic("sang-math: usage must be a dictionary") }
  if type(blueprint) != array or blueprint.len() == 0 {
    panic("sang-math: blueprint must be a nonempty array of section dictionaries")
  }
  let code = if ma-de == none { str(calc.rem(calc.abs(seed), 10000)) } else { str(ma-de) }
  if code.len() > 4 or code.len() == 0 { panic("sang-math: ma-de must have at most four digits") }
  while code.len() < 4 { code = "0" + code }
  for i in range(code.len()) { if not "0123456789".contains(code.at(i)) { panic("sang-math: ma-de must contain digits only") } }

  let seen-ids = ()
  for q in bank {
    let _ = validate-question(q)
    if q.id != none {
      if seen-ids.contains(q.id) { panic("sang-math: duplicate question ID " + str(q.id)) }
      seen-ids.push(q.id)
    }
  }

  let remaining = bank
  let sections = ()
  let all = ()
  for (section-index, spec) in blueprint.enumerate() {
    if type(spec) != dictionary { panic("sang-math: blueprint section must be a dictionary") }
    let allowed = ("count", "kind", "grade", "topic", "difficulty", "tags", "title")
    for key in spec.keys() {
      if not allowed.contains(key) {
        panic("sang-math: blueprint section " + str(section-index + 1) + " has unknown field " + key)
      }
    }
    let count = spec.at("count", default: none)
    if type(count) != int or count < 0 { panic("sang-math: blueprint section count must be a non-negative integer") }
    let kind = spec.at("kind", default: none)
    if kind != none and not (QUESTION_MC, QUESTION_TF, QUESTION_SA, QUESTION_WRITTEN).contains(kind) {
      panic("sang-math: blueprint section " + str(section-index + 1) + " has unsupported kind " + repr(kind))
    }
    let pool = bank-filter(
      remaining,
      grade: spec.at("grade", default: none),
      topic: spec.at("topic", default: none),
      difficulty: spec.at("difficulty", default: none),
      kind: kind,
      tags: spec.at("tags", default: ()),
    )
    if pool.len() < count {
      panic("sang-math: blueprint section " + str(section-index + 1) + " needs " + str(count) + " questions but only " + str(pool.len()) + " match")
    }
    let originals = _balanced-select(pool, count, seed + section-index * 1009, usage)
    let selected = originals
    if shuffle-choices {
      selected = selected.enumerate().map(((i, q)) => {
        if q.kind == "mcq" { bank-shuffle-choices(q, seed: seed + section-index * 1009 + i * 9176 + 1) } else { q }
      })
    }
    sections.push((..spec, questions: selected))
    all += selected
    remaining = remaining.filter(q => not originals.contains(q))
  }
  (ma-de: code, seed: seed, sections: sections, questions: all)
}

#let exam-variants(bank, blueprint, codes, seed: 1, shuffle-choices: true) = {
  if type(codes) != array or codes.len() == 0 { panic("sang-math: codes must be a nonempty array") }
  if bank.any(q => q.at("id", default: none) == none) { panic("sang-math: each question needs an ID for balanced variants") }
  let usage = (:)
  let seen-codes = ()
  let result = ()
  for (i, code) in codes.enumerate() {
    let variant = exam-variant(
      bank, blueprint,
      seed: seed + i * 104729,
      ma-de: code,
      shuffle-choices: shuffle-choices,
      usage: usage,
    )
    if seen-codes.contains(variant.ma-de) { panic("sang-math: duplicate exam code " + variant.ma-de) }
    seen-codes.push(variant.ma-de)
    result.push(variant)
    for q in variant.questions {
      let key = repr(q.id)
      usage.insert(key, usage.at(key, default: 0) + 1)
    }
  }
  result
}
