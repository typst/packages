#import "@preview/touying:0.7.4": *
#import "statale-colors.typ" as palette
#import "utils.typ": _localization

/// Custom header.
/// -> content
#let _header-mi(
  /// Whether the header is for the outline.
  /// -> bool
  is-outline: false,
  self,
) = {
  show: pad.with(x: 1.782cm)
  grid(
    columns: 2,
    column-gutter: 1.1323cm,
    {
      set image(height: 3.182cm, width: 2.673cm)
      if not is-outline {
        self.store.header-logo-light
      } else {
        self.store.header-logo-dark
      }
    },
    align(
      bottom,
      context {
        show: pad.with(bottom: 0.25cm)
        set text(fill: if not is-outline { self.colors.primary } else { white })
        if is-outline {
          text(
            weight: "bold",
            size: 1.8em,
            _localization.at(text.lang).toc,
          )
        }
        text(
          weight: "bold",
          size: 26pt,
          utils.display-current-heading(level: 2),
        )
        linebreak()
        utils.display-current-heading(level: 1)
      },
    ),
  )
}

/// Custom footer.
/// -> content
#let _footer-mi(self) = {
  set align(bottom)
  set text(fill: white, size: 15pt)
  show: components.cell.with(
    fill: self.colors.primary,
    inset: (x: 1.782cm, y: 1em),
  )
  context utils.slide-counter.display() + "/" + utils.last-slide-number
  h(1fr)
  utils.call-or-display(
    self,
    (self.info.author, self.info.title).join(" | "),
  )
}

/// Draw the logo with the university name on the right.
/// -> content
#let _make-logo(
  _university: "Università\ndegli Studi\ndi Milano",
  _color: white,
) = {
  pad(
    1cm,
    grid(
      columns: 3,
      column-gutter: 0.5cm,
      align: horizon,
      image(
        if _color == white {
          "img/unimi-white.svg"
        } else {
          "img/unimi-black.svg"
        },
        height: 3.5cm,
      ),
      line(stroke: _color + 1pt, angle: 90deg, length: 3.5cm),
      align(left, text(
        fill: _color,
        weight: "bold",
        font: "Libertinus Serif",
        size: 23pt,
        upper(_university),
      )),
    ),
  )
}

/// Basic slide.
/// -> content
#let unimi-slide(
  /// The title of this slide.
  /// -> string
  title: auto,
  /// Touying overrides for this slide.
  /// -> dictionary
  config: (:),
  /// Whether to repeat this slide.
  /// -> auto | bool
  repeat: auto,
  /// Touying settings for this slide.
  /// -> dictionary
  setting: body => body,
  /// Touying compsoser arguments for this slide.
  /// -> dictionary
  composer: auto,
  ..args,
  body,
) = touying-slide-wrapper(self => {
  let info = self.info + args.named()
  let self = utils.merge-dicts(
    self,
    config-page(
      header: self.store.header,
      footer: self.store.footer,
    ),
  )
  touying-slide(
    self: self,
    config: config,
    repeat: repeat,
    setting: setting,
    composer: composer,
    ..args,
    body,
  )
})

