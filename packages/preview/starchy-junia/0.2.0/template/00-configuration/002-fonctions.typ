#import "000-paquets.typ": *
#import "001-variables.typ": *

/* 
Ordre de définition des types de fonctions :
  - Assistances         fa-*    | Fonction permettant d'épurer la définitions des modèles
  - Bloc de contenu     fbc-*   | Affiche des informations qui occupe une page, comme le lexique ou la bibliographie
  - Mise en page :      fmp-*   | Bascule la mise en pages complète du documents, permet d'établir des sections (pré-sommaire => corps => annexes)
  - Modèles             fm-*    | Fonction interne au modèle dans le but de réaliser une action spécifique
  - Redéfinies          fr-*    | Fonctions déjà existantes mais redéfinies suivant la vision de l'auteur du modèle
*/

// -------------------------------
// --- FONCTIONS D'ASSISTANCES ---
// -------------------------------
// Utile pour réaliser des tâches spécifiques mais éviter un gros bout de code dans un paramètre

// Fonction pour récupérer et afficher le titre dans l'entête de page
#let fa-afficher-titre() = context {
  // On recupère la page actuelle (avec `context`) :
  let page-num = here().page()
  // On regarde si un titre de niveau 1 s'y trouve :
  let chapters-on-this-page = query(selector(heading.where(level: 1))).filter(h => h.location().page() == page-num)
  // Si non alors :
  if chapters-on-this-page.len() == 0 {
    // Affichage du titre en entête à droite, on utilise le paquet `hydra` pour le faire proprement
    align(right, emph(hydra(1)))
    // Ligne de séparation en header 
    line(length: 100%, stroke: 0.4pt)
  }
}

// Gestion du filigrane de confidentialité et du mode ébauche
// Lit directement les états globaux, aucun paramètre nécessaire
#let fa-fond-de-page() = context [
  // Filigrane CONFIDENTIEL (coin supérieur gauche)
  #if v-filigrane-global.get() [
    #place(
      // Gestion de l'emplacement du filigrane
      top + left, dx: 5mm, dy: 5mm,
      rect(
        // On l'entoure avec un rectangle rouge
        stroke: rgb(255, 51, 51), inset: 5pt,
        // On change les paramètres du texte à afficher
        text(fill: rgb(255, 51, 51), size: 0.9em, weight: "bold")[
          // Affichage du texte selon la langue choisi dans le modèle
          #v-liste-trad-auto.at("secret").at(v-langue-global.get())
        ]
      )
    )
  ]
  // Filigrane BROUILLON (centre de chaque page)
  #if v-ebauche-global.get() [
    // Gestion de l'emplacement du filigrane
    #place(center + horizon,
      // On le met en diagonale
      rotate(45deg,
        // On change les paramètres du texte à afficher
        text(6.5em, gray.lighten(70%))[
          // Affichage du texte selon la langue choisi dans le modèle
          #v-liste-trad-auto.at("brouillon").at(v-langue-global.get())
        ]
      )
    )
  ]
]

// Applique la couleur de lien correspondant au type de référence
// Lit les couleurs depuis le state v-couleurs-cite-global mis à jour par le modèle
// kind accepte : "glossaire", "citation", "annexe"
#let fa-style-lien(it, kind: "default") = context {
  let couleurs = v-couleurs-cite-global.get()
  let v-style-des-liens = (
    glossaire: couleurs.at(0).darken(45%),
    citation:  couleurs.at(1).darken(45%),
    annexe:    couleurs.at(2).darken(45%),
  )
  let color = v-style-des-liens.at(kind, default: none)
  if color != none { text(fill: color, it) } else { it }
}

// -------------------------------------
// --- FONCTIONS DE BLOC DE CONTENUS ---
// -------------------------------------
// Fonctions de mise en page des sections, ou des bloc de contenus, page de garde, etc.
// Permet la traduction automatiques des titres, impossible autrement

