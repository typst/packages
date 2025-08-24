// seu-beamer modified to fit Jun's presentations

#import "@preview/touying:0.4.2": *
#import "@preview/cuti:0.2.1": show-cn-fakebold // 用于中文假粗体

// 导航条
#let seu-nav-bar(self: none) = states.touying-progress-with-sections(dict => {
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

// 纲要
#let seu-outline(self: none) = states.touying-progress-with-sections(dict => {
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

  // set text(size: 0.5em)
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

// slide、title-slide、outline-slide、new-section-slide、ending-slide 这些宏负责不同类型幻灯片的呈现和版式设置。
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
    self.seu-title = title
  }
  if subtitle != auto {
    self.seu-subtitle = subtitle
  }
  if header != auto {
    self.seu-header = header
  }
  if footer != auto {
    self.seu-footer = footer
  }
  if display-current-section != auto {
    self.seu-display-current-section = display-current-section
  }
  (self.methods.touying-slide)(
    ..args.named(),
    self: self,
    title: title,
    setting: body => {
      show: args.named().at("setting", default: body => body)
      // align(center + horizon, block(body))
      align(horizon, body)
    },
    ..args.pos(),
  )
}

#let title-slide(self: none, ..args) = {
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
  self.seu-title = [Table of Contents]
  let content = {
    set align(horizon)
    set text(weight: "bold")
    hide([-])
    seu-outline(self: self)
  }
  (self.methods.touying-slide)(self: self, repeat: none, section: (title: [Outline]), content)
}

#let new-section-slide(self: none, short-title: auto, title) = {
  self.seu-title = [Content]
  let content = {
    set align(horizon)
    set text(weight: "bold")
    hide([-]) // 如果没这个会导致显示出问题
    seu-outline(self: self)
  }
  (self.methods.touying-slide)(self: self, repeat: none, section: (title: title, short-title: short-title), content)
}

#let ending-slide(self: none, title: none, body) = {
  let content = {
    set align(center + horizon)
    if title != none {
      block(
        fill: self.colors.primary,
        inset: (x: 3em, y: 0.7em),
        radius: 0.5em,
        text(size: 1.5em, fill: self.colors.neutral-lightest, weight: "bold", title),
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

// 幻灯片的注册
#let register(
  self: themes.default.register(),
  aspect-ratio: "16-9",
  progress-bar: true,
  display-current-section: true,
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
    // 绿色方案
    // primary: rgb("#4d7c2b"),
    // primary-dark: rgb("#3d5c27"),
    // secondary: rgb("#fdd100"),
    // tertiary: rgb("#006600"),
    // neutral-lightest: rgb("#ffffff"),
    // neutral-darkest: rgb("#000000"),
    // 蓝色方案
    // primary: rgb("#1e3a8a"),
    // primary-dark: rgb("#1e2a6a"),
    // secondary: rgb("#60a5fa"),
    // tertiary: rgb("#2563eb"),
    // neutral-lightest: rgb("#ffffff"),
    // neutral-darkest: rgb("#000000"),
    // 红色方案
    primary: rgb("#c62828"),
    primary-dark: rgb("#8e0000"),
    secondary: rgb("#ff8a80"),
    tertiary: rgb("#d32f2f"),
    neutral-lightest: rgb("#ffffff"),
    neutral-darkest: rgb("#000000")
  )
  // marker
  self.seu-knob-marker = box(
    width: 0.5em,
    place(
      dy: 0.1em,
      circle(
        fill: gradient.radial(
          self.colors.primary.lighten(100%),
          self.colors.primary.darken(40%),
          focal-center: (30%, 30%),
        ),
        radius: 0.25em,
      ),
    ),
  )

  // 这些变量将用于之后的全局调用
  self.seu-enable-progress-bar = progress-bar
  self.seu-progress-bar = self => states.touying-progress(ratio => {
    grid(
      columns: (ratio * 100%, 1fr),
      rows: 2pt,
      components.cell(fill: self.colors.primary),
      components.cell(fill: self.colors.tertiary),
    )
  })
  self.seu-navigation = self => {
    grid(
      align: center + horizon,
      columns: (1fr, auto, auto),
      rows: 1.8em,
      components.cell(fill: self.colors.neutral-darkest, seu-nav-bar(self: self)),
      //block(fill: self.colors.primary, inset: 0.2em, image("assets/seu-title-bl-white-embed-min.svg", height: 100%)),
      // 这里可以插入个校徽logo
      //block(fill: self.colors.primary, inset: 0.1em, image("assets/seu-logo-min.svg", height: 100%)),
    )
  }
  self.seu-display-current-section = display-current-section
  self.seu-title = none
  self.seu-subtitle = none
  self.seu-footer = self => {
    let cell(fill: none, it) = rect(
      width: 100%,
      height: 100%,
      inset: 1pt,
      outset: 0pt,
      fill: fill,
      stroke: none,
      align(horizon, text(fill: self.colors.neutral-lightest, it)),
    )
    grid(
      columns: footer-columns,
      rows: 1.5em,
      cell(fill: self.colors.neutral-darkest, utils.call-or-display(self, footer-a)),
      cell(fill: self.colors.neutral-darkest, utils.call-or-display(self, footer-b)),
      cell(fill: self.colors.neutral-darkest, utils.call-or-display(self, footer-c)),
      cell(fill: self.colors.neutral-darkest, utils.call-or-display(self, footer-d)),
    )
  }
  self.seu-header = self => {
    if self.seu-title != none {
      block(
        width: 100%,
        height: 1.8em,
        fill: gradient.linear(self.colors.primary, self.colors.neutral-darkest),
        place(
          left + horizon,
          text(fill: self.colors.neutral-lightest, weight: "bold", size: 1.3em, self.seu-title),
          dx: 1.5em,
        ),
      )
    }
  }
  // set page
  let header(self) = {
    set align(top)
    grid(
      rows: (auto, auto),
      utils.call-or-display(self, self.seu-navigation),
      utils.call-or-display(self, self.seu-header),
    )
  }
  let footer(self) = {
    set text(size: .5em)
    set align(center + horizon)
    utils.call-or-display(self, self.seu-footer)
  }

  self.page-args += (
    paper: "presentation-" + aspect-ratio,
    header: header,
    footer: footer,
    header-ascent: 0em,
    footer-descent: 0em,
    margin: (top: 4em, bottom: 0.7em, x: 2.5em),
    background: place(center + horizon, dx: 75%, dy: 5%, image("assets/sydney.svg", width: 95%)),
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
        radius: (top: 0.4em),
        inset: (top: 0.4em, bottom: 0.3em, x: 0.5em),
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
        radius: (bottom: 0.4em),
        inset: (top: 0.4em, rest: 0.5em),
        it,
      ),
    )
  }

  self.methods.init = (self: none, text-size: 22pt, body) => {
    set text(size: text-size, font: ("JetBrains Mono"))
    set block(spacing: 0.8em)
    set heading(outlined: false)
    set list(marker: self.seu-knob-marker)

    show strong: it => text(weight: "bold", it)
    set par(justify: true)

    show figure.caption: set text(size: 0.6em)
    show footnote.entry: set text(size: 0.6em)

    show: show-cn-fakebold

    set text(lang: "en")
    show figure.where(kind: table): set figure.caption(position: top)

    body
  }

  self
}
