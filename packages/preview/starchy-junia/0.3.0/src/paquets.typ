// Paquets utilisés en interne par le modèle
// Les paquets proposés pour la rédaction (cetz, fletcher, lilaq…) sont importés côté projet,
// dans `Modele/ressources/commun.typ`
// On les trouve à cette addresse : https://typst.app/universe

// Glossaire
#import "@preview/glossarium:0.5.10" as glossarium: make-glossary, register-glossary, print-glossary

// Récupération des titres de la page actuelle
#import "@preview/hydra:0.6.3": hydra

// Mise en forme des blocs de code (numéros de lignes, langage, surlignage…), utilisé comme module : `codly.new`, `codly.set_`…
#import "@preview/codly:2.0.0" as codly
// Noms, couleurs et icônes des langages pour codly
#import "@preview/codly-languages:0.1.10": codly-languages
