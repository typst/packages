#import "@preview/hydra:0.6.3": hydra

#let cs-logos = ().to-dict()

#for protection in ("avec", "sans") {
  let prot = protection + "-protection"
  cs-logos.insert(prot, ().to-dict())

  for orientation in ("horizontal", "vertical") {
    cs-logos.at(prot).insert(orientation, ().to-dict())

    for couleur in ("noir", "blanc", "rvb") {
      cs-logos.at(prot).at(orientation).insert(couleur, image("images/" + prot + "/" + orientation + "/" + couleur + ".svg"))
    }
  }
}

// TODO: better indentation (depending on heading level) ?
// TODO: allow disable title page
// TODO: more customization
// TODO: more proper color palette
// TODO: more title page templates (i.e. internship report, course, exam, ...)
// TODO: slide template


/// Generate a list of logos next to each other.
/// If `cs-logo` is not `none`, it is either appended or prepended (depending on `append`).
//
/// `logo-list()` therefore returns the CS logo (vertical, in color) by default.
#let logo-list(cs-logo: cs-logos.sans-protection.vertical.rvb, append: true, ..other-logos) = {
  let logos = other-logos.pos()
  if cs-logo != none {
    let index = if append { logos.len() } else { 0 }
    logos.insert(index, cs-logo)
  }

  grid(
    columns: (1fr,) * logos.len(),
    ..logos.map(logo => align(horizon + center, box(logo, width: 50%, height: 75%)))
  )
}



#let template(
  title: "",
  name: "",
  dates: "",
  title-page-header: logo-list(),
  tuteur-company: [
    Foo BAR \
    #link("mailto:foo.bar@example.fr") \
  ],
  tuteur-school: [
    Foo BAR \
    #link("mailto:foo.bar@centralesupelec.fr") \
  ],
  doc
) = {
  let background = context {
    if here().page() == 1 {
      let radius = (40% * page.height) / 2
      let logo = box(cs-logos.sans-protection.vertical.blanc, width: 55%)
      let inner = circle(
        place(horizon + center, logo, dx: radius / 2),
        fill: rgb("#9c003c"),
        radius: radius
      )
      place(
        top + left,
        inner,
        dx: -radius,
        dy: 75% - radius
      )
    }
  }

  let header = context {
    if here().page() > 1 {
      set block(below: 0pt)
      grid(
        columns: (1fr, 1fr),
        inset: (y: 5pt),
        {
          set block(inset: (x: 5pt))
          align(horizon + left, cs-logos.sans-protection.horizontal.rvb)
        },
        align(right, hydra(1, skip-starting: false))
      )
      line(length: 100%)
    }
  }

  let footer = context {
    if here().page() > 1 {
      grid(
        columns: (20%, 1fr, 20%),
        align(left, name),
        align(center, strong(title)),
        align(right, counter(page).display("1/1", both: true))
      )
    }
  }



  set document(title: title)
  set page(
    paper: "a4",
    background: background,
    header: header,
    footer: footer
  )


  // Adds a "." for level 1 heading numbering
  set heading(numbering: (..nums) => numbering("1.1", ..nums) + "." * int(nums.len() == 1))

  show heading.where(level: 1): it => {
    let heading-content = text(size: 20pt, it)

    heading-content
    v(-0.6em)
    line(stroke: 2pt + rgb("#b42135"), length: 80% * measure(heading-content).width) // or B51227 ?
  }

  // Indentation
  show heading: it => pad(left: 1em * calc.min(1, it.level - 1), it)
  set par(first-line-indent: (amount: 2em, all: true), hanging-indent: 1em, justify: true)

  show heading.where(level: 1): it => pagebreak(weak: true) + it

  show heading: it => {
    if it.level > 1 {
      v(2em)
    }
    it
  }


  // Skip title page for numbering
  context counter(page).update(0)


  let title = {
    line(length: 100%, stroke: 1pt)
    text(size: 2em, strong(title))
    line(length: 100%, stroke: 1pt)
  }

  let middle = {
    v(2em)
    text(size: 1.8em, name)
    v(1em)
    text(size: 1.2em, dates)
  }

  align(center, grid(
    rows: (30%, auto, 25%, 25%),
    title-page-header,
    title,
    middle,
    grid(
      columns: (1fr, 2fr, 2fr, 1fr),
      //height: 100
      {},
      rect(fill: rgb("#00ffff00"), width: 100%, height: 100%, [
        #text(size: 1.1em, strong[Tuteur de l'entreprise:]) \
        #tuteur-company
      ]),
      rect(fill: rgb("#00ffff00"), width: 100%, height: 100%, [
        #text(size: 1.2em, strong[Tuteur de l'école:]) \
        #tuteur-school
      ]),
      {}
    )
  ))

  pagebreak()
  outline(title: "Table of contents", depth: 2)
  pagebreak(weak: true)
  doc
}

