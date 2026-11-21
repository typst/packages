// Logo placement: a large logo in the top-left corner of the title and
// ending slides, and a small one at the right end of the title bar,
// normally on a white panel so that an ordinary dark logo stays readable.

#import "design.typ": *

/// Scales `logo` up or down to the largest size that fits in a box
/// `max-height` by `max-width`, so a wide wordmark is limited by width and a
/// square crest by height, whatever the image's own size. Needs no context.
#let fitted-logo(logo, max-height, max-width) = context {
  let size = measure(logo)
  if size.height == 0pt or size.width == 0pt { return logo }
  let ratio = calc.min(max-height / size.height, max-width / size.width)
  scale(ratio * 100%, reflow: true, logo)
}

// Box for the corner logo: 19% of the page height, and 30% (16:9) or 37%
// (4:3) of the page width, which keeps it clear of the title graphic.
#let _corner-logo(self, logo) = context fitted-logo(
  logo,
  page.height * .19,
  page.width * if self.store.aspect-ratio == "4-3" { .37 } else { .30 },
)

/// Puts `logo` at the top of the slide and `body` vertically centred in the
/// space below it, so the two never overlap. Without a logo, `body` is
/// returned unchanged.
#let with-corner-logo(self, logo, body) = if logo == none { body } else {
  block(width: 100%, height: 100%, grid(
    columns: (1fr,),
    rows: (auto, 1fr),
    row-gutter: self.store.font-size * 1.2,
    _corner-logo(self, logo),
    align(horizon, body),
  ))
}

/// Top margin of the title and ending slides when they carry a logo: the
/// same as the left margin, so the logo sits in the corner.
#let corner-margin = page-margin-x * 1.5

// The bar logo: as tall as a one-line bar allows, at most 22% of the page
// width. Needs context.
#let _bar-logo(self, logo, bar-height) = fitted-logo(
  logo,
  bar-height - self.store.font-size * .7,
  page.width * .22,
)

/// Width taken from the title bar by the logo and its panel, from the page's
/// right edge. Needs context.
#let bar-logo-width(self, bar-height) = {
  let logo = self.store.logo-bar
  if logo == none { return 0pt }
  let width = measure(_bar-logo(self, logo, bar-height)).width
  let panel = self.store.logo-bar-fill != none
  let pad = self.store.font-size * .5
  let slant = if panel { bar-height * .38 } else { 0pt }
  width + page-margin-x + if panel { pad + slant } else { 0pt }
}

/// The logo at the right end of a title bar of height `height`, on a panel
/// whose left edge leans like the stripes of the plain cover. The logo ends
/// at the page's right margin. Needs context.
#let bar-logo(self, height, min-height) = {
  let logo = self.store.logo-bar
  if logo == none { return }
  let fill = self.store.logo-bar-fill
  if fill != none {
    let width = bar-logo-width(self, min-height)
    let slant = min-height * .38
    place(top + right, polygon(
      fill: fill,
      (0pt, height),
      (slant, 0pt),
      (width, 0pt),
      (width, height),
    ))
  }
  place(right + horizon, dx: -page-margin-x, _bar-logo(self, logo, min-height))
}
