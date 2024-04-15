#import "../configs/font.typ" as fonts
#import "../configs/info.typ" as infos
#import "../content.typ": abstract
#let indent = h(2em)

#grid(
  columns: (1fr)
)[
  #align(center)[
    #text(
      font: fonts.HeiTi,
      size: fonts.No2,
    )[
      #infos.title-CN.sum()
    ]
  ]
  #align(right)[
    #text(
      font: fonts.HeiTi,
      size: fonts.No2-Small,
    )[
      ——#infos.subtitle-CN
    ]
  ]
  #align(center)[
    #text(
      font: fonts.SongTi,
      size: fonts.No4,
    )[
      #infos.author-CN
    ]
  ]
  #align(center)[
    #text(
      font: fonts.KaiTi,
      size: fonts.No4-Small,
    )[
      （#infos.department-CN 指导教师：#infos.advisor-CN）
    ]
  ]

  #linebreak()
  #linebreak()

  #set par(
    first-line-indent: 0em,
    leading: 25pt,
  )
  #set text(
      font: fonts.SongTi,
      size: fonts.No4
    )
    
  #par()[
    #text(
      font: fonts.HeiTi,
      size: fonts.No3,
    )[[摘要]:]#abstract.at(0)
  ]
  #par()[
     #indent#abstract.at(1)
  ]

  #linebreak()
  #linebreak()

  #par()[
    #text(
    font: fonts.HeiTi,
    size: fonts.No3,
  )[[关键词]:]
    #text(
      font: fonts.SongTi,
      size: fonts.No4
    )[
      关键词；关键词；关键词
    ]
  ]
]