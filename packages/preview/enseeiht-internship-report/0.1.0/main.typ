#import "@local/enseeiht-internship-report:0.1.0": cover


#show: doc => cover(
  title: [PFE - Rapport de Stage en Entreprise],
  subtitle: [Nom du Stage],
  subject: [Sujet du Stage, consigne, etc...],
  author: (
    
      name: "Victor Marti",
      job: "DevOps",
      affiliation: "Enseeiht",
      email: "victor.marti564d@gmail.com",
      date: "17 Août 2025 - 17 Septembre 2025"
    
  ),
  tutors: (
    (
      name: "Tuteur Ecole",
      affiliation: "Enseeiht",
      email: "tuteur.ecole@toulouse-inp.fr",
    ),
    (
      name: "Tuteur Entreprise",
      affiliation: "Example",
      email: "tuteur.entreprise@example.com",
    ),
  ),
  abstract: lorem(80),
  logo-company: "asset/example.png",
  logo-school: "asset/logo_enseeiht.png",
  doc,
)
#show heading.where(level: 1): it => {
  pagebreak()
  it
}
#outline(title: [Sommaire],)

// Permet de faire des commentaires, révisions
#let c(body, fill: yellow) = {
  rect(
    fill: fill,
    inset: 8pt,
    [*#body*],
  )
}


= Remerciements

Voici comment faire des sources : kubernetes @k8s virtualbox @virtualbox
= Introduction

== Contexte et Enjeux



#bibliography("sources.yml")