/// The title slide.
/// -> content
#let title-slide(
  /// Touying overrides for this slide.
  /// -> dictionary
  config: (:),
  ..args,
) = touying-slide-wrapper(self => {
  let info = self.info + args.named()
  let body = {
    set align(horizon)
    set par(leading: 0.5em)
    if info.title != none {
      block(
        width: 63%,
        text(
          size: 27pt,
          fill: self.colors.primary,
          weight: "bold",
          info.title,
        ),
      )
    }
    if info.subtitle != none {
      block(
        width: 53%,
        text(
          size: 1em,
          fill: self.colors.primary,
          info.subtitle,
        ),
      )
    }
    if info.course != none {
      block(
        text(
          fill: self.colors.primary,
          size: 16pt,
          info.course,
        ),
      )
    }
    block({
      set text(size: 14pt)
      if info.author != none {
        strong(info.author)
      }
      if info.serial-number != none {
        " (" + info.serial-number + ")"
      }
    })
    if info.date != none {
      set text(size: 12pt)
      context {
        if text.lang == "it" {
          block({
            info.date.display("[day padding:none]")
            " "
            (
              "Gennaio",
              "Febbraio",
              "Marzo",
              "Aprile",
              "Maggio",
              "Giugno",
              "Luglio",
              "Agosto",
              "Settembre",
              "Ottobre",
              "Novembre",
              "Dicembre",
            )
              .map(lower)
              .at(info.date.month() - 1)
            " "
            info.date.display("[year]")
          })
        } else {
          block(utils.display-info-date(self))
        }
      }
    }
  }
  let self = utils.merge-dicts(
    self,
    config-page(
      header: self.store.header,
      background: context {
        set curve.line(relative: true)
        place(
          dx: page.width * 3 / 4,
          // trapezoid title page background
          curve(
            fill: self.colors.primary,
            curve.line((page.width * 1 / 4, 0cm)),
            curve.line((0cm, page.height)),
            curve.line((-page.width * 7 / 16, 0cm)),
            curve.close(),
          ),
        )
        align(
          right + bottom,
          self.info.logo,
        )
      },
    ),
    config-common(
      freeze-slide-counter: true,
    ),
  )
  touying-slide(self: self, config: config, body)
})

/// Last slide. Usually it contains "Thanks for listening!" or similar phrases.
/// -> content
#let focus-slide(
  /// Touying overrides for this slide.
  /// -> dictionary
  config: (:),
  body,
) = touying-slide-wrapper(self => {
  let self = utils.merge-dicts(
    self,
    config-page(fill: self.colors.primary),
    config-common(
      freeze-slide-counter: true,
    ),
  )
  set text(fill: self.colors.neutral-lightest, size: 1.5em)
  touying-slide(self: self, config: config, align(horizon + center, body))
})


/// The new section slide.
/// -> content
#let new-section-slide(
  ..args,
  body,
) = touying-slide-wrapper(self => {
  let body = {
    show outline.entry: it => {
      link(
        it.element.location(),
        it.indented(
          it.prefix(),
          "▶ " + it.body(),
        ),
      )
      v(1em)
    }
    v(2em)
    components.adaptive-columns(
      text(
        fill: white,
        size: 21pt,
        components.progressive-outline(
          title: none,
          indent: 1em,
          depth: 1,
          alpha: 20%,
          ..args,
        ),
      ),
    )
  }
  let self = utils.merge-dicts(
    self,
    config-page(
      header: _header-mi(self, is-outline: true),
      fill: self.colors.primary,
    ),
    config-common(
      freeze-slide-counter: true,
    ),
  )
  touying-slide(self: self, body)
})

/// Main presentation function.
/// -> content
#let unimi-presentation(
  /// Aspect ratio of the presentation.
  /// -> string
  aspect-ratio: "16-9",
  /// Language of the presentation.
  /// -> string
  language: "it",
  ..args,
  body,
) = {
  set text(size: 20pt, font: "Carlito", number-type: "old-style", lang: language)
  show heading.where(level: 1): set heading(numbering: "1")

  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      margin: (
        top: 4.5cm,
        bottom: 2.1cm,
        x: 1.935cm,
      ),
    ),
    config-common(
      slide-fn: unimi-slide,
      new-section-slide-fn: new-section-slide,
      datetime-format: "[month repr:long] [day], [year]",
    ),
    config-colors(
      primary: palette.maincolor,
    ),
    config-info(
      title: none,
      course: none,
      author: none,
      serial-number: none,
      date: datetime.today(),
      logo: _make-logo(),
    ),
    config-store(
      header: _header-mi,
      header-logo-light: image("img/presentation/logo_RGB.svg"),
      header-logo-dark: image("img/presentation/logo_RGB_negative.svg"),
      footer: _footer-mi,
    ),
    ..args,
  )

  body
}
