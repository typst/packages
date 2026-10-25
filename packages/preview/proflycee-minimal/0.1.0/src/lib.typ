// Copyright (c) 2026 Arthur Meyer
// SPDX-License-Identifier: MIT
// Voir le fichier LICENSE à la racine du paquet.

// Point d'entrée du paquet.
//
// proflycee-minimal : portage minimaliste, en Typst, de quelques commandes du
// paquet LaTeX ProfLycee (Cédric Pierquet). Point d'entrée déclaré dans
// typst.toml : seules les fonctions ci-dessous sont exportées.
//
// Organisation de src/ (une commande ProfLycee par fichier, rangées par thème) :
//   lib.typ                      ce fichier
//   deps.typ                     dépendances externes (cetz)
//   outils.typ                   outils communs (non exportés)
//   arbre.typ                    moteur commun des arbres (non exporté)
//   analyse/cercle-trigo.typ
//   analyse/resolution-approchee.typ
//   analyse/suites.typ
//   analyse/numworks.typ          écrans NumWorks dessinés
//   arithmetique/pgcd.typ
//   arithmetique/modulo.typ
//   arithmetique/conversion-bases.typ
//   arithmetique/division-eucl.typ
//   arithmetique/diviseurs.typ
//   probas/calculs-lois.typ
//   probas/arbre-probas.typ
//   probas/loi-graphe.typ
//
// Correspondance avec ProfLycee :
//   \ResolutionApprochee → resolution-approchee (renvoie un dictionnaire :
//                         defaut, exces, approchee, valeur)
//   (pas d'équivalent) →  numworks-solveur, numworks-graphique, numworks-suite
//                         (écrans de calculatrice dessinés, au lieu des
//                         captures et du tableau de la doc)
//   \CalculTermeRecurrence → calcul-terme-recurrence
//   (pas d'équivalent) →  suite-recurrente (la fonction n => u_n)
//   \SolutionSeuil     →  solution-seuil
//   \CompteurSeuil     →  rang-seuil
//   \CercleTrigo  →  cercle-trigo (canvas autonome)
//                    cercle-trigo-dessin (éléments seuls, dans son propre canvas)
//   \PresentationPGCD  →  presentation-pgcd
//   (pas d'équivalent) →  remontee-euclide (remontée de l'algorithme, Bézout)
//   \CalcBinomP, \CalcBinomC, …, \CalcNormC, \CalcExpoC
//                      →  calc-binom-p, calc-binom-c, …, calc-norm-c, calc-expo-c
//   \BinomP, \BinomC, …, \NormaleC, \ExpoC
//                      →  binom-p, binom-c, …, normale-c, expo-c
//   (pas d'équivalent) →  loi-binomiale, loi-poisson, loi-geometrique,
//                         loi-hypergeometrique, loi-normale, loi-exponentielle
//                         (une loi = une fonction : X(k), X(a, b))
//   \ArbreProbasTikz   →  arbre-probas
//   EnvArbreProbasTikz →  arbre-probas-dessin
//   \LoiNormaleGraphe  →  loi-normale-graphe (+ loi-normale-graphe-dessin)
//   \LoiExpoGraphe     →  loi-expo-graphe (+ loi-expo-graphe-dessin)
//   \ResteMod, \QuoMod →  reste-mod, quo-mod
//   (pas d'équivalent) →  modulo(n) (la fonction a => reste-mod(a, n))
//   \ConversionEntreBases → conversion-entre-bases
//   (pas d'équivalent) →  conversion(sens) (la fonction nb => …)
//   \DivisionEucl      →  division-eucl
//   \DivEucl           →  div-eucl
//   \ListeDiviseurs    →  liste-div
//   \ArbreDiviseurs    →  arbre-div (+ arbre-div-dessin)
//   \DecompFactPremiers → dpfp (noms abrégés pour le §60)
//   \PresFactPremiers  →  prespfp
//   \SimplFracDecomp   →  simpfrac

// Analyse
#import "analyse/cercle-trigo.typ": cercle-trigo, cercle-trigo-dessin
#import "analyse/resolution-approchee.typ": resolution-approchee
#import "analyse/suites.typ": calcul-terme-recurrence, suite-recurrente, solution-seuil, rang-seuil
#import "analyse/numworks.typ": numworks-solveur, numworks-graphique, numworks-suite

// Arithmétique
#import "arithmetique/pgcd.typ": presentation-pgcd, remontee-euclide
#import "arithmetique/modulo.typ": reste-mod, quo-mod, modulo
#import "arithmetique/conversion-bases.typ": conversion-entre-bases, conversion
#import "arithmetique/division-eucl.typ": division-eucl, div-eucl
#import "arithmetique/diviseurs.typ": (
  liste-div, arbre-div, arbre-div-dessin,
  dpfp, prespfp, simpfrac,
)

// Probabilités
#import "probas/calculs-lois.typ": (
  loi-binomiale, loi-poisson, loi-geometrique, loi-hypergeometrique, loi-normale, loi-exponentielle,
  calc-binom-p, calc-binom-c, calc-poiss-p, calc-poiss-c, calc-geom-p, calc-geom-c,
  calc-hypergeom-p, calc-hypergeom-c, calc-norm-c, calc-expo-c,
  binom-p, binom-c, poisson-p, poisson-c, geom-p, geom-c, hypergeom-p, hypergeom-c, normale-c, expo-c,
)
#import "probas/arbre-probas.typ": arbre-probas, arbre-probas-dessin
#import "probas/loi-graphe.typ": loi-normale-graphe, loi-normale-graphe-dessin, loi-expo-graphe, loi-expo-graphe-dessin
