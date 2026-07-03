// === Import ===
// Libraries, modules ou paquets
#import "universe.typ": *
// Entrées du glossaire (paquet Glossarium)
#import "../Ressources/E_Lexique.typ": v-liste-glossaire

// === Déclaration de l'état global pour la langue ===
#let v-langue-global = state("langue_document", "fr")

// ╔══════════════════════════════════════╗
// ║         VARIABLES GLOBALES           ║
// ╚══════════════════════════════════════╝
// Adresse de JUNIA
#let v-adresse-junia = [JUNIA \ 2 Rue Norbert Ségard \ 59014 Lille cedex]
// Gestion de la date du rapport de manière automatique
#let v-date-du-jour = datetime.today()
#let v-mois-long = (
  January : "Janvier", February : "Février",  March :     "Mars",
  April :   "Avril",   May :      "Mai",      June :      "Juin",
  July :    "Juillet", August :   "Août",     September : "Septembre",
  October : "Octobre", November : "Novembre", December :  "Décembre"
)
// On affecte les mois français au mois anglais
#let v-mois-court = v-mois-long.at(v-date-du-jour.display("[month repr:long]"))
// Récupération du mois anglais
#let v-month-short = v-date-du-jour.display("[month repr:long]")
// Récupération de l'année
#let v-annee-court = v-date-du-jour.display("[year repr:full]")
// Liste + Dictionnaires pour les titres FR / EN
#let liste-trad-auto = (
  // Titres de partie
  sommaire_ebauche: ("fr": [Liste des notes],             "en": [List of notes]),
  sommaire:         ("fr": [Table des matières],          "en": [Table of contents]),
  sommaire_fig:     ("fr": [Table des figures],           "en": [List of figures]),
  sommaire_tab:     ("fr": [Liste des tableaux],          "en": [List of tables]),
  lexique:          ("fr": [Lexique],                     "en": [Glossary]),
  bibliographie:    ("fr": [Références Bibliographiques], "en": [Bibliography]),
  annexe:           ("fr": [Annexes],                     "en": [Appendices]),
  // Appelation (citations hors lexique et bibliographie)
  annexe_fig:       ("fr": [Annexe],                      "en": [Appendix]),
  chap_sup:         ("fr": [Chap.],                       "en": [Chap.]),
  page_app:         ("fr": [Page],                        "en": [Page]),
  delim_app:        ("fr": [sur],                         "en": [of]),
  // Filigranes
  brouillon:        ("fr": [BROUILLON],                   "en": [DRAFT]),
  secret:           ("fr": [CONFIDENTIEL],                "en": [CONFIDENTIAL]),
  // Variables (e.g Mois)
  mois_date:        ("fr": v-mois-court,                  "en": v-month-short)
)

