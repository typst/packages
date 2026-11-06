// 导入字体模块
#import "fonts.typ": fonts, font-setup, songti, heiti, kaiti, fangsong

// 页面样式定义
#let page-styles = (
  empty: (
    header: none,
    footer: none,
  ),
  abstract-cn: (
    header: context [
      #set text(size: 9pt, font: fonts.song)
      #align(center)[摘要]
      #line(length: 100%)
    ],
    footer: context [#align(right)[#text(size: 9pt)[#counter(page).display("I")]]],
  ),
  abstract-en: (
    header: context [
      #set text(size: 9pt, font: fonts.song)
      #align(center)[Abstract]
      #line(length: 100%)
    ],
    footer: context [#align(right)[#text(size: 9pt)[#counter(page).display("I")]]],
  ),
  toc: (
    header: context [
      #set text(size: 9pt, font: fonts.song)
      #align(center)[目录]
      #line(length: 100%)
    ],
    footer: context [#align(right)[#text(size: 9pt)[#counter(page).display("I")]]],
  ),
  normal: (
    header: context [
      #set text(size: 9pt, font: fonts.song)
      #let headings = query(selector(heading.where(level: 1)).before(here()))
      #if headings.len() > 0 [
        #let last-heading = headings.last()
        #align(center)[
          #if last-heading.numbering != none [
            第#counter(heading).at(last-heading.location()).first()章 #last-heading.body
          ] else [
            #last-heading.body
          ]
        ]
      ]
      #line(length: 100%)
    ],
    footer: context [#align(right)[#text(size: 9pt)[#counter(page).display("1")]]],
  ),
)

// 页面设置函数
#let page-setup(style: "normal") = {
  // 应用全局字体设置
  font-setup()
  
  set page(
    paper: "a4",
    margin: (top: 20mm, bottom: 20mm, left: 30mm, right: 30mm),
    header: page-styles.at(style).header,
    footer: page-styles.at(style).footer,
    header-ascent: 7mm,
    footer-descent: 18pt,
  )
}

// 样式切换函数
#let cover-style() = {
  font-setup() // 确保封面也应用字体设置
  set page(
    paper: "a4",
    margin: (top: 20mm, bottom: 20mm, left: 30mm, right: 30mm),
    header: none,
    footer: none,
    header-ascent: 7mm,
    footer-descent: 18pt,
  )
}

#let abstract-cn-style() = {
  counter(page).update(1)
  set page(
    paper: "a4",
    margin: (top: 20mm, bottom: 20mm, left: 30mm, right: 30mm),
    header: none,
    footer: context [#align(right)[#text(size: 9pt)[#counter(page).display("I")]]],
    header-ascent: 7mm,
    footer-descent: 18pt,
  )
}

#let abstract-en-style() = {
  counter(page).update(2)
  set page(
    paper: "a4",
    margin: (top: 20mm, bottom: 20mm, left: 30mm, right: 30mm),
    header: none,
    footer: context [#align(right)[#text(size: 9pt)[#counter(page).display("I")]]],
    header-ascent: 7mm,
    footer-descent: 18pt,
  )
}

#let toc-style() = {
  counter(page).update(3)
  set page(
    paper: "a4",
    margin: (top: 20mm, bottom: 20mm, left: 30mm, right: 30mm),
    header: context [
      #set text(size: 9pt, font: fonts.song)
      #align(center)[目录]
      #line(length: 100%)
    ],
    footer: context [#align(right)[#text(size: 9pt)[#counter(page).display("I")]]],
    header-ascent: 7mm,
    footer-descent: 18pt,
  )
}

#let content-style() = {
  counter(page).update(1)
  set page(
    paper: "a4",
    margin: (top: 20mm, bottom: 20mm, left: 30mm, right: 30mm),
    header: context [
      #set text(size: 9pt, font: fonts.song)
      #let headings = query(selector(heading.where(level: 1)).before(here()))
      #if headings.len() > 0 [
        #let last-heading = headings.last()
        #align(center)[
          #if last-heading.numbering != none [
            第#counter(heading).at(last-heading.location()).first()章 #last-heading.body
          ] else [
            #last-heading.body
          ]
        ]
      ]
      #line(length: 100%)
    ],
    footer: context [#align(right)[#text(size: 9pt)[#counter(page).display("1")]]],
    header-ascent: 7mm,
    footer-descent: 18pt,
  )
  set text(size: 12pt) // 小四号字体
}