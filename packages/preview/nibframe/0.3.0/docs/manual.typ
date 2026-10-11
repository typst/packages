// nibframe — reference manual (English / Français)
// Build:  typst compile --root . docs/manual.typ docs/manual-en.pdf
//         typst compile --root . --input lang=fr docs/manual.typ docs/manual-fr.pdf
// The style catalogue uses the previews of docs/catalogue/ (sh scripts/build-catalogue.sh); every other figure is live.
#import "_h.typ": *
#import "_styles.typ": styles-info

#set document(title: "nibframe " + nf.nibframe-version + " — " + T("manual", "manuel"), author: "nibframe")
#set page(paper: "a4", margin: (x: 2.1cm, y: 2.2cm),
  footer: context {
    if counter(page).get().first() > 1 [
      #set text(8pt, fill: luma(120))
      nibframe #nf.nibframe-version · #T("Reference manual", "Manuel de référence") #h(1fr) #counter(page).display()
    ]
  })
#set text(font: ("Libertinus Serif", "DejaVu Serif"), size: 10.5pt, lang: lang)
#set par(justify: true)
#show raw: it => if ns == "local" and it.text.contains("@preview/") { raw(it.text.replace("@preview/", "@local/"), lang: it.lang, block: it.block) } else { it }
#show raw: set text(font: ("DejaVu Sans Mono",), size: 8.6pt)
#show raw.where(block: true): set par(justify: false)
#show raw.where(block: false): it => box(fill: luma(240), inset: (x: 2pt), outset: (y: 2pt), radius: 1.5pt, it)
#show heading.where(level: 1): it => { pagebreak(weak: true); v(4pt); text(20pt, fill: accent, it); v(4pt); line(length: 100%, stroke: 0.6pt + accent); v(4pt) }
#show heading.where(level: 2): it => { v(10pt); text(13.5pt, fill: accent, it); v(2pt) }
#show heading.where(level: 3): it => { text(11.5pt, fill: accent, it.body); v(-2pt) }
#show link: set text(fill: rgb("#1a4f8b"))

#let cat-img(n, w: 100%) = image("catalogue/" + n + ".jpg", width: w)
#let band-of(n) = calc.round((nf.frame-margin(style: n, gap: 0mm) - 4mm).mm(), digits: 1)

// ───────────────────────────────────────────────────────────── cover
#page(margin: (x: 1.7cm, top: 1.4cm, bottom: 1.4cm))[
#align(center)[
  #v(0.6cm)
  #text(40pt, weight: "bold", fill: accent)[nibframe]
  #v(0.1cm)
  #text(13pt)[#T("Decorative frames and borders for Typst — drawn with nibart", "Cadres et bordures décoratifs pour Typst — dessinés avec nibart")]
  #v(0.35cm)
  #text(18pt, weight: "bold")[#T("Reference manual", "Manuel de référence")]
  #h(0.5cm)
  #text(10pt, fill: luma(90))[#T("Version", "Version") #nf.nibframe-version · #styles-info.len() #T("styles", "styles") · Typst ≥ 0.15 · MIT]
  #v(0.1cm)
  #text(9pt, fill: luma(90))[#T("Author", "Auteur") #pkg.authors.first() · #link(pkg.repository, pkg.repository.trim("https://", at: start))]
  #v(0.7cm)
  #grid(columns: (1fr,) * 3, gutter: 9pt,
    ..("bill-swell", "bill-plait", "bill-rosette", "bill-wavy", "bill-diploma", "bill-lattice", "bill-weave", "airmail", "checker", "stars", "hearts", "eggdart").map(n => block(stroke: 0.4pt + luma(200), radius: 2pt, clip: true, cat-img(n))))
]
]
#text(20pt, weight: "bold", fill: accent)[#T("Contents", "Sommaire")]
#v(6pt)
#outline(title: none, indent: 1.2em, depth: 2)

// ───────────────────────────────────────────────────────────── 1. getting started
= #T("Getting started", "Prise en main")

== #T("What nibframe does", "Ce que fait nibframe")

#T[
`nibframe` draws *decorative frames* — around every page of a document, or around any box (certificate, card, poster). There are #styles-info.len() styles: Celtic plaits and knotwork, arabesques, Islamic stars, Greek key, banknote guilloché, floral garlands, Art Deco, postage stamps… Each frame is computed for the exact size you ask for, so it fits an A4 page, a business card or a banner alike.

Everything is vector geometry produced by the `nibart` plugin (Hobby splines, pen envelopes, knots with automatic over/under crossings): no image, no font. The frame stays crisp at any zoom and prints at the resolution of your printer.
][
`nibframe` dessine des *cadres décoratifs* — autour de chaque page d'un document, ou autour de n'importe quelle boîte (diplôme, carte, affiche). Il y a #styles-info.len() styles : tresses et entrelacs celtiques, arabesques, étoiles islamiques, clé grecque, guilloché de billet, guirlandes florales, Art déco, timbres-poste… Chaque cadre est calculé pour la taille exacte demandée : il convient aussi bien à une page A4 qu'à une carte de visite ou à une bannière.

Tout est de la géométrie vectorielle produite par le plugin `nibart` (splines de Hobby, enveloppes de plumes, nœuds à croisements dessus/dessous automatiques) : ni image ni police. Le cadre reste net à tout niveau de zoom et s'imprime à la résolution de l'imprimante.
]

== #T("Installation", "Installation")
```typ
#import "@preview/nibframe:0.3.0": *
```
#if ns == "local" [
  #T[Local edition: installed with `install.sh` / `install.ps1` under the `@local` namespace; it needs the local edition of `nibart` (`@local/nibart`) installed as well.][Édition locale : installée avec `install.sh` / `install.ps1` dans l'espace de noms `@local` ; elle demande l'édition locale de `nibart` (`@local/nibart`), installée elle aussi.]
] else [
  #T[Typst Universe: nothing else to install — `nibart`, which `nibframe` imports itself, is downloaded automatically. A local edition (zip with `install.sh` / `install.ps1`) installs the same package under the `@local` namespace.][Typst Universe : rien d'autre à installer — `nibart`, que `nibframe` importe lui-même, est téléchargé automatiquement. Une édition locale (zip avec `install.sh` / `install.ps1`) installe le même paquet dans l'espace de noms `@local`.]
]

