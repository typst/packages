#import "font.typ" as fonts
#import "info.typ" as infos

#let shortline(
  title,
  pos: left,
  titlelength: 4em,
  linelength: 5em,
  isCN: true,
) = {
  let drawbaseline(length, weight, content) = {
    box(
      width: length, 
      stroke: (bottom: weight)
      )[#content]
  }

  set text(
      font: fonts.SongTi,
      size: fonts.No4-Small
  )

  align(right)[
    #if (title == [Available for reference]){
      title
      drawbaseline(
        linelength, 
        0pt
      )[#text(size: fonts.No4-Small)[
        □ Yes □ No]
      ]
    }else{
      title
      drawbaseline(
        linelength, 
        0.5pt
      )[]
    }
        
  ]
}

#let longline(
  length,
  title,
  content,
) = {
  grid.cell(
      colspan: 3,
      rowspan: 3,
    )[
      #text(
        font: fonts.SongTi,
        size: fonts.No3,
        weight: "bold",
      )[
        #h(2em)
        #box(
          width: 6em
        )[
          #align(left)[
              #title
            ]
        ]
        #box(
          inset: 3pt,
          width: length,
          stroke: (bottom: 0.5pt),
          baseline: 1pt,
        )[#content]
      ]
    ]
}

#let fillwith(
  width, 
  height,
  topline, 
  baseline,
  body
  ) = {
    if topline{
      topline = 0.5pt
    }else{
      topline = 0pt
    }
    if baseline{
      baseline = 0.5pt
    }else{
      baseline = 0pt
    }

    grid.cell(
        align: top + center,
        colspan: width,
        rowspan: height,
        stroke: (
          top: topline, 
          bottom: baseline),
        [
          #body
        ]
      )
}

#let makecover-core(
  classes,
  NO,
  UDC,
  secret,
  isCN: true
) = {
  let topline = false
  let baseline = false
  let columns = 3
  grid(
    align: auto,
    columns: columns,
    row-gutter: 1em,
    
    shortline([#classes]),
    h(0.5fr),
    shortline([#NO]),

    shortline([#UDC]),
    h(0.5fr),
    shortline([#secret]),

    fillwith(
      columns,
      3,
      topline, 
      baseline
    )[
      #box(
        fill: blue
      )
    ],

    fillwith(
      columns,
      3,
      topline, 
      baseline
    )[
      #if isCN{
        image(
          "SUSTech LOGO CN.svg",
          width: 90%
        )
      }else{
        image(
          "SUSTech LOGO EN.svg",
          width: 90%
        )
      }
      
    ],

    fillwith(
      3,
      1,
      topline,
      baseline,
    )[
      #text()[]
    ],

    fillwith(
      columns, 
      5, 
      topline, 
      baseline
    )[
        #text(
          font: fonts.SongTi,
          size: fonts.Initial-Small,
          weight: 550,
        )[
          #if(isCN){
            [本科生毕业设计（论文）]
          }else{
            [Undergraduate Thesis]
          }
        ]
    ],

    fillwith(
      columns,
      7,
      topline,
      baseline,
    )[],
    
    longline(
      18em,
      box(width: 8em)[
        #if(isCN == true){
          [题#h(2em)目：]
        }else{
          [Thesis Title:]
        }
        ],
    )[
        #align(center)[
          #if(isCN){
            infos.title-CN.at(0)
          }else{
            infos.title-EN.at(0)
          }
        ]
    ],
    

    // blank long line
    longline(
      18em,
      [],
    )[
      #align(center)[
        #if(isCN){
            infos.title-CN.at(1)
          }else{
            infos.title-EN.at(1)
          }
      ]
    ],

    longline(
      18em,
      [],
    )[
      #align(center)[
        #if(isCN){
            infos.title-CN.at(2)
          }else{
            infos.title-EN.at(2)
        }
      ]
    ],
    

    longline(
      18em,
      box(width: 8em)[
        #if(isCN == true){
          [姓#h(2em)名：]
        }else{
          [Student Name:]
        }
      ]
      )[
        #align(center)[
          #if(isCN){
            infos.author-CN
          }else{
            infos.author-EN
          }
        ]
      ],

    longline(
      18em,
      box(width: 8em)[
        #if(isCN == true){
          [学#h(2em)号：]
        }else{
          [Student ID:]
        }
      ]
      )[
        #align(center)[
          #infos.SID
        ]
      ],

    longline(
      18em,
      box(width: 8em)[
        #if(isCN == true){
          [系#h(2em)别：]
        }else{
          [Department:]
        }
      ]
      )[
        #align(center)[
          #if(isCN){
            infos.department-CN
          }else{
            infos.department-EN
          }
        ]
      ],


    longline(
      18em,
      box(width: 8em)[
        #if(isCN == true){
          [专#h(2em)业：]
        }else{
          [Rrogram:]
        }
      ]
      )[
        #align(center)[
          #if(isCN){
            infos.major-CN
          }else{
            infos.major-EN
          }
        ]
      ],

    longline(
      18em,
      box(width: 8em)[
        #if(isCN == true){
          [指导教师：]
        }else{
          [Thesis Advisor:]
        }
      ]
      )[
        #align(center)[
          #if(isCN){
            infos.advisor-CN
          }else{
            infos.advisor-EN
          }
        ]
      ],

    fillwith(
      3,
      7,
      topline,
      baseline,
    )[],
    
    fillwith(
      3,
      1,
      topline,
      baseline,
    )[
      #text(
        font: fonts.SongTi,
        size: fonts.No3,
      )[
        #if(isCN){
          datetime.today().display(
            infos.date-CN
          )
        }else{
          datetime.today().display(
            infos.date-EN
          )
        }
      ]
    ]
  )
  pagebreak()
}

#let make-cover(isCN: bool) = {
  if(isCN){
    makecover-core(
    [分类号], 
    [编  号], 
    [U D C], 
    [密  级],
  )
  }else{
    makecover-core(
    [C L C], 
    [Number], 
    [U D C], 
    [Available for reference],
    isCN: false,
  )
  }
} 

#make-cover(isCN: false)