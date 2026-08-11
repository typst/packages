#import "../utils/header.typ": footer

#let twoside-pagebreak = metadata(<mzt:twoside-pagebreak>)
#let twoside-emptypage = metadata(<mzt:twoside-emptypage>)
#let twoside-numbering-footer = metadata(<mzt:twoside-numbering-footer>)


#let show-twoside-pagebreak(s, twoside: true) = {
  show metadata.where(value: <mzt:twoside-pagebreak>): pagebreak(
    weak: true,
    // to: if twoside {
    //   "odd"
    // },
  )

  show metadata.where(value: <mzt:twoside-emptypage>): [
    #if twoside {
      [ #pagebreak()#[#v(100%)]<mzt:no-header-footer> ]
    }
  ]

  show metadata.where(value: <mzt:twoside-numbering-footer>): [
    #if twoside {
      footer(
        center: numbering => numbering,
        // left: numbering => locate(loc => if calc.even(loc.page()) {
        //   numbering
        // }),
        // right: numbering => locate(loc => if not calc.even(loc.page()) {
        //   numbering
        // }),
      )
    } else {
      footer(center: numbering => numbering)
    }
  ]
  s
}
