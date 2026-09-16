#import "../utils/style.typ": *

#let spine(anonymous: false, info: (:), ..args) = {
  if (not anonymous) {
    set page(footer: none)
    set align(center)
    set text(font: 字体.仿宋, size: 字号.四号, weight: "bold")
    block(height: 23.19cm, width: 1.18cm, stroke: black)[
      #v(102pt)
      #for c in info.title.cn [
        #c

      ]
      #v(1fr)
      #for c in info.author.cn [
        #c

      ]

      #v(1fr)
      同

      济

      大

      学
      #v(98pt)
    ]
  }
}