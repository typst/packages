// colors and assets https://github.com/ndgnuh/HUST-Beamer-Theme
#import "@preview/touying:0.6.1": *
// #import themes.stargazer: *

#let hustred = rgb("AD1D2F")
#let hustyellow = rgb("CE8C09")
#let hustblue = rgb("002E5C")

#let hust-color-theme(name: str) = {
  if name == "red" {
    (
      primary: hustred,
      secondary: hustyellow,
    )
  } else if name == "blue" {
    (
      primary: hustblue,
      secondary: hustred,
    )
  } else {
    panic("Unknown color theme: " + name)
  }
}

#let hust-image(self, name) = {
  let theme = self.store.theme
  let aspect-ratio = self.store.aspect-ratio
  return image("assets/" + name + "-" + theme + "-" + aspect-ratio + ".png")
}

#let slide(
  title: auto,
  header: auto,
  footer: auto,
  align: auto,
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  if align != auto {
    self.store.align = align
  }
  if title != auto {
    self.store.title = title
  }
  if header != auto {
    self.store.header = header
  }
  if footer != auto {
    self.store.footer = footer
  }
  let new-setting = body => {
    show: std.align.with(self.store.align)
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

#let title-slide(config: (:), ..args) = touying-slide-wrapper(self => {
  let new-config = config
  new-config = utils.merge-dicts(
    config,
    config-page(
      background: hust-image(self, "title-bg"),
      header: none,
      footer: none,
      margin: (top: 1em, left: 1em),
    ),
  )

  self = utils.merge-dicts(self, new-config)

  self.store.title = none

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
    image("assets/title-top-left.png", height: 18%)

    v(0.5fr)

    block(
      inset: (
        left: 0.5em,
        right: 5em,
      ),
      breakable: false,
      {
        text(
          size: 1.8em,
          fill: hustred,
          weight: "bold",
          info.title,
        )

        if info.subtitle != none {
          parbreak()
          text(
            size: 1.2em,
            fill: hustred,
            weight: "semibold",
            info.subtitle,
          )
        }

        v(0.5em)

        if info.author != none {
          parbreak()
          text(size: 1em, info.author, fill: hustred)
        }

        if info.institution != none {
          parbreak()
          text(size: 0.7em, info.institution, fill: hustred)
        }

        if info.date != none {
          parbreak()
          text(size: 0.7em, utils.display-info-date(self), fill: black)
        }
      },
    )

    v(1.0fr)
  }

  touying-slide(self: self, body)
})

#let outline-slide(
  config: (:),
  title: utils.i18n-outline-title,
  level: 1,
  numbered: true,
  ..args,
) = touying-slide-wrapper(self => {
  self.store.title = title
  touying-slide(
    self: self,
    config: config,
    std.align(
      self.store.outline-align,
      components.adaptive-columns(
        text(
          fill: self.colors.primary,
          weight: "bold",
          components.custom-progressive-outline(
            level: level,
            alpha: self.store.alpha,
            indent: (0em, 1em),
            vspace: (.4em,),
            numbered: (numbered,),
            depth: 1,
            ..args.named(),
          ),
        ),
      )
        + args.pos().sum(default: none),
    ),
  )
})

#let new-section-slide(
  config: (:),
  title: utils.i18n-outline-title,
  level: 1,
  numbered: true,
  ..args,
  body,
) = outline-slide(config: config, title: title, level: level, numbered: numbered, ..args, body)

#let ending-slide(
  config: (:),
  title: none,
) = touying-slide-wrapper(self => {
  // nice hack lol
  let dx = 36.4%
  let height = (
    100%
      - if self.store.aspect-ratio == "16-9" {
        2em
      } else {
        0.5em
      }
  )

  let content = place(
    box(
      width: 100% - dx,
      height: height,
      align(
        center + horizon,
        text(
          title,
          size: 3em,
          weight: "bold",
          fill: hustred,
        ),
      ),
    ),
    dx: dx,
  )

  let new-config = utils.merge-dicts(
    config,
    config-page(
      background: hust-image(self, "ending-bg"),
      header: none,
      footer: none,
      margin: 0em,
    ),
  )

  touying-slide(
    self: self,
    config: new-config,
    content,
  )
})

#let hust-theme(
  aspect-ratio: "16-9",
  theme: "red",
  align: horizon,
  outline-align: top,
  alpha: 20%,
  lang: "en",
  font: ("Lato",),
  title: self => utils.display-current-heading(depth: self.slide-level),
  footer-pagenum: text(context utils.slide-counter.display() + " / " + utils.last-slide-number, fill: hustred),
  progress-bar: true,
  ..args,
  body,
) = {
  if theme != "red" and theme != "blue" {
    panic("Unknown color theme: " + theme)
  }

  if aspect-ratio != "16-9" and aspect-ratio != "4-3" {
    panic("Unknown aspect ratio: " + aspect-ratio)
  }

  set text(lang: lang, font: font)
  // show: stargazer-theme.with(aspect-ratio: aspect-ratio, ..args)
  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      header: self => {
        set std.align(top)
        utils.call-or-display(self, self.store.header)
      },
      footer: self => {
        set std.align(bottom)
        set text(size: .5em)
        utils.call-or-display(self, self.store.footer)
      },
      header-ascent: 0em,
      footer-descent: 0em,
      margin: (top: 3.5em, bottom: 3em, x: 2.5em),
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
    ),
    config-methods(
      init: (self: none, body) => {
        set text(size: 20pt)
        set list(marker: components.knob-marker(primary: self.colors.primary))
        show figure.caption: set text(size: 0.6em)
        show footnote.entry: set text(size: 0.6em)
        show heading: set text(fill: self.colors.primary)
        show link: it => if type(it.dest) == str {
          set text(fill: self.colors.primary)
          it
        } else {
          it
        }

        show figure.where(kind: table): set figure.caption(position: top)

        body
      },
    ),
    config-colors(
      ..hust-color-theme(name: theme),
      neutral-lightest: white,
    ),
    config-store(
      aspect-ratio: aspect-ratio,
      theme: theme,
      align: align,
      outline-align: outline-align,
      alpha: alpha,
      title: title,
      footer-pagenum: footer-pagenum,
      progress-bar: progress-bar,
      header: self => if self.store.title != none {
        block(
          width: 100%,
          height: 2.2em,
          fill: self.colors.primary,
          place(
            left + horizon,
            text(
              fill: self.colors.neutral-lightest,
              weight: "bold",
              size: 1.3em,
              utils.call-or-display(self, self.store.title),
            ),
            dx: 1.5em,
          ),
          below: 0.25em,
        )
        rect(
          fill: self.colors.secondary,
          height: 0.2em,
          width: 100%,
        )
      },
      footer: self => {
        box(
          inset: (x: 1em, bottom: 1.5em),
          grid(
            columns: 2,
            rows: (1fr, 1fr),
            grid.cell(image("assets/footer-left.png", height: 3em), rowspan: 2),
            grid.cell(
              align: bottom,
              inset: (left: 2em),
              rect(
                fill: hustred,
                width: 100%,
                height: 0.2em,
              ),
            ),
            grid.cell(
              align: right,
              utils.call-or-display(self, self.store.footer-pagenum),
            )
          ),
        )
      },
    ),
    ..args,
  )

  body
}
