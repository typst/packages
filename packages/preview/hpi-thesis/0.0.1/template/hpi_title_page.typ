#let hpi-title-page(
  professor: "",
  advisors: (),
  chair: "",
  name: "",
  title: "",
  translation: "",
  study_program: "",
  date: "",
  type: "Bachelor",
) = {
  page(footer: [])[
    // Title page
    #grid(
      columns: (1fr, 1fr),
      rows: (80pt, 80pt),
      grid.cell(image("up_logo.png")),      
      grid.cell(align(right, image("hpi_logo.svg")))
    )
  
    #align(center, block[
      #line(length: 100%, stroke: 1.5pt)\
      #text(2em, weight: "bold", title) \ \
      #text(1.5em, translation) \ \
      #line(length: 100%, stroke: 1.5pt)
    ])
  
    #align(center, text(1.5em, weight: "bold", name))
  
    #if type == "Bachelor" {
      align(center, block[
        Universitätsbachelorarbeit\
        zur Erlangung des akademischen Grades
      ])
  
      align(center, text(1.5em, block[
        Bachelor of Science \
        #text(style: "italic", "(B.Sc.)")
      ]))
  
      align(center, block[
        im Studiengang \
        #study_program
      ])
  
      align(center, block[
        eingereicht am #date am \
        Fachgebiet #chair der \
        Digital-Engineering-Fakultät \
        der Universität Potsdam
      ])
  
      v(1cm)
      align(center, grid(
        columns: (1fr, 1.8fr),
        rows: (18pt, 18pt),
        grid.cell(align(left, text(weight: "bold", "Gutachter"))),
        grid.cell(align(left, professor)),
        grid.cell(align(left, text(weight: "bold", "Betreuer"))),
        grid.cell(align(left, advisors.join("<break>")))
      ))
    }
  
    #if type == "Master" {
      align(center, block[
        Universitätsmasterarbeit\
        zur Erlangung des akademischen Grades
      ])
  
      align(center, text(1.5em, block[
        Master of Science \
        #text(style: "italic", "(M.Sc.)")
      ]))
  
      align(center, block[
        im Studiengang \
        #study_program
      ])
  
      align(center, block[
        eingereicht am #date am \
        Fachgebiet #chair der \
        Digital-Engineering-Fakultät \
        der Universität Potsdam
      ])
  
      v(1cm)
      align(center, grid(
        columns: (1fr, 1.8fr),
        rows: (18pt, 18pt),
        grid.cell(align(left, text(weight: "bold", "Gutachter"))),
        grid.cell(align(left, professor)),
        grid.cell(align(left, text(weight: "bold", "Betreuer"))),
        grid.cell(align(left, advisors.join(", ")))
      ))
    }
  ]
}