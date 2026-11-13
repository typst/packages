// Title slide: one column of metadata beside the title graphic, or a plain
// cover drawn with Typst shapes when `title-graphic: none`.

#import "@preview/touying:0.8.0": config-common, config-page, touying-slide, touying-slide-wrapper, utils
#import "design.typ": *
#import "chrome.typ": author-text
#import "logo.typ": corner-margin, with-corner-logo
#import "navigation.typ": outline-slide-fn

#let _bundled-graphic = image(
  "../template/assets/monash-presentation/background/bg-02.png",
  width: 100%,
  height: 100%,
  fit: "cover",
)

// Right edge of the text column as a fraction of the page width. The bundled
// graphic's blue band starts at 70% of the width in 16:9 and, cropped by
// `fit: "cover"`, at 77% in 4:3.
#let _column-end(self) = {
  if self.store.title-graphic == none { none } else if (
    self.store.aspect-ratio == "4-3"
  ) { 71% } else { 64% }
}

#let _rule(self) = monash-accent-rule(
  width: 3.2em,
  height: 3pt,
  paint: self.store.accent-color,
)

// Institution and date: "institution | date" on one line when it fits,
// otherwise the date on its own line without the separator, so a line
// never ends with a dangling "|".
#let _meta-line(self, info) = {
  let parts = ()
  if info.institution != none { parts.push(info.institution) }
  if info.date != none { parts.push(utils.display-info-date(self)) }
  if parts.len() == 0 { return }
  let style = text.with(size: self.store.font-size * .8, fill: monash-dark-grey)
  let joined = style(parts.join(text(fill: monash-grey)[#h(.4em)|#h(.4em)]))
  if parts.len() == 1 { return joined }
  layout(region => {
    if measure(joined).width <= region.width { joined } else {
      style(parts.join(linebreak()))
    }
  })
}

// The text column: logo, title, subtitle, rule, author, institution and
// date, and `extra`, in reading order with flow spacing only.
#let _column(self, info, extra) = {
  let size = self.store.font-size
  let color = self.store.title-color
  set par(justify: false)
  set block(spacing: 0pt)
  block(below: size * .75, {
    set par(leading: .3em)
    text(fill: color, size: self.store.title-font-size, weight: "bold", info.title)
  })
  if info.subtitle != none {
    block(below: size * .55, {
      set par(leading: .4em)
      text(fill: color, size: self.store.title-font-size * .62, info.subtitle)
    })
  }
  block(above: size * .5, below: size * 1.1, _rule(self))
  if info.author != none {
    block(below: size * .5, {
      set par(leading: .45em)
      text(fill: color, size: size * 1.05, author-text(info.author))
    })
  }
  block(below: size * .5, {
    set par(leading: .45em)
    _meta-line(self, info)
  })
  if extra != none {
    block(above: size * .3, text(size: size * .75, fill: monash-dark-grey, extra))
  }
}

// Places the column, ending at `column-end` of the page width (or using the
// full width for `none`), and scales it down if it is taller than the
// available height so that it never leaves the page.
#let _fitted-column(column-end, body) = layout(region => {
  let width = if column-end == none { region.width } else {
    column-end * page.width - (page.width - region.width)
  }
  let natural = measure(block(width: width, body)).height
  if natural <= region.height {
    block(width: width, body)
  } else {
    let ratio = region.height / natural
    scale(
      ratio * 100%,
      origin: left + horizon,
      reflow: true,
      block(width: width / ratio, body),
    )
  }
})

// Decoration of the plain cover, drawn with shapes only: a blue band along
// the left edge and the bottom with an accent stripe, and diagonal bars in
// the top corner.
#let _plain-decoration(self) = {
  let size = self.store.font-size
  place(top + left, rect(width: size * .45, height: 100%, fill: monash-blue))
  place(bottom + left, block(width: 100%, {
    block(width: 100%, height: 3pt, fill: self.store.accent-color, below: 0pt)
    block(width: 100%, height: size * 1.1, fill: monash-blue)
  }))
  let bar(dx, fill) = place(top + right, dx: dx, polygon(
    fill: fill,
    (0pt, 0pt),
    (size * 1.6, 0pt),
    (size * .2, size * 3.6),
    (-size * 1.4, size * 3.6),
  ))
  bar(-size * 4.6, monash-blue-wash)
  bar(-size * 2.8, monash-blue.transparentize(60%))
  bar(-size * 1.0, monash-blue)
}

#let _graphic(self) = {
  let graphic = self.store.title-graphic
  if graphic == auto {
    place(top + left, _bundled-graphic)
  } else if graphic == none {
    _plain-decoration(self)
  } else {
    place(top + left, box(width: 100%, height: 100%, graphic))
  }
}

#let _cover-page(self, logo) = {
  let size = self.store.font-size
  let plain = self.store.title-graphic == none
  let top = if logo != none { corner-margin } else if plain { size * 3.8 } else {
    size * 1.4
  }
  config-page(
    header: none,
    footer: none,
    margin: (
      left: page-margin-x * 1.5,
      right: if plain { page-margin-x * 1.5 } else { 0pt },
      top: top,
      bottom: size * if plain { 2.4 } else { 1.4 },
    ),
    background: _graphic(self),
  )
}

/// Creates the title slide from `config-info` (title, subtitle, author,
/// institution, date). Everything is laid out in one column, which shrinks
/// rather than overflowing for very long metadata. A logo sits in the
/// top-left corner with the column below it. With
/// `outline: true` (the default) an outline slide follows.
///
/// ```typst
/// #title-slide(extra: [Seminar series])
/// ```
#let title-slide(
  /// Touying configuration for this slide.
  config: (:),
  /// Extra content below the metadata.
  extra: none,
  /// `config-info` fields that override the theme's for this slide.
  ..args,
) = touying-slide-wrapper(self => {
  let info = self.info + args.named()
  let cover-self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    _cover-page(self, info.logo),
    config,
  )
  let column = _fitted-column(_column-end(self), _column(cover-self, info, extra))
  let body = with-corner-logo(cover-self, info.logo, column)
  touying-slide(self: cover-self, setting: std.align.with(horizon), body)
  if self.store.outline {
    outline-slide-fn(self)
  }
})
