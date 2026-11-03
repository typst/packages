// PreFigure element constructors for xmlit — author a diagram in native Typst
// syntax instead of writing raw XML. This file is a module: `prefigure` re-
// exports it as `tags`, so every PreFigure element is `tags.<name>(…)`.
//
//   #import "@preview/prefigure:0.1.0": prefigure, tags
//
//   #let d = tags.diagram(dimensions: "(300,300)",
//     tags.coordinates(bbox: "[-4,4,-4,4]",
//       tags.grid-axes(xlabel: "x", ylabel: "y"),
//       tags.graph(function: "f(x)=x*x"),
//       tags.label(p: "(1,1)")[the curve $y = x^2$]))
//   #prefigure(d)                       // pass the tree straight to prefigure()
//
// Each function is an xmlit tag (see xmlit's `make-tag`): named arguments become
// XML attributes, positional arguments and `[bodies]` become children, and a
// `$…$` in a body becomes an `<m>`/`<md>` equation node that `prefigure` renders
// with Typst. PreFigure's italic tag is `<it>` and its bold is `<b>`, so xmlit's
// default emphasis mapping (`_…_` → `<em>`) is remapped here to `<it>`; `*…*`
// already maps to `<b>`.
//
// The set below is every element the PreFigure engine recognises: the RELAX NG
// schema's elements (prefig/resources/schema/pf_schema.rnc) plus the few the
// Rust core also dispatches but the schema omits (`center`, `set-eye`, the 3d
// transforms, and the smooth-bézier path commands).

#import "@preview/xmlit:0.1.3": make-tag

// PreFigure uses <it> for italics (xmlit defaults to <em>). *strong* is already <b>.
#let prefigure-handlers = (
  "emph": (c, convert, ctx) => (
    (tag: "it", attrs: (:), children: convert(c.body)),
  ),
)

// Normalize a Typst-native attribute value into the string form PreFigure's XML
// attributes expect, so a diagram authored with the `tags.*` constructors can
// pass native Typst values instead of pre-stringified attributes:
//
//   * bool   true / false  -> "yes" / "no". This is PreFigure's boolean
//            convention on the engine side (`get_or(attr, "no") == "yes"`) and
//            the only spelling its RELAX NG enums (`{"yes"|"no"}`) accept, so a
//            raw `true` would both read as false and fail `validate:`.
//   * array  (a, b, …)      -> "[a,b,…]". Numeric list/tuple attributes such as
//            `dimensions`, `bbox`, and `margins` are parsed by the engine's
//            expression evaluator, which treats `[…]` and `(…)` identically
//            (both become an array), and the schema types them as free `{text}`.
//            Square brackets are emitted uniformly — PreFigure's convention for
//            bbox/margins/points. Applied recursively, so nested coordinate
//            lists like `((0,0),(1,1))` round-trip to `[[0,0],[1,1]]`.
//   * int / float           -> stringified (matches what xmlit would do, and is
//            what makes the recursive array join well-typed).
//   * str and everything else pass through unchanged, so an already-stringified
//            `"(260,260)"` or `"yes"` keeps working.
//
// Only the `tags.*` constructors route through here; raw-XML input (`read(…)`)
// is untouched, since it already carries strings.
#let _normalize-attr(v) = {
  if type(v) == bool {
    if v { "yes" } else { "no" }
  } else if type(v) == array {
    if v.len() == 0 { "[]" } else { "[" + v.map(_normalize-attr).join(",") + "]" }
  } else if type(v) == int or type(v) == float {
    // Typst formats a negative number with U+2212 MINUS SIGN, not ASCII "-",
    // which PreFigure's expression parser would reject; normalize it back.
    str(v).replace("\u{2212}", "-")
  } else {
    v
  }
}

// One PreFigure tag per binding. `_t` keeps the tag name in one place per line.
// The base xmlit tag is wrapped so each named argument (an XML attribute) is run
// through `_normalize-attr` before serialization; positional arguments (the
// children/body) are forwarded untouched.
#let _t(name) = {
  let base = make-tag(name, handlers: prefigure-handlers)
  (..args) => {
    let named = (:)
    for (k, v) in args.named() {
      named.insert(k, _normalize-attr(v))
    }
    base(..args.pos(), ..named)
  }
}

// Root & coordinate systems
#let diagram = _t("diagram")
#let coordinates = _t("coordinates")
#let grid = _t("grid")
#let grid-axes = _t("grid-axes")
#let axes = _t("axes")
#let xlabel = _t("xlabel")
#let ylabel = _t("ylabel")
#let tick-mark = _t("tick-mark")

// Functions & curves
#let graph = _t("graph")
#let parametric-curve = _t("parametric-curve")
#let implicit-curve = _t("implicit-curve")
#let contour = _t("contour")
#let spline = _t("spline")
#let tangent-line = _t("tangent-line")
#let derivative = _t("derivative")
#let area-under-curve = _t("area-under-curve")
#let area-between-curves = _t("area-between-curves")
#let riemann-sum = _t("riemann-sum")

// Shapes & primitives
#let point = _t("point")
#let line = _t("line")
#let vector = _t("vector")
#let circle = _t("circle")
#let ellipse = _t("ellipse")
#let arc = _t("arc")
#let angle-marker = _t("angle-marker")
#let rectangle = _t("rectangle")
#let triangle = _t("triangle")
#let polygon = _t("polygon")

// Paths (and their step children)
#let path = _t("path")
#let moveto = _t("moveto")
#let rmoveto = _t("rmoveto")
#let lineto = _t("lineto")
#let rlineto = _t("rlineto")
#let horizontal = _t("horizontal")
#let vertical = _t("vertical")
#let cubic-bezier = _t("cubic-bezier")
#let quadratic-bezier = _t("quadratic-bezier")
#let smooth-cubic = _t("smooth-cubic")
#let smooth-quadratic = _t("smooth-quadratic")

// Differential equations, fields & data
#let slope-field = _t("slope-field")
#let vector-field = _t("vector-field")
#let de-solve = _t("de-solve")
#let plot-de-solution = _t("plot-de-solution")
#let histogram = _t("histogram")
#let scatter = _t("scatter")

// Networks
#let network = _t("network")
#let node = _t("node")
#let edge = _t("edge")

// Labels & text
#let label = _t("label")
#let caption = _t("caption")
#let legend = _t("legend")
#let item = _t("item")
#let m = _t("m")
#let it = _t("it")
#let b = _t("b")
#let newline = _t("newline")
#let plain = _t("plain")

// Grouping & transforms
#let group = _t("group")
#let transform = _t("transform")
#let translate = _t("translate")
#let translate3d = _t("translate3d")
#let rotate = _t("rotate")
#let scale = _t("scale")
#let scale3d = _t("scale3d")
#let change-basis = _t("change-basis")
#let center = _t("center")
#let set-eye = _t("set-eye")

// Shapes library, reuse, definitions & misc
#let shape = _t("shape")
#let define-shapes = _t("define-shapes")
#let templates = _t("templates")
#let definition = _t("definition")
#let repeat = _t("repeat")
#let clip = _t("clip")
#let image = _t("image")
#let read = _t("read")
#let annotations = _t("annotations")
#let annotation = _t("annotation")
