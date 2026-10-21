#import "@preview/tidy:0.4.3"
#import "@preview/codly:1.3.0": *
#set text(lang:"fr")
#set raw(lang: "typ")
#let primary = teal.mix(eastern)
#show link: set text(primary)
#show: codly-init.with()
#codly(display-name: false, number-format: none, zebra-fill: none)

// #set page(
//   header: [
//     #h(1fr) #datetime.today().display()
//   ],
//   numbering: "1.",
// )

#[
  #set align(center)
  #let prop = toml("../typst.toml").package
  #text(2em, weight: "bold", primary)[longops]\
  #let subtitle = text(1.5em, prop.description)
  #subtitle

  #{//context 
    box(width: 1fr)[//measure(subtitle).width
      v#prop.version 
      #h(1fr)
      #prop.authors.join(
        ", ",
        last: " & ",
      )#h(1fr)#prop.license]
  }]

= A propos
En tant que professeur de mathématiques, j'ai parfois besoin de montrer comment poser un calcul "à la main". Je mets maintenant à disposition des fonctions que j'ai crées initialement pour moi.
J'utilisais précédemment le paquet LaTeX "xlop" et, typst étant beaucoup plus commode d'accès, j'ai voulu en faire un équivalent moi-même. Ce paquet n'est pas une traduction directe de "xlop", il a des fonctionnalités en plus et d'autres en moins, selon mes besoins. 

J'ai parfois utilisé des IA (principalement Gemini pour la partie "Priorités" ou pour ajouter aux autres fonctions des possibilités que j'avais d'abord codées moi-même pour l'une d'entre elles).

*Remerciements* : Je tiens à remercier #link("https://github.com/ObaulG")[ObaulG], la partie "durées/horaires" vient en grande partie de son travail.


#import "Ops-fr.typ"
#import "/Operations.typ"

#show heading.where(level:2): it => {pagebreak(); it}
== Fonctions pour les calculs posés "à la main" ...
#let docs = tidy.parse-module(
  read("Ops-fr.typ") + read("/Operations.typ"),
  // name:"OpsM",
  scope: (Operations: Operations), 
  preamble: "#import Operations: *\n",
)

#show: tidy.render-examples.with(
layout: (code, preview) => grid(code, preview)
)
// #set block(
//   breakable:false,
// )

#let show-example(
  ..args
) = {
  
  tidy.show-example.show-example(
    ..args,
    layout: (code, preview, ..args) => block(breakable: false, 
      tidy.show-example.default-layout-example(
        code, preview, 
        code-block: block.with(radius: 3pt, stroke: .5pt + luma(200)),
        preview-block: block.with(radius: 3pt, fill: rgb("#e4e5ea")),
        col-spacing: 5pt,
        ..args
      )
    ),
  )
}

// #tidy.show-module(
//   module,
//   style: dictionary(tidy.styles.default) + (show-example: show-example),
// )

#tidy.show-module(docs, style: dictionary(tidy.styles.default) + (show-example: show-example),omit-private-definitions: true,)

#import "/durées.typ" 
#import "durees-fr.typ" 

== Additions et soustractions de durées/horaires
#let docs = tidy.parse-module(
  read("durees-fr.typ") + read("/durées.typ"),
  // name:"OpsM",
  scope: (durées: durées), 
  preamble: "#import durées: *\n",
)
#tidy.show-module(docs, style: dictionary(tidy.styles.default) + (show-example: show-example))

#import "Prio-fr.typ"
#import "/Priorités.typ"

== Calculs détaillés et mise en avant
#let docs = tidy.parse-module(
  read("Prio-fr.typ") + read("/Priorités.typ"),
  // name:"OpsM",
  scope: (Priorités: Priorités), 
  preamble: "#import Priorités: *\n",
)
#tidy.show-module(docs, style: dictionary(tidy.styles.default) + (show-example: show-example))
