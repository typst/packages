#import "dependency.typ": *
#let sdu-red = rgb("#880000")
#let sdu-logo = image("img/sdu.png", height: 10%)
#set text(region: "CN")
#let outline-slide(title: [Outline], column: 2, marker: auto, ..args) = touying-slide-wrapper(self => {
  let info = self.info + args.named()
  let header = {
    set align(center + bottom)
    block(
      fill: self.colors.neutral-lightest,
      outset: (x: 2.4em, y: .8em),
      stroke: (bottom: self.colors.primary + 3.2pt),
      text(self.colors.primary, weight: "bold", size: 1.6em, title),
    )
  }
  let body = {
    set align(horizon)
    show outline.entry: it => {
      let mark = if (marker == auto) {
        image("img/uob-bullet.svg", height: .8em)
      } else if type(marker) == image {
        set image(height: .8em)
        image
      } else if type(marker) == symbol {
        text(fill: self.colors.primary, marker)
      }
      block(stack(dir: ltr, spacing: .8em, mark, link(it.element.location(), it.body())), below: 0pt)
    }
    show: pad.with(x: 1.6em)
    columns(column, outline(title: none, indent: 1em, depth: 1))
  }
  self = utils.merge-dicts(
    self,
    config-page(
      header: header + v(-4em),
      margin: (top: 2em, bottom: 1.6em),
      fill: self.colors.neutral-lightest,
    ),
  )
  touying-slide(self: self, body)
})
#let title-slide(
  config: (:),
  extra: none,
  ..args,
) = touying-slide-wrapper(self => {
  self = ty.utils.merge-dicts(
    self,
    config,
    config-common(freeze-slide-counter: true),
    config-page(margin: 0em),
  )
  let info = self.info + args.named()
  let body = {
    if info.logo != none {
      v(1em)
      pad(left: 1cm)[
        #info.logo
      ]
    }
    v(-0.7em)
    image("img/sdu-title.png")

    let content = {
      text(
        size: 1.35em,
        fill: white,
        weight: "bold",
        info.title,
      )
      if info.subtitle != none {
        parbreak()
        text(size: 1.0em, fill: self.colors.neutral-lightest, weight: "bold", info.subtitle)
      }
      grid(
        text(fill: white, info.author)
      )
      // v(0.2em)
      // 介绍
      if info.institution != none {
        parbreak()
        text(size: 0.8em, fill: white, info.institution)
      }
      // 日期
      if info.date != none {
        parbreak()
        text(size: 1.0em, fill: white, info.date.display())
      }
    }

    place(
      dx: 2em,
      dy: -13.2em,
      content,
    )
    align(
      right,
      pad(right: 0.7cm)[
        #image("img/word.png")
      ],
    )
  }
  touying-slide(self: self, body)
})

#let sdu-footer(self) = {
  set align(bottom + center)
  set text(size: 0.8em)
  show: pad.with(.0em)
  block(
    width: 100%,
    height: 1.5em,
    fill: self.colors.primary,
    pad(
      y: .4em,
      x: 2em,
      grid(
        columns: (auto, 1fr, auto, auto),
        text(fill: self.colors.neutral-lightest.lighten(40%), ty.utils.call-or-display(self, self.store.footer-a)),
        text(fill: self.colors.neutral-lightest.lighten(40%), ty.utils.call-or-display(self, self.store.footer-c)),
        text(fill: self.colors.neutral-lightest.lighten(10%), ty.utils.call-or-display(self, self.store.footer-d)),
      ),
    ),
  )
}

