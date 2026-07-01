#let logo_path = "./res/PKU.svg"
#let logo_str = read(logo_path).replace("920f14", "cccccc")

#let whole-page-title(meta, logo) = {
  set page(margin: 0pt, header: none, footer: none)

  // Logo
  place(
    center + top,
    dx: 40%,
    dy: 10pt,
  )[
    #set image(width: 100%)
    #logo
  ]

  // Info panel
  place(
    bottom + left,
    dx: 0pt,
    dy: -20%,
    rect(fill: rgb("cccccc"), width: 100%, height: 10pt),
  )
  place(
    bottom + left,
    dx: 24pt,
    dy: -20%,
    text(
      meta.course-name,
      size: 36pt,
      font: ("Source Han Serif SC"),
      baseline: -0.6em,
    ),
  )
  place(
    bottom + left,
    dx: 24pt,
    dy: -20%,
    box([
      #set text(
        size: 20pt,
        font: ("Source Han Serif SC"),
        baseline: 1em,
      )
      #set align(horizon)
      #meta.author-info
    ]),
  )
}

#let simple-title(meta, logo) = {
  set align(horizon)
  stack(
    dir: ltr,
    spacing: 8pt,
    {
      set image(width: 30%)
      logo
    },
    context line(
      length: 20% * page.width,
      angle: 90deg,
      stroke: (
        thickness: 0.8pt,
        paint: gray.lighten(60%),
      ),
    ),
    {
      set align(left)
      block[
        #set text(font: (
          "New Computer Modern",
          "Source Han Serif SC",
        ))

        #text(size: 28pt, weight: "bold")[
          #meta.course-name
        ]

        #text(size: 18pt)[
          #meta.serial-str
        ]

        #text(size: 12pt, font: "STFangsong")[
          #meta.author-info
        ]
      ]
    },
  )
}

#let header = meta => {
  set text(size: 10.5pt, font: "Source Han Serif SC")
  block(
    grid(
      columns: (1fr, 1fr),
      align(left + horizon, meta.course-name), align(right + horizon, meta.serial-str),
    ),
  )
  place(line(length: 100%, stroke: 0.5pt), dy: 0.5em)
}

#let footer = meta => {
  let cur = context counter(page).get().at(0)
  let tot = context counter(page).final().at(0)
  return align(center)[
    #set text(size: 10.5pt)
    #cur / #tot
  ]
}

#let theme(meta) = {
  let logo = if "logo" in meta {
    meta.logo
  } else {
    image.decode(logo_str)
  }
  return (
    title: (
      whole-page: {
        whole-page-title(meta, logo)
        pagebreak(weak: true)
      },
      simple: {
        set align(center)
        block(simple-title(meta, logo))
      },
    ),
    page-setting: (
      header: header(meta),
      footer: footer(meta),
    ),
    fonts: (
      heading: (
        "New Computer Modern",
        "Source Han Serif SC",
      ),
      text: (
        "New Computer Modern",
        "Source Han Serif SC",
      ),
      equation: (
        "New Computer Modern Math",
        "Source Han Serif SC",
      ),
    ),
  )
}