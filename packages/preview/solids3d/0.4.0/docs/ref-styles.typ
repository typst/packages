#import "_h.typ": *

= #T("Reference — styles: engraving, vintage, pencil", "Référence — styles : gravure, vintage, crayon")

#T[
Three look-and-feel families are available through `picture(style: …)`; `fig` sets them for you (`style: "engraving"`, `"banknote"`, `"etching"`, `"vintage"`, `"pencil"`). *Engraving* turns tone into the thickness of parallel lines (copper-plate engraving, banknotes); *vintage* engraves surfaces like an old scientific plate (a light sepia line screen); *pencil* does the same in wavy graphite and draws every stroke with a rough graphite pen. In `vintage` and `pencil`, a surface with no material, `hatch:` or `stipple:` is engraved by the lit line screen (`engraving:` tunes it); an explicit `hatch:`, `stipple:` or material gives the projected-patch hatching described below.
][
Trois familles de rendu sont disponibles via `picture(style: …)` ; `fig` les règle pour vous (`style: "engraving"`, `"banknote"`, `"etching"`, `"vintage"`, `"pencil"`). La *gravure* traduit le ton en épaisseur de lignes parallèles (taille-douce, billets de banque) ; le style *vintage* grave les surfaces comme une planche scientifique ancienne (trame sépia légère) ; le *crayon* fait de même en graphite ondulé et trace chaque trait avec une mine rugueuse. En `vintage` et `pencil`, une surface sans matériau, `hatch:` ni `stipple:` est gravée par la trame de lignes éclairée (`engraving:` la règle) ; un `hatch:`, `stipple:` ou matériau explicite donne le hachage par patch projeté décrit plus bas.
]

== #T("Engraving", "Gravure")

