#import "fonts.typ": *

#let authorization-page(
  title: "吉林大学本科毕业论文（设计）版权使用授权书",
  content: "本毕业论文（设计）作者同意学校保留并向国家有关部门或机构送交论文的复印件和电子版，允许论文被查阅和借阅。本人授权吉林大学可以将本毕业论文（设计）的全部或部分内容编入有关数据库进行检索，可以采用影印、缩印或扫描等复制手段保存和汇编本毕业论文（设计）。",
  confidential: false,
  author-signature-img: none,
  mentor-signature-img: none,
  date: auto
) = {
  page[
    #set par(leading: 1.5em, first-line-indent: 2em)
    
    // 标题
    #align(center)[
      #text(size: 18pt, weight: "bold", font: fonts.hei)[#title]
    ]
    
    #v(1cm)
    
    // 正文
    #text(size: 14pt, font: fonts.song)[#content]
    
    #v(0.8cm)
    
    // 保密选项
    #align(left)[
      #text(size: 14pt, font: fonts.fang)[
        保密 □, 在 #h(1em) 年解密后连用本授权书。
      ]
    ]
    
    #v(0.3cm)
    
    #align(left)[
      #text(size: 14pt, font: fonts.fang)[
        不保密 □.
      ]
    ]
    
    #v(1.5cm)
    
    // 签名区域
    #grid(
      columns: (1fr, 1fr),
      column-gutter: 3em,
      
      // 左列：作者签名
      [
        #align(center)[
          #text(size: 12pt, font: fonts.fang)[作者签名：]
        ]
        #v(1.5cm)
        #if author-signature-img != none [
          #align(center)[
            #image(author-signature-img, width: 4cm)
          ]
        ] else [
          #align(center)[
            #line(length: 4cm)
          ]
        ]
        
        #v(0.3cm)
        
        #align(center)[
          #text(size: 12pt, font: fonts.fang)[
            #if date == auto [
              日期：#underline(h(1.2em))年 #underline(h(1.2em))月 #underline(h(1.2em))日
            ] else [
              日期：#date
            ]
          ]
        ]
      ],
      
      // 右列：指导教师签名
      [
        #align(center)[
          #text(size: 12pt, font: fonts.fang)[指导教师签名：]
        ]
        #v(1.5cm)
        #if mentor-signature-img != none [
          #align(center)[
            #image(mentor-signature-img, width: 4cm)
          ]
        ] else [
          #align(center)[
            #line(length: 4cm)
          ]
        ]
        
        #v(0.3cm)
        
        #align(center)[
          #text(size: 12pt, font: fonts.fang)[
            #if date == auto [
              日期：#underline(h(1.2em))年 #underline(h(1.2em))月 #underline(h(1.2em))日
            ] else [
              日期：#date
            ]
          ]
        ]
      ]
    )
  ]
}