#let footer-backend(self) = {
  self => [
    #if self.store.footer == true {
      set text(0.7em)
      // Colored Style
      if (self.store.theme == "full") {
        columns(2, gutter: 0cm)[
          // Left side of the Footer
          #align(left)[#block(
              width: 100%,
              outset: (left: 0.3 * self.store.space, bottom: 0cm),
              height: 0.1 * self.store.space,
              fill: self.colors.primary,
              inset: (right: 3pt),
            )[
              #v(0.1 * self.store.space)
              #set align(right)
              #smallcaps()[#if self.info.author != none { self.info.author } else { title }]
            ]
          ]
          // Right Side of the Footer
          #align(right)[#block(
              width: 100%,
              outset: (right: 2 * self.store.space, bottom: 0cm),
              height: 0.1 * self.store.space,
              fill: self.colors.primary,
              inset: (left: 3pt),
            )[
              #v(0.1 * self.store.space)
              #set align(left)
              #if self.info.subtitle != none {
                self.info.subtitle
              } else if subtitle != none {
                subtitle
              } else if authors != none {
                if (type(authors) != array) { authors = (authors,) }
                authors.join(", ", last: " and ")
              } else [#date]
            ]
          ]
        ]
      } // Normal Styling of the Footer
      else if (self.store.theme == "normal") {
        box()[#line(length: 50%, stroke: 2pt + self.colors.primary)]
        box()[#line(length: 50%, stroke: 2pt + self.colors.primary)]
        v(-0.2cm)
        grid(
          columns: (1fr, 1fr),
          align: (right, left),
          inset: 5pt,
          [#smallcaps()[
              #if self.info.author != none { self.info.author } else { title }]],
          [#if self.info.subtitle != none {
              self.info.subtitle
            } else if subtitle != none {
              subtitle
            } else if authors != none {
              if (type(authors) != array) { authors = (authors,) }
              authors.join(", ", last: " and ")
            } else [#date]
          ],
        )
      }
    }
  ]
}
#let slide(
  title: auto,
  align: auto,
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  let header(self) = {
    set std.align(top)
    show: components.cell.with(fill: self.colors.secondary, inset: 1em)
    set std.align(horizon)
    set text(fill: self.colors.secondary-dark, weight: "medium", size: 1.2em)
    v(1em)
    components.left-and-right(
      {
        context {
          let page = here().page()
          let heads = query(selector(heading.where(level: 1)))
          let headings = query(selector(heading.where(level: 2)))
          let heading = headings.rev().find(x => x.location().page() <= page)
          let is-new-section = (
            heads.any(it => it.location().page() == page) or ty.utils.slide-counter == ty.utils.last-slide-number
          )
          if not is-new-section {
            if heading != none {
              if (self.store.theme == "normal") {
                v(self.store.space / 1)
                // h(self)

                set text(1.4em, weight: "bold", fill: self.colors.primary)
                block(
                  h(0.3cm)
                    + heading.body
                    + if not heading.location().page() == page [
                      #{ numbering("(i)", page - heading.location().page() + 1) }
                    ],
                )
              }
            }
          }
        }
      },
      {
        [#if self.store.count == true {
            [
              #context {
                let last = counter(page).final().first()
                let current = here().page()
                // Before the current page
                for i in range(1, current) {
                  link((page: i, x: 0pt, y: 0pt))[
                    #box(circle(radius: 0.08cm, fill: self.colors.primary, stroke: 1pt + self.colors.primary))
                  ]
                }
                // Current Page
                link((page: current, x: 0pt, y: 0pt))[
                  #box(circle(radius: 0.08cm, fill: self.colors.primary, stroke: 1pt + self.colors.primary))
                ]
                // After the current page
                for i in range(current + 1, last + 1) {
                  link((page: i, x: 0pt, y: 0pt))[
                    #box(circle(radius: 0.08cm, stroke: 1pt + self.colors.primary))
                  ]
                }
              }
              #h(1cm)
            ]
          }]
      },
    )
  }
  self = ty.utils.merge-dicts(
    self,
    config,
    config-common(freeze-slide-counter: false),
    config-page(),
  )
  let self = ty.utils.merge-dicts(
    self,
    config-page(
      fill: self.colors.neutral-lightest,
      header: header,
      footer: self.methods.footer,
    ),
  )
  let new-setting = body => {
    show: std.align.with(horizon)
    set text(fill: self.colors.neutral-darkest)
    show: setting
    body
  }
  touying-slide(self: self, config: config, repeat: repeat, setting: new-setting, composer: composer, ..bodies)
})



#let new-section-slide(level: 1, numbered: true, title) = touying-slide-wrapper(self => {
  let header = {
    ty.components.progress-bar(height: 8pt, self.colors.primary, self.colors.primary.lighten(40%))
  }
  let body = {
    set align(horizon + center)
    show: pad.with(10%)
    set text(size: 1.5em, fill: self.colors.neutral-lightest, weight: "bold")
    context {
      block(
        // outset: (right: 2pt, bottom: 2pt),
        fill: self.colors.neutral-light,
        radius: 8pt,
        move(
          dx: -4pt,
          dy: -4pt,
          block(
            width: 100%,
            fill: self.colors.primary,
            inset: (x: 1em, y: .8em),
            radius: 8pt,
            ty.utils.display-current-heading(level: level, numbered: numbered),
          ),
        ),
      )
      let start-page = 1
      let end-page = calc.inf
      if level != none {
        let current-heading = ty.utils.current-heading(level: level)
        if current-heading != none {
          start-page = current-heading.location().page()
          let next-headings = query(
            selector(heading.where(level: level)).after(inclusive: false, current-heading.location()),
          )
          if next-headings != () {
            end-page = next-headings.at(0).location().page()
          } else {
            end-page = calc.inf
          }
        }
      }
      let chapters = query(
        heading.where(
          level: 2,
          outlined: true,
        ),
      )
      set par(
        first-line-indent: 0.5em,
        spacing: 0.65em,
        justify: true,
      )
      set text(size: 0.7em, fill: self.colors.primary)
      for chapter in chapters {
        if chapter.location().page() >= start-page and chapter.location().page() <= end-page {
          link(chapter.location(), chapter.body)
          v(0em)
        }
      }
    }
  }
  self = utils.merge-dicts(
    self,
    config-page(
      fill: self.colors.neutral-lightest,
      header: header,
      footer: sdu-footer,
      margin: 0em,
    ),
  )
  touying-slide(self: self, body)
})


