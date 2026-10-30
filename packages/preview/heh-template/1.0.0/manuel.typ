#import "/lib.typ": (
  config, double-table, heh-config, heh-document, hint, important, info,
)

#show: heh-document.with(
  document-config-fn: config.default-document-config.with(
    title: "Documentation de HEH-Template",
    description: "Démonstration et documentation du template",
    formation: none,
    orientation: none,
    authors: (
      ("Contributeurs de HEH-Template", ""),
    ),
  ),
  print-config-fn: config.default-print-config.with(
    monochrome: "monochrome" in sys.inputs and sys.inputs.monochrome == "true",
  ),
)

= Utilisation basique

Pour utiliser le template, commencez par le télécharger dans le dossier de vos paquets locaux typst. Ici par exemple, sous `heh-template/1.0.0`. Pour respecter la charte graphique HEH, la *police utilisée est Roboto*, pensez donc à l'installer aussi.

Afin que le style sout appliqué en entier, utilisez une directive `show` globale au document:

```typst
#import "@preview/heh-template:1.0.0" : heh-document, campus, config

// Appel du template en utilisant le style du département technique (DST)
#show: heh-document.with(
  campus-config-fn: campus.dst-config,
  document-config-fn: config.default-document-config
)

= Premier titre

```

= Configuration du document

Pour modifier la configuration du document, vous devez modifier la fonction `default-document-config` avec `.with()` pour changer ses paramètres par défaut. Par exemple:

```typst
#import "@preview/heh-template:1.0.0" : heh-document, campus, config

// Appel du template en utilisant le style du département technique (DST)
#show: heh-document.with(
  campus-config-fn: campus.dst-config,
  document-config-fn: config.default-document-config.with(
    title: "Titre", // Titre du document
    description: "Description", // Description du document
    formation: "Bachelier en Informatique", // Nom de la formation
    orientation: "Orientation développement", // Orientation / sous-titre de la formation
    year: "2025 - 2026", // Année académique
    authors: ( // Liste contentn le prenom/nom des auteurs avec leur email
      ("Prenom Nom", "prenom.nom@std.heh.be"),
      ("Xy Z", "xy.z@std.heh.be"),
    ),
  )
)

// Reste du document

= Premier titre
```

= Style du document

Comme paramètre pour `campus-config-fn`, vous pouvez choisir parmi les différents départements de la HEH.

- `dst-config` : Département des sciences et technologies
- `dss-ms-config` : Département des sciences sociales (Mons)
- `dss-to-config` : Département des sciences sociales (Tournai)
- `dsee-ms-config` : Département des sciences de l'éducation et de l'enseignement (Mons)
- `dsee-to-config` : Département des sciences de l'éducation et de l'enseignement (Tournai)
- `deco-config` : Département des sciences juridiques, économiques et de gestion


= Configuration de l'impression / des pages

Les données de configuration des pages / du document se trouvent dans `print-config-fn` qui peut être modifiée de la même façon que `document-config-fn`. Par exemple:

```typst
...
#show: heh-document.with(
    ...
    print-config-fn: default-print-config.with(
      monochrome: false, // Si `true`, le document sera affiché uniquement en nuances de gris,
      monochromeimages: true, // Si `true` et que le mode monochrome est activé, transforme automatiquement toutes les images du document en nuances de gris,

      outlines: (
        config.outlines.headings,
        config.outlines.tables,
        config.outlines.images,
      ), // Une liste de dictionnaires avec 'target' comme sélecteur et 'title' pour le titre de la table.

      font: "Roboto", // Police d'écriture du document,
      lang: "fr", // Langage du document
    )
)
...
```

#important[
  Le paramètre `monochromeimages` utilise un module externe pour transformer les images en nuances de gris. La conversion peut prendre un certain temps lors de la compilation.

  Les images à convertir doivent être spécifiées avec un `path` comme ceci: `#image(path("image.png"))`
]

#hint[
  Pour définir le paramètre `monochrome` plus simplement, vous pouvez utilise `sys.inputs` et compiler le fichier avec `--input monochrome=true`

  ```typst
  ...
  monochrome: "monochrome" in sys.inputs and sys.inputs.monochrome == "true"
  ...
  ```
]

#hint[
  Pour désactiver la table des matières, vous pouvez définir la valeur de `outline` a *`none`*. Si une partie de la table des matières n'a rien a afficher (pas de tableaux, d'images, d'en-têtes, ...), elle ne s'affichera pas.
  ```typst
  outlines: none, // désactive la table des matières
  ```
]

#hint[
  Vous pouvez également importer certaines tables des matières préfaites pour vous depuis la variable `config.outlines` afin de gagner du temps et de la lisiblité sur votre document:
  - `config.outlines.headings`
  - `config.outlines.tables`
  - `config.outlines.images`
  ```typst
  outlines: (config.outlines.headings, ) // ATTENTION! La virgule est nécéssaire
  ```
]

