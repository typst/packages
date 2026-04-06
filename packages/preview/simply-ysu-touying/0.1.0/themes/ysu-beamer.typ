// Yanshan University Touying theme

#import "@preview/touying:0.6.3": *
#import "@preview/cuti:0.4.0": show-cn-fakebold

#let _wordmark(white: false, height: 0.8em) = image(
  if white {
    "assets/ysu-wordmark-only-white.png"
  } else {
    "assets/ysu-wordmark-only.png"
  },
  height: height,
)

#let _emblem(white: false, height: 1.1em) = image(
  if white {
    "assets/ysu-seal-white.png"
  } else {
    "assets/ysu-seal.png"
  },
  height: height,
)

#let _watermark(width: 32%) = image("assets/ysu-watermark.png", width: width)

#let _heading-body(level: auto, depth: 9999) = context {
  let current = utils.current-heading(level: level, depth: depth)
  if current == none {
    none
  } else {
    current.body
  }
}

#let _header-title(self: none) = context {
  let slide-title = _heading-body(level: 2, depth: self.slide-level)
  if slide-title == none {
    _heading-body(level: 1, depth: self.slide-level)
  } else {
    slide-title
  }
}

#let _nav-bar(self: none) = context {
  let current = utils.current-heading(level: 1)
  let sections = query(selector(heading.where(level: 1)))
  if sections.len() == 0 {
    []
  } else {
    set text(size: 0.42em)
    for (index, section) in sections.enumerate() {
      let active = current != none and current.location().page() == section.location().page()
      if index > 0 {
        h(0.25em)
      }
      box(
        inset: (x: 0.55em, y: 0.22em),
        radius: 999pt,
        fill: if active {
          white.transparentize(84%)
        } else {
          none
        },
      )[
        #text(
          fill: if active {
            white
          } else {
            white.transparentize(35%)
          },
          link(section.location(), section.body),
        )
      ]
    }
  }
}

#let _tblock(self: none, title: none, it) = {
  grid(
    columns: 1,
    row-gutter: 0pt,
    block(
      fill: self.colors.primary-dark,
      width: 100%,
      radius: (top: 7pt),
      inset: (top: 0.4em, bottom: 0.3em, x: 0.55em),
      text(fill: self.colors.neutral-lightest, weight: "bold", title),
    ),
    rect(
      fill: gradient.linear(self.colors.primary-dark, self.colors.primary-lighter, angle: 90deg),
      width: 100%,
      height: 4pt,
    ),
    block(
      fill: self.colors.primary-lightest,
      width: 100%,
      radius: (bottom: 7pt),
      stroke: (paint: self.colors.primary-light, thickness: 0.8pt),
      inset: (top: 0.45em, bottom: 0.55em, x: 0.6em),
      it,
    ),
  )
}

#let tblock(title: none, it) = touying-fn-wrapper(_tblock.with(title: title, it))

#let slide(
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  align: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  let slide-align = if align == auto {
    self.store.align
  } else {
    align
  }
  let header(self) = {
    let header-title = _header-title(self: self)
    set std.align(top)
    grid(
      rows: (auto, auto, auto),
      row-gutter: 0pt,
      block(
        fill: self.colors.primary-dark,
        inset: (x: 0.6em, y: 0.24em),
        grid(
          columns: (1fr, auto, auto),
          align: center + horizon,
          column-gutter: 0.55em,
          _nav-bar(self: self),
          _wordmark(white: true, height: 0.68em),
          _emblem(white: true, height: 1.06em),
        ),
      ),
      if self.store.progress-bar {
        components.progress-bar(height: 2pt, self.colors.secondary, self.colors.primary-lighter)
      } else {
        []
      },
      if header-title != none {
        block(
          fill: gradient.linear(self.colors.primary, self.colors.primary-dark),
          inset: (x: 1em, y: 0.28em),
          radius: (bottom: 7pt),
          text(
            fill: self.colors.neutral-lightest,
            weight: "bold",
            size: 0.8em,
            header-title,
          ),
        )
      } else {
        []
      },
    )
  }
  let footer(self) = {
    set std.align(center + bottom)
    set text(size: 0.42em)
    let cell(fill: none, it) = components.cell(
      fill: fill,
      inset: (x: 1.1mm, y: 0.9mm),
      std.align(horizon, text(fill: self.colors.neutral-lightest, it)),
    )
    show: block.with(width: 100%, height: auto)
    grid(
      columns: self.store.footer-columns,
      rows: 1.5em,
      cell(fill: self.colors.primary-dark, utils.call-or-display(self, self.store.footer-a)),
      cell(fill: self.colors.primary-dark, utils.call-or-display(self, self.store.footer-b)),
      cell(fill: self.colors.primary, utils.call-or-display(self, self.store.footer-c)),
      cell(fill: self.colors.secondary, utils.call-or-display(self, self.store.footer-d)),
    )
  }
  let self = utils.merge-dicts(
    self,
    config-page(
      header: header,
      footer: footer,
    ),
  )
  let new-setting = body => {
    show: std.align.with(slide-align)
    show: setting
    body
  }
  touying-slide(
    self: self,
    config: config,
    repeat: repeat,
    setting: new-setting,
    composer: composer,
    ..bodies,
  )
})

