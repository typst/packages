#import "../configs/font.typ" as fonts
#set outline(
  fill: box(
    width: 1fr, 
    repeat(h(5pt) + "." + h(5pt))) + h(5pt)
  )

#show outline: it => {
  show heading: title => {
    set align(center)
    set text(
      font: fonts.HeiTi,
      size: fonts.No2-Small,
    )
    title
  }
  it
}

#show outline.entry: it => {

  v(0.5em, weak: false)
  set text(
    font: fonts.SongTi,
    size: fonts.No4,
  )
  if(it.level == 1){
    set text(weight: "bold")
    it
  }else{
    it
  }
}

  // show heading: title => {
  //   set align(center)
  //   set text(
  //     font: fonts.HeiTi,
  //     size: fonts.No2-Small,
  //   )
  //   title
  // }


#pagebreak()
#outline(
  title: [目录]
)
#pagebreak()