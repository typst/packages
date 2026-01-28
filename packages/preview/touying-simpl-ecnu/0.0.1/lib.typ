/**
 *  Stargazer theme - adapted for ECNU
 * */

#import "@preview/touying:0.6.1": *
#import "@preview/numbly:0.1.0": numbly
#import themes.stargazer: *

/// 模板的核心类，规范了文档的格式。
/// 
/// - aspect-ratio (str): 纵横比 
/// - lang (str):  语言
/// - font (array): 字体覆盖列表
/// - use-background (bool): 是否使用背景图 
/// -> 
#let ecnu-theme(
  aspect-ratio: "16-9",
  lang: "en",
  font: (
    (
      name: "Libertinus Serif",
      covers: "latin-in-cjk",
    ),
    "Source Han Sans SC", "Source Han Sans",
  ),
  use-background: true,
  ..args,
  body,
) = {
  set text(lang: lang, font: font)
  set heading(numbering: numbly("{1}.", default: "1.1"))

  show: stargazer-theme.with(
    aspect-ratio: aspect-ratio,
   header-right: grid(
      columns: 2,
      image("assets/ecnu_logo.png"),
      image("assets/ecnu_title.png")
    ),
    config-colors(
      primary: rgb("#b60b2d"),
      primary-dark: rgb("#5a0718"),
      secondary: rgb("#fdd100"),
      tertiary: rgb("#004f71"),
      neutral-lightest: rgb("#ffffff"),
      neutral-darkest: rgb("#5a0718"),
    ),
    config-page(
      background: if use-background {
        place(
          center + horizon,
          dx: 13%,
          image("assets/ecnu_background.png", width: 75%),
        )
      } else {
        none
      },
      ),
    ..args,
  )

  body
}