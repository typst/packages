#import "fonts.typ": *

// 基础摘要模板
#let base-abstract(title, content, keywords-label, keywords, is-chinese: true, page-header: none, page-number: 1) = {
  set page(
    paper: "a4",
    margin: (top: 20mm, bottom: 20mm, left: 30mm, right: 30mm),
    header: none,
    footer: context [#align(right)[#text(size: 9pt)[#counter(page).display("I")]]],
    header-ascent: 7mm,
    footer-descent: 18pt,
  )
  
  counter(page).update(page-number)
  
  [
    #set par(leading: 1.5em)  // 1.5倍行距，使用em单位
    
    // 标题（4号字体，居中）
    #align(center)[
      #if is-chinese [
        #text(size: 14pt, weight: "bold", font: fonts.hei)[#title]
      ] else [
        #text(size: 14pt, weight: "bold")[#title]
      ]
    ]
    
    // 空1行
    #v(1em)
    
    // 正文内容（小4号字体，1.5倍行距，两个字符缩进）
    #set par(first-line-indent: 2em)  // 首行缩进两个字符
    #if is-chinese [
      #text(size: 12pt, font: fonts.song)[#content]
    ] else [
      #text(size: 12pt)[#content]
    ]
    
    // 空2行
    #v(2em)
    
    // 关键词（小4号字体，无缩进）
    #set par(first-line-indent: 0em)  // 关键词部分不缩进
    #if is-chinese [
      #text(size: 12pt, weight: "bold", font: fonts.song)[#keywords-label]
    ] else [
      #text(size: 12pt, weight: "bold")[#keywords-label]
    ]
    #h(1em)
    #if is-chinese [
      #text(size: 12pt, font: fonts.song)[#keywords.join("  ")]  // 中文关键词用空格分隔
    ] else [
      #text(size: 12pt)[#keywords.join("  ")]  // 英文关键词用空格分隔
    ]
    
    #pagebreak()
  ]
}

// 中文摘要
#let chinese-abstract(content, keywords) = {
  base-abstract(
    "摘  要", 
    content, 
    "关键词", 
    keywords,
    is-chinese: true,
    page-header: context [
      #set text(size: 9pt, font: fonts.song)
      #align(center)[摘要]
      #line(length: 100%)
    ],
    page-number: 1
  )
}

// 英文摘要  
#let english-abstract(content, keywords) = {
  base-abstract(
    "Abstract", 
    content, 
    "Keywords", 
    keywords,
    is-chinese: false,
    page-header: context [
      #set text(size: 9pt, font: fonts.song)
      #align(center)[Abstract]
      #line(length: 100%)
    ],
    page-number: 2
  )
}