# coquille-st-jacques

Illustrated course handout template for French school teachers — cover
page, styled table of contents, ready-to-use colored callout boxes
(definition, key point, warning, example, analogy, theorem…),
auto-test questions with drawn checkboxes, colored-header tables, and
captioned diagrams.

Conçu et utilisé dans l'atelier *« Un cours avec l'IA »* à l'école
Saint-Jacques d'Hazebrouck.

Fournit :

- une **page de couverture** avec image de fond, sur-titre, titre, sous-titre
  et ligne de métadonnées,
- une **page de sommaire** stylée,
- des **encarts colorés** prêts à l'emploi (`#def`, `#key`, `#warn`, `#ex`,
  `#analogy`, `#keyhint`, `#atelier`, `#theorem`),
- un **bloc de question** pour auto-test (`#qcm-q`) avec case à cocher
  dessinée (pas de glyphe Unicode → zéro avertissement de substitution
  de police sur [typst.app](https://typst.app)),
- des **tableaux** avec en-tête coloré (`#head`) et cellules de catégorie
  (`#cat-cell`),
- un helper de **schéma légendé** (`#schema`) et une **figure inline** (`#fig`),
- une **palette de couleurs** réutilisable.

## Démarrer un nouveau projet

Sur [typst.app](https://typst.app), bouton **« Start from template »**,
choisissez *coquille-st-jacques* — vous obtenez un projet pré-rempli
prêt à éditer.

Ou en ligne de commande :

```bash
typst init @preview/coquille-st-jacques
```

## Utiliser le modèle dans un projet existant

```typ
#import "@preview/coquille-st-jacques:0.1.0": *
```

## Exemple minimal

```typ
#import "@preview/coquille-st-jacques:0.1.0": *

#show: course-template.with(
  title: "Mon cours",
  author: "Prénom Nom",
  eyebrow: [MATIÈRE — NIVEAU],
  cover-title: [Titre du cours],
  cover-subtitle: "Sous-titre éventuel",
  cover-metadata: [Métadonnées · contexte],
  cover-background: image("ma-couverture.png", width: 100%, height: 100%, fit: "cover"),
  show-toc: true,
)

= Premier chapitre

Voici une #def[définition].

#key[À retenir : l'essentiel tient en une phrase.]

#warn[Attention à ne pas confondre…]

#qcm-q(1, [Quelle est la capitale de la France ?],
  options: ("Paris", "Lyon", "Marseille"))
```

## API

### `course-template(…)`

Wrap principal à utiliser avec `#show: course-template.with(…)`.

Paramètres :

| Nom | Type | Défaut | Description |
|---|---|---|---|
| `title` | str | `"Document"` | Titre du document (métadonnée PDF). |
| `author` | str | `""` | Auteur. |
| `eyebrow` | content / none | `none` | Sur-titre de couverture. |
| `cover-title` | content / none | `none` | Titre principal de couverture. |
| `cover-subtitle` | str / none | `none` | Sous-titre. |
| `cover-metadata` | content / none | `none` | Ligne basse de couverture. |
| `cover-background` | content / none | `none` | Image de fond de couverture, **déjà construite** avec `image(...)`. Les images chargées par un package ne pouvant pas résoudre les chemins de l'appelant, il faut passer le résultat de `image(...)`, pas un chemin. |
| `show-toc` | bool | `true` | Afficher le sommaire. |
| `toc-title` | str | `"Sommaire"` | Titre du sommaire. |
| `body-font` | str | `"DejaVu Serif"` | Police du corps. |
| `body-size` | length | `11pt` | Taille du corps. |
| `heading-font` | str | `"DejaVu Sans"` | Police des titres. |
| `lang` | str | `"fr"` | Langue. |
| `margin` | dict | `(top: 18mm, bottom: 22mm, left: 18mm, right: 18mm)` | Marges. |

### Encarts

- `#def[…]` — Définition (bleu)
- `#key[…]` — À retenir (ambre)
- `#warn[…]` — Attention (rouge)
- `#ex[…]` — Exemple concret (vert)
- `#analogy[…]` — Analogie (rose, italique)
- `#keyhint[…]` — Clé de compréhension (violet)
- `#atelier[…]` — À construire en atelier (turquoise)
- `#theorem[…]` — Théorème (slate / ardoise — pour les maths)

### Auto-test

```typ
#qcm-q(num, question, options: none, lines: 0)
```

- `num` : numéro de la question
- `question` : contenu (content)
- `options` : liste de choix (génère des cases à cocher dessinées)
- `lines` : nombre de lignes pointillées (réponse libre)

### Tableaux

```typ
#table(
  columns: 3,
  head[Colonne A][Colonne B][Colonne C],
  cat-cell[Catégorie], [valeur], [valeur],
)
```

### Schéma légendé

```typ
#schema(image("chemin/vers/image.png", width: 100%), [Légende de l'image], breakpage: true)
```

L'argument est un **contenu image** (résultat de `#image(...)`), pas un
chemin, pour la même raison que `cover-background`.

### Figure inline légendée

Variante compacte de `schema` pour les figures vectorielles ou les
petits schémas qui restent **dans le flot** du texte (pas de saut de
page, et la figure est insécable) :

```typ
#fig(
  cetz.canvas({ /* … */ }),
  [Légende de la figure],
)
```

Le premier argument est n'importe quel contenu (figure CETZ, image,
bloc personnalisé). Idéal pour les illustrations qui accompagnent un
calcul ou une démonstration.

### Couverture / sommaire séparés

`#cover-page(…)` et `#toc-page(…)` sont également exposés si vous
souhaitez les utiliser indépendamment du template.

## Polices

Le modèle utilise **DejaVu Serif** (corps) et **DejaVu Sans** (titres).
[typst.app](https://typst.app) ne les fournit pas en standard : pour un
rendu identique, joignez le dossier `fonts/` à votre projet (ou
sélectionnez d'autres polices via `body-font` / `heading-font`).

## Licence

Apache-2.0
