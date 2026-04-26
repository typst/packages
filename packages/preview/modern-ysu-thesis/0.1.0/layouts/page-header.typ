#import "../utils/style.typ": 字号, 字体
#import "../utils/custom-numbering.typ": custom-numbering
#import "../utils/custom-heading.typ": heading-display, active-heading, current-heading,header-display
#import "../utils/unpairs.typ": unpairs

#let page-header(
  twoside: false,
  fonts: (:),
  // 其他参数
  numbering: custom-numbering.with(first-level: "第1章 ", depth: 4, "1.1 "),
  heading-align: (center, auto),
  // 页眉
  header-render: auto,
  header-vspace: 0em,
  display-header: true,
  stroke-width: 0.5pt,
  reset-footnote: true,
  ..args,
  it,
) = {
  set page(..(if display-header {
    (
      header: {
        // 重置 footnote 计数器
        if reset-footnote {
          counter(footnote).update(0)
        }
        locate(loc => {
          // 5.1 获取当前页面的一级标题
          if header-render == auto {
            // let cur-heading = current-heading(level: 1, loc)
            let first-level-heading = if calc.rem(loc.page(), 2)==1 {
                heading-display(active-heading(level: 1,prev:false, loc)) 
            } else {
              "燕山大学本科生毕业设计（论文）" 
            }
            header-display(first-level-heading)
          } else {
            header-render(loc)
          }
          v(header-vspace)
        })
      }
    )
  } else {
    (
      header: {
        // 重置 footnote 计数器
        if reset-footnote {
          counter(footnote).update(0)
        }
      }
    )
  }))
  it
}