#import "@preview/touying:0.6.1": *

#let _theme_colors = state("colors", ())

#let container = rect.with(height: 100%, width: 100%, inset: 0pt)
#let innerbox = rect.with(stroke: (dash: "dashed"))
#let margin = (x: 4em, y: 2em)
#let liublue = rgb(0, 185, 231)
#let linkcolor = rgb(51, 102, 204)

#let footer-comment(alignment: right, size: 14pt, comment) = {
  place(
    left + bottom,
    dx: 40mm,
    dy: 19mm,
    box(stroke: 0pt, inset: 5mm, height: 15mm, width: 220mm, align(alignment + horizon, text(size: size, comment))),
  )
}

#let text-box(content, alignment: center, stroke: 2pt + liublue, width: auto) = {
  box(stroke: stroke, fill: white, width: width, radius: 10pt, inset: 5mm, align(alignment, content))
}

#let text-block(
  title,
  width: 100%,
  height: auto,
  fg: none,
  bg: white.darken(5%),
  stroke: 0.5pt,
  alignment: left,
  body,
) = context {
  rect(
    stroke: stroke,
    width: width,
    height: height,
    radius: 5mm,
    inset: 0mm,
    outset: 0mm,
    fill: bg,
    [
      #if (title != none) [
        #align(center, rect(
          radius: 5mm,
          width: 100%,
          fill: if fg == none { _theme_colors.get().primary } else { fg },
          inset: 3mm,
          text(fill: white, title),
        ))
        #v(-9mm)]
      #align(alignment, box(inset: 5mm, stroke: 0pt, width: 100%, body))
    ],
  )
}

#let slide(title: auto, ..args) = touying-slide-wrapper(self => {
  _theme_colors.update(self.colors)
  if title != auto {
    self.store.title = title
  }
  // set page
  let header(self) = {
    set align(horizon)
    // container[#innerbox[#pad(x: 1.6em, y: 0.0em, align(text(font: self.store.header-font, size: 1.5em, "Header")))]]
    set par(spacing: 0mm)
    set align(horizon)
    set text(font: self.store.header-font, size: 1.5 * self.store.size)
    pad(x: 1.2em, align(
      utils.fit-to-width(grow: false, 100%, utils.display-current-heading(level: 2)),
    ))
  }
  let footer(self) = {
    set par(spacing: 0mm)
    align(center, line(length: 90%))
    set text(size: self.store.size)

    context pad(
      x: 2em,
      y: 0.9em,
      align(right, text(size: 14pt, utils.slide-counter.display())),
    )
    place(left + bottom, dx: 5mm, dy: -2mm, image(self.store.logo.black, height: 18mm))
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

#let title-slide(
  config: (:),
  extra: none,
  logo-version: "white",
  ..args,
) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config,
    config-common(freeze-slide-counter: true),
    config-page(fill: self.colors.neutral-lightest),
  )
  let info = self.info + args.named()
  let body = {
    set page(fill: self.colors.theme-color)
    set page(
      background: if (self.store.title-background != none and type(self.store.title-background) != color) {
        image(self.store.title-background)
      } else { none },
      fill: if self.store.title-background == none { self.colors.theme-color } else { black },
    )

    set par(justify: false, spacing: 0.5em, leading: 0.4em)
    set text(fill: white, font: self.store.title-font, weight: "regular")
    block(
      width: 100%,
      inset: 2em,
      {
        set par(leading: 0.5em)
        text(size: 54pt, text(weight: "medium", info.title))
        if info.subtitle != none {
          linebreak()
          v(0.5em)
          text(size: 24pt, info.subtitle)
        }

        set text(size: 24pt)
        if info.author != none {
          block(spacing: 1em, info.author)
        }
        if info.date != none {
          block(spacing: 1em, utils.display-info-date(self))
        }
        set text(size: .8em)
        if info.institution != none {
          block(spacing: 1em, info.institution)
        }
      },
    )
    if extra != none {
      text(size: 28pt, extra)
    }
    place(left + bottom, float: false, dx: -5mm, dy: 20mm, image(
      if logo-version == "white" { self.store.logo.white } else { self.store.logo.black },
      height: 28mm,
    ))
  }

  touying-slide(self: self, body)
})

