// --- Imports ---
#import "000-paquets.typ": *
#import "001-variables.typ": *
#import "002-fonctions.typ": *

// ---------------------------------------------------------
// --- MODÈLE COMMUN (noyau partagé entre les 3 modèles) ---
// ---------------------------------------------------------
// Ce fichier centralise tout ce qui est commun aux 3 modèles :
// mise en page globale, styles des titres/figures, gestion des références et des paquets transverses.
// Il n'a pas vocation à être utilisé seul.

#let junia-core(
  // Liste des entrées du glossaire.
  // () par défaut — les modèles autonomes passent leur propre liste,
  // modele-junia() passe v-liste-glossaire importé depuis l'architecture de dossiers.
  glossaire: (),

  // Tailles des titres du niveau 1 à 6
  tailles-police: (1.75em, 1.6em, 1.4em, 1.25em, 1.1em, 1em),

  // Langue du document, définie lors de l'appel du modèle
  langue-document: "",

  // Affichage du reste du document
  body,

) = {

  // --- Police et langue ---
  set text(
    lang: langue-document, 
    size: 12pt, 
    font: "New Computer Modern Sans"
    )

  // --- Réglages globaux de mise en page ---
  set page(
    paper: "a4", 
    margin: auto, 
    binding: auto
  )
    
  set par(
    justify: true, 
    linebreaks: "optimized"
  )

  // --- Styles globaux ---
  // Notes de bas de page
  show footnote.entry: set text(size: 0.75em)
  
  // Espacement de la légende des figures
  set figure(gap: 1em)
  
  // Texte des tableaux légèrement réduit
  show table: set text(size: 0.833em)
  
  // Légende des tableaux au-dessus
  show figure.where(kind: table): set figure.caption(position: top)

  // --- Suppléments (formes longues pour les légendes) ---
  // Utilisation de `context` pour une résolution dynamique selon la langue
  let supp-eq  = context v-liste-trad-auto.at("eq_long").at(v-langue-global.get())
  let supp-fig = context v-liste-trad-auto.at("fig_long").at(v-langue-global.get())
  let supp-tab = context v-liste-trad-auto.at("tab_long").at(v-langue-global.get())

  // Gestion des équations
  set math.equation(supplement: supp-eq)

  // Gestion des figures
  set figure(
    supplement: it => {
      if it.func() == table { supp-tab } else { supp-fig }
    },
  )

  // --- Paquet : Glossarium ---
  // Mise à jour du state pour que fbc-lexique puisse le lire
  v-glossaire-global.update(glossaire)
  
  show: make-glossary
  // Vérification avant enregistrement pour éviter une panique si la liste est vide
  if glossaire.len() != 0 {
    register-glossary(glossaire)
  }

  // --- Gestion des références (@clé) ---
  // IMPORTANT : pas de `context` global — cela briserait le chaînage
  // vers la règle show ref de make-glossary (nécessaire pour le lexique).
  // Les `context` sont locaux aux cas qui en ont besoin.
  show ref: it => {
    let el = it.element
    if el != none {

      // Entrée de glossaire, fa-style-lien gère son propre context
      if "kind" in el.fields() and el.kind == "glossarium_entry" {
          return {
            v-lexique-cite-global.update(true)
            fa-style-lien(it, kind: "glossaire")
          }
      }
      // Figure de type annexe
      if el.func() == figure and el.kind == "annexe" {
        return fa-style-lien(it, kind: "annexe")
      }
      // Figure image — forme courte dans le texte
      if el.func() == figure and el.kind == image {
        return context {
          let lang = v-langue-global.get()
          let sup = v-liste-trad-auto.at("fig_court").at(lang)
          let num = counter(figure.where(kind: image)).at(el.location())
          link(el.location())[#sup~#numbering(el.numbering, ..num)]
        }
      }
      // Tableau — forme courte dans le texte
      if el.func() == figure and el.kind == table {
        return context {
          let lang = v-langue-global.get()
          let sup = v-liste-trad-auto.at("tab_court").at(lang)
          let num = counter(figure.where(kind: table)).at(el.location())
          link(el.location())[#sup~#numbering(el.numbering, ..num)]
        }
      }
      // Équation — forme courte dans le texte
      if el.func() == math.equation {
        return context {
          let lang = v-langue-global.get()
          let sup = v-liste-trad-auto.at("eq_court").at(lang)
          let num = counter(math.equation).at(el.location())
          link(el.location())[#sup~#numbering(el.numbering, ..num)]
        }
      }
    }
    // Chaînage vers make-glossary : `it` retourné hors de tout context
    // permet à la règle show ref de glossarium de s'exécuter normalement.
    it
  }

  // --- Citations bibliographiques ---
  show cite: it => fa-style-lien(it, kind: "citation")

  // --- Style des titres ---
  show heading: it => {
    if it.level == 1 {
      // Saut de page avant chaque chapitre de niveau 1
      pagebreak(weak: true)
      v(1em)
    } else {
      // Espacement proportionnel au niveau
      v(1em / it.level)
    }
    // Taille décroissante selon le niveau
    let v-taille = tailles-police.at(it.level - 1, default: 1em)
    set text(size: v-taille, weight: "bold")
    // `sticky` empêche un titre orphelin en bas de page
    block(sticky: true, {
      if it.numbering != none {
        counter(heading).display(it.numbering)
        h(0.5em / it.level)
      }
      it.body
    })
    v(0.35em / it.level)
  }

  // --- Paquet : Codly (blocs de code) ---
  show: codly-init.with()
  codly(
    languages:        codly-languages,
    number-format:    it => text(fill: rgb("#aaaaaa"), size: 0.8em, str(it)),
    number-align:     end,
    display-icon:     true,
    display-name:     true,
    header-repeat:    false,
    header-cell-args: (fill: rgb("#f0f0f0")),
    smart-indent:     true,
  )

  // --- Paquet : Drafting (notes de relecture) ---
  // set-margin-note-defaults requiert un booléen — on l'enveloppe dans un
  // show rule avec context pour résoudre le state avant l'appel
  show: body => context {
    set-margin-note-defaults(
      hidden: not v-ebauche-global.get(),
      side: right,
      stroke: (paint: red, thickness: 0.5pt, join: "round", dash: "solid"),
    )
    body
  }

  // --- Suite du document ---
  body
}
