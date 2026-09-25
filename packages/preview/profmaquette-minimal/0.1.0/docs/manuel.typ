// Manuel du paquet profmaquette-minimal.

#import "@preview/profmaquette-minimal:0.1.0" as paquet
#import "@preview/gentle-clues:1.3.1": info, tip, warning, code, idea

#let manifeste = toml("../typst.toml").package


// ══════════════════════════════════════════════════════════════════════════════
// OUTILS DU MANUEL
// ══════════════════════════════════════════════════════════════════════════════

// Dès qu'il y aura une illustration, je ferai en sorte d'avoir le rendu à côté
// avec `dessous: true` pour les exemples larges. Le code est écrit une seule
// fois : le rendu ne peut pas se désynchroniser de ce qu'on montre.
//
// Chaque exemple a sa propre `maquette` (numérotation, corrigés et feuille de
// route indépendants). Les sauts de page sont neutralisés : ils sont interdits
// dans un cadre (le bloc « Correction » en demande un).
//
// `hauteur` : ne montre que le haut du rendu (ex. seulement la feuille de route).
#let exemple(dessous: false, hauteur: none, texte-code) = {
  let source = code(width: 100%)[
    #text(size: 8.5pt, raw(texte-code.text, lang: "typ", block: true))
  ]
  let contenu = {
    show pagebreak: none
    set text(size: 9pt)
    eval(texte-code.text, mode: "markup", scope: dictionary(paquet))
  }
  // Rendu partiel : l'exemple est mis en page dans une grande zone (le paquet
  // mesure la place disponible), puis seul son haut est montré.
  if hauteur != none {
    contenu = box(width: 100%, height: hauteur, clip: true, block(width: 100%, height: 25cm, contenu))
  }
  let rendu = block(width: 100%, stroke: .5pt + luma(75%), radius: 4pt, inset: 10pt, contenu)
  block(breakable: false, above: 1.2em, below: 1.2em, if dessous {
    stack(spacing: 6pt, source, rendu)
  } else {
    grid(columns: (1fr, 1fr), column-gutter: 10pt, source, rendu)
  })
}

// Fiche d'un paramètre : nom, type(s) et valeur par défaut, puis description.
//   #parametre("position-corriges", ("str", "bool"), `"fin"`)[…]
#let parametre(nom, types, defaut, description) = block(
  width: 100%,
  inset: (left: 10pt, y: 4pt),
  stroke: (left: 2pt + luma(80%)),
  breakable: false,
  {
    raw(nom)
    h(6pt)
    for t in types { box(fill: luma(92%), inset: (x: 3pt, y: 1pt), radius: 2pt, text(size: 8pt, raw(t))) + h(3pt) }
    h(1fr)
    text(size: 8.5pt, fill: luma(40%))[défaut : #defaut]
    linebreak()
    description
  },
)

// Fiche paramètre "carte" (façon docs de gentle-clues) : nom, badges de type et
// valeur par défaut en en-tête, description, puis un exemple.
//   #parametre-carte("titre", ("content", "none"), `none`)[…]
#let couleurs-types = (
  content: (fond: rgb("#dbeafe"), texte: rgb("#1d4ed8")),
  "none": (fond: rgb("#fee2e2"), texte: rgb("#b91c1c")),
  bool: (fond: rgb("#ffedd5"), texte: rgb("#c2410c")),
  str: (fond: rgb("#dcfce7"), texte: rgb("#15803d")),
)
#let type-badge(t) = {
  let c = couleurs-types.at(t, default: (fond: luma(90%), texte: luma(30%)))
  box(fill: c.fond, inset: (x: 5pt, y: 2pt), radius: 3pt, text(size: 8pt, fill: c.texte, raw(t)))
}
// Signature d'une fonction en bloc de code, avec chaque `none` coloré comme le
// badge de type correspondant (pas de coloration syntaxique normale : la
// notation `type | type` n'est pas du Typst valide, donc pas mise en couleur
// par le surligneur habituel).
#let signature(texte) = {
  show raw.where(block: true): it => for (i, ligne) in it.text.split("\n").enumerate() {
    if i > 0 { linebreak() }
    for (j, morceau) in ligne.split("none").enumerate() {
      if j > 0 { text(fill: couleurs-types.at("none").texte, raw("none")) }
      raw(morceau)
    }
  }
  raw(block: true, lang: "typ", texte)
}
#let parametre-carte(nom, types, defaut, description) = block(
  width: 100%,
  fill: luma(96%),
  radius: 4pt,
  inset: 12pt,
  above: 12pt,
  below: 0pt,
  breakable: false,
  {
    text(size: 12pt, weight: "bold", raw(nom))
    h(8pt)
    // Le "none" n'est pas montré ici : il apparaît déjà dans la signature
    // (en couleur) et dans le "Défaut" ci-dessous.
    for t in types.filter(t => t != "none") { type-badge(t); h(3pt) }
    v(6pt, weak: true)
    description
    v(4pt, weak: true)
    text(size: 8.5pt, fill: luma(40%))[Défaut : #defaut]
  },
)

// ─── Historique des versions, lu dans CHANGELOG.md ───────────────────────────
// Convertit le petit sous-ensemble de Markdown utilisé dans CHANGELOG.md (titres
// `##`, listes `-` imbriquées de deux espaces, lignes de suite, `code`, **gras**)
// sans paquet supplémentaire. Le texte n'est jamais interprété comme du Typst :
// un `#`, un `$` ou un `_` du CHANGELOG s'affiche tel quel.

// Texte d'une ligne : `code` et **gras**.
#let md-en-ligne(texte) = {
  for (i, morceau) in texte.split("`").enumerate() {
    if calc.odd(i) { raw(morceau) } else {
      for (j, bout) in morceau.split("**").enumerate() {
        if calc.odd(j) { strong(bout) } else { bout }
      }
    }
  }
}

// Liste imbriquée à partir d'éléments (niveau, texte) consécutifs.
#let md-liste(elements) = {
  let base = elements.first().niveau
  let groupes = ()
  for el in elements {
    if el.niveau <= base or groupes.len() == 0 { groupes.push((texte: el.texte, enfants: ())) }
    else { groupes.at(-1).enfants.push(el) }
  }
  list(..groupes.map(g => {
    md-en-ligne(g.texte)
    if g.enfants.len() > 0 { md-liste(g.enfants) }
  }))
}