#T[Import everything (`*`): the package exports only a handful of names (`framed`, `frame-box`, `frame-graphic`…), none of which clashes with Typst. You never have to import `nibart` yourself, except to combine a frame with your own drawing (recipe 4).][Importez tout (`*`) : le paquet n'exporte que quelques noms (`framed`, `frame-box`, `frame-graphic`…), aucun ne gêne Typst. Vous n'avez jamais à importer `nibart` vous-même, sauf pour combiner un cadre avec votre propre dessin (recette 4).]

== #T("Quick start", "Démarrage rapide")

#T[One show rule frames every page and leaves room for the text:][Une règle `show` encadre chaque page et laisse la place du texte :]
```typ
#import "@preview/nibframe:0.3.0": *

#show: framed.with(style: "celtic")

= My document
#lorem(200)
```
#T[Options follow the style. The next example sets the colours, the width of the band, its distance from the page edge and the space left between the band and the text:][Les options suivent le style. L'exemple suivant règle les couleurs, la largeur de la bande, sa distance au bord de la page et l'espace laissé entre la bande et le texte :]
```typ
#import "@preview/nibframe:0.3.0": *
#show: framed.with(style: "guilloche", color: rgb("#1c7a78"), accent: rgb("#9a3324"),
  band: 14mm, inset: 6mm, gap: 8mm)
```
#T[The *thickness* of the frame is the `band` option. Every style accepts it — even `band: 3.5mm` gives a clean frame for all #styles-info.len() styles — so a frame that looks too heavy is simply thinned. Default band on the left, `band: 3.5mm` on the right:][L'*épaisseur* du cadre est l'option `band`. Tous les styles l'acceptent — même `band: 3.5mm` donne un cadre propre pour les #styles-info.len() styles — un cadre qui paraît trop lourd s'amincit donc simplement. Bande par défaut à gauche, `band: 3.5mm` à droite :]
#ex(```
let f(s, ..o) = frame-graphic(32mm, 22mm, style: s, ..o)
grid(columns: 2, gutter: 3mm,
  f("checker"), f("checker", band: 3.5mm),
  f("hearts"), f("hearts", band: 3.5mm))
```)

#T[To frame a box rather than the pages — here a small card — use `frame-box`; the result on the right is computed live:][Pour encadrer une boîte plutôt que les pages — ici une petite carte — utilisez `frame-box` ; le résultat à droite est calculé en direct :]
#ex(```
frame-box(
  align(center)[#text(13pt, weight: "bold")[Hello] \ frame-box],
  width: 46mm, height: 30mm,
  style: "laurel", gap: 3mm,
)
```)

== #T("How to read this manual", "Comment lire ce manuel")
#T[
Chapter 2 explains the geometry of a frame. Chapter 3 documents the *eight functions* (signature, table of parameters, return value, example). Chapter 4 documents the *options* shared by all functions, each with a live comparison. Chapter 5 is the *catalogue of the #styles-info.len() styles*; its pictures are pre-rendered previews (JPEG) of each style with default options, so that the manual stays light — everything else, including every example next to its code, is executed by the package when the manual is compiled. Chapter 6 gives recipes. An index of functions, options and styles, with page numbers, closes the manual.

In the examples the code is in *code mode* and uses the names without any prefix, as after `#import "@preview/nibframe:0.3.0": *`; `nib` is the `nibart` module. The value of the last expression is what appears on the right.
][
Le chapitre 2 explique la géométrie d'un cadre. Le chapitre 3 documente les *huit fonctions* (signature, tableau des paramètres, valeur renvoyée, exemple). Le chapitre 4 documente les *options* communes à toutes les fonctions, chacune avec une comparaison en direct. Le chapitre 5 est le *catalogue des #styles-info.len() styles* ; ses images sont des aperçus pré-rendus (JPEG) de chaque style avec les options par défaut, pour que le manuel reste léger — tout le reste, y compris chaque exemple à côté de son code, est exécuté par le paquet à la compilation du manuel. Le chapitre 6 donne des recettes. Un index des fonctions, options et styles, avec numéros de page, clôt le manuel.

Dans les exemples, le code est en *mode code* et utilise les noms sans préfixe, comme après `#import "@preview/nibframe:0.3.0": *` ; `nib` est le module `nibart`. La valeur de la dernière expression est ce qui s'affiche à droite.
]

// ───────────────────────────────────────────────────────────── 2. concepts
= #T("Anatomy of a frame", "Anatomie d'un cadre")

#T[
A frame lives in a rectangle of size `width × height`. Three lengths place it:
- *`inset`* — the distance between the edge of the rectangle (the page edge) and the outside of the band;
- *`band`* — the width of the decorative band itself (each style has its own default, 5 to 7.5 mm, so that it stays slim);
- *`gap`* — the free space left between the band and the text. It belongs to the page layout, not to the drawing: `frame-margin` and `framed` add it to `inset + band` to compute the page margin.

The text area therefore starts `inset + band + gap` from every edge, which is exactly what `frame-margin` returns.
][
Un cadre vit dans un rectangle de taille `width × height`. Trois longueurs le placent :
- *`inset`* — la distance entre le bord du rectangle (le bord de la page) et l'extérieur de la bande ;
- *`band`* — la largeur de la bande décorative elle-même (chaque style a sa valeur par défaut, de 5 à 7,5 mm, pour rester fine) ;
- *`gap`* — l'espace libre laissé entre la bande et le texte. Il relève de la mise en page, pas du dessin : `frame-margin` et `framed` l'ajoutent à `inset + band` pour calculer la marge de la page.

La zone de texte commence donc à `inset + band + gap` de chaque bord, ce que renvoie exactement `frame-margin`.
]

