// University theme - modified to fit HKUST GZ 
// Inspired by https://github.com/Coekjan/touying-buaa

#import "@preview/touying:0.4.2": *

#let hkustgz-nav-bar(self: none) = states.touying-progress-with-sections(dict => {
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

  set text(size: 0.5em)
  for (i, section) in final-sections.enumerate() {
    set text(fill: if i != current-index {
      gray
    } else {
      white
    })
    box(inset: 0.5em)[#link(section.loc, utils.section-short-title(section))<touying-link>]
  }
})

#let hkustgz-outline(self: none) = states.touying-progress-with-sections(dict => {
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
  }
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
    self.hkustgz-title = title
  }
  if subtitle != auto {
    self.hkustgz-subtitle = subtitle
  }
  if header != auto {
    self.hkustgz-header = header
  }
  if footer != auto {
    self.hkustgz-footer = footer
  }
  if display-current-section != auto {
    self.hkustgz-display-current-section = display-current-section
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
  // self = utils.empty-page(self)
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
      align(right, info.logo)
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
  }
  (self.methods.touying-slide)(self: self, repeat: none, content)
}

#let outline-slide(self: none) = {
  self.hkustgz-title = context if text.lang == "zh" [目录] else [Outline]
  let content = {
    set align(horizon)
    set text(weight: "bold")
    hide([-])
    hkustgz-outline(self: self)
  }
  (self.methods.touying-slide)(self: self, repeat: none, section: (title: context if text.lang == "zh" [目录] else [Outline]), content)
}

#let new-section-slide(self: none, short-title: auto, title) = {
  self.hkustgz-title = context if text.lang == "zh" [目录] else [Outline]
  let content = {
    set align(horizon)
    set text(weight: "bold")
    hide([-]) // magic
    hkustgz-outline(self: self)
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
  ..args,
) = {
  // color theme
  self = (self.methods.colors)(
    self: self,
    primary: rgb("#005bac"),
    primary-dark: rgb("#004078"),
    secondary: rgb("#ffffff"),
    tertiary: rgb("#005bac"),
    neutral-lightest: rgb("#ffffff"),
    neutral-darkest: rgb("#000000"),
  )
  // marker
  self.hkustgz-knob-marker = box(
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
  self.hkustgz-enable-progress-bar = progress-bar
  self.hkustgz-progress-bar = self => states.touying-progress(ratio => {
    grid(
      columns: (ratio * 100%, 1fr),
      rows: 2pt,
      components.cell(fill: self.colors.primary),
      components.cell(fill: self.colors.neutral-lightest),
    )
  })
  self.hkustgz-navigation = self => {
    grid(
      align: center + horizon,
      columns: (1fr, auto, auto),
      rows: 1.8em,
      components.cell(fill: self.colors.neutral-darkest, hkustgz-nav-bar(self: self)),
      block(fill: self.colors.neutral-darkest, inset: 4pt, height: 100%, image("assets/vi/hkustgz-logo.svg")),
    )
  }
  self.hkustgz-title = none
  self.hkustgz-subtitle = none
  self.hkustgz-footer = self => {
    let cell(fill: none, it) = rect(
      width: 100%,
      height: 100%,
      inset: 1mm,
      outset: 0mm,
      fill: fill,
      stroke: none,
      align(horizon, text(fill: self.colors.neutral-lightest, it)),
    )
    grid(
      columns: footer-columns,
      rows: (1.5em, auto),
      cell(fill: self.colors.neutral-darkest, utils.call-or-display(self, footer-a)),
      cell(fill: self.colors.neutral-darkest, utils.call-or-display(self, footer-b)),
      cell(fill: self.colors.primary, utils.call-or-display(self, footer-c)),
      cell(fill: self.colors.primary, utils.call-or-display(self, footer-d)),
    )
  }
  self.hkustgz-header = self => {
    if self.hkustgz-title != none {
      block(
        width: 100%,
        height: 1.8em,
        fill: gradient.linear(self.colors.primary, self.colors.neutral-darkest),
        place(left + horizon, text(fill: self.colors.neutral-lightest, weight: "bold", size: 1.3em, self.hkustgz-title), dx: 1.5em),
      )
    }
  }
  // set page
  let header(self) = {
    set align(top)
    grid(
      rows: (auto, auto),
      utils.call-or-display(self, self.hkustgz-navigation),
      utils.call-or-display(self, self.hkustgz-header),
    )
  }
  let footer(self) = {
    set text(size: .5em)
    set align(center + bottom)
    grid(
      rows: (auto, auto),
      utils.call-or-display(self, self.hkustgz-footer),
      if self.hkustgz-enable-progress-bar {
        utils.call-or-display(self, self.hkustgz-progress-bar)
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
      fill: self.colors.primary-dark,
      width: 100%,
      radius: (top: 6pt),
      inset: (top: 0.4em, bottom: 0.3em, left: 0.5em, right: 0.5em),
      text(fill: self.colors.neutral-lightest, weight: "bold", title),
    ),
      rect(
        fill: gradient.linear(self.colors.primary-dark, self.colors.primary.lighten(90%), angle: 90deg),
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

  self.methods.init = (self: none, lang: "en", font: ("Linux Libertine",), body) => {
    set text(size: 19pt, font: font)
    set heading(outlined: false)
    set list(marker: self.hkustgz-knob-marker)

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