// Tout le fichier. Le titre `#` du fichier est ignoré (le manuel a le sien) ;
// chaque `## version` devient un titre de niveau `niveau`.
#let historique(source, niveau: 2) = {
  let elements = ()
  for ligne in source.split("\n") {
    let item = ligne.match(regex("^( *)[-*] (.*)$"))
    if ligne.trim() == "" { elements.push((type: "vide")) }
    else if ligne.starts-with("# ") { }
    else if ligne.starts-with("## ") { elements.push((type: "titre", texte: ligne.slice(3).trim())) }
    else if item != none {
      elements.push((type: "item", niveau: calc.quo(item.captures.at(0).len(), 2), texte: item.captures.at(1)))
    } else if elements.len() > 0 and elements.last().type in ("item", "texte") {
      elements.at(-1).texte += " " + ligne.trim()
    } else { elements.push((type: "texte", texte: ligne.trim())) }
  }
  let tampon = ()
  for el in elements + ((type: "vide"),) {
    if el.type == "item" { tampon.push(el); continue }
    if tampon.len() > 0 { md-liste(tampon); tampon = () }
    if el.type == "titre" { heading(level: niveau, numbering: none, outlined: false, md-en-ligne(el.texte)) }
    else if el.type == "texte" { par(md-en-ligne(el.texte)) }
  }
}


// ══════════════════════════════════════════════════════════════════════════════
// MISE EN PAGE
// ══════════════════════════════════════════════════════════════════════════════

#set document(title: "Manuel de " + manifeste.name, author: manifeste.authors)
#set page(paper: "a4", margin: (x: 2cm, y: 2.2cm), numbering: "1 / 1")
#set text(lang: "fr", size: 10.5pt)
#set par(justify: true)
#set heading(numbering: "1.1", supplement: [partie])
// Couleurs des titres, dans le texte comme dans le sommaire : parties en
// crimson, sous-parties en navy.
#let couleur-partie = rgb("#DC143C")
#let couleur-sous-partie = navy
#show heading.where(level: 1): set text(fill: couleur-partie)
#show heading.where(level: 2): set text(fill: couleur-sous-partie)
// Renvois (« partie 7 », « partie 7.1 ») dans la couleur de la partie visée.
#show ref: it => {
  let cible = it.element
  if cible != none and cible.func() == heading {
    text(fill: if cible.level == 1 { couleur-partie } else { couleur-sous-partie }, it)
  } else { it }
}
#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  v(1em)
  it
  v(.5em)
}
#show raw.where(block: false): box.with(fill: luma(94%), inset: (x: 2pt), outset: (y: 2pt), radius: 2pt)


// ══════════════════════════════════════════════════════════════════════════════
// PAGE DE TITRE
// ══════════════════════════════════════════════════════════════════════════════

#align(center)[
  #v(3cm)
  #text(size: 26pt, weight: "bold", manifeste.name)
  #v(.3em)
  #text(size: 12pt)[version #manifeste.version]
  #v(1em)
  #text(size: 13pt)[Fiches d'exercices à la manière de ProfMaquette]
  #v(.5em)
  #manifeste.authors.join(", ")
  #v(2cm)
]

#block(inset: (x: 1.5cm))[
  #manifeste.name sert à composer des fiches d'exercices avec Typst : on écrit les énoncés et leurs corrigés au même endroit dans l'éditeur de texte, et le paquet (à l'aide des options) se charge de tout le reste. En résumé :

  - les exercices sont numérotés automatiquement via l'ordre d'apparition dans le code ;

  - on peut choisir si un exercice est *sur la route* ou non ;

  - une *feuille de route* montre à l'élève le parcours de la fiche : les
    exercices sur la route, les autres et les étapes à faire valider ;
  - un *entraînement en ligne* s'ouvre d'un clic sur l'exercice, et son QR code
    est regroupé en fin de fiche ;
  - les *corrigés* s'affichent sous chaque énoncé, en fin de fiche ou pas du
    tout, et l'on choisit lesquels, d'un seul réglage.

  Le même fichier donne ainsi la fiche élève et la fiche corrigée. Le paquet
  s'adresse d'abord aux enseignants, en particulier de mathématiques.
]

#v(1fr)
#info(title: "Un portage partiel de ProfMaquette")[
  #manifeste.name s'inspire directement du package LaTeX
  https://ctan.org/pkg/profmaquette de *Christophe
  Poulain*, dont il ne reprend qu'une petite partie. Il a d'abord été écrit pour
  un usage personnel et pourra évoluer, y compris de façon incompatible entre
  deux versions `0.x`.
]

#pagebreak()
// Sommaire : chaque ligne est un lien vers sa section (comme les signets du
// PDF), dans les couleurs des titres.
#{
  show outline.entry.where(level: 1): set text(fill: couleur-partie, weight: "bold")
  show outline.entry.where(level: 2): set text(fill: couleur-sous-partie)
  outline(depth: 2)
}


// ══════════════════════════════════════════════════════════════════════════════
// 1. DÉMARRER
// ══════════════════════════════════════════════════════════════════════════════

= Démarrer

== Importer le paquet et imports 

#raw(block: true, lang: "typ", "#import \"@preview/" + manifeste.name + ":" + manifeste.version + "\": *")

Dans la suite du manuel, cette ligne est sous-entendue au début de chaque
exemple.

#info(title: "Paquets importés")[
  Les icônes du paquet (haltère, clé, coche, calculatrice) sont fournies avec lui.
  Aucune autre icône n'est incluse, et elles proviennent toutes de la web app
  Typst. Les paquets importés par Typst sont les suivants :
  - tiaoma (pour la gestion des QR-Code)
]

== Fonctionnement d'une "maquette"

#idea(title: "Le principe")[
  Toute la fiche d'exercices se place dans une `maquette`. Les réglages de cette maquette déterminent entièrement le fonctionnement de la maquette tout le long du document. Nous détaillerons tous les réglages possibles le moment venu, mais voyons des exemples simples.
]

