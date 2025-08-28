#import "../utils/header.typ": header-content

#let acknowledgements(content: none) = {
  pagebreak()

  set page(header: header-content("致谢"))


  // let format_title = text.with(font: "SimHei", size: 18pt, weight: "bold")

  heading("致谢",level:1,numbering: none)


  content
  

}
