#import "@preview/valkyrie:0.2.2" as z

#let base-colors-schema = z.dictionary((
  bgcolor1:   z.color(),
  bgcolor2:   z.color(),
  textcolor1: z.color(),
  textcolor2: z.color(),
))

#let poster-section(
  title,
  body,
  base-colors: none,
  title-style: none,
  fill: false,
) = {
  assert(base-colors != none, message: "Must provide base-colors to poster-section")
  assert(title-style != none, message: "Must provide title-style to poster-section")
  base-colors = z.parse(base-colors, base-colors-schema)
  assert(type(title-style) == function, message: "title-style must be a partial application of text()")

  let fill_color = if fill {base-colors.bgcolor1} else {none}
  block(
    width:  100%,
    fill:   fill_color,
    inset:  20pt,
    radius: 10pt,
    stack(
      align(center)[
        #(title-style)[#title]
        #v(0.4em)
      ],
      v(0.15em),
      line(
        length: 100%,
        stroke: (
          paint: base-colors.bgcolor2,
          thickness: 3pt,
          cap: "round"
        )
      ),
      v(0.6em),
      text(fill: base-colors.textcolor1)[#body],
      v(0.3em)
    )
  )
}

#let poster-header(
  title,
  author,
  subtitle,
  logo,
  base-colors,
) = {
  set text(fill: base-colors.textcolor2)
  set align(center + horizon)

  stack(
    dir: ttb,
    block(
      fill: base-colors.bgcolor2,
      width: 100%,
      height: 100%,
      grid(
        columns: (1fr, 4fr, 1fr),
        [],
        align(center + horizon)[#stack(
          spacing: 30pt,
          title,
          author,
          subtitle,
        )],
        if logo != none {logo} else []
      )
    ),
  )
}


#let poster-footer(base-colors) = {
  stack(
    dir: ttb,
    block(
      fill:   base-colors.bgcolor2,
      width:  100%,
      height: 100%,
    )
  )
}


#let poster(
  title:        "",
  author:       "",
  base-colors:  none,
  subtitle:     none,
  logo:         none,
  doc,
) = {
  // validation
  assert(base-colors != none, message: "Must provide base-colors to simple-research-poster")
  base-colors = z.parse(base-colors, base-colors-schema)

  grid(
    columns: 1,
    rows: (13%, 83%, 4%),
    poster-header(
      title,
      author,
      subtitle,
      logo,
      base-colors,
    ),
    doc,
    poster-footer(base-colors)
  )
}
