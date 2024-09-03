#import "@local/rapide-tp:0.1.0": *

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
  "L3 MIAGE - Base de données",
  date: "05/09/2024",
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
#code_block(code: "print('Hello, World!')", language: "py", title: "HelloWorld en Python")

#question("Une question sans numéro !", counter: false)
#code_block(file-path: "assets/example.sql") 
#remarque("Détecte automatiquement le language utilisé avec l'extension du fichier : ")
#code_block(file-path: "assets/main.py", title: "Code Python")

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

