#let standard-box(text: "") = {
  rect(width: 100%, height: 15pt, stroke: 0.5pt, text)
}

#let tall-box(text: "") = {
  rect(width: 100%, height: 1fr, stroke: 0.5pt, text)
}

#let small-box = [
  #rect(width: 15pt, height: 15pt, stroke: 0.5pt)
]

#let small-box = [
  #rect(width: 15pt, height: 15pt, stroke: 0.5pt)
]

#let header(callsign, type, departure) = {[
  #text(6pt)[
#table(columns: (25%, 25%, 25%, 25%), stroke: (none), row-gutter: -8pt
)[Callsign][Type][Sartime][Departure Airport][#standard-box(text: callsign)][#standard-box(text: type)][#standard-box()][#standard-box(text: departure)][DEPARTURE TIME][FORECAST][NOTAM][W & B][#table(columns: (1fr, 1fr), inset: 0pt,
  align: horizon,
  stroke: (none),
  [#standard-box()],
  [#standard-box()],
)][#table(columns: (1fr, 1fr, 1fr), inset: 0pt,
  align: horizon,
  stroke: (none),
  [#small-box],
  [#small-box],
  [#small-box]
)][#table(columns: (1fr, 1fr, 1fr), inset: 0pt,
  align: horizon,
  stroke: (none),
  [#small-box],
  [#small-box],
  [#small-box]
)][#table(columns: (1fr, 1fr), inset: 0pt,
  align: horizon,
  stroke: (none),
  [#standard-box()],
  [#standard-box()],
)][#text(size: 6pt)[#table(columns: (1fr, 1fr), inset: 0pt,
  align: horizon,
  stroke: (none),
  [ETD],
  [ATD],
)]][#text(size: 6pt)[#table(columns: (1fr, 1fr, 1fr), inset: 0pt,
  align: horizon,
  stroke: (none),
  [GAFS],
  [TAFS],
  [GPWT]
)]][#text(size: 6pt)[#table(columns: (1fr, 1fr, 1fr), inset: 0pt,
  align: horizon,
  stroke: (none),
  [Location],
  [FIR],
  [Head]
)]][#text(size: 6pt)[#table(columns: (1fr, 1fr), inset: 0pt,
  align: horizon,
  stroke: (none),
  [WGT KG],
  [CG %],
)]]]
]}

#let nav-log(fixes) = {[
  #box(height: 30%)[
  #text(6pt)[
      #table(columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1.5fr, 1.5fr, 1.5fr),
      align: horizon,
      stroke: 0.5pt,
      fill: (x, _) =>
        if calc.odd(x) { rgb("#f0f0f0") }
        else { white },
      table.header(table.cell(rowspan: 1, colspan: 13, fill: rgb("#f0f0f0"))[#align(center)[*NAV LOG*]]),
      rows: (0.8fr, 1fr, 1.5fr, 1.5fr, 1.5fr, 1.5fr, 1.5fr, 1.5fr, 1.5fr),
      [POSN],
      [FL/ALT],
      [TAS],
      [TR(M)],
      [Wind],
      [HDG(M)],
      [G/S],
      [DIST],
      [ETI],
      [EET],
      [PLN EST],
      [REV EST],
      [ATA ATD],
      fixes
    )]
  ]
]}

#let fuel-com-log = [
  #box(height:25%)[
  #text(5pt)[
  #columns(3)[
    Fuel Track
    #table(columns:(0.75fr, 1fr, 1fr),
    stroke: 0.5pt,
    fill: (x, y) =>
        if y == 0 { rgb("#f0f0f0") }
        else if calc.even(y) { rgb("#f0f0f0") }
        else { white },)[At][Left (min)][Right (min)][(#h(0.5fr))][][][(#h(0.5fr))][][][(#h(0.5fr))][][][(#h(0.5fr))][][][(#h(0.5fr))][][][(#h(0.5fr))][][][(#h(0.5fr))][][][(#h(0.5fr))][][]
    Frequencies
    #table(columns:(0.75fr, 1fr, 1fr), stroke: 0.5pt, fill: (x, y) =>
        if y == 0 { rgb("#f0f0f0") }
        else if calc.even(y) { rgb("#f0f0f0") })[At][Com 1][Com 2][#v(4pt)][][][#v(4pt)][][][#v(4pt)][][][#v(4pt)][][][#v(4pt)][][][#v(4pt)][][][#v(4pt)][][][#v(4pt)][][]
    Fuel
      #table(columns:(1fr, 1fr, 1fr), stroke: 0.5pt, rows: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
      fill: (x, y) =>
        if y == 0 { rgb("#f0f0f0") }
        else if y == 1 and x == 1 { black }
        else if y == 7 { rgb("#f0f0f0") }
        else { white },

      )[*FUEL*][*MIN*][*LITRES*][TAXI][][][TRIP\*][][][V RESERVE][][][ALTERNATE][][][F RESERVE][][][HOLDING][][][*REQUIRED*][][][MARGIN][][][ENDURANCE]]
      ]
  ]
]


#let notes-and-divert() = {
  box(height:22%)[
    #text(6pt)[
    #columns(2)[

      #text(6pt)[
        #table(columns: (1fr, 1fr), stroke: (none))[Aerodrome][#text(size: 6pt)[#table(columns: (1fr, 1fr, 1fr), inset: 0pt,
          align: horizon,
          stroke: (none),
          [Elev],
          [CTAF],
          [OTHER]
        )]][#standard-box()][
          #table(columns: (1fr, 1fr, 1fr), inset: 0pt,
          align: horizon,
          stroke: (none),
          [#standard-box()],
          [#standard-box()],
          [#standard-box()]
        )][Field Layout][Pilot Notes][#tall-box()][#tall-box()]
      ]
    Divert
    #table(columns:(1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr), 
    stroke: 0.5pt,
    fill: (x, y) =>
      if y == 0 { rgb("#f0f0f0") }
      else if y == 1 and x != 6 { black }
      else { white },

    rows: (1fr, 1fr, 1fr, 1fr))[*POSN*][*ALT*][*HDG (M)*][*DIST*][*ETI*][*EST*][*ATD*]]]
  ]
}

#let table-json(data) = {
    let keys = data.at(0).keys()
    table(
      columns: keys.len(),
      ..keys,
      ..data.map(
        row => keys.map(
          key => [
            #if key == "Image" { image(row.at(key), width: 50%) } else { row.at(key) }            
          ]
        )
      ).flatten()
    )
}

#let aero-navigator(callsign: "", type: "", departure: "", waypoint: false, waypoints: "", notes: false, doc) = [
  #set text(font: "DejaVu Sans Mono", size: 9pt)

  #set page(
    paper: "a5",
    margin: (top: 0.30in, bottom: 0.1in, left: 0.1in, right: 0.1in),
    footer: [
      
    ],
    number-align: center
  )
  Nav Log
  #header(callsign, type, departure)
  // TODO - use JSON to add waypoints to table
  #nav-log([])
  #fuel-com-log
  #notes-and-divert()
  #if notes == true {
      box(height: 95%)[
        #text(6pt)[
        Pilot Notes
        #table(columns:(1fr),
          stroke: 0.5pt,
          rows: (1fr))
        ]
    ]
  }
  
  #if waypoint == true and waypoints != "" {
    box(height: 100%)[
      #table-json(json(waypoints))
    ]
  }
]