#exemple(```typ
#maquette[
  #exercice(titre: "Factoriser")[
    Factoriser $x^2 - 9$.
  ]
  #corrige[$(x - 3)(x + 3)$] 
]
```)

Expliquons quand même le rendu qu'on obtient à droite. Par défaut, les corrigés sont regroupés dans un bloc « Correction » qui se situe en fin de
fiche et sur une nouvelle page. La clé de couleur rouge sert d'indicateur pour signifier que l'exercice est corrigé au sein même de la fiche. 

#info(title: "Comment lire un exemple dans cette documentation ?")[
  Tout le long de la documentation, un exemple illustrant le propos aura toujours la même structure : le code à gauche (dans un encadré "Code") et le rendu à droite. Pour des questions de place, on a "collé" la nouvelle page de Correction à celle des exercices.
]

#tip(title: "Deux manières d'écrire une maquette")[
  `#show: maquette.with(…)` en tête de fichier a le même effet que
  `#maquette(…)[…]` autour de toute la fiche. Cette équivalence est rappelée à différents endroits de la documentation
]


#exemple(```typ
#show: maquette.with()
  #exercice(titre: "Factoriser")[
    Factoriser $x^2 - 9$.
  ]
  #corrige[$(x - 3)(x + 3)$] 
```)

== Les fonctions du paquet

Quasiment tout passe par `maquette(…)` ou par `exercice(…)`. Les réglages de `maquette(…)` s'appliquent pour toute la fiche, alors que ceux d'`exercice(…)` s'appliquent localement (c'est-à-dire uniquement sur l'exercice en question). \
Les paramètres à régler sont regroupés dans les différentes sections. \
Le paquet n'expose que ces cinq fonctions.
#table(
  columns: (auto, 1fr),
  stroke: none,
  inset: (x: 6pt, y: 4pt),
  table.hline(stroke: .6pt),
  table.header[*Fonction*][*Rôle*],
  table.hline(stroke: .4pt),
  `maquette`, [englobe la fiche et regroupe tous les réglages],
  `exercice`, [un énoncé numéroté (@exercices)],
  `corrige`, [le corrigé de l'exercice qui précède (@corriges)],
  `thematique`, [le titre d'une thématique, qui place une coche sur la feuille de route (@fdr)],
  `afficher-fdr`, [le schéma de la feuille de route (@fdr)],
  table.hline(stroke: .6pt),
)


// ══════════════════════════════════════════════════════════════════════════════
// 2. MODE MAQUETTE
// ══════════════════════════════════════════════════════════════════════════════

= Mode maquette <mode-maquette>

Le paquet permet de définir un `mode` à la maquette, et on peut appliquer des paramètres qui influent sur ces modes. 

#signature("maquette(
  …
  mode-maquette: str,
  titre-maquette: dictionary,
  style-maquette: str,
  couleur-titre: color | auto,
  …
) -> content")


#parametre-carte("mode-maquette", ("str",), `"exercices"`)[
  Pour le moment, il n'y a que deux modes à la maquette : `exercices` et `interro`. Le mode interro ajoute juste Nom / Prénom / Classe à compléter à la main, comme les évaluations de
  ProfMaquette (clé IE).
]
#exemple(dessous: true, ```typ
#show: maquette.with(
  mode-maquette: "interro",
  titre-maquette: (
    gauche: "CH 02",
    centre: "Suites numériques",
    droite: "",
  ),
)
#exercice(titre: "Premiers termes")[
  Calculer $u_1$ et $u_2$.
]
```)

Sans `titre-maquette`, le mode "interro" affiche quand même la zone Nom /
Prénom / Classe, en pleine largeur :

#exemple(dessous: true, ```typ
#show: maquette.with(mode-maquette: "interro")
#exercice(titre: "Premiers termes")[
  Calculer $u_1$ et $u_2$.
]
```)

#parametre-carte("titre-maquette", ("dictionary",), `(:)`)[
  Ce paramètre permet de régler le titre de la maquette. C'est un dictionnaire avec les clés facultatives
  `gauche`, `centre` et `droite`. Rien n'est affiché si aucune des trois n'est
  donnée, sauf en mode `interro` (ci-dessus), où la zone Nom / Prénom /
  Classe reste affichée. Par défaut, rien n'est affiché et cet usage laisse la possibilité à l'utilisateur d'utiliser son propre template.
]

#exemple(```typ
#show: maquette.with(
  titre-maquette: (
    gauche: "CH 02",
    centre: "Suites numériques",
    droite: "coucou",
  ),
)
#exercice(titre: "Premiers termes")[
  Calculer $u_1$ et $u_2$.
]
```)

#exemple(```typ
#show: maquette.with()
#exercice(titre: "Premiers termes")[
  Calculer $u_1$ et $u_2$.
]
```)


#parametre-carte("style-maquette", ("str",), `"onglet"`)[
  Présentation du cartouche de titre. `onglet` est le seul style pour
  l'instant (donc la valeur par défaut). Il est inspiré du thème
  « pretty » du paquet Typst bookly (fonction `pretty-part` de son code
  source).
]

#parametre-carte("couleur-titre", ("color", "auto"), `auto`)[
  Couleur d'accent du cartouche de titre.
]
#exemple(```typ
#show: maquette.with(
  titre-maquette: (
    gauche: "CH 07",
    centre: "Espaces de Banach", 
  ),
  couleur-titre: rgb("#1B3A6B"),
)
#exercice(titre: "Premiers termes")[
  Calculer $u_1$ et $u_2$.
]
```)

#tip(title: "Une clé du cartouche peut manquer")[
  `gauche`, `centre` et `droite` sont toutes facultatives comme le montrent les exemples précédents. 
]


// ══════════════════════════════════════════════════════════════════════════════
// 3. EXERCICES
// ══════════════════════════════════════════════════════════════════════════════

= Les exercices <exercices>

Un exercice s'écrit `#exercice(…)[…]`, avec entre parenthèses les paramètres de l'exercice et entre crochets le contenu de l'exercice. \
L'énoncé est encadré et
numéroté automatiquement, à partir de 1 dans chaque maquette. L'énoncé peut
contenir n'importe quel contenu Typst : formules, listes, figures, tableaux.

== Paramètres des exercices

On note ci-dessous, après "paramètre:" les types que peut valoir le paramètre.
#signature("exercice(
  calculatrice: bool,
  entrainement: str | none,
  route: bool,
  pas-corrige: bool,
  source: content | none,
  stop: bool,
  titre: content | none,
  titre-complement: content | none,
  body,
) -> content")




