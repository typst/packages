#import "@preview/muw-community-templates:0.1.1" as muw-presentation
#import muw-presentation: *

#set text(lang: "de")

#polylux.enable-handout-mode(false)

#let muw-logo-white(..args) = muw-box(fill: gray, figure(box([Hello], ..args)))
#let muw-logo-blue(..args) = muw-box(fill: gray, figure(box([Hallo], ..args)))
#let custom-muw-logos = (muw-logo-white, muw-logo-blue)


#show: slides.with(
  title: [Titel mit blauem Hintergrund],
  series: [Titel der Präsentation ODER des Vortragenden],
  klinik: [Universitätsklinik für XY],
  orga: [Organisationseinheit],

  author: [Univ. Prof. Dr. Maximilian Mustermann],
  email: none,  // link("mailto:n12345678@students.meduniwien.ac.at"),

  paper: "presentation-16-9",  // 4-3",
  toc: false,
  show-date: true,
  
  // if you want to use custom logs for your institute
  // for example for the Comprehensive Center for AI in Medicine (CAIM)
  logos: none, // custom-muw-logos,

  page-numbering: (current, total) => { [ #strong[#current] / #total ] },
  
  // if you want to be fancy
  //  display the page number as a fraction in %
  /* page-numbering: (current, total) => {[
    #calc.round(
      eval(
        str(current) + "/" +
        str(total) + "* 100"
      ),
      digits: 3
    )%
  ]},*/
)


// === main content ===========================================================


// Use #slide to create a slide and style it using your favourite Typst functions
#slide[
  #set align(horizon)
  = Very minimalist slides

  #lorem(10)

  #muw-box(
    height: 25mm,
    fill: muw-colors.dunkelblau,
    text(fill: white)[
      ~ Hier ist eine MedUni Wien box ... ~ \
      ~ Hier könnte auch ein bild sein ... ~
    ]
  )

]


#slide[
  == a random list

  - abc
  - def
    - ghi
    - jkl
      - mno
      - pqr
        - stu
        - vwx

]


#slide[
  == This slide changes!

  You can always see this.
  // Make use of features like #uncover, #only, and others to create dynamic content
  #polylux.uncover(2)[But this appears later!]
  
]


#black-slide[

  == Are you a radiologist or do you want to show a CT, MRI or X-ray image?


  #stack(dir: ltr, spacing: 1fr,
    [
      #v(3cm)
      use: `#black-slide[]`
    ],
    [
      #set text(size: 12pt)
     
      #figure(
        muw-box(
          stroke: 1pt + white,
          image("./img/Knie_mr.jpg", width: 30%)
        ),
        caption: [
          Magnetresonanztomographie Aufnahme eines \
          menschlichen Kniegelenks, in sagittaler Schichtung @wikipedia_mrt
        ]
      )
    ]
  )
]

#color-slide[
    #show: align.with(center + horizon)
    
    // #heading(outlined: false)[Nun eine kurze Demonstration]

    #text(size: 130pt, weight: "bold")[#v(-2cm) or use `color-slide`]
]


#color-slide(bg-fill: muw-colors.gruen)[
  hier in grün ...
]



#slide[
  == side by side text

  #polylux.toolbox.side-by-side[
    #lorem(7)
  ][
    #lorem(10)
  ][
    #lorem(5)
  ]

  #polylux.toolbox.side-by-side(gutter: 3mm, columns: (1fr, 2fr, 1fr))[
    #rect(width: 100%, stroke: none, fill: aqua)
  ][
    #rect(width: 100%, stroke: none, fill: teal)
  ][
    #rect(width: 100%, stroke: none, fill: eastern)
  ]

]


#slide[
  = https://typst.app/universe/

  if you want to present more specific things such as physical formulas, chemical equations, system-describing diagrams

  - chem: https://github.com/Typsium
  - phy: https://github.com/Leedehai/typst-physics
  - etc.

]




#slide[
  // https://typst.app/docs/reference/model/bibliography/

  #bibliography("lit.bib")
]
