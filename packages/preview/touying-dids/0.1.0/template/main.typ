#import "@preview/touying:0.5.3": *
#import "@preview/touying-dids:0.1.0": *

// Specify `lang` and `font` for the theme if needed.
#show: dids-theme.with(

  config-info(
    title: [Touying for DIDS: Customize Your Slide Title Here],
    subtitle: [Customize Your Slide Subtitle Here],
    author: [Authors],
    date: datetime.today(),
    institution: [NUDT DIDS],
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
