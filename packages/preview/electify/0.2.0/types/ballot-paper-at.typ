#let ballot-paper-at(
  type: str,
  date: datetime,
  constituency: str,
  candidates-count: 12,
  parties: array
) = {
  
  import "@preview/datify:0.1.3": custom-date-format

  let txtGray = rgb("3f3f3f")

  set text(lang: "de", font: "Fira Sans", size: 10pt, fill: txtGray)
  set page(width: auto, height: auto, flipped: true, margin: (top: 40pt, bottom: 20pt, x: 20pt))
  set columns(gutter: 15pt)
  set par(leading: 10pt)

  set align(center)

  text(size: 30pt, weight: "bold")[Amtlicher Stimmzettel\ ]  
  block(above: 15pt, below: 30pt)[
    #text(size: 14pt)[
      für die \
    ]
    #text(size: 17pt, weight: "bold")[
      #type am #custom-date-format(date, "DD. MMMM YYYY", "de") \
    ]
    #text(size: 15pt, weight: "bold")[
      Regionalwahlkreis #constituency \
    ]
  ]

  set par(leading: 6pt)
  set rect(height: 1fr, fill: blue)
  
  table(
    columns: (190pt,) + (130pt,) * parties.len(),
    align: center + horizon,
    inset: (x: 10pt, y: 8pt),
    stroke: txtGray,

    table.hline(stroke: 2pt),
    table.vline(stroke: 2pt),
    
    // PARTY NUMBERS
    table.cell(align: left)[Liste Nr.], 

    ..for i in range(parties.len()) {
      ( table.cell(text(size: 15pt, weight: "bold")[#{i+1}]), )
    },

    // PARTY NAMES
    table.cell(align: left)[Parteibezeichnung],

    ..for party in parties {
      ( table.cell(party.name), )
    },

    // PARTY ABBREVATIONS
    table.cell(align: left)[Kurzbezeichnung],
    
    ..for party in parties {
      ( table.cell(inset: (x: 12pt, y: 10pt), text(size: 30pt, weight: "semibold", party.abbrevation)), )
    },
    
    // VOTE CIRCLES
    table.cell(align: left)[Für die gewählte Partei im Kreis ein X einsetzen.],

    ..for i in range(parties.len()) {
      ( table.cell(circle(width: 45pt, height: 45pt)), )
    },
    
    // FEDERAL PRIORITY VOTE
    table.cell(align: left)[
      #text(size: 11pt)[VORZUGSSTIMME \u{2012}\ BUNDESWAHLVORSCHLAG\ ]
      Für die Vergabe einer Vorzugsstimme an eine Bewerberin oder einen Bewerber der Bundesparteiliste der gewählten Partei die Bezeichnung der Bewerberin oder des Bewerbers (Name und/oder Reihungsnummer der jeweiligen Bundesparteiliste) in das entsprechende Feld einsetzen.
    ],
    ..for _ in range(parties.len()) { (table.cell([]), ) },

    // STATE PRIORITY VOTE
    table.cell(align: left)[
      #text(size: 11pt)[VORZUGSSTIMME \u{2012}\ LANDESWAHLKREIS\ ]
      Für die Vergabe einer Vorzugsstimme an eine Bewerberin oder einen Bewerber der Landesparteiliste der gewählten Partei die Bezeichnung der Bewerberin oder des Bewerbers (Name und/oder Reihungsnummer der jeweiligen Landesparteiliste) in das entsprechende Feld einsetzen.
    ],
    ..for _ in range(parties.len()) { (table.cell([]), ) },

    // REGIONAL PRIORITY VOTE
    
    table.cell(
      rowspan: candidates-count,
      align: left + top
    )[
      #text(size: 11pt)[VORZUGSSTIMME \u{2012}\ REGIONALWAHLKREIS\ ]
      Für die Vergabe einer Vorzugsstimme an eine Bewerberin oder einen Bewerber der Landesparteiliste der gewählten Partei im Kreis links vom Namen ein X einsetzen.
    ],
      
    ..for i in range(candidates-count) {
      for party in parties {
        if i < party.candidates.len() {
          let (last-name, first-name, birthday) = party.candidates.at(i)
          
          (
            table.cell(inset: (x: 5pt), align: left + top)[
              #grid(
                columns: (15pt, 1fr),
                align: (center + horizon, left + horizon),
                row-gutter: 4pt,
                column-gutter: 4pt,
                rows: 12pt,
                [#(i + 1)], text(tracking: -0.3pt)[#last-name],
                [#circle(width: 13pt, height: 13pt)], text(tracking: -0.3pt)[#first-name, #birthday]
              )
            ],
          )
        } else {
          (table.cell(align: left + top)[], )
        }
      }
    },

    table.hline(stroke: 2pt),
    table.vline(stroke: 2pt),
    
  )
    
}