#{
  let W = 84mm; let H = 50mm
  let (i, b, g) = (4mm, 6.5mm, 6mm)
  align(center, block(stroke: 0.4pt + luma(190), inset: 10pt, radius: 3pt, {
    box(width: W, height: H, stroke: 0.5pt + luma(120), {
      place(top + left, nf.frame-graphic(W, H, style: "pearls", band: b, inset: i))
      place(top + left, dx: i + b + g, dy: i + b + g, rect(width: W - 2 * (i + b + g), height: H - 2 * (i + b + g), stroke: (dash: "dashed", thickness: 0.5pt, paint: rgb("#9a3324")), inset: 0pt,
        align(center + horizon, text(8pt, fill: rgb("#9a3324"))[#T("text area", "zone de texte")])))
      let lab(body, x, y, al: left) = place(top + left, dx: x, dy: y, text(7pt, fill: accent, body))
      lab([inset], 0.6mm, i / 2 - 1.1mm)
      lab([band], i + 1mm, i + b / 2 - 1.1mm)
      place(top + left, dx: i + b + 0.5mm, dy: H / 2 - 1.2mm, text(7pt, fill: accent)[gap])
    })
  }))
}

#T[
*The page must have a fixed size* (`auto` is refused by `frame-background`). *Frames adapt to the size*: patterns repeat a whole number of times along each side, corners are drawn at the four corners, and everything is symmetrical — left/right and top/bottom. Every style has a *continuous contour*; corner ornaments are *optional* (`corners: false`, see chapter 4) and, when present, lie over the contour in a lighter or darker colour.
][
*La page doit avoir une taille fixe* (`auto` est refusé par `frame-background`). *Les cadres s'adaptent à la taille* : les motifs se répètent un nombre entier de fois le long de chaque côté, les coins sont dessinés aux quatre angles et tout est symétrique — gauche/droite et haut/bas. Chaque style a un *contour continu* ; les ornements de coin sont *facultatifs* (`corners: false`, voir chapitre 4) et, quand ils sont présents, se superposent au contour dans une couleur plus claire ou plus foncée.
]

// ───────────────────────────────────────────────────────────── 3. functions
= #T("Functions", "Fonctions")

#T[
Five functions draw or measure frames (`frame-graphic`, `frame-items`, `frame-margin`, `frame-background`, `frame-box`), one is a show rule (`framed`), and two give information (`nibframe-version`, `frame-styles`). All functions that take a `style:` also accept every option of chapter 4 as extra named arguments (`..opts`); an unknown option stops the compilation with a message that lists the known ones.
][
Cinq fonctions dessinent ou mesurent des cadres (`frame-graphic`, `frame-items`, `frame-margin`, `frame-background`, `frame-box`), une est une règle `show` (`framed`), et deux donnent des informations (`nibframe-version`, `frame-styles`). Toutes les fonctions qui acceptent `style:` acceptent aussi toutes les options du chapitre 4 comme arguments nommés supplémentaires (`..opts`) ; une option inconnue arrête la compilation avec un message qui liste les options connues.
]

== #T("Show rule and page", "Règle show et page")

#api("framed", "framed(style: \"classic\", gap: 6mm, margin: true, ..opts, body)",
  T[Show rule that frames *every page* of the document. It sets the page background to the frame (`frame-background`) and, unless `margin: false`, the page margins to `frame-margin`, so that the text never touches the band. Put it first, before any content: `#show: framed.with(style: "celtic")`.][Règle `show` qui encadre *chaque page* du document. Elle met le cadre en fond de page (`frame-background`) et, sauf si `margin: false`, règle les marges de page sur `frame-margin`, de sorte que le texte ne touche jamais la bande. Placez-la en premier, avant tout contenu : `#show: framed.with(style: "celtic")`.],
  params: (
    P("style", "string", "\"classic\"", [Name of the style (see `frame-styles` and chapter 5).], [Nom du style (voir `frame-styles` et le chapitre 5).]),
    P("gap", "length", "6mm", [Space between the band and the text.], [Espace entre la bande et le texte.]),
    P("margin", "bool", "true", [`true`: set the page margins (`frame-margin`). `false`: keep your own margins.], [`true` : règle les marges de page (`frame-margin`). `false` : conserve vos propres marges.]),
    P("..opts", "named", "—", [Any option of chapter 4 (`band`, `inset`, `color`…).], [Toute option du chapitre 4 (`band`, `inset`, `color`…).]),
    P("body", "content", none, [The document (given by the `show` rule).], [Le document (fourni par la règle `show`).]),
  ),
  ret: T[the document, with the page set up.][le document, avec la page configurée.],
  note: T[The page keeps its size and orientation; set `#set page(paper: "a5", flipped: true)` *before* or *after* the show rule as you like. With `margin: false` the band may overlap the text unless your margins are large enough: use `frame-margin` to measure them.][La page garde sa taille et son orientation ; écrivez `#set page(paper: "a5", flipped: true)` avant ou après la règle, comme vous voulez. Avec `margin: false`, la bande peut chevaucher le texte si vos marges sont trop petites : mesurez-les avec `frame-margin`.],
  ex: ```
// in a document § dans un document :
// #show: framed.with(style: "greek", color: rgb("#9a3324"))
// the live result shows one such page § le résultat montre une telle page :
frame-box(
  align(left, text(7pt)[#lorem(22)]),
  width: 46mm, height: 62mm, style: "greek",
  color: rgb("#9a3324"), gap: 4mm,
)
```,
  live: ```
frame-box(
  align(left, text(7pt)[#lorem(22)]),
  width: 46mm, height: 62mm, style: "greek",
  color: rgb("#9a3324"), gap: 4mm,
)
```)

