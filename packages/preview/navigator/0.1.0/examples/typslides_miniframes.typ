#import "@preview/typslides:1.3.2" as ts
#import ts: *
#import "../lib.typ" as navigator

// --- CONFIGURATION ---
#show: typslides.with(
  ratio: "16-9",
  theme: "bluey",
  show-progress: false,
)

// Define colors for the navigation bar
#let primary = rgb("#1a5fb4")

// State to control bar visibility
#let show-nav-bar = state("show-nav-bar", false)

// --- REDÉFINITION AUTOMATISÉE DES FONCTIONS TYPSLIDES ---

// 1. title-slide : Masque la barre, pas de dot (Transition)
#let title-slide(body) = {
  show-nav-bar.update(false)
  ts.title-slide(body)
}

// 2. slide : Affiche la barre + émet un dot (Contenu)
#let slide(title: none, ..args) = {
  ts.slide(title: title, ..args.named(), [
    #show-nav-bar.update(true)
    #metadata((t: "ContentSlide"))
    #args.pos().sum(default: none)
  ])
}

// 3. focus-slide : Affiche la barre + émet un dot (Contenu spécial)
#let focus-slide(body) = {
  ts.focus-slide([
    #show-nav-bar.update(true)
    #metadata((t: "ContentSlide"))
    #body
  ])
}

// --- RENDU DU HEADER/FOOTER ---

#set page(footer: context {
  if show-nav-bar.get() {
    let selector = metadata.where(value: (t: "ContentSlide"))
    let struct = navigator.get-structure(slide-selector: selector)
    let current = navigator.get-current-logical-slide-number(slide-selector: selector)
    
    block(width: 100%, inset: (bottom: 1em, x: 2em))[
      #navigator.render-miniframes(
        struct, 
        current, 
        fill: none, 
        text-color: black,
        active-color: primary,
        inactive-color: gray.lighten(50%),
        style: "compact",
        show-level1-titles: true,
        line-spacing: 10pt,
        navigation-pos: "bottom",
      )
    ]
  }
})

// --- PRESENTATION CONTENT ---

#front-slide(
  title: [Typslides + Navigator],
  subtitle: [Consistent Aesthetic Integration],
  authors: "David Hajage",
)

// On utilise maintenant #title-slide pour les transitions
#title-slide[ Introduction ]

#slide(title: [ Minimalism ])[
  #lorem(40)
]

#slide(title: [ Robustness ])[
  #lorem(40)
]

#title-slide[ Features ]

#slide(title: [ Automation ])[
  #lorem(40)
]

#title-slide[ Conclusion ]

#focus-slide[
  #lorem(4)
]