/// Affiche le lexique (glossaire) du document,
/// pour cela on se sert du paquet #link("https://typst.app/universe/package/glossarium")[#text(fill: blue)[glossarium]].
///
/// On affiche le lexique *uniquement si des entrées ont été renseignées*, jamais
/// de section vide. Les entrées sont définies dans le fichier `E-lexique.typ`
/// (modèle complet) ou passées via `glossaire` dans les autres modèles.
/// Citer une entrée avec `@cle` pour créer un lien vers sa définition.
///
/// Utilisation avec paramètres : `#show: fbc-lexique.with(tout-lister: true)` pour
/// afficher toutes les entrées même si elles ne sont pas citées dans le document.
///
/// -> content
#let fbc-lexique(
  /// Titre de la section. Laisser vide pour la traduction automatique
  /// ("Lexique" ou "Glossary" selon `lang-doc`). -> content
  titre-utilisateur : [],
  /// `false` $->$ seules les entrées citées sont affichées. \
  /// `true`  $->$ toutes les entrées, même les non citées. -> bool
  tout-lister : false,
  body
) = context {

  // Si l'utilisateur n'a pas fourni de titre, on utilise la traduction automatique
  let titre-section = if titre-utilisateur != [] { titre-utilisateur } else { v-liste-trad-auto.at("lexique").at(v-langue-global.get()) }

  // v-glossaire-global est un état mis à jour par junia-core() au démarrage avec la liste fournie via le paramètre `glossaire` du modèle utilisé.
  // Si la liste est vide, il n'y a rien à afficher ni à enregistrer.
  let liste-clees = v-glossaire-global.get()

  // Vérification de la présence d'entrées dans la liste du glossaire
  if liste-clees.len() != 0 {

    // --- Résolution de la dépendance circulaire ---
    //   Le show ref de junia-core met à jour v-lexique-cite-global à `true` dès qu'une entrée glossarium est rencontrée lors du rendu.
    //   .final() lit la valeur de ce state après la DERNIÈRE passe de compilation.
    //   Typst compile le document plusieurs fois jusqu'à stabilité (point fixe) :
    //     - Passe 1 : v-lexique-cite-global.final() = false → lexique masqué mais les labels sont quand même dans le document (voir plus bas) 
    //                                                 → les @cle sont résolus → le state passe à true
    //     - Passe 2 : v-lexique-cite-global.final() = true → lexique affiché → plus de changement → convergence atteinte
    let a-ete-cite = v-lexique-cite-global.final()

    // On affiche la section si au moins une entrée a été citée, OU si l'utilisateur veut tout lister explicitement.
    let afficher = tout-lister or a-ete-cite
    // Affichage du titre de la section
    if afficher {
      heading(level: 1, outlined: false)[#titre-section]
    }

    // --- Appel à print-glossary ---
    // On appelle print-glossary UNE SEULE FOIS pour éviter les labels dupliqués.
    // (Deux appels créeraient deux fois les figures glossarium avec les mêmes
    // labels <__gls:cle>, ce qui provoque une erreur de compilation.)
    //
    // Pour garantir que les labels existent dans le document dès la première
    // passe (même quand la section est masquée), on détourne le rendu des
    // figures glossarium via une règle show :
    //   - Si affiché : les figures s'affichent normalement (it => it)
    //   - Si masqué  : les figures sont placées hors flux avec place(hide(it))
    //                  → invisibles à l'œil, mais présentes dans le document
    //                  → leurs labels <__gls:cle> existent et les @cle se résolvent
    show figure.where(kind: "glossarium_entry"): if afficher { it => it } else { it => place(hide(it)) }
    // Affichage des entrées lexiques à l'aide de glossarium, selon le découpage en groupes
    print-glossary(
      liste-clees, 
      show-all: tout-lister, 
      disable-back-references: true
    )
  }
  body
}
  
/// Affiche la table des matières du document.
///
/// Liste tous les titres du *corps du document* jusqu'au niveau `profondeur`. 
/// Les titres des annexes n'y apparaissent pas, ils sont exclus automatiquement via le marqueur `<end_of_main_doc>`. 
/// Les titres qui apparaissent avant la fonction `fmp-corps-document` ne sont pas affiché dans la table des matières 
///
/// Utilisation avec paramètres : `#show: fbc-sommaire.with(profondeur: 2)` pour
/// un sommaire limité aux deux premiers niveaux de titres (`=` et `==`).
///
/// -> content
#let fbc-sommaire(
  /// Titre de la section. Laisser vide pour la traduction automatique
  /// ("Table des matières" ou "Table of contents"). -> content
  titre-utilisateur : [],
  /// Niveau de titre maximum inclus. Par défaut `3` (niveaux `=`,
  /// `==`, `===`). Réduire à `2` pour un sommaire plus court. (on peut aller nativement jusque 6) -> int
  profondeur: 3,
  body
) = context {
  // Définition du titre selon le choix de l'utilisateur
  let titre-section = if (titre-utilisateur != []) {titre-utilisateur} else {v-liste-trad-auto.at("sommaire").at(v-langue-global.get())}
  
  outline(
    // Gestion de la traduction automatique du titre
    title: titre-section,
    // Niveau des titres affichés
    depth: profondeur,
    // Mise en page de la table des matières
    indent: auto,
    // Objets concerné, ici les titres "affichables" qui apparaissent avant la balise
    target: heading.where(outlined: true).before(<end_of_main_doc>)
  )
  body
}

