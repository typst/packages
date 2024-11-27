#import "lib.typ": *
#import "@preview/touying:0.4.2": *

#let ustcblue=rgb("#034ea1")


 //横向导航栏
#let ustc-nav-bar(self: none) = states.touying-progress-with-sections(dict => {
  let (current-sections, final-sections) = dict
  current-sections = current-sections.filter(section => section.loc != none).map(section => (
    section,
    section.children,
  )).flatten().filter(item => item.kind == "section")
  final-sections = final-sections.filter(section => section.loc != none).map(section => (
    section,
    section.children,
  )).flatten().filter(item => item.kind == "section")
  let current-index = current-sections.len() - 1

  set text(size: 1em)
  for (i, section) in final-sections.enumerate() {
    set text(fill: if i != current-index {
      gray
    } else {
      white
    })
    box(inset: 1em)[#link(section.loc, utils.section-short-title(section))<touying-link>]
  }
})


 //章节目录页（）
#let ustc-outline(self: none) = states.touying-progress-with-sections(dict => {
  let (current-sections, final-sections) = dict
  current-sections = current-sections.filter(section => section.loc != none).map(section => (
    section,
    section.children,
  )).flatten().filter(item => item.kind == "section")
  final-sections = final-sections.filter(section => section.loc != none).map(section => (
    section,
    section.children,
  )).flatten().filter(item => item.kind == "section")
  let current-index = current-sections.len() - 1

  for (i, section) in final-sections.enumerate() {
    if i == 0 {
      continue
    }
    set text(fill: if current-index == 0 or i == current-index {
      self.colors.primary
    } else {
      self.colors.primary.lighten(80%)
    })
    
    block(
      spacing: 1.5em,
      [#link(section.loc, utils.section-short-title(section))<touying-link>],
    )
    if  i == current-index {
      block(height: 2pt, width: 100%, spacing: 0pt, utils.call-or-display(self, self.ustc-chapter-progress-bar))
    }
  }

  // for (i, section) in final-sections.enumerate() {
  //   if i == 0 {
  //     continue
  //   } else if current-index == 0 {
  //     set text(fill: self.colors.primary)
  //     block(
  //     spacing: 1.5em,
  //     [#link(section.loc, utils.section-short-title(section))<touying-link>],
  //   )
  //   } else if i == current-index {
  //     set text(fill: self.colors.primary)
  //     block(
  //     spacing: 1.5em,
  //     [#link(section.loc, utils.section-short-title(section))<touying-link>],
  //   )
  //     block(height: 2pt, width: 100%, spacing: 0pt, utils.call-or-display(self, self.ustc-chapter-progress-bar))
  //   } else if i < current-index {
  //     set text(fill: self.colors.secondary)
  //     block(
  //     spacing: 1.5em,
  //     [#link(section.loc, utils.section-short-title(section))<touying-link>],
  //   )
  //   } else {
  //     set text(fill: self.colors.tertiary)
  //     block(
  //     spacing: 1.5em,
  //     [#link(section.loc, utils.section-short-title(section))<touying-link>],
  //   )
  //   }
    
  // }
})


#let slide(
  self: none,
  title: auto,
  subtitle: auto,
  header: auto,
  footer: auto,
  display-current-section: auto,
  ..args,
) = {
  if title != auto {
    self.ustc-title = title
  }
  if subtitle != auto {
    self.ustc-subtitle = subtitle
  }
  if header != auto {
    self.ustc-header = header
  }
  if footer != auto {
    self.ustc-footer = footer
  }
  if display-current-section != auto {
    self.ustc-display-current-section = display-current-section
  }
  (self.methods.touying-slide)(
    ..args.named(),
    self: self,
    title: title,
    setting: body => {
      show: args.named().at("setting", default: body => body)
      align(horizon, body)
    },
    ..args.pos(),
  )
}