#parametre-carte("calculatrice", ("bool",), `true`)[
  Sur `false`, une icône de calculatrice barrée apparaît dans le titre de
  l'exercice, pour signaler qu'elle est interdite. Sur `true` (défaut), rien
  ne s'affiche.
]
#exemple(```typ
#maquette[
  #exercice[Calculatrice autorisée.]
  #exercice(calculatrice: false)[Calculatrice interdite.]
]
```)

#parametre-carte("entrainement", ("str", "none"), `none`)[
  Ce paramètre permet de mettre l'adresse d'un lien en ligne et génère automatiquement un QR-Code à la fin de la page d'exercices (non modifiable). Également, cela ajoute une haltère sur le filet droit de l'exercice. \
  Cette haltère est cliquable depuis le pdf, et amène sur ledit site. Pour en savoir plus, se rendre à la @entrainements.
]
#exemple(```typ
#show: maquette.with()
#exercice(entrainement: "https://typst.app")[
  Réciter la table de 7.
]

#exercice[
  Réciter la table de 9.
]

#exercice(entrainement: "https://typst.app")[
  Réciter la table de 5.
]
```)

#idea(title: "Potentiels usages en classe")[
  J'utilise cette fonctionnalité pour travailler les automatismes, principalement avec Mathalea en glissant un lien Capytale vers l'activité. On peut l'utiliser pour sans doute mille et une autres choses (et, le cas échéant, on peut modifier le titre "Automatismes" en autre chose : voir la @entrainements). Pour l'élève/étudiant qui a sa feuille en version papier, cette haltère lui signifie qu'il y a des automatismes associés à cet exercice et il peut scanner le QR-Code en fin de feuille afin d'accéder au site. Si la feuille est donnée également en ligne, cliquer sur l'haltère suffit. Cette haltère a donc un double intérêt !]


#parametre-carte("route", ("bool",), `true`)[
  La valeur du paramètre modifie la couleur de l'entourage de l'exercice. Par défaut (`true`), la couleur du cadre est noire. Si on le met sur `false`, la couleur du cadre devient grise. \
  Également, faire passer un exercice hors route change sa position dans la feuille de route. Voir @fdr. \
  La couleur des exercices sur toute la route peut se régler une fois pour toute avec le paramètre  
  `couleur-route`. Pour plus de détails, voir @maquette
]
#exemple(```typ
#maquette[
  #exercice[Calculer $2 + 3$.]
  #exercice(route: false)[
    Calculer $2^10$.
  ]
]
```) 

#parametre-carte("pas-corrige", ("bool",), `false`)[
  Ce paramètre, s'il est réglé sur `true`, permet de ne pas afficher le corrigé d'un corrigé alors même qu'il est écrit dans un `corrige` qui le suit. Pour en savoir plus, voir la @corriges.
]
#exemple(```typ
#maquette[
  #exercice(pas-corrige: true)[Calculer $5 times 6$.]
  #corrige[Ce corrigé ne sera jamais affiché.]

  #exercice[
    Résoudre les équations de Navier-Stokes
  ]
  #corrige[
    Facile ! (from OpenAI)
  ]
]
```)

#warning(title: "Rajoute utile par rapport à ProfMaquette")[
  La gestion présentée ici des corrigés est locale, par exercice. Ayant expérimenté beaucoup, j'ai trouvé cela plutôt désagréable lorsque nos fiches sont longues (j'expliquerai le fonctionnement que j'avais plus loin dans le document). En conséquence, j'ai rajouté un paramètre global (dans les paramètres de `#maquette`) qui permet de gérer directement l'affichage des corrigés. Voir @corriges.
]
 

#parametre-carte("source", ("content", "none"), `none`)[
  Ce paramètre permet d'afficher un petit texte posé sur le filet bas de l'exercice, à droite, de la même couleur que celui de l'haltère.  
]
#exemple(```typ
#show: maquette.with()
  #exercice(source: "Manuel p. 42, n° 3")[
    Calculer $1/2 + 1/3$.
  ]
```)

#idea(title: "Potentiels usages en classe")[
  On peut très bien utiliser ce `source` pour sourcer la provenance d'un exercice (un type DNB, un type BAC, un examen...). Mon usage est différent : lorsque je mets un automatisme, j'utilise `source` pour ajouter des précisions aux élèves sur ce que j'attends d'eux dans l'automatisme. 
]

#parametre-carte("stop", ("bool",), `false`)[
  Ce paramètre permet d'arrêter la feuille de route à un endroit donné en y ajoutant une coche, juste après cet exercice. Voir @fdr pour les détails.
]
 

#exemple(```typ
#show: maquette.with()
#align(center,afficher-fdr) 
  #exercice(
    route: false,
    stop: true
  )[ 
  ]
  #exercice[ 
  ]
```)


#warning(title: "Rajoute utile par rapport à ProfMaquette")[
  La gestion des `stop` peut se faire manuellement, comme dans l'exemple ci-dessus. C'est le fonctionnement de ProfMaquette. Si vous ajoutez un `#thematique[…]` (dans le but de thématiser par thème les exercices que vous donnez dans votre fiche), alors le `stop` s'appliquera à l'endroit voulu.
]

#exemple(```typ
#show: maquette.with()
#align(center,afficher-fdr) 

#thematique[Calcul mental]
  #exercice[Calculer $9 times 7$.]

  #exercice(route: false)[
    Calculer (en posant) $1789 times 1870$.
  ]

#thematique[Anneaux d'entiers]

  #exercice[Calculer $cal(O)_(Q[sqrt(2)])$] 


```)

  
 

#parametre-carte("titre", ("content", "none"), `none`)[
  Ce paramètre permet d'afficher un titre à l'exercice  après « Exercice N : » dans l'étiquette du cadre.
]
#exemple(```typ
#show: maquette.with()
#exercice(titre: "Addition de fractions",
  calculatrice: false
)[Calculer $1/2 + 3/5$]
```)

#parametre-carte("titre-complement", ("content", "none"), `none`)[
  Ce titre permet de compléter le titre du titre du corrigé correspondant.
]
#exemple(```typ
#maquette[
  #exercice(
    titre-complement: "méthode",
    calculatrice: false
  )[Calculer $2^10$.]
  #corrige[$1024$]
]
```)

== Le cas des exercices longs

Un exercice ne se coupe jamais entre deux pages : s'il ne tient pas en bas de
la page, il passe entièrement à la page suivante. Seul un exercice plus haut
qu'une page entière se coupe, pour ne rien perdre de l'énoncé.

== Le style des cadres

Le réglage `style-exercice` de la maquette choisit l'allure des cadres, pour
toute la fiche. \
Ce n'est pas un paramètre de `#exercice`, mais étant donné qu'il impacte le rendu direct des exercices, je préfère le mettre ici en plus. Par défaut, le rendu est celui de `fond-blanc` \
Ce réglage s'applique aussi au bloc « Automatismes ». Quatre styles
existent pour le moment :



