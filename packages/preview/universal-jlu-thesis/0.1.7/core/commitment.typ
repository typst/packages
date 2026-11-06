#import "fonts.typ": *

#let commitment-page(
  title: "吉林大学学士学位论文（设计）承诺书",
  content: "本人郑重承诺：所呈交的学士学位毕业论文（设计），是本人在指导教师的指导下，独立进行实验、设计、调研等工作基础上取得的成果。除文中已经注明引用的内容外，本论文（设计）不包含任何其他个人或集体已经发表或撰写的作品成果。对本人实验或设计中做出重要贡献的个人或集体，均已在文中以明确的方式注明。本人完全意识到本承诺书的法律结果由本人承担。",
  signature: "承诺人：",
  date-text: "年  月  日"
) = {
  page[
    #set par(leading: 1.5em, first-line-indent: 2em)
    
    #align(center)[
      #text(size: 18pt, weight: "bold", font: fonts.hei)[#title]
    ]
    
    #v(1.5cm)
    
    #text(size: 14pt, font: fonts.fang)[#content]
    
    #v(8cm)
    
    // 签名和日期部分
    #grid(
      columns: (1fr),
      rows: (auto, 2em, auto),
      
      // 签名行
      [#align(right)[#text(size: 14pt, font: fonts.fang)[#signature]#h(10.75em)]],
      
      // 空行
      [],
      
      // 日期行
      [#align(right)[#text(size: 14pt, font: fonts.fang)[#date-text]#h(4em)]]
    )
  ]
}