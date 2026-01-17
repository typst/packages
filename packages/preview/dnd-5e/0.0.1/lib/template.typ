#import "config.typ"
#import "core.typ"
#import "utils.typ"
#import "flex-heading.typ"

#import "external.typ"

#let footer-template(self, lr: str, chapter-name: str) = {
  let chap-align = left
  if lr == "right" {
    chap-align = right
  }

  align(
    bottom + center,
    [
      #place(
        chap-align + top,
        dx: self.style.footer.at(lr).number.dx,
        dy: self.style.footer.at(lr).number.dy,
        circle(radius: 12pt, stroke: self.fill.footer.debug)[
          #align(center + horizon)[
            #text(
              font: self.font.footer.font,
              size: self.font.footer.number.size,
              fill: self.fill.footer.fill,
              weight: self.font.footer.number.weight,
            )[
              #context counter(page).display("1")
            ]
          ]
        ],
      )
      #place(
        chap-align + top,
        dx: self.style.footer.at(lr).chapter.dx,
        dy: self.style.footer.at(lr).chapter.dy,
        [
          #text(
            font: self.font.footer.font,
            size: self.font.footer.chapter.size,
            weight: self.font.footer.chapter.weight,
            fill: self.fill.footer.fill,
          )[
            #chapter-name
          ]
        ],
      )
      #image(self.style.footer.at(lr).image, width: 133%)
    ],
  )
}

