#import "@preview/touying:0.7.4": *
#import "@preview/cuti:0.4.0": *
#import themes.metropolis: *
#import "szu-colors.typ": *

#let szu-theme(
  aspect-ratio: "16-9",
  lang: "zh",
  font: (:),
  title: [Shenzhen University Slides based on Touying and Typst],
  subtitle: [基于 Touying 的深圳大学 Typst 幻灯片模板],
  author: [深小荔],
  date: datetime.today(),
  institution: [深圳大学],
  logo: none,
  header-right: none,
  ..args,
  body,
) = {
  if lang == "zh" {
    show: show-cn-fakebold
  }

  show: metropolis-theme.with(
    aspect-ratio: aspect-ratio,
    lang: lang,
    config-info(
      title: title,
      subtitle: subtitle,
      author: author,
      date: date,
      institution: institution,
      logo: logo,
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
    header-right: if header-right != none { header-right } else { self => none },
    ..args,
  )

  set heading(numbering: "1.1.1.1")

  // 设置 bibliography 的字体大小为 10pt（比默认字体小一些）
  show bibliography: it => {
    set text(size: 10pt)
    it
  }

  body
}