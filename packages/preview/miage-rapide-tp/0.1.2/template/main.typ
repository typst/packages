#import "@preview/miage-rapide-tp:0.1.2": *

#show: doc => conf(
  subtitle: "Rendu TP n°1",
  authors: (
    (
      name: "NOM1 Prénom1",
    ),
    ( 
      name: "NOM2 Prénom2",
    ),
    (
      name: "NOM3 Prénom3",
    ),
    (
      name: "NOM4 Prénom4",
    ),
  ),
  toc: true,
  lang: "fr",
  font: "Satoshi",
  date: "05/09/2023",
  years: (2024, 2025),
  years-label: "Année universitaire",
  "L3 MIAGE - Base de données",
  doc
)

= Introduction
#lorem(10)

= TP

Une mini introduction pour le TP...
#question("La question 1 ?")
#remarque("Remarque personnalisée", bg-color: olive, text-color: white)

#question("Donne un exemple de code en python.")
Voici le code nécessaire pour afficher "Hello, World!" en Python :
#code-block("print('Hello, World!')", "py", title: "HelloWorld en Python")

#question("Une question sans numéro !", counter: false)
#remarque("La remarque par défaut est très sobre.")
#question("Passer du code via un fichier ?")
#code-block(read("code/main.py"), "py")
#code-block(read("code/example.sql"), "sql", title: "Classic SQL")

#question("Insérer une image ?")
#figure(
  image("assets/resultat.png", width: 50%),
)
Du texte entre les images.
#figure(
  image("assets/logo.png", width: 30%),
  caption: [
    Un exemple d'image avec une légende.
  ],
)

#question("Une autre question ?")
$ A = pi r^2 $
$ "area" = pi dot "radius"^2 $
$ cal(A) :=
    { x in RR | x "is natural" } $
#let x = 5
$ #x < 17 $

#question("Des matrices ?")
$ mat(
  1, 2, ..., 10;
  2, 2, ..., 10;
  dots.v, dots.v, dots.down, dots.v;
  10, 10, ..., 10;
) $

#question("Du code inline !")
What is ```rust fn main()``` in Rust
would be ```c int main()``` in C

#question("Un tableau ?")
#table(
  columns: (1fr, 1fr, 1fr),
  inset: 10pt,
  align: horizon,
  table.header(
    [], [*Area*], [*Parameters*],
  ),
  "Une cellule",
  $ pi h (D^2 - d^2) / 4 $,
  [
    $h$: height \
    $D$: outer radius \
    $d$: inner radius
  ],
  "Une autre cellule",
  $ sqrt(2) / 12 a^3 $,
  [$a$: edge length]
)
= Conclusion
#lorem(10)

