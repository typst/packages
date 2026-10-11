# nibframe

**Cadres et bordures** décoratifs pour une page — ou pour n'importe quelle boîte — dessinés avec [nibart](https://typst.app/universe/package/nibart) :
soixante-dix-neuf styles — arabesque, tresse, double tresse et entrelacs celtiques, guirlandes florales, étoiles islamiques, clé grecque, guilloché de billet, Art déco, chaîne, accolades, perles, baroque, nœuds de Salomon, zellige, seigaiha, timbre-poste, pellicule, néon, enluminure… Le dessus/dessous des entrelacs celtiques est calculé.
De la géométrie vectorielle pure : ni image ni police, et le cadre s'adapte à toute taille de page.

[Manuel (FR)](docs/manual-fr.pdf) · [Manual (EN)](docs/manual-en.pdf) · [English](README.md) · [Journal des modifications](CHANGELOG.md)

![Cadres](docs/img/frames.jpg)

## Installation

Depuis **Typst Universe**, rien à installer : `#import "@preview/nibframe:0.3.0": *` (la dépendance `nibart` est téléchargée automatiquement).

## Démarrage rapide

```typ
#import "@preview/nibframe:0.3.0": *

#show: framed.with(style: "celtic")     // chaque page reçoit le cadre, et des marges qui y laissent place

= Mon document
#lorem(200)
```

Placez la règle `show` en premier. Les options suivent le style :

```typ
#import "@preview/nibframe:0.3.0": *
#show: framed.with(style: "guilloche", color: rgb("#1c7a78"), accent: rgb("#9a3324"), band: 14mm, inset: 6mm, gap: 8mm)
```

## Styles

`"classic"`, `"celtic"`, `"braid"`, `"chain"`, `"arabesque"`, `"islamic"`, `"greek"`, `"scallop"`, `"deco"`, `"braces"`, `"pearls"`, `"guilloche"`, `"banknote"`, `"baroque"`, `"triquetra"`, `"solomon"`, `"zellige"`, `"seigaiha"`, `"kilim"`, `"laurel"`, `"flowers"`, `"stamp"`, `"film"`, `"photo"`, `"neon"`, `"illumination"`, `"bill-lens"`, `"bill-fan"`, `"bill-ribbon"`, `"bill-shell"`, `"bill-wave"`, `"bill-frill"`, `"bill-net"`, `"bill-swell"`, `"bill-plait"`, `"bill-rosette"`, `"bill-wavy"`, `"bill-diploma"`, `"bill-lattice"`, `"bill-weave"`, `"airmail"`, `"checker"`, `"stars"`, `"hearts"`, `"eggdart"`, `"vitruvian"`, `"arches"`, `"tapa"`, `"stripes"`, `"herringbone"`, `"knot-cartouche"`, `"knot-eights"`, `"knot-lozenge"`, `"knot-ring"`, `"knot-rope"`, `"knot-triple"`, `"knot-weave"`, `"knot-blocks"`, `"daisy"`, `"sakura"`, `"lotus"`, `"palmette"`, `"ogee"`, `"rinceau"`, `"girih"`, `"hexastar"`, `"strap"`, `"certificate"`, `"certificate-ribbon"`, `"stepped"`, `"deckle"`, `"label"`, `"diamond-chain"`, `"lace-grid"`, `"diploma-shell"`, `"medallion"`, `"rosette-ribbon"`, `"fleur-edge"`, `"filigree"` (liste : `frame-styles`).

![Galerie](docs/img/gallery.jpg)

