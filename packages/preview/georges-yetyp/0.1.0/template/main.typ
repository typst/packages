#import "@preview/georges-yetyp:0.1.0": rapport

#show: rapport.with(
  nom: "Georgette Lacourgette",
  titre: "Titre du stage",
  entreprise: (
    nom: "Nom de l'entreprise",
    adresse: [
      12 rue de la Chartreuse, \
      38000 Grenoble, \
      France
    ],
    logo: image("logo.png", height: 4em),
  ),
  responsable: (
    nom: "Jean Dupont",
    fonction: "CTO",
    téléphone: "+33 6 66 66 66 66",
    email: "jean@dupont.fr"
  ),
  tuteur: (
    nom: "Marie Dumoulin",
    téléphone: "+33 6 66 66 66 66",
    email: "marie@dumoulin.org"
  ),
  référent: (
    nom: "Dominique Dupré",
    téléphone: "+33 6 66 66 66 66",
    email: "dominique@dupre.fr"
  ),
  résumé: [
    #lorem(100)

    #lorem(20)
  ],
  glossaire: [
    / Georges : Prénom de la mascotte de l'école.
  ]
)

= Introduction

== Présentation de l'entreprise

#lorem(30)

#lorem(50)

#figure(
  image("logo.png"),
  caption: [Le logo de l'entreprise]
)

#lorem(100)
 
== Mes missions

#lorem(50)

#figure(
  ```rust
  fn main() {
      println!("Hello world!");
  }
  ```,
  caption: [Le fameux programme "Hello world"]
)

#lorem(130)