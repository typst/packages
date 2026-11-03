// package dependancies and show rules
#import "@preview/physica:0.9.8": *
#import "@preview/touying:0.7.3": *

#show: super-T-as-transpose

// Theme Color Palettes
#let themes = (
  sky: (
    sea: rgb("#3b60a0"),
    sky: rgb("#bdd0f1"),
    skyl: rgb("#eff3ff"),
    skyll: rgb("#f4f9ff"),
    paper: rgb("#f5f6f8"),
    header-fill: none,
    header-text: none,
    page-fill: white,
  ),
  sunset: (
    sea: rgb("#970014"),
    sky: rgb("#D8A6A2"),
    skyl: rgb("#fdf0f0"),
    skyll: rgb("#FFF8F6"),
    paper: rgb("#f5f6f8"),
    header-fill: rgb("#F7EEE7"),
    header-text: rgb("#970014"),
    page-fill: rgb("#fffefd"),
  ),
)

// Default theme colors (sky)
#let sea = themes.sky.sea
#let sky = themes.sky.sky
#let skyl = themes.sky.skyl
#let skyll = themes.sky.skyll
#let paper = themes.sky.paper

// Theme state for dynamic components
#let _theme-state = state("xwysyy-theme", themes.sky)

#let red(body) = text(fill: rgb("#9c1d11"), body)
#let bred(body) = text(size: 1.1em, stroke: 0.02em + rgb("#9c1d11"), fill: rgb("#9c1d11"), body)
#let yellow(body) = text(fill: rgb("#d9ad20"), body)
#let byellow(body) = text(size: 1.1em, stroke: 0.02em + rgb("#d9ad20"), fill: rgb("#d9ad20"), body)

#let xwysyy-elements(
  doc,
  code-font: "Maple Mono",
  t-sea: sea,
  t-sky: sky,
  t-skyll: skyll,
  t-paper: paper,
) = [
  // Bold enhancement
  #show strong: it => {
    let c = text.fill
    text(size: 1.1em, stroke: 0.02em + c, it.body)
  }

  // List style
  #set list(marker: (text(fill: t-sea, [❖]), text(fill: t-sky, [⬦]), text(fill: t-sky, [–])), spacing: 1.2em, indent: 0.5em, body-indent: 0.8em)
  #set enum(spacing: 1.2em, indent: 0.5em)

  // Italic — per-character synthetic skew for CJK
  #show emph: it => {
    if type(it.body) == content and it.body.has("text") {
      for c in it.body.text {
        box(skew(ax: -8deg, c))
      }
    } else {
      box(skew(ax: -8deg, it.body))
    }
  }

  // Image shadow disabled (layout+measure incompatible with touying slides)
  // #show image: it => {
  //   layout(size => {
  //     let w = measure(it).width
  //     let h = measure(it).height
  //     block(width: w, height: h, {
  //       place(dx: 1.5pt, dy: 1.5pt, block(width: w, height: h, fill: luma(210), radius: 1pt))
  //       place(dx: 0pt, dy: 0pt, it)
  //     })
  //   })
  // }

  // Figure captions — smaller
  #show figure.caption: it => {
    set text(size: 0.78em, fill: luma(100))
    v(0.3em)
    it
  }

  // Table captions on top
  #show figure.where(kind: table): set figure.caption(position: top)

  // Codeblocks
  #show raw.where(block: true): it => {
    set text(font: code-font, size: 0.9em)
    block(
      width: 100%,
      height: auto,
      fill: t-skyll,
      inset: 0.6em,
      radius: 0.5em,
      it
    )
  }
  #show raw.where(block: false): it => {
    set text(font: code-font)
    box(
      fill: t-skyll,
      inset: (x: 0.3em, y: 0.2em),
      radius: 0.3em,
      baseline: 0.2em,
      it
    )
  }

  // Links
  #show link: underline
  #show link: it => {
    set text(fill: t-sea)
    it
  }

  // Detail Decoration — longer patterns first to avoid partial matches
  #show "<==>": [$arrow.l.r.double.long$]
  #show "<=>": [$<=>$]
  #show "-->": [$-->$]
  #show "<--": [$<--$]
  #show "==>": [$==>$]
  #show "<==": [$arrow.l.double.long$]
  #show "->": [$->$]
  #show "<-": [$<-$]
  #show "=>": [$=>$]
  #show "<=": [$arrow.l.double$]
  #show "|->": [$|->$]

  // Tables
  #set table(
    stroke: none,
    gutter: 0.2em,
    align: center,
    fill: (x, y) => if y == 0 {t-sea} else {t-skyll},
  )
  #show table.cell: it => {
    if it.y == 0 {
    set text(t-paper, weight: "bold")
    it
  } else {it}
  }

  #doc
]

