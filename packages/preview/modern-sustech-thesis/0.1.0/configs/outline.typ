#import "font.typ" as fonts
  // show heading: title => {
  //   set align(center)
  //   set text(
  //     font: fonts.HeiTi,
  //     size: fonts.No2-Small,
  //   )
  //   title
  // }

#let toc(isCN: true) = {
  set outline(
  fill: box(
    width: 1fr, 
    repeat(h(5pt) + "." + h(5pt))) + h(5pt)
  )

  show outline: it => {
    show heading: title => {
      set align(center)
      if(isCN){
        set text(
          font: fonts.HeiTi,
          size: fonts.No2-Small,
        )
        title
        v(1em)
      }else{
        set text(
          font: fonts.HeiTi,
          size: fonts.No2-Small,
          weight: "bold",
        )
        title
        v(1em)
      }
    }
    it
  }

  show outline.entry: it => {

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

  if(isCN){
    pagebreak()
    outline(
      title: [目录]
    )
  }else{
    pagebreak()
    outline(
      title: [Table of Content]
    )
  }
  
}