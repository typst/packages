#import "@preview/touying:0.7.3": *
#import "@preview/zebraw:0.6.1": zebraw
#import "design.typ": *

#let monash-blue-light = monash-blue-wash

#let _display-logo(self, fallback: [Monash University], height: 1em) = {
  if self.info.logo != none {
    box(height: height, self.info.logo)
  } else {
    text(size: height, fill: monash-blue, weight: "bold", fallback)
  }
}

#let _title-color(color) = {
  if color == "white" {
    white
  } else if color == "black" {
    black
  } else {
    color
  }
}

#let _titlegraphic(graphic) = {
  if type(graphic) == str {
    image(graphic, width: 100%, height: 100%, fit: "cover")
  } else {
    box(width: 100%, height: 100%, graphic)
  }
}

#let _title-bar(label) = {
  place(
    top + left,
    dx: -monash-page-margin-x,
    dy: -monash-page-margin-top,
    rect(
      width: 100% + 2 * monash-page-margin-x,
      height: monash-title-bar-height,
      fill: monash-blue,
      inset: (x: monash-page-margin-x - .2cm, y: .45cm),
    )[
      #set text(fill: white, size: monash-title-bar-font-size, weight: "bold")
      #label
    ],
  )
  v(monash-title-bar-height - monash-page-margin-top + .75cm)
}

#let _monash-footer(self) = {
  set align(bottom)
  block(width: 100%, height: monash-footer-height)[
    #place(bottom + left, dx: -monash-page-margin-x)[
      #rect(width: 100% + 2 * monash-page-margin-x, height: 2pt, fill: monash-grey-soft)
    ]
    #place(bottom + left, dx: -monash-page-margin-x)[
      #box(width: 100% + 2 * monash-page-margin-x)[
        #components.progress-bar(height: 2pt, monash-orange, monash-grey-soft)
      ]
    ]
    #place(bottom + right)[
      #move(dx: -.15cm, dy: -.16cm)[
        #context text(
          fill: monash-grey,
          size: monash-footer-size,
          utils.slide-counter.display(),
        )
      ]
    ]
  ]
}

/// Monash-inspired Touying content slide.
///
/// This is installed as the default slide function by `monash-theme`. Use it
/// directly only when a deck needs manual Touying slide control.
#let slide(
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  align: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  if align != auto {
    self.store.align = align
  }

  let new-setting = body => {
    _title-bar(utils.display-current-heading(depth: self.slide-level))
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

#let _cover-meta-block(self, info, title-color, fontsize) = {
  let institution = if info.institution != none { info.institution } else { none }
  let date = if info.date != none { utils.display-info-date(self) } else { none }

  block(width: 100%)[
    #if info.author != none {
      text(fill: title-color, size: fontsize * 1.05, weight: "regular", info.author)
    }
    #if institution != none or date != none {
      if info.author != none { v(.18cm) }
      text(size: fontsize * .82, fill: monash-dark-grey)[
        #if institution != none { institution }
        #if institution != none and date != none {
          text(fill: monash-grey)[ | ]
        }
        #if date != none { date }
      ]
    }
  ]
}

/// Creates the title slide for a Monash-inspired Touying deck.
///
/// The slide uses the configured `titlegraphic`, title metadata, author,
/// institution, and date. Extra content can be placed below the metadata.
#let title-slide(config: (:), extra: none, ..args) = touying-slide-wrapper(self => {
  let info = self.info + args.named()
  let title-color = _title-color(self.store.titlecolor)
  let titlefontsize = self.store.titlefontsize
  let fontsize = self.store.fontsize

  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(margin: 0em, header: none, footer: none),
    config,
  )

  touying-slide(self: self, {
    place(top + left)[
      #_titlegraphic(self.store.titlegraphic)
    ]
    place(top + left, dx: 1.0cm, dy: 4.8cm)[
      #block(width: 65%)[
        #set text(fill: title-color, size: titlefontsize, weight: "bold")
        #set par(leading: .8em)
        #info.title
        #if info.subtitle != none {
          linebreak()
          text(size: titlefontsize * .65, weight: "regular")[#info.subtitle]
        }
      ]
    ]
    place(top + left, dx: 1.0cm, dy: 11.05cm)[
      #block(width: 60%)[
        #_cover-meta-block(self, info, title-color, fontsize)
        #if extra != none {
          v(.2cm)
          text(size: fontsize * .75, fill: monash-dark-grey, extra)
        }
      ]
    ]
  })
})

#let _section-number-box() = {
  context {
    let value = counter(heading).get().first() + 1
    box(
      fill: monash-orange,
      inset: (x: 8pt, y: 5pt),
      baseline: 20%,
      text(fill: white, weight: "bold", str(value)),
    )
  }
}

