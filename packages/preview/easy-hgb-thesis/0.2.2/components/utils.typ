/// Sets the line spacing to the given spacing.
///  - spacing (length, number): The spacing to use. If a length is provided, the top-edge to top-edge distance will be set to this value. If a number is provided, top-edge to top-edge distance will be set to this multiple of the line height.
#let line-spacing(spacing, doc) = context {
  let line-height = measure(text("x")).height
  let line-height = (line-height / 1em.to-absolute()) * 1em
  set par(leading: if type(spacing) == length {
    spacing - line-height
  } else {
    line-height * (spacing - 1)
  })
  doc
}

#let sans-fonts = state("_eht-sans-fonts", (
  "Libertinus Sans",
  "New Computer Modern Sans",
  "Inter",
  "Arial",
))

#let apply-sans-font(other-fonts: (), body) = context {
  let fonts = {
    other-fonts
    sans-fonts.get()
    if type(text.font) == array { text.font } else { (text.font,) }
  }
  set text(font: fonts.dedup())
  body
}

#let mark-heading-boundaries(body) = [
  // This makes distinction between heading and references (f.e. in outline) possible
  #metadata(none) <_eht-pre-heading>
  #body
  #metadata(none) <_eht-post-heading>
]

#let with-inside-heading(func) = context {
  let next-after-heading = query(selector(<_eht-post-heading>).after(here()))

  let is-inside-heading = next-after-heading.len() > 0
  if is-inside-heading {
    next-after-heading = next-after-heading.first()
    // If there is a _ght-pre-heading between here and next-after-heading, we are outside a heading
    let pre-headings = query(
      selector(<_eht-pre-heading>)
        .after(here())
        .before(next-after-heading.location()),
    )
    if pre-headings.len() > 0 {
      is-inside-heading = false
    }
  }

  func(is-inside-heading)
}

#let nearest-top-level-heading(location) = {
  let next-pre-heading = query(
    selector(<_eht-pre-heading>).after(location),
  ).first(default: none)
  if (
    next-pre-heading == none
      or query(
        selector(<_eht-post-heading>)
          .after(location)
          .before(next-pre-heading.location()),
      ).len()
        > 0
  ) {
    // There has to we have to be inside a heading currently, so we can just return the previous pre-heading
    return query(selector(<_eht-pre-heading>).before(location)).last(
      default: none,
    )
  } else {
    return next-pre-heading.location()
  }
}

#let hierarchical-numbering(style, levels: 1) = (..ns) => {
  numbering(style, ..counter(heading).get().chunks(levels).first(), ..ns)
}

#let reset-listing-counters(value: 0) = {
  counter(figure.where(kind: image)).update(value)
  counter(figure.where(kind: table)).update(value)
  counter(figure.where(kind: raw)).update(value)
  counter(math.equation).update(value)
}