#exemple(dessous: true, ```typ

#maquette(style-exercice: "fond-blanc")[
  #exercice[HEYYY] 
  #exercice(route: false)[HEYYY] 
]

#maquette(style-exercice: "bandeau")[
  #exercice[HEYYY] 
  #exercice(route: false)[HEYYY] 
]

#maquette(style-exercice: "etiquette-encadree")[
  #exercice[HEYYY] 
  #exercice(route: false)[HEYYY] 
]
#maquette(style-exercice: "etiquette-pleine")[
  #exercice[HEYYY] 
  #exercice(route: false)[HEYYY] 
]
```)

Chaque maquette repart de l'exercice 1, d'où les numéros identiques.


// ══════════════════════════════════════════════════════════════════════════════
// 4. CORRIGÉS
// ══════════════════════════════════════════════════════════════════════════════

= Les corrigés <corriges>

Le corrigé d'un exercice s'écrit juste après lui, avec `#corrige[…]`. Cette fonction n'admet pas de paramètre, et c'est un choix voulu : les paramètres sont tous appliqués localement sur `#exercice(…)[…]` ou alors au niveau des réglages de la maquette.
Ce sont les réglages de la `maquette` qui
décident où ils s'affichent, et lesquels s'affichent.

== Paramètres des corrigés

En voici la liste, dans l'ordre alphabétique.

#signature("maquette(
  …
  liste-corriges: auto | int | str | array,
  nouvelle-page-corriges: bool,
  page-par-corrige: bool,
  position-corriges: str | bool,
  titre-corriges: content | auto,
  vers-corrige: bool,
  …
) -> content")

#parametre-carte("liste-corriges", ("auto", "int", "str", "array"), `auto`)[
  Le paramètre `liste-corriges` permet, depuis la maquette, d'afficher une liste des exercices corrigés. Voici ce qui est pris en compte :
  #table(
    columns: (auto, 1fr),
    stroke: none,
    inset: (x: 6pt, y: 3pt),
    table.hline(stroke: .6pt),
    table.header[*Valeur*][*Corrigés affichés*],
    table.hline(stroke: .4pt),
    `auto`, [tous (par défaut)],
    `4`, [celui de l'exercice 4],
    `"1-6,9,12"`, [ceux des exercices 1 à 6, 9 et 12],
    `(1, "3-5")`, [ceux des exercices 1, 3, 4 et 5],
    `"route"`, [ceux des exercices sur la route],
    `"pas-route"`, [ceux des exercices hors route],
    `()`, [aucun],
    table.hline(stroke: .6pt),
  )
]

$$

#idea(title: "Utilisation comme prof !")[
  L'intérêt de cette combinaison est la suivante : on affiche tous les corrigés lorsqu'on est en train de préparer sa fiche d'exos : on ecrit en paramètre de maquette `liste-corriges: auto`. Une fois que tout semble bon, on règle `liste-corriges` sur `()` pour imprimer un sujet seul. Ensuite, au moment de rajouter les exercices, on remet `liste-corriges` sur ce que l'on veut voir apparaître (voir plus haut), en choisissant où avec `position-corriges` (`"fin"` ou `"apres"`). 
]

#exemple(```typ
#show: maquette.with(
  position-corriges: "fin",
  liste-corriges: "1, 3-5",
)
  #exercice[Énoncé 1.]
  #corrige[Corrigé 1.]
  #exercice[Énoncé 2.]
  #corrige[Corrigé 2.]
  #exercice[Énoncé 3.]
  #corrige[Corrigé 3.]
  #exercice[Énoncé 4.]
  #corrige[Corrigé 4.]
  #exercice[Énoncé 5.]
  #corrige[Corrigé 5.]
```)


#warning(title: "Différences fondamentales entre pas-corrige et liste-corriges")[
  `liste-corriges` s'applique à la numérotation à l'instant $i$ de l'ordre des exercices. Si vous modifiez la position de deux exercices dans la fiche, alors ce ne sont pas les mêmes exercices qui sont corrigés. En comparaison, le paramètre `pas-corrige` est un paramètre de l'exercice, donc ne dépend pas de la localisation de l'exercice dans la fiche. Les usages de ces deux paramètres sont donc très différents.

   `pas-corrige: true`  l'emporte toujours sur  `liste-corriges`.
]

#exemple(```typ
#show: maquette.with(
  position-corriges: "apres",
  liste-corriges: "1-2",
)
  #exercice[Hello]
  #corrige[Corrigé 1.]
  #exercice(pas-corrige: true)[World]
  #corrige[Corrigé 2.]

