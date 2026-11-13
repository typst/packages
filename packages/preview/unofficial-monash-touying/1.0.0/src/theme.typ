// The `monash-theme` show rule: validates options and configures Touying.

#import "@preview/touying:0.8.0": config-colors, default-config, config-common, config-info, config-methods, config-page, config-store, touying-slides, utils
#import "design.typ": *
#import "options.typ": check-footer, check-options, check-unknown-options, logo-places
#import "chrome.typ": content-margin-bottom, content-margin-top, footer as page-footer, notes, title-bar
#import "styles.typ": slide-rules
#import "slides.typ": slide
#import "navigation.typ": new-section-slide
#import "frames.typ": frame-counters

#let _font-rules(font, code-font, font-size, body) = {
  set text(size: font-size, fill: black)
  set text(font: font) if font != auto
  show raw: set text(font: code-font)
  body
}

/// Applies the Monash-inspired slide theme to a Touying deck.
///
/// Use this as the main document show rule. Every named parameter below is a
/// theme option; Touying settings are passed as positional `config-*(..)`
/// arguments.
///
/// ```typst
/// #show: monash-theme.with(
///   font: "Arial",
///   config-info(title: [Presentation Title]),
/// )
/// ```
#let monash-theme(
  /// Slide format: `"16-9"` or `"4-3"`.
  aspect-ratio: "16-9",
  /// Text font. `auto` keeps Typst's default font (or the one you set before
  /// the theme). `"Arial"` gives the Monash look where it is installed.
  font: auto,
  /// Font for code, as a family name or an array of names.
  code-font: "DejaVu Sans Mono",
  /// Body text size.
  font-size: 22pt,
  /// Title size on the title slide.
  title-font-size: 36pt,
  /// Colour of the title-slide text.
  title-color: black,
  /// Title-slide graphic: `auto` for the bundled background, `none` for the
  /// plain cover, or content such as `image(..)`.
  title-graphic: auto,
  /// Accent colour for list markers, strong text, progress, and numbers.
  accent-color: monash-orange,
  /// Logo. Content goes in the top-left corner of the title and ending
  /// slides and on a white panel at the right of the title bar. A
  /// dictionary `(cover: .., bar: .., bar-fill: white)` sets each place;
  /// `bar-fill: none` draws a white logo directly on the blue bar.
  logo: none,
  /// Whether `#title-slide()` is followed by an outline slide.
  outline: true,
  /// Whether level-one headings create section divider slides.
  section-slides: true,
  /// Whether the footer shows the progress bar.
  progress-bar: true,
  /// Slide number pattern, or `none` to hide it. A pattern with two counting
  /// symbols such as `"1 / 1"` receives the current slide and the total.
  slide-numbering: "1",
  /// Footer text on the left: `none`, `auto` (short title and author), or
  /// content.
  footer: none,
  /// Touying `config-*(..)` values, then the document body.
  ..args,
  /// Document body transformed by the theme.
  body,
) = {
  check-unknown-options(args.named())
  check-options(
    aspect-ratio: aspect-ratio,
    font: font,
    code-font: code-font,
    font-size: font-size,
    title-font-size: title-font-size,
    title-color: title-color,
    title-graphic: title-graphic,
    accent-color: accent-color,
    logo: logo,
    outline: outline,
    section-slides: section-slides,
    progress-bar: progress-bar,
    slide-numbering: slide-numbering,
  )
  check-footer(footer)

  show: _font-rules.with(font, code-font, font-size)

  let store = (
    align: top,
    aspect-ratio: aspect-ratio,
    font-size: font-size,
    code-font: code-font,
    title-font-size: title-font-size,
    title-color: title-color,
    title-graphic: title-graphic,
    accent-color: accent-color,
    outline: outline,
    progress-bar: progress-bar,
    slide-numbering: slide-numbering,
    footer: footer,
    logo-bar: logo-places(logo).bar,
    logo-bar-fill: logo-places(logo).bar-fill,
  )
  let margin-self = (store: store)

  show: touying-slides.with(
    config-page(
      ..utils.page-args-from-aspect-ratio(aspect-ratio),
      margin: (
        x: page-margin-x,
        top: content-margin-top(margin-self),
        bottom: content-margin-bottom(margin-self),
      ),
      header: title-bar,
      header-ascent: 0%,
      footer: page-footer,
      footer-descent: 0%,
    ),
    config-common(
      slide-fn: slide,
      notes-fn: notes,
      new-section-slide-fn: if section-slides { new-section-slide } else { none },
      slide-level: 2,
      show-strong-with-alert: false,
      default-frozen-counters: default-config.default-frozen-counters + frame-counters,
    ),
    config-methods(
      init: slide-rules.with(accent-color),
      alert: utils.alert-with-primary-color,
    ),
    config-colors(
      primary: monash-blue,
      secondary: accent-color,
      tertiary: monash-grey,
      neutral-lightest: monash-paper,
      neutral-darkest: monash-charcoal,
    ),
    config-store(..store),
    config-info(logo: logo-places(logo).cover),
    ..args,
  )

  body
}
