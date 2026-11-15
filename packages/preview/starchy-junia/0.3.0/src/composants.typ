// =============================================================================
// COMPOSANTS — blocs de contenu (fbc-*) et insertion de PDF (fm-afficher-pdf)
// =============================================================================
/*
Préfixes des fonctions du modèle :
  - Assistances         fa-*    | Fonctions internes, voir `outils.typ`
  - Bloc de contenu     fbc-*   | Affiche une section, comme le lexique ou la bibliographie (ce fichier)
  - Mise en page        fmp-*   | Bascule la mise en page d'une zone : pré-sommaire → corps → annexes (`zones.typ`)
  - Modèle              fm-*    | Action ponctuelle dans le contenu, comme l'insertion d'un PDF (ce fichier)
*/
#import "paquets.typ": *
#import "etats.typ": *
#import "outils.typ": *

// -------------------------------------
// --- FONCTIONS DE BLOC DE CONTENUS ---
// -------------------------------------
// Fonctions de mise en page des sections, ou des bloc de contenus, page de garde, etc.
// Permet la traduction automatiques des titres, impossible autrement

/// Affiche le lexique (glossaire) du document,
/// pour cela on se sert du paquet #link("https://typst.app/universe/package/glossarium")[#text(fill: blue)[glossarium]].
///
/// On affiche le lexique *uniquement si des entrées ont été renseignées*, jamais
/// de section vide. Les entrées sont définies dans le fichier `ressources/lexique.typ`
/// (modèle complet) ou passées via `glossaire` dans les autres modèles.
/// Citer une entrée avec `@cle` pour créer un lien vers sa définition.
///
/// Utilisation avec paramètres : `#show: fbc-lexique.with(tout-lister: true)` pour
/// afficher toutes les entrées même si elles ne sont pas citées dans le document.
///
/// -> content
#let fbc-lexique(
  /// Titre de la section. `auto` = traduction automatique
  /// ("Lexique" ou "Glossary" selon `langue`). -> content
  titre: auto,
  /// `false` $->$ seules les entrées citées sont affichées. \
  /// `true`  $->$ toutes les entrées, même les non citées. -> bool
  tout-lister : false,
  ..autres,
  body
) = context {

  fa-verifier-arguments("fbc-lexique", autres, renommes: v-renommes-titre)
  // Si l'utilisateur n'a pas fourni de titre, on utilise la traduction automatique
  let titre-section = if titre != auto { titre } else { v-liste-trad-auto.at("lexique").at(v-langue-global.get()) }

  // v-glossaire-global est un état mis à jour par modele-junia() au démarrage avec la liste fournie via le paramètre `glossaire` du modèle utilisé.
  // Si la liste est vide, il n'y a rien à afficher ni à enregistrer.
  let liste-clees = v-glossaire-global.get()

  // Vérification de la présence d'entrées dans la liste du glossaire
  if liste-clees.len() != 0 {

    // --- Une entrée est-elle citée dans le document ? ---
    //   Chaque citation pose un repère invisible et constant (voir `v-lexique-cite`). Tester les
    //   citations elles-mêmes ou le décompte de glossarium rendait la compilation instable : leur rendu
    //   change d'une passe à l'autre, et le lexique apparaissait puis disparaissait.
    let a-ete-cite = query(v-lexique-cite).len() > 0

    // On affiche la section si au moins une entrée a été citée, OU si l'utilisateur veut tout lister explicitement.
    let afficher = tout-lister or a-ete-cite
    // Affichage du titre de la section
    if afficher {
      heading(level: 1, outlined: false)[#titre-section]
    }

    // --- Appel à print-glossary ---
    // Avec `show-all: false`, glossarium n'imprime que les entrées citées : aucune entrée n'est
    // donc imprimée quand la section est masquée, sans qu'il faille les cacher nous-mêmes.
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
  /// Titre de la section. `auto` = traduction automatique
  /// ("Table des matières" ou "Table of contents"). -> content
  titre: auto,
  /// Niveau de titre maximum inclus. Par défaut `3` (niveaux `=`,
  /// `==`, `===`). Réduire à `2` pour un sommaire plus court. (on peut aller nativement jusque 6) -> int
  profondeur: 3,
  ..autres,
  body
) = context {
  // Définition du titre selon le choix de l'utilisateur
  fa-verifier-arguments("fbc-sommaire", autres, renommes: v-renommes-titre)
  let titre-section = if titre != auto { titre } else { v-liste-trad-auto.at("sommaire").at(v-langue-global.get()) }
  
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
/// Liste toutes les figures image avec numéro, légende et page — ainsi que les programmes
/// si le paramètre `code` du modèle est en mode `"figure"`.
/// La section n'est générée *que si le document contient au moins une figure*, jamais de table vide.
///
/// -> content
#let fbc-liste-figure(
  /// Titre de la section. `auto` = traduction automatique
  /// ("Table des figures" ou "List of figures"). -> content
  titre: auto,
  ..autres,
  body
) = context {
  // Définition du titre selon le choix de l'utilisateur
  fa-verifier-arguments("fbc-liste-figure", autres, renommes: v-renommes-titre)
  let titre-section = if titre != auto { titre } else { v-liste-trad-auto.at("sommaire_fig").at(v-langue-global.get()) }
  // Figures de type image, auxquelles s'ajoutent les programmes s'ils sont traités comme des figures
  let cible = if v-code-global.get().mode == "figure" {
    figure.where(kind: image).or(figure.where(kind: raw))
  } else {
    figure.where(kind: image)
  }
  // On cherche à savoir s'il y a des figures dans le document, sinon on affiche pas le sommaire
  let nombre-fig = query(cible).len()
  // Test pour l'affichage du sommaire 
  if (nombre-fig != 0) {
    outline(
      // Gestion de la traduction automatique du titre
      title: titre-section,
      // Objets concerné, ici les figures de types "images"
      target: cible
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
  /// Titre de la section. `auto` = traduction automatique
  /// ("Liste des tableaux" ou "List of tables"). -> content
  titre: auto,
  ..autres,
  body
) = context {
  // Définition du titre selon le choix de l'utilisateur
  fa-verifier-arguments("fbc-liste-tableau", autres, renommes: v-renommes-titre)
  let titre-section = if titre != auto { titre } else { v-liste-trad-auto.at("sommaire_tab").at(v-langue-global.get()) }
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

/// Affiche la liste des programmes (blocs de code placés dans une `figure`).
///
/// Liste tous les programmes avec numéro, légende et page.
/// La section n'est générée *que si le document contient au moins un programme*, jamais de liste vide.
/// En mode `"figure"` (paramètre `code` du modèle), les programmes apparaissent dans la table des figures
/// et cette liste n'est pas générée.
///
/// -> content
#let fbc-liste-programme(
  /// Titre de la section. `auto` = traduction automatique
  /// ("Liste des programmes" ou "List of listings"). -> content
  titre: auto,
  ..autres,
  body
) = context {
  // Définition du titre selon le choix de l'utilisateur
  fa-verifier-arguments("fbc-liste-programme", autres, renommes: v-renommes-titre)
  let titre-section = if titre != auto { titre } else { v-liste-trad-auto.at("sommaire_prog").at(v-langue-global.get()) }
  // On cherche à savoir s'il y a des programmes dans le document, sinon on affiche pas la liste
  let nombre-prog = query(figure.where(kind: raw)).len()
  // Pas de liste séparée si les programmes sont traités comme des figures
  if (nombre-prog != 0) and (v-code-global.get().mode == "programme") {
    outline(
      // Gestion de la traduction automatique du titre
      title: titre-section,
      // Objets concerné, ici les figures de types "code"
      target: figure.where(kind: raw)
    )
  }
  body
}

/// Prépare l'affichage de la bibliographie du document.
///
/// N'affiche la section *que si des citations `@cle` sont présentes* dans le texte. Typst exige que `bibliography()` soit toujours
/// appelée pour résoudre les références, la section est rendue invisible via `show bibliography: it => []` quand elle est vide.
/// Donne aussi au `#bibliography(...)` qui suit son titre traduit automatiquement.
///
/// Cette fonction ne fait qu'entourer `body` — c'est `body` qui doit contenir l'appel `#bibliography(...)` lui-même, avec les
/// chemins vers les fichiers `.bib`/`.yml`. Ces chemins sont relatifs au fichier appelant (ex. `squelette.typ`) : ils ne
/// peuvent pas être résolus depuis l'intérieur du paquet, d'où cette séparation.
///
/// Utilisation :
/// ```typst
/// #show: fbc-bibliographie
/// #bibliography("ressources/bibliographie.yml")
/// ```
///
/// -> content
#let fbc-bibliographie(
  /// Titre de la section. `auto` = traduction automatique
  /// ("Références Bibliographiques" ou "Bibliography"). -> content
  titre: auto,
  /// `false` = la section est masquée si aucune citation `@cle` n'est
  /// présente dans le texte. `true` = ne jamais la masquer — à utiliser avec
  /// `full: true` sur `#bibliography(...)` pour tout lister. -> bool
  tout-lister : false,
  ..autres,
  body
) = context {
  // Paramètres de la version 0.2.x : les fichiers et le style se donnent désormais à `#bibliography(...)`
  let migration-biblio = "les fichiers et le style se donnent désormais à `#bibliography(...)`, placé juste après `#show: fbc-bibliographie`, ex : `#bibliography((\"ressources/bibliographie.yml\", \"ressources/bibliographie.bib\"), style: \"ieee\")`."
  fa-verifier-arguments("fbc-bibliographie", autres, renommes: v-renommes-titre + (
    chemins-biblio: migration-biblio,
    style-biblio:   migration-biblio,
  ))
  // Titre traduit, sauf si l'appelant en fournit un dans `#bibliography(title: ...)`
  set bibliography(title: if titre != auto { titre } else { v-liste-trad-auto.at("bibliographie").at(v-langue-global.get()) })
  // On compte le nombre de citations dans le document
  let nombre-entrees = query(cite).len()
  // Si on ne possède pas cite et que l'on a pas choisi explicitement de tout afficher, la bibliographie est masquée
  show bibliography: if ((nombre-entrees == 0) and (not tout-lister)) { it => [] } else { it => it }
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
  // Date de rédaction du document, `auto` = mois et année de compilation
  date:                 auto,
  // Logos : contenu (ex : `image("images/logo.png")`, appelé côté projet) ou `none`
  // Adresses : contenu ou `none`. Pour la gauche, `auto` = logo et adresse JUNIA
  logo-gauche:          auto,
  adresse-gauche:       auto,
  logo-centre:          none,
  adresse-centre:       none,
  logo-droite:          none,
  adresse-droite:       none,
  body
) = context {

  // ── Logos et adresses ────────────────────────────────────────────────────────
  // `auto` → logo et adresse JUNIA, résolus ici plutôt qu'en valeur par défaut de paramètre
  let logo-gauche    = if logo-gauche == auto { image("../assets/junia-logo.png") } else { logo-gauche }
  let adresse-gauche = if adresse-gauche == auto { v-adresse-junia } else { adresse-gauche }

  // Un chemin passé en texte serait résolu depuis l'intérieur du paquet et introuvable
  for (nom, img) in (("logo-gauche", logo-gauche), ("logo-centre", logo-centre), ("logo-droite", logo-droite)) {
    if type(img) == str {
      panic("modele-junia : `" + nom + "` attend une image, pas un chemin — écrire `" + nom + ": image(\"" + img + "\")`.")
    }
  }

  align(top,
    grid(
      columns: (1fr, 1fr, 1fr),
      row-gutter: 1em,
      [#align(left)[   #logo-gauche ]],
      [#align(center)[ #logo-centre ]],
      [#align(right)[  #logo-droite ]],
      [#adresse-gauche],
      [#adresse-centre],
      [#adresse-droite],
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
      #if date == auto {
        [#v-liste-trad-auto.at("mois_date").at(v-langue-global.get()) #v-annee-court]
      } else {
        date
      }
    ]]
  ))

  pagebreak()
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
/// Le PDF est passé sous forme d'image, `image("chemin.pdf")`, écrite dans le
/// fichier appelant : le chemin est ainsi résolu depuis le projet, ce que le
/// paquet ne peut pas faire lui-même.
///
/// Exemple : `#fm-afficher-pdf(image("plans/plan.pdf"), legende: [Plan du réseau],`
/// `premiere-page: 2, derniere-page: 4, etiquette: "mon-plan")` puis citer avec `@mon-plan`.
///
/// -> content
#let fm-afficher-pdf(
  /// Le PDF, sous la forme `image("chemin/vers/fichier.pdf")`. *Obligatoire.* -> content
  ..autres,
  /// Légende sous la première page. Laisser vide pour aucune légende. -> content
  legende: [],
  /// Première page à afficher. Commence à `1` (cohérent avec les
  /// lecteurs PDF). -> int
  premiere-page: 1,
  /// Dernière page à afficher. Doit être ≥ `premiere-page`. -> int
  derniere-page: 1,
  /// Largeur d'affichage relative à la page. -> ratio
  largeur: 90%,
  /// Étiquette pour citer le document avec `@etiquette` dans le texte. Sans espaces.
  /// `none` si non nécessaire. -> str
  etiquette: none,
) = {
  // --- Vérifications ---
  let migration = "passer le PDF en premier argument : `fm-afficher-pdf(image(\"chemin.pdf\"), ...)`."
  fa-verifier-arguments("fm-afficher-pdf", autres, renommes: (donnees: migration, chemin: migration, tag: "renommé en `etiquette`."))
  // Le PDF est le premier argument positionnel, capturé par `..autres` pour pouvoir signaler l'ancienne syntaxe
  let fichier = autres.pos().at(0, default: none)
  if fichier == none or type(fichier) != content {
    panic("fm-afficher-pdf : " + migration)
  }
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
    etiquette == none or not etiquette.contains(" "),
    message: "fm-afficher-pdf : l'étiquette ne doit pas contenir d'espaces : " + repr(etiquette) + "."
  )

  // --- Affichage ---
  for nb-page in range(premiere-page, derniere-page + 1) {
    // Argument optionnel : absent → hérite du `set figure(numbering: ...)` global,
    // présent → force `none` (pages de continuation, jamais numérotées)
    let args-supp = if nb-page == premiere-page { (:) } else { (numbering: none) }
  
    align(horizon + center)[
      #figure(
        // Page et largeur imposées par règle `set` sur l'image fournie par l'appelant
        { set image(page: nb-page, width: largeur); fichier },
        // Légende et numérotation uniquement sur la première page affichée
        caption:   if nb-page == premiere-page { legende } else { none },
        outlined: nb-page == premiere-page,
        ..args-supp,
      )#if etiquette != none and nb-page == premiere-page { label(etiquette) }
    ]
  }
}