#let title-slide(config: (:), extra: none, ..args) = touying-slide-wrapper(self => {
  let self = utils.merge-dicts(
    self,
    config,
    config-common(freeze-slide-counter: true),
    config-page(
      header: none,
      footer: none,
      margin: (top: 1.3em, bottom: 1.25em, x: 2.2em),
      background: none,
    ),
  )
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
  let body = {
    block(
      width: 100%,
      stack(
        dir: ttb,
        spacing: 0.45em,
        grid(
          columns: (1fr, auto),
          column-gutter: 0.8em,
          _wordmark(height: 0.88em),
          _emblem(height: 2.2em),
        ),
        rect(
          width: 100%,
          height: 4pt,
          fill: gradient.linear(self.colors.primary, self.colors.tertiary),
        ),
        v(0.35em),
        text(size: 2.05em, fill: self.colors.primary-darkest, weight: "bold", info.title),
        if info.subtitle != none {
          text(size: 1.02em, fill: self.colors.primary, info.subtitle)
        },
        v(0.55em),
        block(
          width: 78%,
          fill: self.colors.primary-lightest,
          stroke: (paint: self.colors.primary-light, thickness: 0.9pt),
          radius: 12pt,
          inset: 0.95em,
          {
            set text(size: 0.82em, fill: self.colors.neutral-darkest)
            grid(
              columns: (1fr,) * calc.min(info.authors.len(), 3),
              column-gutter: 1em,
              row-gutter: 0.5em,
              ..info.authors.map(author => text(weight: "bold", author)),
            )
            if info.institution != none {
              v(0.45em)
              text(size: 0.96em, info.institution)
            }
            if info.date != none {
              v(0.35em)
              text(size: 0.92em, utils.display-info-date(self))
            }
            if extra != none {
              v(0.5em)
              extra
            }
          },
        ),
      ),
    )
  }
  touying-slide(self: self, body)
})

#let outline-slide(config: (:), title: [目录]) = touying-slide-wrapper(self => {
  let body = context {
    let current = utils.current-heading(level: 1)
    let sections = query(selector(heading.where(level: 1)))
    show: pad.with(x: 7%, y: 7%)
    stack(
      dir: ttb,
      spacing: 0.75em,
      text(size: 1.55em, fill: self.colors.primary-dark, weight: "bold", title),
      rect(
        width: 100%,
        height: 3pt,
        fill: gradient.linear(self.colors.primary, self.colors.tertiary),
      ),
      ..sections.map(section => {
        let active = current != none and current.location().page() == section.location().page()
        box(
          width: 100%,
          inset: (x: 0.8em, y: 0.48em),
          radius: 10pt,
          fill: if active {
            self.colors.primary-lighter
          } else {
            self.colors.neutral-lightest
          },
          stroke: (
            paint: if active {
              self.colors.primary
            } else {
              self.colors.primary-light
            },
            thickness: if active { 1.2pt } else { 0.8pt },
          ),
        )[
          #text(
            fill: if active {
              self.colors.primary-dark
            } else {
              self.colors.primary
            },
            weight: "bold",
            link(section.location(), section.body),
          )
        ]
      }),
    )
  }
  touying-slide(self: self, config: config, body)
})

#let new-section-slide(config: (:), level: 1, numbered: false, body) = touying-slide-wrapper(self => {
  let self = utils.merge-dicts(
    self,
    config-page(background: place(right + bottom, dx: -0.9em, dy: -0.9em, _watermark(width: 28%))),
  )
  let slide-body = {
    show: pad.with(x: 10%, y: 18%)
    stack(
      dir: ttb,
      spacing: 0.7em,
      grid(
        columns: (auto, auto),
        align: center + horizon,
        column-gutter: 0.55em,
        _wordmark(height: 0.76em),
        _emblem(height: 1.5em),
      ),
      rect(
        width: 100%,
        height: 4pt,
        fill: gradient.linear(self.colors.primary, self.colors.tertiary),
      ),
      text(
        size: 1.8em,
        fill: self.colors.primary-darkest,
        weight: "bold",
        utils.display-current-heading(level: level, numbered: numbered, style: auto),
      ),
      text(size: 0.82em, fill: self.colors.primary, [燕山大学学术报告模板]),
    )
    body
  }
  touying-slide(self: self, config: config, slide-body)
})