| Style | Description |
|---|---|
| `classic` | deux filets et volutes à la plume plate |
| `celtic` | tresse à deux brins (`strands: 3` pour trois brins) ; dessus/dessous calculé par nibart |
| `braid` | double tresse celtique : deux tresses côte à côte |
| `chain` | maillons entrelacés |
| `arabesque` | vigne calligraphique : tiges, vrilles, feuilles, fleurs aux coins |
| `islamic` | étoiles à huit pointes entrelacées (deux carrés tissés) |
| `greek` | méandre grec (clé) |
| `scallop` | arcs de dentelle, éventails aux coins |
| `deco` | traits Art déco et éventails aux coins |
| `braces` | quatre accolades calligraphiques |
| `pearls` | un collier de perles entre deux filets |
| `guilloche` | sinusoïdes déphasées |
| `banknote` | rosettes de guilloché en filets fins |
| `baroque` | rinceaux calligraphiques sur une tige ondulée, bouquets de feuilles, fleurs d'angle |
| `triquetra` | un nœud de trèfle celtique par motif (dessus/dessous calculé) |
| `solomon` | nœuds de Salomon : deux boucles tressées par motif |
| `zellige` | étoiles entrelacées à douze pointes (trois carrés tissés) |
| `seigaiha` | vagues japonaises en écailles (nécessite `paper`) |
| `kilim` | chaîne de losanges emboîtés |
| `laurel` | paires de feuilles de laurier sur une tige, étoiles aux coins |
| `flowers` | fleurs à six pétales sur une tige ondulée |
| `stamp` | dentelure de timbre-poste |
| `film` | pellicule : perforations arrondies |
| `photo` | coins d'album photo |
| `neon` | tube lumineux : traits translucides superposés |
| `illumination` | filets dorés, frise de quadrilobes, rayons d'angle (enluminure) |
| `bill-lens` | deux faisceaux de filets croisés formant des lentilles |
| `bill-fan` | filets ondulés à bord festonné et petites rosettes |
| `bill-ribbon` | un ruban torsadé de filets déphasés |
| `bill-shell` | arcs emboîtés en coquilles sous trois filets droits |
| `bill-wave` | un faisceau d'ondes dont l'amplitude croît sur la bande |
| `bill-frill` | bord inférieur en volant sous des filets droits |
| `bill-net` | deux familles d'ondes entrelacées : un réseau moiré |
| `bill-swell` | une onde dont les filets s'écartent et se resserrent |
| `bill-plait` | une tresse fine et dense de filets torsadés |
| `bill-rosette` | chaîne de lentilles avec rosettes de guilloché |
| `bill-wavy` | contour ondulé : deux faisceaux d'ondes croisés (sans filets droits) |
| `bill-diploma` | bordure de diplôme : éventail de filets sous un bord ondulé, double filet intérieur ondulé |
| `bill-lattice` | treillis d'ondes triangulaires (losanges et triangles) |
| `bill-weave` | deux faisceaux en opposition de phase qui s'entrelacent autour d'un contour ondulé |
| `airmail` | rayures diagonales « par avion » |
| `checker` | damier bicolore |
| `stars` | rangée d'étoiles et de points |
| `hearts` | rangée de cœurs |
| `eggdart` | moulure d'oves et fers de lance |
| `vitruvian` | rinceau vitruvien : vague courante avec spirales |
| `arches` | arcade en ogive |
| `tapa` | lignes en zigzag (tapa / chevrons) |
| `stripes` | rayures concentriques d'épaisseurs variées |
| `herringbone` | traits obliques cernés : corde / chevrons |
| `knot-cartouche` | tuiles d’entrelacs celtiques : tresse fermée par des boucles |
| `knot-eights` | chaîne de petits nœuds en huit fermés |
| `knot-lozenge` | tuiles d’entrelacs avec losange et tresses |
| `knot-ring` | anneaux entrelacés entre deux tresses |
| `knot-rope` | deux rangs d’anneaux entrelacés (corde) |
| `knot-triple` | trois blocs d’entrelacs par tuile |
| `knot-weave` | longue tresse à tissage central |
| `knot-blocks` | blocs de nœuds fermés en alternance |
| `daisy` | guirlande de marguerites à huit pétales et feuilles |
| `sakura` | fleurs de cerisier à cinq pétales sur une branche |
| `lotus` | lotus dressés alternant avec des boutons inversés |
| `palmette` | palmettes et volutes sur une tige ondulée |
| `ogee` | chaîne d’amandes avec quadrilobes |
| `rinceau` | vague avec éventails de feuilles, volutes et perles |
| `girih` | étoiles à huit branches cernées et losanges |
| `hexastar` | hexagrammes entrelacés (sceau de Salomon) |
| `strap` | entrelacs anguleux en bandes |
| `certificate` | bande guillochée, bord perlé et rinceaux d’acanthe dans les coins (optionnels ; essayez `texture: "rosettes"`) |
| `certificate-ribbon` | idem, avec un guilloché en rubans entrelacés |
| `stepped` | pyramides à gradins imbriquées (bord crénelé) |
| `deckle` | vagues qui s’estompent d’un bord frangé vers des lignes droites |
| `label` | fin double filet avec volutes aux coins et fleuron au milieu de chaque côté |
| `diamond-chain` | chaîne de losanges emboîtés, avec des triangles en filets entre eux |
| `lace-grid` | grille en dentelle de petits quadrilobes |
| `diploma-shell` | bordure ondulée de diplôme avec un éventail-coquille guilloché au milieu des côtés haut et bas |
| `medallion` | bande en treillis de losanges avec de grands disques guillochés sur les coins |
| `rosette-ribbon` | ruban de filets pincé à intervalles réguliers, une rosace à chaque pincement |
| `fleur-edge` | bord extérieur festonné, fleurons à quatre pointes, treillis de losanges |
| `filigree` | volutes en miroir avec feuilles, ornement dense et symétrique |
| `dedication` | triple filet, rangée de losanges entre les filets, rosaces à rameaux feuillus aux angles et au milieu de chaque côté (invitations, dédicaces) |
| `plank` | quatre planches de bois assemblées en onglet, avec veines et un clou à chaque angle (un cadre fait de planches) |
| `torn` | bande de papier déchiré, bord extérieur et intérieur irréguliers, ombre douce (la déchirure est la même sur les côtés opposés) |
| `coil` | bordure arrondie de cahier avec des anneaux de reliure sur un côté (`binding: "left"`, `"right"`, `"top"`, `"bottom"` ou `"none"`) |

