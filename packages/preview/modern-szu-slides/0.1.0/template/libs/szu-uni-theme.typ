#import "@preview/touying:0.7.4": *
#import "@preview/cuti:0.4.0": *
#import themes.university: *
#import "szu-colors.typ": *

// 创建两个不同大小的logo定义
// 1. 用于标题幻灯片的8%宽度logo
#let szu-logo-title = image("../assets/szu-logo.svg", width: 8%)
// 2. 用于右上角的正常大小logo
#let szu-logo-red = image("../assets/szu-logo.svg")

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
  show: university-theme.with(
    // Lang and font configuration
    lang: lang,
    // Basic information
    config-info(
      title: title,
      subtitle: subtitle,
      author: author,
      date: date,
      institution: institution,
      logo: szu-logo-title,  // 在标题幻灯片中使用8%宽度的logo
    ),
    config-colors(
      primary: szu-first-red,
      secondary: szu-second-red,
      tertiary: szu-third-red,
      neutral-darkest: rgb("#000000"),
      neutral-darker: szu-primary-dark-red,
      neutral-dark: szu-primary-red,
      neutral-light: szu-second-red,
      neutral-lighter: szu-third-red,
      neutral-lightest: rgb("#ffffff"),
    ),
    header-right: self => szu-logo-red,
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