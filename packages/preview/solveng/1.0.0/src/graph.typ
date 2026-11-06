// Plotting: lilaq on paper, our own renderer (src/plot.js) in HTML.
#import "defined.typ": *
#import "@preview/lilaq:0.6.0" as _lq

// HTML: the renderer, once per document
#let _plot-js-done = state("solveng-plot-js", false)
#let _plot-js() = context if not _plot-js-done.get() { html.elem("script", read("plot.js")); _plot-js-done.update(true) }

// The dot shapes: corners around the point, in units of the dot's size (y down), as lilaq sizes its own marks so
// they look alike in size; none for a circle. HTML draws the same corners.
#let _dot-corners(shape) = {
  let regular(n, turn: 0) = {
    let r = 0.5 * calc.sqrt(1 + 4 / (n * n))
    // the triangle sits low, its weight at its centre
    let dy = (0, .13, 0, .03, 0, .02).at(n - 2, default: 0) * r * (if turn == 180 { -1 } else { 1 })
    range(n).map(i => { let a = (i * 360 / n + turn) * 1deg; (r * calc.sin(a), -r * calc.cos(a) + dy) })
  }
  let bars(turn) = {
    let (w, l) = (0.17, 0.58)
    ((w, -l), (w, -w), (l, -w), (l, w), (w, w), (w, l), (-w, l), (-w, w), (-l, w), (-l, -w), (-w, -w), (-w, -l))
      .map(((x, y)) => { let a = turn * 1deg; (x * calc.cos(a) - y * calc.sin(a), x * calc.sin(a) + y * calc.cos(a)) })
  }
  if shape == "square" { let h = 0.425; ((-h, -h), (h, -h), (h, h), (-h, h)) }
  else if shape == "triangle" { regular(3) }
  else if shape == "triangle-down" { regular(3, turn: 180) }
  else if shape == "diamond" { regular(4) }
  else if shape == "pentagon" { regular(5) }
  else if shape == "hexagon" { regular(6) }
  else if shape == "star" { range(10).map(i => { let r = if calc.even(i) { 0.66 } else { 0.27 }; let a = i * 36deg; (r * calc.sin(a), -r * calc.cos(a)) }) }
  else if shape == "plus" { bars(0) }
  else if shape == "cross" { bars(45) }
  else { none }
}
// A dot for lilaq: the shape in the color, with a ring of the page's color around it, so dots stand apart from
// lines and from each other where they touch.
#let _dot-mark(shape, color) = m => {
  let s = m.size
  let ring = (paint: white, thickness: 1.1pt, join: "round")
  let pts = _dot-corners(shape)
  if pts == none {
    let r = s / 2
    place(move(dx: -r, dy: -r, std.circle(radius: r, fill: color, stroke: ring)))
    move(dx: -r, dy: -r, std.circle(radius: r, fill: color, stroke: none))
  } else {
    let at = pts.map(((x, y)) => (x * s, y * s))
    place(std.polygon(fill: color, stroke: ring, ..at))
    std.polygon(fill: color, stroke: none, ..at)
  }
}

