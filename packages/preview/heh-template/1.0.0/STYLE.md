# Règles de formatage - template HEH Typst

Les règles suivantes sont **complémentaires** au style par défaut appliqué par `typststyle`. Pour appliquer automatiquement le style de `typstyle`, utilisez la commande `just format`

## Règles de base

### Indentation

- Le code est indenté avec une longeur de **2 espaces**
- Les variables et noms de fonctions utilisent la convention **kebab-case**
- Les blocs (`()`, `{}`, `[]`, ...) doivent être indentés selon la hiérarchie du document

### Longeur des lignes

- Maximum de 100 charactères par ligne

### Espacement

- Tout les variables, opérateurs, et blocs sont **entourés d'un espace**. Par exemple, on écrira `200px + 200px` au lieu de `200px+200px`.
- Les virgules ne sont **pas précédées d'un espace**
- Les virgules qui ne constituent **pas la fin de la ligne sont succédées par un espace**

## Blocs

- L'accolade ouvrante **peut se situer sur la même ligne**
- L'accolade fermante doit se trouver sur **sa propre ligne**
- Les fonctions et les blocs de contenu ne contenant qu'une ligne ne **doivent pas utiliser d'accolades**
- Si un bloc est quasiment composé exclusivement de code et **d'un peu de markup**, il vaut mieux utiliser **un bloc de code**

## Fonctions et appels de fonction

- Les valeurs par défaut des paramètres d'une fonction **doivent être utiles pour la compréhension du code si nécéssaire**
- Si la ligne des paramètres est trop longue, les paramètres peuvent être listées sur plusieurs lignes (un paramètre par ligne)
- Le raccourci `#function(params)[content]` **devrait** être utilisé uniquement si il n'y a pas de `params`, par exemeple pour `#function[content]`. Dans les autres cas, la syntaxe `#function(params, content)` **devrait** être utilisée

## Conditions, boucles, ...

- Les paramètres doivent être **espacés** d'un espace si ils sont mis entre paranthèses

## Commentaires

- Les commentaires **doivent** être placés au dessus du code qu'ils concernent

## Fichiers

- Les fichiers **doivent** être terminés par une ligne vide

