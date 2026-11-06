#import "../utils/style.typ": 字体, 字号

// ============================================
// 页眉统一配置
// ============================================

// 页眉上升距离（页面顶部到页眉内容的距离）
#let header-ascent = 1.2cm - 1.5em

// 页眉内部间距配置
#let header-inner-spacing = 0.5em  // 内容与上线的距离
#let header-line-gap = 0.3em       // 两根线之间的距离

// 页眉线条粗细
#let header-line-thick = 2.7pt       // 上线粗细
#let header-line-thin = 0.5pt      // 下线粗细

// 页眉配置（用于 set page）
#let graduate-header-config = (
  header-ascent: header-ascent,
)

// 页眉渲染函数
#let header-render(content, fonts: (:)) = {
  fonts = 字体 + fonts
  [
    #set par(leading: 0em, spacing: 0em)
    #set text(font: fonts.宋体, size: 字号.小五)
    #align(center)[#content]
    #v(header-inner-spacing)
    #line(length: 100%, stroke: header-line-thick + black)
    #v(header-line-gap)
    #line(length: 100%, stroke: header-line-thin + black)
  ]
}

#let graduate-header-title(doctype) = {
  if doctype == "doctor" {
    "西北工业大学博士学位论文"
  } else {
    "西北工业大学硕士学位论文"
  }
}

#let add-blank-even-page(doctype: "master", fonts: (:), terminal: false) = {
  fonts = 字体 + fonts
  context {
    let current-page = counter(page).get().first()
    if calc.rem(current-page, 2) == 1 {
      pagebreak(weak: not terminal)
      set page(header: header-render([#graduate-header-title(doctype)], fonts: fonts))
      v(1fr)
    }
  }
}

#let break-to-odd-page(doctype: "master", fonts: (:)) = {
  fonts = 字体 + fonts
  context {
    let current-page = counter(page).get().first()
    if calc.rem(current-page, 2) == 1 {
      pagebreak()
      set page(header: header-render([#graduate-header-title(doctype)], fonts: fonts))
      v(1fr)
    }
    pagebreak()
  }
}