#let dnd-template(
  is-first: true,
  title-page: none,
  ..args,
  body,
) = {
  let args = (config.default-config,) + args.pos()
  let self = utils.merge-dicts(..args)

  set document(
    ..(
      if type(self.info.title) in (str, content) {
        (title: self.info.title)
      }
    ),
    ..(
      if type(self.info.author) in (str, array) {
        (author: self.info.author)
      } else if type(self.info.author) == content {
        (author: self.info.author.map(author => author.name))
      }
    ),
    ..(
      if type(self.info.date) in (datetime,) {
        (date: self.info.date)
      }
    ),
  )

  let background = self.page.background
  if type(background) != content {
    background = image(self.page.background, height: 100%, width: 100%, fit: "cover")
  }

  set page(
    paper: self.page.paper,
    background: background,
    footer: context {
      {
        let elements = query(selector(heading.where(level: 2, outlined: true)).before(here()))

        if elements.len() > 0 {
          let chapter-name = none
          if self.page.show-chapter {
            chapter-name = upper([#external.transl("chapter") ] + str(elements.len()) + " | " + elements.last().body)
          } else {
            chapter-name = elements.last().body
          }

          // Format the chapter name
          chapter-name = utils.call-if-fn(self.font.footer.chapter.style, chapter-name)


          // Determine if the current page is even or odd
          let is-even-page = calc.rem(here().page(), 2) == 0

          // Define footer content based on page parity
          let footer-content = if is-even-page {
            footer-template(self, lr: "right", chapter-name: chapter-name)
          } else {
            footer-template(self, lr: "left", chapter-name: chapter-name)
          }

          // Render the footer content
          footer-content
        }
      }
    },
    footer-descent: -100pt,
  ) if is-first

  external.transl(data: eval(external.fluent("l10n/", lang: ("en", self.page.lang))))

  set text(
    font: self.font.global.font,
    size: self.font.global.size,
    weight: self.font.global.weight,
    fill: self.fill.global.text,
    tracking: -0.2pt,
    lang: self.page.lang,
    // overhang: true
  )

  // // set par(leading: 0.9pt)


  // ////////////////////////////////////////////
  // ////////////////////////////////////////////
  // // HEADERS

  set heading(numbering: "1.")
  show heading.where(level: 1): it => context {
    let parts = counter(heading).get()

    if parts.last() == 0 {
      smallcaps[
        #text(
          fill: self.fill.headers.level-2,
          font: self.font.headers.level-1.font,
          size: self.font.headers.level-1.size,
          weight: self.font.headers.level-1.weight,
        )[#it.body #v(-2.3em)]
      ]
      linebreak()
      linebreak()
    } else {
      pagebreak(weak: true)
      align(center + horizon)[
        #smallcaps[
          #text(
            font: self.font.headers.level-1.font,
            size: self.font.headers.level-1.size,
            stroke: self.font.headers.level-1.stroke,
            weight: self.font.headers.level-1.weight,
            fill: self.fill.headers.level-1,
          )[
            #if self.page.show-part { 
              [#external.transl("part") #counter(heading).at(it.location()).last() #linebreak() #it.body]           
            } else {
              it.body
            }
          ]
        ]
      ]
    }
  }

  show heading.where(level: 2): it => context {
    if (
      it.fields().keys().contains("label") and it.label != "dnd-image-heading-section"
        or not it.fields().keys().contains("label")
    ) {
      pagebreak()
    }

    align(left)[
      #text(
        font: self.font.headers.level-2.font,
        weight: self.font.headers.level-2.weight,
        size: self.font.headers.level-2.size,
        stroke: self.font.headers.level-2.stroke,
        fill: self.fill.headers.level-2,
      )[
        #if self.page.show-chapter {
          // counter(heading).at(it.element.location())
          [#smallcaps[#external.transl("chapter") #counter(heading).at(it.location()).last(): #it.body]]
        } else {
          it.body
        }
      ]
    ]
  }

  show heading.where(level: 3): it => {
    text(
      font: self.font.headers.level-3.font,
      size: self.font.headers.level-3.size,
      weight: self.font.headers.level-3.weight,
      fill: self.fill.headers.level-3,
    )[
      #smallcaps(it.body)
      #linebreak()
    ]
  }

  show heading.where(level: 4): it => {
    v(-6pt)
    stack(
      spacing: self.style.headers.level-4.line-spacing,
      text(
        font: self.font.headers.level-4.font,
        size: self.font.headers.level-4.size,
        weight: self.font.headers.level-4.weight,
        fill: self.fill.headers.level-4,
      )[
        #smallcaps(it.body)
      ],
      line(
        stroke: (
          paint: self.fill.headers.level-4-line,
          thickness: self.style.headers.level-4.line-thickness,
        ),
        length: 100%,
      ),
      v(-4pt),
    )
  }

  show heading.where(level: 5): it => {
    text(
      font: self.font.headers.level-5.font,
      size: self.font.headers.level-5.size,
      weight: self.font.headers.level-5.weight,
      fill: self.fill.headers.level-5,
    )[
      #smallcaps[#it.body]
      #linebreak()
    ]
  }

  show heading.where(level: 6): it => {
    v(-0.6em, weak: false)
    set text(
      font: self.font.headers.level-6.font,
      size: self.font.headers.level-6.size,
    )

    (self.font.headers.level-6.style)(it.body + ". ")
  }

  show heading.where(level: 7): it => {
    v(-0.6em, weak: false)
    h(1em, weak: false)
    set text(
      font: self.font.headers.level-7.font,
      size: self.font.headers.level-7.size,
    )
    (self.font.headers.level-7.style)(it.body)
  }

  ////////////////////////////////////////////
  ////////////////////////////////////////////
  /// OUTLINE

  let indent = (
    "1": 0em,
    "2": 1em,
    "3": 2em,
    "4": 3em,
    "5": 4em,
    "6": 5em,
    "7": 6em,
  )

  let indent-outline(level) = {
    if self.style.outline.indent {
      if not self.page.using-parts {
        h(indent.at(str(level - 1)))
      } else {
        h(indent.at(str(level)))
      }
    }
  }

  show outline.entry: it => {
    link(
      it.element.location(),
      [
        #if it.level == 1 {
          let part-num = counter(heading).at(it.element.location())
          stack(
            spacing: 3pt,
            text(
              font: self.font.outline.level-1.font,
              size: self.font.outline.level-1.size,
              weight: self.font.outline.level-1.weight,
              fill: self.fill.outline.level-1,
            )[
              #if self.page.show-part {
                utils.maybe-apply-style(self.font.outline.level-1.style, {
                  [#external.transl("part") #str(part-num.last()): #it.body()]
                })
              } else {
                utils.maybe-apply-style(self.font.outline.level-1.style, { it.body() })
              }
            ],
            line(
              stroke: (
                paint: self.fill.outline.line,
                thickness: 1.2pt,
              ),
              length: 100%,
            ),
          )
        } else if it.level == 2 {
          let ch-num = counter(heading).at(it.element.location())

          v(12pt, weak: true)
          indent-outline(it.level)

          utils.maybe-apply-style(self.font.outline.level-2.style, {
            text(
              fill: self.fill.outline.level-2,
              size: self.font.outline.level-2.size,
              weight: self.font.outline.level-2.weight,
            )[
              #if self.page.show-chapter {
                [#external.transl("chapter", t: "short") #ch-num.last(): ]
              }
              #it.body()
              #box(width: 1fr, repeat([#self.style.outline.repeated-symbol], gap: 0.15em, justify: true))
              #it.page()
              #linebreak()
            ]
          })
        } else {
          (
            indent-outline(it.level)
              + it.body()
              + box(width: 1fr, repeat([#self.style.outline.repeated-symbol], gap: 0.15em, justify: true))
              + it.page()
              + linebreak()
          )
        }
      ],
    )
  }

  show table.cell.where(y: 0): set text(
    font: self.font.table.header.font,
    weight: self.font.table.header.weight,
    fill: self.fill.table.header,
  )
  show table.cell: set align(left)
  show table: set text(font: self.font.table.body.font)
  set table(fill: (none_, y) => if calc.odd(y) { self.fill.table.cell }, stroke: none)

  // FIGURE CONFIG
  set figure.caption(position: top)
  show figure.caption: it => {
    set text(
      size: self.font.table.title.size,
      font: self.font.table.title.font,
      weight: self.font.table.title.weight,
    )
    set align(left)
    if type(self.font.table.title.style) == function {
      (self.font.table.title.style)(it.body)
    } else {
      it.body
    }
  }

  show: core.show-content-with-warp.with(self: self, is-first-slide: false)

  body
}

#let show-outline() = {
  show outline: it => {
    utils.in-outline.update(true)
    it
    utils.in-outline.update(false)
  }

  set page(columns: 2)
  outline()
  set page(columns: 1)
}