#api("frame-background", "frame-background(style: \"classic\", ..opts)",
  T[A page background that draws the frame at the size of the page. It is a `context` function: use it as `set page(background: frame-background(style: "celtic"))`. Use it instead of `framed` when you manage the margins yourself (`frame-margin` tells you how much room the frame takes), or to give different pages different frames.][Un fond de page qui dessine le cadre à la taille de la page. C'est une fonction `context` : utilisez-la ainsi `set page(background: frame-background(style: "celtic"))`. Employez-la à la place de `framed` quand vous gérez vous-même les marges (`frame-margin` dit la place que prend le cadre), ou pour donner des cadres différents à des pages différentes.],
  params: (
    P("style", "string", "\"classic\"", [Name of the style.], [Nom du style.]),
    P("..opts", "named", "—", [Any option of chapter 4.], [Toute option du chapitre 4.]),
  ),
  ret: T[content that fills the page background (assertion error if the page width or height is `auto`).][un contenu qui remplit le fond de page (erreur d'assertion si la largeur ou la hauteur de la page est `auto`).],
  ex: ```
// in a document § dans un document :
// #set page(
//   margin: frame-margin(style: "scallop"),
//   background: frame-background(style: "scallop"))
// the live result shows the frame of a page 45 × 62 mm
// le résultat montre le cadre d'une page de 45 × 62 mm
frame-graphic(45mm, 62mm, style: "scallop")
```,
  live: ```
frame-graphic(45mm, 62mm, style: "scallop")
```)

#api("frame-margin", "frame-margin(style: \"classic\", gap: 6mm, ..opts)",
  T[The page margin that keeps the text clear of the frame: `inset + band + gap`. `framed` uses it; call it yourself when you set the margins by hand.][La marge de page qui garde le texte à distance du cadre : `inset + band + gap`. `framed` l'utilise ; appelez-la vous-même si vous réglez les marges à la main.],
  params: (
    P("style", "string", "\"classic\"", [Name of the style (the default band depends on it).], [Nom du style (la bande par défaut en dépend).]),
    P("gap", "length", "6mm", [Space between the band and the text.], [Espace entre la bande et le texte.]),
    P("..opts", "named", "—", [Options that change the geometry: `band`, `inset`.], [Options qui changent la géométrie : `band`, `inset`.]),
  ),
  ret: T[a length.][une longueur.],
  ex: ```
// millimetres § millimètres
(
  classic: frame-margin(style: "classic").mm(),
  pearls: frame-margin(style: "pearls").mm(),
  wide: frame-margin(style: "pearls", band: 12mm, gap: 10mm).mm(),
)
```)

== #T("Drawing a frame", "Dessiner un cadre")

#api("frame-graphic", "frame-graphic(width, height, style: \"classic\", ..opts)",
  T[The frame alone, as content: a `box` of exactly `width × height` (origin at the top-left, nothing inside). Place it, scale it, put it in a grid, or stack your text over it with `place`.][Le cadre seul, sous forme de contenu : une `box` de `width × height` exactement (origine en haut à gauche, rien à l'intérieur). Placez-le, mettez-le à l'échelle, rangez-le dans une grille, ou superposez-y votre texte avec `place`.],
  params: (
    P("width", "length", none, [Width of the whole frame (outside of the band + `inset`).], [Largeur du cadre entier (extérieur de la bande + `inset`).]),
    P("height", "length", none, [Height of the whole frame.], [Hauteur du cadre entier.]),
    P("style", "string", "\"classic\"", [Name of the style.], [Nom du style.]),
    P("..opts", "named", "—", [Any option of chapter 4.], [Toute option du chapitre 4.]),
  ),
  ret: T[content (`box`) of size `width × height`.][un contenu (`box`) de taille `width × height`.],
  ex: ```
stack(dir: ltr, spacing: 4mm,
  frame-graphic(28mm, 40mm, style: "deco"),
  frame-graphic(40mm, 24mm, style: "deco",
    color: rgb("#9a3324"), accent: rgb("#1c7a78")),
)
```)

#api("frame-items", "frame-items(width, height, style: \"classic\", ..opts)",
  T[The raw drawing items of a frame, to feed `nibart`'s `mp-fig` together with your own items. Origin: *bottom-left* corner (nibart's y-up axes). Use it to draw something inside the frame in the same figure, to change the order of layers, or to transform the frame with `nibart` before drawing it.][Les objets de dessin bruts d'un cadre, à donner à `mp-fig` de `nibart` avec vos propres objets. Origine : coin *inférieur gauche* (axes y vers le haut de nibart). Servez-vous-en pour dessiner quelque chose à l'intérieur du cadre dans la même figure, changer l'ordre des couches, ou transformer le cadre avec `nibart` avant de le dessiner.],
  params: (
    P("width", "length", none, [Width of the frame.], [Largeur du cadre.]),
    P("height", "length", none, [Height of the frame.], [Hauteur du cadre.]),
    P("style", "string", "\"classic\"", [Name of the style.], [Nom du style.]),
    P("..opts", "named", "—", [Any option of chapter 4.], [Toute option du chapitre 4.]),
  ),
  ret: T[an array of `nibart` drawables (spread it with `..` into `nib.mp-fig`).][un tableau d'objets dessinables `nibart` (étalez-le avec `..` dans `nib.mp-fig`).],
  ex: ```
nib.mp-fig(
  ..frame-items(50mm, 34mm, style: "pearls"),
  nib.mp-dot((25mm, 17mm), pen: nib.pencircle(9pt),
    fill: rgb("#9a3324")),
  width: 50mm, height: 34mm, origin: (0pt, 0pt), pad: 0pt,
)
```)

#api("frame-box", "frame-box(body, width: auto, height: auto, style: \"classic\", gap: 6mm, ..opts)",
  T[A frame around arbitrary content — certificate, card, poster, a figure. The body is centred inside the band, at distance `gap` from it. With `auto` sizes the box fits the body plus `inset + band + gap` on each side; give `width` and/or `height` to impose the size (the body is then centred in the remaining area).][Un cadre autour d'un contenu quelconque — diplôme, carte, affiche, figure. Le corps est centré dans la bande, à la distance `gap`. Avec des tailles `auto`, la boîte s'ajuste au corps plus `inset + band + gap` de chaque côté ; donnez `width` et/ou `height` pour imposer la taille (le corps est alors centré dans la zone restante).],
  params: (
    P("body", "content", none, [The content to frame.], [Le contenu à encadrer.]),
    P("width", "auto or length", "auto", [Width of the whole box (frame included).], [Largeur de la boîte entière (cadre compris).]),
    P("height", "auto or length", "auto", [Height of the whole box.], [Hauteur de la boîte entière.]),
    P("style", "string", "\"classic\"", [Name of the style.], [Nom du style.]),
    P("gap", "length", "6mm", [Space between the band and the body.], [Espace entre la bande et le corps.]),
    P("..opts", "named", "—", [Any option of chapter 4.], [Toute option du chapitre 4.]),
  ),
  ret: T[a `box`.][une `box`.],
  note: T[The body is centred but not clipped: if it is larger than the free area it overflows the band. `frame-box` needs a `context` to measure the body, so it is not usable inside a function that needs its size immediately.][Le corps est centré mais pas rogné : s'il dépasse la zone libre, il déborde sur la bande. `frame-box` utilise un `context` pour mesurer le corps ; elle ne convient donc pas dans une fonction qui a besoin de sa taille immédiatement.],
  ex: ```
stack(dir: ltr, spacing: 4mm,
  frame-box(text(13pt)[Hello], style: "stars", gap: 3mm),
  frame-box(
    align(center)[#text(10pt, weight: "bold")[Prize] \ #text(7pt)[2026]],
    width: 38mm, height: 26mm, style: "label", gap: 2mm),
)
```)

== #T("Information", "Informations")

#api("frame-styles", "frame-styles",
  T[The array of the style names, in catalogue order. Use it to loop over all styles (as the gallery of the package does), to check a name, or to pick one at random.][Le tableau des noms de styles, dans l'ordre du catalogue. Servez-vous-en pour parcourir tous les styles (comme le fait la galerie du paquet), vérifier un nom, ou en choisir un au hasard.],
  ret: T[an array of strings.][un tableau de chaînes.],
  ex: ```
(
  count: frame-styles.len(),
  first: frame-styles.slice(0, 5),
  last: frame-styles.last(),
)
```)

#api("nibframe-version", "nibframe-version",
  T[The version of the package, as a string.][La version du paquet, sous forme de chaîne.],
  ret: T[a string.][une chaîne.],
  ex: ```
nibframe-version
```)

// ───────────────────────────────────────────────────────────── 4. options
#let opt = api.with(cols: (1fr, 1.15fr))

= #T("Options", "Options")

#T[
Options are *named arguments* given after the style to `framed`, `frame-background`, `frame-graphic`, `frame-items`, `frame-margin` and `frame-box`. They are shared by all styles, but a style only uses those that make sense for it; the others are ignored silently. A misspelt name is an error (`nibframe: unknown option …`). In the comparisons below the grey outline marks the limit of the box.
][
Les options sont des *arguments nommés* donnés après le style à `framed`, `frame-background`, `frame-graphic`, `frame-items`, `frame-margin` et `frame-box`. Elles sont communes à tous les styles, mais un style n'utilise que celles qui ont un sens pour lui ; les autres sont ignorées sans bruit. Un nom mal orthographié est une erreur (`nibframe: unknown option …`). Dans les comparaisons ci-dessous, le contour gris marque la limite de la boîte.
]

