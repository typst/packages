#import "../theme/type.typ": 字体, 字号
#import "../config/constants.typ": page-margins, distance-to-the-edges

#let use-footer-preface(content) = {
  context {
    let footer-body = context [
        #align(center)[
          #set text(size: 字号.小五, font: 字体.宋体)
          #counter(page).display("- I -")
        ]
    ]

    let footer-body-size = measure(footer-body)
    let footer-ascent = page-margins.bottom - distance-to-the-edges.footer - footer-body-size.height

    set page(
      footer: footer-body,
      footer-descent: footer-ascent,
    )

    content
  }
}

#let use-footer-main(content) = {
  context {
    let footer-body = context [
      #align(center)[
        #set text(size: 字号.小五, font: 字体.宋体)
        #counter(page).display("- 1 -")
      ]
    ]

    let footer-body-size = measure(footer-body)
    let footer-ascent = page-margins.bottom - distance-to-the-edges.footer - footer-body-size.height

    set page(
      footer: footer-body,
      footer-descent: 11.5pt,
      // footer-descent: footer-ascent,
    )

    content
  }
}