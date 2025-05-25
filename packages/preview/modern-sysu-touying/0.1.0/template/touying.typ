#import "@preview/touying:0.6.1": *

// 建议在正式编辑幻灯片时，采用 typst.app 中的已发布版本模板
#import "@preview/modern-sysu-touying:0.0.1": *
// #import "lib.typ": *

// Specify `lang` and `font` for the theme if needed.
#show: sysu-theme.with(
  // lang: "zh",
  // font: (
  //   (
  //     name: "Linux Libertine",
  //     covers: "latin-in-cjk",
  //   ),
  //   "Source Han Sans SC",
  //   "Source Han Sans",
  // ),
  config-info(
    title: [Touying for SYSU: Customize Your Slide Title Here],
    subtitle: [Customize Your Slide Subtitle Here],
    author: [Authors],
    date: datetime.today(),
    institution: [Sun Yat-sen University],
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