= Configuration des pieds de page et en-têtes

Les pieds et en-têtes de page n'étant pas standards pour toute la HEH, le template propose *plusieurs styles* et vous permet de définir les vôtres facilement en modifiant les paramètres `header-style` et `footer-style` de `heh-document`. Vous pouvez également y rajouter des paramètres supplémentaires en utilisant la fonction `.with()` sur la fonction du header / footer

== Exemple de changement de footers

```typst
#import "@preview/heh-template:1.0.0" : headers, footers, ...
...
#show: heh-document.with(
    ...
    header-style: headers.year-title, // Affiche l'année académique et le titre
    header-extra-params: (),
    footer-style: footer.page-numbers.with(
      show-total: false
    ), // Affiche les numéros de pages (sans le total)
)
...

```

== Définition d'une fonction personalisée (headers / footers)

```typst
#import "@preview/heh-template:1.0.0": ..., heh-config
...
#let myheader(
  show-logo: false
) = context {
  // Accès à config.campus, config.document et config.print
  let config = heh-config.get()
}

#show: heh-document.with(
    ...
    header-style: myheader.with(show-logo: true),
)
```

== Liste des footers

- Numéros de page (@footers-no)
- Numéros de page avec indicateur de côté (@footers-no-sided)

=== Numéros de page <footers-no>

Affiche les numéros de page à droite de la page

```typst
...
footer-style: footers.page-numbers
...
```

==== Paramètres

- `show-total`: Affiche le nombre total de pages du document à coté (par défaut)

=== Numéros de page avec indicateur de coté <footers-no-sided>

Affiche les numéros de page à gauche ou à droite de la page, selon la ou elle devrait être imprimée (page de gauche => gauche, page de droite => droite)

```typst
...
footer-style: footers.page-numbers-side
...
```

==== Paramètres

- `show-total`: Affiche le nombre total de pages du document à coté (par défaut)

== Liste des headers

- Logo, année et titre @logo-year-title
- Année académique et titre @year-title

=== Logo, année et titre <logo-year-title>

Affiche le logo a gauche et l'année académique / le titre à droite

```typst
header-style: headers.logo-year-title
```

==== Paramètres `.with()`

- `bool show-year`: Affiche l'année acadamique (par défaut)
- `bool show-title`: Affiche le titre du document (par défaut)

=== Année académique et titre <year-title>

Affiche le titre et l'année académique (par défaut le titre à gauche et l'année à droite)

```typst
...
header-style: headers.year-title
...
```

==== Paramètres (`.with()`)

- `bool title-left`: Affiche le titre à gauche (par défaut)

= Modifier les configurations d'un campus

Si vous souhaitez modifier les configurations d'un campus (changer les noms, les couleurs, ...), vous pouvez utiliser les versions modifiées de `**-naming-config`, `**-style-config` et `**-contact-config`.

Voici le schéma des configurations:

```typst
(
  naming: (
    short-name: "DST",
    full-name: "Département des sciences et technologies",
    logo-title: "Sciences",
    logo-subtitle: "et technologies",
  ),
  contact: (
    address-line1: "Avenue Victor Maistriau 8a",
    address-line2: "B-7000 Mons",
    phone-nr-pretty: "+32 (0)65 33 81 54",
    phone-nr-short: "+3265338154",
    mail: "scitech-mons@heh.be",
  ),
  style: (
    decorations-color: rgb("#2f5496"),
    primary-color: rgb("#e41513"),
    onprimary-color: rgb("#ffffff"),
  ),
)
```

== Exemple: modification des noms

```typst
...
campus-config-fn: campus.dst-config.with(
    naming: campus.dst-naming-config.with(
        full-name: "Département des technologies et sciences"
    )
)
...
```

= Fonctionnalités du template

== Tableaux

Le template propose des tableaux stylysés avec les couleurs des différents campus de la HEH. Le style est appliqué par défaut pour les tableaux créés avec `#table()`

Dans le heh-template, nous avons stylisé des tableaux en thème avec les couleurs des différents campus de la heh. le style est appliqué par défault si vous faites un simple tableau `#table()`.

Par exemple:
```typ
#table(
  columns: (50pt, 1fr, 1fr),
  table.header(
    [ID], [Nom], [Email]
  ),
  [1], [John Doe], [john.doe\@std.heh.be],
  [2], [John Doe], [john.doe\@std.heh.be],
  [3], [John Doe], [john.doe\@std.heh.be],
)
```

#table(
  columns: (50pt, 1fr, 1fr),
  table.header([ID], [Nom], [Email]),
  [1], [John Doe], [john.doe\@std.heh.be],
  [2], [John Doe], [john.doe\@std.heh.be],
  [3], [John Doe], [john.doe\@std.heh.be],
)

