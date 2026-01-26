#import "env.typ": *
#import "answer.typ": *

#let lnbk = linebreak
#let pgbk = pagebreak

#let font-size = (small: 10.5pt, medium: 12pt, large: 14pt)

#let _get-page-width-available() = {
  if page.margin == auto {
    return page.width - 2 * calc.min(page.width, page.height) * 2.5 / 21
  } else if type(page.margin) == dictionary {
    return page.width - (page.margin.left + page.margin.right)
  }
  return page.width - 2 * (page.margin.length + page.margin.ratio * page.width)
}

/// Print a BIG TITLE at the start of a page.
/// - body (auto, string, content):
///   the title you want to print,
///   when set to auto (by default), `document.title` would be used.
/// -> content
#let sxj-title(body: auto) = {
  pgbk()
  set align(center)
  set text(size: font-size.large, weight: "extrabold")
  if body == auto {
    context document.title
  } else {
    body
  }
}

/// Print a small title at the center of a line.
/// - body (content): The small title you want to print.
/// -> content
#let sxj-title-small(body) = {
  set align(center)
  set text(size: font-size.medium, weight: "extrabold")
  if body == none {
    context document.title
  } else {
    body
  }
}

/// A form of info for students to fill.
/// - line-length (int): Length of each line.
/// - gutter (length): Column gutter between two categories.
/// - contents (arguments): The info required.
/// -> content
#let sxj-student-info(line-length: 6, gutter: .5em, ..contents) = {
  let cnts = contents.pos()
  if cnts.len() == 0 { cnts = ([班级], [姓名], [学号]) }
  set align(center)
  cnts.map(it => [#it] + [：] + sxj-blank(line-length)).join(h(gutter))
}

#let sxj-par(indent: 2em, body) = {
  h(indent)
  body
}

#let sxj-equ(it) = {
  let spacing = env-get("equ-spacing")
  h(spacing)
  math.display(it)
  h(spacing)
}

/// Print unit in the right variants.
/// - unit (content): Unit you want to print like `km/h` etc.
/// -> content
#let sxj-unit(unit) = {
  math.equation(math.upright(unit))
}

/// Print well-aligned options numbering `A.`, `B.`, `C.`...
/// - col (array):
///   An array of preferred column(int).
///   Try automatically from the first to last
///   until all options have enough space to present.
/// - opts (arguments): Options you give.
/// -> content
#let sxj-options(col: (4, 2), ..opts) = context {
  let cnts = opts
    .pos()
    .enumerate(start: 1)
    .map(it => {
      let (i, opt) = it
      grid(
        gutter: 0em,
        columns: (auto, auto),
        numbering("A. ", i), opt,
      )
    })

  let width-max = cnts.map(it => measure(it).width.pt()).reduce((acc, new) => calc.max(acc, new))
  let col-max = calc.min(
    calc.max(calc.floor((_get-page-width-available() + 0% - 20pt).length.pt() / width-max), 1),
    env-get("opt-columns-max"),
  )
  let col-num = if type(col) == array {
    let found = col.find(x => (x <= col-max))
    if found != none { found } else { col-max }
  } else if type(col) == int {
    calc.min(col, col-max)
  } else if col == auto {
    col-max
  }

  lnbk(justify: false)
  grid(columns: (1fr,) * col-num, column-gutter: 0pt, rows: auto, row-gutter: 1em, ..cnts)
}

#let sxj-footer(num-page-current, num-page-total) = {
  set text(size: font-size.small)
  set align(center)
  [第 ] + str(num-page-current) + [ 页]
  h(.5em)
  [共 ] + str(num-page-total) + [ 页]
}
