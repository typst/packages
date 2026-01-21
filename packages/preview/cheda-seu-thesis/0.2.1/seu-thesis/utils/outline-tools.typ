#import "states.typ": *
#import "../utils/fonts.typ": 字体, 字号

/* 
这里有一个巨大的自造轮子用于显示目录。

由于 heading 跨页问题，如果使用 Typst 内置的目录，将导致页码显示错误、链接跳转锚点不正确。故仍使用自造轮子。

请查阅 `utils/show-heading.typ` 以查看 heading 跨页的其他影响 。如有更好的解决方案，欢迎给出建议或提交 PR。
*/

#let cn-outline(
  outline-depth: 3, 
  base-indent: 1em,
  first-level-spacing: none,
  first-level-font-weight: "regular",
  show-self-in-outline: true,
  item-spacing: 14pt,
  use-raw-heading: false,
) = [
  #set text(font: 字体.宋体, size: 字号.小四)

  #set par(leading: item-spacing, first-line-indent: 0pt)

  #locate(loc => {
    let elems = query(heading.where(outlined: true), loc)
    for el in elems {
      let el_real_loc = query(selector(<__heading__>).after(el.location()), el.location()).first().location()

      let outlineline = {
        if (el.level == 1) {
          v(if first-level-spacing != none {first-level-spacing} else {item-spacing} - 1em)
          // 一级标题前更长的空间
        }

        h((el.level - 1) * 2em + base-indent)

        if el.level == 1 {
          set text(weight: first-level-font-weight)

          if chapter-numbering-show-state.at(el_real_loc) != none {
            chapter-numbering-show-state.at(el_real_loc)
            h(0.5em)
          }

          if use-raw-heading {
            chapter-name-str-state.at(el_real_loc)
          } else {
            chapter-name-show-state.at(el_real_loc)
          }
        } else if el.level <= outline-depth and chapter-numbering-show-state.at(el_real_loc) != none {
          chapter-numbering-show-state.at(el_real_loc)
          h(0.3em)
          chapter-name-show-state.at(el_real_loc)
        } else {continue}

        box(width: 1fr, h(10pt) + box(width: 1fr, repeat[.]) + h(10pt))

        chapter-page-number-show-state.at(el_real_loc)

        linebreak()
      }

      link(el_real_loc)[#outlineline]
    }
  })
]