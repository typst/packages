#import "font.typ" as fonts
#import "../sections/info.typ" as infos
#import "../sections/info.typ": *

#let indent = h(2em)

#let abstract(
  isCN: true
) = {
  grid(
  columns: (1fr)
)[
  #align(center)[
    #text(
      font: fonts.HeiTi,
      size: fonts.No2,
    )[
      #if(isCN){
        [#infos.title-CN.sum()]
      }else{
        set text(weight: "bold")
        [#infos.title-EN.sum()]
      }
      
    ]
  ]
  #align(right)[
    #text(
      font: fonts.HeiTi,
      size: fonts.No2-Small,
    )[
      #if(isCN){
        [——#infos.subtitle-CN]
      }else{
        set text(weight: "bold")
        [——#infos.subtitle-EN]
      }
      
    ]
  ]
  #align(center)[
    #text(
      font: fonts.SongTi,
      size: fonts.No4,
    )[
      #if(isCN){
        [#infos.author-CN]
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
      （#infos.department-CN 指导教师：#infos.advisor-CN）
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
        )[[摘要]:]#abstract-content.at(0)
      ]

      v(0.5em)
      par()[
        #indent#abstract-content.at(1)
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
          #for i in infos.keywords{
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
        )[[Abstract]:]#abstract-content.at(0)
      ]
      v(0.5em)
      par()[
        #indent#abstract-content.at(1)
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
          #for i in infos.keywords{
            i
            [; ]
          }
      ]
      ]      
    }
  ]
  
  

  
]

}

#abstract(isCN: true)