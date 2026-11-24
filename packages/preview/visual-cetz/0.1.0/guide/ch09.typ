#import "tpl.typ": *

#pagebreak(weak: true)

= Aide-mémoire

#set text(size: 7.4pt)
#show raw: set text(size: 6.1pt)

#grid(columns: (1fr, 1fr), column-gutter: 10pt, row-gutter: 8pt,
[
  === Squelette
  ```typ
  #import "@preview/cetz:0.5.2"
  #cetz.canvas(length: 1cm, {
    import cetz.draw: *
    ...
  })
  ```

  === Coordonnées
  ```typc
  (1, 2)  (1, 2, 3)  (x: 1, y: 2)
  (30deg, 2)  (angle: 30deg, radius: 2)
  "elem"  "elem.north"
  (rel: (1, 0))  (rel: (1,0), to: "a")
  (a, 50%, b)  (a, 1.5, 30deg, b)
  (a, "-|", b)  (a, "|-", b)
  (p, "_|_", a, b)
  (bary: (a: 1, b: 2))
  (element: "c", point: p, solution: 1)
  ()   // point précédent
  ```

  === Formes
  ```typc
  line(a, b, .., close: false)
  rect(a, b, radius: 0)
  circle(c, radius: 1)
  circle-through(a, b, c)
  arc(p, start: , stop: , delta: , mode: )
  arc-through(a, b, c)
  polygon(o, n, angle: 0deg)
  n-star(o, n, inner-radius: 50%)
  grid(from, to, step: 1)
  content(p, [..], angle: , anchor: )
  bezier(s, e, c1, [c2])
  bezier-through(s, m, e)
  catmull(..pts, tension: .5)
  hobby(..pts, omega: (0,0))
  merge-path({ .. }, close: false)
  compound-path({ .. }, fill-rule: )
  svg-path(("m", (0,0)), ("l", (1,1)))
  rect-around("a", "b", padding: 0)
  mark(from, to, symbol: ">")
  ```

  === Booléens
  ```typc
  boolean(a, b, op: "union")
  //  "union" "intersection"
  //  "difference" "xor"
  ```
],
[
  === Style
  ```typc
  set-style(fill: , stroke: , radius: )
  set-style(circle: (fill: red))
  fill(red)   stroke(2pt + blue)
  // clés : fill fill-rule stroke radius
  //        padding mark shorten
  ```

  === Marques
  ```typc
  mark: (end: ">")
  mark: (start: ">", end: ">")
  mark: (symbol: ">")           // 2 bouts
  mark: (end: (">", ">"))
  mark: (end: ">", pos: 50%, scale: 2,
         fill: red, harpoon: true,
         flip: true, slant: 50%,
         anchor: "tip")
  // > < <> [] ] [ | o + x * )> >> )
  ```

  === Ancres
  ```typc
  "e.north" "e.center" "e.45deg"
  "e.start" "e.mid" "e.end" "e.25%"
  anchor("nom", (x, y))
  copy-anchors("elem")
  for-each-anchor("e", n => { .. })
  ```

  === Groupes & calques
  ```typc
  group(name: "g", { .. })
  scope({ .. })
  hide(..)   floating(..)
  on-layer(1, { .. })
  intersections("i", { .. })
  get-ctx(ctx => { .. })
  ```

  === Transformations
  ```typc
  translate((1, 2))  translate(x: 1)
  rotate(30deg, origin: (0,0))
  scale(2)  scale(x: 2, y: .5)
  set-origin((1,1))   move-to((2,0))
  set-viewport(a, b, bounds: (10,10))
  transform(mat)  set-transform(mat)
  ```

  === 3D
  ```typc
  ortho({ on-xy({ .. }) })
  perspective(distance: auto, { .. })
  on-xy(z: 0, ..) on-xz(y: 0, ..)
  on-zy(x: 0, ..)
  ```

  === Bibliothèques
  ```typc
  cetz.tree.tree((root, c1, c2))
  cetz.angle.angle(o, a, b, label: )
  cetz.angle.right-angle(o, a, b)
  cetz.decorations.zigzag / coil /
    wave / square / brace / flat-brace
  cetz.palette.new(colors: (..))
  ```

  === Vecteurs / matrices
  ```typc
  vector.add/sub/scale/div/neg
  vector.len/dist/norm/lerp
  vector.dot/cross/angle/angle2
  matrix.ident(4)  matrix.mul-mat(a,b)
  matrix.transform-translate/scale
  matrix.transform-rotate-x/y/z/xyz
  matrix.inverse(m)
  ```

])

#v(4pt)
#grid(columns: (1fr, 1fr), column-gutter: 10pt,
[
  === Extension
  ```typc
  register-mark("n", style => {
    anchor("tip", (0,0))
    anchor("base", (style.length, 0))
    ..
  }, mnemonic: "N")
  register-coordinate-resolver(
    (ctx, c) => c)
  ```

],[
  === Géométrie (CeTZ pur)
  ```typc
  // nommer d'abord : circle(p, name: "A")
  circle-through("A","B","C", name: "cc")
  "cc.center"        // circonscrit
  (bary: (A: 1, B: 1, C: 1))   // gravité
  (bary: (A: a, B: b, C: c))   // inscrit
  ("A", 50%, "B")              // milieu
  ("A", -60%, "B")   // extrapole avant A
  ("A", 160%, "B")   // … et après B
  ("A", 100%, -60deg, "B")     // + rotation
  ("P", "_|_", "A", "B")       // projeté
  ("A", "-|", "B")  ("A", "|-", "B")
  (element: "c", point: "P", solution: 1)
  intersections(name: "x", "H", { .. })
  "c.45deg"          // point du cercle
  get-ctx(ctx => {   // mesurer
    cetz.coordinate.resolve(ctx, "A", "B") })
  ```

  === Écosystème
  ```typc
  // @preview/cetz-plot:0.1.4
  plot.plot(size: (6,4), { plot.add(..) })
  plot.add(domain: (a,b), x => y)
  plot.add-hline/-vline/-fill-between
  plot.add-errorbar(pt, y-error: .3)
  plot.formats.sci / fraction /
    multiple-of / decimal
  chart.columnchart / barchart
  chart.piechart / radarchart
  chart.boxwhisker
  smartart.process.basic / chevron
  smartart.cycle.basic
  // @preview/cetz-venn:0.2.0
  venn.venn2(a-fill: red)   venn.venn3(..)
  ```
])
