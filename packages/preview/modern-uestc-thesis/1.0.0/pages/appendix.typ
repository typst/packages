#import "@preview/numbly:0.1.0": numbly
#import "../components/table.typ": thesis-table

#import "../utils/header.typ": header-content

#let appendix(content: []) = {
  set page(header: header-content("附录"))
  [

    #set heading(
      numbering: none,
    )

    #set figure(
      kind: table,
      caption: none,
    )
    #content

  
    
    
  ]
}
