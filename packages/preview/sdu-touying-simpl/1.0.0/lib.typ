#import "dependency.typ": *

#let sdu-red = rgb("#880000")
#let sdu-logo = image("img/sdu.png", height: 10%)
#set text(region: "CN")

#let primary = sdu-red
#let primary-dark = rgb("#880000")
#let secondary = rgb("#ffffff")
#let neutral-lightest = rgb("#ffffff")
#let neutral-darkest = rgb("#000000")
#let themeblue = rgb("#4285f4")
#let themegreen = rgb("#34a853")
#let themeyellow = rgb("#fbbc05")
#let themered = rgb("#ea4335")

#let tblock(title: none, it) = {
  grid(
    columns: 1,
    row-gutter: 0pt,
    block(
      fill: primary,
      width: 100%,
      radius: (top: 6pt),
      inset: (top: 0.4em, bottom: 0.3em, left: 0.5em, right: 0.5em),
      text(fill: neutral-lightest, weight: "bold", title),
    ),
    rect(
      fill: gradient.linear(primary-dark, primary.lighten(90%), angle: 90deg),
      width: 100%,
      height: 4pt,
    ),
    block(
      fill: primary.lighten(90%),
      width: 100%,
      radius: (bottom: 6pt),
      inset: (top: 0.4em, bottom: 0.5em, left: 0.5em, right: 0.5em),
      it,
    ),
  )
}

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
      block(stack(dir: ltr, spacing: .8em, mark, link(it.element.location(), it.body())), below: 0pt,)
    }
    show: pad.with(x: 1.1em)
    pad(left:0%)[
      #outline(title: none, indent: 1em, depth: 1)
    ]
    
  }
  self = utils.merge-dicts(
    self,
    config-page(
      header: header + v(-4em),
      margin: (top: 0.5em, bottom: 1.6em),
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
      if info.institution != none {
        parbreak()
        text(size: 0.8em, fill: white, info.institution)
      }
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
        
        text(fill: self.colors.neutral-lightest, ty.utils.call-or-display(self, self.store.footer-a)),
        utils.fit-to-width(grow: false,100%,text(fill: self.colors.neutral-lightest.lighten(40%), ty.utils.call-or-display(self, self.store.footer-b))),
        text(fill: self.colors.neutral-lightest.lighten(10%), ty.utils.call-or-display(self, self.store.footer-c)),
      ),
    ),
  )
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
    
    ty.components.progress-bar(height: 8pt, self.colors.primary.lighten(20%), self.colors.primary.lighten(40%)) 
    
    set text(fill: self.colors.neutral-lightest, weight: "bold", size: 1.2em)
    set std.align(horizon)
    // v(1em)
    show: components.cell.with(fill: self.colors.primary, inset: 2em)
    utils.fit-to-width(grow: false,100%,ty.utils.display-current-heading(level: 2, numbered: false))
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
#let new-section-slide(config: (:), level: 1, numbered: true, body) = touying-slide-wrapper(self => {
  let header = {
    set std.align(top)
    ty.components.progress-bar(height: 8pt, self.colors.primary, self.colors.primary.lighten(40%))
  }
  let slide-body = {
    set std.align(horizon)
    show: pad.with(20%)
    set text(size: 1.5em)
    stack(
      dir: ttb,
      spacing: 1em,
      text(self.colors.neutral-darkest, utils.display-current-heading(level: level, numbered: numbered, style: auto)),
      block(
        height: 2pt,
        width: 100%,
        spacing: 0pt,
        components.progress-bar(height: 2pt, self.colors.primary, self.colors.primary-light),
      ),
    )
    text(self.colors.neutral-dark, body)
  }
  self = utils.merge-dicts(
    self,
    config-page(fill: self.colors.neutral-lightest, header: header),
  )
  touying-slide(self: self, config: config, slide-body)
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

#let focus-slide(body) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(
      fill: self.colors.primary,
      margin: 2em,
      header: none,
      footer: none,
    ),
  )
  set text(fill: self.colors.neutral-lightest, weight: "bold", size: 1.5em)
  touying-slide(self: self, align(horizon+center, body))
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
        let color = if calc.even(row + col) { self.colors.neutral-lightest } else { silver }
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
  footer-a: self => self.info.author,
  footer-b: self => if self.info.short-title == auto {
    self.info.title
  } else {
    self.info.short-title
  },
  footer-c: context ty.utils.slide-counter.display() + " / " + ty.utils.last-slide-number,
  ..args,
  body,
) = {
  show: touying-slides.with(
    config-colors(
      primary: primary,
      primary-dark: primary-dark,
      secondary: secondary,
      neutral-lightest: neutral-lightest,
      neutral-darkest: neutral-darkest,
      themeblue: themeblue,
      themegreen: themegreen,
      themeyellow: themeyellow,
      themered: themered,
    ),
    config-store(
      align: align,
      alpha: 60%,
      footer: true,
      header: header,
      header-right: none,
      footer-a: footer-a,
      footer-b: footer-b,
      footer-c: footer-c,
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
    ),
    config-page(
      paper: "presentation-" + aspect-ratio,
      margin: (top: 2.4em, bottom: 1.7em, x: 2.5em),
      header-ascent: 10%,
      footer-descent: 30%,
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
      init: (self: none, body) => {
        set text(size: 20pt)
        show heading: set text(fill: self.colors.primary)
        set list(marker: (text([#v(-0.2em)‣], fill: self.colors.primary, size: 1.6em),
                          text([--], fill: self.colors.primary)))
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