#let xwysyy-note(
  doc,
  title: none,
  subtitle: none,
  font: ("Times New Roman", "Noto Serif CJK SC"),
  code-font: "Maple Mono",
  base-size: 10pt,
  lang: "en",
) = [
  #set text(
    font: font,
    lang: lang,
    size: base-size,
    weight: "regular",
    style: "normal",
  )

  #set page(
    paper: "a4",
    columns: 1,
    margin: (x: 2cm, y: 2cm),
    numbering: "1 / 1",
  )
  #set par(justify: true, leading: 0.8em)
  #set heading(numbering: "1.1")

  // Title block
  #if title != none {
    align(center)[
      #v(1em)
      #text(size: 1.6em, weight: "bold", title)
      #if subtitle != none {
        v(0.3em)
        text(size: 0.9em, fill: luma(120), subtitle)
      }
      #v(1em)
    ]
  }

  // Quote decoration
  #show ">|": it => [
    #box(baseline: 0.4em, rect(width: 0.2em, height: 1.2em, fill: luma(200)))
    #h(0.5em)
  ]

  // Headings
  #show heading.where(level: 1): it => {
    v(0.5em)
    text(size: 1.25em, fill: luma(30), weight: "bold", it.body)
    v(-0.6em)
    line(length: 100%, stroke: 0.5pt + luma(200))
    v(0.3em)
  }
  #show heading.where(level: 2): it => {
    v(0.3em)
    text(size: 1.15em, fill: luma(50), weight: "bold", it.body)
    v(0.1em)
  }
  #show heading.where(level: 3): it => {
    v(0.2em)
    text(size: 1.05em, fill: luma(60), weight: "bold", it.body)
    v(0.1em)
  }
  #show heading.where(level: 4): it => text(
    fill: luma(70), size: 1em, weight: "bold", it.body,
  )

  // Bold
  #show strong: it => text(weight: "bold", it.body)

  // List markers
  #set list(marker: (text(fill: luma(120), [❖]), text(fill: luma(160), [⬦]), text(fill: luma(160), [–])), spacing: 1em, indent: 0.5em, body-indent: 0.8em)
  #set enum(spacing: 1em, indent: 0.5em)

  // Italic — CJK skew (guard for non-text content like links/math/code)
  #show emph: it => {
    if type(it.body) == content and it.body.has("text") {
      for c in it.body.text {
        box(skew(ax: -8deg, c))
      }
    } else {
      box(skew(ax: -8deg, it.body))
    }
  }

  // Figure captions
  #show figure.caption: it => {
    set text(size: 0.85em, fill: luma(100))
    v(0.3em)
    it
  }
  #show figure.where(kind: table): set figure.caption(position: top)

  // Code blocks
  #show raw.where(block: true): it => {
    set text(font: code-font, size: 0.9em)
    block(width: 100%, fill: luma(248), inset: 0.6em, radius: 0.3em, it)
  }
  #show raw.where(block: false): it => {
    set text(font: code-font)
    box(fill: luma(245), inset: (x: 0.3em, y: 0.15em), radius: 0.2em, baseline: 0.15em, it)
  }

  // Links
  #show link: underline
  #show link: it => { set text(fill: rgb("#4271ae")); it }

  // Arrow decorations
  #show "<==>": [$arrow.l.r.double.long$]
  #show "<=>": [$<=>$]
  #show "-->": [$-->$]
  #show "<--": [$<--$]
  #show "==>": [$==>$]
  #show "<==": [$arrow.l.double.long$]
  #show "->": [$->$]
  #show "<-": [$<-$]
  #show "=>": [$=>$]
  #show "<=": [$arrow.l.double$]
  #show "|->": [$|->$]

  // Tables
  #set table(
    stroke: 0.5pt + luma(200),
    gutter: 0em,
    align: center,
    fill: (x, y) => if y == 0 { luma(240) } else { none },
  )
  #show table.cell: it => {
    if it.y == 0 {
      set text(weight: "bold")
      it
    } else { it }
  }

  #doc
]

