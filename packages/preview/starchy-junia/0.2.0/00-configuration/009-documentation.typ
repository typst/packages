// =============================================================================
// DOCUMENTATION — starchy-junia
// =============================================================================
// Compiler ce fichier depuis la racine :
// typst compile 00-configuration/009-documentation.typ documentation.pdf
// =============================================================================

#import "000-paquets.typ": tidy
#import "002-fonctions.typ": fmp-corps-document
#import "004-modeles.typ": junia-light

#let src-fonctions = read("002-fonctions.typ")
#let src-modeles   = read("004-modeles.typ")

#let docs-fonctions = tidy.parse-module(src-fonctions, name: "Fonctions")
#let docs-modeles   = tidy.parse-module(src-modeles,   name: "Modèles")

#show: junia-light.with(
  titre:                  [starchy-junia \ Documentation],
  auteurs:                ("MathYeiv",),
  sous-titre:             [Référence des modèles et fonctions \ \ #text(fill: blue)[#link("https://codeberg.org/MathYeiv/starchy-junia")]],
  tailles-police:         (1.4em, 1.3em, 1.2em, 1.1em, 1em, 1em),
  profondeur-sommaire:    3,
  avec-sommaire:          true,
  lang-doc:               "fr",
)

#show: fmp-corps-document

= Les trois modèles

#tidy.show-module(docs-modeles)

= Fonctions de mise en page et de contenu

#tidy.show-module(docs-fonctions)
