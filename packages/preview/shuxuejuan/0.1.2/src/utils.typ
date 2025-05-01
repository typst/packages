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
  let _ctts = contents.pos()
  if _ctts.len() == 0 { _ctts = ([班级], [姓名], [学号]) }
  let _index = 0
  set align(center)
  while _index < _ctts.len() {
    [#_ctts.at(_index)] + [：] + sxj-blank(line-length)
    if _index != _ctts.len() - 1 { h(gutter) }
    _index += 1
  }
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
/// - opt (arguments): Options you give.
/// -> content
#let sxj-options(col: (4, 2), ..opt) = context {
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
  let col-num
  let width-cnts-max = _contents
    .map(it => measure(it).width.pt())
    .reduce((accumulated, new) => calc.max(accumulated, new))
  let col-max = calc.min(
    calc.max(calc.floor((_get-page-width-available() + 0%-20pt).length.pt() / width-cnts-max), 1),
    env-get("opt-columns-max"),
  )
  if type(col) == array {
    col-num = col.find(x => (x <= col-max))
    if col-num == none { col-num = col-max }
  } else if type(col) == int {
    col-num = calc.min(col, col-max)
  } else if col == auto {
    col-num = col-max
  }
  let columns = ()
  while col-num > 0 {
    columns.push(1fr)
    col-num -= 1
  }
  // Output
  lnbk(justify: false)
  grid(columns: columns, column-gutter: 0pt, rows: auto, row-gutter: 1em, .._contents)
}

#let sxj-footer(num-page-current, num-page-total) = {
  set text(size: font-size.small)
  set align(center)
  [第 ] + str(num-page-current) + [ 页]
  h(.5em)
  [共 ] + str(num-page-total) + [ 页]
}
