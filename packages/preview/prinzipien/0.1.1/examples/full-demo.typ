// A deck that showcases every configuration option of the theme, with
// deliberately non-default values throughout. See `demo.typ` for the
// plain deck that sticks to the defaults.

#import "../lib.typ": *

// The accent colour of this deck, shared between the theme configuration
// and the placeholder graphics below.
#let accent = rgb("#1a68f9")

// Placeholder wordmark standing in for a real logo image.
#let acme-logo = box({
  box(
    width: .8em,
    height: .8em,
    baseline: 12.5%,
    fill: accent,
    radius: .15em,
  )
  h(.35em)
  text(weight: "bold")[ACME]
})

#show: prinzipien-theme.with(
  // Every theme option, set explicitly:
  aspect-ratio: "16-9", // or "4-3"
  margin: 40%, // wider than the default 33%
  background: rgb("#fbfaf8"), // warm off-white instead of pure white
  foreground: rgb("#1c2733"), // dark blue-grey instead of near-black
  accent: accent, // blue instead of the default orange
  suppressed: rgb("#8a94a0"), // muted blue-grey for de-emphasis
  accent-tint: tint(accent, saturation: 25%), // paler than the auto tint
  // An explicit square logo instead of the auto-cropped full logo.
  logo-square: box(
    width: .8em,
    height: .8em,
    fill: accent,
    radius: .15em,
  ),
  // The presentation information, all fields filled in:
  config-info(
    title: [Every option of this theme is one line of configuration],
    subtitle: [A tour of the prinzipien theme options],
    author: [John Doe],
    institution: [ACME Corporation],
    date: datetime.today(),
    logo: acme-logo,
  ),
)

// Fields given to `title-slide` override the configured ones.
#title-slide(subtitle: [A tour of the theme options, overridden per slide])

== This deck sets every option away from its default

Compare it with `demo.typ`, which relies on the defaults only;
both build on Touying @touying.

#preview()

#point(substatement: [Margin width, colours, and logos are parameters])[
  The layout is configured in one place
]

== A 40% margin leaves a narrower content area

The `margin` option accepts a ratio of the slide width or a length.

== The explicit square logo replaces the auto-cropped one

`logo-square` overrides the square derived from `config-info`'s `logo`.

== The wider margin still holds labels for the content

#slide(margin-content: [
  #set text(size: .7em)
  The margin still holds labels, at 40% width.
])[
  #rect(
    width: 100%,
    height: 70%,
    fill: tint(accent, saturation: 15%),
    stroke: none,
    align(center + horizon, circle(radius: 3em, fill: tint(accent))),
  )
]

#point(substatement: [The tint is derived from it — or set explicitly])[
  One accent colour still rules the deck
]

== The accent tint behind emphasized words is configurable

The tint behind #alert[emphasized words] defaults to `tint(accent)`;
this deck sets a paler 25% tint explicitly.

== Suppressed content uses the configured muted colour

Overview maps and the page number pick it up automatically,
as documented by Doumont @doumont2009.

#review()

== Seven options cover the whole visual identity

Aspect ratio, margin, three colours, a tint, and a logo —
within the limits of what an audience retains @miller1956.

#show: appendix

== Backmatter works unchanged with any configuration

Appendix slides are numbered with roman numerals,
excluded from the slide total.

== References

#bibliography("full-demo.bib", title: none)
