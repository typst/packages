= Exemple de listes

== Listes non ordonnées
Les listes sont créées avec le symbole `-` :

- Ceci est le premier élément
- Ceci est le deuxième élément
- Ceci est le troisième élément

== Listes ordonnées
Les énumérations sont créées avec le symbole `+` :

+ Premier élément ordonné
+ Deuxième élément ordonné
+ Troisième élément ordonné

== Listes imbriquées

Vous pouvez créer des listes imbriquées en ajoutant une indentation :

- Fruits
  - Pommes
  - Bananes
  - Oranges
- Légumes
  - Carottes
  - Brocoli
  - Épinards

== Listes mixtes

+ Étape un
+ Étape deux
  - Sous-élément A
  - Sous-élément B
+ Étape trois

== Listes de termes

Les listes de termes (similaires aux listes de définitions) utilisent `/` :

/ Terme 1: Ceci est la définition du premier terme.
/ Terme 2: Ceci est la définition du deuxième terme.
/ Typst: Un système de composition basé sur un langage de balisage.

== Listes personnalisées

#set enum(numbering: "1.a)")
+ Élément de premier niveau
  + Élément imbriqué a)
  + Élément imbriqué b)
+ Un autre élément de premier niveau

#set list(marker: [→])
- Élément avec puce personnalisée
- Un autre élément avec puce personnalisée
