#import "@preview/hydra:0.6.3": hydra


#let get-logos() = {
  let logos-cs = (:)
  let root-path = "images/"

  for protection in ("avec", "sans") {
    let prot = protection + "-protection"
    logos-cs.insert(prot, ().to-dict())

    for orientation in ("horizontal", "vertical") {
      logos-cs.at(prot).insert(orientation, ().to-dict())

      for couleur in ("noir", "blanc", "rvb") {
        logos-cs.at(prot).at(orientation).insert(couleur, image(root-path + prot + "/" + orientation + "/" + couleur + ".svg"))
      }
    }
  }
  logos-cs
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
// #let logo-list(cs-logo: logos-cs.sans-protection.vertical.rvb, append: true, ..other-logos) = {
#let logo-list(cs-logo, append: true, ..other-logos) = {
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

#let get-heading-pagebreak() = {
  state("heading-pagebreak").get()
}

#let set-heading-pagebreak(value) = {
  state("heading-pagebreak").update(value)
}

#let reset-heading-pagebreak() = context {
  set-heading-pagebreak(state("default-heading-pagebreak").get())
}

#let enable-numbering(reset: true) = context {
  if reset {
    counter(page).update(1)
  }
  state("numbering-enabled").update(true)
}

#let disable-numbering() = context {
  state("numbering-enabled").update(false)
}



#let tuteurs(
  tuteur-company: [
    Foo BAR \
    #link("mailto:foo.bar@example.fr") \
  ],
  tuteur-school: [
    Foo BAR \
    #link("mailto:foo.bar@centralesupelec.fr") \
  ]) = {
  grid(
    columns: (1fr, 2fr, 2fr, 1fr),
    {},
    {
      text(size: 1.1em, strong[Tuteur de l'entreprise:\ ])
      tuteur-company
    },
    {
      text(size: 1.2em, strong[Tuteur de l'école:\ ])
      tuteur-school
    },
    {}
  )
}


#let template(
  title: "",
  footer-title-size: 1em,
  name: "",
  footer-name-size: 0.8em,
  dates: "",
  title-page-header: [],
  title-page-bottom: [],
  heading-pagebreak: true,
  /// Vertical spacing added before level > 1 headings, and for level 1 heading
  /// with pagebreak disabled.
  pre-heading-spacing: 2em,
  enable-title-page: true,
  logos: none,
  doc
) = {
  let cs-logos = if logos == none { get-logos() } else { logos }

  let background = context {
    if here().page() == 1 and enable-title-page {
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
    if state("footer-enabled").get() {
      let name-content = {
        set text(size: footer-name-size)
        align(left, name)
      }
      let title-content = {
        set text(size: footer-title-size)
        align(center, title)
      }
      grid(
        columns: (20%, 1fr, 20%),
        name-content,
        title-content,
        if state("numbering-enabled").get() {
          let numbering-style-roman = state("numbering-style-roman").get()
          let style = if numbering-style-roman { "(i)" } else { "1/1" }
          align(right, counter(page).display(style, both: not numbering-style-roman))
        }
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


  set-heading-pagebreak(heading-pagebreak)
  state("default-heading-pagebreak").update(heading-pagebreak)

  state("footer-enabled").update(false)
  state("numbering-style-roman").update(true)
  disable-numbering()

  // Adds a "." for level 1 heading numbering
  set heading(numbering: (..nums) => numbering("1.1", ..nums) + "." * int(nums.len() == 1))

  show heading.where(level: 1): it => {
    let heading-content = text(size: 20pt, it)

    heading-content
    v(-0.6em)
    line(stroke: 2pt + rgb("#b42135"), length: 80% * measure(heading-content).width) // or B51227 ?
  }

  show heading.where(level: 1): it => {
    if get-heading-pagebreak() {
      pagebreak(weak: true)
    }
    it
  }

  show heading: it => {
    if it.level > 1 or not get-heading-pagebreak() {
      v(pre-heading-spacing)
    }
    it
  }



  let title-content = {
    line(length: 100%, stroke: 1pt)
    text(size: 2em, title)
    line(length: 100%, stroke: 1pt)
  }

  let middle = {
    v(2em)
    text(size: 1.8em, name)
    v(1em)
    text(size: 1.2em, dates)
  }

  ////////////////
  // Title page //
  ////////////////
  if enable-title-page {
    align(center, grid(
      rows: (30%, auto, 25%, 25%),
      title-page-header,
      title-content,
      middle,
      title-page-bottom
    ))

    pagebreak()
  }


  //////////////
  // Outlines //
  //////////////
  state("footer-enabled").update(true)
  enable-numbering()

  counter(page).update(1)

  set-heading-pagebreak(false)
  outline(title: "Table of contents", depth: 2, target: heading.where(supplement: [Section]))
  context {
    if query(heading.where(supplement: [Appendix])).len() > 0 {
      outline(title: "Appendix", target: heading.where(supplement: [Appendix]))
    }
  }
  reset-heading-pagebreak()

  pagebreak(weak: true)
  counter(page).update(1)
  state("numbering-style-roman").update(false)

  ///////////////
  // Main body //
  ///////////////
  doc
}


#let appendix(body) = {
  // should be true, but otherwise bugs ...
  // typst bug ?
  pagebreak(weak: false)
  pagebreak(weak: false)
  heading(numbering: none)[Appendixes]
  // TODO: different (underline color, ... ?)
  set heading(numbering: "A.", supplement: [Appendix])
  set-heading-pagebreak(false)
  counter(heading).update(0)
  body
}