== Tableaux double entrées

Si vous voulez utiliser des tableaux a double entrée, vous pouvez importer directement `#double-table()` depuis heh-template

```typ
#double-table(
  columns: (50pt, 1fr, 1fr),
  [], [A], [not A],
  [B], [O], [X],
  [not B], [X], [X]
)
```

#double-table(
  columns: (50pt, 1fr, 1fr),
  [],
  [A],
  [not A],
  [B],
  [O],
  [X],
  [not B],
  [X],
  [X],
)

== Tableaux personalisés

Pour l'instant, le template ne propose que des tableaux à simple et à double entrée. Si vous souhaitez pousser la modification des tableaux, vous pouvez créer vos propres fonctions:

Vous pouvez utiliser le `state` `heh-config` qui contient l'ensemble de la configuration du document

```typ
#let custom-table(
  ..args
) = context {

    let primary-color = heh-config.get().campus.style.primary-color

    show table.cell: it => {
    if(it.y <= 1 or it.x == 0) {
      set text(white, weight: "bold")
      it
    } else {
      it
    }
  }

  table(..args,     fill: (x, y) => {
    if (y <= 1 or x == 0) {
      primary-color.darken(40%)
    } else {
      primary-color.transparentize(90%)
    }
  })
}
```

Et son utilisation en pratique:

#block(breakable: false)[
  ```typ
  #custom-table(
    columns: (1fr, 1fr, 1fr, 1fr, 1fr),
    table.cell(rowspan: 2)[],
    table.cell(colspan: 2)[2025],
    table.cell(colspan: 2)[2026],
    table.cell(colspan: 2)[Quad 1],
    [Quad 2], [Quad 3],
    [Rattrapage?],
    table.cell(colspan: 2)[Non],
    [Non],
    [Oui]
  )
  ```
]
#let custom-table(
  ..args,
) = context {
  let primary-color = heh-config.get().campus.style.primary-color

  show table.cell: it => {
    if (it.y <= 1 or it.x == 0) {
      set text(white, weight: "bold")
      it
    } else {
      it
    }
  }

  table(..args, fill: (x, y) => {
      if (y <= 1 or x == 0) {
        primary-color.darken(40%)
      } else {
        primary-color.transparentize(90%)
      }
    })
}

#custom-table(
  columns: (1fr, 1fr, 1fr, 1fr, 1fr),
  table.cell(rowspan: 2)[],
  table.cell(colspan: 2)[2025],
  table.cell(colspan: 2)[2026],
  table.cell(colspan: 2)[Quad 1],
  [Quad 2],
  [Quad 3],
  [Rattrapage?],
  table.cell(colspan: 2)[Non],
  [Non],
  [Oui],
)

== Boites (information / important / ...)

Boites d'information, avertissement, d'astuces, ... pour mettre en évidence du texte

Pour les utilisez, importez les fonctions `info`, `important` ou `hint` depuis le template.

=== Exemple

```typst
#import "@preview/heh-template:1.0.0" : info, important, hint

#info[Information utile]
#hint[N'oubliez pas que vous pouvez entièrement customiser les boites d'information]
#important[N'oubliez pas de mettre à jour le template]
```

#info[Information utile]
#hint[N'oubliez pas que vous pouvez entièrement customiser les boîtes d'information]
#important[N'oubliez pas de mettre à jour le template]

=== Boites personalisées

Pour créer vos propres boites, vous pouvez simplement modifier les fonctions existantes:

```typst
#let superimportant = important.with(
  accent-color: rgb("#8B0000"),
  title: "Super important !",
)

#superimportant[Attention, il faut impérativement penser à mettre à jour le template]
```

== Présentations

HEH-Template vous permet de réaliser des présentations composées de slides avec l'aide de #link("https://polylux.dev/book", "polylux"). Pour un exemple plus complet, référez vous à `demo_presentation.typ`.

=== Utilisation basique

Les présentations sont composées de groupes de slides. Ceux ci sont créés avec la fonction `slidegroup`. Par exemple:

```typst
#import "@preview/heh-template:1.0.0": heh-presentation, slidegroup, slide

#show: heh-presentation.with(
  ... // config
  handout-mode: false // Active le mode "handout" (supprime les animations)
)


#slidegroup("Introduction")[
  #slide[
    == Titre de la slide

    Bonjour !
  ]

  #slide[
    == Titre de l'autre slide

    Hello !
  ]
]
```

Vous pouvez aussi utiliser les `uncover`, `item-by-item`, ... et les autres helpers de polylux pour faire des animations (référez vous à la #link("https://polylux.dev/book", "documentation polylux"))

