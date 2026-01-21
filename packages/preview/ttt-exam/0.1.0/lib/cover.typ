
#import "i18n.typ": *
#import "@preview/ttt-utils:0.1.0": components, grading

#import components: checkbox, field, lines

#let grading_table(dist) = {
  table(
    columns: (2cm, 1fr, 5cm),
    inset: 0.7em,
    align: center,
    "Note", "Punkteschlüssel", "Anzahl",
    ..dist.rev().map(g => (g.grade, [von #g.lower-limit bis #g.upper-limit], []) ).flatten(),
    table.cell(colspan: 2)[
      #align(end)[Notendurchschnitt #math.lr(size: 1em)[#sym.diameter]:]
    ]
  ) 
}

// COVER PAGE
#let cover-page(
  class: none,
  subject: none,
  dates: (
          gehalten: none, 
          zurückgegeben: none, 
          eingetragen: none,
        ),
  comment: none,
  total_points: 100,
  ..args
) = {
  
  return page(
    margin: (left: 20mm, right: 20mm, top: 10mm, bottom: 20mm),
    footer: none
  )[
    #set text(16pt)

    // header - title
    #box(
      width: 100%, 
      stroke: luma(70),
      inset: 1em, 
      radius: 3pt
    )[
      #align(center)[#text(22pt)[Deckblatt Leistungsnachweis]]
    ]

    // content
    #grid(
      columns: (auto, 1fr, auto, auto),
      align: (col, _) => if ( calc.even(col) ) { end } else { auto },
      gutter: 1em,
      linguify("class", from: ling_db) + ": ", text(weight: "semibold", class),
      "Schuljahr: ", 
      { 
        if type(dates.gehalten) == datetime {
          let date = dates.gehalten;
          if date.month() < 9 {str(date.year()-1) + "/" + str(date.year())} else { str(date.year()) + "/" + str(date.year()+1) }
        } else { align(bottom,line(length: 3cm))}
      },
      linguify("subject", from: ling_db) + ": ", text(weight: "semibold", subject),
      grid.cell(colspan: 2, align: start)[#checkbox() SA #h(1em) #checkbox() KA \ #checkbox() #field(none)]
    )
    #v(0.5cm)
    
    // Missing student and student count
    #table(
      columns: (auto),
      row-gutter: (1cm),
      stroke: none,
      inset: 0pt,
      align: bottom,
      [Fehlende SchülerInnen: #box(width: 1fr)[#align(end)[ Anzahl Teilnehmer: #box(width:1.5cm, stroke: (bottom: 0.5pt))]]],
      lines(2)
    )


    // Dates
    Datum: #h(1fr)
    #field("gehalten", value: dates.gehalten.display("[day].[month].[year]")) #h(1fr) 
    #field("zurückgegeben") #h(1fr) 
    #field("eingetragen")
    
    #v(0.5cm)

    // Grading table uses the ihk grading distribution
    #grading_table(grading.ihk-grades(total_points));

    // Comment
    #grid(
      columns: (auto),
      row-gutter: 1cm,
      smallcaps("Bemerkung:"),
      if (comment != none) {comment} else {
          lines(2)
      },
    )
    
    // Signature
    #align(bottom, 
      box(
        stroke: (top: (thickness:1pt, paint:blue, dash: "dashed") ), 
        width: 100%, 
        inset: (top: 4pt)
      )[
        #text(12pt)[#smallcaps("Unterschrift:")]
        
        #h(1cm) #field("Lehrer") 
        #h(1fr) #field("Fachbetreuer")
      ]
    )      

  ] // end page

}