#let _monash-new-section(
  config: (:),
  level: 1,
  numbered: true,
  body,
) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(footer: none),
    config,
  )

  let section-title = utils.display-current-heading(level: level, numbered: false)
  touying-slide(self: self, {
    _title-bar(section-title)
    v(.5cm)
    block(inset: (left: 1cm), [
      #text(size: self.store.fontsize * 1.1)[
        #_section-number-box()
        #h(.4em)
        #text(fill: monash-orange, weight: "regular", section-title)
      ]
    ])
  })
})

#let _monash-heading-three(it) = {
  v(1em, weak: true)
  text(weight: "bold", fill: monash-blue, it.body)
  v(.7em, weak: true)
}

/// Applies the Monash-inspired slide theme to a Touying deck.
///
/// Use this as the main document show rule. It keeps Touying as the authoring
/// model while applying Monash title bars, footer progress, text styles,
/// inline code styling, and light `zebraw` code blocks.
///
/// ```typst
/// #show: monash-theme.with(
///   config-info(title: [Presentation Title]),
/// )
/// ```
#let monash-theme(
  /// Touying aspect ratio. Defaults to widescreen slides.
  aspect-ratio: "16-9",
  /// Optional logo content shown by the theme.
  logo: none,
  /// Title-slide background image path or content.
  titlegraphic: "../template/assets/monash-presentation/background/bg-02.png",
  /// Title text colour. Accepts `black`, `white`, or a colour value.
  titlecolor: black,
  /// Main title font size.
  titlefontsize: monash-title-font-size,
  /// Base slide font size.
  fontsize: monash-body-size,
  /// Reserved brand motif switch for compatibility with the template surface.
  brand-motif: false,
  /// Optional motto value stored for future theme extensions.
  motto: none,
  /// Progress indicator location. The current theme uses the footer.
  progress-position: "footer",
  /// Whether to show the footer progress bar.
  progress-bar: true,
  ..args,
  /// Document body transformed by the theme.
  body,
) = {
  show: touying-slides.with(
    config-page(
      ..utils.page-args-from-aspect-ratio(aspect-ratio),
      margin: (x: monash-page-margin-x, top: monash-page-margin-top, bottom: monash-page-margin-bottom),
      footer: _monash-footer,
      footer-descent: 0%,
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: _monash-new-section,
      slide-level: 2,
      show-strong-with-alert: false,
      zero-margin-footer: true,
    ),
    config-methods(
      init: (self: none, body) => {
        set text(font: "Arial", size: fontsize, fill: black)
        set par(justify: false, leading: .65em)
        set figure(placement: none)
        set list(
          marker: (
            box(width: .55em, height: .55em, baseline: -.05em, fill: monash-orange),
            text(fill: monash-orange.lighten(20%), size: .75em)[#sym.triangle.filled.r],
            text(fill: monash-orange.lighten(20%), size: .75em)[#sym.star.filled],
          ),
          indent: 1.2em,
          body-indent: .6em,
        )
        set enum(
          full: true,
          numbering: (..nums) => box(
            fill: monash-orange,
            inset: (x: 4pt, y: 2pt),
            text(fill: white, size: .72em, weight: "bold", nums.pos().last()),
          ),
          indent: 1.2em,
          body-indent: .8em,
        )
        show heading.where(level: 3): _monash-heading-three
        show heading.where(level: 4): set text(fill: monash-blue, weight: "bold")
        show strong: it => text(fill: monash-orange, weight: "bold", it.body)
        show raw.where(block: false): it => box(
          fill: monash-blue-wash,
          stroke: (paint: monash-grey-soft, thickness: .45pt),
          radius: 1.5pt,
          inset: (x: .18em, y: .04em),
          baseline: .08em,
          text(
            font: ("Source Code Pro", "DejaVu Sans Mono"),
            size: .68em,
            fill: monash-blue-dark,
            weight: "medium",
            it,
          ),
        )
        show raw.where(block: true): set text(
          font: ("Source Code Pro", "DejaVu Sans Mono"),
          size: .72em,
          fill: monash-charcoal,
        )
        show: zebraw.with(
          background-color: monash-grey-light,
          highlight-color: monash-blue-wash,
          lang: false,
          radius: 2pt,
          inset: (x: monash-space-md, y: monash-space-sm),
          numbering: false,
        )
        body
      },
      alert: utils.alert-with-primary-color,
    ),
    config-colors(
      primary: monash-blue,
      secondary: monash-orange,
      tertiary: monash-grey,
      neutral-lightest: monash-paper,
      neutral-darkest: monash-charcoal,
    ),
    config-store(
      align: top,
      brand-motif: brand-motif,
      motto: motto,
      progress-bar: progress-bar,
      progress-position: progress-position,
      titlegraphic: titlegraphic,
      titlecolor: titlecolor,
      titlefontsize: titlefontsize,
      fontsize: fontsize,
    ),
    config-info(logo: logo),
    ..args,
  )

  body
}
