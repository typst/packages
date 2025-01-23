#import "env.typ": *
#import "answer.typ": *

#let lnbk = linebreak
#let pgbk = pagebreak

#let fontSize = (small: 10.5pt, medium: 12pt, large: 14pt)

#let getPageAvailableWidth() = {
  if page.margin == auto {
    return page.width - 2 * calc.min(page.width, page.height) * 2.5 / 21
  } else if type(page.margin) == dictionary {
    return page.width - (page.margin.left + page.margin.right)
  }
  return page.width - 2 * (page.margin.length + page.margin.ratio * page.width)
}

#let sxjTitle(body: none) = {
  pgbk()
  set align(center)
  set text(size: fontSize.large, weight: "extrabold")
  if body == none {
    context document.title
  } else {
    body
  }
}

#let sxjTitleSmall(body) = {
  set align(center)
  set text(size: fontSize.medium, weight: "extrabold")
  if body == none {
    context document.title
  } else {
    body
  }
}

#let sxjStudentInfo(line-length: 6, col-gutter: .5em, ..contents) = {
  let _ctts = contents.pos()
  if _ctts.len() == 0 { _ctts = ([班级], [姓名], [学号]) }
  let _index = 0
  set align(center)
  while _index < _ctts.len() {
    [#_ctts.at(_index)] + [：] + sxjBlank(line-length)
    if _index != _ctts.len() - 1 { h(col-gutter) }
    _index += 1
  }
}

#let sxjPar(indent: 2em, body) = {
  h(indent)
  body
}

#let sxjEqu(it) = {
  let spacing = envGet("equ-spacing")
  h(spacing)
  math.display(it)
  h(spacing)
}

#let sxjUnit(unit) = {
  math.equation(math.upright(unit))
}

#let sxjOptions(col: (4, 2), ..opt) = context {
  let _opts = opt.pos()
  // Initializing _contents
  let _contents = ()
  let __i = 0
  while __i < _opts.len() {
    _contents.push(
      grid(
        gutter: 0em,
        columns: (auto, auto),
        numbering("A. ", __i + 1), _opts.at(__i),
      ),
    )
    __i += 1
  }
  // Preparing _columns for grid
  let numCol
  let widthContentsMax = _contents
    .map(it => measure(it).width.pt())
    .reduce((accumulated, new) => calc.max(accumulated, new))
  let colMax = calc.min(
    calc.max(calc.floor(getPageAvailableWidth().pt() / widthContentsMax), 1),
    envGet("opt-columns-max"),
  )
  if type(col) == array {
    numCol = col.find(x => (x <= colMax))
    if numCol == none { numCol = colMax }
  } else if type(col) == int {
    numCol = calc.min(col, colMax)
  } else if col == auto {
    numCol = colMax
  }
  let columns = ()
  while numCol > 0 {
    columns.push(1fr)
    numCol -= 1
  }
  // Output
  lnbk(justify: false)
  grid(columns: columns, column-gutter: 0pt, rows: auto, row-gutter: 1em, .._contents)
}

#let sxjFooter(numPageCurrent, numPageTotal) = {
  set text(size: fontSize.small)
  set align(center)
  [共 ] + str(numPageCurrent) + [ 页]
  h(.5em)
  [共 ] + str(numPageTotal) + [ 页]
}
