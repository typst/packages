#import "font.typ" as fonts

#let abstract(
  isCN: true,
  information: (
    title: (
      [第一行],
      [第二行],
      [第三行],
    ),
    subtitle: [副标题],
    keywords: (
      [Keyword1],
      [关键词2],
      [啦啦啦],
      [你好]
    ),
    author: [慕青QAQ],
    department: [数学系],
    major: [数学],
    advisor: [木木],
  ),
  body: (
      [#lorem(40)],
      [#lorem(40)],
  ),
) = {
  let indent = h(2em)

  grid(
  columns: (1fr)
)[
  #align(center)[
    #text(
      font: fonts.HeiTi,
      size: fonts.No2,
    )[
      #if(isCN){
        [#information.title.sum()]
      }else{
        set text(weight: "bold")
        [#information.title.sum()]
      }
      
    ]
  ]
  #align(right)[
    #text(
      font: fonts.HeiTi,
      size: fonts.No2-Small,
    )[
      #if(isCN){
        [——#information.subtitle]
      }else{
        set text(weight: "bold")
        [——#information.subtitle]
      }
      
    ]
  ]
  #align(center)[
    #text(
      font: fonts.SongTi,
      size: fonts.No4,
    )[
      #if(isCN){
        [#information.author]
      }
    ]
  ]
  #align(center)[
    #text(
      font: fonts.KaiTi,
      size: fonts.No4-Small,
    )[
      #if(isCN){
        [
      （#information.department 指导教师：#information.advisor）
      ]
      }
    ]
  ]
  
  #v(2em)

  #set par(
    first-line-indent: 0em,
    leading: 25pt,
  )
  #set text(
      font: fonts.SongTi,
      size: fonts.No4
    )
  #par()[
    #if(isCN){
      [
        #text(
          font: fonts.HeiTi,
          size: fonts.No3,
        )[[摘要]:]#body.at(0)
      ]

      v(0.5em)
      par()[
        #indent#body.at(1)
      ]

      v(4em)

      par()[
        #text(
          font: fonts.HeiTi,
          size: fonts.No3,
        )[[关键词]:]
        #text(
          font: fonts.SongTi,
          size: fonts.No4
        )[
          #for i in information.keywords{
            i
            [；]
          }
        ]
      ]
    }else{
      [
        #text(
          font: fonts.HeiTi,
          size: fonts.No3,
          weight: "bold"
        )[[Abstract]:]#body.at(0)
      ]
      v(0.5em)
      par()[
        #indent#body.at(1)
      ]
      v(4em)
      par()[
        #text(
          font: fonts.HeiTi,
          size: fonts.No3,
          weight: "bold"
        )[[Key Words]:]
        #text(
          font: fonts.SongTi,
          size: fonts.No4
        )[
          #for i in information.keywords{
            i
            [; ]
          }
      ]
      ]      
    }
  ]
]
}