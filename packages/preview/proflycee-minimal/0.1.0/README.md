# proflycee-minimal

Quelques commandes du package LaTeX
[ProfLycee](https://ctan.org/pkg/proflycee) de **Cédric Pierquet**, portées en
Typst pour les cours de mathématiques du lycée : cercle trigonométrique,
résolution approchée d'équations et suites récurrentes (avec des écrans de
calculatrice NumWorks dessinés), arithmétique (algorithme d'Euclide et
remontée de Bézout, modulo, bases, division euclidienne, diviseurs, facteurs
premiers) et probabilités (calculs avec les lois usuelles, arbres, schémas
des lois normale et exponentielle).

> **Note :** une petite partie seulement de ProfLycee, qui reste la
> référence. Écrit d'abord pour mon usage personnel, le paquet pourra évoluer
> de façon incompatible entre deux versions `0.x`. Une documentation complète
> suivra ; les clés de chaque commande sont décrites en tête de son fichier
> source.

*A few commands from Cédric Pierquet's LaTeX package ProfLycee, ported to Typst
for French high-school maths (in French): trigonometric circle, approximate
equation solving and recursive sequences with drawn NumWorks calculator
screens, arithmetic (Euclid's algorithm with Bézout coefficients, modular
reduction, base conversion, Euclidean division, divisors, prime
factorisation) and probability (usual distributions, trees, density
sketches).*

## Démarrage rapide

```typ
#import "@preview/proflycee-minimal:0.1.0": *

#cercle-trigo(rayon: 2.5)

$1234 equiv #reste-mod(1234, 26) space [26]$ et #div-eucl(145, 7, aff-verif: true).

#presentation-pgcd(150, 27)
```

Les noms des clés sont ceux de ProfLycee, en kebab-case français
(`AffValeurs` → `aff-valeurs`) ; une version étoilée devient une clé
(`\ResteMod*` → `reste-mod(…, negatif: true)`). Chaque commande dessinée
existe aussi en version `…-dessin`, à placer dans son propre canvas
[CeTZ](https://typst.app/universe/package/cetz).

Plusieurs commandes sont des *fabriques* : on crée une fois l'objet (une loi,
une suite, une réduction modulo n, une conversion), puis on l'utilise
directement.

## Analyse

```typ
#cercle-trigo(rayon: 2.5, equation-sin: true, sin: -30, aff-valeurs: false)

#let s = resolution-approchee(x => calc.pow(x, 3) - 2 * x * x - x - 1, k: 2, intervalle: (0, 10))
$x_0 approx #s.defaut$ par défaut, $x_0 approx #s.exces$ par excès.
#numworks-solveur(s) #numworks-graphique(s, fenetre: (-1, 4, -4, 6))

#let f = x => 1 + (1 + x * x) / (1 + x)
$u_7 approx #calcul-terme-recurrence(f, no: 1, uno: 2, n: 7)$ ;
#solution-seuil(f, 5, no: 1, uno: 2, balayage: true).
#numworks-suite(f, no: 1, uno: 2)
```

| ProfLycee | proflycee-minimal |
|---|---|
| `\CercleTrigo` | `cercle-trigo`, `cercle-trigo-dessin` |
| `\ResolutionApprochee` | `resolution-approchee` (dictionnaire : `defaut`, `exces`, `approchee`, `valeur`) |
| `\CalculTermeRecurrence` | `calcul-terme-recurrence`, `suite-recurrente` (fabrique) |
| `\SolutionSeuil`, `\CompteurSeuil` | `solution-seuil`, `rang-seuil` |
| — | `numworks-solveur`, `numworks-graphique`, `numworks-suite` (écrans dessinés) |

## Arithmétique

```typ
#presentation-pgcd(150, 27) #remontee-euclide(150, 27)

#let m26 = modulo(26)
$1234 equiv #m26(1234) space [26]$, $7^50 equiv #reste-mod(7, 8, puissance: 50) space [8]$

#conversion-entre-bases("16->2", "ACDC", aff-bases: true)

#liste-div(60) \ #dpfp(2781240) \ #simpfrac(1320, 1248, barrer: true, aff-couleur: true)
#arbre-div(60)
```

| ProfLycee | proflycee-minimal |
|---|---|
| `\PresentationPGCD` | `presentation-pgcd`, et `remontee-euclide` (Bézout, absente de ProfLycee) |
| `\ResteMod`, `\QuoMod` | `reste-mod`, `quo-mod`, `modulo` (fabrique) |
| `\ConversionEntreBases` | `conversion-entre-bases`, `conversion` (fabrique) |
| `\DivisionEucl`, `\DivEucl` | `division-eucl`, `div-eucl` |
| `\ListeDiviseurs`, `\ArbreDiviseurs` | `liste-div`, `arbre-div` |
| `\DecompFactPremiers`, `\PresFactPremiers`, `\SimplFracDecomp` | `dpfp`, `prespfp`, `simpfrac` |

## Probabilités

```typ
#let X = loi-binomiale(5, 0.4)
$P(X = 3) approx #X(3)$, $P(X >= 2) approx #X(2, none, arrondi: 4)$ \
$P(Y >= 600) approx #normale-c(550, 30, 600, none, arrondi: 4)$

#arbre-probas((
  ($A$, [0,5]), ($B$, [0,4]), ($overline(B)$, [0,6]),
  ($overline(A)$, [0,5]), ($B$, [0,1]), ($overline(B)$, [0,9]),
))

#loi-normale-graphe(150, 12.5, 122, 160, largeur: 4, hauteur: 2)
```

| ProfLycee | proflycee-minimal |
|---|---|
| `\CalcBinomP`, `\BinomP`, … `\NormaleC`, `\ExpoC` | `calc-binom-p`, `binom-p`, … `normale-c`, `expo-c` |
| — | `loi-binomiale`, `loi-poisson`, `loi-geometrique`, `loi-hypergeometrique`, `loi-normale`, `loi-exponentielle` (fabriques) |
| `\ArbreProbasTikz`, `EnvArbreProbasTikz` | `arbre-probas`, `arbre-probas-dessin` |
| `\LoiNormaleGraphe`, `\LoiExpoGraphe` | `loi-normale-graphe`, `loi-expo-graphe` |

## Remerciements

Merci à **Cédric Pierquet** : les idées et les noms des clés viennent de
[ProfLycee](https://ctan.org/pkg/proflycee), les limites de cette adaptation
sont les miennes. Dessins : [CeTZ](https://typst.app/universe/package/cetz).
NumWorks est une marque de NumWorks ; ce paquet n'en est pas affilié, ses
écrans sont de simples dessins pédagogiques.

## Licence

MIT. Voir [LICENSE](LICENSE).

proflycee-minimal est une réécriture indépendante en Typst : il reprend des
idées et les noms des clés de ProfLycee (distribué sous LPPL 1.3c), mais pas
son code.
