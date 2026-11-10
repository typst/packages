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

  set image(width: self.footer.image.scale)

  align(
    bottom + center,
    [
      #place(
        chap-align + top,
        dx: self.footer.image.at(lr).number.dx,
        dy: self.footer.image.at(lr).number.dy,
        circle(radius: 12pt, stroke: self.footer.image.debug)[
          #align(center + horizon)[
            #text(
              font: self.footer.body.font,
              size: self.footer.number.size,
              fill: self.footer.body.fill,
              weight: self.footer.number.weight,
            )[
              #context counter(page).display("1")
            ]
          ]
        ],
      )
      #place(
        chap-align + top,
        dx: self.footer.image.at(lr).chapter.dx,
        dy: self.footer.image.at(lr).chapter.dy,
        [
          #text(
            font: self.footer.body.font,
            size: self.footer.chapter.size,
            fill: self.footer.body.fill,
            weight: self.footer.chapter.weight,
          )[
            #chapter-name
          ]
        ],
      )
      #self.footer.image.at(lr).image
    ],
  )
}


#let dnd-template(
  is-first: true,
  title-page: none,
  ..args,
  body,
) = {
  let args = (config.default-config(),) + args.pos()
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

  set page(
    paper: self.page.paper,
    background: self.page.background,
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
          chapter-name = utils.call-if-fn(self.footer.chapter.style, chapter-name)


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

  // external.transl(data: eval(external.fluent("l10n/", lang: ("en", self.page.lang))))
  external.transl(data: read("l10n/it.ftl"), lang: "it")
  external.transl(data: read("l10n/en.ftl"), lang: "en")

  set text(
    font: self.global.text.font,
    size: self.global.text.size,
    weight: self.global.text.weight,
    fill: self.global.text.fill,
    hyphenate: true,
    tracking: -0.2pt,
    lang: self.page.lang,
    // overhang: true
  )

  // // set par(leading: 0.9pt)


  // ////////////////////////////////////////////
  // ////////////////////////////////////////////
  // // HEADERS

  set heading(numbering: "1.")
  show heading.where(level: 1): it => {
    let parts = counter(heading).get()

    if parts.last() == 0 {
      smallcaps[
        #text(
          fill: self.headers.level-2.fill,
          font: self.headers.level-1.font,
          size: self.headers.level-1.size,
          weight: self.headers.level-1.weight,
        )[#it.body #v(-2.3em)]
      ]
      linebreak()
      linebreak()
    } else {
      pagebreak(weak: true, to: self.headers.level-1.to)
      align(center + horizon)[
        #smallcaps[
          #text(
            font: self.headers.level-1.font,
            size: self.headers.level-1.size,
            stroke: self.headers.level-1.stroke,
            weight: self.headers.level-1.weight,
            fill: self.headers.level-1.fill,
          )[
            #if self.page.show-part {
              [#external.transl("part") #counter(heading).at(it.location()).last() #linebreak() #it.body]
            } else {
              utils.maybe-apply-style(self.headers.level-1.style, { it.body() })
            }
          ]
        ]
      ]
    }
  }

  show heading.where(level: 2): it => {
    if (
      it.fields().keys().contains("label") and it.label != "dnd-image-heading-section"
        or not it.fields().keys().contains("label")
    ) {
      pagebreak()
    }

    align(left)[
      #text(
        font: self.headers.level-2.font,
        weight: self.headers.level-2.weight,
        size: self.headers.level-2.size,
        stroke: self.headers.level-2.stroke,
        fill: self.headers.level-2.fill,
      )[
        #if self.page.show-chapter {
          [#smallcaps[#external.transl("chapter") #counter(heading).at(it.location()).last(): #it.body]]
        } else {
          utils.maybe-apply-style(self.headers.level-2.style, { it.body })
        }
      ]
    ]
  }

  show heading.where(level: 3): it => {
    text(
      font: self.headers.level-3.font,
      size: self.headers.level-3.size,
      weight: self.headers.level-3.weight,
      fill: self.headers.level-3.fill,
    )[
      #utils.maybe-apply-style(self.headers.level-3.style, { it.body })
      #linebreak()
    ]
  }

  show heading.where(level: 4): it => {
    v(-6pt)
    stack(
      spacing: self.headers.level-4.line.spacing,
      text(
        font: self.headers.level-4.font,
        size: self.headers.level-4.size,
        weight: self.headers.level-4.weight,
        fill: self.headers.level-4.fill,
      )[
        #utils.maybe-apply-style(self.headers.level-4.style, { it.body })
      ],
      line(
        stroke: (
          paint: self.headers.level-4.line.fill,
          thickness: self.headers.level-4.line.thickness,
        ),
        length: 100%,
      ),
      v(-4pt),
    )
  }

  show heading.where(level: 5): it => {
    text(
      font: self.headers.level-5.font,
      size: self.headers.level-5.size,
      weight: self.headers.level-5.weight,
      fill: self.headers.level-5.fill,
    )[
      #utils.maybe-apply-style(self.headers.level-5.style, { it.body })
      #linebreak()
    ]
  }

  show heading.where(level: 6): it => {
    v(-0.6em, weak: false)
    set text(
      font: self.headers.level-6.font,
      size: self.headers.level-6.size,
    )
    utils.maybe-apply-style(self.headers.level-6.style, { it.body + "." + h(1em, weak: true) })
  }

  show heading.where(level: 7): it => {
    v(-0.6em, weak: false)
    h(1em, weak: false)
    set text(
      font: self.headers.level-7.font,
      size: self.headers.level-7.size,
    )
    utils.maybe-apply-style(self.headers.level-7.style, { it.body })
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
    if self.outline.indent {
      if not self.page.using-parts {
        h(indent.at(str(level - 1)))
      } else {
        h(indent.at(str(level)))
      }
    }
  }

  let show-lower-outlines(it, outline-text) = {
    (
      indent-outline(it.level)
        + outline-text
        + box(width: 1fr, repeat([#self.outline.repeated-symbol], gap: 0.15em, justify: true))
        + it.page()
        + linebreak()
    )
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
              font: self.outline.level-1.font,
              size: self.outline.level-1.size,
              weight: self.outline.level-1.weight,
              fill: self.outline.level-1.fill,
            )[
              #if self.page.show-part {
                utils.maybe-apply-style(self.outline.level-1.style, {
                  [#external.transl("part") #str(part-num.last()): #it.body()]
                })
              } else {
                utils.maybe-apply-style(self.outline.level-1.style, { it.body() })
              }
            ],
            line(
              stroke: (
                paint: self.outline.line.fill,
                thickness: self.outline.line.thickness,
              ),
              length: 100%,
            ),
          )
        } else if it.level == 2 {
          let ch-num = counter(heading).at(it.element.location())

          v(12pt, weak: true)
          indent-outline(it.level)

          utils.maybe-apply-style(self.outline.level-2.style, {
            text(
              font: self.outline.level-2.font,
              fill: self.outline.level-2.fill,
              size: self.outline.level-2.size,
              weight: self.outline.level-2.weight,
            )[
              #if self.page.show-chapter {
                [#external.transl("chapter", t: "short") #ch-num.last(): ]
              }
              #it.body()
              #box(width: 1fr, repeat([#self.outline.repeated-symbol], gap: 0.15em, justify: true))
              #it.page()
              #linebreak()
            ]
          })
        } else if it.level == 3 {
          set text(
            font: self.outline.level-3.font,
            size: self.outline.level-3.size,
            weight: self.outline.level-3.weight,
            fill: self.outline.level-3.fill,
          )
          let outline-text = utils.maybe-apply-style(self.outline.level-3.style, { it.body() })
          show-lower-outlines(it, outline-text)
        } else if it.level == 4 {
          let outline-text = utils.maybe-apply-style(self.outline.level-4.style, { it.body() })
          show-lower-outlines(it, outline-text)
        } else if it.level == 5 {
          let outline-text = utils.maybe-apply-style(self.outline.level-5.style, { it.body() })
          show-lower-outlines(it, outline-text)
        } else {
          (
            indent-outline(it.level)
              + it.body()
              + box(width: 1fr, repeat([#self.outline.repeated-symbol], gap: 0.15em, justify: true))
              + it.page()
              + linebreak()
          )
        }
      ],
    )
  }

  show table.cell.where(y: 0): set text(
    font: self.table.header.font,
    weight: self.table.header.weight,
    fill: self.table.header.fill,
  )
  show table.cell: set align(left)
  show table: set text(font: self.table.body.font, size: self.table.body.size, fill: self.table.body.fill)
  set table(
    fill: (none_, y) => if calc.odd(y) { self.table.cell.primary-fill } else {
      if y > 1 { self.table.cell.secondary-fill }
    },
    stroke: none,
  )

  // FIGURE CONFIG
  set figure.caption(position: top)
  show figure.caption: it => {
    set text(
      size: self.table.title.size,
      font: self.table.title.font,
      weight: self.table.title.weight,
    )
    set align(left)
    if type(self.table.title.style) == function {
      (self.table.title.style)(it.body)
    } else {
      it.body
    }
  }

  show: core.show-content-with-warp.with(self: self, is-first-slide: false)

  body
}

#let show-outline(n-cols: 2, do-pagebreak: true, balance-columns: false) = {
  show outline: it => {
    utils.in-outline.update(true)
    it
    utils.in-outline.update(false)
  }

  if (do-pagebreak == true) {
    pagebreak()
  }
  let l-outline = columns(n-cols)[
    #outline()
  ]
  if balance-columns {
    utils.columns-balance(
      n-cols: n-cols,
      l-outline,
    )
  } else {
    l-outline
  }
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

  set image(height: 100%, width: 100%, fit: "cover")
  set page(background: img, footer: none)

  [a]
  // Maybe reset to standard
})

#let dnd-image-heading-part(config: (:), img, title-styled, title-unstyled: none) = core.fn-wrapper(self => {
  if config != (:) {
    self = utils.merge-dicts(self, config)
  }


  set image(height: 100%, width: 100%, fit: "cover")
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
        font: self.headers.level-2.font,
        weight: self.headers.level-2.weight,
        size: self.headers.level-2.size,
        stroke: self.headers.level-2.stroke,
        fill: self.headers.level-2.fill,
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
