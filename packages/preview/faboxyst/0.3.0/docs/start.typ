#import "_h.typ": *
#let imp = if ns == "local" { "@local/faboxyst:" + pkg.version } else { "@preview/faboxyst:" + pkg.version }
#pagebreak(weak: true)
#heading(level: 1, T("Getting started", "Prise en main"))

#T[
`faboxyst` draws boxes, frames and teaching blocks *as vector shapes*, with a hand-drawn character (wobbling strokes, hatching, tape, shadows). It has no image dependency: every piece scales with the text, follows the text direction (left-to-right and right-to-left) and has a monochrome print mode. The engine that makes lines wobble is written in pure Typst; the engraved "antique" register uses the *nibart* package for its broad-nib strokes.
][
`faboxyst` dessine des boîtes, cadres et blocs pédagogiques *sous forme de formes vectorielles*, avec un caractère dessiné à la main (traits tremblés, hachures, adhésif, ombres). Il n’utilise aucune image : chaque élément suit la taille du texte, la direction d’écriture (de gauche à droite comme de droite à gauche) et dispose d’un mode impression monochrome. Le moteur qui fait trembler les traits est écrit en Typst pur ; le registre « antique » gravé s’appuie sur le paquet *nibart* pour ses traits de plume large.
]

== #T("Installation", "Installation")

#T[Two editions exist. The *Typst Universe* edition imports everything from `@preview`; the *local* edition is installed under `@local` (copy the folder to #raw("~/.local/share/typst/packages/local/faboxyst/" + pkg.version) on Linux, or the equivalent data directory on macOS and Windows). Both need Typst #pkg.compiler or later.][Il existe deux éditions. L’édition *Typst Universe* importe tout depuis `@preview` ; l’édition *locale* s’installe sous `@local` (copiez le dossier dans #raw("~/.local/share/typst/packages/local/faboxyst/" + pkg.version) sous Linux, ou le répertoire de données équivalent sous macOS et Windows). Les deux demandent Typst #pkg.compiler ou plus récent.]

#block(fill: luma(246), inset: 7pt, radius: 3pt, width: 100%, raw("#import \"" + imp + "\": *\n\n#show: faboxyst.with(theme: themes.notebook)\n\n#fabox(title: [Hello], colour: rgb(\"#2E7D32\"))[A first hand-drawn box.]", lang: "typ", block: true))

#T[Dependencies: *nibart* (strokes of the antique register; imported by the package itself) and *cetz* (used by a few slide components). You never import them yourself.][Dépendances : *nibart* (traits du registre antique ; importé par le paquet lui-même) et *cetz* (utilisé par quelques composants de diapositive). Vous n’avez jamais à les importer.]

== #T("The three ideas to know", "Les trois idées à connaître")

#T[*1 — The theme.* `faboxyst` is a `show` rule: it stores a theme (colours, fonts, `roughness`, `seed`, `stroke-weight`, padding, text direction) that all boxes read. Change it once for the whole document, or locally with `make-theme`.][*1 — Le thème.* `faboxyst` est une règle `show` : elle mémorise un thème (couleurs, polices, `roughness`, `seed`, `stroke-weight`, marges, direction du texte) que toutes les boîtes lisent. On le change une fois pour tout le document, ou localement avec `make-theme`.]

#ex("#show: faboxyst.with(theme: themes.blueprint)\n#note[Blueprint theme: blue ink on a ruled sheet.]\n#show: faboxyst.with(theme: make-theme(roughness: 2.4))\n#tip[Same note, twice as wobbly.]")

#T[*2 — Sketchiness.* `roughness` multiplies every wobble amplitude (0 gives clean lines); `seed` makes the drawing reproducible, and many boxes take their own `seed`, `rough` or `hand` options.][*2 — La nervosité du trait.* `roughness` multiplie toutes les amplitudes de tremblement (0 donne des traits nets) ; `seed` rend le dessin reproductible, et beaucoup de boîtes ont leurs propres options `seed`, `rough` ou `hand`.]

