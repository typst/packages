// Los perfiles que trae el paquete: los de pgf-go-profiles.sty. Un perfil es un diccionario de opciones,
// como las de gobanist-set; profile: "nombre" usa uno de estos.

// La mezcla de xcolor (a!p!b): p por ciento de a y el resto de b, en RGB.
#let xmix(a, p, b) = color.mix((a, p), (b, 100% - p), space: rgb)

#let pgf-gray = luma(50%)

#let wain-goban = rgb("#402A2D")
#let wain-grid = rgb("#FAE0B2")
#let wain-black = rgb("#4B4B4D")
#let wain-shade = rgb("#E6E7E8")
#let wain-white = rgb("#EFEFEF")

#let pgfgo-color = rgb(220, 179, 92)
#let pgfgo-dark = xmix(pgfgo-color, 10%, black)
#let pgfgosmooth-grid = rgb("#C7A253")

// La sombra y el brillo de las piedras de wain y pgfgo.
#let raised = (
  shadow: (on: true, opacity: 0.5, offset: 1pt, angle: -45deg),
  shine: (on: true, angle: 45deg, color: wain-shade),
)

#let wain = (
  background: (fill: (color: wain-goban, opacity: 1), line: (color: wain-grid, opacity: 1)),
  grid: (line: (color: wain-grid, width: 1pt)),
  label: (text: (fill: wain-goban)),
  players: (
    all: (
      stone: raised + (line: (on: true, color: wain-grid, width: 0.2pt, opacity: 1), radius: 0.17cm),
      move: (label: (text: (fill: black))),
      mark: (line: (color: wain-goban, width: 1pt), label: (text: (fill: wain-goban))),
    ),
    neutral: (stone: (fill: (color: xmix(wain-black, 50%, wain-white)))),
    white: (stone: (fill: (color: wain-white)), move: (label: (text: (fill: wain-goban)))),
    black: (
      stone: (fill: (color: wain-black)),
      move: (label: (text: (fill: wain-grid))),
      mark: (line: (color: wain-grid), label: (text: (fill: wain-grid))),
    ),
  ),
  arrow: (color: wain-grid),
  line: (color: wain-grid),
)

#let pgfgo = (
  background: (
    fill: (color: pgfgo-color, opacity: 1),
    line: (color: pgfgo-dark, opacity: 1),
    shadow: true,
    rounded-corners: (inner: 0pt, outer: 2pt),
  ),
  grid: (line: (color: pgfgo-dark, width: 1pt)),
  players: (
    all: (
      stone: raised + (line: (on: true, color: black, width: 0.3pt, opacity: 1), radius: 0.17cm),
      mark: (line: (color: black, width: 1pt), label: (text: (fill: black))),
    ),
    white: (stone: (fill: (color: wain-white), shine: (color: white)), move: (label: (text: (fill: black)))),
    black: (stone: (fill: (color: wain-black)), move: (label: (text: (fill: pgfgo-color))), mark: (line: (color: pgfgo-color))),
  ),
  arrow: (color: xmix(red, 80%, black)),
  line: (color: xmix(red, 80%, black)),
)

#let pgfgosmooth = (
  profile: pgfgo,
  background: (line: false, rounded-corners: (inner: 2pt, outer: 8pt)),
  grid: (line: (color: pgfgosmooth-grid)),
  players: (
    neutral: (stone: (line: false, radius: 0.19cm, shine: (opacity: 0.5))),
    black: (stone: (line: false, shine: (opacity: 0.5))),
    white: (stone: (line: false)),
  ),
)

// Sin borde y con líneas finas.
#let simple = (
  background: (line: false),
  grid: (line: (width: 0.4pt)),
  players: (all: (stone: (line: (width: 0.5pt)))),
  arrow: (width: 0.8pt),
  line: (width: 0.6pt),
)

// Las líneas paralelas del patrón Lines de TikZ, a 45 o a -45 grados: distance entre una y otra, de grosor
// width.
#let lines(angle, distance, width, color) = {
  let s = distance * calc.sqrt(2)
  tiling(size: (s, s), for k in (-1, 0, 1) {
    let (y1, y2) = if angle > 0deg { (s, 0pt) } else { (0pt, s) }
    place(line(start: (k * s, y1), end: (k * s + s, y2), stroke: (paint: color, thickness: width)))
  })
}

// En blanco y negro, rayado donde hay relleno.
#let draft = (
  background: (line: false),
  grid: (line: (width: 0.4pt)),
  arrow: (width: 0.6pt),
  line: (width: 0.4pt),
  players: (
    all: (
      stone: (line: (width: 0.4pt)),
      mark: (line: (width: 0.6pt), fill: (color: white, pattern: lines(45deg, 1.2pt, 0.3pt, black))),
    ),
    black: (
      stone: (fill: (color: white, pattern: lines(45deg, 1.5pt, 0.4pt, pgf-gray))),
      move: (label: (text: (fill: black))),
      mark: (line: (color: black), label: (text: (fill: black))),
      territory: (fill: (color: none, pattern: lines(45deg, 2pt, 0.4pt, pgf-gray))),
    ),
    white: (territory: (fill: (color: none, pattern: lines(-45deg, 2pt, 0.4pt, pgf-gray)))),
  ),
)

// Los perfiles con imágenes: las de images/, junto a src/.
#let picture(name) = path("../images/pgfgo-" + name)
#let soft-shadow = (stone: (shadow: (
  on: true, angle: -45deg, offset: 0.75pt, scale: 1.2, opacity: 0.6, image: picture("shadow.png"),
)))

// Madera, pizarra y concha. Cada piedra blanca usa una de cinco imágenes, con un pequeño giro.
#let shell = (
  background: (line: false, fill: (image: picture("board.jpg"))),
  arrow: (halo: false),
  line: (halo: false),
  players: (
    all: soft-shadow,
    black: (stone: (image: picture("shell-black.png"))),
    white: (stone: (image: (
      file: range(1, 6).map(n => picture("shell-white-" + str(n) + ".png")),
      rotate: (-15deg, 15deg),
    ))),
  ),
)

// Como shell, con piedras mates: dos imágenes para las blancas, sin giro.
#let yunzi = (
  profile: shell,
  players: (
    black: (stone: (image: picture("yunzi-black.png"))),
    white: (stone: (image: (file: (picture("yunzi-white-1.png"), picture("yunzi-white-2.png")), rotate: 0deg))),
  ),
)

// Madera lisa y piedras lisas, una imagen para cada color.
#let baduktv = (
  background: (line: false, fill: (image: picture("baduktv-goban.png"))),
  arrow: (halo: false),
  line: (halo: false),
  players: (
    all: soft-shadow,
    black: (stone: (image: picture("baduktv-black.png"))),
    white: (stone: (image: picture("baduktv-white.png"))),
  ),
)

#let profiles = (
  default: (:),
  wain: wain,
  pgfgo: pgfgo,
  pgfgosmooth: pgfgosmooth,
  simple: simple,
  draft: draft,
  shell: shell,
  yunzi: yunzi,
  baduktv: baduktv,
)
