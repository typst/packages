#import "../constants.typ" as constants
#import "units.typ" as units


// empty, w/o borders
#let empty(body) = {
  page(
    margin: 0pt,
    header: none,
    footer: none,
  )[
    #body
  ]
}

// ---

// base, ?title + body w/ borders & footer
#let base-content(title: none, body) = {
  if title != none {
    heading(level: 2, title)
  }

  align(left + horizon)[
    #body
  ]
}

#let base(title: none, body) = page(base-content(title: title, body))

// ---

// title + ?subtitle, shared by the title layouts
#let title-heading(title, subtitle: none) = {
  heading(level: 1, title)
  if subtitle != none {
    set par(leading: 0.6em)
    text(
      size: units.font.lg, 
      fill: constants.palette.grey.medium,
      subtitle
    )
  }
  v(-units.space.sm)
}

// ---

// title, (?sub-)title + bot/top ?meta w/o footer
#let title-content(
  title, 
  subtitle: none, 
  meta-top: none, 
  meta-bot: none
) = {
  if meta-top != none { 
    align(left + top, meta-top)
  }

  align(left + horizon, title-heading(title, subtitle: subtitle))

  if meta-bot != none { 
    align(left + bottom, meta-bot)
  }
}

#let title(..args) = page(header: none, footer: none, title-content(..args))

// ---

// title-split, borderless image left + title content right w/o footer
#let title-split-content(
  image,
  title,
  subtitle: none,
  meta-top: none,
  meta-bot: none,
  columns: (1fr, 1fr),
) = grid(
  columns: columns,
  rows: 100%,
  block(width: 100%, height: 100%, clip: true, {
    set std.image(width: 100%, height: 100%, fit: "cover")
    image
  }),
  pad(units.space.base, grid(
    rows: (auto, 1fr, auto),
    row-gutter: units.space.sm,
    align: left,
    meta-top,
    align(horizon, title-heading(title, subtitle: subtitle)),
    meta-bot,
  )),
)

#let title-split(..args) = page(
  margin: 0pt,
  header: none,
  footer: none,
  title-split-content(..args),
)
