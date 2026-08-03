# Visual CeTZ

**Guide visuel de [CeTZ](https://typst.app/universe/package/cetz) 0.5.2 pour Typst.**

Chaque construction est montrée par son code et son rendu, côte à côte, dans
l'esprit de [VisualTikZ](https://ctan.org/pkg/visualtikz).

**→ [`Visual-CeTZ-0.5.2.pdf`](Visual-CeTZ-0.5.2.pdf) — 51 pages, 27 chapitres,
200 exemples.**

## Lire le guide

Le PDF se suffit à lui-même. Le code de gauche est exactement le contenu d'un
`cetz.canvas({ … })` après `import cetz.draw: *` ; le rendu de droite en est la
sortie réelle. Les exemples sont autonomes : copiez-collez, ça marche.

## Sommaire

| Ch. | Sujet |
|----|----|
| 1 | Prise en main, `canvas`, anatomie d'un appel |
| 2 | Les 11 systèmes de coordonnées |
| 3 | Formes : `line`, `rect`, `circle`, `arc`, courbes, chemins |
| 4 | Styles : niveaux, héritage, clés, dégradés |
| 5 | Marques : mnémoniques, formes, position, taille |
| 6 | Ancres : boussole, chemin, `anchor:`, ancres personnalisées |
| 7 | Groupes, `scope`, calques, intersections |
| 8 | Transformations |
| 9 | Dessin 3D : `ortho`, `perspective`, plans |
| 10 | Opérations booléennes |
| 11 | Décorations : zigzag, coil, wave, accolades |
| 12 | Angles |
| 13 | Arbres |
| 14 | Palettes |
| 15 | Recettes : diagrammes, courbes, cotation, hachures, graphes |
| 16 | Vecteurs et matrices |
| 17 | Étendre CeTZ : marques et coordonnées personnalisées |
| 18 | `cetz-plot` : courbes, axes, remplissages, formats |
| 19 | `chart` : barres, camembert, radar, boîte à moustaches |
| 20 | `cetz-venn` |
| 21 | SmartArt : processus et cycles |
| 22 | Recettes avancées : automate, Gantt, heatmap, chronogramme |
| 23 | Détails souvent ignorés (options fines de chaque fonction) |
| 24 | Galerie : figures complètes |
| 25 | Couverture complémentaire (contours, violons, annotations) |
| 26 | **Géométrie euclidienne en CeTZ pur** : centres du triangle, droite d'Euler, cercle des neuf points, Thalès, Simson, Napoléon, Ptolémée, coniques |
| 27 | Aide-mémoire et pièges fréquents |

## Recompiler

Il faut [Typst](https://github.com/typst/typst/releases) 0.14 ou plus récent.
Les paquets sont téléchargés automatiquement au premier lancement.

```sh
typst compile main.typ Visual-CeTZ-0.5.2.pdf
```

ou, avec le Makefile fourni :

```sh
make          # compile le PDF (ne fait rien s'il est à jour)
make force    # recompile inconditionnellement
make watch    # recompile à chaque modification, Ctrl-C pour arrêter
make clean    # supprime le PDF
```

`make` ne recompile que si `main.typ`, un chapitre ou `tpl.typ` est plus récent
que le PDF.

> **« Nothing to be done for 'all' » alors que j'ai modifié un fichier ?**
>
> C'est le cas juste après avoir dézippé l'archive : `unzip` restaure les dates
> d'origine des sources, qui sont *antérieures* à celle du PDF livré avec. `make`
> croit donc le PDF à jour. Trois remèdes, au choix :
>
> ```sh
> make force     # recompile sans poser de question
> make clean all # supprime le PDF, puis recompile
> touch *.typ    # rafraîchit les dates des sources
> ```
>
> Le problème ne se pose qu'une fois : vos modifications ultérieures porteront
> une date postérieure au PDF, et `make` les verra normalement.

**Si `typst` n'est pas dans votre `PATH`**, indiquez son chemin :

```sh
make TYPST=~/bin/typst
```

ou exportez-le une fois pour la session :

```sh
export TYPST=~/bin/typst
make
```

**Si vous n'avez pas `make`** (Windows sans outils Unix, notamment), la commande
`typst compile main.typ Visual-CeTZ-0.5.2.pdf` ci-dessus suffit — le Makefile ne
fait rien de plus.

## Organisation des sources

| Fichier | Rôle |
|---|---|
| `main.typ` | page de titre, sommaire, inclusion des chapitres |
| `tpl.typ` | mise en page et fonctions `ex()`, `exr()`, `note()`, `api()` |
| `ch01.typ` … `ch08.typ`, `ch10.typ` … `ch16.typ` | les chapitres |
| `ch09.typ` | l'aide-mémoire, inclus en dernier |

**Les exemples ne sont pas recopiés à la main.** `ex()` reçoit un bloc de code
brut, l'affiche tel quel *et* l'évalue dans un `cetz.canvas`. Le code montré et
l'image affichée ne peuvent donc jamais diverger.

Pour ajouter un chapitre : créez `ch17.typ` commençant par
`#import "tpl.typ": *`, puis ajoutez `#include "ch17.typ"` dans `main.typ`
avant la ligne `#include "ch09.typ"`.

## Dépendances

Uniquement des paquets publiés :

- `@preview/cetz:0.5.2`
- `@preview/cetz-plot:0.1.4` — chapitres 18, 19, 21, 25
- `@preview/cetz-venn:0.2.0` — chapitre 20

Le chapitre 26 n'utilise **que** les primitives de CeTZ, sans aucune
bibliothèque de géométrie.

Chaque exemple faisant appel à un paquet autre que CeTZ affiche sa ligne
`#import` en commentaire sur sa première ligne, pour rester copiable tel quel.

## Licence

Le contenu du guide (texte, exemples, figures) est placé sous
[CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) : réutilisez-le
librement, y compris commercialement, en citant la source.
FERGOUS Abdelhak.
