#import "env.typ": *
#import "utils.typ": *
#import "question.typ": *

#let sxj-qg-get-level(envs: (:)) = {
  let level = envs.level
  if level == auto {
    let questionBeforeHere = query(selector(question).before(here()))
    if questionBeforeHere.len() != 0 {
      level = calc.min(questionBeforeHere.last().level + 1, 3)
    } else { level = 1 }
  }
  return level
}

#let sxj-qg-get-rows(envs: (:), contents) = {
  let qtNum = int(contents.pos().len() / 2)
  let col = envs.col
  let rowNum = calc.ceil(qtNum / col)
  let rows = ()
  let i = 0
  while i < rowNum {
    rows.push(auto)
    rows.push(envs.gutter)
    i += 1
  }
  return rows
}

#let sxj-qg-ins-answer-empty(envs: (:), contents) = {
  let a = contents.pos()
  let b = ()
  for i in a {
    b.push(i)
    b.push([])
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
  /// Tag: Codes for auto punc
  // let numQst = query(selector(<lblQuestion>).after(here())).map(x => x.value.last())
  // numQst.remove(0)
  // numQst = numQst.position(x => x < numQst.first())
  ///
  let r = contents.pos()
  let i = 0
  while i < r.len() {
    /// Tag: Codes for auto punc
    // numQst -= 1
    // Bug: Don't know why but this line of code makes some numberings wrong
    // r.at(i) = [#r.at(i)] + { if numQst != 0 [；] else [。] }
    ///
    r.at(i) = [#r.at(i)；]
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
/// - col (int): The number of columns you want for this group of question
/// - level (int, auto):
///   The level for each question,
///   when set to auto, it would be the next level of current question level.
/// - gutter (length):
///   The gutter between two rows of questions,
///   or the height for each question's answer.
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
  level: auto,
  col: 2,
  gutter: 1em,
  preprocessor: sxj-qg-pcs-std,
  ..contents,
) = {
  v(.5em)
  context {
    let pcs = preprocessor
    let cnts = contents
    while pcs.len() != 0 {
      cnts = pcs.remove(0)(envs: (level: level, col: col, gutter: gutter), cnts)
    }
    with-env(qst-align-number: qst-align-number)[
      #grid(
        column-gutter: 0em,
        row-gutter: 0em,
        columns: col,
        rows: sxj-qg-get-rows(envs: (level: level, col: col, gutter: gutter), cnts),
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