// ---------- plotting ----------
/// Plots an equation: ranges, nice ticks, axis labels and units are picked automatically.
///
/// Math holds the curves, separated by a backslash: `$cos(w) \ w$`, or a function such as
/// `$P(U: #V) = U^2/R$`. A parameter annotation supplies the axis unit; `..` takes the one undefined variable.
/// With `:=`, curves also define their names for later calculations. Curves share the same x axis.
///
/// ```typ
/// #import units: Ω, W, V
/// #worksheet($R := 50 #Ω$, $P_0 := 2 #W$, hidden: true)
/// #graph($P(U: #V) = U^2/R$, ymark: $P_0$)
/// #graph($cos(w) \ w$, mark: auto)
/// #graph($y(x) = x^2 \ y(x) = 2x + 3$, xrange: (-3, 5))
/// ```
///
/// Drawn with `@preview/lilaq:0.6.0` in the schoolbook style: axes through the origin with arrows, a faint grid at the regular ticks. Ticks use the document's decimal separator, axis labels read `U / V`; curves of the same unit share one graph, with a legend in the corner the curves leave emptiest. In HTML export the graph is drawn in the browser instead, in the same style: the curves draw themselves in when the graph comes into view, and the pointer shows the values of every curve with their units. The static picture stays in the page for readers without scripts.
///
/// **Ranges:** values and expressions in `xrange` / `yrange` must have the axis unit (`$f(20) #Ω$` is fine) – `xrange: ($10 #Ω$, $f(20)$)` with a unitless `f(20)` is an error, since it isn't clear what was meant. Without a range: around the marks; else around what's interesting – roots, extrema, poles, edges of the domain (√, ln) and, above all, where curves cross – rounded to nice ticks, starting at 0 when everything interesting is positive. With `ymark`, the y range is around the marked values (steep curves leave the picture). **Units** follow from what's plotted: y's from the curves (shown in the SI unit with a fitting prefix; `preferred-units` picks others), x's from the curve's parameter (`U(I: mA) = …`) or a function x is passed to whose parameter has one (`$q(I: mA) := I R$`, then `#graph($U(I) = q(I)$)` is over I in mA), else from the units in `xrange` and the marks, else from the curve and the units of the y values (`P(..) = U_0^2/R_2` with `ymark: $2 #W$`: R₂ in Ω).
///
/// **Data:** a vector of values is plotted as the points through its elements, joined in index order (with a dot at each when there are at most 30): `#graph($y$)` against the zero-based index k (as in `at(y, k)`), `#graph($y(τ)$)` over the vector `tau` of the same length – or over any expression without free names that is one, `y(2 tau)`. Units come from the elements (each vector needs one unit for all its elements; every element must have a value). Function curves can go alongside: `#graph($y(τ) \ c(τ)$)` with a function `c`, or an expression in `tau` (`$2 tau$`), where `tau` stands for the x axis and the function is sampled over it; the x range is from the data's first to last x value unless `xrange` says otherwise, and the units of x and y must agree. Marks work on data too, with linear interpolation between the points: x values, `"roots"` and `"crossings"` (with data and with functions) where the values change sign, `"extrema"` as the local extreme points, and `ymark`. A vector with a free name is several curves instead, one per element (`$vec(t, t^2)$`). For measurements, `lines: none` draws the data as points alone, without the line: `#graph($y(τ) \ c(τ)$, lines: (none, auto))` shows measured points next to the curve `c`.
///
/// **Piecewise functions** (`cases`) break their line where a branch changes with a jump; a value that holds at a single x – `2 & "for" x = 1`, or a point set apart from the line – is drawn as a dot. `joined: true` joins the pieces through them instead. The steps of `rect`, `sgn`, `floor` and `ceil` break the line the same way, without dots for the values right on their edges; with `joined: true` each step is joined by a vertical line.
///
/// **Layers:** curves are drawn in the order written, each over the ones before and over the axes: a function written after measured points runs over them, one written before runs under them. Every dot has a thin ring of the page's color, so dots stand apart from lines and from each other; a dot right on a dot of another curve is drawn smaller, the one below showing as a ring around it.
///
/// **Marks** default to none. Requested marks are always visible – the ranges grow to show them. Combine them in an array, `(auto, $R_1$)`.
///
/// **Size:** `width` / `height` are the whole graph, labels included; `auto` makes the plot area 8 × 5 cm. Any other named argument goes straight to lilaq's `diagram` (e.g. `title: [Load]`, `grid: none`); it shapes the printed graph, not the one drawn in HTML. For full control, plot with lilaq directly.
///
/// - equation (content): Math curves separated by a backslash.
/// - ..args (any): Named options passed on to lilaq's `diagram` (e.g. `title: [Load]`).
/// - xrange (auto, array, content, int, float): x values that must be visible: numbers in the x axis's unit (`(1, 2)`), values (`($10 #Ω$, $1 kΩ$)`) or expressions of defined variables (`(0, $2 R$)`). Two or more give the range from the smallest to the largest; a single one widens the picked range. `auto`: around the marked x values, else picked from the curves.
/// - yrange (auto, array, content, int, float): y values that must be visible, like `xrange` (numbers in the y axis's SI unit). Two or more give the exact y range. `auto`: fitted to the curves.
/// - mark (none, auto, array, content, int, float): What to mark, with both coordinates written on the axes: x values like `xrange` (`$R$`, `2`, `$5 #V$`; a point with guide lines on every curve, the range grows to show it), `"crossings"`, `"roots"`, `"extrema"` (searched within the range) and `auto`: where two curves cross. An array combines them: `(auto, $R_1$)`. `()` or `none` (default): no marks.
/// - xmark (none, array, str, content, int, float): Like `mark`, but only the x value is written on the axis.
/// - ymark (none, array, content, int, float): y values to mark, like `yrange`: every point where a curve reaches one, with guide lines; the value is written on the y axis.
/// - samples (int): Number of sample points.
/// - width (auto, length, ratio, relative, fraction): Width of the whole graph, labels included: `12cm`, `300pt` or a share like `100%`. `1fr` is the container's width – in a grid, the column's. `auto`: a plot area of 8 cm.
/// - height (auto, length, ratio, relative, fraction): Like `width`; `auto`: a plot area of 5 cm. A share is of the container's height, or of the width when the page grows with its content.
/// - colors (auto, array, color): Colors of the curves, curve after curve and repeating: `(gray, blue, rgb("#f98eff"))`. `auto` keeps the worksheet's `graph-colors`, also for a single curve: `(auto, red)` changes only the second (and fourth, …). By default Petroff's ten colors, chosen to stay apart for color-blind readers (lilaq's default too). `lines`, `dots` and `joined` work the same way.
/// - lines (auto, array, str, dictionary, none): The curves' lines, like `colors`: Typst dash patterns such as `"solid"`, `"dashed"`, `"dotted"`, `"dash-dotted"`, `"densely-dashed"`, `"loosely-dotted"`, or an array of lengths like `(4pt, 2pt)`, so curves can be told apart without color (color-blind readers, grayscale prints); `none` draws no line – data as points alone (a scatter plot), a function as its single points. `auto`: the worksheet's `graph-lines`, by default `("solid", "dashed", "dotted", "dash-dotted")`, the order of scientific plotting tools.
/// - dots (auto, array, str, none): The curves' dots, like `colors`: `"circle"`, `"square"`, `"triangle"`, `"triangle-down"`, `"diamond"`, `"pentagon"`, `"hexagon"`, `"star"`, `"cross"`, `"plus"`; `none` draws no dots. `auto`: the worksheet's `graph-dots`, by default `("circle", "square", "triangle", "diamond")`, so curves can be told apart without color too. Dots are drawn for data's points (with at most 30 points, or without a line) and a function's single points (`2 & "for" x = 1` in `cases`).
/// - joined (auto, bool, array): Whether everything a curve draws is joined with a line, like `colors`: a function's pieces, from the end of one to its single point and on to the start of the next, as data's points are (with `lines: none`: data's dots joined). Joins to points beyond the graph leave it; the pointer doesn't read them. `auto`: the worksheet's `graph-joined`, by default `false`. A curve with nothing to draw is an error.
/// - digits, separator, form, … (auto): Every option of `worksheet` works here too, for this call only.
/// -> content
#let graph(
  equation, ..args, xrange: auto, yrange: auto, mark: none, xmark: (), ymark: (), samples: 400,
  width: auto, height: auto, colors: auto, lines: auto, dots: auto, joined: auto,
  digits: auto, trailing-zeros: auto, separator: auto, grouping: auto, scientific: auto, engineering: auto, multiplication: auto, form: auto,
  max-denominator: auto, fractions: auto, prefixes: auto, show-si: auto, preferred-units: auto,
  approximate: auto, block: auto, max-solutions: auto, defined-style: auto, errors: auto, show-types: auto,
  words: auto, chips: auto, unit-style: auto, unit-separator: auto,
) = _mine(context {
  let lc = _check(_given((digits: digits, trailing-zeros: trailing-zeros, separator: separator, grouping: grouping, scientific: scientific, engineering: engineering, multiplication: multiplication, form: form, max-denominator: max-denominator, fractions: fractions, prefixes: prefixes, show-si: show-si, preferred-units: preferred-units, approximate: approximate, block: block, max-solutions: max-solutions, defined-style: defined-style, errors: errors, show-types: show-types, words: words, chips: chips, unit-style: unit-style, unit-separator: unit-separator)) + _given((graph-colors: colors, graph-lines: lines, graph-dots: dots, graph-joined: joined)).pairs().map(((k, v)) => (k, _graph-style(k, v))).filter(((k, v)) => not _E(v)).to-dict())
  if _E(lc) { return _errc("graph: " + lc.err, _cf.get(), wide: true) }
  let cf = _merge(_cf.get(), lc)
  // shown, and reported as a problem of the document, as a worksheet's are
  let fail(m) = _errc("graph: " + m, cf, wide: true) + [#metadata((kind: "error", element: none, message: "graph: " + m, source: ""))<solveng>]
  // types
  if args.pos().len() > 0 { return fail("pass curves in one equation, separated by a backslash") }
  if type(equation) != content or equation.func() != math.equation { return fail("pass curves as math equations") }
  let eqs = (equation,)
  if args.pos().any(a => type(a) == array) { return fail("the x range is named: xrange: " + repr(args.pos().find(a => type(a) == array))) }
  // options graph had: what replaces them
  let gone = (x: "x is the one variable of the curves that isn't defined", xunit: "x's unit comes from a function parameter with a unit (q(I: mA)), xrange or the marks", yunit: "y's unit comes from the curves; preferred-units: (\"mW\",) picks another", builtin-units: "units are Typst bindings: #import units: …", units: "units are Typst bindings: #import units: …, or unit($…$)", dashes: "lines: the line style per curve, like (\"solid\", \"dashed\"); none draws no line", draw: "lines: none (only dots), dots: none (only lines) and joined: true (everything joined with a line), per curve")
  let old = args.named().keys().find(k => k in gone)
  if old != none { return fail(old + ": is gone – " + gone.at(old)) }
  let XV = (content, int, float)
  let list(v) = if v == auto or v == none { () } else if type(v) == array { v } else { (v,) }
  let (rng, yrng) = (list(xrange), list(yrange))
  for (n, r) in (xrange: rng, yrange: yrng) { if r.any(v => type(v) not in XV) { return fail(n + ": values to show, like (1, 2), (\"10 Ω\", \"1 kΩ\") or (0, \"2 R\")") } }
  let ymk = list(ymark)
  if ymk.any(v => type(v) not in XV) { return fail("ymark: y values like \"P0\" or 2, or an array of these") }
  // marks: x values, keywords, auto; (item, y labelled): mark writes x and y on the axes, xmark only x
  let KW = _VALUES.mark
  let ms(v) = if v == none or v == false { () } else if v == true { (auto,) } else if type(v) == array { v } else { (v,) }
  let ents = ms(mark).map(m => (m, true)) + ms(xmark).map(m => (m, false))
  if ents.any(((m, _)) => m != auto and type(m) not in XV and m not in ("crossings", "roots", "extrema")) { return fail("mark / xmark: auto, x values like \"R\" or 2, \"crossings\", \"roots\", \"extrema\", or an array of these; () for none") }
  let iskw(m) = type(m) == str and m in KW
  let kws = ents.filter(((m, _)) => iskw(m))
  let autos = ents.filter(((m, _)) => m == auto).map(e => e.at(1))
  let mxs = ents.filter(((m, _)) => m != auto and not iskw(m))
  if type(samples) != int or samples < 2 { return fail("samples: an integer ≥ 2") }
  for (n, v) in (width: width, height: height) {
    let ok = if v == auto { true } else if type(v) == length { v.to-absolute() > 0pt } else if type(v) == ratio { v > 0% } else if type(v) == relative { v.ratio >= 0% and v.length.to-absolute() >= -1e9pt } else if type(v) == fraction { v > 0fr } else { false }
    if not ok { return fail(n + ": auto, a length like 8cm or 300pt, or a share like 100% or 1fr, got " + repr(v) + if type(v) in (int, float) { " – write " + repr(v) + "cm" } else { "" }) }
  }
  // the curves' styles: the graph's own over the worksheet's (graph-colors, graph-lines, graph-dots, graph-joined),
  // auto keeping the worksheet's
  for (k, v) in (colors: colors, lines: lines, dots: dots, joined: joined) {
    if v != auto { let c = _graph-style(k, v); if _E(c) { return fail(c.err) } }
  }

  // Serialize math with its explicit unit and operation substitutions.
  let src(q) = if type(q) == content and q.func() == math.equation { let m = _src(q.body); (src: if _E(m) { "?" } else { m }, label: _src(q.body)) } else { panic("solveng: graph: values must be numbers or math equations") }
  let v(a) = if type(a) in (int, float) { float(a) } else { src(a) }
  let mk(m) = if m == auto { "auto" } else if type(m) == str and m in KW { m } else { v(m) }
  let req = (
    cfg: _req-cfg(cf), curves: eqs.map(src).map(q => {
      let labels = if q.label == none or _E(q.label) { () } else { _call(_p.statements, q.label) }
      _call(_p.statements, q.src).enumerate().map(((i, s)) => (src: s, label: labels.at(i, default: none)))
    }).flatten(), xrange: rng.map(v), yrange: yrng.map(v),
    marks: ms(mark).map(m => (mk(m), true)) + ms(xmark).map(m => (mk(m), false)), ymark: ymk.map(v), samples: samples,
  )
  // drawn with the definitions made before; the curves written with := define what they name afterwards, as the
  // same equation in a worksheet does – a pure update of the state, so graphs building on each other settle
  let draw = context {
    let g = _call(_p.graph, _env(_st.get()), req)
    if "err" in g { return fail(g.err) }
    let M(s) = _m(s, cf)
    // a color, a dash and a dot shape per curve: curves stay apart without color too
    let style(i) = { let at(a) = a.at(calc.rem(i, a.len())); (color: at(cf.graph-colors), dash: at(cf.graph-lines), shape: at(cf.graph-dots), joined: at(cf.graph-joined)) }
    // the legend goes to the corner the curves leave emptiest
    let (gw, gh) = (g.x1 - g.x0, g.y1 - g.y0)
    let uv = (g.series.map(s => s.points).join() + g.points.map(p => (p.x, p.y))).map(((x, y)) => ((x - g.x0) / gw, (y - g.y0) / gh))
    let corners = ((top + left, (u, v) => u < 0.45 and v > 0.6), (top + right, (u, v) => u > 0.55 and v > 0.6), (bottom + right, (u, v) => u > 0.55 and v < 0.4), (bottom + left, (u, v) => u < 0.45 and v < 0.4))
    let (corner, crowd) = corners.map(((a, inside)) => (a, uv.filter(((u, v)) => inside(u, v)).len())).sorted(key: c => c.at(1)).first()
    // no corner is free: beside the plot, at the top
    let outside = crowd > 0.02 * uv.len()
    let legend = if outside { (position: top + left, dx: 100% + 1.2em) } else { (position: corner) }
    // joined: everything a curve draws joined with a line, as data's points are: a function's pieces, from the end of
    // one (a run of samples, or a single point) to the start of the next, in x order – also towards the nearest ones
    // beyond the graph (beyond: true), the join leaving the graph. Joins are drawn, not read by the pointer.
    let joins(c) = style(c).joined
    let series = ()
    for (k, s) in g.series.enumerate() {
      series.push(s)
      let c = s.curve
      if not joins(c) or s.at("data", default: false) or g.series.slice(k + 1).any(t => t.curve == c) { continue }
      let pieces = g.series.filter(t => t.curve == c and t.points.len() > 0).sorted(key: t => t.points.first().at(0))
      for (a, b) in pieces.zip(pieces.slice(1)) {
        series.push((points: (a.points.last(), b.points.first()), curve: c, label: none, data: false, dots: false, bridge: true))
      }
    }
    // what each series draws, in the order written – lines: a function's pieces and data's joined points, and the joins;
    // dots: data's points (where it has few, or no line) and a function's single points. A later curve covers the
    // earlier ones, as written. A dot right on a dot of another curve is drawn smaller, the one below a ring around it.
    let cell(x, y) = str(calc.round((x - g.x0) / gw * 250)) + "," + str(calc.round((y - g.y0) / gh * 250))
    let taken = (:)
    let layers = ()
    for s in series {
      let st = style(s.curve)
      let (data, bridge, beyond) = (s.at("data", default: false), s.at("bridge", default: false), s.at("beyond", default: false))
      // lines: a function's pieces, data's points joined (with lines: none only where joined), the joins; dots: a
      // function's single points, data's points where it has few or no line
      let line = s.points.len() > 1 and (bridge or st.dash != none or (data and st.joined))
      let dotted = st.shape != none and not bridge and not beyond and (if data { st.dash == none or s.at("dots", default: false) } else { s.points.len() == 1 })
      let dots = ()
      if dotted {
        for (x, y) in s.points {
          let k = cell(x, y)
          let under = taken.at(k, default: ())
          dots.push((x, y, under.filter(c => c != s.curve).len()))
          taken.insert(k, under + (s.curve,))
        }
      }
      // dots on their own line are smaller than dots standing alone
      layers.push((line: line, dots: dots, size: if line { 4pt } else { 5pt }))
    }
    // a curve's name, from the piece of it that has it (one of its runs)
    let name-of(i) = { let s = series.find(s => s.curve == i and s.label != none); if s == none { none } else { s.label } }
    // every curve draws something; its legend shows what: its line, its dots, or both
    let shows(i) = series.enumerate().filter(((k, s)) => s.curve == i).map(((k, s)) => layers.at(k))
    let legend-of(i) = { let l = shows(i); if l.any(l => l.line) { if l.any(l => l.dots.len() > 0) { "both" } else { "line" } } else { "dot" } }
    for i in range(calc.max(0, ..series.map(s => s.curve + 1))) {
      let l = shows(i)
      if l.len() > 0 and l.all(l => not l.line and l.dots.len() == 0) {
        let written = req.curves.at(i, default: (:)).at("label", default: none)
        return fail((if name-of(i) != none { name-of(i) } else if written != none { written } else { "curve " + str(i + 1) }) + " draws nothing: " + (if style(i).shape == none { "lines: none and dots: none" } else { "lines: none leaves its dots, and a function has dots only where a branch of cases holds at a single x" }))
      }
    }
    let plots = ()
    let named = ()
    for (k, s) in series.enumerate() {
      let st = style(s.curve)
      let lay = layers.at(k)
      // the legend names each curve once, on what it draws first
      let label = if name-of(s.curve) != none and s.curve not in named and (lay.line or lay.dots.len() > 0) { named.push(s.curve); $#M(name-of(s.curve))$ }
      // above the axes, each series over the ones before it, its dots over its line; below the legend (25)
      let z = 21 + k * 0.002
      if lay.line {
        // round caps: the dots of a dotted pattern are zero-length dashes. In the legend the line has its dot
        // where its data has dots (every: (): none on the curve itself)
        plots.push(_lq.plot(s.points.map(p => p.at(0)), s.points.map(p => p.at(1)), color: st.color, label: label, z-index: z,
          // joins (joined: true) are faint: where the curve has values stays clear
          stroke: (paint: if s.at("bridge", default: false) { st.color.transparentize(60%) } else { st.color }, thickness: 1.2pt, dash: if st.dash in ("solid", none) { none } else { st.dash }, cap: "round", join: "round"),
          mark: if legend-of(s.curve) == "both" { _dot-mark(st.shape, st.color) } else { none }, mark-size: lay.size, every: ()))
        label = none
      }
      // in the legend its dot at full size, whether or not one of its dots is on top of another
      if label != none and lay.dots.len() > 0 {
        plots.push(_lq.plot((lay.dots.first().at(0),), (lay.dots.first().at(1),), color: st.color, stroke: none, label: label,
          mark: _dot-mark(st.shape, st.color), mark-size: lay.size, every: ()))
        label = none
      }
      for level in lay.dots.map(d => d.at(2)).dedup() {
        let ds = lay.dots.filter(d => d.at(2) == level)
        // unclipped: a dot on the edge of the plot is whole
        plots.push(_lq.plot(ds.map(d => d.at(0)), ds.map(d => d.at(1)), color: st.color, stroke: none, label: label, z-index: z + 0.001,
          mark: _dot-mark(st.shape, st.color), mark-size: lay.size * calc.pow(0.6, level), clip: false))
        label = none
      }
    }
    let guide = (paint: luma(110), thickness: 0.6pt, dash: "dashed")
    for p in g.points {
      if p.guides != "" { plots.push(_lq.plot((p.x, p.x), (g.ax, p.y), stroke: guide, mark: none)) }
      if p.guides == "xy" { plots.push(_lq.plot((g.ay, p.x), (p.y, p.y), stroke: guide, mark: none)) }
      plots.push(_lq.plot((p.x,), (p.y,), color: black, stroke: none, mark: _dot-mark("circle", black), mark-size: 4pt, clip: false, z-index: 24))
    }
    // the origin's 0, unless an axis writes it already
    let origin = g.x-axis-zero and g.y-axis-zero and 0 not in g.xticks and 0 not in g.yticks
    if origin { plots.push(_lq.place(0, 0, align: top + right, box(inset: (right: 0.35em, top: 0.3em), $0$))) }
    // regular ticks get a grid line, marked values are only written on the axis. The grid stays open at the
    // edges, no line closes the plot area on any side. The x axis writes its last value at the arrow's end too,
    // without a grid line; the y axis's end has its label instead.
    let axis(kind, ticks, labels, marked, position, lim) = {
      let at(v, e) = calc.abs(v - e) <= 1e-9 * (lim.at(1) - lim.at(0))
      let all = ticks.zip(labels, marked).filter(t => kind == "x" or not at(t.at(0), lim.at(1))).map(((v, l, m)) => (v, l, m or at(v, lim.at(0)) or at(v, lim.at(1))))
      let regular = all.filter(t => not t.at(2))
      (position: position, mirror: false, subticks: none,
        ticks: regular.map(t => (t.at(0), $#M(t.at(1))$)),
        extra-ticks: all.filter(t => t.at(2)).map(((v, l, _)) => _lq.tick(v, label: $#M(l)$, kind: kind)))
    }
    let xm = g.at("xmarked", default: g.xticks.map(_ => false))
    let ym = g.at("ymarked", default: g.yticks.map(_ => false))
    // the x axis's label beside the arrow's end, clear of the value written there; the graph makes room for it on
    // the right, where lilaq places it outside the diagram
    let end = g.xticks.position(v => calc.abs(v - g.x1) <= 1e-9 * (g.x1 - g.x0))
    let xlabel = { if end != none { std.h(measure($#M(g.xlabels.at(end))$).width / 2 + 0.25em) }; $#M(g.xlabel)$ }
    let make(w, h) = {
      // schoolbook: axes through the origin with arrows, a faint grid at the regular ticks only
      show: _lq.theme.schoolbook
      show: _lq.set-grid(stroke: luma(225) + 0.5pt, stroke-sub: none)
      show: pad.with(right: measure(xlabel).width)
      _lq.diagram(width: w, height: h, xlim: (g.x0, g.x1), ylim: (g.y0, g.y1), legend: legend,
        xlabel: xlabel, ylabel: $#M(g.ylabel)$,
        xaxis: axis("x", g.xticks, g.xlabels, xm, if g.x-axis-zero { 0 } else { bottom }, (g.x0, g.x1)),
        yaxis: axis("y", g.yticks, g.ylabels, ym, if g.y-axis-zero { 0 } else { left }, (g.y0, g.y1)),
        ..args.named(), ..plots)
    }
    // auto: a plot area of 8 × 5 cm; lengths and shares (100%, 50pt) are the whole graph, labels included
    let sized = std.layout(size => {
      let (aw, ah) = (width == auto, height == auto)
      let abs(v, full) = if type(v) == ratio { v * full } else if type(v) == relative { v.ratio * full + v.length.to-absolute() } else if type(v) == fraction { v / 1fr * full } else { v.to-absolute() }
      if aw and ah { return make(8cm, 5cm) }
      // HTML has no width to take a share of: a nominal 16cm, the SVG scales with the page anyway
      let full-w = if calc.abs(size.width.pt()) < 1e6 { size.width } else { 16cm }
      let W = if aw { 8cm } else { abs(width, full-w) }
      // a share of the height: of the container, or of the width when the page grows with its content
      let full-h = if calc.abs(size.height.pt()) < 1e6 { size.height } else { W }
      let H = if ah { 5cm } else { abs(height, full-h) }
      let m = measure(make(W, H))
      let w1 = if aw { W } else { calc.max(W - (m.width - W), 1cm) }
      let h1 = if ah { H } else { calc.max(H - (m.height - H), 1cm) }
      make(w1, h1)
    })
    if _target() != "html" { return align(center, sized) }
    // HTML: drawn in the browser, animated and with the values under the pointer; the static picture stays for
    // readers without scripts. Labels are the document's math, placed over the drawing.
    let hex(c) = (if type(c) == gradient { c.sample(50%) } else { c }).to-hex()
    let svg-dash(d) = if d == none or d == "solid" { "" } else if type(d) == str {
      (dotted: "0 3.5", densely-dotted: "0 2.5", loosely-dotted: "0 6", dashed: "6 4", densely-dashed: "6 2.5", loosely-dashed: "6 7",
        dash-dotted: "6 3 0 3", densely-dash-dotted: "6 2 0 2", loosely-dash-dotted: "6 5 0 5").at(d)
    } else { (if type(d) == dictionary { d.array } else { d }).map(l => if l == "dot" { "0" } else { str(calc.round(l.to-absolute().pt() * 4 / 3, digits: 2)) }).join(" ") }
    let ncurves = calc.max(0, ..series.map(s => s.curve + 1))
    let rc = _req-cfg(cf)
    let spec = (
      x0: g.x0, x1: g.x1, y0: g.y0, y1: g.y1, ax: g.ax, ay: g.ay, xz: g.x-axis-zero, yz: g.y-axis-zero, origin: origin,
      xt: g.xticks.zip(xm), yt: g.yticks.zip(ym),
      // what each series draws, as on paper: its line, and its dots (x, y, how many dots of other curves lie below)
      series: series.enumerate().map(((k, s)) => (p: s.points, c: s.curve, data: s.at("data", default: false), bridge: s.at("bridge", default: false), beyond: s.at("beyond", default: false), line: layers.at(k).line, d: layers.at(k).dots, size: layers.at(k).size.pt())),
      curves: range(ncurves).map(i => { let st = style(i); (color: hex(st.color), dash: svg-dash(st.dash), corners: _dot-corners(st.shape), legend: legend-of(i), named: i in named) }),
      points: g.points, legend: if outside { "outside" } else { (if corner.y == top { "top-" } else { "bottom-" }) + (if corner.x == left { "left" } else { "right" }) }, sep: rc.separator, digits: rc.digits, em: text.size.to-absolute().pt(), size: { let m = measure(sized); (w: m.width.pt(), h: m.height.pt()) },
    )
    let lab(k, body) = html.elem("span", attrs: ("data-k": k), body)
    let labels = (
      lab("x", $#M(g.xlabel)$), lab("y", $#M(g.ylabel)$),
      ..("xu", "yu", "xn", "yn").map(k => { let v = g.at((xu: "xunit", yu: "yunit", xn: "xname", yn: "yname").at(k), default: ""); lab(k, if v != "" { $#M(v)$ }) }),
      ..g.xlabels.enumerate().map(((i, l)) => lab("xt" + str(i), $#M(l)$)),
      ..g.ylabels.enumerate().map(((i, l)) => lab("yt" + str(i), $#M(l)$)),
      ..series.filter(s => s.label != none).map(s => lab("c" + str(s.curve), $#M(s.label)$)),
    )
    _css(); _plot-js()
    html.elem("div", attrs: (class: "solveng-plot"), {
      html.elem("div", attrs: (class: "solveng-plot-static"), html.frame(sized))
      html.elem("div", attrs: (class: "solveng-plot-labels", hidden: "hidden"), labels.join())
      html.elem("script", attrs: (type: "application/json", class: "solveng-plot-spec"), json.encode(spec, pretty: false))
    })
  }
  draw + _st.update(s => { let r = _call(_p.graph_define, _env(s), req); s + (env: r.env, last: (errors: r.errors)) })
  context _st.get().last.errors.map(fail).join()
})