#let ending-slide(config: (:), title: none, body) = touying-slide-wrapper(self => {
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
  touying-slide(self: self, content)
})

#let slides(config: (:), title-slide: true, slide-level: 1, ..args) = touying-slide-wrapper(self => {
  if title-slide {
    title-slide(self: self)
  }
  touying-slides(self: self, slide-level: slide-level, ..args)
})


#let focus-slide(config: (:), background-color: sdu-red, background-img: none, body) = touying-slide-wrapper(self => {
  let background-color = if background-img == none and background-color == none {
    self.colors.primary
  } else {
    background-color
  }
  self = ty.utils.merge-dicts(
    self,
    config,
    config-common(freeze-slide-counter: true),
    config-page(margin: 0em),
  )
  set text(fill: white, size: 2em)
  touying-slide(self: self, align(horizon, body))
})

#let matrix-slide(config: (:), columns: none, rows: none, ..bodies) = touying-slide-wrapper(self => {
  self = ty.utils.merge-dicts(
    self,
    config,
    config-common(freeze-slide-counter: true),
    config-page(margin: 0em),
  )
  touying-slide(
    self: self,
    config: config,
    composer: (..bodies) => {
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
        panic(
          "number of rows ("
            + str(num-rows)
            + ") * number of columns ("
            + str(num-cols)
            + ") must at least be number of content arguments ("
            + str(bodies.len())
            + ")",
        )
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
    },
    ..bodies,
  )
})

#let sdu-theme(
  aspect-ratio: "16-9",
  header: self => utils.display-current-heading(
    setting: utils.fit-to-width.with(grow: false, 100%),
    depth: self.slide-level,
  ),
  footer-line-color: none,
  footer-columns: true,
  footer-a: self => self.info.author,
  footer-b: self => none,
  footer-c: self => if self.info.short-title == auto {
    self.info.title
  } else {
    self.info.short-title
  },
  footer-d: context ty.utils.slide-counter.display() + " / " + ty.utils.last-slide-number,
  ..args,
  body,
) = {
  show: touying-slides.with(
    config-colors(
      primary: sdu-red,
      primary-dark: rgb("#004098"),
      secondary: rgb("#ffffff"),
      tertiary: sdu-red,
      neutral-lightest: rgb("#ffffff"),
      neutral-darkest: rgb("#000000"),
      themeblue: rgb("#4285f4"),
      themegreen: rgb("#34a853"),
      themeyellow: rgb("#fbbc05"),
      themered: rgb("#ea4335"),
    ),
    config-store(
      align: align,
      count: true,
      theme: "normal",
      alpha: 60%,
      footer: true,
      space: 1cm,
      sdu-knob-marker: self => box(
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
      ),
      header: header,
      header-right: none,
      footer-a: footer-a,
      footer-b: footer-b,
      footer-c: footer-c,
      footer-d: footer-d,
      footer-line-color: footer-line-color,
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
    ),
    config-page(
      paper: "presentation-" + aspect-ratio,
      margin: (top: 4em, bottom: 1.7em, x: 2em),

      header-ascent: 1.9cm,
      footer-descent: 0%,
    ),
    config-methods(
      d-cover: (self: none, body) => {
        utils.cover-with-rect(
          fill: utils.update-alpha(
            constructor: rgb,
            self.page-args.fill,
            self.d-alpha,
          ),
          body,
        )
      },
      footer: sdu-footer,
      alert: (self: none, it) => text(fill: self.colors.primary, it),
      tblock: (self: none, title: none, it) => {
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
      },
      init: (self: none, body) => {
        set text(size: 20pt)
        show heading: set text(fill: self.colors.primary)
        set list(marker: self.store.sdu-knob-marker)
        show figure.caption: set text(size: 0.6em)
        show footnote.entry: set text(size: 0.6em)
        show link: it => if type(it.dest) == str {
          set text(fill: self.colors.primary)
          it
        } else {
          it
        }
        body
      },
    ),
    ..args,
  )
  body
}
