#let palette = (
  rgb(156, 92, 58),
  rgb(62, 107, 135),
  rgb(143, 31, 36),
  rgb(106, 76, 147),
  rgb(196, 152, 27),
  rgb(147, 76, 90),
  rgb(24, 82, 33)
)

#let get-color(location: location) = {
  let index = counter(heading).at(location).first() - 1
  return palette.at(calc.rem(index, palette.len()))
}

#let deep-merge(base, override) = {
  let result = (:)
  
  // Copy all keys from base
  for (key, value) in base {
    result.insert(key, value)
  }
  
  // Apply overrides
  for (key, value) in override {
    // Skip empty arrays - keep the base value
    if type(value) == array and value.len() == 0 {
      continue
    }
    
    if key in base and type(value) == dictionary and type(base.at(key)) == dictionary {
      result.insert(key, deep-merge(base.at(key), value))
    } else {
      result.insert(key, value)
    }
  }
  
  result
}

#let corner = 2pt

#let container(
  body,
  alignment: start,
) = context {
  block(
    stroke: get-color(location: here()),
    radius: corner+1pt,
    inset: (x: 1em, y: 1em),
  )[
    #align(alignment)[
      #body
    ]
  ]
}
    

#let cheatsheet(
  info: (
    title: "",
    authors: (),
  ),
  headers: (
    align: center,
    numbering: true,
  ),
  layout: (:),
  body
) = {
  
  let defaults =  (
    font-size: 6pt,
    margin: (
      x: 10pt,
      y: 20pt
    ),
    columns: (
      count: 4,
      gutter: 4pt
    ),
  )
  let layout = deep-merge(defaults, layout)
  
  let authors_array = if not type(info.authors) == array {
    (info.authors,)
  } else {
    info.authors
  }
  
  set page(
    paper: "a4",
    flipped: true,
    margin: layout.margin,
    header: [
      #grid(
        columns: (1fr, 1fr, 1fr),
        align: (left, center, right),
        [
          #text(datetime.today().display("[month repr:long] [day], [year]"), weight: "bold")
        ],
        [
          #text(if info.title == "" { "Cheatsheet" } else { info.title + " Cheatsheet" }, weight: "bold")
        ],
        [
          #text(authors_array.join(", ", last: " & "), weight: "bold")
        ]
      )
      #v(-3pt)
      #line(length: 100%, stroke: black)
    ],
    footer: context [
      #align(center)[
        #text(weight: "bold")[#counter(page).display("1 / 1", both: true)]
      ]
    ],
  )
  
  let get-numbered-heading(it, num: none) = {
    if headers.numbering { if num != none { [#num. #it.body] } else { it } } else { it.body }
  }
  
  set text(
    size: layout.font-size,
    font: ("Roboto", "Arial", "Helvetica", "Liberation Sans", "DejaVu Sans"),
    lang: "en",
    region: "gb"
  )
  set heading(numbering: "1.1.")
           
  show heading.where(level: 1): it => {
    set text(white, size: layout.font-size)
    set align(headers.align)
  
    block(
      radius: corner,
      inset: 1.0mm,
      width: 100%,
      above: layout.font-size,
      below: layout.font-size,
      fill: get-color(location: it.location()),
      get-numbered-heading(it)
    )
  }
  
  show selector.or(
    heading.where(level: 2),
    heading.where(level: 3),
  ): it => {
    let num = counter(heading).at(it.location()).last()
    let stroke-style = if it.level == 3 { "dashed" } else { none }
    let weight = if it.level == 3 { "regular" } else { "bold" }
  
    box(inset: (bottom: 0.4em), grid(
      columns: (1fr, auto, 1fr),
      align: horizon + start,
      column-gutter: 1em,
      line(length: 100%, stroke: (
        paint: get-color(location: it.location()),
        dash: stroke-style,
        cap: "round"
      )),
      text(
        fill: get-color(location: it.location()),
        weight: weight,
        size: layout.font-size,
      )[#get-numbered-heading(it, num: num)],
      line(length: 100%, stroke: (
        paint: get-color(location: it.location()),
        dash: stroke-style,
        cap: "round"
      )),
    ))
  }
  
  show figure: set figure(supplement: [])
  
  columns(layout.columns.count, gutter: layout.columns.gutter, body)
}