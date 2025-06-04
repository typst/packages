/**
 *  Stargazer theme - adapted for CAU
 * */

#import "@preview/touying:0.6.1": *
#import "@preview/numbly:0.1.0": numbly
#import themes.stargazer: *

/// 模板的核心类，规范了文档的格式。
/// 
/// - aspect-ratio (str): 纵横比 
/// - lang (str):  语言
/// - font (list): 字体覆盖列表
/// - use-background (bool): 是否使用背景图 
/// -> 
#let cau-theme(
  aspect-ratio: "16-9",
  lang: "en",
  font: ("Libertinus Serif", "Source Han Sans SC", "Noto Sans CJK SC", "SimHei", "Heiti SC", "STHeiti"),
  use-background: true,
  ..args,
  body,
) = {
  set text(lang: lang, font: font)
  set heading(numbering: numbly("{1}.", default: "1.1"))

  show: stargazer-theme.with(
    aspect-ratio: aspect-ratio,
    config-info(logo: image("assets/CAU_logo.svg")),
    config-colors(
      primary: rgb("#4d7c2b"),
      primary-dark: rgb("#3d5c27"),
      secondary: rgb("#fdd100"),
      tertiary: rgb("#006600"),
      neutral-lightest: rgb("#ffffff"),
      neutral-darkest: rgb("#000000"),
    ),
    config-page(
      background: if use-background {
        place(
          center + horizon,
          dx: 47%,
          dy: 7%,
          image("assets/Gate.svg", width: 75%),
        )
      } else {
        none
      },
    ),
    ..args,
  )

  body
}
