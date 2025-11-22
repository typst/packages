#import "env.typ": *
#import "utils.typ": *
#import "question.typ": *

#let sxj-qg-get-level(envs: (:)) = {
  let level = envs.level
  if level == auto {
    let qst-before-here = query(selector(question).before(here()))
    if qst-before-here.len() != 0 {
      level = calc.min(qst-before-here.last().level + 1, 3)
    } else { level = 1 }
  }
  return level
}

#let sxj-qg-get-rows(envs: (:), contents) = {
  let num-qst = int(contents.pos().len() / 2)
  let col = envs.col
  let num-row = calc.ceil(num-qst / col)
  let rows = ()
  let i = 0
  while i < num-row {
    rows.push(auto)
    rows.push(auto)
    i += 1
  }
  return rows
}

#let sxj-qg-ins-answer-empty(envs: (:), contents) = {
  let a = contents.pos()
  let b = ()
  for i in a {
    b.push(i)
    b.push(box(height: envs.gutter, []))
  }
  return arguments(..b)
}

#let sxj-qg-add-bracket-empty(envs: (:), contents) = {
  let r = contents.pos()
  let i = 0
  while i < r.len() {
    r.at(i) = [#sxj-bracket[]#r.at(i)]
    i += 2
  }
  return arguments(..r)
}

#let sxj-qg-add-punc(envs: (:), contents) = {
  let qst-after-here = query(selector(question).after(here())).map(x => x.level)
  let num-to-last-qst = qst-after-here.position(x => x < qst-after-here.first())
  if num-to-last-qst == none { num-to-last-qst = qst-after-here.len() }

  let r = contents.pos()
  let i = 0
  while i < r.len() {
    num-to-last-qst -= 1
    r.at(i) = [#r.at(i)] + { if num-to-last-qst != 0 [；] else [。] }
    i += 2
  }
  return arguments(..r)
}

#let sxj-qg-to-question(envs: (:), contents) = {
  let r = contents.pos()
  let i = 0
  while i < r.len() {
    r.at(i) = question(level: sxj-qg-get-level(envs: envs), r.at(i))
    i += 2
  }
  return arguments(..r)
}

#let sxj-qg-rearrange(envs: (:), contents) = {
  let ctt = contents.pos()
  // Getting questions into q and answers into a
  let q = ()
  let a = ()
  while ctt.len() != 0 {
    if calc.odd(ctt.len()) {
      q.push(ctt.pop())
    } else {
      a.push(ctt.pop())
    }
  }
  // Filling r with q and a in rearranged order
  let r = ()
  let col = envs.col
  let i = 0
  while q.len() > 0 or a.len() > 0 {
    if calc.even(calc.div-euclid(i, col)) {
      if q.len() != 0 {
        r.push(q.pop())
      } else { r.push([]) }
    } else {
      if a.len() != 0 {
        r.push(a.pop())
      } else { r.push([]) }
    }
    i += 1
  }
  return arguments(..r)
}

#let sxj-qg-pcs-basic = (sxj-qg-to-question, sxj-qg-rearrange)
#let sxj-qg-pcs-std = (sxj-qg-ins-answer-empty, sxj-qg-add-punc) + sxj-qg-pcs-basic
#let sxj-qg-pcs-tf = (sxj-qg-ins-answer-empty, sxj-qg-add-punc, sxj-qg-add-bracket-empty) + sxj-qg-pcs-basic

/// Grab questions into one group;
/// - gutter (length):
///   When `sxj-qg-ins-answer-empty` is in `preprocessor`,
///   it's the gutter between two rows of questions;
///   Otherwise it's the gutter between two rows of content.
///   TODO/DNF: need to be made clearer in the future,
///   probably seperated into `row-gutter` and `ans-height`.
/// - col (int): The number of columns you want for this group of question
/// - level (int, auto):
///   The level for each question,
///   when set to auto, it would be the next level of current question level.
/// - preprocessor (array):
///   A array of funcs to process contents,
///   each func's args and return should be (envs, contents)=>arguments,
///   where envs is a named parameter, a dictionary of necessary parameters given to sxj-question-group like level, col etc.
///   and contents would be arguments of contents.
///   Pre-defined funcs would be named like `sxj-qg-*()`,
///   pre-defined preprocessor would be named like `sxj-qg-pcs-*`.
/// - contents (arguments): arguments of questions' contents
/// -> content
#let sxj-question-group(
  qst-align-number: "One-Lined-Compact",
  gutter: auto,
  col: 2,
  level: auto,
  preprocessor: sxj-qg-pcs-std,
  ..contents,
) = {
  v(.5em)
  context {
    let cnts = contents
    let envs = (gutter: gutter, col: col, level: level)
    for pcs in preprocessor { cnts = pcs(envs: envs, cnts) }
    with-env(qst-align-number: qst-align-number)[
      #grid(
        column-gutter: 0em,
        gutter: if preprocessor.contains(sxj-qg-ins-answer-empty) { 0em } else { gutter },
        columns: col,
        rows: sxj-qg-get-rows(envs: envs, cnts),
        align: (x, y) => {
          if calc.even(y) { return left + horizon }
          return auto
        },
        ..cnts
      )
    ]
  }
  v(-1em)
}
