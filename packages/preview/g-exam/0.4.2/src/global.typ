#import "@preview/oxifmt:0.2.1": strfmt

#let __g-question-number = counter("g-question-number")
#let __g-question-point = state("g-question-point", 0)
#let __g-question-points-position-state = state("g-question-points-position", left)
#let __g-question-text-parameters-state = state("question-text-parameters:", none)

#let __g-localization = state("g-localization")
#let __g-show-solution = state("g-show-solution", false)

#let __g-decimal-separator = state("g-decimal-separator", ".")

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