// information item
#let info(something, description) = [
  *#something* #h(1fr) *#description*\
]

// Sliding Themes for Touying

#let xwysyy-slide(title: auto, ..args) = touying-slide-wrapper(self => {
  if title != auto {
    self.store.title = title
  }
  // set page
  let header(self) = {
    set align(top)
    block(
      width: 100% + 2em,
      height: 2.5em,
      fill: self.store.header-fill,
      inset: (x: 1em),
      {
        set align(horizon)
        text(fill: self.store.header-text, weight: "extrabold", size: 1.56em, {
          if self.store.title != none {
            utils.call-or-display(self, self.store.title)
          } else {
            utils.display-current-heading(level: 2)
          }
        })
      }
    )
  }
  let footer(self) = {
    set align(bottom)
    set text(fill: self.colors.neutral-dark, size: .9em)
    block(
      inset: (x: 0.5em, bottom: 0.4em),
      {
      utils.call-or-display(self, self.store.footer)
      h(1fr)
      context utils.slide-counter.display()
    }
    )
  }
  self = utils.merge-dicts(
    self,
    config-page(
      header: header,
      footer: footer,
    ),
  )
  touying-slide(self: self, ..args)
})

#let title-slide(..args) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-page(margin: 0em),
  )
  let info = self.info + args.named()
  let body = {
    set align(center + horizon)
    line(length: 100%, stroke: self.colors.neutral-dark)
    v(-0.9em)
    block(
      fill: self.colors.neutral-dark,
      width: 100%,
      inset: (y: 1.2em),
      text(size: 2.2em, fill: self.colors.neutral-lightest, weight: "bold", info.title),
    )
    if info.subtitle != none {
      v(-0.9em)
      block(
        fill: self.colors.neutral-lighter,
        width: 100%,
        {
        line(length: 100%, stroke: self.colors.neutral-dark)
        v(-0.65em)
        text(size: 1.6em, fill: self.colors.neutral-dark, weight: "bold", info.subtitle)
        v(-0.65em)
        line(length: 100%, stroke: self.colors.neutral-dark)}
      )
    }
    set text(fill: self.colors.neutral-darkest)
    v(1em)
    if info.author != none {
      block(text(size: 1.1em, info.author))
    }
    if info.institution != none {
      block(text(size: 0.9em, style: "italic", info.institution))
    }
    if info.date != none {
      block(utils.display-info-date(self))
    }
  }
  touying-slide(self: self, body)
})

#let new-section-slide(self: none, body) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-page(
      margin: 0em,
    ),
  )
  let main-body = {
    set align(center + horizon)
    set text(size: 2em, fill: self.colors.neutral-dark, weight: "bold", style: "italic")
    line(start: (17%, 0em), length: 83%, stroke: self.colors.neutral-dark)
    v(-0.97em)
    block(
      fill: self.colors.neutral-lighter,
      inset: (y: 0.42em),
      width: 100%,
      utils.display-current-heading(level: 1)
    )
    v(-0.97em)
    line(start: (-17%, 0em), length: 83%, stroke: self.colors.neutral-dark)
  }
  touying-slide(self: self, main-body)
})

#let focus-slide(body) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-page(
      fill: self.colors.neutral-dark,
      margin: 0em,
    ),
  )
  set text(fill: self.colors.neutral-lightest, size: 2em, weight: "bold")
  touying-slide(self: self, align(horizon + center, body))
})

#let end-slide(title: [Thank You!], body: none) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(self, config-page(
    fill: white,
    margin: 2em,
  ))
  let main-body = {
    set align(center + horizon)
    text(fill: self.colors.neutral-dark, size: 3em, weight: "bold", title)
    if body != none {
      v(0.5em)
      line(length: 20%, stroke: (thickness: 1.5pt, paint: self.colors.primary))
      v(0.5em)
      text(size: 1.3em, fill: self.colors.neutral-dark.lighten(30%), body)
    }
  }
  touying-slide(self: self, main-body)
})

