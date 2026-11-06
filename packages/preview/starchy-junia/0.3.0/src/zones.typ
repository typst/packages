// =============================================================================
// ZONES DU DOCUMENT — fonctions de mise en page (fmp-*)
// =============================================================================
// Passage d'une zone à l'autre : pré-sommaire → corps du document → annexes
#import "etats.typ": *
#import "outils.typ": *

// ----------------------------------
// --- FONCTIONS DE MISE EN PAGES ---
// ----------------------------------
// Passage d'une partie à une autre, on change des paramètres globaux de mise en page

// Bascule vers la zone pré-sommaire.
//
// À placer *après* la configuration du modèle et *avant* le premier
// contenu pré-sommaire. Modifie la mise en page pour toute la zone :
// pagination romaine remise à zéro, titres non numérotés et absents
// de la table des matières, figures numérotées simplement (I, II…),
// filigranes actifs si `ebauche` ou `bandeau-confidentiel` sont `true`.
//
// Appelée automatiquement par `modele-junia`.
//
// -> content
#let fmp-pre-sommaire(
  body, 
) = context {
  // Lecture de l'état global de la gestion du fond de page
  let fond-de-page = v-fond-de-page-global.get()
  // Pas de numérotation des équations dans le pré-sommaire
  set math.equation(numbering: none)
  // Entrée dans la zone pré-sommaire : figures numérotées en chiffres romains (voir `fa-numero-figure`)
  v-zone-global.update("pre-sommaire")

  // Pied de page du pré-sommaire : « Page I », sans total ni en-tête
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
/// La profondeur des titres numérotés et la numérotation des équations se règlent
/// avec le paramètre `numerotation` de `modele-junia`.
///
/// -> content
#let fmp-corps-document(
  ..autres,
  body
) = context {
  fa-verifier-arguments("fmp-corps-document", autres, renommes: (
    profondeur: "se règle désormais dans `modele-junia` : `numerotation: (profondeur: 2)`.",
  ))
  let numerotation = v-numerotation-global.get()
  // Lecture de l'état global de la gestion du fond de page
  let fond-de-page = v-fond-de-page-global.get()
  // Variable pour la page
  let v-page-app = v-liste-trad-auto.at("page_app").at(v-langue-global.get())
  // Variable pour le délimiteur
  let v-delim-app = v-liste-trad-auto.at("delim_app").at(v-langue-global.get())
  
  // Numérotation des équations selon le paramètre  
  set math.equation(
    numbering: if numerotation.equations {
      (..num) => numbering("(1.1)", counter(heading).get().first(), num.pos().first())
    } else { none }
  )
  // Entrée dans la zone corps : figures numérotées chapitre.rang (voir `fa-numero-figure`)
  v-zone-global.update("corps")
  // Repère du début du corps, à partir duquel les figures sont numérotées par chapitre (voir `fa-rang-figure`)
  [#metadata("debut-corps")#v-debut-corps]
  // Remise à zéro des équations pour repartir de 1 à chaque nouveau chapitre
  // (les figures, elles, sont numérotées relativement au chapitre, voir `fa-rang-figure`)
  show heading.where(level: 1): it => {
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
    if nums.pos().len() <= numerotation.profondeur {
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
  // Entrée dans la zone annexes
  v-zone-global.update("annexes")
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
  // Une annexe longue (programme, tableau) peut s'étendre sur plusieurs pages
  show figure.where(kind: "annexe"): set block(breakable: true)
  // Alignement des figures d'annexes
  // Un programme long qui s'étend sur plusieurs pages n'est pas centré verticalement
  show figure.where(kind: "annexe"): it => if it.body.func() == raw { align(center, it) } else { align(horizon + center, it) }
  // On s'assure que le compteur spécifique aux annexes démarre bien à 1
  counter(figure.where(kind: "annexe")).update(0)
  // Obligatoire pour afficher le "reste" du document
  body
}
