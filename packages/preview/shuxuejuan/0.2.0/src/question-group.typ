#import "question.typ": *
#import "answer.typ": *

#let sxj-qg-get-level(envs) = if envs.level != auto { envs.level } else {
  calc.min(
    query(
      selector(<sxj-label-question>).before(here()),
    )
      .map(x => x.value.counter-question.at(1, default: 2))
      .last(default: 2)
      + 1,
    3,
  )
}

#let sxj-qg-ins-ans-empty(envs, cnts) = (
  cnts.map(qst => (qst, none)).flatten()
)

#let sxj-qg-to-ans(envs, cnts) = (
  cnts.chunks(2).map(((qst, ans)) => (qst, sxj-answer-jie(ans))).flatten()
)

#let sxj-qg-mv-ans-to-br(envs, cnts) = (
  cnts.chunks(2).map(((qst, ans)) => ([#sxj-bracket(ans)#qst], none)).flatten()
)

#let sxj-qg-add-punc(envs, cnts) = (
  cnts.chunks(2).map(((qst, ans)) => (qst + [；], ans)).flatten()
)

// DNF: buggy, might cause layout convergence warnings too.
#let sxj-qg-add-auto-punc(envs, cnts) = {
  let levels = query(
    selector(<sxj-label-question>).after(here()),
  ).map(x => x.value.counter-question.at(1))
  let num-to-last = levels.position(level => level != envs.level)
  if num-to-last == none { num-to-last = levels.len() }

  let grouped = cnts.chunks(2)
  let (last-qst, last-ans) = grouped.pop()
  (
    grouped.map(((qst, ans)) => (qst + [；], ans))
      + (last-qst + if num-to-last == grouped.len() + 1 [。] else [；], last-ans)
  ).flatten()
}

#let sxj-qg-to-qst-zh(envs, cnts) = (
  cnts
    .chunks(2)
    .map(
      ((qst, ans)) => (sxj-question-zh(level: envs.level, qst), ans),
    )
    .flatten()
)

#let sxj-qg-to-ans-jie(envs, cnts) = (
  cnts.chunks(2).map(((qst, ans)) => (qst, sxj-answer-jie(ans))).flatten()
)

#let sxj-qg-pack(envs, cnts) = (
  cnts
    .chunks(2)
    .map(((qst, ans)) => grid(
      columns: 1fr,
      rows: (1em + par.leading, envs.gutter),
      align(horizon, qst),
      ans,
    ))
)

#let sxj-qg-bchr-basic = (sxj-qg-to-qst-zh, sxj-qg-pack)
#let sxj-qg-bchr-std = (sxj-qg-add-punc,) + sxj-qg-bchr-basic
#let sxj-qg-bchr-tf = (sxj-qg-add-punc, sxj-qg-mv-ans-to-br) + sxj-qg-bchr-basic

#let sxj-question-group(
  col: 2,
  gutter: 0em,
  level: auto,
  batcher: sxj-qg-bchr-std,
  ..contents,
) = context {
  let envs = (
    col: col,
    gutter: gutter,
    level: sxj-qg-get-level((level: level)),
  )
  let cnts = batcher.fold(contents.pos(), (acc, pcs) => pcs(envs, acc))

  v(-.5 * par.spacing)
  grid(
    gutter: 0em,
    columns: (1fr,) * envs.col,
    rows: auto,
    ..cnts
  )
  v(-.5 * par.spacing)
}