/// Affiche la table des figures.
///
/// Liste toutes les figures image avec numéro, légende et page.
/// La section n'est générée *que si le document contient au moins une figure*, jamais de table vide.
///
/// -> content
#let fbc-liste-figure(
  /// Titre de la section. Laisser vide pour la traduction automatique
  /// ("Table des figures" ou "List of figures"). -> content
  titre-utilisateur : [],
  body
) = context {
  // Définition du titre selon le choix de l'utilisateur
  let titre-section = if (titre-utilisateur != []) {titre-utilisateur} else {v-liste-trad-auto.at("sommaire_fig").at(v-langue-global.get())}
  // On cherche à savoir s'il y a des figures dans le document, sinon on affiche pas le sommaire
  let nombre-fig = query(figure.where(kind: image)).len()
  // Test pour l'affichage du sommaire 
  if (nombre-fig != 0) {
    outline(
      // Gestion de la traduction automatique du titre
      title: titre-section,
      // Objets concerné, ici les figures de types "images"
      target: figure.where(kind: image)
    )
  } 
  body
}

/// Affiche la liste des tableaux.
///
/// Liste tous les tableaux avec numéro, légende et page.
/// La section n'est générée *que si le document contient au moins un tableau*, jamais de liste vide.
///
/// -> content
#let fbc-liste-tableau(
  /// Titre de la section. Laisser vide pour la traduction automatique
  /// ("Liste des tableaux" ou "List of tables"). -> content
  titre-utilisateur : [],
  body
) = context {
  // Définition du titre selon le choix de l'utilisateur
  let titre-section = if (titre-utilisateur != []) {titre-utilisateur} else {v-liste-trad-auto.at("sommaire_tab").at(v-langue-global.get())}
  // On cherche à savoir s'il y a des figures dans le document, sinon on affiche pas le sommaire
  let nombre-fig = query(figure.where(kind: table)).len()
  // Test pour l'affichage du sommaire 
  if (nombre-fig != 0) {
    outline(
      // Gestion de la traduction automatique du titre
      title: titre-section,
      // Objets concerné, ici les figures de types "tableau"
      target: figure.where(kind: table)
    )
  } 
  body
}

