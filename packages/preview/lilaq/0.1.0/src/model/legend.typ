#import "../process-styles.typ": twod-ify-alignment
#import "../bounds.typ": place-with-bounds
#import "../libs/elembic/lib.typ" as e

/// A diagram legend listing all labeled plots. 
/// 
/// Also refer to the 
/// #link("tutorials/legend")[legend tutorial] for more details. 
#let legend(

  /// The items to place in the legend. Items are tuples of a 
  /// plot preview image and the corresponding label. This field is 
  /// filled automatically by @diagram. 
  /// -> array
  ..children,

  /// How to fill the background of the legend. 
  /// -> none | color | gradient | tiling
  fill: white.transparentize(20%),

  /// Determines the padding of the entire legend within its box. 
  /// -> relative
  inset: 0.3em,

  /// How to stroke the outer border of the legend. 
  /// -> none | stroke 
  stroke: 0.5pt + gray,

  /// The radius of the outer border of the legend. 
  /// -> relative | dictionary
  radius: 1.5pt,

  /// Where to place the legend in the diagram. This can be an alignment
  /// or a position `(x, y)` where `x` and `y` are relative lengths, i.e., 
  /// they can be
  /// - lengths like `20pt` or `2em`,
  /// - ratios like `50%` (measuring in the data area),
  /// - or a combination thereof. 
  /// -> alignment | array
  position: top + right,

  /// In the case that @legend.position is an `alignment`, `pad` determines 
  /// how much to pad the legend from the outer edge of the data area 
  /// of the diagram. 
  /// -> length
  pad: 2pt, 

  /// The horizontal displacement of the legend from the position specified 
  /// through @legend.position. 
  /// -> length
  dx: 0pt,

  /// The vertical displacement of the legend from the position specified 
  /// through @legend.position. 
  /// -> length
  dy: 0pt,

  /// Specifies the $z$ position of the legend in the order of rendered
  /// diagram objects. 
  /// -> int | float
  z-index: 6,

) = {}

#let legend = e.element.declare(
  "legend",
  prefix: "lilaq",

  display: it => box(
    stroke: it.stroke,
    inset: it.inset,
    fill: it.fill,
    radius: it.radius,
    table(..it.children.join())
  ),

  fields: (
    e.field("children", e.types.array(e.types.any), required: true),
    e.field("fill", e.types.option(e.types.paint), default: white.transparentize(20%)),
    e.field("inset", relative, default: 0.3em),
    e.field("stroke", e.types.option(stroke), default: 0.5pt + gray),
    e.field("radius", e.types.union(relative, dictionary), default: 1.5pt),
    
    e.field("position", e.types.union(alignment, array), default: top + right),
    e.field("pad", length, default: 2pt),
    e.field("dx", length, default: 0pt),
    e.field("dy", length, default: 0pt),
    e.field("z-index", float, default: 6),
  ),

  parse-args: (default-parser, fields: none, typecheck: none) => (args, include-required: false) => {
    let args = if include-required {
      let values = args.pos()
      arguments(values, ..args.named())
    } else if args.pos() == () {
      args
    } else {
      assert(false, message: "element 'legend': unexpected positional arguments\n  hint: these can only be passed to the constructor")
    }

    default-parser(args, include-required: include-required)
  },
)


#let _place-legend-with-bounds(

  /// -> true | dictionary
  my-legend, 

  /// -> array(array)
  legend-entries,

  e-get

) = {
  let get-settable-field(element, object, field) = {
    e.fields(object).at(field, default: e-get(element).at(field))
  }

  if my-legend == true { my-legend = (:)}
  my-legend = legend(..legend-entries, ..my-legend)

  let pos = get-settable-field(legend, my-legend, "position")
  let dx = get-settable-field(legend, my-legend, "dx")
  let dy = get-settable-field(legend, my-legend, "dy")
  let pad = get-settable-field(legend, my-legend, "pad")

  let alignment = top + left

  if type(pos) == std.alignment {
    alignment = pos
  } else if type(pos) == array {
    assert.eq(pos.len(), 2, message: "`legend.position` needs to be a pair of coordinates, got " + repr(pos))
    dx += pos.at(0)
    dy += pos.at(1)
    pad = 0pt
  }
  
  place-with-bounds(
    alignment: alignment, 
    content-alignment: "inside", 
    dx: dx, dy: dy, pad: pad,
    wrap-in-box: true,
    {
      set table(
        columns: 2, 
        stroke: none, 
        inset: 2pt, 
        align: horizon + left
      )
      set table.cell(breakable: false)
      my-legend
    }
  )
}