#let liu-sectioning-slide(config: (:), level: 1, numbered: true, body) = touying-slide-wrapper(self => {
  let slide-body = {
    set std.align(top)
    set page(fill: self.colors.theme-color)
    set text(fill: white, size: 35pt, font: self.store.header-font, weight: "regular")
    set par(spacing: 0.5em, leading: 0.4em, justify: false)
    v(0.5fr)
    block(inset: 10mm, stack(
      dir: ttb,
      spacing: 1em,
      text(
        white,
        utils.display-current-heading(
          level: 1,
          style: (setting: body => body, numbered: false, current-heading) => setting({
            current-heading.body
          }),
        ),
      ),
      if (self.progress-bar) {
        components.progress-bar(self.colors.neutral-lightest, gray)
      },
      text(size: 25pt, fill: white, body),
    ))
    place(left + bottom, float: false, dx: -20mm, dy: 19mm, image(
      self.store.logo.white,
      height: 18mm,
    ))
    v(1fr)
  }
  self = utils.merge-dicts(
    self,
    config-page(fill: self.colors.neutral-lightest),
  )
  touying-slide(self: self, config: config, slide-body)
})

#let end-slide(
  content,
  config: (:),
  extra: none,
  ..args,
) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config,
    config-common(freeze-slide-counter: true),
    config-page(fill: self.colors.neutral-lightest),
  )
  let body = {
    set page(fill: self.colors.theme-color)

    set par(justify: false, spacing: 0.5em, leading: 0.4em)
    set text(fill: white, font: self.store.header-font, weight: "regular")
    align(center + horizon, block(
      width: 100%,
      inset: 2em,
      text(size: 1.5em, text(weight: "regular", content)),
    ))
    place(left + bottom, float: false, dx: -5mm, dy: 20mm, image(
      self.store.logo.white,
      height: 28mm,
    ))
  }
  touying-slide(self: self, body)
})

#let liu-theme(
  title: "A Title",
  subtitle: none,
  author: "An Author",
  lang: "en",
  handout: false,
  title-font: ("Liberation Sans", "Libertinus Sans", "Helvetica"),
  header-font: ("Liberation Sans", "Libertinus Sans", "Helvetica"),
  body-font: ("Liberation Serif", "Libertinus Serif", "Georgia"),
  math-font: "New Computer Modern Math",
  title-background: "assets/backgrounds/background_01.jpg",
  progress-bar: true,
  size: 20pt,
  ..args,
  body,
) = {
  set text(size: size, font: body-font, lang: lang)
  show math.equation: set text(font: math-font)
  set par(spacing: 1.1em, leading: 0.6em, justify: false)

  set list(spacing: 1.0em)
  set enum(spacing: 1.0em)
  set grid(gutter: 10mm)

  set outline(depth: 1)

  let logo-versions = (
    "sv": (
      black: "assets/logo/LiU_primar_svart.svg",
      white: "assets/logo/LiU_primar_vit.svg",
    ),
    "en": (
      black: "assets/logo/LiU_primary_black.svg",
      white: "assets/logo/LiU_primary_white.svg",
    ),
  )

  show: touying-slides.with(
    config-info(
      title: title,
      subtitle: subtitle,
      author: author,
    ),
    config-page(
      paper: "presentation-16-9",
      margin: (bottom: 21mm, x: 2em, top: 25mm),
      header-ascent: 0em,
      footer-descent: 3.8mm,
    ),
    config-common(
      slide-fn: slide,
      handout: handout,
      progress-bar: progress-bar,
      new-section-slide-fn: liu-sectioning-slide,
    ),
    config-colors(
      primary: liublue, //rgb(64, 101, 197),
      neutral-lightest: rgb("#ffffff"),
      neutral-darkest: rgb("#000000"),
      theme-color: liublue,
    ),
    config-methods(alert: (self: none, it) => text(fill: self.colors.primary, it)),
    config-store(
      title: none,
      footer: none,
      header-font: header-font,
      body-font: body-font,
      title-font: title-font,
      math-font: math-font,
      title-background: title-background,
      lang: lang,
      logo: logo-versions.at(lang),
      size: size,
    ),
    ..args,
  )


  // _theme_colors.update(this.colors)
  // let args = (configs.default-config,) + args.pos()
  // let self = utils.merge-dicts(..args)


  // Style links
  show link: this => {
    if type(this.dest) == label {
      this
    } else {
      text(this, fill: linkcolor, weight: "regular")
    }
  }

  // show raw.where(lang: "typst"): it => {
  show raw.where(lang: "typst"): it => {
    box(width: 100%, fill: white.darken(5%), inset: 0.55em, radius: 0.55em)[
      #it
    ]
  }

  body
}