#ex("#for r in (0, 1, 3) {\n  show: faboxyst.with(theme: make-theme(roughness: r))\n  box(fabox(colour: rgb(\"#1565C0\"), width: 2.1cm)[r = #r])\n  h(3pt)\n}")

#T[*3 — Direction and print.* Arabic or Hebrew text mirrors the anchored parts (badges, tabs, ribbons) automatically; `themes.arabic` sets the language and fonts. `themes.print` turns every surface white and every rule black, and `print-group` marks content that must be rendered in grey.][*3 — Direction et impression.* Un texte arabe ou hébreu fait pivoter automatiquement les éléments ancrés (pastilles, onglets, rubans) ; `themes.arabic` règle la langue et les polices. `themes.print` rend toutes les surfaces blanches et tous les filets noirs, et `print-group` marque le contenu à rendre en gris.]

#ex("#set text(dir: rtl, lang: \"ar\")\n#fabox(title: [عنوان], colour: rgb(\"#6A1B9A\"))[نص عربي داخل علبة.]")

== #T("Reading this manual", "Lire ce manuel")

#T[Chapters follow families of functions. Each entry gives: the name (with its aliases), a one-line description, a signature, a *table of all parameters* with default values and explanations, and an example whose code sits beside its rendering. Parameter names are consistent across the package: `colour` is the main colour, `weight` a stroke weight, `inset` the inner padding, `radius` the corner rounding, `seed` the random seed, `-x` / `-y` suffixes are horizontal and vertical offsets, and `..a` forwards extra options to the underlying box.][Les chapitres suivent les familles de fonctions. Chaque entrée donne : le nom (avec ses alias), une description d’une ligne, une signature, un *tableau de tous les paramètres* avec valeurs par défaut et explications, et un exemple dont le code est à côté du rendu. Les noms de paramètres sont cohérents dans tout le paquet : `colour` est la couleur principale, `weight` une épaisseur de trait, `inset` la marge intérieure, `radius` l’arrondi des coins, `seed` la graine aléatoire, les suffixes `-x` / `-y` des décalages horizontaux et verticaux, et `..a` transmet les options en plus à la boîte sous-jacente.]

== #T("Migration: full-page frames", "Migration : cadres pleine page")

#T[
In v0.3.0, six full-page frame functions moved from faboxyst to the companion package *nibframe*. They are no longer exported by faboxyst; use the matching nibframe styles below. `plate-page`, `patent-page` and `bound-page` remain because they are page layouts, not frame functions.
][
Dans la v0.3.0, six fonctions de cadre pleine page ont été transférées de faboxyst vers le paquet compagnon *nibframe*. faboxyst ne les exporte plus ; utilisez les styles nibframe correspondants ci-dessous. `plate-page`, `patent-page` et `bound-page` restent disponibles : ce sont des mises en page, pas des fonctions de cadre.
]

#T[Former function → nibframe style:][Fonction de cadre → style nibframe :]
#{
  set text(size: 8pt)
  table(columns: (auto, auto, 1fr), stroke: (x: none, y: 0.25pt + luma(205)), inset: (x: 4pt, y: 3pt),
    table.header([*faboxyst*], [*nibframe*], [*#T("note", "remarque")*]),
    raw("ornate-pages"), raw("frame-style: \"dedication\""), T("Ornate double border with corner bosses.", "Double bordure ornée à bossages d’angle."),
    raw("rosette-pages"), raw("frame-style: \"dedication\""), T("Rosette corners.", "Angles à rosettes."),
    raw("volute-pages"), raw("\"classic\" / \"label\""), T("Volute scrolls.", "Volutes."),
    raw("plank-pages"), raw("\"plank\""), T("Wooden planks with nails.", "Planches de bois cloutées."),
    raw("torn-pages"), raw("\"torn\""), T("Torn paper edge.", "Bord de papier déchiré."),
    raw("coil-pages"), raw("\"coil\" (binding: option)"), T("Spiral binding on a chosen side.", "Reliure spirale sur le côté choisi."),
  )
}
