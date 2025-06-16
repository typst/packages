
#let titlepage(
    thesis-type: "",
    degree: "",
    program: "",
    supervisor: "",
    advisors: (),
    department: "",
    author: "",
    date: none,
    title: ""
) ={

  set par(leading: 0.65em, first-line-indent: 0em, justify: false)
  show par: set block(spacing: 1.2em) // spacing after a paragraph

  place(bottom+left,float: false, dx: 0cm, dy:-10%)[#box(width: 74%)[

          // Title in upper case
          #text(size: 28pt, weight: "black", font: "Arial")[#upper[#title]]
          // JKU big-K Logo
          #image("big_K.png", width: 125pt)  
          //#v(-1cm)
          // Additional Information
          #set text(weight: "regular", font: "Arial")
          #text(size: 14pt)[#thesis-type's Thesis\ ]
          #text(size: 11pt)[to confer the academic degree of\ ]
          #text(size: 14pt)[#degree\ ]
          #text(size: 11pt)[in the #thesis-type's program\ ]
          #text(size: 14pt)[#program ]
      ]
    ]

    // JKU logo in the header
    place(top+right ,float: false, dx: 1cm, dy: -1.6cm)[#box(width: 26%)[
          // Title
          #align(right)[#image("JKU.png", width: 150pt)]

      ]
    ] 
  
    place(top+right ,float: false, dx: 1.2cm, dy: 3cm)[#box(width: 28%)[
          // Title
          #align(left)[
            
            
            #text(size: 9pt)[
            Author\
            *#author* \ \
            Submission\
            *#department*\ \
            Thesis Supervisor\
            *#supervisor*\ \
            #if advisors != () and advisors != ""  [
              #if advisors.len()>=2 [
                Assistant Thesis Supervisors\
              ] else [
                Assistant Thesis Supervisor\ 
              ]
              *#advisors.join(", \n")*\ \
            ]
            #date.display("[month repr:long] [year]")
            ]
          ]
      ]
    ] 

    place(bottom+right ,float: false, dx: 1cm, dy:1cm)[#box(width: 25%)[
          // Title
          #align(left)[
            
              #text(size: 8pt)[
            
              #text(size: 8pt, weight: "black", font: "Arial")[JOHANNES KEPLER
              UNIVERSITY LINZ]\
              Altenberger Straße 69\
              4040 Linz, Austria\
              jku.at\
            ]
            



            
          ]
      ]
    ]
  pagebreak()
}