#let cmp = "(w, h, ..opts) => box(stroke: 0.3pt + luma(190), nf.frame-graphic(w, h, ..opts))"

== #T("Geometry", "Géométrie")

#opt("band", "band: auto",
  T[Width of the decorative band. `auto` takes the default of the style (5 to 7.5 mm). This is *the* setting for the thickness of a frame: every style stays clean down to about 3.5 mm, and large bands suit big pages.][Largeur de la bande décorative. `auto` prend la valeur par défaut du style (5 à 7,5 mm). C'est *le* réglage de l'épaisseur d'un cadre : tous les styles restent propres jusqu'à environ 3,5 mm, et les grandes bandes conviennent aux grandes pages.],
  params: (P("band", "auto or length", "auto", [Width of the band.], [Largeur de la bande.]),),
  ex: ```
let b(w) = box(stroke: 0.3pt + luma(190),
  frame-graphic(28mm, 20mm, style: "greek", band: w))
stack(dir: ltr, spacing: 3mm, b(3mm), b(6mm), b(9mm))
```)

#opt("inset", "inset: 4mm",
  T[Distance between the edge of the box (or of the page) and the outside of the band. A printer rarely prints to the very edge: keep at least 3–4 mm for a page.][Distance entre le bord de la boîte (ou de la page) et l'extérieur de la bande. Une imprimante imprime rarement jusqu'au bord : gardez au moins 3 à 4 mm pour une page.],
  params: (P("inset", "length", "4mm", [Outer margin.], [Marge extérieure.]),),
  ex: ```
let b(i) = box(stroke: 0.3pt + luma(190),
  frame-graphic(28mm, 20mm, style: "greek", inset: i))
stack(dir: ltr, spacing: 3mm, b(0mm), b(4mm), b(8mm))
```)

#opt("radius", "radius: auto",
  T[Corner radius of the band. `auto` depends on the style (some styles have square corners by nature).][Rayon des coins de la bande. `auto` dépend du style (certains styles ont des coins carrés par nature).],
  params: (P("radius", "auto or length", "auto", [Corner radius.], [Rayon de coin.]),),
  ex: ```
let b(r) = box(stroke: 0.3pt + luma(190),
  frame-graphic(28mm, 20mm, style: "pearls", radius: r))
stack(dir: ltr, spacing: 3mm, b(0.5mm), b(4mm), b(9mm))
```)

#opt("period", "period: auto",
  T[Length of one repeat of the pattern along the band (used by `celtic`, `guilloche`, `pearls`). The frame rounds it so that a whole number of repeats fits each side.][Longueur d'un motif répété le long de la bande (utilisée par `celtic`, `guilloche`, `pearls`). Le cadre l'arrondit pour qu'un nombre entier de motifs tienne sur chaque côté.],
  params: (P("period", "auto or length", "auto", [Length of one repeat.], [Longueur d'un motif.]),),
  ex: ```
let b(p) = box(stroke: 0.3pt + luma(190),
  frame-graphic(36mm, 22mm, style: "guilloche", period: p))
stack(dir: ltr, spacing: 3mm, b(5mm), b(10mm))
```)

== #T("Colour and line", "Couleur et trait")

#opt("color", "color: rgb(\"#2f628c\")",
  T[Main colour of the style (blue by default).][Couleur principale du style (bleu par défaut).],
  params: (P("color", "color", "rgb(\"#2f628c\")", [Main colour.], [Couleur principale.]),),
  ex: ```
let b(c) = frame-graphic(28mm, 20mm, style: "classic", color: c)
stack(dir: ltr, spacing: 3mm, b(rgb("#2f628c")), b(rgb("#9a3324")), b(rgb("#1c7a78")))
```)

#opt("accent", "accent: rgb(\"#b07a1c\")",
  T[Second colour of the style (ochre by default): details, rosettes, leaves, corner ornaments.][Seconde couleur du style (ocre par défaut) : détails, rosettes, feuilles, ornements de coin.],
  params: (P("accent", "color", "rgb(\"#b07a1c\")", [Second colour.], [Seconde couleur.]),),
  ex: ```
let b(c) = frame-graphic(28mm, 20mm, style: "laurel", accent: c)
stack(dir: ltr, spacing: 3mm, b(rgb("#b07a1c")), b(rgb("#9a3324")), b(rgb("#4d7b47")))
```)

#opt("ink", "ink: rgb(\"#2b2622\")",
  T[Colour of the outlines (used by `celtic`, `guilloche`, `braces` and the knotted styles).][Couleur des contours (utilisée par `celtic`, `guilloche`, `braces` et les styles à entrelacs).],
  params: (P("ink", "color", "rgb(\"#2b2622\")", [Outline colour.], [Couleur des contours.]),),
  ex: ```
let b(c) = frame-graphic(36mm, 22mm, style: "braces", ink: c)
stack(dir: ltr, spacing: 3mm, b(rgb("#2b2622")), b(rgb("#9a3324")))
```)

