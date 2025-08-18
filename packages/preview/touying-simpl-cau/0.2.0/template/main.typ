#import "@preview/touying:0.6.1": *
#import "@preview/touying-simpl-cau:0.2.0": *

// Specify `lang` and `font` for the theme if needed.
#show: cau-theme.with(
  // lang: "zh",
  // font: ("Linux Libertine", "Source Han Sans SC", "Source Han Sans"),
  config-info(
    title: [Touying for CAU: Customize Your Slide Title Here],
    subtitle: [Customize Your Slide Subtitle Here],
    author: [Authors],
    date: datetime.today(),
    institution: [China Agricultural University],
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
