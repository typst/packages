#import "@preview/touying:0.6.1": *
#import "@preview/cuti:0.3.0": *
#import themes.metropolis: *
#import "szu-colors.typ": *

#let szu-logo-title = image("../assets/szu-logo.svg")
#let szu-logo-gold = image("../assets/szu-logo-gold.svg")

#let szu-theme(
  aspect-ratio: "16-9",
  lang: "zh",
  font: (:),
  title: [Shenzhen University Slides based on Touying and Typst],
  subtitle: [基于 Touying 的深圳大学 Typst 幻灯片模板],
  author: [深小荔],
  date: datetime.today(),
  institution: [深圳大学],
  ..args,
  body,
) = {
  show: metropolis-theme.with(
    // Lang and font configuration
    lang: lang,
    // Basic information
    config-info(
      title: title,
      subtitle: subtitle,
      author: author,
      date: date,
      institution: institution,
      logo: szu-logo-title,  // 在标题幻灯片中使用的logo
    ),
    config-colors(
      primary: szu-primary-red,
      primary-dark: szu-primary-dark-red,
      secondary: szu-first-red,
      secondary-light: szu-second-red,
      secondary-lighter: szu-third-red,
      neutral-darkest: rgb("#000000"),
      neutral-darker: szu-primary-dark-red,
      neutral-dark: szu-primary-red,
      neutral-light: szu-second-red,
      neutral-lighter: szu-third-red,
      neutral-lightest: rgb("#ffffff"),
    ),
    // 在右上角添加 logo
    header-right: self => image("../assets/szu-logo-white.svg", width: 1.4em, height: 1.4em),
  )

  set heading(numbering: "1.1.1.1")

  // 设置 bibliography 的字体大小为 10pt（比默认字体小一些）
  show bibliography: it => {
    set text(size: 10pt)
    it
  }

  if lang == "zh" {
    show: show-cn-fakebold
  }

  body
}