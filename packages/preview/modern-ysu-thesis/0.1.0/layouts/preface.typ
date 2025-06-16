#import "../utils/custom-heading.typ": heading-display, active-heading, current-heading,header-display
// 前言，重置页面计数器
#let preface(
  // documentclass 传入的参数
  twoside: false,
  // 其他参数
  spec: (front: "- I -", inner: "- 1 -", back: "I"),
  ..args,
  it,
) = {
  // 分页
  if (twoside) {
    pagebreak() + " "
  }
  set page(numbering: "I",
  footer:[
    #set align(center)
    #counter(page).display("- I -")
  ],
  // 从mainmatter那里复制过来的，区别是奇偶页的标题不同
  header:{
    locate(loc => {
      let cur-heading = current-heading(level: 1, loc)
          let first-level-heading = if calc.rem(loc.page(), 2)==1 {
              heading-display(active-heading(level: 1,prev:false, loc)) 
          } else {
            "燕山大学本科生毕业设计（论文）" 
          }
          header-display(first-level-heading)
        v(0em)
    })
  })
  counter(page).update(1)
  it
}