// ╔══════════════════════════════════════╗
// ║         FONCTIONS UTILITAIRES        ║
// ╚══════════════════════════════════════╝
// == Fonction "d'aide" == (Utile pour réaliser des tâches spécifiques mais éviter un gros bout de code dans un paramètre)
// Fonction pour récupérer et afficher le titre dans l'entête de page
#let f-afficher-titre() = context {
  // On recupère la page actuelle (avec `context`) :
  let page-num = here().page()
  // On regarde si un titre de niveau 1 s'y trouve :
  let chapters-on-this-page = query(selector(heading.where(level: 1)))
    .filter(h => h.location().page() == page-num)
  // Si non alors :
  if chapters-on-this-page.len() == 0 {
    // Affichage du titre en entête à droite
    align(right, emph(hydra(1)))
    // Ligne de séparation en header (équivalent headrule)
    line(length: 100%, stroke: 0.4pt)
  }
}
// == Fonctions de mise en page des sections == (Permet la traductions automatiques des titres, impossible autrement)
// Affichage du lexique
#let f-lexique(body) = context {
  // Gestion de la traduction automatique du titre
  heading(level: 1, outlined: false)[#liste-trad-auto.at("lexique").at(v-langue-global.get())]
  print-glossary(
    v-liste-glossaire,
    show-all: false, // Mettre `true` si on veut afficher toutes les entrées
    disable-back-references: true,
  )
  // Obligatoire pour afficher le "reste" du document
  body
}
// Affichage de la table des matières
#let f-sommaire(body) = context {
  outline(
    // Gestion de la traduction automatique du titre
    title: liste-trad-auto.at("sommaire").at(v-langue-global.get()),
    depth: 3,
    indent: auto,
    target: heading.where(outlined: true).before(<end_of_main_doc>)
  )
  // Obligatoire pour afficher le "reste" du document
  body
}
// Affichage de la liste des figures
#let f-liste-figure(body) = context {
  outline(
    // Gestion de la traduction automatique du titre
    title: liste-trad-auto.at("sommaire_fig").at(v-langue-global.get()),
    target: figure.where(kind: image)
  )
  // Obligatoire pour afficher le "reste" du document
  body
}
// Affichage de la liste des tableaux
#let f-liste-tableau(body) = context {
  outline(
    // Gestion de la traduction automatique du titre
    title: liste-trad-auto.at("sommaire_tab").at(v-langue-global.get()),
    target: figure.where(kind: table)
  )
  // Obligatoire pour afficher le "reste" du document
  body
}
// Affichage de la bibliographie
#let f-bibliographie(body) = context {
  bibliography(
    (
      "../Ressources/N_Bibliographie.yml",
      "../Ressources/N_Bibliographie.bib"
    ),
    // Gestion de la traduction automatique du titre
    title: liste-trad-auto.at("bibliographie").at(v-langue-global.get()),
    full: false, // Mettre `true` si on veut afficher toutes les entrées
    style: "ieee",
  )
  // Obligatoire pour afficher le "reste" du document
  body
}
// == Fonction de "basculement" == (Passage d'une partie à une autre, on change des paramètres globaux)
// Fonction pour le passage du pré-sommaire au corps du document
#let f-corps-document(body) = context {
  // Variable pour la page
  let v-page-app = liste-trad-auto.at("page_app").at(v-langue-global.get())
  // Variable pour le délimiteur
  let v-delim-app = liste-trad-auto.at("delim_app").at(v-langue-global.get())
  // Paramétrage du pied de page
  set page(
    numbering: "1",
    header: f-afficher-titre(),
    footer: context {
      line(length: 100%, stroke: 0.4pt)
      // Gestion de la traduction automatique du délimitateur pour l'indication du nombre de page
      align(right)[
        #v-page-app #counter(page).display() #v-delim-app #counter(page).final().first()
      ]
    }
  )
  // Remise à zéro du compteur page
  counter(page).update(1)
  // Numérotation des titres (ex: 1.1)
  set heading(
    // Présence dans la table des matières
    outlined: true,
    // Appellation lors d'une citation, gestion automatique
    supplement: liste-trad-auto.at("chap_sup").at(v-langue-global.get()),
    numbering: (..nums) => {
    // On vérifie combien de niveaux on a (la longueur du tableau)
    if nums.pos().len() <= 3 {
      // Si c'est 3 ou moins, on affiche le numéro
      numbering("1.1", ..nums)
    } else {
      // Sinon on ne le numérote pas
      none
    }
  })
  // Affichage dans le sommaire principal si les listes de fig / tab apparaissent après celui-ci
  show outline: set heading(outlined: true)
  // Obligatoire pour afficher le "reste" du document
  body
}
// Fonction pour le passage du corps du document aux annexes
#let f-annexes(body) = context {
  // Génération automatique du titre et du sommaire des annexes
  outline(
    // Titre de la partie, gestion automatique
    title: liste-trad-auto.at("annexe").at(v-langue-global.get()),
    // Récupération des titres aprés le délimiteur correspondant
    target: heading.where(outlined: true).after(<end_of_main_doc>),
    indent: auto
  )
  // Délimiteur pour le document, permet de séparer les titres (Table des matières / Sommaires des annexes)
  [#[] <end_of_main_doc>]
  // Réinitialisation du compteur des titres pour le contenu, on recommence à compter de zéro
  counter(heading).update(0)
  // Paramétrages des titres
  set heading(
    // Numérotation des chapitres d'annexes en lettres (A, B, C...)
    numbering: "A.1",
    // On désactive l'affichage dans les signets du PDF
    bookmarked: false,
  )
  // Automatisation des figures d'annexes
  set figure(
    // On fixe le type
    kind: "annexe",
    // Appellation lorsque l'on cite un annexe
    supplement: liste-trad-auto.at("annexe_fig").at(v-langue-global.get()),
    // Numérotation
    numbering: "1",
    // Espacement de la légende
    gap: 1em
  )
  // Positionnement de la légende en haut de la figure
  show figure.where(kind: "annexe"): set figure.caption(position: top)
  // Alignement des figures d'annexes
  show figure.where(kind: "annexe"): it => align(horizon+center)[#it]
  // On s'assure que le compteur spécifique aux annexes démarre bien à 1
  counter(figure.where(kind: "annexe")).update(0)
  // Obligatoire pour afficher le "reste" du document
  body
}

// ╔══════════════════════════════════════╗
// ║         MODÈLE PRINCIPAL             ║
// ╚══════════════════════════════════════╝
#let modele-junia(
  // Choix de la page de garde
  generate-cover:       true,           // Génére la page de garde par défaut
  cover-pdf-path:       none,           // Si désactivé, chemin vers la page PDF

  // Paramètres de la page de garde
  type-rapport:         [],
  titre-rapport:        [],             // Utile pour les métadonnées
  confidentialite:      [],
  type-diplome:         [],
  professeur:           [],
  encadrant:            [],
  auteurs:              (),             // Utile pour les métadonnées
  formation:            [],
  promotion:            [],
  niveau-classe:        [],
  mois-annee:           auto,           // Affiche la date de manière automatique dans la page de garde

  // "Mode" du rapport
  ebauche:              false,          // Mode ébauche et affichage des notes
  filigrane:            false,          // Affiche le filigrane confidentiel sur le rapport

  // Paramètres du rapport
  math-num:             false,          // Permet de numéroté les équations mathématiques si besoin
  lang-doc:             "fr",           // Langue du document
  doc,                                  // Obligatoire
) = {

  // === Mise à jour de la variable global de langue ===
  // On vérifie que la langue existe, sinon on repasse en français
  if (liste-trad-auto.sommaire.keys().contains(lang-doc) == false) {lang-doc = "fr"}
  // Mise à jour de la langue global
  v-langue-global.update(lang-doc)

  // === Métadonnées PDF ===
  // Quand on ouvre pas le document mais qu'on passe simplement le curseur dessus
  set document(title: titre-rapport, author: auteurs.join(","))

  // === Gestion des filigranes ===
  let f-fond-de-page = [
    // Filigrane de confidentialité, en haut à gauche (sauf page de garde pdf)
    #if filigrane [
      #place(
        top + left,
        dx: 5mm,
        dy: 5mm,
        rect(
          stroke: rgb(255, 51, 51),
          inset: 5pt,
          text(fill: rgb(255, 51, 51), size: 0.9em, weight: "bold")[#context liste-trad-auto.at("secret").at(v-langue-global.get())]
        )
      )
    ]
    // Filigrane "BROUILLON" géant, au centre de toutes les pages (sauf page de garde pdf)
    #if ebauche [
      #place(center + horizon, rotate(45deg, text(6.5em, gray.lighten(70%))[#context liste-trad-auto.at("brouillon").at(v-langue-global.get())]))
    ]
  ]

  // === Réglages globaux ===
  // Format du document
  set page(
    paper: "a4",
    margin: auto,
    binding: auto,
  )
  // Langue du document, taille et choix de la police...
  set text(
    lang: lang-doc,
    // Les titres et espacements sont calculés selon la taille de la police (unitée : `em`)
    size: 12pt,
    // Police
    font: "New Computer Modern Sans"
  )
  // Gestion des paragraphes, espacement, justification...
  set par(
    // Justifier, toujours
    justify: true,
    // Gestion de la césure
    linebreaks: "optimized",
  )
  // Gestion des notes de bas de page
  show footnote.entry: set text(size: 0.75em)
  // = Gestion des figures =
  set figure(
    // Espacement de la légende
    gap: 1em,
  )
  // Gestion des tableaux
  show table : set text(size: 0.833em)
  show figure.where(kind: table): set figure.caption(position: top)

  // === Styles centralisés (Glossaire, Annexes & Bibliographies) ===
  // On gère la couleur lorsque l'on cite une source bibliographique ou que l'on appelle une entrée du glossaire ou un annexe avec `@`
  let v-style-des-liens = (
    glossaire: green.darken(45%),  // Glossaire
    citation:  blue.darken(45%),   // Bibliographie
    annexe:    purple.darken(45%), // Annexe
  )
  // On change automatiquement la couleur selon le type de la clé
  let f-style-link(it, kind: "default") = {
    let color = v-style-des-liens.at(kind, default: none)
    if color != none {
      text(fill: color, it)
    } else {
      it
    }
  }

  // === Glossaire & Annexes ===
  // Gestion interne du paquet "Glossarium"
  show: make-glossary
  register-glossary(v-liste-glossaire)

  // Mise en forme des références glossaire et annexes avec les couleurs définies précédemment
  show ref: it => {
    let el = it.element
    if el != none {
      // Glossaire
      if "kind" in el.fields() and el.kind == "glossarium_entry" {
        return f-style-link(it, kind: "glossaire")
      }
      // Figure de type "annexe"
      if el.func() == figure and el.kind == "annexe" {
        return f-style-link(it, kind: "annexe")
      }
    }
    // Autres
    it
  }

  // === Bibliographie ===
  // Mise en forme des entrées bibliographiques avec la couleur définie précédemment
  show cite: it => f-style-link(it, kind: "citation")

  // === Style de numérotation et taille des titres ===
  // Numérotation des figures et tableaux avec le numéro de chapitre devant la légende
  set figure(numbering: (..num) =>
    numbering("1.1", counter(heading).get().first(), num.pos().first())
  )
  // Numérotation des équations avec le numéro de chapitre avant le numéro de l'équation, activable dans les paramètres du modèle
  set math.equation(numbering: if math-num == true {
    // Si activé (`true`), on numérote
    (..num) => numbering("(1.1)", counter(heading).get().first(), num.pos().first())
  } else {
    // Sinon, on ne met pas de numérotation
    none
  })
  // Gestion de la taille et de l'espacement des titres et réinitialisation des compteurs pour les figures et équations
  show heading: it => {
    if it.level == 1 {
      // Remise à zéro des compteurs pour chaque nouveau chapitre
      counter(math.equation).update(0)
      counter(figure.where(kind: image)).update(0)
      counter(figure.where(kind: table)).update(0)
      counter(figure.where(kind: raw)).update(0)
      // On passe à la page suivante lors d'un nouveau chapitre
      pagebreak(weak: true)
      // Espace avant le titre de niveau 1
      v(1em)
    } else {
      // Espacement avant pour les autres niveaux (2 à 6)
      v(1em / it.level)
    }
    // La taille diminue avec le niveau, si 12pt pour le texte alors : 21pt, 19.2pt, 16.8pt, 15pt, 13.2pt et 12pt
    let v-taille = (1.75em, 1.6em, 1.4em, 1.25em, 1.1em, 1em).at(it.level - 1, default: 1em)
    // On affecte la liste précédente pour les tailles des titres
    set text(size: v-taille, weight: "bold")
    // Block avec le titre et éventuellement le numéro du chapitre
    block(
      // Sticky force le block a "s'accrocher" au paragraphe suivant, pas de titre orphelin
      sticky: true, {
      if it.numbering != none {
        // Si un numéro existe on l'affiche (choix d'affiche dans la fonction : `f-corps-document`)
        counter(heading).display(it.numbering)
        // Espace numérotation-titre réduit avec le niveau
        h(0.5em / it.level)
      }
      // Affichage du titre
      it.body
    })
    // Espacement après le titre
    v(0.35em / it.level)
  }

  // === Paquet : "Drafting" et mode ébauche ===
  // Configuration des notes dans la marge
  set-margin-note-defaults(
    // Attention : si ebauche est true, on veut voir les notes
    hidden: not ebauche,
    // Place les notes à droite par défaut
    side: right,
    // Définit la ligne de connexion
    stroke: (
      paint: red,
      thickness: 0.5pt,
      join: "round",
      dash: "solid",
    )
  )

  // === Paquet : Codly (gestion des blocs de codes) ===
  // Active le paquet
  show: codly-init.with()

  codly(
    // — Icônes et couleurs automatiques par langage (Python, Rust, JS…) —
    languages:        codly-languages,

    // — Numérotation des lignes —
    number-format:    it => text(fill: rgb("#aaaaaa"), size: 0.8em, str(it)),
    number-align:     end,        // Numéros alignés à droite

    // — En-tête du langage (icône + nom) —
    display-icon:     true,               // Affiche l'icône du langage
    display-name:     true,               // Affiche le nom du langage

    // — Ligne de séparation entre en-tête et code —

    header-repeat:    false,              // Ne pas répéter l'en-tête sur chaque page
    header-cell-args: (fill: rgb("#f0f0f0")),  // Fond légèrement plus foncé pour l'en-tête

    // — Smart indent : ajuste l'indentation au retour à la ligne —
    smart-indent:     true,
  )

  // ===== Page de garde =====
  if generate-cover {
    // Placement de l'image de JUNIA
    align(top,
      grid(
        columns: (1fr, 1fr, 1fr),
        row-gutter: 1em,
        [#align(left)[
          #image("../Images/Garde/JUNIA_LOGO.png")
        ]],
        [#align(center)[
          // Image du milieu
        ]],
        [#align(right)[
          // Image de droite
        ]],
        [
          #v-adresse-junia
        ],
        [],
        [
          // Adresse de l'entreprise
        ]
      )
    )
    // On affiche "Brouillon" si on se trouve en mode ébauche
    if ebauche {
      place(center + horizon, rotate(45deg, text(6.5em, gray.lighten(70%))[#context liste-trad-auto.at("brouillon").at(v-langue-global.get())]))
    }
    // Texte centré sur la page, titre et confidentialité
    place(center+horizon)[
      #type-rapport #v(0.125em)
      #text(2em, weight: "bold")[#titre-rapport] #v(0.25em)
      #text(1.1em, fill: red, weight: "bold")[#confidentialite] #v(0.75em)
      #type-diplome #v(0.5em)
      #professeur #linebreak()
      #encadrant
    ]
    // Auteurs du document, placement dynamique
    align(bottom, for k in (auteurs) { k; linebreak() })
    v(0.25em)
    // Classe/Niveau et date
    align(bottom, grid(
      columns: (1fr, 1fr, 1fr),
      row-gutter: 0.75em,
      [#formation],
      [],
      [],
      [#promotion #niveau-classe],
      [],
      [
        #align(right)[
          #context if (mois-annee == auto) {
            text()[#liste-trad-auto.at("mois_date").at(v-langue-global.get()) #v-annee-court]
          } else {text()[#mois-annee]}]
      ]
    ))
    // Nouvelle page après la page de garde
    pagebreak()
  } else if cover-pdf-path != none {
    // Page de garde depuis un PDF externe
    page(
      margin: 0pt,
      header: none,
      footer: none,
      background: image(cover-pdf-path, width: 100%, height: 100%)
    )[]
    // Les brackets vide [] assure que la page est rendu
  }

  // === Style pré-sommaire ===
  set page(
    // Numérotation en chiffres romain
    numbering: "I",
    footer: context {
      line(length: 100%, stroke: 0.4pt)
      align(right)[
        #liste-trad-auto.at("page_app").at(v-langue-global.get()) #counter(page).display("I")
      ]
    },
    background: f-fond-de-page
  )
  // On réinitialise le compteur page, sinon on compte la page de garde
  counter(page).update(1)
  // Pré-Sommaire : chapitres non numérotés
  set heading(
    // Caché dans la table des matières
    outlined: false,
    // Affiché dans les signets du PDF
    bookmarked: true,
    // Pas de numérotation
    numbering: none,
  )

  // === Liste des remarques en mode "ébauche" ===
  context if ebauche {note-outline(title: [#liste-trad-auto.at("sommaire_ebauche").at(v-langue-global.get())])}

  // === Obligatoire ===
  doc
}
