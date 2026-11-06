// #import "config.typ": *
#import "@preview/touying-pres-ustc:0.1.0": *

#codly(languages: (
  rust: (name: "Rust", icon: icon("./assets/img/brand-rust.svg"), color: RED),
))

// #set table(
//   stroke: none,
//   gutter: 0.2em,
//   fill: (x, y) =>
//     if x == 0 or y == 0 { BLUE },
//   inset: (right: 1.5em),
// )

// #show table.cell: it => {
//   if it.x == 0 or it.y == 0 {
//     set text(white)
//     strong(it)
//   } else if it.body == [] {
//     // Replace empty cells with 'N/A'
//     pad(..it.inset)[_N/A_]
//   } else {
//     it
//   }
// }

#show: codly-init.with()//codly代码块初始化
#show: init
#show: slides.with()

//第一步
//建议使用mycontent.typ来新建你自己的内容，不要直接修改content.typ，content.typ方便你参考。
#include "./content.typ"
//取消注释下面的行，注释上面的行
//#include "./mycontent.typ"