#opt("line", "line: 0.6pt",
  T[Thickness of the thin rules (and of the hairlines of the guilloché styles).][Épaisseur des filets (et des traits fins des styles guilloché).],
  params: (P("line", "length", "0.6pt", [Rule thickness.], [Épaisseur des filets.]),),
  ex: ```
let b(t) = frame-graphic(28mm, 20mm, style: "pearls", line: t)
stack(dir: ltr, spacing: 3mm, b(0.3pt), b(0.6pt), b(1.4pt))
```)

#opt("paper", "paper: white",
  T[Colour of the page, used by the styles that *hide* what lies under their overlaps (`seigaiha`, `kilim`, `photo`, `baroque`…). If your page is not white, give its colour here; otherwise white patches show.][Couleur de la page, utilisée par les styles qui *cachent* ce qui se trouve sous leurs recouvrements (`seigaiha`, `kilim`, `photo`, `baroque`…). Si votre page n'est pas blanche, donnez ici sa couleur ; sinon des plages blanches apparaissent.],
  params: (P("paper", "color", "white", [Page colour.], [Couleur de la page.]),),
  ex: ```
let cream = rgb("#f4ecd8")
let b(p) = box(fill: cream, frame-graphic(36mm, 22mm, style: "kilim", paper: p))
stack(dir: ltr, spacing: 3mm, b(white), b(cream))
```)

== #T("Structure", "Structure")

#opt("strands", "strands: auto",
  T[Number of strands: `celtic` takes 2 (plait) or 3 (braid); `guilloche` takes 7 (a dense bundle).][Nombre de brins : `celtic` accepte 2 (tresse) ou 3 (natte) ; `guilloche` accepte 7 (faisceau dense).],
  params: (P("strands", "auto or integer", "auto", [Number of strands.], [Nombre de brins.]),),
  ex: ```
let b(n) = frame-graphic(36mm, 24mm, style: "celtic", strands: n)
stack(dir: ltr, spacing: 3mm, b(2), b(3))
```)

#opt("rules", "rules: true",
  T[Thin rules along both edges of the band (used by `celtic`, `guilloche`, `braces`). `false` leaves the pattern alone.][Filets fins le long des deux bords de la bande (utilisés par `celtic`, `guilloche`, `braces`). `false` ne laisse que le motif.],
  params: (P("rules", "bool", "true", [Draw the rules.], [Dessiner les filets.]),),
  ex: ```
let b(r) = frame-graphic(36mm, 22mm, style: "guilloche", rules: r)
stack(dir: ltr, spacing: 3mm, b(true), b(false))
```)

#opt("corners", "corners: true",
  T[Corner ornaments. `false` keeps the continuous contour and the pattern of the sides only. Where the corner ornament is a separate drawing it is lighter or darker than the contour and lies over it.][Ornements de coin. `false` ne garde que le contour continu et le motif des côtés. Quand l'ornement de coin est un dessin séparé, il est plus clair ou plus foncé que le contour et se superpose à lui.],
  params: (P("corners", "bool", "true", [Draw the corner ornaments.], [Dessiner les ornements de coin.]),),
  ex: ```
let b(c) = frame-graphic(36mm, 24mm, style: "bill-lens", corners: c)
stack(dir: ltr, spacing: 3mm, b(true), b(false))
```)

#opt("corner-color", "corner-color: auto",
  T[Colour of the corner ornaments of the `bill-*` styles. `auto` is a lighter shade of `accent`.][Couleur des ornements de coin des styles `bill-*`. `auto` est une teinte plus claire de `accent`.],
  params: (P("corner-color", "auto or color", "auto", [Corner colour.], [Couleur des coins.]),),
  ex: ```
let b(c) = frame-graphic(36mm, 24mm, style: "bill-lens", corner-color: c)
stack(dir: ltr, spacing: 3mm, b(auto), b(rgb("#9a3324")))
```)

#opt("binding", "binding: \"left\"",
  T[Side of the wire rings of the `coil` style: `"left"`, `"right"`, `"top"`, `"bottom"`, or `"none"` for the border alone. The other styles ignore it.][Côté des anneaux de reliure du style `coil` : `"left"`, `"right"`, `"top"`, `"bottom"`, ou `"none"` pour la bordure seule. Les autres styles l'ignorent.],
  params: (P("binding", "string", "\"left\"", [`"left"`, `"right"`, `"top"`, `"bottom"` or `"none"`.], [`"left"`, `"right"`, `"top"`, `"bottom"` ou `"none"`.]),),
  ex: ```
let b(s) = frame-graphic(30mm, 24mm, style: "coil", binding: s)
stack(dir: ltr, spacing: 3mm, b("left"), b("top"), b("none"))
```)

== #T("Texture and seal", "Texture et sceau")

