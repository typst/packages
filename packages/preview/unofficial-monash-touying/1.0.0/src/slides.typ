// Content slide and the special slides without a title bar.

#import "@preview/touying:0.8.0": config-common, config-page, touying-slide, touying-slide-wrapper, utils
#import "design.typ": *
#import "labels.typ": labels
#import "chrome.typ": plain-inline-code, title-bar-spacer
#import "logo.typ": corner-margin, with-corner-logo
#import "appendix.typ": appendix-marker

/// Content slide with the Monash title bar and footer.
///
/// Level-two headings create these slides automatically. Call it directly
/// for manual layouts, for example `#slide(composer: (1fr, 1fr))[A][B]`.
#let slide(
  /// Touying configuration for this slide.
  config: (:),
  /// Number of subslides; `auto` counts pauses.
  repeat: auto,
  /// Extra set and show rules for the body, as a function of the body.
  setting: body => body,
  /// Touying composer for several bodies, for example `(1fr, 1fr)`.
  composer: auto,
  /// Vertical and horizontal alignment of the body. Defaults to `top`.
  align: auto,
  /// Slide bodies.
  ..bodies,
) = touying-slide-wrapper(self => {
  if align != auto {
    self.store.align = align
  }
  let new-setting = body => {
    appendix-marker(self)
    title-bar-spacer(self)
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

// A heading that is laid out invisibly, so that a special slide's title is
// found by `utils.display-current-heading` (Touying's theme guide, step 3).
#let hidden-heading(self, title) = place(hide(heading(
  level: self.slide-level,
  title,
  bookmarked: false,
  outlined: false,
  numbering: none,
)))

/// One statement shown large on a full-bleed Monash blue slide, without
/// title bar or footer. It does not advance the slide counter.
///
/// ```typst
/// #focus-slide[Questions?]
/// ```
#let focus-slide(
  /// Touying configuration for this slide.
  config: (:),
  /// The statement.
  body,
) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(
      fill: monash-blue,
      header: none,
      footer: none,
      margin: (x: page-margin-x * 3, y: page-margin-x * 2),
    ),
    config,
  )
  let setting(body) = {
    appendix-marker(self)
    set text(fill: white, size: 1.6em, weight: "bold")
    set par(leading: .5em)
    show: plain-inline-code.with(self)
    show: std.align.with(center + horizon)
    body
  }
  touying-slide(self: self, setting: setting, body)
})

/// Closing slide with a large title and free content below it, such as
/// contact details and links. No title bar; it does not advance the slide
/// counter.
///
/// ```typst
/// #ending-slide[
///   Your Name \ your.name\@monash.edu
/// ]
/// ```
#let ending-slide(
  /// The large title.
  title: labels.thank-you,
  /// Touying configuration for this slide.
  config: (:),
  /// Closing content.
  body,
) = touying-slide-wrapper(self => {
  let size = self.store.font-size
  let logo = self.info.at("logo", default: none)
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(
      header: none,
      footer: none,
      margin: (
        left: if logo != none { corner-margin } else { page-margin-x * 2 },
        right: page-margin-x * 2,
        top: if logo != none { corner-margin } else { size * 1.6 },
        bottom: size * 2.6,
      ),
      background: place(bottom + left, block(width: 100%, {
        block(width: 100%, height: 3pt, fill: self.store.accent-color, below: 0pt)
        block(width: 100%, height: size * 1.1, fill: monash-blue)
      })),
    ),
    config,
  )
  let setting(body) = {
    appendix-marker(self)
    hidden-heading(self, title)
    show: std.align.with(horizon)
    with-corner-logo(self, logo, {
      block(below: size * .6, text(size: size * 2.2, fill: monash-blue, weight: "bold", title))
      block(below: size * 1.1, monash-accent-rule(width: 3.2em, height: 3pt, paint: self.store.accent-color))
      set text(fill: monash-charcoal)
      body
    })
  }
  touying-slide(self: self, setting: setting, body)
})