/// Affiche la bibliographie du document.
///
/// N'est affichée *que si des citations `@cle` sont présentes* dans le texte. Typst exige que `bibliography()` soit toujours appelée
/// pour résoudre les références, la section est rendue invisible via `show bibliography: it => []` quand elle est vide.
///
/// Utilisation avec paramètres : `#show: fbc-bibliographie.with(chemins-biblio: ("refs.bib",), style-biblio: "apa")`
/// pour utiliser un fichier de bibliographie personnalisé avec le style APA.
///
/// -> content
#let fbc-bibliographie(
  /// Titre de la section. Laisser vide pour la traduction automatique
  /// ("Références Bibliographiques" ou "Bibliography"). -> content
  titre-utilisateur : [],
  /// Chemins vers les fichiers `.bib` ou `.yml`. Plusieurs fichiers
  /// peuvent être combinés. Défaut : chemins de l'architecture standard.
  /// Exemple : `("ma-biblio.bib", "autres-refs.yml")`. -> array
  chemins-biblio: (
    "../04-ressources/041-bibliographies/N-bibliographie.yml",
    "../04-ressources/041-bibliographies/N-bibliographie.bib"
    ),
  /// `false` = seules les sources citées sont affichées.
  /// `true` = tout afficher, même les non citées. -> bool
  tout-lister : false,
  /// Style de citation. Par défaut `"ieee"`.
  /// Autres : `"apa"`, `"chicago-author-date"`. -> str
  style-biblio: "ieee",
  body
) = context {
  // Définition du titre selon le choix de l'utilisateur
  let titre-section = if (titre-utilisateur != []) {titre-utilisateur} else {v-liste-trad-auto.at("bibliographie").at(v-langue-global.get())}
  // On compte le nombre de citations dans le document
  let nombre-entrees = query(cite).len()
  // Si on ne possède pas cite et que l'on a pas choisi explicitement de tout afficher, la bibliographie est masquée
  show bibliography: if ((nombre-entrees == 0) and (not tout-lister)) { it => [] } else { it => it }    
  
  bibliography(
    // Chemins vers la/les bibliographies
    chemins-biblio,
    // Gestion de la traduction automatique du titre
    title: titre-section,
    // Choix du comportement de la bibliographie, soit on affiche tout soit on affiche seulement les clées citées
    full: tout-lister, 
    // Style de la bibliographie
    style: style-biblio,
  )
  body
}

