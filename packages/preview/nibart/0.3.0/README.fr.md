# nibart

**Une approche « à la MetaPost » pour promener une plume le long d'un chemin** — pour Typst 0.15+.\
[English](README.md) · [Manuel (FR)](https://github.com/fergousA/nibart/blob/3ecc4ffd61ba743302bc9a7a4a96a1f80c77de0c/docs/manual-fr.pdf) · [Manual (EN)](https://github.com/fergousA/nibart/blob/3ecc4ffd61ba743302bc9a7a4a96a1f80c77de0c/docs/manual-en.pdf) · [Galerie](https://github.com/fergousA/nibart/tree/3ecc4ffd61ba743302bc9a7a4a96a1f80c77de0c/examples) · [Journal des modifications](https://github.com/fergousA/nibart/blob/3ecc4ffd61ba743302bc9a7a4a96a1f80c77de0c/CHANGELOG.md)

`nibart` apporte à Typst le cœur de Metafont/MetaPost : des chemins lissés par l'algorithme de Hobby (directions, tensions,
« curl »), et des *plumes* — cercle, ellipse, plume plate, polygone, ou plume dont la largeur et l'angle changent le long du
trait — dont le contour balayé exact est calculé pour vous. Calligraphie, lettrage, fioritures, schémas à main levée,
figures techniques dans la tradition MetaPost : le tout sous forme de formes vectorielles ordinaires.