#let ending-slide(config: (:), title: [谢谢！], body) = touying-slide-wrapper(self => {
  let self = utils.merge-dicts(
    self,
    config,
    config-common(freeze-slide-counter: true),
    config-page(
      header: none,
      footer: none,
      background: place(right + bottom, dx: -0.9em, dy: -0.9em, _watermark(width: 26%)),
    ),
  )
  let slide-body = {
    show: std.align.with(center + horizon)
    stack(
      dir: ttb,
      spacing: 0.8em,
      _emblem(height: 2.8em),
      _wordmark(height: 0.95em),
      if title != none {
        block(
          fill: self.colors.primary,
          radius: 12pt,
          inset: (x: 1.6em, y: 0.65em),
          text(size: 1.45em, fill: self.colors.neutral-lightest, weight: "bold", title),
        )
      },
      body,
    )
  }
  touying-slide(self: self, slide-body)
})

#let ysu-theme(
  aspect-ratio: "16-9",
  align: top,
  progress-bar: true,
  footer-columns: (20%, 18%, 1fr, 5em),
  footer-a: self => self.info.author,
  footer-b: self => utils.display-info-date(self),
  footer-c: self => if self.info.short-title == auto {
    self.info.title
  } else {
    self.info.short-title
  },
  footer-d: self => context utils.slide-counter.display() + " / " + utils.last-slide-number,
  watermark: true,
  ..args,
  body,
) = {
  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      fill: rgb("#ffffff"),
      header-ascent: 0em,
      footer-descent: 0em,
      margin: (top: 4.2em, bottom: 0.8em, x: 2.2em),
      background: if watermark {
        place(right + bottom, dx: -0.8em, dy: -0.8em, _watermark())
      } else {
        none
      },
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: new-section-slide.with(numbered: false),
      show-strong-with-alert: false,
    ),
    config-methods(
      init: (self: none, body) => {
        set text(
          size: 22pt,
          font: (
            "Times New Roman",
            "KaiTi",
            "STKaiti",
            "LXGW WenKai",
            "Microsoft YaHei",
            "Arial",
          ),
        )
        set block(spacing: 0.8em)
        set par(justify: true)
        set heading(outlined: false)
        set list(marker: box(
          width: 0.55em,
          place(
            dy: 0.08em,
            circle(
              fill: gradient.radial(self.colors.primary-lightest, self.colors.primary),
              radius: 0.16em,
            ),
          ),
        ))
        show strong: it => text(weight: "bold", it)
        show heading.where(level: 3): set text(fill: self.colors.primary)
        show heading.where(level: 4): set text(fill: self.colors.primary-dark)
        show figure.caption: set text(size: 0.62em)
        show footnote.entry: set text(size: 0.6em)
        show figure.where(kind: table): set figure.caption(position: top)
        show: show-cn-fakebold
        set text(lang: "zh")
        body
      },
      alert: utils.alert-with-primary-color,
    ),
    config-colors(
      primary: rgb("#2B69C1"),
      primary-light: rgb("#78A4E7"),
      primary-lighter: rgb("#DCE8FA"),
      primary-lightest: rgb("#F6F9FF"),
      primary-dark: rgb("#1F4F94"),
      primary-darker: rgb("#163A70"),
      primary-darkest: rgb("#102744"),
      secondary: rgb("#173A72"),
      secondary-light: rgb("#4F78B9"),
      secondary-lighter: rgb("#DFE9FA"),
      tertiary: rgb("#4D88D6"),
      neutral-light: rgb("#A3AEC2"),
      neutral-lighter: rgb("#E8EDF6"),
      neutral-lightest: rgb("#FFFFFF"),
      neutral-dark: rgb("#344760"),
      neutral-darker: rgb("#22344B"),
      neutral-darkest: rgb("#162234"),
    ),
    config-store(
      align: align,
      progress-bar: progress-bar,
      footer-columns: footer-columns,
      footer-a: footer-a,
      footer-b: footer-b,
      footer-c: footer-c,
      footer-d: footer-d,
    ),
    ..args,
  )

  body
}
