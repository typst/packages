#import "style.typ": zihao, ziti

#let tust-page-header(
  heading: "天津科技大学本科毕业设计",
  show-header: true,
  it,
) = {
  set page(
    header: if show-header {
      context {
        set text(font: ziti.songti, size: zihao.wuhao)
        set par(first-line-indent: 0em)
        block(height: 1cm)
        align(center, heading)
        v(-4pt)
        line(length: 100%, stroke: 0.5pt)
        block(height: 1fr)
      }
    } else { none },
    footer: context {
      set text(font: "Times New Roman", size: zihao.wuhao)
      align(center, counter(page).display())
    },
  )
  it
}