#let title-slide(self: none, ..args) = {
  self = utils.empty-page(self)
  let info = self.info + args.named()
  info.authors = {
    let authors = if "authors" in info {
      info.authors
    } else {
      info.author
    }
    if type(authors) == array {
      authors
    } else {
      (authors,)
    }
  }
  let content = {
    if info.logo != none {
      align(center + horizon, info.logo)
    }
    show: align.with(center + horizon)
    block(
      fill: self.colors.primary,
      inset: 1.5em,
      radius: 0.5em,
      breakable: false,
      {
        text(size: 1.2em, fill: self.colors.neutral-lightest, weight: "bold", info.title)
        if info.subtitle != none {
          parbreak()
          text(size: 1.0em, fill: self.colors.neutral-lightest, weight: "bold", info.subtitle)
        }
      },
    )
    // authors
    
    grid(
      columns: (1fr,) * calc.min(info.authors.len(), 3),
      column-gutter: 1em,
      row-gutter: 1em,
      
      ..info.authors.map(author => text(fill: black, author)),
    )
    v(0.5em)
    // institution
    if info.institution != none {
      parbreak()
      text(size: 0.7em, info.institution)
    }
    // date
    if info.date != none {
      parbreak()
      text(size: 1.0em, utils.info-date(self))
    }
    // place(right + top, image("assets/vi/ustc_logo_side.svg",format: "svg"), dx: -1em)
  }
  (self.methods.touying-slide)(self: self, repeat: none, content)
}

#let outline-slide(self: none) = {

  self.ustc-title = context if text.lang == "zh" [大纲] else [Outline]
    set page(background: rotate(-60deg,
    place(right + horizon, image("assets/img/USTC-NO-TEXT.svg",format: "svg", width: 25%), dx: 14em,dy:18em)
  ),
  )
  let content = {
    set align(horizon)
    set text(weight: "bold")
    hide([-])
    ustc-outline(self: self)
  }
  (self.methods.touying-slide)(self: self, repeat: none, section: (title: context if text.lang == "zh" [大纲] else [Outline]), content)
}


#let new-section-slide(self: none, short-title: auto, title) = {
  self.ustc-title = context if text.lang == "zh" [大纲] else [Outline]
  let content = {
    set align(horizon)
    set text(weight: "bold")
    hide([-]) // magic
    ustc-outline(self: self)
  }
  (self.methods.touying-slide)(self: self, repeat: none, section: (title: title, short-title: short-title), content)
}


#let ending-slide(self: none, title: none, body) = {
  let content = {
    set align(center + horizon)
    if title != none {
      block(
        fill: self.colors.tertiary,
        inset: (top: 0.7em, bottom: 0.7em, left: 3em, right: 3em),
        radius: 0.5em,
        text(size: 1.5em, fill: self.colors.neutral-lightest, title),
      )
    }
    body
  }
  (self.methods.touying-slide)(self: self, repeat: none, content)
}


#let slides(self: none, title-slide: true, slide-level: 1, ..args) = {
  if title-slide {
    (self.methods.title-slide)(self: self)
  }
  (self.methods.touying-slides)(self: self, slide-level: slide-level, ..args)
}

#let focus-slide(self: none, background-color: none, background-img: none, body) = {

  let background-color = if background-img == none and background-color ==  none {
    rgb(self.colors.primary)
  } else {
    background-color
  }
  self = utils.empty-page(self)
  self.page-args += (
    fill: self.colors.primary,
    margin: 1em,
    ..(if background-color != none { (fill: background-color) }),
    ..(if background-img != none { (background: {
        set image(fit: "stretch", width: 100%, height: 100%)
        background-img
      })
    }),
  )
  set text(fill: white, weight: "bold", size: 2em)
  (self.methods.touying-slide)(self: self, repeat: none, align(horizon, body))
}

#let matrix-slide(self: none, columns: none, rows: none, ..bodies) = {
  self = utils.empty-page(self)
  (self.methods.touying-slide)(self: self, composer: (..bodies) => {
    let bodies = bodies.pos()
    let columns = if type(columns) == int {
      (1fr,) * columns
    } else if columns == none {
      (1fr,) * bodies.len()
    } else {
      columns
    }
    let num-cols = columns.len()
    let rows = if type(rows) == int {
      (1fr,) * rows
    } else if rows == none {
      let quotient = calc.quo(bodies.len(), num-cols)
      let correction = if calc.rem(bodies.len(), num-cols) == 0 { 0 } else { 1 }
      (1fr,) * (quotient + correction)
    } else {
      rows
    }
    let num-rows = rows.len()
    if num-rows * num-cols < bodies.len() {
      panic("number of rows (" + str(num-rows) + ") * number of columns (" + str(num-cols) + ") must at least be number of content arguments (" + str(bodies.len()) + ")")
    }
    let cart-idx(i) = (calc.quo(i, num-cols), calc.rem(i, num-cols))
    let color-body(idx-body) = {
      let (idx, body) = idx-body
      let (row, col) = cart-idx(idx)
      let color = if calc.even(row + col) { white } else { silver }
      set align(center + horizon)
      rect(inset: .5em, width: 100%, height: 100%, fill: color, body)
    }
    let content = grid(
      columns: columns, rows: rows,
      gutter: 0pt,
      ..bodies.enumerate().map(color-body)
    )
    content
  }, ..bodies)
}