```)



 

#parametre-carte("nouvelle-page-corriges", ("bool",), `true`)[
  Le bloc « Correction » commence sur une nouvelle page par défaut. Si l'on règle le paramètre sur `false`, alors il suit la
  fiche, sans saut de page.
]

#parametre-carte("page-par-corrige", ("bool",), `false`)[
  Si ce paramètre est réglé sur `true`, chaque corrigé est écrit sur une page. Chaque corrigé démarre en haut d'une page et dispose ainsi de toute la place possible. Pour une utilisation pertinente de ce paramètre, il vaut mieux que `position-corriges` soit réglée sur `fin`.
]

#parametre-carte("position-corriges", ("str", "bool"), `"fin"`)[
  Ce paramètre décide où afficher les corrigés sélectionnés : `"fin"` (bloc
  Correction en fin de fiche, sur une nouvelle page) ou `"apres"` (sous chaque
  énoncé). `true` est aussi accepté : il vaut `"fin"`. Il ne règle jamais le
  *nombre* de corrigés affichés — pour un sujet seul (aucun corrigé), utiliser
  `liste-corriges: ()` (voir plus haut) plutôt que ce paramètre.
]
#exemple(```typ
#maquette(position-corriges: "apres")[
  #exercice[Calculer $2 + 3$.]
  #corrige[$2 + 3 = 5$.]
]
```)

#exemple(```typ
#maquette(liste-corriges: ())[
  #exercice[Calculer $2 + 3$.]
  #corrige[$2 + 3 = 5$.]
]
```)

#warning(title: "Attention aux subtilités !")[
  lorsqu'on écrit `"après"` ou `"fin"`, il faut mettre des guillemets, mais pas pour `true`.
]


#parametre-carte("titre-corriges", ("content", "auto"), `auto`)[
  Ce paramètre permet de modifier le texte automatisé affiché lorsqu'un exercice corrigé est affiché.
]
#exemple(```typ
#show: maquette.with(
  position-corriges: "apres",
  titre-corriges: "Solution de l'exercice"
)
#exercice[Calculer $2 + 3$.]
#corrige[$5$.]
```)

#parametre-carte("vers-corrige", ("bool",), `true`)[
  Ce paramètre permet de faire apparaître la clé cliquable sur l'exercice lorsque le corrigé est écrit et qu'on a décidé de l'afficher. Cette clé est cliquable et mène au corrigé dans le document. En cliquant sur #text(red)[*Corrigé de l'exercice ...*], on retourne à l'exercice correspondant.
]
#exemple(```typ
#show: maquette.with(
  position-corriges: "fin",
  vers-corrige: false
)

#exercice[Calculer $2 + 3$.]

#corrige[$5$.]

```)

== Compléter un titre

#parametre-carte("titre-complement", ("content", "none"), `none`)[
  Le paramètre `titre-complement` est un paramètre de `#exercice`, mais puisqu'il impacte le rendu du corrigé, je le mets ici.  Il permet de compléter le titre du corrigé, après le ":"
]



#exemple(```typ
#show: maquette.with(
  position-corriges: "apres"
)
  #exercice(
    titre-complement: "méthode"
  )[
    Résoudre $2x = 6$.
  ]
  #corrige[On divise par 2. Il vient  $x = 3$.]
  #exercice(
    pas-corrige: true
  )[
    Résoudre $3x = 12$.
  ]
  #corrige[$x = 4$.]
```)
 

// ══════════════════════════════════════════════════════════════════════════════
// 5. FEUILLE DE ROUTE
// ══════════════════════════════════════════════════════════════════════════════

= La feuille de route <fdr>

La feuille de route montre à l'élève le parcours de la fiche. Elle reprend la
feuille de route de ProfMaquette (clé `FdR`, commande `\AfficheFdR`).

== Afficher le schéma <fdr-schema>

`#afficher-fdr` dessine le schéma de tous les exercices de la maquette. On le
place en général avant le premier exercice, centré avec
`#align(center, afficher-fdr)`.

Les exercices sont alors distingués en deux genres : il y a ceux du haut et ceux du bas. On peut leur donner le sens que l'on veut.

- Les exercices sur la route (`route: true`, défaut) forment la *route du bas* : ce sont des disques pleins, numérotés.

- Les exercices hors route (`route: false`) sont sur la *ligne du haut*, en disques blancs.
- Les disques blancs rejoignent la coche avec les disques noirs.

#exemple(```typ
#maquette[
  #align(center, afficher-fdr)
  #exercice[Énoncé 1.]
  #exercice(route: false)[
    Énoncé 2.
  ]
  #exercice[Énoncé 3.]
]
```)

#info(title: "Raccord avec ProfMaquette")[
  `afficher-fdr` est un contenu, pas une fonction : on écrit `#afficher-fdr`, et
  non `#afficher-fdr()`.
]

Le schéma ne montre que les exercices de la maquette qui le contient. Sa
couleur se règle avec `maquette(couleur-fdr: …)` (@maquette). Si la route est
plus large que la page, elle passe à la ligne entre deux thématiques.

#idea(title: "Quels usages de cette feuille de route ?")[
  Me concernant, j'utilise ces FdR pour regrouper les exercices par thématiques, puis en désignant la liste des exercices que l'on va corriger en classe comme étant ceux qui sont sur la route, et ceux qu'on ne corrigera pas en blanc, hors route. Ce fonctionnement avec le schéma laisse la liberté à l'enseignant de l'utiliser (ou pas) comme bon lui semble !
]

#pagebreak()

== Thématiques et coches <fdr-thematiques>

Une fiche se découpe souvent en thématiques : « Factoriser », « Résoudre »…
`#thematique[…]` écrit le titre d'une thématique, et *ferme la thématique
précédente* : sur la feuille de route, une coche suit son dernier exercice. Une
coche finale termine toujours la route.


#exemple(```typ
#show: maquette.with()

#align(center, afficher-fdr)

#thematique[Factoriser]
#exercice[Factoriser $9x -12$.]
#exercice(route: false)[
  Factoriser $4x^2 + 6x$.
]
#thematique[Résoudre]
#exercice[Énoncé 3.] 
```)

Le titre est en gras, en 14 pt (plus grand si le texte de la fiche dépasse
11 pt), et n'est jamais numéroté. Il est aligné à gauche, sauf avec
`#thematique(alignement: center)[…]` ou `alignement: right`. Une thématique
placée avant le premier exercice ne place pas de coche.

#info(title: "Pourquoi pas les titres Typst ?")[
  `thematique` n'est pas un `heading` : les réglages de titres du document
  (numérotation, `show heading`) ne la modifient pas, elle n'apparaît pas dans
  une table des matières, et les titres ordinaires (`=`, `==`…) n'ont aucun
  effet sur la feuille de route.
]

== Calcul des coches <fdr-coches>

Les coches découpent la route en *tronçons*. Dans chaque tronçon :

- les exercices sont numérotés dans l'ordre de la branche à laquelle ils appartiennent ; 

- la ligne du haut redescend sur la route à la coche du tronçon.

Voici l'exemple de la documentation de ProfMaquette : quatorze exercices, en
deux thématiques. Seul le schéma est montré.