#let outline-slide(chapters: auto) = {
  xwysyy-slide(title: [目录])[
    #context {
      let t = _theme-state.get()
      let chs = if chapters == auto {
        query(heading.where(level: 1))
          .filter(h => not h.has("label") or str(h.label) != "touying:hidden")
          .map(h => h.body)
      } else {
        chapters
      }
      let two-col = chs.len() > 5
      let bsz = if two-col { 2em } else { 2.6em }
      let tsz = if two-col { 1.4em } else { 2em }
      let badge(n) = box(
        width: bsz, height: bsz, fill: t.sea, radius: 50%,
        align(center + horizon, text(fill: t.paper, weight: "bold", size: bsz * 0.58, n))
      )
      let items = chs.enumerate().map(((i, ch)) => grid(
        columns: (auto, 1fr),
        column-gutter: if two-col { 1em } else { 1.4em },
        align: (center + horizon, left + horizon),
        badge(numbering("01", i + 1)),
        text(size: tsz, weight: "semibold", ch),
      ))
      if two-col {
        let mid = calc.ceil(items.len() / 2)
        v(0.5em)
        grid(
          columns: (1fr, 1fr),
          gutter: 1.5em,
          stack(spacing: 1.6em, ..items.slice(0, mid)),
          stack(spacing: 1.6em, ..items.slice(mid)),
        )
      } else {
        v(1em)
        stack(spacing: 2.4em, ..items)
      }
    }
  ]
}

#let textbox(inset: 0.8em, radius: 0.4em, width: 100%, gutter: 0.6em, ..bodies) = context {
  let t = _theme-state.get()
  let bodies = bodies.pos()
  if bodies.len() == 1 {
    block(width: width, fill: t.skyll, inset: inset, radius: radius, bodies.first())
  } else {
    components.lazy-layout(grid(
      columns: (1fr,) * bodies.len(),
      gutter: gutter,
      ..bodies.map(b => block(width: 100%, fill: t.skyll, inset: inset, radius: radius, {
        b
        components.lazy-v(1fr)
      })),
    ))
  }
}

#let image-slide(body: none, img: none) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-page(
      background: img,
      margin: (x: 0em, y: 1.4em),
    ),
  )
  set text(fill: self.colors.neutral-dark, size: 1.4em)
  set image(width: 100%, height: auto)
  touying-slide(self: self, align(left + bottom,
    align(
      center,
      block(
        fill: self.colors.neutral-lighter,
        if body != none {
        line(length: 100%, stroke: self.colors.neutral-dark)
        v(-0.85em)
        body
        v(-0.85em)
        line(length: 100%, stroke: self.colors.neutral-dark)
      }
      ))))
})

#let xwysyy-pre(
  aspect-ratio: "16-9",
  footer: none,
  theme: "sky",
  ..args,
  body,
) = {
  let t = themes.at(theme)
  _theme-state.update(t)
  set text(
    font: ("Times New Roman", "Noto Serif CJK SC"),
    lang: "en",
    size: 5.5mm,
    weight: "semibold",
    style: "normal",
  )
  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      margin: (top: 3.7em, x: 1em, bottom: 1.4em)
    ),
    config-common(
      slide-fn: xwysyy-slide,
      new-section-slide-fn: new-section-slide,
      frozen-counters: (counter(figure), counter(math.equation)),
    ),
    config-colors(
      primary: t.sky,
      neutral-light: t.skyl,
      neutral-lighter: t.skyll,
      neutral-lightest: t.paper,
      neutral-dark: t.sea,
      neutral-darkest: black,
    ),
    config-methods(
      alert: (self: none, it) => text(weight: "bold", stroke: 0.02em, it),
    ),
    config-store(
      title: none,
      footer: footer,
      header-fill: if t.header-fill != none { t.header-fill } else { t.sea },
      header-text: if t.header-text != none { t.header-text } else { t.paper },
    ),
    config-page(
      fill: t.page-fill,
    ),
    ..args,
  )

  show: xwysyy-elements.with(t-sea: t.sea, t-sky: t.sky, t-skyll: t.skyll, t-paper: t.paper)

  body
}