| Option | Sens | Défaut |
|---|---|---|
| `band` | largeur de la bande décorative | `auto` : 5 à 7,5 mm selon le style |
| `inset` | distance entre le bord de la page et la bande | `4mm` |
| `color`, `accent` | les deux couleurs du style | bleu, ocre |
| `ink` | contours (celtic, guilloche, braces) | brun sombre |
| `paper` | couleur de la page, utilisée par les styles qui masquent des recouvrements (seigaiha, kilim, photo, baroque) | `white` |
| `corners` | ornements d'angle ; `false` ne garde que le contour continu et le motif des côtés | `true` |
| `corner-color` | couleur des rosettes d'angle des styles `bill-*` | `accent` éclairci |
| `binding` | `coil` seulement : côté des anneaux (`"left"`, `"right"`, `"top"`, `"bottom"`, `"none"`) | `"left"` |
| `texture` | texture de fond à l'intérieur du cadre : `"scales"`, `"waves"`, `"rosettes"` (tous les styles) | `none` |
| `texture-color` | couleur de la texture | `accent` pâle |
| `seal` | un sceau de guilloché (rosace) en bas à droite de la page | `false` |
| `line` | filets fins | `0.6pt` |
| `radius` | rayon des coins | selon le style |
| `period` | longueur d'un motif (celtic, guilloche, pearls) | selon le style |
| `strands` | celtic : 2 ou 3 ; guilloche : 7 | |
| `rules` | filets fins le long des deux bords (celtic, guilloche, braces) | `true` |

## Fonctions

- `framed(style:, gap: 6mm, margin: true, ..options)` — règle `show` ; règle le fond et la marge de la page (`margin: false` garde votre marge).
- `frame-background(style:, ..options)` — pour `set page(background: …)` si vous gérez les marges ; `frame-margin(style:, gap:, ..options)` renvoie `inset + band + gap`.
- `frame-box(corps, width:, height:, style:, gap:, ..options)` — une boîte encadrée autour de n'importe quel contenu (diplôme, carte, affiche). `width`/`height` : `auto` s'ajuste au contenu.
- `frame-graphic(largeur, hauteur, style:, ..options)` — le cadre seul, comme contenu de cette taille.
- `frame-items(largeur, hauteur, style:, ..options)` — les éléments [nibart](https://typst.app/universe/package/nibart) bruts pour `nibart.mp-fig`, à combiner avec votre propre dessin.

## Notes

- La page doit avoir une taille fixe (pas `auto`). Le temps de calcul croît avec la taille de la page pour les styles noués (`celtic`, `braid`, `chain` : quelques secondes pour une page A4) et `banknote` (PDF plus lourd).
- Typst 0.15 est requis (nibart utilise un plugin WebAssembly).

Exemples dans le dépôt : [`examples/gallery.typ`](examples/gallery.typ) (tous les styles), [`examples/frames.typ`](examples/frames.typ) (quatre pages complètes + un diplôme) ; `--input lang=en` pour l'anglais.

## Licence

Auteur : **FERGOUS Abdelhak** ([@fergousA](https://github.com/fergousA)) · dépôt : <https://github.com/fergousA/nibframe>.  
[MIT](LICENSE).