#api("engraving", "engraving(spacing: 2.1pt, angle: 38, cross: true, cross-angle: 78, wave: none, gain: 1.0, minimum: 0.13pt, contours: true, nib-width: 1.35, nib-angle: 38, nib-ratio: 0.36, ink: auto, paper: auto, step: 1.6pt)",
  T[Settings of the engraving screen. Pass the result to `picture(style: "engraving", engraving: engraving(…))` or to `fig(…, engraving: …)`. The surface is covered by parallel lines whose *thickness* (not spacing) follows the lighting, drawn with a broad nib; a second family crosses them in the deep shadows. The `banknote` style of `fig` is `wave: (…)`; `etching` changes `ink` and `paper`.][Réglages de la trame de gravure. Passez le résultat à `picture(style: "engraving", engraving: engraving(…))` ou à `fig(…, engraving: …)`. La surface est couverte de lignes parallèles dont l'*épaisseur* (et non l'espacement) suit l'éclairage, tracées à la plume large ; une seconde famille les croise dans les ombres profondes. Le style `banknote` de `fig` correspond à `wave: (…)` ; `etching` change `ink` et `paper`.],
  params: (
    P("spacing", "length", "2.1pt", [Distance between two lines.], [Distance entre deux lignes.]),
    P("angle", "number", "38", [Direction of the first family, in degrees.], [Direction de la première famille, en degrés.]),
    P("cross", "bool", "true", [Add the crossed family in the deepest shadows.], [Ajouter la famille croisée dans les ombres les plus profondes.]),
    P("cross-angle", "number", "78", [Offset of the second family from `angle`.], [Décalage de la seconde famille par rapport à `angle`.]),
    P("wave", "none or dictionary", "none", [`none` = straight lines; `(amplitude: 0.5pt, length: 14pt, shift: 0.0)` = wavy lines (banknote). A non-zero `shift` turns the phase from line to line (moiré).], [`none` = lignes droites ; `(amplitude: 0.5pt, length: 14pt, shift: 0.0)` = lignes ondulées (billet). Un `shift` non nul fait tourner la phase de ligne en ligne (moiré).]),
    P("gain", "number", "1.0", [Quantity of ink: > 1 darker, < 1 lighter.], [Quantité d'encre : > 1 plus sombre, < 1 plus clair.]),
    P("minimum", "length", "0.13pt", [Thinnest visible line; below it the line disappears (white highlights).], [Ligne visible la plus fine ; en dessous elle disparaît (reflets blancs).]),
    P("contours", "bool", "true", [Broad-nib outlines of the surfaces.], [Contours à la plume large des surfaces.]),
    P("nib-width, nib-angle, nib-ratio", "number", "1.35, 38, 0.36", [Width factor, angle (degrees) and flatness of the contour nib.], [Facteur de largeur, angle (degrés) et aplatissement de la plume des contours.]),
    P("ink, paper", "colour", "auto", [Ink and paper colours (defaults: warm black on cream).], [Couleurs d'encre et de papier (défauts : noir chaud sur crème).]),
    P("step", "length", "1.6pt", [Sampling step along a line (smaller = smoother, slower).], [Pas d'échantillonnage le long d'une ligne (plus petit = plus lisse, plus lent).]),
  ),
  ex: ```
let s = torus(1, 0.4)
let e(opts) = fig(s, size: 2.6cm, view: "high", style: "engraving", engraving: engraving(..opts))
grid(columns: 3, gutter: 4pt,
  e((:)),
  e((angle: 0, cross: false, spacing: 3pt)),
  e((wave: (amplitude: 0.7pt, length: 12pt), gain: 1.3)))
```)

#api("engraved", "engraved(shape, m: 48, rim: auto, edges: none, color: none)",
  T[One-call engraved solid for `picture(style: "engraving")`: the hatched surface, its silhouette, and optionally the edges (cone base, box edges). It is what `fig` uses.][Solide gravé en un appel pour `picture(style: "engraving")` : la surface hachurée, sa silhouette, et éventuellement les arêtes (base d'un cône, arêtes d'un pavé). C'est ce qu'utilise `fig`.],
  params: (
    P("shape", "shape", none, [Solid of revolution.], [Solide de révolution.]),
    P("m", "integer", "48", [Samples of the silhouette.], [Échantillons de la silhouette.]),
    P("rim", "pen or none", "auto", [Pen of the contour (`auto` = 0.8 pt); `none` = no contour.], [Plume du contour (`auto` = 0,8 pt) ; `none` = pas de contour.]),
    P("edges", "pen or none", "none", [Pen for the wireframe edges.], [Plume des arêtes filaires.]),
    P("color", "colour", "none", [Surface colour (sets the tone).], [Couleur de la surface (règle le ton).]),
  ),
  ex: ```
picture(width: 4cm, projection: orthographic(4, 3, 2), style: "engraving",
  engraved(cone(1, 1.8), edges: linewidth(0.6)),
  engraved(sphere(0.5, c: (1.6, 0, 0.5))))
```)

== #T("Vintage and pencil", "Vintage et crayon")

#api("vintage-hatch", "vintage-hatch(spacing: 0.24, angle: 35.0, cross: false, broken: true, lit: true, segment: 0.22, gap: 0.08, light: auto, count: none, length: none, crosshatch: none, seed: 11, pen: …)",
  T[Hatching specification given to `draw(surface, hatch: …)`. Dashes are broken and shortened where the light is strong (`lit: true`).][Spécification de hachures donnée à `draw(surface, hatch: …)`. Les traits sont brisés et raccourcis là où la lumière est forte (`lit: true`).],
  params: (
    P("spacing", "number", "0.24", [Distance between hatch lines, in projected units.], [Distance entre hachures, en unités projetées.]),
    P("angle", "number", "35", [Direction, in degrees.], [Direction, en degrés.]),
    P("cross", "bool", "false", [Second family at right angles.], [Seconde famille à angle droit.]),
    P("broken", "bool", "true", [Break lines into short segments (`segment`, `gap`).], [Briser les lignes en segments courts (`segment`, `gap`).]),
    P("lit", "bool", "true", [Hatch only the shaded part.], [Ne hachurer que la partie ombrée.]),
    P("segment, gap", "number", "0.22, 0.08", [Length of segments and gaps (broken lines).], [Longueur des segments et des intervalles (lignes brisées).]),
    P("count, length, crosshatch, seed", "…", "none, none, none, 11", [Kept for compatibility, ignored since 0.4.], [Conservés pour compatibilité, ignorés depuis la 0.4.]),
    P("pen", "pen", "pale sepia", [Pen of the hatch lines.], [Plume des hachures.]),
  ),
  ex: ```
let s = sphere(1)
picture(width: 3.6cm, projection: orthographic(4, 2, 1.6), style: "vintage",
  draw(surface(s), hatch: vintage-hatch(spacing: 0.07, cross: true, lit: false)),
  draw(silhouette(s)))
```)

#api("vintage-stipple", "vintage-stipple(count: 42, seed: 0, min-size: 0.012, max-size: 0.028, gamma: 1.8, distribution: \"random\", lit: true, light: auto, max-patch-count: 96, pen: …)",
  T[Stippling (dots) instead of hatching: dots are denser and bigger in the shadows.][Pointillé à la place des hachures : les points sont plus denses et plus gros dans l'ombre.],
  params: (
    P("count", "integer", "42", [Dots per patch at full shadow.], [Points par patch dans l'ombre totale.]),
    P("seed", "integer", "0", [Random seed.], [Graine aléatoire.]),
    P("min-size, max-size", "number", "0.012, 0.028", [Dot sizes (projected units).], [Tailles des points (unités projetées).]),
    P("gamma", "number", "1.8", [Tone curve.], [Courbe de ton.]),
    P("distribution", "string", "\"random\"", [Placement of the dots.], [Placement des points.]),
    P("lit, light", "…", "true, auto", [As in `vintage-hatch`.], [Comme pour `vintage-hatch`.]),
    P("max-patch-count", "integer", "96", [Patches treated at most (speed limit).], [Nombre maximal de patchs traités (limite de vitesse).]),
  ),
  ex: ```
let s = sphere(1)
picture(width: 3.6cm, projection: orthographic(4, 2, 1.6), style: "vintage",
  draw(surface(s), stipple: vintage-stipple(count: 240, min-size: 0.02, max-size: 0.05, lit: false)),
  draw(silhouette(s)))
```)

#api("vintage-shaded / vintage-material", "vintage-shaded(shape, hatch: auto, stipple: none, pen: auto, outline: auto)     vintage-material(color: vintage-wash, opacity: 0.82)",
  T[`vintage-shaded` is the vintage counterpart of `engraved`: a hatched surface and its outline in one call. `vintage-material` is the translucent sepia wash used as surface colour. Constants: `vintage-paper`, `vintage-ink`, `vintage-pale-ink`, `vintage-wash`.][`vintage-shaded` est l'équivalent vintage de `engraved` : une surface hachurée et son contour en un appel. `vintage-material` est le lavis sépia translucide utilisé comme couleur de surface. Constantes : `vintage-paper`, `vintage-ink`, `vintage-pale-ink`, `vintage-wash`.],
  params: (
    P("shape", "shape", none, [The solid.], [Le solide.]),
    P("hatch, stipple", "spec", "auto, none", [`auto` engraves the surface by tone; otherwise a `vintage-hatch()` or `vintage-stipple()` spec.], [`auto` grave la surface selon le ton ; sinon une spécification `vintage-hatch()` ou `vintage-stipple()`.]),
    P("pen, outline", "pen", "auto", [Hatch pen and outline pen.], [Plume des hachures et plume du contour.]),
    P("color, opacity", "colour, number", "vintage-wash, 0.82", [Parameters of `vintage-material`.], [Paramètres de `vintage-material`.]),
  ),
  ex: ```
picture(width: 4.4cm, projection: orthographic(4, 2, 1.6), style: "vintage",
  vintage-shaded(cylinder(0.7, 1.4)),
  vintage-shaded(sphere(0.5, c: (1.4, 0, 0.5)), stipple: vintage-stipple(), hatch: none))
```)

#api("vintage-picture / pencil-picture", "vintage-picture(..commands, …picture options)     pencil-picture(..commands, …picture options)",
  T[`picture` with `style: "vintage"` or `style: "pencil"` already set (warm paper background). Same options as `picture`.][`picture` avec `style: "vintage"` ou `style: "pencil"` déjà réglé (fond de papier chaud). Mêmes options que `picture`.],
  ex: ```
let s = cone(0.9, 1.6)
pencil-picture(width: 3.4cm, projection: orthographic(4, 2, 1.6),
  draw(surface(s)), draw(silhouette(s)))
```)

#api("pencil-pen", "pencil-pen(paint: black, thickness: 0.65pt, roughness: 0.10, passes: 1, seed: 0, opacity: 0.82, nib-major: 1.15, nib-angle: 24.0, nib-ratio: 0.42, pressure: none, samples: none, cap: \"round\", join: \"round\")",
  T[A graphite pen: an elliptical nib swept along the path with a little jitter (`roughness`) and several passes. Use it as any pen: `draw(path, pencil-pen(thickness: 1pt, passes: 2))`.][Une mine de graphite : une plume elliptique balayée le long du chemin avec un peu de tremblement (`roughness`) et plusieurs passes. S'utilise comme n'importe quelle plume : `draw(chemin, pencil-pen(thickness: 1pt, passes: 2))`.],
  params: (
    P("paint", "colour", "black", [Graphite colour.], [Couleur de la mine.]),
    P("thickness", "length", "0.65pt", [Line width.], [Épaisseur du trait.]),
    P("roughness", "number", "0.10", [Amplitude of the hand tremble.], [Amplitude du tremblement de la main.]),
    P("passes", "integer", "1", [Number of overlaid strokes.], [Nombre de traits superposés.]),
    P("seed", "integer", "0", [Random seed.], [Graine aléatoire.]),
    P("opacity", "number", "0.82", [Opacity of each pass.], [Opacité de chaque passe.]),
    P("nib-major, nib-angle, nib-ratio", "number", "1.15, 24, 0.42", [Shape of the elliptical nib.], [Forme de la plume elliptique.]),
    P("pressure, samples", "…", "none", [Pressure profile along the path, samples.], [Profil de pression le long du chemin, échantillons.]),
    P("cap, join", "string", "\"round\"", [Line cap and join.], [Terminaison et jonction.]),
  ),
  ex: ```
picture(width: 3.6cm, projection: orthographic(4, 3, 2.4), style: "pencil",
  draw(box3(O, (1.6, 1.2, 1)), pencil-pen(thickness: 1.1pt, passes: 2, roughness: 0.2)))
```)

== #T("Other tools", "Autres outils")

#api("solid-plot", "solid-plot(shape, size: 6cm, projection: currentprojection, light: currentlight, style: \"none\", surfacepen: none, meshpen: none, hatch: none, stipple: none, outline: none, m: auto, n: 12, shading: \"smooth\", refine: true, backend: \"svg\")     (alias plot3d)",
  T[One-call figure for a solid with explicit pens: kept for compatibility; `fig` is the simpler way.][Figure d'un solide en un appel avec plumes explicites : conservée pour compatibilité ; `fig` est plus simple.],
  ex: ```
solid-plot(sphere(1), size: 3cm, projection: orthographic(4, 2, 1.6),
  surfacepen: rgb("#a9c4e8"), outline: linewidth(0.8pt))
```)

#api("obj", "obj(text, colors: (:), transform: none)",
  T[Reads the text of a Wavefront `.obj` file (`v` vertices, `f` faces, `g` / `usemtl` groups) and returns a surface. Load the file with `read("model.obj")`. `colors` maps group names to colours, `transform` is a 4 × 4 matrix applied to the vertices.][Lit le texte d'un fichier Wavefront `.obj` (sommets `v`, faces `f`, groupes `g` / `usemtl`) et renvoie une surface. Chargez le fichier avec `read("modele.obj")`. `colors` associe des noms de groupes à des couleurs, `transform` est une matrice 4 × 4 appliquée aux sommets.],
  params: (
    P("text", "string", none, [Content of the `.obj` file.], [Contenu du fichier `.obj`.]),
    P("colors", "dictionary", "(:)", [Group name → colour.], [Nom de groupe → couleur.]),
    P("transform", "transform", "none", [Matrix applied to the vertices.], [Matrice appliquée aux sommets.]),
  ),
  ex: ```
let tetra = "v 0 0 0\nv 1.4 0 0\nv 0.7 1.2 0\nv 0.7 0.4 1.3\nf 1 3 2\nf 1 2 4\nf 2 3 4\nf 3 1 4"
fig(obj(tetra), size: 3cm, view: (15, 35))
```)
