#import "../utils/states.typ": *
#import "../utils/fonts.typ": 字体, 字号

#let main-body-bachelor-conf(thesisname: [], doc) = {
  set page(
    header: {
        set align(center)
        set text(font: 字体.宋体, size: 字号.小五, lang: "zh")
        set par(first-line-indent: 0pt, leading: 16pt, justify: true)
        show par: set block(spacing: 16pt)

        locate(loc => {
          let next-heading = query(selector(<__heading__>).after(loc), loc)
          if next-heading != () and next-heading.first().location().page() == loc.page() and chapter-level-state.at(loc) == 1 {
            [] 
          } else {
            if calc.even(loc.page()) {
              thesisname.heading
            } else {
              let cl1nss = chapter-l1-numbering-show-state.at(loc)
              if not cl1nss in (none, "", [], [ ]){
                cl1nss
                h(0.3em)
              }
              chapter-l1-name-str-state.at(loc)
            }
            v(-1em)
            line(length: 100%, stroke: (thickness: 0.5pt))
          }})
        

        counter(footnote).update(0)
      },
    numbering: "1",
    header-ascent: 10%,
    footer-descent: 10%
  )

  pagebreak(weak: false)
  

  counter(page).update(1)
  counter(heading.where(level: 1)).update(0)
  part-state.update("正文")

  doc
}