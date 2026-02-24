// Patron de format Typst pour soumettre un article long à ORASIS (ou RFIAP).
// Sans garanties. 
// Deux colonnes, pas de numérotation et 10 points.

#import "@preview/sunny-orasis:0.1.0": orasis

#show: orasis.with(
  
  title: "Mon merveilleux article pour ORASIS",
  
  authors: (
    (name: "M. Oimême", affiliation: "1"),
    (name: "M. Oncopain", affiliation: "2"),
  ),
  
  affiliations: ("Mon Institut", "Son Institut"),
  emails: ("Mon adresse électronique",),
  
  abstract-fr: [
    Ceci est mon résumé pour les journées francophones des jeunes chercheurs en vision par ordinateur (ORASIS). Il doit occuper une dizaine de lignes.
  ],
  keywords-fr: [Exemple type, format, modèle.],
  
  abstract-en: [
    This is the English version of the abstract. Exactly as in French it must be short. It must exhibit the same content...
  ],
  keywords-en: [Example, model, template.],
)

= Introduction
Le contenu de l'article peut être rédigé avec n'importe quel formateur ou traitement de texte, pourvu qu'il réponde aux critères de présentation donnés ici. L'objectif visé est de proposer une unité de présentation des actes, et nous vous invitons à respecter ce modèle autant que le permet votre logiciel favori.

La soumission se fait obligatoirement au *format PDF*, quelque soit le logiciel d'édition. Chaque article doit être compris entre 6 et 8 pages.

Pour les auteurs utilisant Typst, le fichier source de ce texte (`orasis.typ`) est lui-même une base pour obtenir une sortie conforme avec Typst#footnote[patron validé sur la version Typst 0.12.0].

Les autres trouveront des renseignements (peut-être) plus lisibles pour eux dans le fichier `orasis.doc` (Word) ou le fichier `orasis.tex` (LaTeX).

La base du texte est du Times-Roman 10 points présenté en deux colonnes. La séparation inter-colonne est de 1 cm.

Le titre principal est en 14 points gras (28 points = 1cm).

Dans les sections, le titre est en 12 points gras. Les para-
graphes ne sont pas décalés.

Les sous-sections numérotées comme suit :

== État de l'art
Les en-têtes sont également en 12 points gras.

Il n'y a pas nécessairement d'espacement entre les paragraphes.

Les références à la bibliographie peuvent être de la forme @foo:baz @key:foo. Les numéros correspondent à l'ordre d'apparition dans la bibliographie, pas dans le texte. L'ordre alphabétique est conseillé.

= Le coin Typst
Pour les utilisateurs de Typst, ce patron est minimaliste et vous aurez besoin de la documentation Typst pour insérer équations et images.

Les fichiers nécessaires pour la compilation sont :
- `orasis.typ` (le patron)
- `main.typ` (le cœur de votre article)
- `refs.bib` (vos références)
- `ref_style.csl` (_facultatif_) (pour afficher les références [1], [2] de la façon suivante : [1, 2])

#set heading(numbering: none) // Pas de numérotations pour l'annexe et la bibliographie
= Annexe
Merci de votre participation.

// Bibliographie avec fichier permettant aux citations juxtaposées d'être fusionnées (IEEE) :
#bibliography("refs.bib", title: "Références", style: "ref_style.csl")
// Version sans le fichier .csl :
// #bibliography("references.bib", title: "Références")