#let dnd-par(
  config: (:),
  body,
) = core.fn-wrapper(self => {
  [====== #body]
})

#let dnd-subpar(body) = core.fn-wrapper(self => {
  [======= #body]
})

#let dnd-image-page(config: (:), img) = core.fn-wrapper(self => {
  panic("not implemented yet")
  if config != (:) {
    self = utils.merge-dicts(self, config)
  }

  set image(height: 100%, width: 100%, fit:"cover")
  set page(background: img, footer: none)
  
  [a]
  // Maybe reset to standard
})

#let dnd-image-heading-part(config: (:), img, title-styled, title-unstyled: none) = core.fn-wrapper(self => {
  if config != (:) {
    self = utils.merge-dicts(self, config)
  }

  
  set image(height: 100%, width: 100%, fit:"cover")
  set page(background: img, footer: none)

  heading(depth: 1)[
    #if title-unstyled != none {
      flex-heading.flex-heading(title-styled, title-unstyled)
    } else {
      title-styled
    }
  ]
})

#let dnd-image-heading-section(
  config: (:),
  img,
  depth,
  title-styled,
  offset: 0em,
  title-unstyled: none,
  img-height: auto,
  img-width: auto,
  img-fit: "cover",
  alignment: center,
) = core.fn-wrapper(self => {
  if config != (:) {
    self = utils.merge-dicts(self, config)
  }

  show heading.where(level: 2): it => context {
    align(alignment)[
      #text(
        font: self.font.headers.level-2.font,
        weight: self.font.headers.level-2.weight,
        size: self.font.headers.level-2.size,
        stroke: self.font.headers.level-2.stroke,
        fill: self.fill.headers.level-2,
      )[
        #if self.page.show-chapter {
          [#smallcaps[#external.transl("chapter") #counter(heading).get().last(): #it.body]]
        } else {
          it.body
        }
      ]
    ]
  }

  pagebreak()

  context {
    let page-width = page.width

    set image(fit: img-fit, height: img-height, width: page-width)

    // TODO: find a way to automate this "7.5em"
    place(
      dy: -7.5em,
      top + center,
      img,
    )

    v(measure(img).height - 6.5em)
    v(-offset)
    // TODO: here we may add a "separator" for the heading and the body
  }

  [
    #heading(depth: depth)[
      #if title-unstyled != none {
        flex-heading.flex-heading(title-styled, title-unstyled)
      } else {
        title-styled
      }
    ]<dnd-image-heading-section>
  ]
})
