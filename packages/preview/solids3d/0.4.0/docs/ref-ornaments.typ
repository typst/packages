#import "_h.typ": *

= #T("Reference — knots, braces and plates", "Référence — nœuds, accolades et planches")

== #T("Knots and links", "Nœuds et entrelacs")

#T[
A strand is a function `t => (x, y, z)` on `[0, 1)` describing a *closed* curve (or an array of points). `knot3` projects the strands as tubes with true over / under crossings. In `fig` you simply give the curves; use `knot3` directly inside `picture` for several knots in one scene or to choose the colours.
][
Un brin est une fonction `t => (x, y, z)` sur `[0, 1)` décrivant une courbe *fermée* (ou un tableau de points). `knot3` projette les brins en tubes avec de vrais croisements dessus / dessous. Dans `fig`, on donne simplement les courbes ; utilisez `knot3` directement dans `picture` pour plusieurs nœuds dans une scène ou pour choisir les couleurs.
]

#api("knot3", "knot3(..strands, samples: 120, width: 7pt, colors: auto, style: \"gap\", gap: auto, outline: auto, ink: auto, flips: ())",
  T[Draws one or several closed curves as tubes. At each crossing the strand that is *lower* (further from the camera) is interrupted (`style: "gap"`) or simply drawn first and covered by the upper one (`style: "weave"`, continuous tubes).][Dessine une ou plusieurs courbes fermées comme des tubes. À chaque croisement, le brin du *dessous* (le plus éloigné de la caméra) est interrompu (`style: "gap"`) ou simplement dessiné d'abord puis recouvert par celui du dessus (`style: "weave"`, tubes continus).],
  params: (
    P("..strands", "function or array", none, [Closed curves `t => point`, or arrays of such functions (as returned by `hopf-link()`, `borromean()`).], [Courbes fermées `t => point`, ou tableaux de telles fonctions (comme ceux de `hopf-link()`, `borromean()`).]),
    P("samples", "integer", "120", [Points per strand.], [Points par brin.]),
    P("width", "length", "7pt", [Tube diameter on the page.], [Diamètre du tube sur la page.]),
    P("colors", "array", "auto", [One colour per strand (cycles).], [Une couleur par brin (en boucle).]),
    P("style", "string", "\"gap\"", [`"gap"` or `"weave"`.], [`"gap"` ou `"weave"`.]),
    P("gap", "length", "auto", [Clearance left at an interrupted crossing.], [Dégagement laissé à un croisement interrompu.]),
    P("outline", "length", "auto", [Width of the dark outline (`auto` = 14 % of `width`).], [Épaisseur du contour sombre (`auto` = 14 % de `width`).]),
    P("ink", "colour", "auto", [Colour of the outline.], [Couleur du contour.]),
    P("flips", "array", "()", [Indices of crossings whose over / under order is reversed by hand (to fix a view-dependent ambiguity).], [Indices des croisements dont l'ordre dessus / dessous est inversé à la main (pour lever une ambiguïté dépendant de la vue).]),
  ),
  note: T[Gap-style knots with many near crossings (Borromean rings) can lose pieces: prefer `"weave"` or a thinner tube.][Les nœuds en style « gap » à nombreux croisements proches (anneaux de Borromée) peuvent perdre des morceaux : préférez `"weave"` ou un tube plus fin.],
  ex: ```
picture(width: 4cm, projection: orthographic(5, 3, 4),
  knot3(..hopf-link(R: 1.2), width: 9pt, colors: (rgb("#c0392b"), rgb("#2c6fbb")), style: "weave"))
```)

#api("trefoil / figure-eight / torus-knot / hopf-link / borromean", "trefoil(scale: 1.0)     figure-eight(scale: 1.0)     torus-knot(p, q, R: 2.0, r: 0.9)     hopf-link(R: 1.0)     borromean(a: 2.0, b: 1.2)",
  T[Ready-made curves. `trefoil` and `figure-eight` return one strand, `torus-knot(p, q)` the (p, q) torus knot on a torus of centre radius `R` and tube radius `r` (`p`, `q` coprime), `hopf-link` and `borromean` return arrays of two and three strands.][Courbes toutes faites. `trefoil` et `figure-eight` renvoient un brin, `torus-knot(p, q)` le nœud torique (p, q) sur un tore de rayon central `R` et de rayon de tube `r` (`p`, `q` premiers entre eux), `hopf-link` et `borromean` renvoient des tableaux de deux et trois brins.],
  params: (
    P("scale", "number", "1.0", [Overall size (the trefoil is about 4 units wide).], [Taille globale (le trèfle fait environ 4 unités de large).]),
    P("p, q", "integer", none, [Windings around the axis / around the tube.], [Enroulements autour de l'axe / autour du tube.]),
    P("R, r", "number", "2.0, 0.9", [Radii of the torus.], [Rayons du tore.]),
    P("a, b", "number", "2.0, 1.2", [Semi-axes of the three ellipses.], [Demi-axes des trois ellipses.]),
  ),
  ex: ```
grid(columns: 2, gutter: 4pt,
  fig(torus-knot(2, 3), size: 2.8cm, tube: 8pt, view: (20, 60)),
  fig(torus-knot(3, 4, R: 2, r: 0.9), size: 2.8cm, tube: 6pt, view: (20, 60)))
```)

#api("brace3", "brace3(a, b, label, flip: auto, distance: 6pt, outside: true, offset: (0, 0, 0), kind: \"brace\", amplitude: 9pt, light: 0.35pt, heavy: 1.7pt, pen: auto, gap: 5pt)",
  T[A calligraphic brace between two 3D points, drawn by nibart's `delimiter`: the pen swells where the curve bends. The label (text or formula) is centred beyond the tip. By default the brace is pushed to the *outer* side of the figure, past its bounding box, so that it never crosses the drawing; `outside: false` keeps it next to the segment.][Une accolade calligraphique entre deux points 3D, dessinée par le `delimiter` de nibart : la plume gonfle là où la courbe tourne. L'étiquette (texte ou formule) est centrée au-delà de la pointe. Par défaut l'accolade est repoussée du côté *extérieur* de la figure, au-delà de sa boîte englobante, pour ne jamais couper le dessin ; `outside: false` la garde contre le segment.],
  params: (
    P("a, b", "point", none, [Ends of the segment to measure.], [Extrémités du segment à mesurer.]),
    P("label", "content", "none", [Label (third positional argument, or `label:`).], [Étiquette (troisième argument positionnel, ou `label:`).]),
    P("flip", "auto or bool", "auto", [Side of the brace: `auto` = outer side; `true` / `false` force the other / the first one.], [Côté de l'accolade : `auto` = côté extérieur ; `true` / `false` forcent l'un ou l'autre côté.]),
    P("distance", "length", "6pt", [Gap on paper between the segment (or the figure) and the brace.], [Écart sur le papier entre le segment (ou la figure) et l'accolade.]),
    P("outside", "bool", "true", [Push beyond the bounding box of the figure.], [Repousser au-delà de la boîte englobante de la figure.]),
    P("offset", "point", "(0, 0, 0)", [3D displacement of the whole brace.], [Déplacement 3D de toute l'accolade.]),
    P("kind", "string", "\"brace\"", [`"brace"`, `"paren"` or `"paren-straight"`.], [`"brace"`, `"paren"` ou `"paren-straight"`.]),
    P("amplitude", "length", "9pt", [Height of the tip.], [Hauteur de la pointe.]),
    P("light, heavy", "length", "0.35pt, 1.7pt", [Hairline and full widths of the nib.], [Largeurs du délié et du plein de la plume.]),
    P("pen", "colour", "auto", [Ink colour (`auto` = the ink of the figure).], [Couleur d'encre (`auto` = l'encre de la figure).]),
    P("gap", "length", "5pt", [Distance of the label from the tip.], [Distance de l'étiquette à la pointe.]),
  ),
  ex: ```
fig(brick(3, 2, 1.4), size: 4.6cm,
  brace3((-1.5, 1, -0.7), (1.5, 1, -0.7), $a$),
  brace3((1.5, 1, -0.7), (1.5, -1, -0.7), $b$, kind: "paren"),
  brace3((1.5, 1, -0.7), (1.5, 1, 0.7), $c$, flip: true))
```)

== #T("Plates", "Planches")

#api("plate", "plate(body, title: none, subtitle: none, number: none, caption: none, ink: …, paper: …, pad: 16pt, band: 2.2pt, corner: 9pt, border: true, width: auto, font: auto, ornament: true)",
  T[An engraved plate around `body`: cream paper, a double line frame with notched corners (drawn by nibart), a title with plate number (`Pl. I`), a calligraphic flourish and a caption. Use it for figure sheets in a book or a course.][Une planche gravée autour de `body` : papier crème, cadre à double filet et coins échancrés (dessiné par nibart), titre avec numéro de planche (`Pl. I`), fleuron calligraphique et légende. À utiliser pour les planches de figures d'un livre ou d'un cours.],
  params: (
    P("body", "content", none, [What is framed.], [Ce qui est encadré.]),
    P("title, subtitle", "content", "none", [Heading(s) above the figure (small capitals).], [Titre(s) au-dessus de la figure (petites capitales).]),
    P("number", "content", "none", [Plate number (`Pl. I`…).], [Numéro de planche (`Pl. I`…).]),
    P("caption", "content", "none", [Italic caption below.], [Légende en italique dessous.]),
    P("ink, paper", "colour", "engraving colours", [Ink and paper colours.], [Couleurs d'encre et de papier.]),
    P("pad", "length", "16pt", [Space between the frame and the content.], [Espace entre le cadre et le contenu.]),
    P("band", "length", "2.2pt", [Width of the frame band (keep it slim).], [Largeur de la bande du cadre (la garder fine).]),
    P("corner", "length", "9pt", [Size of the corner notches.], [Taille des échancrures de coin.]),
    P("border", "bool", "true", [Draw the frame.], [Tracer le cadre.]),
    P("width", "length, ratio or auto", "auto", [Total width.], [Largeur totale.]),
    P("font", "string or array", "auto", [Font of the titles.], [Police des titres.]),
    P("ornament", "bool", "true", [Draw the flourish under the title.], [Tracer le fleuron sous le titre.]),
  ),
  ex: ```
plate(title: "Les solides", subtitle: "de révolution", number: "II", width: 7.4cm, band: 1.6pt,
  caption: [Cône et sphère],
  fig(cone(1, 1.8), sphere(0.7, c: (1.8, 0, 0.7)), size: 5.2cm, style: "engraving"))
```)
