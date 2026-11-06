// =====================================================================
//  visual-cetz — montrer un exemple par son code ET son rendu
// =====================================================================
//
//  Le guide « Visual CeTZ » (51 pages, 200 exemples) est construit avec
//  ces quatre fonctions. Elles sont exposées ici parce qu'elles servent
//  à tout le monde, pas seulement à lui : dès qu'on documente une
//  bibliothèque de dessin, on veut le code à gauche et sa sortie à
//  droite, sans risquer qu'ils divergent.
//
//  LE CODE MONTRÉ EST CELUI QUI EST EXÉCUTÉ. C'est le point entier.
//  Recopier l'exemple à côté de son image marche un mois, puis quelqu'un
//  corrige l'un sans l'autre et la documentation ment. Ici la source est
//  unique : `ex()` reçoit un bloc brut, l'affiche tel quel, puis
//  l'évalue. Les deux ne peuvent pas se contredire.
//
//      #import "@preview/visual-cetz:0.1.0": ex, exr, note, api
//
//      #ex(```
//      circle((0, 0), radius: 1)
//      line((-1, 0), (1, 0))
//      ```)
//
//  Le guide complet est dans `guide/` — voir le README.

#import "@preview/cetz:0.5.2"

// ---------------------------------------------------------------------
//  Le contexte d'évaluation
// ---------------------------------------------------------------------
//
//  `eval` N'A PAS ACCÈS AUX IMPORTS DU FICHIER APPELANT. Il faut lui
//  passer explicitement tout ce que l'exemple utilise, d'où ce
//  dictionnaire. `dictionary(draw)` déplie les fonctions de dessin
//  (`circle`, `line`, `content`…) pour que l'exemple s'écrive comme
//  après un `import cetz.draw: *`, ce qui est la façon dont on écrit
//  vraiment du CeTZ.
#let cetz-scope = dictionary(cetz.draw) + (
  cetz: cetz,
  canvas: cetz.canvas,
  tree: cetz.tree,
  angle-lib: cetz.angle,
  decorations: cetz.decorations,
  palette: cetz.palette,
  vector: cetz.vector,
  matrix: cetz.matrix,
  util: cetz.util,
  intersection: cetz.intersection,
)

/// Enrichit le contexte avec d'autres bibliothèques.
///
/// Les extensions de CeTZ (`cetz-plot`, `cetz-venn`…) ne sont pas
/// importées ici : ce serait imposer leur téléchargement à qui n'en veut
/// pas, et figer leurs versions. On les ajoute au besoin :
///
///     #import "@preview/cetz-plot:0.1.4": plot, chart
///     #let scope = with-scope((plot: plot, chart: chart))
///     #ex(scope: scope, ```
///     plot.plot(size: (4, 3), { plot.add(x => calc.sin(x), domain: (0, 6)) })
///     ```)
#let with-scope(extra) = cetz-scope + extra

// ---------------------------------------------------------------------
//  Le style par défaut
// ---------------------------------------------------------------------

#let default-style = (
  fill: rgb("#f6f8fa"),
  stroke: 0.4pt + rgb("#d0d7de"),
  radius: 3pt,
  size: 7.6pt,
)

// ---------------------------------------------------------------------
//  ex — un canevas CeTZ, code à gauche, rendu à droite
// ---------------------------------------------------------------------

