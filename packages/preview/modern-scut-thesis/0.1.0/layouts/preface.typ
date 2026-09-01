// SCUT 前言：罗马数字页码
#import "../utils/section-break.typ": section-break
#import "../utils/style.typ": 字体, 辅助字体, 辅助字号

#let preface(
  fonts: (:),
  ..args,
  it,
) = {
  fonts = 字体 + fonts

  section-break(open-right: false)
  counter(page).update(1)
  set page(
    numbering: "I",
    footer: context {
      set text(font: 辅助字体, size: 辅助字号)
      align(center, stack(
        counter(page).display("I"),
        v(15mm),
      ))
    },
  )
  it
}
