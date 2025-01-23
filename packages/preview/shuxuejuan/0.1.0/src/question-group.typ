#import "env.typ": *
#import "utils.typ": *
#import "question.typ": *

#let sxjQG_getLevel(envs: (:)) = {
  let level = envs.level
  if level == auto {
    let questionBeforeHere = query(selector(question).before(here()))
    if questionBeforeHere.len() != 0 {
      level = calc.min(questionBeforeHere.last().level + 1, 3)
    } else { level = 1 }
  }
  return level
}

#let sxjQG_getRow(envs: (:), contents) = {
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

#let sxjQG_insertAnswerEmpty(envs: (:), contents) = {
  let a = contents.pos()
  let b = ()
  for i in a {
    b.push(i)
    b.push([])
  }
  return arguments(..b)
}

#let sxjQG_addBracketEmpty(envs: (:), contents) = {
  let r = contents.pos()
  let i = 0
  while i < r.len() {
    r.at(i) = [#sxjBracket[]#r.at(i)]
    i += 2
  }
  return arguments(..r)
}

#let sxjQG_addSuffixPunc(envs: (:), contents) = {
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

#let sxjQG_toQuestion(envs: (:), contents) = {
  let r = contents.pos()
  let i = 0
  while i < r.len() {
    r.at(i) = question(level: sxjQG_getLevel(envs: envs), r.at(i))
    i += 2
  }
  return arguments(..r)
}

#let sxjQG_rearrange(envs: (:), contents) = {
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

#let sxjQG_pcs_basic = (sxjQG_toQuestion, sxjQG_rearrange)
#let sxjQG_pcs_std = (sxjQG_insertAnswerEmpty, sxjQG_addSuffixPunc) + sxjQG_pcs_basic
#let sxjQG_pcs_tf = (sxjQG_insertAnswerEmpty, sxjQG_addSuffixPunc, sxjQG_addBracketEmpty) + sxjQG_pcs_basic

/// Core func:
/// Grab questions into one group;
/// Use sxjQG_*() to preprocess the contents you want to make into questions.
/// - col (int):
/// - gutter (length):
/// - preprocessor (array): A array of funcs to process contents
/// - contents (arguments):
/// -> content
#let sxjQuestionGroup(
  qst-align-number: "One-Lined-Compact",
  level: auto,
  col: 2,
  gutter: 1em,
  preprocessor: sxjQG_pcs_std,
  ..contents,
) = {
  v(.5em)
  context {
    let pcs = preprocessor
    let cnts = contents
    while pcs.len() != 0 {
      cnts = pcs.remove(0)(envs: (level: level, col: col, gutter: gutter), cnts)
    }
    withEnv(qst-align-number: qst-align-number)[
      #grid(
        column-gutter: 0em,
        row-gutter: 0em,
        columns: col,
        rows: sxjQG_getRow(envs: (level: level, col: col, gutter: gutter), cnts),
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
