// The things a graph is made of. Each function only records what to draw;
// `graph` decides where it goes.
//
// Shared conventions (the same name always means the same thing):
//   a point      is (x, y)
//   a range      is (from, to)            - x:, y:, domain:
//   stroke:      any Typst stroke (red, 2pt, 2pt + red, (dash: "dashed"));
//                auto = the next palette color for curves and points, ink for helpers
//   label:       the element's entry in the legend
//   a trailing   content argument is written on the graph next to the element,
//                on the side given by pos: (top, bottom + left, ...; auto picks one)

#let _number(v) = type(v) in (int, float)
#let _point(p) = type(p) == array and p.len() in (2, 3) and _number(p.at(0)) and _number(p.at(1))

#let _check-point(who, p) = assert(_point(p),
  message: "quadrille: " + who + ": a point is written (x, y), got " + repr(p))

#let _check-range(who, name, r) = assert(r == auto or (type(r) == array and r.len() == 2
  and _number(r.at(0)) and _number(r.at(1)) and r.at(0) < r.at(1)),
  message: "quadrille: " + who + ": " + name + " is written (from, to) with from < to, got " + repr(r))

#let _check-fn(who, f) = assert(type(f) == function,
  message: "quadrille: " + who + " needs a function such as `x => x * x`, got " + repr(type(f))
    + if type(f) == content { " - write it as `x => ...`, not as an equation" } else { "" })

// The optional content written next to an element.
#let _body(who, extra) = {
  let pos = extra.pos()
  assert(extra.named().len() == 0,
    message: "quadrille: " + who + ": unknown option " + repr(extra.named().keys().at(0, default: "")))
  assert(pos.len() <= 1, message: "quadrille: " + who + ": too many arguments")
  let b = pos.at(0, default: none)
  assert(b == none or type(b) in (content, str, int, float),
    message: "quadrille: " + who + ": expected text or math to write next to it, got " + repr(b))
  b
}

/// The graph of y = f(x).
///
/// - f: a function of x. Return `none` where it is undefined (`x => if x != 0 { 1 / x }`).
/// - domain: the x range to draw, (from, to); auto = the whole graph.
/// - step: distance between sampled x values; auto = `samples` evenly spaced values.
#let fn(f, ..body, domain: auto, step: auto, samples: 400, stroke: auto, label: none, pos: auto) = {
  _check-fn("fn", f)
  _check-range("fn", "domain", domain)
  (kind: "fn", f: f, body: _body("fn", body), domain: domain, step: step, samples: samples,
   stroke: stroke, label: label, pos: pos)
}

/// A curve given as t => (x, y), for t in domain (default one full turn, 0 to 2 pi).
#let parametric(f, ..body, domain: (0, 2 * calc.pi), step: auto, samples: 400, stroke: auto,
                label: none, pos: auto) = {
  _check-fn("parametric", f)
  _check-range("parametric", "domain", domain)
  (kind: "parametric", f: f, body: _body("parametric", body), domain: domain, step: step,
   samples: samples, stroke: stroke, label: label, pos: pos)
}

/// Points, given one by one or as one array: points((0, 0), (1, 2)) or points(data).
/// A third value names the point: points((1, 2, $A$)).
/// Or marks on a function: points(f, step: 0.5) puts one at every step of x.
///
/// - mark: "dot", "circle" (open), "square", "diamond", "triangle", "cross", "plus" or none.
/// - connect: draw lines from each point to the next. close: also join the last to the first.
/// - fill: fills the shape when close is true.
#let points(..args, mark: "dot", size: auto, connect: false, close: false, fill: none,
            stroke: auto, label: none, domain: auto, step: auto, pos: auto) = {
  assert(args.named().len() == 0,
    message: "quadrille: points: unknown option " + repr(args.named().keys().at(0, default: "")))
  let given = args.pos()
  let body = if given.len() > 0 and type(given.last()) in (content, str) { given.pop() }
  let f = none
  if given.len() == 1 and type(given.first()) == function {
    f = given.first()
    given = ()
  } else if (given.len() == 1 and type(given.first()) == array and given.first().len() > 0
      and type(given.first().first()) == array) {
    given = given.first()        // points(data) with data = ((x, y), ...)
  }
  for p in given { _check-point("points", p) }
  assert(f != none or given.len() > 0, message: "quadrille: points: no points given")
  _check-range("points", "domain", domain)
  assert(mark in (none, "dot", "circle", "square", "diamond", "triangle", "cross", "plus"),
    message: "quadrille: points: unknown mark " + repr(mark)
      + " (use \"dot\", \"circle\", \"square\", \"diamond\", \"triangle\", \"cross\", \"plus\" or none)")
  (kind: "points", pts: given, f: f, body: body, mark: mark, size: size, connect: connect or close,
   close: close, fill: fill, stroke: stroke, label: label, domain: domain, step: step, pos: pos)
}

