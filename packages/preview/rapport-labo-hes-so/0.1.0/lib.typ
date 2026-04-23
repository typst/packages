// Modèle de rapport de laboratoire HES-SO
// Exportation principale des fonctions du template

#import "@preview/glossarium:0.5.10": make-glossary, print-glossary, register-glossary
#import "@preview/lilaq:0.6.0" as lq

// Imports internes
#import "template/src/settings/name.typ": *
#import "template/src/settings/glossaire.typ": mes-acronymes
#import "layout/1-layout.typ": mis-en-page
#import "layout/2-layout.typ": pdf
#import "layout/box-layout.typ": *
#import "layout/cover-page-layout.typ": page-garde


// Fonction principale : rapport
// Utilise la configuration de src/settings/name.typ
//
// Utilisation simple:
//   #show: rapport()

#let rapport() = doc => {
  // Affichage de la page de garde
  page-garde()

  // Application de la mise en page
  show: make-glossary
  show: mis-en-page

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
  include "layout/2-layout.typ"

  include "template/src/assets/PDF/annexe.typ"
}

// Exports des boîtes utilitaires
#let info-box = info-box
#let danger-box = danger-box
#let valid-box = valid-box
#let feu-box = feu-box
#let idea-box = idea-box
#let todo-box = todo-box
#let stabilo = stabilo
#let mon-code = code
#let mon-code-fichier = code-fichier
#let photo = photo
#let pdf-annexe = pdf