#opt("texture", "texture: none",
  T[A pale background texture inside the frame, available for every style: `"scales"`, `"waves"` or `"rosettes"`. It adds many small shapes — use it on boxes and short documents rather than on a long book.][Une texture pâle en fond à l'intérieur du cadre, disponible pour tous les styles : `"scales"` (écailles), `"waves"` (vagues) ou `"rosettes"`. Elle ajoute beaucoup de petites formes — réservez-la aux boîtes et aux documents courts plutôt qu'à un long livre.],
  note: T[The texture fills the area inside the band, 1.5 mm away from it: the box must be larger than the band on both sides, or the compilation fails with a negative size.][La texture remplit la zone à l'intérieur de la bande, à 1,5 mm d'elle : la boîte doit être plus grande que la bande des deux côtés, sinon la compilation échoue avec une taille négative.],
  params: (P("texture", "none or string", "none", [`none`, `"scales"`, `"waves"` or `"rosettes"`.], [`none`, `"scales"`, `"waves"` ou `"rosettes"`.]),),
  ex: ```
let b(t) = box(stroke: 0.3pt + luma(190),
  frame-graphic(34mm, 28mm, style: "classic", texture: t))
stack(dir: ltr, spacing: 2mm, b("scales"), b("waves"), b("rosettes"))
```, cols: (1.5fr, 1fr))

#opt("texture-color", "texture-color: auto",
  T[Colour of the texture. `auto` is a pale shade of `accent`.][Couleur de la texture. `auto` est une teinte pâle de `accent`.],
  params: (P("texture-color", "auto or color", "auto", [Texture colour.], [Couleur de la texture.]),),
  ex: ```
let b(c) = box(stroke: 0.3pt + luma(190),
  frame-graphic(38mm, 28mm, style: "classic", texture: "waves", texture-color: c))
stack(dir: ltr, spacing: 3mm, b(auto), b(rgb("#1c7a78").lighten(65%)))
```)

#opt("seal", "seal: false",
  T[A guilloché seal (a rosette) in the bottom-right corner of the box, like on a diploma. Leave room for it in your layout.][Un sceau guilloché (une rosace) dans le coin inférieur droit de la boîte, comme sur un diplôme. Laissez-lui la place dans votre mise en page.],
  params: (P("seal", "bool", "false", [Draw the seal.], [Dessiner le sceau.]),),
  ex: ```
stack(dir: ltr, spacing: 3mm,
  frame-graphic(36mm, 26mm, style: "certificate", seal: true),
  frame-graphic(36mm, 26mm, style: "certificate"))
```)

// ───────────────────────────────────────────────────────────── 5. catalogue
= #T("Catalogue of styles", "Catalogue des styles")

