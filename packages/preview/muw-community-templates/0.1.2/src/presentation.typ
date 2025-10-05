// This is a beamer template for the Medical University of Vienna

#import "@preview/polylux:0.4.0" as polylux

#import "colors.typ" as muw_colors

// MedUni Wien logo in dark blue and white for the footer
#let muw-logo-white(..args) = image("./../img/MedUni-Wien-white.svg", ..args)
#let muw-logo-blue(..args) = image("./../img/MedUni-Wien.svg", ..args)
#let muw_logos = (muw-logo-blue, muw-logo-white)

// box with roundet corners (tl and br with 15%)
#let muw-box(radius: 15%, ..args) = box(radius: (top-left: radius, bottom-right: radius), clip: true, ..args)

#let custom-footer(
  logos: muw_logos,
  footer-title: [Titel der Präsentation ODER des Vortragenden],
  orga: [Organisationseinheit],
  show-date: false,
  page-numbering: (n, total) => { [ #strong[#n] / #total ] },
) = context {
  let logos = if logos != none { logos } else { muw_logos }

  set text(fill: if page.fill != muw_colors.dunkelblau { white }
                  else { muw_colors.dunkelblau })
  
  box(
    fill: if page.fill == muw_colors.dunkelblau { white }
           else { muw_colors.dunkelblau },
    height: 100% + .3mm
  )[
    #set align(center + horizon) 
    #stack(dir: ltr, spacing: 1fr,
      [
        #box(inset: (x: 3mm))[
          #if page.fill != muw_colors.dunkelblau {
            logos.last()(height: 10mm)
          } else {
            logos.first()(height: 10mm)
          }
        ]
      ],
      [
        #{
          set align(left)
          stack(dir: ttb, spacing: 3mm,
            text(size: 10pt, footer-title),
            text(size: 12pt, weight: "semibold", orga)
          )
        }
      ],
      [ 
        #{
          set text(size: 15pt)
          set align(right)
          box(inset: (x: 4mm, y: 3mm))[
            #stack(
              dir: ttb, spacing: 3mm,
              if show-date == true {
                text(size: 10pt)[
                  #datetime.today().display("[day]. [month repr:short] [year]")
                ]
              },
              [
                #if here().page() > 1 {
                  page-numbering(
                    counter(page).at(here()).first(),
                    counter(page).final().first()
                  )
                }
              ]
            ) 
          ]                          
        }
      ],
    )    
  ]
}


// --- define slides ----------------------------------------------------------

#let slide(..args) = {
  polylux.slide(..args)
}

#let color-slide(
  bg-fill: muw_colors.coral,
  font-fill: black,
  ..args
) = {
  set page(fill: bg-fill)
  set text(fill: font-fill)
  
  polylux.slide(..args)
}

#let black-slide(
  bg-fill: black,
  font-fill: white,
  ..args
) = {
  set page(fill: bg-fill)
  set text(fill: font-fill)
  
  polylux.slide(..args)
}

#let blue-slide(
  bg-fill: muw_colors.dunkelblau,
  ..args
) = {
  set page(fill: bg-fill)
  set text(fill: white)
 
  polylux.slide(..args)
}


// --- template ---------------------------------------------------------------

#let slides(
  title: [Titel mit blauem Hintergrund],
  series: [Titel der Präsentation ODER des Vortragenden],
  klinik: [Universitätsklinik für XY],
  orga: [Organisationseinheit],

  author: [Univ. Prof. Dr. Maximilian Mustermann],
  email: none,  // link("mailto:n12345678@students.meduniwien.ac.at"),
  
  paper: "presentation-16-9",
  margin: 2cm,
  toc: false,
  show-date: true,
  logos: none,

  page-numbering: (n, total) => { [ #strong[#n] / #total ] },
  
  // page-numbering: (n, total) => {[
  //     #calc.round(
  //       eval(
  //         str(counter(page).at(here()).first()) + "/" +
  //         str(counter(page).final().first()) + "* 100"
  //       ),
  //       digits: 3
  //     )%
  // ]},

  body

) = {
  set page(
    paper: paper,
    margin: margin,

    footer: align(bottom,
      polylux.toolbox.full-width-block(
      )[
        #custom-footer(
          logos: logos,
          footer-title: series,
          orga: orga,
          show-date: show-date,
          page-numbering: page-numbering
        )  
    ]),    
  )

  set text(size: 25pt)
  show math.equation: set text(size: 25pt)
  
  // title slide
  blue-slide[
    #[
      #set align(horizon)
      
      = #title
      
      #author \
      #klinik \
      #if email != none { text(size: 10pt, email) }
    ]
  ]

  if toc == true {
    slide[
      #outline()
    ]
  }
  
  body
}
