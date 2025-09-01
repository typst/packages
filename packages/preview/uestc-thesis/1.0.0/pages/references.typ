// References page as a function
#import "../utils/header.typ": header-content

#let references(bib) = {


  set page(header: header-content("参考文献"))
  set par(first-line-indent: 0em, justify: true)
  set text(font: ("Times New Roman", "SimSun"), size: 10.5pt) // 五号字
  // heading("参考文献",numbering: none)
  bib

  
}
