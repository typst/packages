#import "@preview/touying:0.4.2": *
#import "@preview/touying-buaa:0.1.0" as buaa-theme

#let s = buaa-theme.register()

// Global information configuration
#let s = (s.methods.info)(
  self: s,
  title: [Touying for BUAA: Customize Your Slide Title Here],
  subtitle: [Customize Your Slide Subtitle Here],
  author: [Authors],
  date: datetime.today(),
  institution: [Beihang University],
)

// Extract methods
#let (init, slides) = utils.methods(s)
#show: init

// Extract slide functions
#let (slide, empty-slide, title-slide, outline-slide, new-section-slide, ending-slide) = utils.slides(s)
#show: slides.with()

#outline-slide()

= The section I

== Slide I / i

Slide content.

== Slide I / ii

Slide content.

= The section II

== Slide II / i

Slide content.

== Slide II / ii

Slide content.
