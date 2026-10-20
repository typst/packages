# Référence API — Arabic Exam Kit

Cette référence liste les composants publics exportés par `src/lib.typ`.
Les paramètres complets et des exemples exécutables sont dans
[`guide.typ`](guide.typ).

## Styles communs

| Fonction | Paramètres importants | Usage |
|---|---|---|
| `mf-style` | `mode`, `roughness`, `dir`, `seed` | familles décoratives et math-faciles |
| `exercise-style` | `mode`, `roughness`, `dir`, `color_mode`, `seed` | exercices 1 à 10 |
| `exam-style` | `mode`, `roughness`, `dir`, `seed` | sujet rouge |
| `sexam-style` | `mode`, `roughness`, `dir`, `seed` | sujet noir et blanc |
| `wexam-style` | `mode`, `roughness`, `dir`, `seed` | sujet bleu étoilé |

## Cartes et effets

| Fonction | Rôle |
|---|---|
| `mf-card`, `mf-box`, `mf-grid-box` | conteneurs pédagogiques de base |
| `mf-perforated-box`, `mf-spiral-box` | papier perforé / carnet spirale |
| `mf-choice`, `mf-pill` | QCM et boutons |
| `mf-ribbon-flat`, `mf-ribbon-arched` | rubans vectoriels |
| `mf-magnetic-filings-box` | cadre de limailles de fer |
| `mf-coffee-stain`, `mf-coffee-blot` | anneau et tache de café |
| `mf-paint-splat` | éclaboussures `model: 1` à `9` |
| `worksheet` | fiche pédagogique complète responsive, normale ou rough |

## Exercices numérotés

`exercise-1` à `exercise-9` utilisent un argument `title:` facultatif et un
corps entre crochets. `exercise-10` accepte en plus :

- `columns:` ;
- `cells:` ;
- `title-band-width:` ;
- `title-band-extra:` ;
- `title-band-height:` ;
- `title-band-extra-height:`.

## Sujet rouge

| Fonction | Rôle |
|---|---|
| `exam-page-frame` | cadre couvrant la page, avec `height:` et `footer:` facultatif |
| `exam-header` | en-tête deux lignes et flèches rouges superposées |
| `exam-duration`, `exam-notice`, `exam-meta-line` | métadonnées sous l’en-tête |
| `exam-exercise-ribbon` | ruban de titre d’exercice |
| `exam-exercise-box` | titre + contenu d’exercice |
| `exam-circle-geometry` | figure de cercle `ctz-euclide` |

## Sujet sexam

| Fonction | Rôle |
|---|---|
| `sexam-header` | trois lignes et deux règles noires |
| `sexam-exercise-heading` | intitulé à droite, filet à gauche |
| `sexam-score-box` | boîte de score ; donnez `label: "2"` |
| `sexam-part` | question avec score facultatif |
| `sexam-footer`, `sexam-page` | bas de page et shell de page |

## Sujet 2AM bleu

| Fonction | Rôle |
|---|---|
| `wexam-header` | bande étoilée, cartes titre/année/durée |
| `wexam-notice` | message et danger rouge à droite |
| `wexam-exercise-heading` | pilule cyan et points rouges |
| `wexam-number-box`, `wexam-question` | boîtes de numéros et questions |
| `wexam-angle-figure` | figure d’angles vectorielle |
| `wexam-house-figure` | façade vectorielle |
| `wexam-footer`, `wexam-page` | structure de page et footer |
