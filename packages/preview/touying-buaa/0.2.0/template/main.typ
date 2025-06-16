#import "@preview/touying:0.5.2": *
#import "@preview/touying-buaa:0.2.0": *

// Specify `lang` and `font` for the theme if needed.
#show: buaa-theme.with(
  // lang: "zh",
  // font: ("Linux Libertine", "Source Han Sans SC", "Source Han Sans"),
  config-info(
    title: [Touying for BUAA: Customize Your Slide Title Here],
    subtitle: [Customize Your Slide Subtitle Here],
    author: [Authors],
    date: datetime.today(),
    institution: [Beihang University],
  ),
)

#title-slide()

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
