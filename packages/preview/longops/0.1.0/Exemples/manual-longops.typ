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



#import "/Operations.typ"

#show heading.where(level:1): it => {pagebreak(); it}
== Fonctions pour les calculs posés "à la main" ...
#let docs = tidy.parse-module(
  read("/Operations.typ"),
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

#import "/Priorités.typ"

#tidy.show-module(docs, style: tidy.styles.default,omit-private-definitions: true,)

== Calculs détaillés et mise en avant
#let docs = tidy.parse-module(
  read("/Priorités.typ"),
  // name:"OpsM",
  scope: (Priorités: Priorités), 
  preamble: "#import Priorités: *\n",
)
#tidy.show-module(docs, style: tidy.styles.default)