#exemple(dessous: true, hauteur: 1.6cm, ```typ
#let obl = exercice[…]
#let fac = exercice(route: false)[…]
#maquette[
  #align(center, afficher-fdr)
  #thematique[Première thématique]
  #obl #obl #fac #fac #obl #obl #fac #obl   // exercices 1 à 8
  #thematique[Seconde thématique]
  #obl #obl #fac #fac #fac #fac             // exercices 9 à 14
]
```)


#tip(title: "Une coche à la main")[
  Si vous ne souhaitez pas utiliser ces thématiques, vous pouvez utiliser `stop` (voir @exercices) : `exercice(stop: true)` ajoute une coche juste après cet exercice, sans
  thématique.  
]


// ══════════════════════════════════════════════════════════════════════════════
// 6. ENTRAÎNEMENTS
// ══════════════════════════════════════════════════════════════════════════════

= Les entraînements en ligne <entrainements>

Un exercice avec `entrainement: "https://…"` porte une haltère cliquable sur son
filet droit (@exercices). Toutes les adresses de la fiche sont aussi regroupées
en QR codes dans le bloc « Automatismes », ajouté automatiquement par la
maquette : l'élève qui travaille sur papier y accède avec son téléphone. Chaque
QR code porte le numéro de son exercice, et il est lui aussi cliquable.

#info(title: "Où et de quelle couleur ?")[
  Le bloc se place en bas de la dernière page s'il reste de la place, sinon en
  bas de la page suivante. Sa couleur est
  celle des liens vers l'extérieur, `couleur-externe` (@maquette), comme l'haltère
  et la source.
]
 
#signature("maquette(
  …
  nombre-qr: int,
  taille-qr: length,
  titre-qr: content | auto,
  …
) -> content")

#parametre-carte("nombre-qr", ("int",), `3`)[
  Nombre de QR codes par ligne dans le bloc « Automatismes ».
]
#exemple(```typ
#maquette(nombre-qr: 4)[
  #exercice(entrainement: "https://typst.app")[
    Tables de multiplication.
  ]
  #exercice[Sans entraînement.]
  #exercice(entrainement: "https://ctan.org")[
    Fractions.
  ]
]
```)

#pagebreak()

#parametre-carte("taille-qr", ("length",), `2cm`)[
  Longueur du côté commun de tous les QR codes. Une adresse trop longue pour rester
  lisible à cette taille donne un QR code agrandi automatiquement.
]

#exemple(```typ
#show: maquette.with(
  taille-qr: 0.5cm,
  nombre-qr: 4)
  #exercice(entrainement: "https://typst.app")[
    Tables de multiplication.
  ]
  #exercice[
    Tables de multiplication.
  ]
  #exercice(entrainement: "https://typst.app")[
    Tables de multiplication.
  ]
  #exercice(entrainement: "https://typst.app")[
    Tables de multiplication.
  ]
  #exercice(entrainement: "https://typst.app")[
    Tables de multiplication.
  ]
```)

#parametre-carte("titre-qr", ("content", "auto"), `auto`)[
  Ce paramètre modifie le nom donné au cadre contenant les QR-Codes.
]
#exemple(```typ
#show: maquette.with(
  taille-qr: 1cm,
  titre-qr: "QR codes à scanner"
)
#exercice(entrainement: "https://typst.app")[
  Tables de multiplication. 
]
```)


// ══════════════════════════════════════════════════════════════════════════════
// 7. RÉGLAGES DE LA MAQUETTE
// ══════════════════════════════════════════════════════════════════════════════

= Réglage des couleurs de la maquette <maquette>

Tous les réglages de la fiche se donnent à `maquette`, en un seul endroit. Nous en avons déjà vu une bonne partie. \  
Il y a deux possibilités pour définir les réglages de la maquette. Soit :
```typ
#maquette(position-corriges: "fin", liste-corriges: "1-6,9,12")[
  … la fiche …
]
```

ou, sans crochets autour de toute la fiche, en tête du fichier :

```typ
#show: maquette.with(position-corriges: "fin", liste-corriges: "1-6,9,12")
```

Si vous n'utilisez qu'une seule maquette dans votre document .typ, je conseille d'utiliser la méthode avec `#show:` qui permettra une indentation de moins tout le long du document. 
 

Le paquet utilise quatre couleurs, chacune avec un rôle, modifiables
indépendamment les unes des autres.

#signature("maquette(
  …
  couleur-externe: color | auto,
  couleur-interne: color | auto,
  couleur-route: color | auto,
  couleur-fdr: color,
  …
) -> content")

#parametre-carte("couleur-externe", ("color", "auto"), `auto`)[
  Couleur de ce qui mène *hors* du document : haltère, QR codes, source.
  `auto` : `rgb("#0090C8")` (cyan foncé).
]
#exemple(```typ
#show: maquette.with(
  couleur-externe: green.darken(20%)
  )
#exercice(
  entrainement: "https://typst.app",
  source: "p. 12",
  )[Énoncé.]
```)

#parametre-carte("couleur-interne", ("color", "auto"), `auto`)[
  Ce paramètre détermine la couleur des éléments cliquables qui permettent de *naviguer* dans le document : la clé, et les titres « Corrigé de l'exercice N ». La valeur de `auto` est `rgb("#DC143C")`
  (Crimson, comme dans ProfMaquette).
]
#exemple(```typ
#show: maquette.with(
  position-corriges: "fin",
  vers-corrige: false,
  couleur-interne: purple
)

#exercice[Énoncé.]
#corrige[Corrigé.]

```)

#exemple(```typ
#show: maquette.with(
  position-corriges: "apres", 
  couleur-interne: yellow
)
#exercice[Énoncé.]
#corrige[Corrigé.]
```)
 

#parametre-carte("couleur-route", ("color", "auto"), `auto`)[
  Ce paramètre gère la couleur des exercices sur la route (filet et titre). La valeur de `auto` est noire. Les
  exercices hors route, eux, restent toujours gris.
]
#exemple(```typ
#show: maquette.with(couleur-route: green)
#exercice[Sur la route.]

```)

#parametre-carte("couleur-fdr", ("color",), `black`)[
  Ce paramètre gère la couleur du schéma de la feuille de route (@fdr).
]
#exemple(```typ
#show: maquette.with(couleur-fdr: orange)
#align(center, afficher-fdr)
#exercice[Énoncé 1.]
#exercice(route: false)[Hors route.]

