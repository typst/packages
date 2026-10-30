#import "_h.typ": *

#heading(level: 1, T("What's new in v0.3.0 (since v0.1.0)", "Nouveautés de la v0.3.0 (depuis la v0.1.0)"))

#T[
Compared with v0.1.0, v0.3.0 keeps the original `fabox`, semantic callouts, classroom plates, `sashbox` / `ruban` ribbons and ticket components, and expands the library substantially.
][
Par rapport à la v0.1.0, la v0.3.0 conserve `fabox`, les blocs sémantiques, les planches pédagogiques, les rubans `sashbox` / `ruban` et les tickets d’origine, tout en élargissant considérablement la bibliothèque.
]

#v(5pt)

#T[
- *More components and formats.* New stationery and scrapbook pieces, ornate and sketched frames, infographics, book-cover styles and antique page layouts, alongside boxes that adapt more readily to their content.
- *Broader right-to-left support.* `direction: auto` and automatic mirroring make Arabic and Hebrew layouts easier to use; themes also provide a monochrome print mode.
- *New in v0.3.0:* 18 infographic functions and 4 sketched frames, with broad-nib drawing supplied by *nibart* for engraved and dry-media effects.
- *A simpler drawing engine.* The sketch engine is now written in pure Typst; the former WebAssembly modules are no longer needed.
- *Migration note.* Six full-page frame functions moved to the companion package *nibframe*. The page layouts `plate-page`, `patent-page` and `bound-page` remain in faboxyst.
][
- *Davantage de composants et de formats.* De nouveaux éléments de papeterie et de carnet, des cadres ornés et dessinés, des infographies, des couvertures et des mises en page antiques, ainsi que des boîtes qui s’adaptent mieux à leur contenu.
- *Prise en charge élargie de l’écriture de droite à gauche.* `direction: auto` et le miroir automatique facilitent les mises en page arabes et hébraïques ; les thèmes proposent aussi un mode d’impression monochrome.
- *Nouveautés de la 0.3.0 :* 18 fonctions d’infographie et 4 cadres dessinés, avec les traits de plume large de *nibart* pour les effets gravés et les textures sèches.
- *Un moteur de dessin simplifié.* Le moteur d’esquisse est désormais écrit en Typst pur ; les anciens modules WebAssembly ne sont plus nécessaires.
- *Note de migration.* Six fonctions de cadres pleine page ont été transférées dans le paquet compagnon *nibframe*. Les mises en page `plate-page`, `patent-page` et `bound-page` restent dans faboxyst.
]

#v(5pt)
#block(fill: soft, inset: (x: 8pt, y: 6pt), radius: 3pt, width: 100%, T(
  [The core API remains available. For the moved frame functions and their replacements, see the migration table in “Getting started”.],
  [L’API de base reste disponible. Pour retrouver les fonctions de cadre déplacées et leurs remplacements, consultez le tableau de migration dans « Prise en main ».],
))
