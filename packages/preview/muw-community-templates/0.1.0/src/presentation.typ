/**
 * This is a beamer template for the Medical University of Vienna
 *
 * see: https://www.meduniwien.ac.at/web/studierende/service-center/meduni-wien-vorlagen/
 */


#import "@preview/polylux:0.4.0" as polylux

// colors for MedUni Wien CD
#import "colors.typ" as muw_colors

// MedUni Wien logo in dark blue and white for the footer
#let muw-logo-white(..args) = image("./../img/MedUni-Wien-white.svg", ..args)
#let muw-logo-blue(..args) = image("./../img/MedUni-Wien.svg", ..args)
#let muw-logos = (muw-logo-blue, muw-logo-white)

// box with roundet corners (tl and br with 15%)
#let muw-box(radius: 15%, ..args) = box(radius: (top-left: radius, bottom-right: radius), clip: true, ..args)

/**
 * Footer for the presentation
 *
 * on the left bottom side is the logo (depending on the footer color in dark blue or white)
 *
 * the color is always dark blue (only white if the slide itself is dark blue)
 *
 * in the middle the title of the presentation and the organisation is shown
 *
 * on the right the current page number is display (if page number > 1) and
 *  optional date is being displayed
 */
#let custom-footer(
  logos: muw-logos,
  footer-title: [Titel der Präsentation ODER des Vortragenden],
  orga: [Organisationseinheit],
  show-date: false,
  page-numbering: (n, total) => { [ #strong[#n] / #total ] },
) = {
  let logos = if logos != none {logos} else {muw-logos}

  context {
    set text(fill: if page.fill != muw_colors.dunkelblau { white } else { muw_colors.dunkelblau })

    let current-margin = if page.margin == auto {
      (2.5 / 21) * calc.min(page.height, page.width)       
    } else {
      // TODO: scheint bisschen komplexer zu sein...
      0mm  // page.margin.left  .left .right .x .y oder so ...
    }

    place(bottom, dx: -current-margin)[
      #box(
        fill: if page.fill == muw_colors.dunkelblau { white } else { muw_colors.dunkelblau },
        height: 100% + 1mm,
        width: 100% + 2 * current-margin
      )[
  
        #set align(center + horizon) 
        
        #stack(dir: ltr, spacing: 1fr,
          [
            #box(inset: (x: 1mm))[
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
            #if here().page() > 1 {
              set text(size: 15pt)
              set align(right)
              box(inset: (x: 4mm))[
                #stack(
                  dir: ttb, spacing: 3mm,
                  if show-date == true {
                    text(size: 10pt)[#datetime.today().display("[day]. [month repr:short] [year]")]
                  },
                  [
                    #page-numbering(counter(page).at(here()).first(), counter(page).final().first())
                  ]
                ) 
              ]                          
            }
          ],
        )    
      ]
    ]
  }
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
  toc: false,
  show-date: true,
  logos: none,

  // page-numbering: (n, total) => { [ #strong[#n] / #total ] },
  
  // if you want to be fancy
  //  display the page number as a fraction in %
  page-numbering: (n, total) => {[
      #calc.round(
        eval(
          str(counter(page).at(here()).first()) + "/" +
          str(counter(page).final().first()) + "* 100"
        ),
        digits: 3
      )%
  ]},

  body

) = {
  set page(
    paper: paper,
    footer: custom-footer(
      logos: logos,
      footer-title: series,
      orga: orga,
      show-date: show-date,
      page-numbering: page-numbering
    )
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

  // show toc if param is set
  if toc == true{
    slide()[
      #outline()
    ]
  }
  
  body
}
