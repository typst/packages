#let au-logo(
  fill: none,
  department: none,
) = {
  grid(
    columns: (auto, auto),
    align: (right, left),
    gutter: 0.5em,

    text(
      font: "au logo",
      fill: fill,
      size: 1em,
      "0",
    ),

    grid(
      rows: (auto, auto),
      align: (top, bottom),
      gutter: 5pt,

      text(
        fill: fill,
        size: 0.5em,
        weight: "bold",
        "AARHUS UNIVERSITY",
      ),

      text(
        fill: fill,
        size: 0.5em,
        department,
      ),
    ),
  )
}

#let au-seal(
  fill: none,
) = {
  text(
    font: "AU Logo",
    fill: white,
    size: 2em,
  )[1]
}

#let today = datetime.today().display("[month repr:long] [day padding:none], [year]")