#T[
The #styles-info.len() styles in the order of `frame-styles`, with default options. Each card shows the preview, the name to give to `style:`, the default width of the band, and a one-line description. The previews are pre-rendered images (62 × 44 mm); regenerate them with `sh scripts/build-catalogue.sh`. A style too heavy for your taste? Add `band: 4mm` (or less). For a sheet of all styles drawn live, compile `examples/gallery.typ` (see the repository).
][
Les #styles-info.len() styles dans l'ordre de `frame-styles`, avec les options par défaut. Chaque carte montre l'aperçu, le nom à donner à `style:`, la largeur par défaut de la bande et une description d'une ligne. Les aperçus sont des images pré-rendues (62 × 44 mm) ; régénérez-les avec `sh scripts/build-catalogue.sh`. Un style trop lourd à votre goût ? Ajoutez `band: 4mm` (ou moins). Pour une planche de tous les styles dessinés en direct, compilez `examples/gallery.typ` (voir le dépôt).
]
#v(4pt)
#grid(columns: (1fr, 1fr, 1fr), column-gutter: 10pt, row-gutter: 11pt,
  ..styles-info.pairs().map(((n, d)) => block(breakable: false, {
    [#metadata(n) <style-entry>]
    block(stroke: 0.4pt + luma(200), radius: 2pt, clip: true, cat-img(n))
    v(1pt)
    text(9.5pt, weight: "bold", fill: accent, raw(n)); text(8pt, fill: luma(100))[ · #band-of(n) mm]
    linebreak()
    text(8.3pt, md(d.at(lang)))
  })))

// ───────────────────────────────────────────────────────────── 6. recipes
= #T("Recipes", "Recettes")

== #T("1. A document with a frame on every page", "1. Un document avec un cadre sur chaque page")
```typ
#import "@preview/nibframe:0.3.0": *
#set page(paper: "a4")
#set text(font: "Libertinus Serif", size: 11pt)
#show: framed.with(style: "arabesque", color: rgb("#2f628c"), accent: rgb("#b07a1c"))

= Annual report
#lorem(300)
```
#T[`framed` sets the page background and margins; text, headings and figures flow inside the free area.][`framed` règle le fond et les marges de page ; texte, titres et figures s'écoulent dans la zone libre.]

== #T("2. A different frame on the cover and on the other pages", "2. Un cadre différent sur la couverture et sur les autres pages")
```typ
#import "@preview/nibframe:0.3.0": *

#set page(paper: "a4",
  margin: frame-margin(style: "certificate", gap: 10mm),
  background: frame-background(style: "certificate", texture: "rosettes"))
#align(center + horizon, text(30pt)[Diploma])

#set page(margin: frame-margin(style: "classic"), background: frame-background(style: "classic"))
#pagebreak()
= Contents
#lorem(120)
```
#T[A `set page` placed after content starts a new page with the new margin and background.][Un `set page` placé après du contenu démarre une nouvelle page avec la nouvelle marge et le nouveau fond.]

== #T("3. A framed certificate", "3. Un diplôme encadré")
#ex(```
frame-box(
  align(center)[
    #text(7pt, tracking: 1pt)[CERTIFICATE OF EXCELLENCE] \
    #v(2mm)
    #text(15pt, style: "italic")[Ada Lovelace] \
    #v(2mm)
    #text(6.5pt)[for her work on the Analytical Engine]
  ],
  width: 70mm, height: 48mm, style: "certificate",
  texture: "rosettes", seal: true, gap: 4mm,
)
```, cols: (1.3fr, 1fr))

== #T("4. Your own drawing inside the frame", "4. Votre propre dessin dans le cadre")
#T[Combine `frame-items` with `nibart` in the same figure: the frame and the drawing share one coordinate system (origin bottom-left).][Combinez `frame-items` et `nibart` dans la même figure : le cadre et le dessin partagent un repère (origine en bas à gauche).]
#ex(```
let (w, h) = (60mm, 40mm)
let heart = nib.mp-path("(30,8){dir 180}..(14,24)..(22,34){dir 0}..(30,26){dir 0}..(38,34)..(46,24)..cycle")
nib.mp-fig(
  ..frame-items(w, h, style: "bill-lens"),
  nib.draw(nib.shifted(heart, 0pt, 0pt),
    pen: nib.pencircle(2pt), fill: rgb("#9a3324")),
  width: w, height: h, origin: (0pt, 0pt), pad: 0pt,
)
```, cols: (1.5fr, 1fr))

== #T("5. The same style at every size", "5. Le même style à toutes les tailles")
#T[The frame is computed for the size you give: patterns repeat a whole number of times, corners stay at the corners.][Le cadre est calculé pour la taille donnée : les motifs se répètent un nombre entier de fois, les coins restent aux coins.]
#ex(```
stack(dir: ltr, spacing: 3mm, ..(
  (22mm, 34mm), (34mm, 22mm), (46mm, 16mm),
).map(((w, h)) => frame-graphic(w, h, style: "greek"))
)
```, cols: (1.6fr, 1fr))

== #T("6. Keeping your own margins", "6. Garder vos propres marges")
```typ
#import "@preview/nibframe:0.3.0": *
#set page(paper: "a5", margin: 22mm)
#show: framed.with(style: "pearls", margin: false)   // frame only, margins unchanged
```
#T[Check that your margin is at least `frame-margin(style: "pearls")` (here 15 mm) so that the text stays clear of the band.][Vérifiez que votre marge est au moins `frame-margin(style: "pearls")` (ici 15 mm) pour que le texte reste à distance de la bande.]

// ───────────────────────────────────────────────────────────── 7. notes
= #T("Notes and limits", "Remarques et limites")
#T[
- *Fixed page size.* `frame-background` and `framed` need a page whose width and height are lengths, not `auto`.
- *Rendering time.* Frames are computed by a WebAssembly plugin. Simple styles take a fraction of a second; the knotted styles (`celtic`, `braid`, `chain`, the `knot-*` family) take a few seconds for an A4 page and the same cost is paid on *every page*: Typst caches identical backgrounds, but a frame that depends on the page content does not benefit. `banknote` and the `bill-*` styles produce heavier PDF files because of their many hairlines.
- *Memory.* A document is limited by the total number of curves it contains. Textures and large knotted frames on hundreds of pages can exhaust memory; frame a few pages or use a lighter style for long documents.
- *Dependency.* `nibframe` imports `nibart` 0.3.0 internally (downloaded automatically by Typst from Universe in the published edition, installed beforehand in the local edition). A frame never needs a font.
- *Right-to-left documents.* The frame is symmetric, so it does not depend on the text direction; this combination has not been tested at length.
- *Colours.* The default colours (blue and ochre) go with white paper. For coloured paper set `paper:` (styles that hide overlaps) and choose `color`/`accent` with enough contrast.
][
- *Taille de page fixe.* `frame-background` et `framed` demandent une page dont la largeur et la hauteur sont des longueurs, pas `auto`.
- *Temps de calcul.* Les cadres sont calculés par un plugin WebAssembly. Les styles simples prennent une fraction de seconde ; les styles à entrelacs (`celtic`, `braid`, `chain`, la famille `knot-*`) prennent quelques secondes pour une page A4, et ce coût est payé sur *chaque page* : Typst met en cache les fonds identiques, mais un cadre qui dépend du contenu de la page n'en profite pas. `banknote` et les styles `bill-*` produisent des PDF plus lourds à cause de leurs nombreux traits fins.
- *Mémoire.* Un document est limité par le nombre total de courbes qu'il contient. Les textures et les grands cadres à entrelacs sur des centaines de pages peuvent épuiser la mémoire ; n'encadrez que quelques pages ou prenez un style plus léger pour les longs documents.
- *Dépendance.* `nibframe` importe `nibart` 0.3.0 en interne (téléchargé automatiquement par Typst depuis Universe dans l'édition publiée, installé au préalable dans l'édition locale). Un cadre n'a jamais besoin d'une police.
- *Documents de droite à gauche.* Le cadre est symétrique ; il ne dépend donc pas du sens du texte ; cette combinaison n'a pas été testée longuement.
- *Couleurs.* Les couleurs par défaut (bleu et ocre) vont avec le papier blanc. Pour du papier coloré, réglez `paper:` (styles qui cachent les recouvrements) et choisissez `color`/`accent` avec assez de contraste.
]

// ───────────────────────────────────────────────────────────── credits
= #T("Credits and licence", "Crédits et licence")
#T[
MIT licence (see `LICENSE`). All frames are drawn with `nibart` (Hobby's algorithm, pen envelopes, knots). The designs are original drawings: some stock vector sheets of guilloché borders, Celtic knotwork and arabesques served as *visual inspiration* only — no artwork was copied or traced.
][
Licence MIT (voir `LICENSE`). Tous les cadres sont dessinés avec `nibart` (algorithme de Hobby, enveloppes de plumes, nœuds). Les motifs sont des dessins originaux : quelques planches vectorielles de bordures guillochées, d'entrelacs celtiques et d'arabesques ont servi de *simple inspiration visuelle* — aucune œuvre n'a été copiée ni décalquée.
]
#v(4pt)
#T[*Author:* #pkg.authors.first() — *repository:* #link(pkg.repository).][*Auteur :* #pkg.authors.first() — *dépôt :* #link(pkg.repository).]

// ───────────────────────────────────────────────────────────── index
= #T("Index", "Index")
#context {
  let es = query(<api-entry>).sorted(key: e => e.value)
  text(11.5pt, weight: "bold", fill: accent)[#T("Functions and options", "Fonctions et options")]
  v(2pt)
  set text(size: 9pt)
  columns(2, gutter: 16pt, for e in es {
    block(spacing: 3.5pt, link(e.location(), [#raw(e.value) #box(width: 1fr, repeat[#h(2pt).#h(2pt)]) #counter(page).at(e.location()).first()]))
  })
  v(8pt)
  text(11.5pt, weight: "bold", fill: accent)[#T("Styles", "Styles")]
  v(2pt)
  let ss = query(<style-entry>).sorted(key: e => e.value)
  columns(3, gutter: 14pt, for e in ss {
    block(spacing: 3pt, link(e.location(), [#raw(e.value) #box(width: 1fr, repeat[#h(2pt).#h(2pt)]) #counter(page).at(e.location()).first()]))
  })
}
