#let default-headline(headline, info, dict) = {
  for x in headline {
    assert(x in ("title", "name", "id", "fl"), message: "Unknown headline key'" + x + "'!")
  }

  if headline == () or headline == ("fl",) {
    return none
  }

  let number_form_box = box(
    curve(
      stroke: .5pt,
      curve.move((0em, -.5em)),
      curve.line((0em, 0em)),
      curve.line((1em, 0em)),
      curve.line((1em, -.5em)),
    ),
  )

  let student_id_boxes = range(7).map(_ => number_form_box).join([ ])

  let name-scheme = if "fl" in headline [
    #dict.firstname, #dict.lastname
  ] else [
    #dict.lastname, #dict.firstname
  ]

  let grid-content = (
    if "title" in headline {
      grid.cell(info.at("header_title", default: info.title), colspan: 2)
    },
    if "name" in headline [
      #name-scheme: #box(width: 1fr, line(length: 100%, stroke: 0.5pt))
    ] else if "id" in headline [
      // empty cell to have id on the right
    ],
    if "id" in headline [
      #dict.student_id: #student_id_boxes
    ],
  ).filter(x => x != none)

  grid(
    columns: (1fr, auto),
    column-gutter: 1cm,
    row-gutter: 2mm,
    align: (left, right),
    inset: (right: 1mm), // else student id boxes overflow
    ..grid-content,
  )
}

#let resolve-headline(headline, info, dict) = if headline == none {
  none
} else if type(headline) == str {
  default-headline((headline,), info, dict)
} else if type(headline) == array {
  default-headline(headline, info, dict)
} else if type(headline) == content {
  headline
} else {
  assert(false, message: "Unexpected value for headline: " + repr(headline))
}
