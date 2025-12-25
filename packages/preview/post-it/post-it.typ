#import "@preview/valkyrie:0.2.2" as z

#let base-colors-schema = z.dictionary((
  bgcolor1:   z.color(),
  bgcolor2:   z.color(),
  textcolor1: z.color(),
  textcolor2: z.color(),
))

#let default-base-colors = (
  bgcolor1:   white,
  bgcolor2:   white,
  textcolor1: blue,
  textcolor2: blue,
)

#let poster-section(
  title,
  body,
  base-colors: default-base-colors,
  fill: false,
) = {
  let fill_color = if fill {base-colors.bgcolor1} else {none}
  block(
    width: 100%,
    fill: fill_color,
    inset: 20pt,
    radius: 10pt,
    stack(
      align(center)[
        #text(
          40pt,
          weight: "extrabold",
          fill: base-colors.bgcolor2
        )[
          #title
        ]
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
  mentor,
  subtitle,
  logo,
  base-colors,
) = {
  let logo-content = {
    if logo != none {
      align(center + horizon)[#logo]
    } else {
      []
    }
  }
  let authors-content = {
    if mentor != none {
      [#author --- #mentor]
    } else {
      [#author]
    }
  }

  set text(
    fill: base-colors.textcolor2
  )
  stack(
    dir: ttb,
    block(
      fill: base-colors.bgcolor2,
      width: 100%,
      height: 100%,
      inset: 0.5in,
      grid(
        columns: (1fr, 4fr, 1fr),
        [],
        align(center + horizon)[#stack(
          spacing: 0.5in,
          text(size: 72pt, weight: "extrabold")[#title],
          text(size: 48pt)[#authors-content],
          text(size: 36pt)[#subtitle]
        )],
        logo-content
      )
    ),
  )
}


#let poster-footer(base-colors) = {
  stack(
    dir: ttb,
    block(
      fill: base-colors.bgcolor2,
      width: 100%,
      height: 100%
    )
  )
}


#let poster(
  title:        "",
  author:       "",
  width:        43in,
  height:       32.5in,
  base-colors:  none,
  mentor:       none,
  subtitle:     none,
  logo:         none,
  doc,
) = {
  // validation
  assert(base-colors != none, message: "Must provide base-colors to post-it")
  base-colors = z.parse(base-colors, base-colors-schema)

  set page(
    height: height,
    width:  width,
    margin: 0in,
  )

  set par(justify: true)

  set text(
    size: 24pt,
  )

  grid(
    columns: 1,
    rows: (13%, 83%, 4%),
    poster-header(
      title,
      author,
      mentor,
      subtitle,
      logo,
      base-colors,
    ),
    doc,
    poster-footer(base-colors)
  )
}
