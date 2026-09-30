#import "cnam-deps.typ": *
#import "cnam-helper.typ": *

#let part-outline = state("part-outline", false)

#let cnam-titlepage(
  thesis-info
) = context {
  set text(font: cnam-fonts.body)

  set page(
    paper: states.paper-size.get(),
    header: none,
    footer: none,
    margin: (left: 13mm, right:13mm, top: 15mm, bottom: 5mm),
  )

  let img-dy = -0.5cm
  let position
  let logo-content = if thesis-info.logo != none {
    let logo = thesis-info.logo
    if type(logo) == array {
      position = top
      row-img(logo)
    } else {
      position = top + right
      logo
    }
  } else {
    position = top + right
    image("resources/logo/cnam.png", height: 5%)
  }
  place(position, dy: img-dy)[#logo-content]

  v(1fr)
  align(center)[
    #text(size: 11pt)[*Conservatoire national des arts et métiers*]

    #v(0.2cm)
    #text(size: 11pt)[#smallcaps[*École doctorale #thesis-info.doctoral-school*]]

    #v(0.2cm)
    #text(size: 11pt)[*#thesis-info.laboratory*]

    #text(size: 25pt)[*Thèse de doctorat*]

    #text(size: 11pt)[
      #show: par.with(leading: 11pt)
      Présentée par : *#states.author.get()* \
      Soutenue le : *#thesis-info.defense-date* \
      Discipline : *#thesis-info.discipline* \
      Spécialité : *#thesis-info.speciality*
    ]

    #v(1cm)
    #box(stroke: 0.8pt + states.colors.get().primary, width: 16.5cm, inset: (top: 1em, bottom: 1em),  radius: 6pt)[
      #set text(size: 18pt)
      *#states.title.get()*
    ]

    #v(0.2cm)
    #text(size: 12pt)[
      #smallcaps[*Thèse dirigée par :*] \
      #let lb = if thesis-info.supervisor.len() > 1 {
        linebreak()
      }
      #for (name, title, institution) in thesis-info.supervisor {
        text[*#name*, #title, #institution]
        lb
      }

      #if thesis-info.co-supervisor.len() > 0 [
        #v(0.25cm)
        #smallcaps[*Et co-dirigée par :*] \
        #let lb = if thesis-info.co-supervisor.len() > 1 {
          linebreak()
        }
        #for (name, title, institution) in thesis-info.co-supervisor {
          text[*#name*, #title, #institution]
          lb
        }
      ]
    ]

    #if thesis-info.committee.len() > 0 {
      v(1cm)
      set text(size: 11pt)
      set table.hline(stroke: 0.5pt)
      table(
        columns: (auto, 1fr, auto),
        stroke: none,
        align: left,
        // table.hline(),
        table.cell(colspan: 3)[*Jury*],
        table.hline(),
        ..for (name, position, role) in thesis-info.committee {
          ([*#name*], position, role)
        },
        table.hline()
      )
    }
  ]
  v(1fr)

  if thesis-info.dedication != none {
     set page(
      paper: states.paper-size.get(),
      header: none,
      footer: none,
      margin: auto
    )

    if states.open-right.get() {
      pagebreak(to: "odd")
    }

    align(right + horizon)[#text(size: 11pt, style: "italic")[#thesis-info.dedication]]
  }
}

