#let bibliography(ctx) = {
  pagebreak(weak: true)
  // show bibliography: set text(size: 0.96em)

  let bib-path = ctx.info.at("bibliography", default: none)
  assert(bib-path != none, message: "bibliography muss angegeben werden.")

  std.bibliography(
    bib-path,
    full: false,
    title: ctx.strings.at("bibliography"),
    style: ctx.info.at("bibliography-style")
  )
  pagebreak(weak: true)
}