/// The segment from a to b. With extend: true, the whole line through a and b.
#let segment(a, b, ..body, extend: false, stroke: auto, label: none, pos: auto) = {
  _check-point("segment", a)
  _check-point("segment", b)
  assert(a.slice(0, 2) != b.slice(0, 2), message: "quadrille: segment: the two points are the same")
  (kind: "segment", a: a, b: b, body: _body("segment", body), extend: extend, stroke: stroke,
   label: label, pos: pos)
}

/// An arrow: vector(to) starts at the origin, vector(from, to) anywhere.
/// (Not called `arrow`, which would hide math's $arrow(F)$.)
#let vector(..args, stroke: auto, label: none, pos: auto) = {
  assert(args.named().len() == 0,
    message: "quadrille: vector: unknown option " + repr(args.named().keys().at(0, default: "")))
  let given = args.pos()
  let body = if given.len() > 0 and type(given.last()) in (content, str) { given.pop() }
  assert(given.len() in (1, 2), message: "quadrille: vector: write vector(to) or vector(from, to)")
  let (a, b) = if given.len() == 1 { ((0, 0), given.first()) } else { given }
  _check-point("vector", a)
  _check-point("vector", b)
  (kind: "vector", a: a, b: b, body: body, stroke: stroke, label: label, pos: pos)
}

/// The horizontal line y = value, across the whole graph (e.g. an asymptote).
#let hline(y, ..body, stroke: auto, label: none, pos: auto) = {
  assert(_number(y), message: "quadrille: hline: expected a number, got " + repr(y))
  (kind: "hline", v: y, body: _body("hline", body), stroke: stroke, label: label, pos: pos)
}

/// The vertical line x = value, across the whole graph.
#let vline(x, ..body, stroke: auto, label: none, pos: auto) = {
  assert(_number(x), message: "quadrille: vline: expected a number, got " + repr(x))
  (kind: "vline", v: x, body: _body("vline", body), stroke: stroke, label: label, pos: pos)
}

/// The region between f and g (default: the x axis) over domain.
/// f and g are functions of x or constants: area(v, domain: (0, 4)) under a v-t graph.
/// fill: auto = the color of the curve drawn just before it, see-through.
#let area(f, ..args, domain: auto, fill: auto, stroke: none, label: none, pos: auto) = {
  assert(args.named().len() == 0,
    message: "quadrille: area: unknown option " + repr(args.named().keys().at(0, default: "")))
  let given = args.pos()
  let body = if given.len() > 0 and type(given.last()) in (content, str) { given.pop() }
  assert(given.len() <= 1, message: "quadrille: area: write area(f), area(f, g) or area(f, g, [text])")
  let g = given.at(0, default: 0)
  for h in (f, g) {
    if type(h) != function {
      assert(_number(h), message: "quadrille: area: expected a function or a number, got " + repr(h)
        + if type(h) == content { " - write it as `x => ...`, not as an equation" } else { "" })
    }
  }
  _check-range("area", "domain", domain)
  (kind: "area", f: f, g: g, body: body, domain: domain, fill: fill, stroke: stroke, label: label, pos: pos)
}

/// Text or math at a point of the graph. pos: which side of the point it goes.
/// (Not called `note`, which would hide the music-note symbols.)
#let annotate(p, body, pos: center) = {
  _check-point("annotate", p)
  (kind: "annotate", p: p, body: body, pos: pos, label: none)
}
