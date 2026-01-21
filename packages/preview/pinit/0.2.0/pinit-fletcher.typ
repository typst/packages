#import "pinit-core.typ": *

/// Draw a connecting line or arc in an arrow diagram.
///
/// Example:
///
/// ```typc
/// #import "@preview/fletcher:0.5.1"
/// Con#pin(1)#h(4em)#pin(2)nect
///
/// #pinit-fletcher-edge(
///  fletcher, 1, end: 2, (1, 0), [bend], bend: -20deg, "<->",
///  decorations: fletcher.cetz.decorations.wave.with(amplitude: .1),
/// )
/// ```
///
/// - fletcher (module): The Fletcher module. You can import it with something like `#import "@preview/fletcher:0.5.1"`
///
/// - start (pin): The starting pin of the edge. It is assumed that the pin is at the *origin point (0, 0)* of the edge.
///
/// - end (pin): The ending pin of the edge. If not provided, the edge will use default values for the width and height.
///
/// - start-dx (length): The x-offset of the starting pin. You should use pt units.
///
/// - start-dy (length): The y-offset of the starting pin. You should use pt units.
///
/// - end-dx (length): The x-offset of the ending pin. You should use pt units.
///
/// - end-dy (length): The y-offset of the ending pin. You should use pt units.
///
/// - width-scale (percent): The width scale of the edge. The default value is 100%.
///
///   If you set the width scale to 50%, the width of the edge will be half of the default width. Then you can use `"r,r"` which is equivalent to single `"r"`.
///
/// - height-scale (percent): The height scale of the edge. The default value is 100%.
///
/// - default-width (length): The default width of the edge. The default value is 30pt, which will only be used if the end pin is not provided or the width is 0pt or 0em.
///
/// - default-height (length): The default height of the edge. The default value is 30pt, which will only be used if the end pin is not provided or the height is 0pt or 0em.
///
///
/// ======================================================================
///
/// The following are the options for the `fletcher.edge` function. Source: [Jollywatt/typst-fletcher](https://github.com/Jollywatt/typst-fletcher)
///
/// ======================================================================
///
/// - ..args (any): An edge's positional arguments may specify:
///   - the edge's #param[edge][vertices], each specified with a CeTZ-style coordinate
///   - the #param[edge][label] content
///   - arrow #param[edge][marks], like `"=>"` or `"<<-|-o"`
///   - other style flags, like `"double"` or `"wave"`
///
///   Vertex coordinates must come first, and are optional:
///
///   ```typc
///   edge(from, to, ..) // explicit start and end nodes
///   edge(to, ..) == edge(auto, to, ..) // start snaps to previous node
///   edge(..) == edge(auto, auto, ..) // snaps to previous and next nodes
///   edge(from, v1, v2, ..vs, to, ..) // a multi-segmented edge
///   edge(from, "->", to) // for two vertices, the marks style can come in between
///   ```
///
///   All vertices except the start point can be shorthand relative coordinate
///   string containing the characters
///   ${#"lrudtbnesw".clusters().map(raw).join($, $)}$ or commas.
///
///   If given as positional arguments, an edge's #param[edge][marks] and
///   #param[edge][label] are disambiguated by guessing based on the types. For
///   example, the following are equivalent:
///
///   ```typc
///   edge((0,0), (1,0), $f$, "->")
///   edge((0,0), (1,0), "->", $f$)
///   edge((0,0), (1,0), $f$, marks: "->")
///   edge((0,0), (1,0), "->", label: $f$)
///   edge((0,0), (1,0), label: $f$, marks: "->")
///   ```
///
///   Additionally, some common options are given flags that may be given as
///   string positional arguments. These are
///   #fletcher.EDGE_FLAGS.keys().map(repr).map(raw).join([, ], last: [, and ]).
///   For example, the following are equivalent:
///
///   ```typc
///   edge((0,0), (1,0), $f$, "wave", "crossing")
///   edge((0,0), (1,0), $f$, decorations: "wave", crossing: true)
///   ```
///
/// - vertices (array): Array of (at least two) coordinates for the edge.
///
///   Vertices can also be specified as leading positional arguments, but if so,
///   the `vertices` option must be empty. If the number of vertices is greater
///   than two, #param[edge][kind] defaults to `"poly"`.
///
/// - kind (string): The kind of the edge, one of `"line"`, `"arc"`, or `"poly"`.
///   This is chosen automatically based on the presence of other options
///   (#param[edge][bend] implies `"arc"`, #param[edge][corner] or additional
///   vertices implies `"poly"`).
///
/// - corner (none, left, right): Whether to create a right-angled corner,
///   turning `left` or `right`.
///   (Bending right means the corner sticks out to the left, and vice versa.)
///
///   #diagram(
///   	node((0,1), `from`),
///   	node((1,0), `to`),
///   	edge((0,1), (1,0), `right`, "->", corner: right),
///   	edge((0,1), (1,0), `left`, "->", corner: left),
///   )
///
/// - bend (angle): Edge curvature. If `0deg`, the connector is a straight line;
///   positive angles bend clockwise.
///
///   #diagram(debug: 0, {
///   	node((0,0), $A$)
///   	node((1,1), $B$)
///   	let N = 4
///   	range(N + 1)
///   		.map(x => (x/N - 0.5)*2*100deg)
///   		.map(θ => edge((0,0), (1,1), θ, bend: θ, ">->", label-side: center))
///   		.join()
///   })
///
/// - label (content): Content for the edge label. See the
///   #param[edge][label-pos] and #param[edge][label-side] options to control
///   the position (and #param[edge][label-sep] and #param[edge][label-anchor]
///   for finer control).
///
/// - label-side (left, right, center): Which side of the edge to place the
///   label on, viewed as you walk along it from base to tip.
///
///   If `center`, then the label is placed directly on the edge and
///   #param[edge][label-fill] defaults to `true`. When `auto`, a value of
///   `left` or `right` is  automatically chosen so that the label is:
///    - roughly above the connector, in the case of straight lines; or
///    - on the outside of the curve, in the case of arcs.
///
/// - label-pos (number): Position of the label along the connector, from the
///   start to end (from `0` to `1`).
///
///   #stack(
///   	dir: ltr,
///   	spacing: 1fr,
///   	..(0, 0.25, 0.5, 0.75, 1).map(p => fletcher.diagram(
///   		cell-size: 1cm,
///   		edge((0,0), (1,0), p, "->", label-pos: p))
///   	),
///   )
///
/// - label-sep (length): Separation between the connector and the label anchor.
///
///   With the default anchor (automatically set to `"south"` in this case):
///
///   #diagram(
///   	debug: 2,
///   	cell-size: 8mm,
///   	{
///   		for (i, s) in (-5pt, 0pt, .4em, .8em).enumerate() {
///   			edge((2*i,0), (2*i + 1,0), s, "->", label-sep: s)
///   		}
///   })
///
///   With #param[edge][label-anchor] set to `"center"`:
///
///   #diagram(
///   	debug: 2,
///   	cell-size: 8mm,
///   	{
///   		for (i, s) in (-5pt, 0pt, .4em, .8em).enumerate() {
///   			edge((2*i,0), (2*i + 1,0), s, "->", label-sep: s, label-anchor: "center")
///   		}
///   })
///
///   Set #param[diagram][debug] to `2` or higher to see label anchors and
///   outlines as seen here.
///
///   Default: #the-param[diagram][label-sep]
///
/// - label-angle (angle, left, right, top, bottom, auto): Angle to rotate the
///   label (counterclockwise).
///
///   If a direction is given, the label is rotated so that the edge travels in
///   that direction relative to the label. If `auto`, the best of `right` or
///   `left` is chosen.
///
///   #for angle in (0deg, 90deg, auto, right, top, left) {
///   	diagram(edge((0,1), (2,0), "->", [#angle], label-angle: angle))
///   }
///
/// - label-anchor (anchor): The CeTZ-style anchor point of the label to use for
///   placement (e.g., `"north-east"` or `"center"`). If `auto`, the best anchor
///   is chosen based on #param[edge][label-side], #param[edge][label-angle],
///   and the edge's direction.
///
/// - label-fill (bool, paint): The background fill for the label. If `true`,
///   defaults to the value of #param[edge][crossing-fill]. If `false` or
///   `none`, no fill is used. If `auto`, then defaults to `true` if the label
///   is covering the edge (#param[edge][label-side]`: center`).
///
/// - label-size (auto, length): The default text size to apply to edge labels.
///
///   Default: #the-param[diagram][label-size]
///
/// - label-wrapper (auto, function): Callback function accepting a node
///   dictionary and returning the label content. This is used to add a label
///   background (see #param[edge][crossing-fill]), and can be used to adjust
///   the label's padding, outline, and so on.
///
///   #example(```
///   diagram(edge($f$, label-wrapper: e =>
///   	circle(e.label, fill: e.label-fill)))
///   ```)
///
///   Default: #the-param[diagram][label-wrapper]
///
/// - stroke (stroke): Stroke style of the edge. Arrows/marks scale with the
///   stroke thickness (and with #param[edge][mark-scale]).
///
/// - dash (string): The stroke's dash style. This is also set by some mark
///   styles. For example, setting `marks: "<..>"` applies `dash: "dotted"`.
///
/// - decorations (none, string, function): Apply a CeTZ path decoration to the
///   stroke. Preset options are `"wave"`, `"zigzag"`, and `"coil"` (which may
///   also be passed as convenience positional arguments), but a decoration
///   function may also be specified.
///
///   #example(```
///   diagram(
///   	$
///   		A edge("wave") &
///   		B edge("zigzag") &
///   		C edge("coil") & D \
///   		alpha &&& omega
///   	$,
///   	edge((0,1), (3,1), "<->", decorations:
///   		cetz.decorations.wave
///   			.with(amplitude: .4)
///   	)
///   )
///   ```)
///
/// - marks (array): The marks (arrowheads) to draw along an edge's stroke. This
///   may be:
///
///   - A shorthand string such as `"->"` or `"hook'-/->>"`. Specifically,
///     shorthand strings are of the form $M_1 L M_2$ or $M_1 L M_2 L M_3$, etc,
///     where
///
///     $ M_i in #`fletcher.MARKS` = #context math.mat(..fletcher.MARKS.get().keys().map(i => $#raw(lang: none, i),$).chunks(6), delim: "{") $
///     is a mark name and
///     $ L in #`fletcher.LINE_ALIASES` = {#fletcher.LINE_ALIASES.keys().map(raw.with(lang: none)).join($,$)} $
///     is the line style.
///
///   - An array of marks, where each mark is specified by name of as a _mark
///     object_ (dictionary of parameters with a `draw` entry).
///
///   Shorthands are expanded into other arguments. For example,
///   `edge(p1, p2, "=>")` is short for `edge(p1, p2, marks: (none, "head"), "double")`, or more precisely, the result of `edge(p1, p2, ..fletcher.interpret-marks-arg("=>"))`.
///
///   #table(
///   	columns: (1fr, 4fr),
///   	align: (center + horizon, horizon),
///   	[Result], [Value of `marks`],
///   	..(
///   		"->",
///   		">>-->",
///   		"<=>",
///   		"==>",
///         "->>-",
///   		"x-/-@",
///   		"|..|",
///   		"hook->>",
///   		"hook'->>",
///   		"||-*-harpoon'",
///         ("X", (inherit: "head", size: 15, sharpness: 40deg),), ((inherit:
///         "circle", pos: 0.5, fill: auto),),
///   	).map(arg => (
///   		fletcher.diagram(edge((0,0), (1,0), marks: arg, stroke: 0.8pt)),
///   		raw(repr(arg)),
///   	)).join()
///   )
///
/// - mark-scale (percent): Scale factor for marks or arrowheads, relative to
///   the #param[edge][stroke] thickness. See also #the-param[diagram][mark-scale].
///
///   #diagram(
///   	label-sep: 10pt,
///   	edge-stroke: 1pt,
///   	for i in range(3) {
///   		let s = (1 + i/2)*100%
///   		edge((2*i,0), (2*i + 1,0), label: s, "->", mark-scale: s)
///   	}
///   )
///
///   Note that the default arrowheads scale automatically with double and
///   triple strokes:
///
///   #diagram(
///   	label-sep: 10pt,
///   	edge-stroke: 1pt,
///   	for (i, s) in ("->", "=>", "==>").enumerate() {
///   		edge((2*i,0), (2*i + 1,0), s, label: raw(s, lang: none))
///   	}
///   )
///
/// - extrude (array): Draw a separate stroke for each extrusion offset to
///   obtain a multi-stroke effect. Offsets may be numbers (specifying multiples
///   of the stroke's thickness) or lengths.
///
///   #diagram({
///   	(
///   		(0,),
///   		(-1.5,+1.5),
///   		(-2,0,+2),
///   		(-.5em,),
///   		(0, 5pt,),
///   	).enumerate().map(((i, e)) => {
///   		edge(
///   			(2*i, 0), (2*i + 1, 0), [#e], "|->",
///   			extrude: e, stroke: 1pt, label-sep: 1em)
///   	}).join()
///   })
///
///   Notice how the ends of the line need to shift a little depending on the
///   mark. This offset is computed with `cap-offset()`.
///
///   See also #the-param[node][extrude].
///
/// - crossing (bool): If `true`, draws a backdrop of color
///   #param[edge][crossing-fill] to give the illusion of lines crossing each
///    other.
///
///   #diagram({
///   	edge((0,1), (1,0), stroke: 1pt)
///   	edge((0,0), (1,1), stroke: 1pt)
///   	edge((2,1), (3,0), stroke: 1pt)
///   	edge((2,0), (3,1), stroke: 1pt, crossing: true)
///   })
///
///   You can also pass `"crossing"` as a positional argument as a shorthand for
///   `crossing: true`.
///
/// - crossing-thickness (number): Thickness of the "crossing" background stroke
///   (applicable if #param[edge][crossing] is `true`) in multiples of the
///   normal stroke's thickness.
///
///   #diagram({
///   	(1, 2, 4, 8).enumerate().map(((i, x)) => {
///   		edge((2*i, 1), (2*i + 1, 0), stroke: 1pt, label-sep: 1em)
///   		edge((2*i, 0), (2*i + 1, 1), raw(str(x)), stroke: 1pt, label-sep:
///   		2pt, label-pos: 0.3, crossing: true, crossing-thickness: x)
///   	}).join()
///   })
///
///   Default: #the-param[diagram][crossing-thickness]
///
/// - crossing-fill (paint): Color to use behind connectors or labels to give
///   the illusion of crossing over other objects.
///
///   #let cross(x, fill) = {
///   	edge((2*x + 0,1), (2*x + 1,0), stroke: 1pt)
///   	edge((2*x + 0,0), (2*x + 1,1), $f$, stroke: 1pt, crossing: true, crossing-fill: fill, label-fill: true)
///   }
///   #diagram(crossing-thickness: 5, {
///   	cross(0, white)
///   	cross(1, blue.lighten(50%))
///   })
///
///   Default: #the-param[diagram][crossing-fill]
///
/// - corner-radius (length, none): Radius of rounded corners for edges with
///   multiple segments. Note that `none` is distinct from `0pt`.
///
///   #for (i, r) in (none, 0pt, 5pt).enumerate() {
///   	if i > 0 { h(1fr) }
///   	fletcher.diagram(
///   		edge-stroke: 1pt,
///   		edge((3*i, 0), "r,t,rd,r", "=>", raw(repr(r)), label-pos: 0.6, corner-radius: r)
///   	)
///   }
///
///   This length specifies the corner radius for right-angled bends. The actual
///   radius is smaller for acute angles and larger for obtuse angles to balance
///   things visually. (Trust me, it looks naff otherwise!)
///
///   Default: #the-param[diagram][edge-corner-radius]
///
/// - shift (length, number, pair): Amount to shift the edge sideways by,
///   perpendicular to its direction. A pair `(from, to)` controls the shifts at
///   each end of the edge independently, and a single shift `s` is short for
///   `(s, s)`. Shifts can absolute lengths (e.g., `5pt`) or coordinate
///   differences (e.g., `0.1`).
///
///   #diagram(
///   	node((0,0), $A$), node((1,0), $B$),
///   	edge((0,0), (1,0), "->", `3pt`, shift: 3pt),
///   	edge((0,0), (1,0), "->", `-3pt`, shift: -3pt, label-side: right),
///   )
///
///   If an edge has many vertices, the shifts only affect the first and last
///   segments of the edge.
///
///   #example(```
///   diagram(
///   	node-fill: luma(70%),
///   	node((0,0), [Hello]),
///   	edge("u,r,d", "->"),
///   	edge("u,r,d", "-->", shift: 8pt),
///   	node((1,0), [World]),
///   )
///   ```)
///
/// - snap-to (pair): The nodes the start and end of an edge should snap to.
/// Each node can be a position or node #param[node][name], or `none` to disable
/// snapping. See also #the-param[node][snap].
///
///   By default, an edge's first and last #param[edge][vertices] snap to nearby
///   nodes. This option can be used in case automatic snapping fails (if there
///   are many nodes close together, for example.)
///
/// - layer (number): Layer on which to draw the edge.
///
///   Objects on a higher `layer` are drawn on top of objects on a lower
///   `layer`. Objects on the same layer are drawn in the order they are passed
///   to `diagram()`.
///
/// - post (function): Callback function to intercept `cetz` objects before they
///   are drawn to the canvas.
///
///   This can be used to hide elements without affecting layout (for use with
///   #link("https://github.com/touying-typ/touying")[Touying], for example).
///   The `hide()` function also helps for this purpose.
///
#let pinit-fletcher-edge(
  fletcher,
  start,
  end: none,
  start-dx: 0pt,
  start-dy: 0pt,
  end-dx: 0pt,
  end-dy: 0pt,
  width-scale: 100%,
  height-scale: 100%,
  default-width: 30pt,
  default-height: 30pt,
  // fletcher.edge arguments
	..args,
	vertices: (),
	label: none,
	label-side: auto,
	label-pos: 0.5,
	label-sep: auto,
	label-angle: 0deg,
	label-anchor: auto,
	label-fill: auto,
	label-size: auto,
	label-wrapper: auto,
	stroke: auto,
	dash: none,
	decorations: none,
	extrude: (0,),
	shift: 0pt,
	kind: auto,
	bend: 0deg,
	corner: none,
	corner-radius: auto,
	marks: (),
	mark-scale: 100%,
	crossing: false,
	crossing-thickness: auto,
	crossing-fill: auto,
	snap-to: (auto, auto),
	layer: 0,
	post: x => x,
) = {
  // fletcher.edge arguments
  let fletcher-edge-args = (
    vertices: vertices,
    label: label,
    label-side: label-side,
    label-pos: label-pos,
    label-sep: label-sep,
    label-angle: label-angle,
    label-anchor: label-anchor,
    label-fill: label-fill,
    label-size: label-size,
    label-wrapper: label-wrapper,
    stroke: stroke,
    dash: dash,
    decorations: decorations,
    extrude: extrude,
    shift: shift,
    kind: kind,
    bend: bend,
    corner: corner,
    corner-radius: corner-radius,
    marks: marks,
    mark-scale: mark-scale,
    crossing: crossing,
    crossing-thickness: crossing-thickness,
    crossing-fill: crossing-fill,
    snap-to: snap-to,
    layer: layer,
    post: post,
  )
  pinit(
    start,
    ..(
      if end != none {
        (end,)
      } else {
        ()
      }
    ),
    callback: (start-pos, ..other-pos) => {
      // calculate width and height
      let width = default-width
      let height = default-height
      let start-x = start-pos.x + start-dx
      let start-y = start-pos.y + start-dy
      if other-pos.pos().len() > 0 {
        let end-pos = other-pos.pos().at(0)
        let end-x = end-pos.x + end-dx
        let end-y = end-pos.y + end-dy
        width = calc.abs(start-x - end-x)
        height = calc.abs(start-y - end-y)
        width *= width-scale
        height *= height-scale
        if width == 0pt or width == 0em {
          width = default-width
        }
        if height == 0pt or height == 0em {
          height = default-height
        }
      }

      let origin-id = repr(start) + repr(start-dx) + repr(start-dy) + "-origin"

      // place the diagram directly to get the origin offset
      absolute-place(
        dx: start-x,
        dy: start-y,
        hide(
          fletcher.diagram(
            spacing: (width, height),
            node-inset: 0pt,
            fletcher.node((0, 0), pin(origin-id)),
            fletcher.edge(..args, ..fletcher-edge-args),
          ),
        ),
      )

      // place the diagram again with the correct offset
      pinit(
        origin-id,
        callback: origin-pos => {
          absolute-place(
            dx: 2 * start-x - origin-pos.x,
            dy: 2 * start-y - origin-pos.y,
            fletcher.diagram(
              spacing: (width, height),
              node-inset: 0pt,
              fletcher.node((0, 0), none),
              fletcher.edge(..args, ..fletcher-edge-args),
            ),
          )
        },
      )
    },
  )
}