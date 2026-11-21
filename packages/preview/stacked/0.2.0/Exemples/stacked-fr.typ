#import "@preview/tidy:0.4.3"
#import "@preview/codly:1.3.0": *
#set text(lang:"fr")
#set raw(lang: "typ")
#let primary = teal.mix(eastern)//rgb("239dad")
#show link: set text(primary)
// #show: codly-init.with()
// #codly(display-name: false, number-format: none, zebra-fill: none)

#[
  #set align(center)
  #let prop = toml("../typst.toml").package
  #text(2em, weight: "bold", primary,prop.name)\
  #let subtitle = text(1.5em, prop.description)
  #subtitle

  #{//context 
    box(width: 1fr)[
      v#prop.version 
      #h(1fr)
      #prop.authors.join(
        ", ",
        last: " & ",
      )
      #h(1fr)#prop.license]
  }]

= A propos
Les empilements de cubes sont apparus dans les programmes de collège en 2025, d'où ce paquet. 

Je me suis inspiré de `tikz3d-fr` (auteur : Cédric Pierquet) et d'une partie de `ProfCollege` de LaTeX (auteur : Christophe Poulain) mais l'implémentation n'en est pas une copie. J'ai utilisé l'IA (Gemini et Claude) pour les dés et la partie aléatoire de la fonction `pile`, le reste est de moi sauf la fonction `dice-face` créée par eric1102 (sur Discord), inclue ici avec son accord.

La version 2 ajoute de nombreuses fonctions pour représenter des solides (polyèdres, cônes, cylindres, sphères), leurs sections par un plan (défini soit par 3 points soit par les 4 coefficients de l'équation cartésienne), leurs patrons. Des fonctions d'aide pour avoir automatiquement les coordonnées des sommets sont définies pour certains cas classiques (pyramides, prismes et quelques polyèdres réguliers : tétraèdre, cube, octaèdre, dodécaèdre et icosaèdre). De plus une fonction globe permet d'expliquer les coordonnées géographiques/sphériques.

= Fonctions v1 : "piles" de cubes et dés

#import "premanuel-fr.typ"
#import "/PileCubes.typ"
#import "/Dés3D.typ"

// #show heading.where(level:2): it => {pagebreak(); it}

#let docs = tidy.parse-module(
  read("premanuel-fr.typ") + read("/PileCubes.typ") + read("/Dés3D.typ"),
  // name:"OpsM",
  scope: (PileCubes: PileCubes, Dés3D:Dés3D,), 
  preamble: "#import PileCubes: *\n #import Dés3D: *\n ",
)

#let show-example(
  ..args
) = {
  
  tidy.show-example.show-example(
    ..args,
    layout: (code, preview, ..args) => block(breakable: false, 
    { set align(horizon+center)
      tidy.show-example.default-layout-example(
        code, preview, 
        code-block: block.with(radius: 3pt,stroke: .5pt + luma(200),),
        preview-block: block.with(radius: 3pt, fill: rgb("#e4e5ea")),
        col-spacing: 5pt,
        ..args
      )}
    ),
  )
}

#tidy.show-module(docs, style: dictionary(tidy.styles.default) + (show-example: show-example),omit-private-definitions: true,sort-functions: none)

= Fonctions v2 pour des solides 3D (et leurs sections et patrons)

#import "premanuel2-fr.typ"
#import "/polysection.typ"
#import "/solidsection.typ"
#import "/solidunfold.typ"
#import "/solidvertices.typ"

#let docs = tidy.parse-module(
  read("premanuel2-fr.typ") + read("/polysection.typ") + read("/solidsection.typ") + read("/solidunfold.typ") + read("/solidvertices.typ"),
  scope: (PileCubes: PileCubes, Dés3D:Dés3D, polysection:polysection, solidsection:solidsection, solidunfold:solidunfold, solidvertices:solidvertices), 
  preamble: "#import polysection: *\n #import solidsection: *\n #import solidunfold: *\n #import solidvertices: *\n ",
)

#tidy.show-module(docs, style: dictionary(tidy.styles.default) + (show-example: show-example),omit-private-definitions: true,sort-functions: none)