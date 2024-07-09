#import "@preview/ttt-utils:0.1.0": assignments
#import "i18n.typ": *

#let header-block(
  logo: none,
  title,
  subtitle: none,
  class,
  subject,
  date,
) = {
  date = if type(date) == datetime { date.display("[day].[month].[year]") } else { date }

  table(
    columns: (3fr, 5fr, 35mm),
    rows: (25mm, 10mm),
    inset: 0.7em,
    table.cell(align: horizon)[
      #set par(leading: 1em)
      #smallcaps(linguify("class", from: ling_db) + ":") #class \ 
      #smallcaps(linguify("subject", from: ling_db) + ":") #subject \
      #smallcaps(linguify("date", from: ling_db) + ":") #date
    ],
    table.cell(align: center + horizon)[
      
      #if logo != none {
        context {
          let size = measure(box(height: 2cm, logo))
          if ( size.width * 0.4 > size.height ) {
            grid(
              align: center,
              rows: (1fr),
              row-gutter: (8pt, 4pt),
              box(height: 0.7cm, logo),
              text(16pt, weight: 500, title),
              if subtitle != none { subtitle }
            )
          } else {
            grid(
              columns: 2,
              column-gutter: 12pt, 
              align: horizon,
              box(height: 2cm, width: calc.min(size.width, 2cm), logo),
              {
                text(16pt, strong(delta: 200,title))
                linebreak()
                if subtitle != none { subtitle }
              }
            )
          }
        }
      } else { 
        text(16pt, weight: 500, title)
          linebreak()
          if subtitle != none { subtitle } 
        }
    ],
    table.cell(rowspan: 2)[#align(top + start)[#smallcaps(linguify("grade", from: ling_db) + ":")] #context if assignments.is-solution-mode() { align(center + horizon,text(32pt, weight: 700, red, "X")) }],
    table.cell(colspan: 2)[#smallcaps(linguify("name", from: ling_db) + ":") #context if assignments.is-solution-mode() { text(red, linguify("solution", from: ling_db)) }]
  )
}

#let header-page(
  logo: none,
  title,
  subtitle: none,
  class,
  subject,
  date,
  point-field: none
) = {
  
  date = if type(date) == datetime { date.display("[day].[month].[year]") } else { date }
  
  grid(
    columns: 1fr,
    rows: (2fr,1fr,1fr),
    align: horizon,
    {
      set text(22pt)
      set align(center)

      if logo != none { place(top+end, logo) }

      grid(
        align: center,
        row-gutter: (1em),
        text(22pt, weight: 500, title),
        if subtitle != none { subtitle }
      )

    },
    grid(
        columns: (1fr, auto),
        row-gutter: 1cm,
      {
        set text(18pt)
        grid(
          columns: (auto, 6cm),
          align: (end + horizon, start + horizon),
          stroke: (x,y) => if (1 == x) { (bottom: 0.5pt)},
          inset: (x: 2pt, y: 5pt),
          row-gutter: 1em,
          column-gutter: 5pt,
          smallcaps(linguify("name", from: ling_db) + ":"), context if assignments.is-solution-mode() { text(red, linguify("solution", from: ling_db)) },
          smallcaps(linguify("class", from: ling_db) + ":"), class,
          smallcaps(linguify("date", from: ling_db) + ":"), date,
        )
      },
      [
        *#linguify("grade", from: ling_db):*
        #rect(width: 3cm, height: 3cm)[#context if assignments.is-solution-mode() { align(center + horizon,text(32pt, weight: 700, red, "X")) }]
      ]
    ),
    align(end,block[
      #set align(start)
      *#linguify("points", from: ling_db):* \
      #point-field
    ])
  )
}
