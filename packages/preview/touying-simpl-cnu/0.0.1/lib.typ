/**
 *  Stargazer theme - adapted for CNU
 * */

#import "@preview/touying:0.7.4": *
#import "@preview/numbly:0.1.0": numbly
#import themes.stargazer: *

/// 模板的核心类，规范了文档的格式。
/// 
/// - aspect-ratio (str): 纵横比 
/// - lang (str):  语言
/// - font (array): 字体覆盖列表
/// - use-background (bool): 是否使用背景图 
/// -> 
#let cnu-theme(
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
    config-info(logo: image("assets/CNU.svg")),
    config-colors(
      // 标准色 · 首都师大蓝（深蓝）C90 M70 Y10 K10 / Pantone 293C
      primary: rgb("#1d4887"),
      // 深蓝加深 25%，用于 tblock 标题栏
      primary-dark: rgb("#163665"),
      // 辅助色 · 金色 Pantone 875C，用于点缀与强调
      secondary: rgb("#b08d4f"),
      // 标准色 · 首都师大蓝（浅蓝）C100 M30 Y0 K0 / Pantone 3005C，用于结尾页
      tertiary: rgb("#0077c8"),
      neutral-lightest: rgb("#ffffff"),
      neutral-darkest: rgb("#000000"),
    ),
    config-page(
      background: if use-background {
        place(
          center + horizon,
          dx: 40%,
          dy: 7%,
          image("assets/emblem.svg", width: 60%),
        )
      } else {
        none
      },
    ),
    ..args,
  )

  body
}
