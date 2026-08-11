#import "@preview/lion-ecl:0.1.0": *
#show: project.with(
  titre: "Rapport",
  subtitle :"Sous titre",
  auteurs: ("Le Lion"),
  mentors : ("Ecully","Bob"),
)

#heading(numbering:none)[Introduction]

On en a marre du temps de compilation infini du LateX, vive le typst, en plus la syntaxe est très facile

= Les bases du typst

On peut écrire en *gras* ou en _italique_ comme ça.

Pour faire des listes il y a le choix : 
+ comme ça
+ aussi
  + sous liste
  + et là
+ et retour ici

- liste sans numéro
- hop

On peut aussi faire des listes avec des termes : 

/ FLE : truc pas marrant
/ STR : truc marrant

Pour mettre des guillemets "c'est" 'basique' 

//un commentaire sur une ligne

/*
et un commentaire
sur plusieurs
lignes
*/

== Utiliser les identifiants

Supposons qu'on ait une équation super chiante à recopier

$ i planck (d Psi(t))/(d t)  = hat(H) Psi(t) $

On peut lui mettre un identifiant : 

#let schrod = [$ i planck (d Psi(t))/(d t)  = hat(H) Psi(t) $]

et l'appeler par #schrod

et ça marche avec n'importe quel type d'objet typst : texte, equation, figure, bloc de code, fonction...
== Insérer une figure <soustitre1>

On peut insérer une figure avec cette commande
#figure(
  image("images/motif.png", width: 70%), 
  caption: [Le motif de l'ECL] 
)<figure1>

Et ensuite la référencer avec @figure1, en ayant pris soin d'ajouter un label après `#figure()<label>`

On peut aussi référencer le titre de cette partie @soustitre1 

Une image peut être en 3 modes :

#box(width: 300pt, height: 200pt)[
  #grid(
    columns: (1fr, 1fr, 1fr),
    gutter: 10pt,
    image("images/motif.png", width: 100%, height: 100%, fit: "cover"), // L'image déborde de l'espace mais a les bonnes proportions
    image("images/motif.png", width: 100%, height: 100%, fit: "contain"),// L'image n'occupe pas l'espace mais a les bonnes proportions
    image("images/motif.png", width: 100%, height: 100%, fit: "stretch") //L'image occupe l'espace mais n'a plus les bonnes proportions
  )
]

== Faire des maths

C'est comme en latex mais sans les `\` : 

Ici j'ai $3x = 8 alpha integral_(beta = 8)^(delta = 9) Gamma(t) d t$, mais si il y a des espaces entre les `$` et l’équation ça devient une grosse équation : 

Ici j'ai $ 3x = 8 alpha " et on ecrit au milieu " integral_(beta = 8)^(delta = 9) Gamma(t) d t $

Pour les fractions : $ 1/3 + (3x^2)/(8b + 6)$

On peut aligner des équations comme en latex :

$ 
  x &= 2 \
  8 b &= 36x^2 + 7x - 7
$

=== Vecteurs et matrices

C'est super simple 
#no-num[$ vec(1,2,3,4) = mat(1,0,0,0; 0,1,0,0; 0,0,1,0; 0,0,0,1)vec(1,2,3,4) $]

On revient à la ligne dans les matrices avec *;* et on peut désactiver la numérotation avec `#no-num[$EQUATION$]`

=== Symboles utiles

On a les ensembles usuels $ RR, NN, CC, QQ, ZZ $

Mais aussi les nombres calligraphiés 
$ cal(M), cal(A), cal(E), cal(V) $<testlabel>

On a aussi : $floor(3x + 6) ceil(9x - 1) x\/3 -> => ==> <= != $

== Citer la biblio

On peut citer @smith2024typst, cela fait apparaître la ref dans la bibliographie

== Mettre des tables

Sans grande surprise : 

#table(
  columns: (1fr, auto, auto),
  inset: 10pt,
  align: horizon,
  table.header(
    [], [*Volume*], [*Parameters*],
  ),
  [],
  $ pi h (D^2 - d^2) / 4 $,
  [
    $h$: height \
    $D$: outer radius \
    $d$: inner radius
  ],
  [],
  $ sqrt(2) / 12 a^3 $,
  [$a$: edge length]
)

== Mettre un bloc de code

Pour mettre un bloc de code, il suffit de l'encadrer comme en markdown, en ajoutant le nom du langage pour la coloration: 

```py
print("Hello World")
print("World Hello")
```

Il est possible de désactiver l'alternance des lignes blanches/grises en fond avec

```typ
#codly(zebra-fill : none)
```

On peut mettre la numérotation des lignes en dehors des blocs de code : 

```typ
#codly(number-placement : "outside") // valeur par defaut : "inside"
```

Pour empêcher un bloc de code d'être séparé sur plusieurs pages : 

```typ
#codly(breakable : false) // valeur par defaut : true
```

Pour ajouter des annotations à un bloc de code :

#codly(
  annotations: (
    (
      //L'indexation des lignes de code commence a 1
      start: 2, end: 5,
      content: block(
        width: 7em,
        align(center)[Partie principale]
      ),
    ),
  ),
)

```py
def fib(n):
  if n <= 1:
    return n
  else:
    return fib(n - 1) + fib(n - 2)
fib(25)
fib(10)
```

Pour référencer une ligne particulière, il suffit de mettre le bloc de code dans un environnement `figure`:

#figure(
)[```py
def fib(n):
  if n <= 1:
    return n
  else:
    return fib(n - 1) + fib(n - 2)
fib(25)
fib(10)
```]<bloc-de-code>

Et on peut référencer @bloc-de-code, ou bien uniquement la deuxième ligne @bloc-de-code:2

Il y a pleins d'autres options possibles, a voir dans la documentation du package *codly*


= Typst avancé

On peut faire des fonctions en typst : 

#let sum = 0
#for value in (1, 2, 3, 4, 5) {
  sum = sum + value
  [valeur = #value \ somme = #sum \ ]
}

Il y a des dictionnaires: 

#let dict = (cle : "valeur", cle2 : 3)

Récupération des valeurs :
#dict.cle
#dict.cle2

Récupération des clés :
#dict.keys()

Accès d'un élément dans un tuple :
#dict.keys().at(0)




= Utiliser le template pour un rapport de stage

== Ajouter le logo de l'entreprise
Si il n'y a pas que l'ECL mais aussi une entreprise, il est possible de mettre les 2 logos à côté, pour ça, passer un élément `image` dans le champ `company-logo` en haut du template

```typ
#show : project.with(
    ...
    company-logo : image("images/logo_company.png")
    sl-size : 60%, // Taille du logo ECL
    cl-size : 23%, // Taille du logo de l'entreprise
    ...
)
```

== Changer la date

Ajouter le champ `date` dans la déclaration du projet
```typ
#show : project.with(
    ...
    date : "12 décembre 2025"
    ...
)
```

== Ajouter un jury pour une soutenance


```typ
#show : project.with(
    ...
    jury : ("Jury 1","Jury 2"),
    defense-date : "12 décembre 2025"
    ...
)
```

== Changer les noms de base

Pour changer les "Auteurs", et "Encadrants", il faut aller dans le fichier `ressources/fr.json`

== Ajouter une table des figures ou une table des tables

Il faut ajouter 

```typ
#show : project.with(
    ...
    fig-table : true,
    tab-table : true,
    ...
)
```


#bibliography("biblio.bib", title: "Bibliographie")