/// Affiche un extrait de code CeTZ et son rendu, côte à côte.
///
/// `src` est un bloc `raw` (des accents graves) ou une chaîne. Son
/// contenu est le corps d'un `cetz.canvas({ … })` : pas besoin d'écrire
/// le canevas ni l'import, ils sont ajoutés.
///
/// - `ratio` : la part de largeur prise par le code (50 % par défaut).
/// - `len` : l'unité du canevas, comme `cetz.canvas(length:)`.
/// - `dbg` : passe `debug: true` au canevas, qui trace alors ses repères.
/// - `scope` : le contexte d'évaluation, voir `with-scope`.
/// - `style` : `fill`, `stroke`, `radius`, `size` du bloc de code.
///
/// La boîte est `breakable: false` : un exemple coupé entre deux pages,
/// code d'un côté et image de l'autre, ne veut plus rien dire.
#let ex(
  src,
  ratio: 50%,
  len: 1cm,
  dbg: false,
  scope: cetz-scope,
  style: (:),
) = {
  let st = default-style + style
  // `raw` ou chaîne : on accepte les deux. Le `.trim("\n")` retire le
  // saut de ligne que les accents graves ajoutent d'eux-mêmes, sans quoi
  // chaque bloc de code commence par une ligne vide.
  let body = (if type(src) == str { src } else { src.text }).trim("\n")
  let pic = eval(
    "canvas(length: " + repr(len) + ", debug: " + repr(dbg) + ", {\n"
      + body + "\n})",
    mode: "code",
    scope: scope,
  )
  block(
    breakable: false,
    width: 100%,
    inset: (top: 3pt, bottom: 3pt),
    grid(
      columns: (ratio, 1fr),
      column-gutter: 8pt,
      align: (top + left, horizon + center),
      block(
        width: 100%, fill: st.fill, radius: st.radius,
        inset: (x: 5pt, y: 4pt), stroke: st.stroke,
        text(size: st.size, raw(body, lang: "typc", block: true)),
      ),
      block(width: 100%, inset: 2pt, pic),
    ),
  )
}

// ---------------------------------------------------------------------
//  exr — même chose, pour du balisage complet
// ---------------------------------------------------------------------

/// Comme `ex`, mais `src` est du balisage Typst complet, pas le corps
/// d'un canevas. Sert aux exemples qui produisent autre chose qu'une
/// figure — un tableau, un `plot` posé dans une grille…
///
/// LES LIGNES `#import "@preview/…"` SONT AFFICHÉES MAIS RETIRÉES avant
/// l'évaluation : `eval` n'atteint pas le système de fichiers et
/// échouerait dessus. L'exemple reste ainsi copiable tel quel par le
/// lecteur — qui, lui, a besoin de cette ligne — sans casser le rendu.
#let exr(src, ratio: 50%, scope: cetz-scope, style: (:)) = {
  let st = default-style + style
  let body = (if type(src) == str { src } else { src.text }).trim("\n")
  let code = body
    .split("\n")
    .filter(l => not l.trim().starts-with("#import \"@preview"))
    .join("\n")
  block(
    breakable: false,
    width: 100%,
    inset: (top: 3pt, bottom: 3pt),
    grid(
      columns: (ratio, 1fr),
      column-gutter: 8pt,
      align: (top + left, horizon + center),
      block(
        width: 100%, fill: st.fill, radius: st.radius,
        inset: (x: 5pt, y: 4pt), stroke: st.stroke,
        text(size: st.size, raw(body, lang: "typ", block: true)),
      ),
      block(width: 100%, inset: 2pt, eval(code, mode: "markup", scope: scope)),
    ),
  )
}

// ---------------------------------------------------------------------
//  note, api — les deux encarts du guide
// ---------------------------------------------------------------------

/// Un encart d'avertissement, filet coloré à gauche.
#let note(body, title: "Note", colour: rgb("#e3b341"),
          fill: rgb("#fff8e6")) = block(
  width: 100%, fill: fill, stroke: (left: 2pt + colour),
  inset: (x: 7pt, y: 5pt), radius: 2pt, breakable: false,
  [#text(weight: "bold", size: 8pt)[#title] #h(4pt)
   #text(size: 8.5pt)[#body]],
)

/// Une signature de fonction, avec sa description sur la ligne suivante.
#let api(sig, ..desc) = block(width: 100%, inset: (y: 2pt))[
  #text(size: 8.5pt, raw(sig, lang: "typc"))
  #if desc.pos().len() > 0 [
    #linebreak()
    #text(size: 8pt, fill: rgb("#444"), desc.pos().first())
  ]
]