// #let register(
//   self: themes.default.register(),
//   aspect-ratio: "16-9",
//   progress-bar: true,
//   footer-columns: (25%, 25%, 1fr, 5em),
//   footer-a: self => self.info.author,
//   footer-b: self => utils.info-date(self),
//   footer-c: self => if self.info.short-title == auto {
//     self.info.title
//   } else {
//     self.info.short-title
//   },
//   footer-d: self => {
//     states.slide-counter.display() + " / " + states.last-slide-number
//   },
//   ..args,
// ) = {
//   // code implementation
// }
#let register(
  self: themes.default.register(),
  aspect-ratio: "16-9",
  progress-bar: true,
  footer-columns: (25%, 25%, 1fr, 5em),
  footer-a: self => self.info.author,
  footer-b: self => utils.info-date(self),
  footer-c: self => if self.info.short-title == auto {
    self.info.title
  } else {
    self.info.short-title
  },
  footer-d: self => {
    states.slide-counter.display() + " / " + states.last-slide-number
  },
  footer-g: self => {
  let githublink= if self.info.github != none {
    self.info.github
  } else {
    "https://github.com/Quaternijkon/Typst_USTC_CS.git"
  }
    link(githublink,image("assets/img/github-mark-white.svg"))
  },
  ..args,
) = {
  // color theme
  self = (self.methods.colors)(
    self: self,
    primary: rgb("#034ea1"),
    // primary-dark: rgb("#004098"),
    secondary: rgb("#ffffff"),
    tertiary: rgb("#005bac"),
    neutral-lightest: rgb("#ffffff"),
    neutral-darkest: rgb("#000000"),
    themeblue: rgb("#4285f4"),
    themegreen: rgb("#34a853"),
    themeyellow: rgb("#fbbc05"),
    themered: rgb("#ea4335"),
  )
  // marker
  self.ustc-knob-marker = box(
    width: 0.5em,
    place(
      dy: 0.1em,
      circle(
        fill: gradient.radial(self.colors.primary.lighten(100%), self.colors.primary.darken(40%), focal-center: (30%, 30%)),
        radius: 0.25em,
      ),
    ),
  )

  // save the variables for later use
  self.ustc-enable-progress-bar = progress-bar

  self.ustc-progress-bar = self => states.touying-progress(ratio => {    
    grid(
      columns: (ratio * 100%, 1fr),
      rows: 2pt,
      components.cell(fill: gradient.linear(self.colors.primary.lighten(10%),self.colors.primary.darken(10%))),
      components.cell(fill: self.colors.neutral-lightest),
    )
  })

  self.ustc-chapter-progress-bar = self => states.touying-progress(ratio => {    
    grid(
      columns: (ratio * 100%, 1fr),
      rows: 2pt,
      components.cell(fill: self.colors.primary),
      components.cell(fill: self.colors.neutral-lightest),
    )
  })

  self.ustc-navigation = self => {
    grid(
      align: center + horizon,
      columns: (1fr, auto, auto),
      rows: 1em,
      components.cell(fill: self.colors.primary, ustc-nav-bar(self: self)),
      // block(fill: self.colors.neutral-lightest, inset: 4pt, height: 100%, image("assets/vi/ustc_logo_side.svg")),
    )
  }

  self.ustc-title = none
  self.ustc-subtitle = none
  self.ustc-footer = self => {
    let cell(fill: none, it) = rect(
      width: 100%,
      height: 100%,
      inset: 1mm,
      outset: 0mm,
      fill: fill,
      stroke: none,
      align(horizon, text(fill: self.colors.neutral-lightest, it)),
    )
    // grid(
    // align: center + horizon,
    // columns: (1fr, auto, auto),
    // rows: 1em,
    // components.cell(fill: self.colors.primary, ustc-nav-bar(self: self)),
    
    // )
    grid(
      // columns: footer-columns,
      columns:(24%,68%,3%,5%),
      rows: (2em, auto),
      // cell(fill: self.colors.primary, utils.call-or-display(self, footer-a)),
      // cell(fill: self.colors.primary-dark, utils.call-or-display(self, footer-b)),
      // cell(fill: self.colors.primary, utils.call-or-display(self, footer-c)),
      cell(fill: self.colors.primary, utils.call-or-display(self, footer-c)),
      cell(fill: self.colors.primary, ustc-nav-bar(self: self)),
      // cell(fill: self.colors.primary, utils.call-or-display(self, footer-a)),
      // cell(fill: self.colors.primary-dark.darken(20%), utils.call-or-display(self, footer-b)),
      cell(fill: self.colors.primary, utils.call-or-display(self, footer-g)),
      cell(fill: self.colors.primary, utils.call-or-display(self, footer-d)),
    )
  }

  self.ustc-header = self => {
    if self.ustc-title != none {
      block(
        width: 100%,
        height: 2em,
        fill: gradient.linear(self.colors.primary, self.colors.neutral-lightest),
      )
      
      place(left + horizon, text(fill: self.colors.neutral-lightest, weight: "bold", size: 1.3em, self.ustc-title), dx: 1.5em)

      place(right + horizon, image("assets/img/ustc_logo_side.svg",format: "svg",width: 20%), dx: -1em)
    }
  }
  // set page
  let header(self) = {
    set align(top)
    grid(
      rows: (auto, auto),
      // utils.call-or-display(self, self.ustc-navigation),
      utils.call-or-display(self, self.ustc-header),
    )
  }
  let footer(self) = {
    set text(size: .5em)
    set align(center + bottom)
    grid(
      rows: (auto, auto),
      utils.call-or-display(self, self.ustc-footer),
      if self.ustc-enable-progress-bar {
        utils.call-or-display(self, self.ustc-progress-bar)
      },
    )
  }

  self.page-args += (
    paper: "presentation-" + aspect-ratio,
    header: header,
    footer: footer,
    header-ascent: 0em,
    footer-descent: 0em,
    margin: (top: 4.5em, bottom: 3.5em, x: 2.5em),
  )
  // register methods
  self.methods.slide = slide
  self.methods.title-slide = title-slide
  self.methods.outline-slide = outline-slide
  self.methods.new-section-slide = new-section-slide
  self.methods.touying-new-section-slide = new-section-slide
  self.methods.ending-slide = ending-slide
  self.methods.focus-slide = focus-slide
  self.methods.matrix-slide = matrix-slide
  self.methods.slides = slides
  self.methods.touying-outline = (self: none, enum-args: (:), ..args) => {
    states.touying-outline(self: self, enum-args: (tight: false) + enum-args, ..args)
  }
  self.methods.alert = (self: none, it) => text(fill: self.colors.primary, it)

  self.methods.tblock = (self: none, title: none, it) => {
    grid(
      columns: 1,
      row-gutter: 0pt,
      block(
      fill: self.colors.primary,
      width: 100%,
      radius: (top: 6pt),
      inset: (top: 0.4em, bottom: 0.3em, left: 0.5em, right: 0.5em),
      text(fill: self.colors.neutral-lightest, weight: "bold", title),
    ),
      rect(
        fill: gradient.linear(self.colors.primary, self.colors.primary.lighten(90%), angle: 90deg),
        width: 100%,
        height: 4pt,
      ),
      block(
        fill: self.colors.primary.lighten(90%),
        width: 100%,
        radius: (bottom: 6pt),
        inset: (top: 0.4em, bottom: 0.5em, left: 0.5em, right: 0.5em),
        it,
      ),
    )
  }

  self.methods.init = (self: none, lang: "zh", font: ("Linux Libertine",), body) => {
    set text(size: 19pt, font: font)
    set heading(outlined: false)
    set list(marker: self.ustc-knob-marker)

    show strong: it => text(weight: "bold", it)

    show figure.caption: set text(size: 0.6em)
    show footnote.entry: set text(size: 0.6em)
    show link: it => if type(it.dest) == str {
      set text(fill: self.colors.primary)
      it
    } else {
      it
    }

    show: if lang == "zh" {
      import "@preview/cuti:0.2.1": show-cn-fakebold
      show-cn-fakebold
    } else {
      it => it
    }

    set text(lang: lang)
    show figure.where(kind: table): set figure.caption(position: top)

    body
  }

  self
}
