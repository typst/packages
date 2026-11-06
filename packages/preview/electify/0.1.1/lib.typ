#let ballot-paper(
    type: str, 
    date: datetime, 
    constituency: str,
    parties: array) = {
  
  import "@preview/datify:0.1.3": custom-date-format

  let txtBlue = rgb("0e7ec3")
  let txtGray = rgb("4b4c4d")
  
  set text(lang: "de", font: "Fira Sans", size: 10pt, fill: txtGray)
  set page(height: auto, margin: (top: 40pt, bottom: 20pt, x: 20pt), columns: 2)
  set columns(gutter: 15pt)
  set par(leading: 10pt)

  let party-first-counter = counter("party-first")
  let party-second-counter = counter("party-second")

  place(
    top + center,
    scope: "parent",
    float: true,
    block[
      #text(size: 25pt, weight: "bold")[Stimmzettel] \ #v(2pt)
      #text(size: 12pt)[
        für die Wahl #type \
        am #custom-date-format(date, "DD. MMMM YYYY", "de") \
        im Wahlkreis #constituency
      ]
      #v(5pt)
      
      #text(size: 20pt, weight: "bold")[Sie haben]
      #text(size: 30pt, weight: "black")[#h(8pt)2#h(12pt)]
      #text(size: 20pt, weight: "bold")[Stimmen]
      #v(-6pt)
      #image("media/arrows.png", width: 260pt)
      #v(-8pt)
    ]
  )

  // ERSTSTIMME
  set align(right)

  text(size: 12pt, weight: "bold")[hier 1 Stimme\ ]
  text[für die Wahl\ ]  
  text(size: 12pt, weight: "bold")[einer Wahlkreisbewerberin/\ ]
  text(size: 12pt, weight: "bold")[eines Wahlkreisbewerbers\ ]
  
  linebreak()
  linebreak()
  text(size: 18pt, weight: "bold")[Erststimme]

  set align(left)
  
  table(
    columns: (auto, 1.2fr, 1fr, auto),
    inset: (x: 5pt, y: 8pt),
    stroke: none,
    rows: 65pt,
    align: horizon, 
    
    table.hline(stroke: 1.3pt + txtGray),
    
    ..for party in parties {
      ( table.vline(stroke: 1.3pt + txtGray), )

      if party.top_candidate == none {
        (table.cell(colspan: 4)[#party-first-counter.step()],)
        ( table.hline(stroke: 0.6pt + txtGray), )
        continue
      }

      ( text(weight: "bold", size: 12pt)[
          #align(right)[
            #party-first-counter.step() 
            #context party-first-counter.display()#v(1fr)]
          ], 
      )
      ( table.vline(stroke: 0.6pt + txtGray),)
      ([
        #text(weight: "bold", size: 12pt)[#party.top_candidate.last_name,]
        #text(size: 7pt)[#party.top_candidate.first_name]
        #v(1fr)
        #par(leading: 5pt)[#text(size: 7pt)[
          #party.top_candidate.profession \
          #party.top_candidate.place
        ]]
      ],)
      ([
        #par(leading: 6pt)[
          #text(size: 12pt, weight: "bold")[#party.abbrevation]; #linebreak()
          #text(size: 7pt)[#party.name]
        ]
      ],)
      ( table.vline(stroke: 0.6pt + txtGray), )
      ( circle(radius: 13pt), )
      ( table.vline(stroke: 1.3pt + txtGray), )
      ( table.hline(stroke: 0.6pt + txtGray), )
    },
    
    table.hline(stroke: 1.3pt + txtGray),
  )
  
  // ZWEITSTIMME
  colbreak()
  
  set align(left)
  set text(fill: txtBlue)
  
  text(size: 12pt, weight: "bold")[hier 1 Stimme\ ]
  text[für die Wahl\ ]  
  text(size: 12pt, weight: "bold")[einer Landesliste (Partei)\ ]
  text(size: 10pt)[\u{2012} maßgebende Stimme für die Verteilung der \
  #h(8pt)Sitze ingesamt auf die einzelnen Parteien \u{2012}]

  v(-0.55pt)
  linebreak()
  text(size: 18pt, weight: "bold")[Zweitstimme]

  linebreak()
  table(
    columns: (auto, 1fr, 2fr, auto),
    inset: (x: 5pt, y: 8pt),
    stroke: none,
    rows: 65pt,
    align: horizon, 
    
    table.hline(stroke: 1.3pt + txtBlue),
    
    ..for party in parties {
      ( table.vline(stroke: 1.3pt + txtBlue), )

      if party.candidates == none {
        (table.cell(colspan: 4)[#party-second-counter.step()],)
        ( table.hline(stroke: 0.6pt + txtBlue), )
        continue
      }

      ( circle(radius: 13pt, stroke: txtBlue), )
      ( table.vline(stroke: 0.6pt + txtBlue), )
      ( par(justify: true)[#text(weight: "bold", size: 14pt)[#party.abbrevation]],)
      ( par(leading: 5.5pt)[
          #text(size: 9pt, weight: "bold")[#party.name]
          #v(-5pt)
          #text(size: 6.25pt)[#party.candidates.join(", ")]
        ], 
      )
      ( table.vline(stroke: 0.6pt + txtBlue), )
      ( text(weight: "bold", size: 12pt)[
          #align(right)[
            #party-second-counter.step() 
            #context party-second-counter.display()#v(1fr)]
          ], 
      )
      ( table.vline(stroke: 1.3pt + txtBlue), )
      ( table.hline(stroke: 0.6pt + txtBlue), )
    },
    
    table.hline(stroke: 1.3pt + txtBlue),
    
  )

}