```)

Toute couleur Typst convient : `blue`, `rgb("#1E90FF")`, `luma(40%)`,
`green.darken(20%)`… Une valeur qui n'est pas une couleur arrête la
compilation avec un message clair.

// ══════════════════════════════════════════════════════════════════════════════
// 8. USAGES AVANCÉS
// ══════════════════════════════════════════════════════════════════════════════

= Usages avancés <avance>

== Langue <langue>

Les mots écrits par le paquet existent en cinq langues. Avec `langue: auto`, le
paquet suit la langue du document (`#set text(lang: …)`).

#table(
  columns: 6,
  stroke: none,
  inset: (x: 5pt, y: 4pt),
  table.hline(stroke: .6pt),
  table.header[][`"fr"`][`"en"`][`"de"`][`"es"`][`"it"`],
  table.hline(stroke: .4pt),
  [Exercice], [Exercice], [Exercise], [Aufgabe], [Ejercicio], [Esercizio],
  [Correction], [Correction], [Solutions], [Lösungen], [Soluciones], [Soluzioni],
  [Automatismes], [Automatismes], [Practice], [Übungen], [Práctica], [Allenamento],
  [QR code], [Exo], [Ex.], [Aufg.], [Ej.], [Es.],
  table.hline(stroke: .6pt),
)

#exemple(```typ
#set text(lang: "de")
#maquette(position-corriges: "apres")[
  #exercice(titre: "Brüche")[
    Berechne $1/2 + 1/3$.
  ]
  #corrige[$5/6$]
]
```)
 
 
== Plusieurs fiches dans un même document <plusieurs-fiches>

Il suffit de placer les maquettes l'une après l'autre. Chaque maquette est
indépendante : elle repart de l'exercice 1, avec sa propre feuille de route, ses
propres QR codes, ses propres corrigés et ses propres couleurs. Ici, la seconde
fiche retrouve les couleurs par défaut.

#exemple(```typ
#maquette(
  position-corriges: "apres",
  couleur-interne: purple,
)[
  #exercice(titre: "Fiche A")[…]
  #corrige[Corrigé A.]
]
#maquette(position-corriges: "apres")[
  #exercice(titre: "Fiche B")[…]
  #corrige[Corrigé B.]
]
```)

#tip(title: "Les réglages vont dans la maquette")[
  Une maquette part toujours de ses propres réglages, indépendamment de ce qui
  l'entoure : ses couleurs se donnent avec ses propres paramètres
  (`#maquette(couleur-interne: …)`), jamais à part. Pour cette raison, lorsqu'on veut plusieurs maquettes, on n'utilisera pas `show: maquette.with(..)`
]
 


// ══════════════════════════════════════════════════════════════════════════════
// 9. ANNEXES
// ══════════════════════════════════════════════════════════════════════════════

= Annexes

== Correspondance avec ProfMaquette

Pour qui connaît ProfMaquette, voici l'équivalent de ses clés et commandes.

#table(
  columns: (1fr, 1fr),
  stroke: none,
  inset: (x: 6pt, y: 4pt),
  table.hline(stroke: .6pt),
  table.header[*ProfMaquette*][*#manifeste.name*],
  table.hline(stroke: .4pt),
  [environnement `Maquette`], [`maquette`],
  [clé `FdR`, `\AfficheFdR`], [`afficher-fdr`],
  [`Route`], [`route: true` (défaut)],
  [`Stop`], [`#thematique[…]` (ou `stop: true`)],
  [`AEntretenir`, zone Entrainement], [`entrainement:`, bloc Automatismes],
  [`Source`], [`source:`],
  [`Calculatrice`], [`calculatrice: false`],
  [environnement `Solution`], [`corrige`],
  [`CorrigeApres` / `CorrigeFin`], [`position-corriges: "apres"` / `"fin"`],
  [`VersSolution`], [`vers-corrige: true`],
  [`PasCorrige`], [`pas-corrige: true`],
  [`TitreSolution`, `TitreCorrige`], [`titre-complement:`, `titre-corriges:`],
  table.hline(stroke: .6pt),
)

Les types de documents de ProfMaquette,  les environnements `Reponse` ou `Indice`
n'ont pas d'équivalent.

== Ce qu'on ne peut pas faire <limites>

- *Pas de saut de page forcé dans un conteneur.* Une maquette placée dans
  `#columns(…)`, un `#block` ou une case de tableau ne peut pas laisser le
  bloc Correction (ni, avec `page-par-corrige: true`, chaque corrigé) sauter
  de page automatiquement : Typst l'interdit (« pagebreaks are not allowed
  inside of containers »). Il faut alors régler `nouvelle-page-corriges: false`
  et `page-par-corrige: false`.

- *Pas de maquette dans une maquette.* `#maquette[#maquette[…]]` arrête la
  compilation avec un message clair, de même que `#show: maquette.with()`
  utilisé deux fois dans le même document. Pour plusieurs fiches
  indépendantes, il faut les placer l'une après l'autre (@plusieurs-fiches).

- *Réglages invalides.* Une couleur qui n'en est pas une, un `style-exercice`
  ou une `position-corriges` hors des valeurs prévues, une sélection de
  corrigés mal écrite (`"3-1"`)… arrêtent la compilation avec un message
  clair plutôt que de produire un rendu silencieusement faux.

== Remerciements

Un grand merci à *Christophe Poulain*, auteur du package LaTeX
#link("https://ctan.org/pkg/profmaquette")[ProfMaquette] : #manifeste.name en
reprend la logique (exercices, feuille de route, entraînements, corrigés) et une
partie du vocabulaire. Les idées sont les siennes, et les limites de cette
adaptation sont les miennes. Pour un outil complet, utilisez ProfMaquette.

#manifeste.name utilise le paquet
#link("https://typst.app/universe/package/tiaoma")[tiaoma] pour les QR codes. Les
icônes (haltère, clé, coche, calculatrice) sont des dessins de
#link("https://fontawesome.com")[Font Awesome Free], sous licence CC BY 4.0. Ce
manuel utilise aussi le paquet
#link("https://typst.app/universe/package/gentle-clues")[gentle-clues] pour ses
encadrés.


// ══════════════════════════════════════════════════════════════════════════════
// 10. HISTORIQUE DES VERSIONS
// ══════════════════════════════════════════════════════════════════════════════

= Historique des versions

Cette section reprend le fichier `CHANGELOG.md` du paquet : elle est mise à
jour à chaque compilation du manuel.

#historique(read("../CHANGELOG.md"))
