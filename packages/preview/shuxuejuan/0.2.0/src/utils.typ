#import "env.typ": *
#import "term.typ": *
#import "answer.typ": *

#let sxj-title(size: auto, body: auto) = {
  set align(center)
  set text(size: size, weight: "extrabold")
  if body == auto {
    context document.title
  } else {
    body
  }
}

#let sxj-equ(spacing: 0em, it) = {
  h(spacing)
  math.display(it)
  h(spacing)
}

#let sxj-unit(unit) = math.equation(math.upright(unit))

#let sxj-student-info(line-length: 4em, gutter: .5em, ..contents) = {
  let cnts = contents.pos()
  if cnts.len() == 0 { cnts = ([班级], [姓名], [学号]) }
  set align(center)
  cnts.map(it => [#it] + [：] + sxj-blank(line-length)).join(h(gutter))
}

#let sxj-footer(num-page-current, num-page-total) = {
  set align(center)
  [第 ] + str(num-page-current) + [ 页]
  h(.5em)
  [共 ] + str(num-page-total) + [ 页]
}

#let sxj-options(
  col: (4, 2),
  ..opts,
) = context layout(((width: width-avail, height: _)) => {
  let cnts = opts
    .pos()
    .enumerate(start: 1)
    .map(
      ((idx, opt)) => grid(
        gutter: 0em,
        columns: (auto, auto),
        numbering("A.", idx) + h(.25em), opt,
      ),
    )

  let opt-width-max = cnts
    .map(it => (measure(it).width + 1em).to-absolute().pt())
    .reduce((acc, new) => calc.max(acc, new))
  let col-max = calc.min(
    calc.max(calc.floor(width-avail.pt() / opt-width-max), 1),
    4,
  )
  let col-num = if type(col) == array {
    (col + (col-max,)).find(x => x <= col-max)
  } else if type(col) == int {
    calc.min(col, col-max)
  } else if col == auto {
    col-max
  }

  grid(
    columns: (1fr,) * col-num, column-gutter: 0em,
    rows: auto, row-gutter: 1em,
    // TODO: `left + horizon` only works fine when
    //   `opts` do not contain multiple lines of text.
    align: left + horizon,
    ..cnts
  )
})