![Galerie de chemins calligraphiques, d'ornements et de dessins décoratifs](https://raw.githubusercontent.com/fergousA/nibart/3ecc4ffd61ba743302bc9a7a4a96a1f80c/docs/img/gallery.jpg)

## Installation

Depuis **Typst Universe**, rien à installer : `#import "@preview/nibart:0.3.0" as nib`.

## Démarrage rapide

```typ
#import "@preview/nibart:0.3.0" as nib

// un chemin en syntaxe MetaPost, une plume plate
#nib.nib-stroke(
  nib.mp-path("(0,0){up}..(25,45)..(60,10)..(95,50)"),
  pen: nib.broadnib(10pt, t: 2.5pt, angle: 35deg),
)

// une plume dont la largeur varie le long du trait
#nib.nib-stroke(
  nib.mp-path("(0,0)..(30,40)..(60,0)..(90,40)"),
  pen: nib.nibpen(
    (at: 0%, width: 3pt), (at: 50%, width: 14pt, thinness: 40%), (at: 100%, width: 3pt),
    angle: 40deg,
  ),
  fill: rgb("#7a2e0e"),
)
```

Les axes suivent MetaPost (*y vers le haut*, angles anti-horaires). Préférez `nib.xxx` à `import "…": *` : le paquet
exporte des noms génériques (`draw`, `cubic`, `reverse`, `pressure`…).

## Fonctionnalités

- **Langage de chemins** — `mp-path("(0,0){up}..tension 1.5..(40,20)--cycle")` : `..`, `--`, `{dir}`, `{curl}`, `tension`,
  `controls`, `cycle` ; aussi `mp-path-pts`, `cubic`, `straight`, `polyline`, `cubics`, `path-join`.
- **Algorithme de Hobby**, comparé à `mpost` (mêmes points de contrôle, écart maximal < 0,01 pt sur 17 chemins de test).
- **Plumes** — `pencircle`, `penellipse`, `broadnib`, `penpoly`, `pensquare`, `penrazor`, et `nibpen` avec arrêts le long de
  l'abscisse curviligne et mode optionnel *suivre la tangente*.
- **Contours exacts** — la région balayée est calculée géométriquement (sans estampage), avec union de tous les recouvrements.
- **Effets calligraphiques** — pointillés irréguliers avec jitter, pression intermittente, morceaux empilés, contour, vue de debug.
- **Opérations sur chemins** — `point-of`, `direction-of`, `arclength`, `arctime`, `subpath`, `reverse`, `closest-time`,
  `intersection-times`, `intersection-point`, boîte englobante, transformations affines.
- **Nœuds et entrelacs** — `knot(...)` : croisements automatiques (aussi au sein d'un même brin), dessus/dessous alterné, style « gap » ou « weave » celtique, liens, tresses.
- **Ornements calligraphiques** — `copperplate` (plume pointue), `prongs` (plume à dents), `delimiter` (accolades et parenthèses entre deux points).
- **Chirurgie de chemins** — `offset` (parallèles), `shorten`, `split-at`, `remove-intervals`, `weld`, `join-smooth`, `round-corners`, `frames-along`…
- **Figures** — `mp-fig` (comme `beginfig … endfig`) avec points, étiquettes, remplissages, squelettes et grille optionnelle ;
  la ligne de base est gérée, les figures peuvent donc s'insérer dans le texte.

### nibart : nœuds, accolades, plume pointue

Trèfle, anneaux olympiques et borroméens, tresses et entrelacs celtiques ; accolades calligraphiques ; plume copperplate ; parallèles, coins arrondis et repères le long d'un chemin — [`examples/nibart.typ`](https://github.com/fergousA/nibart/blob/3ecc4ffd61ba743302bc9a7a4a96a1f80c77de0c/examples/nibart.typ) (`--input lang=en` pour les légendes en anglais).

![Nœuds, entrelacs celtiques, accolades calligraphiques et ornements à la plume pointue](https://raw.githubusercontent.com/fergousA/nibart/3ecc4ffd61ba743302bc9a7a4a96a1f80c77de0c/docs/img/nibart.jpg)

### L'insolite

Une partition aux liaisons effilées, des nœuds qui passent dessus/dessous (calculés avec `intersection-times`), une enseigne au néon,
une broderie, un cerisier fractal, un enso au pinceau sec, une sphère gravée, un guilloché, une carte et un croquis à main levée —
un seul fichier, [`examples/insolite.typ`](https://github.com/fergousA/nibart/blob/3ecc4ffd61ba743302bc9a7a4a96a1f80c77de0c/examples/insolite.typ) (`--input lang=en` pour les légendes en anglais).

| | | |
|---|---|---|
| ![](https://raw.githubusercontent.com/fergousA/nibart/3ecc4ffd61ba743302bc9a7a4a96a1f80c77de0c/docs/img/unexpected-1.jpg) | ![](https://raw.githubusercontent.com/fergousA/nibart/3ecc4ffd61ba743302bc9a7a4a96a1f80c77de0c/docs/img/unexpected-2.jpg) | ![](https://raw.githubusercontent.com/fergousA/nibart/3ecc4ffd61ba743302bc9a7a4a96a1f80c77de0c/docs/img/unexpected-3.jpg) |

Les sources complètes des images sont dans [`examples/`](https://github.com/fergousA/nibart/tree/3ecc4ffd61ba743302bc9a7a4a96a1f80c77de0c/examples) (`galerie`, `exotique`, `boites`, `calligraphie`, `insolite`, `nibart`, `demo`, `chat`, `ile`, `ile-chat`, `podium`).
Dans un clone du dépôt : `typst compile --root . examples/galerie.typ`.
Les exemples que le manuel ne montre pas sont réunis, avec aperçu, description, fonctions utilisées et commande de construction, dans une galerie illustrée générée avec `sh scripts/build-gallery.sh && make gallery`. La plupart des exemples sont bilingues : ajoutez `--input lang=en` ou `--input lang=fr`.

## Documentation

Le manuel de référence (français et anglais ; chaque fonction avec son tableau de paramètres et un exemple détaillé, tous exécutés par le paquet lui-même) est dans [`docs/`](https://github.com/fergousA/nibart/tree/3ecc4ffd61ba743302bc9a7a4a96a1f80c77de0c/docs) :
[`manual-fr.pdf`](https://github.com/fergousA/nibart/blob/3ecc4ffd61ba743302bc9a7a4a96a1f80c77de0c/docs/manual-fr.pdf), [`manual-en.pdf`](https://github.com/fergousA/nibart/blob/3ecc4ffd61ba743302bc9a7a4a96a1f80c77de0c/docs/manual-en.pdf). Pour le reconstruire :
`typst compile --root . --input lang=fr docs/manual.typ`.

## Limites

- Non implémentés : `atleast`, `&`, `buildcycle` ; `...` se comporte comme `..`.
- `draw` renvoie des formes remplies ; le contenu de `mp-label` n'entre pas dans la boîte englobante automatique.
- La géométrie est dans un plugin WebAssembly (`nibart.wasm`) : le paquet fonctionne avec le CLI Typst et les paquets d'Universe.
- Les plumes variables, pointillés et pression sont plus lents que les plumes fixes (voir le manuel).

## Développement

Les sources Rust du plugin sont dans `rust/` dans le dépôt (hors du paquet publié). `make wasm` reconstruit `nibart.wasm`, `make test`
lance les tests, `make docs` reconstruit le manuel, `make package` produit et valide le dossier publiable dans `dist/`.

## Licence

Auteur : **FERGOUS Abdelhak** ([@fergousA](https://github.com/fergousA)) · dépôt : <https://github.com/fergousA/nibart>.\
[MIT](LICENSE). Crates tierces : [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md). Inspiré de MetaPost (D. Knuth,
J. D. Hobby) et du paquet `nibst` (B. Auguie) : les options calligraphiques reproduisent son comportement décrit ; aucun
code de ces projets n'est inclus.