#let cnam-theme(colors: default-colors, it) = {
  // Headings
  show heading.where(level: 1): it => {
    if not states.open-right.get() {
      pagebreak(weak: true)
    }

    // Reset counters
    reset-counters

    set align(right)
    set underline(stroke: 2pt + colors.secondary, offset: 8pt)

    if it.numbering != none {
      let type-chapter = if states.isappendix.get() {states.localization.get().appendix} else {states.localization.get().chapter}
      v(5em)
      block[
        #text(size: 17pt, fill: colors.primary)[#smallcaps[*#type-chapter*]] \
        #text(counter(heading).display(states.num-heading.get()), size: 75pt, fill: colors.primary)
        #v(-0.5em)
        #text(underline(stroke: 0.75pt, offset: 0.5em, extent: 0.15em, it.body), size: 25pt)
      ]
      v(5em)
    } else {
      v(1em)
      text(underline(stroke: 0.75pt, offset: 0.5em, extent: 0.15em, it.body), size: 25pt)
      v(2.5em)
    }
  }

  show heading.where(level: 2): it => {
    block(above: 2em, below: 1.25em)[
      #it
    ]
  }

  show heading.where(level: 3): it => {
    block(above: 1.25em, below: 1.25em)[
      #it
    ]
  }

  // References
  show ref: set text(fill: colors.primary)

  // Links
  show link: it => if type(it.dest) == str {
    if it.dest.starts-with("https://") or it.dest.starts-with("http://") {
      set text(fill: colors.primary)
      underline(stroke: (dash: "dashed"), offset: 2.5pt, it)
    } else if it.dest.starts-with("mailto:") {
      set text(fill: colors.primary)
      underline(
        stroke: (dash: "dashed"),
        offset: 2.5pt,
        it.dest.slice(7)
      )
    } else {
      it
    }
  } else {
    it
  }

  // Lists
  set list(marker: ([#text(fill:colors.primary, size: 1em)[#sym.bullet]], [#text(fill:colors.primary, size: 1em)[#sym.triangle.filled.r]], [#text(fill:colors.primary, size: 1.1em)[--]]))
  set enum(
    numbering: (..n) => {
      set text(fill: colors.primary)
      n = n.pos()
      let level = n.len()
      if level == 1 {
        numbering("1.", ..n)
      } else if level == 2 {
        numbering("a.", ..n.slice(1))
      } else {
        // panic("Enum level not set")
        numbering("i.", ..n)
      }
    },
    full: true,
  )
  show: checklist.with(fill: luma(95%), stroke: colors.primary, radius: .2em)

  // Tables
  show table.cell.where(y: 0): set text(weight: "bold")
  set table(
    stroke: (_, y) => (
      top: if y <= 1 {0.75pt} else {0pt},
      bottom: 0.75pt
    ),
  )

  // Algorithmes
  show figure.where(kind: "algorithm"): it => {
    set figure.caption(position: top)
    let algo-caption = if it.caption != none {box(inset: (top: 0.75em, bottom: 0.75em), it.caption)}

    grid(
      align: left,
      stroke: (_, y) => (
        top: if y <= 1 {0.75pt} else {0pt},
        bottom: 0.75pt
      ),
      algo-caption,
      box(inset: (left: 0.5em, right: 0.5em), it.body),
    )
  }

  show figure.caption.where(kind: "algorithm"): it => {
    let num = counter(figure.where(kind: "algorithm")).display(it.numbering)
    [
      #strong(it.supplement + " " + num)
      #if it.body != [] [
        #it.separator
        #it.body
      ]
    ]
  }

  // Outline
  set outline.entry(fill: box(width: 1fr, repeat(gap: 0.5em)[.]))
  show outline.entry: it => {
    show linebreak: none
    if it.element.func() == heading {
      let number = it.prefix()
      let section = it.element.body
      let item = none

      // ligne "inner" sans fill pour les parts et front-matter
      let is-frontmatter = states.isfrontmatter.at(it.element.location())
      let is-part = part-outline.at(it.element.location())
      let inner-no-fill = [#it.body() #h(1fr) #it.page()]
      let inner = if is-frontmatter or is-part { inner-no-fill } else { it.inner() }

      if it.level == 1 {
        block(above: 1.15em, below: 0em)
        v(0.5em)
        let fill-color = if is-frontmatter or is-part { black } else { colors.primary }
        item = text(fill: fill-color)[*#number #inner*]
      } else if it.level == 2 {
        block(above: 1em, below: 0em)
        item = [#h(1em) #number #inner]
      } else {
        block(above: 1em, below: 0em)
        item = [#h(2em) #number #inner]
      }
      link(it.element.location(), item)
    } else if it.element.func() == figure {
      block(above: 1.15em, below: 0em)
      v(0.25em)

      link(it.element.location(), [#text([#it.prefix().], fill: colors.primary) #h(0.2em) #it.inner()])
    } else {
      it
    }
  }

  let page-header = context {
    // No header on chapter opening pages
    set par(first-line-indent: 0em) if states.par-indent.get()
    if is-chapter-page() { return }

    show linebreak: none

    let h1 = text(fill: colors.primary)[#smallcaps[*#hydra(1)*]]
    let h2 = hydra(2)
    if calc.odd(here().page()) {
      grid(
        columns: (1fr,)*2,
        align: (left, right),
        [#h2],
        [#h1],
      )
    } else {
      grid(
        columns: (1fr,)*2,
        align: (left, right),
        [#h1],
        [#h2],
      )
    }
    place(dx: 0%, dy: 12%)[#line(length: 100%, stroke: 0.5pt)]

    v(0.5em)
  }

  set page(
    paper: states.paper-size.get(),
    header: page-header,
  )

  it
}

// Part
#let part-cnam(title) = context {
  set page(
    header: none,
    footer: none,
    numbering: none
  )

  set align(center + horizon)

  if states.open-right.get() {
    pagebreak(weak: true, to:"odd")
  }

   box(width: 90%, inset: 5em, stroke: 2pt + states.colors.get().primary, radius: 2em)[
    #set text(size: 3em)
    *#title*
  ]

  part-outline.update(true)
  show heading: none
  heading(numbering: none)[
    #v(0.75em)
    #box[#title]
  ]
  part-outline.update(false)

  if states.open-right.get() {
    pagebreak(weak: true, to:"odd")
  }
}

#let minitoc-cnam = context {
  set par(first-line-indent: 0em) if states.par-indent.get()
  let toc-header = states.localization.get().minitoc
  block(above: 3.5em)[
    #text([*#toc-header*])
    #v(-0.75em)
  ]

  let miniline = line(stroke: 0.5pt, length: 100%)

  miniline
  v(0.5em)
  suboutline(target: heading.where(outlined: true, level: 2))
  miniline
}

// Boxes - Definitions
#let custom-box-cnam(title: none, icon: "info", color: rgb(29, 144, 208), body) = {
  showybox(
    title: box-title(color-svg("resources/images/icons/" + icon + ".svg", color, width: 0.9em), text(fill: black)[#title]),
    title-style:(
      sep-thickness: 0pt,
    ),
    frame: (
      title-color: color.lighten(75%),
      border-color: color,
      body-color: color.lighten(95%),
      thickness: (left: 2pt, rest: 0.5pt),
      radius: 2.5pt,
    ),
    align: center,
    breakable: true
  )[#body]
}

#let boxeq-cnam(body) = context _boxeq(stroke: 1pt + states.colors.get().primary, radius: 5pt, body)

#let cnam = (theme: cnam-theme, part: part-cnam, box: custom-box-cnam, minitoc: minitoc-cnam, boxeq: boxeq-cnam)