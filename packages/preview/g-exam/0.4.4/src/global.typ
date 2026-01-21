#import "@preview/oxifmt:1.0.0": strfmt

#let __g-question-number = counter("g-question-number")
#let __g-question-point = state("g-question-point", 0)
#let __g-question-points-position-state = state("g-question-points-position", left)
#let __g-question-text-parameters-state = state("question-text-parameters:", none)

#let __g-localization = state("g-localization")
#let __g-show-solutions = state("g-show-solutions", false)

#let __g-decimal-separator = state("g-decimal-separator", ".")

#let __g-solution-color-state = state("g-solution-color", rgb("#0038A7"))


#let __g-default-localization = (
    grade-table-queston: "Question",
    grade-table-total: "Total",
    grade-table-points: "Points",
    grade-table-grade: "Grade",
    point: "point",
    points: "points",
    page: "Page",
    page-counter-display: "1 of 1",
    family-name: "Surname",
    given-name: "Name",
    group: "Group",
    date: "Date",
    draft-label: "Draft",
  )
  
#let __g-question-numbering(..args) = {
  let nums = args.pos()
  if nums.len() == 1 {
    numbering("1. ", nums.last())
  }
  else if nums.len() == 2 {
    numbering("(a) ", nums.last())
  }
  else if nums.len() == 3 {
    numbering("(i) ", nums.last())
  }
}

#let __g-paint-tab(
    points: none, 
    decimal-separator: "."
  ) = {
  if points != none {
    let label-point = context __g-localization.final().points
    if points == 1 {
      label-point = context __g-localization.final().point
    }

    [(#emph[#strfmt("{0}", calc.round(points, digits: 2), fmt-decimal-separator: decimal-separator) #label-point])]
  }
}

#let __g-solution-color(solution-color: none) = {
    assert(solution-color == none or type(solution-color) == color or type(solution-color) == str, 
      message: "Invalid solution color"
    )

    if solution-color == none {
      solution-color = __g-solution-color-state.final()    
    }

    if type(solution-color) == str {
      solution-color = str.to.rgb(solution-color)
    }

    return  solution-color
}

#let __g_page-margin() = {
  let margins = (top: auto, bottom:auto)

  if type(page.margin) == dictionary {
    if "rest" in page.margin {
      margins.top = page.margin.rest
      margins.bottom = page.margin.rest
    }

    if "y" in page.margin {
      margins.top = page.margin.y
      margins.bottom = page.margin.y
    }

    if "top" in page.margin {
      margins.top = page.margin.top
    }

    if "bottom" in page.margin {
      margins.bottom = page.margin.bottom
    }
  }
  else {
    margins.bottom = page.margin
  }

  if margins.top == auto {
      let min-dim = calc.min(
        if page.width == auto { 210mm } else { page.width },
        if page.height == auto { 297mm } else { page.height },
    )
    margins.top = 2.5 / 21 * min-dim
  }

  if margins.bottom == auto {
      let min-dim = calc.min(
        if page.width == auto { 210mm } else { page.width },
        if page.height == auto { 297mm } else { page.height },
    )
    margins.bottom = 2.5 / 21 * min-dim
  }

  return  margins
}