// Gestion de l'affichage de la liste des notes dans le mode ébauche, produit une non-convergence de la compilation
#let fbc-liste-notes(
  body
) = context {
  // Récupération du titre de la section 
  let titre-section = v-liste-trad-auto.at("sommaire_ebauche").at(v-langue-global.get())
  
  // Lecture de l'état global, si on est en mode ébauche on affiche la liste des notes
  if v-ebauche-global.get() {
      note-outline(title: [#titre-section])
  } 
  body
}

// Gestion de la page de garde
#let fbc-page-de-garde(
  // Type de rapport, écrit en petit au dessus du titre
  type-rapport:         [],
  // Titre du rapport, écrit en gros et centré sur la page
  titre-rapport:        [],
  // Indication si le rapport est confidentiel, ainsi que la durée de confidentialité, écrit en rouge
  confidentialite:      [],
  // Type de diplôme visé dans le cadre de la rédaction de ce rapport
  type-diplome:         [],
  // Professeur(s) qui réalise l'encadrement du rapport
  professeur:           [],
  // Encadrant extérieur qui réalise l'encadrement du rapport
  encadrant:            [],
  // Liste des auteurs du rapport
  auteurs:              (),
  // Formation des étudiants rédigeant le document
  formation:            [],
  // Promotion des étudiants
  promotion:            [],
  // Année / Niveau des étudiants
  niveau-classe:        [],
  // Mois de rédaction du document, laisser vide pour la date automatique
  mois-annee:           auto,
  // Image et adresse gauche
  // Note : none déclenche l'adresse JUNIA par défaut
  img-gau:              "../03-images/030-page-de-garde/junia-logo.png",
  adr-gau:              none,
  // Image et adresse centre
  img-cen:              "",
  adr-cen:              [],
  // Image et adresse droite
  img-dro:              "",
  adr-dro:              [],
  body
) = context {

  // ── Logos et adresses ────────────────────────────────────────────────────────
  // none déclenche l'adresse JUNIA par défaut — évite d'évaluer v-adresse-junia
  // comme valeur par défaut de paramètre (évalué à la définition, pas à l'appel)
  let v-adr-gau = if adr-gau != none { adr-gau } else { v-adresse-junia }

  align(top,
    grid(
      columns: (1fr, 1fr, 1fr),
      row-gutter: 1em,
      [#align(left)[   #if img-gau != "" { image(img-gau) } ]],
      [#align(center)[ #if img-cen != "" { image(img-cen) } ]],
      [#align(right)[  #if img-dro != "" { image(img-dro) } ]],
      [#if v-adr-gau != [] { v-adr-gau }],
      [#if adr-cen   != [] { adr-cen   }],
      [#if adr-dro   != [] { adr-dro   }],
    )
  )

  // ── Filigrane BROUILLON ──────────────────────────────────────────────────────
  // Lu depuis le state — pas besoin de passer ebauche en paramètre
  if v-ebauche-global.get() {
    place(center + horizon,
      rotate(45deg,
        text(6.5em, gray.lighten(70%))[
          #v-liste-trad-auto.at("brouillon").at(v-langue-global.get())
        ]
      )
    )
  }

  // ── Titre et informations du document ────────────────────────────────────────
  place(center + horizon)[
    #type-rapport #v(0.125em)
    #text(2em, weight: "bold")[#titre-rapport] #v(0.25em)
    #text(1.1em, fill: red, weight: "bold")[#confidentialite] #v(0.75em)
    #type-diplome #v(0.5em)
    #professeur #linebreak()
    #encadrant
  ]

  // ── Auteurs ──────────────────────────────────────────────────────────────────
  align(bottom, for k in auteurs { k; linebreak() })
  v(0.25em)

  // ── Formation, promotion et date ─────────────────────────────────────────────
  align(bottom, grid(
    columns: (1fr, 1fr, 1fr),
    row-gutter: 0.75em,
    [#formation], [], [],
    [#promotion #niveau-classe],
    [],
    [#align(right)[
      // La fonction est déjà dans un `context` — pas besoin d'un second context ici
      #if mois-annee == auto {
        [#v-liste-trad-auto.at("mois_date").at(v-langue-global.get()) #v-annee-court]
      } else {
        mois-annee
      }
    ]]
  ))

  pagebreak()
  body
}


// ----------------------------------
// --- FONCTIONS DE MISE EN PAGES ---
// ----------------------------------
// Passage d'une partie à une autre, on change des paramètres globaux de mise en page

/// Bascule vers la zone pré-sommaire.
///
/// À placer *après* la configuration du modèle et *avant* le premier
/// contenu pré-sommaire. Modifie la mise en page pour toute la zone :
/// pagination romaine remise à zéro, titres non numérotés et absents
/// de la table des matières, figures numérotées simplement (I, II…),
/// filigranes actifs si `ebauche` ou `filigrane` sont `true`.
///
/// Appelée automatiquement par `modele-junia`. Pour `junia-expert`,
/// l'appeler manuellement.
///
/// -> content
#let fmp-pre-sommaire(
  body, 
) = context {
  // Lecture de l'état global de la gestion du fond de page
  let fond-de-page = v-fond-de-page-global.get()
  // Pas de numérotation des équations dans le pré-sommaire
  set math.equation(numbering: none)
  // Numérotation simple pour le pré-sommaire (pas de préfixe chapitre)
  set figure(numbering: "I")
  // Remise à zéro des compteurs de figures
  counter(figure.where(kind: image)).update(0)
  counter(figure.where(kind: table)).update(0)
  counter(figure.where(kind: raw)).update(0)
  
  set page(
    // Numérotation en chiffres romain
    numbering: "I",
    footer: context {
      line(length: 100%, stroke: 0.4pt)
      align(right)[
        #v-liste-trad-auto.at("page_app").at(v-langue-global.get()) #counter(page).display("I")
      ]
    },
    background: fond-de-page
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
  // Obligatoire pour afficher le "reste" du document
  body
}

/// Bascule vers la zone corps du document.
///
/// À placer après les fonctions pré-sommaire et avant le premier chapitre numéroté. Modifie la mise en page : pagination arabe
/// remise à zéro, en-tête avec le titre du chapitre courant, titres numérotés jusqu'au niveau 3, figures numérotées par chapitre,
/// saut de page automatique avant chaque chapitre de niveau 1.
///
/// Utilisation avec paramètres : `#show: fmp-corps-document.with(profondeur: 2)` pour ne numéroter que
/// les deux premiers niveaux — les titres `===` et au-delà existent mais ne sont pas numérotés.
///
/// -> content
#let fmp-corps-document(
  /// Niveau de titre maximum numéroté. Au-delà, les titres
  /// existent mais ne sont pas numérotés. Par défaut `3`. -> int
  profondeur: 3,
  body
) = context {
  // Lecture de l'état global de la gestion du fond de page
  let fond-de-page = v-fond-de-page-global.get()
  // Variable pour la page
  let v-page-app = v-liste-trad-auto.at("page_app").at(v-langue-global.get())
  // Variable pour le délimiteur
  let v-delim-app = v-liste-trad-auto.at("delim_app").at(v-langue-global.get())
  
  // Numérotation des équations selon le paramètre  
  set math.equation(
    numbering: if v-equations-global.get() {
      (..num) => numbering("(1.1)", counter(heading).get().first(), num.pos().first())
    } else { none }
  )
  // Numérotation chapitre.figure dans le corps du document
  set figure(
    numbering: (..num) =>
      numbering("1.1", counter(heading).get().first(), num.pos().first()),
  )
  // Remise à zéro des figures pour repartir de 1 à chaque nouveau chapitre
  show heading.where(level: 1): it => {
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(figure.where(kind: raw)).update(0)
    counter(math.equation).update(0)
    it
  }
  
  // Paramétrage du pied de page
  set page(
    numbering: "1",
    header: fa-afficher-titre(),
    footer: context {
      line(length: 100%, stroke: 0.4pt)
      // Gestion de la traduction automatique du délimitateur pour l'indication du nombre de page
      align(right)[
        #v-page-app #counter(page).display() #v-delim-app #counter(page).final().first()
      ]
    },
    background: fond-de-page
  )
  // Remise à zéro du compteur page
  counter(page).update(1)
  // Numérotation des titres (ex: 1.1)
  set heading(
    // Présence dans la table des matières
    outlined: true,
    // Appellation lors d'une citation, gestion automatique
    supplement: v-liste-trad-auto.at("chap_court").at(v-langue-global.get()),
    numbering: (..nums) => {
    // On vérifie combien de niveaux on a (la longueur du tableau)
    if nums.pos().len() <= profondeur {
      // Si c'est 3 ou moins, on affiche le numéro
      numbering("1.1", ..nums)
    } else {
      // Sinon on ne le numérote pas
      none
    }
  })
  // Affichage dans le sommaire principal si les listes de fig / tab apparaissent après celui-ci
  show outline: set heading(outlined: true)

  body
}

/// Bascule vers la zone annexes.
///
/// À placer après la bibliographie et avant le premier titre d'annexe.
/// Si aucun titre de niveau 1 ne suit, la zone est vide et aucun sommaire n'est généré.
///
/// Un sommaire des annexes est généré automatiquement s'il y a du contenu, séparé de la table des matières principale par un
/// marqueur interne. Les titres sont numérotés en lettres (A, A.1, A.1.1…). Les figures sont requalifiées en type "annexe"
/// avec légende en haut et numérotation remise à zéro.
///
/// -> content
#let fmp-annexes(
  body
) = context {
  // On compte le nombre de titre dans les annexes  
  let nombre-ann = query(heading.where(level: 1).after(<end_of_main_doc>)).len()
  // Si il n'ya a pas de titre, on affiche pas le sommaire
  if (nombre-ann != 0) {
    // Génération automatique du titre et du sommaire des annexes
    outline(
      // Titre de la partie, gestion automatique
      title: v-liste-trad-auto.at("annexe").at(v-langue-global.get()),
      // Récupération des titres aprés le délimiteur correspondant
      target: heading.where(outlined: true).after(<end_of_main_doc>),
      indent: auto
    )
  }
  
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
    supplement: v-liste-trad-auto.at("annexe_fig").at(v-langue-global.get()),
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

// ---------------------------
// --- FONCTIONS DU MODELE ---
// ---------------------------
// Fonction par rapport au modèle et ses problématique, simplifie l'écriture ou résout des problèmes spécifiques

/// Affiche une ou plusieurs pages consécutives d'un PDF.
///
/// Utile pour insérer un document externe (plan, schéma, formulaire…)
/// directement dans le rapport, en figure ou en annexe.
/// La légende et le label ne sont placés que sur la *première* page.
///
/// Exemple : `#fm-afficher-pdf(chemin: "plans/plan.pdf", legende: [Plan du réseau],`
/// `premiere-page: 2, derniere-page: 4, tag: "mon-plan")` puis citer avec `@mon-plan`.
///
/// -> content
#let fm-afficher-pdf(
  /// Chemin vers le fichier PDF. *Obligatoire.* -> str
  chemin: "",
  /// Légende sous la première page. Laisser vide pour aucune légende. -> content
  legende: [],
  /// Première page à afficher. Commence à `1` (cohérent avec les
  /// lecteurs PDF). -> int
  premiere-page: 1,
  /// Dernière page à afficher. Doit être ≥ `premiere-page`. -> int
  derniere-page: 1,
  /// Largeur d'affichage relative à la page. -> ratio
  largeur: 85%,
  /// Label pour citer avec `@tag` dans le texte. Sans espaces.
  /// Laisser vide si non nécessaire. -> str
  tag: "",
) = {
  // --- Vérifications ---
  assert(
    chemin != "",
    message: "fm-afficher-pdf : le paramètre `chemin` est vide."
  )
  assert(
    premiere-page >= 1,
    message: "fm-afficher-pdf : `premiere-page` doit être ≥ 1, reçu : " + str(premiere-page) + "."
  )
  assert(
    derniere-page >= premiere-page,
    message: "fm-afficher-pdf : `derniere-page` (" + str(derniere-page) +
             ") doit être ≥ à `premiere-page` (" + str(premiere-page) + ")."
  )
  assert(
    tag == "" or not tag.contains(" "),
    message: "fm-afficher-pdf : le tag ne doit pas contenir d'espaces : \"" + tag + "\"."
  )

  // --- Affichage ---
  for nb-page in range(premiere-page, derniere-page + 1) {
    align(horizon + center)[
      #figure(
        image(chemin, width: largeur, page: nb-page),
        // Légende et numérotation uniquement sur la première page affichée
        caption:   if nb-page == premiere-page { legende } else { none },
        numbering: if nb-page == premiere-page { "1" }    else { none },
      )#if tag != "" and nb-page == premiere-page { label(tag) }
    ]
  }
}

// ----------------------------
// --- FONCTIONS REDEFINIES ---
// ----------------------------
// Réécriture de fonctions ou customisations 

/// Insère une note dans la marge droite.
///
/// Visible *uniquement en mode ébauche* (`ebauche: true`). Reliée au
/// texte par un trait rouge. Utilisation : `#fr-note-de-marge[texte]`.
///
/// -> content
#let fr-note-de-marge(
  /// Texte de la note. -> content
  contenu
) = {
  margin-note(
    block(width: 100%)[
      #set text(size: 9pt, style: "italic") // Style plus discret
      #set align(right)                     // Alignement à droite
      #set par(justify: true)               // Justification
      #contenu
    ]
  )
}

/// Insère une note encadrée dans le flux du texte.
///
/// Visible *uniquement en mode ébauche* (`ebauche: true`). Contrairement
/// à `fr-note-de-marge`, s'insère directement dans le paragraphe —
/// adaptée aux remarques longues. Utilisation : `#fr-note-de-texte[texte]`.
///
/// -> content
#let fr-note-de-texte(
  /// Texte de la note. -> content
  contenu
) = {
  v-inline-note-counter.step()
  inline-note(
    fill: blue.lighten(90%),   // Couleur de fond
    par-break: true,
    stroke: (
        paint: blue,
        thickness: 0.5pt,
        join: "round",
        dash: "solid",
      ),      // Couleur de bordure
  )[
    #set text(size: 9pt, fill: blue.darken(20%)) // Couleur du texte
    #set par(justify: true)
    #contenu
  ]
}