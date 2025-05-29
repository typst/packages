#import "/package/lib.typ": hydra

//  -------------------- 页眉和页脚 --------------------
// 定义页眉样式
#let header-style(doc, title: "", size: 10.5pt) = {
  set text(size: size)
  set page(
    header: context {
      let left = title
      let right = hydra(1, skip-starting: false)
      if calc.odd(here().page()) {
        (left, right) = (right, left)
      }
      stack(
        dir: ttb,
        left + h(1fr) + right,
        v(.5em),
        line(length: 100%, stroke: .5pt),
        v(.15em),
        line(length: 100%, stroke: .5pt),
      )
    },
  )
  doc
}

// 定义页脚样式
#let footer-style(doc, size: 10.5pt, footer-num: "1") = {
  counter(page).update(1)
  set page(
    numbering: footer-num,
    footer: context {
      set text(size: size)
      if calc.odd(counter(page).get().first()) { h(1fr) }
      counter(page).display(footer-num)
    },
  )
  doc
}
