// Modèle de rapport de laboratoire HES-SO
// Exportation principale des fonctions du template

#import "@preview/glossarium:0.5.4": make-glossary, print-glossary, register-glossary
#import "@preview/lilaq:0.5.0" as lq

// Imports internes
#import "template/src/settings/name.typ": *
#import "template/src/settings/glossaire.typ": mes-acronymes
#import "layout/1_layout.typ": mis_en_page
#import "layout/2_layout.typ": pdf
#import "layout/box_layout.typ": *
#import "layout/cover_page_layout.typ": page_de_garde

// Fonction principale : rapport
// Utilise la configuration de src/settings/name.typ
//
// Utilisation simple:
//   #show: rapport()

#let rapport() = doc => {
  // Affichage de la page de garde
  page_de_garde()

  // Application de la mise en page
  show: make-glossary
  show: mis_en_page

  // Enregistrement du glossaire
  register-glossary(mes-acronymes)

  // Table des matières
  heading(level: 1, numbering: none, outlined: false)[Table des matières]
  v(0.6cm)
  outline(title: none, depth: 2, indent: auto)
  pagebreak()

  // Contenu principal
  doc

  // Sections automatiques (bibliographie, glossaire, annexes)

  include "layout/signature.typ"
  include "layout/2_layout.typ"

  include "template/src/assets/PDF/annexe.typ"
}

// Exports des boîtes utilitaires
#let info-box = info_box
#let danger-box = danger_box
#let valid-box = valid_box
#let feu-box = feu_box
#let idea-box = idea_box
#let todo-box = todo_box
#let stabilo = stabilo
#let mon-code = mon_code
#let mon-code-fichier = mon_code_fichier
#let photo = photo
#let pdf-annexe = pdf
