/// Creates a pedigree.
///
/// Use syntax such as:
/// ```examplec
  /// >>> set text(font: "libertinus serif")
/// >>> import pedigrypst: *
/// pedigree(length: 1.5cm, {
///   individual(1, 1, "male")
///   individual(1, 2, "female")
///   individual(2, 1, "female", fill: "filled")
///   union("i1-1", "i1-2")
///   children("u1", "i2-1")
/// })
/// ```
/// -> content
#let pedigree(
  /// The individuals, duplicates, twins, unions, and childrens objects to display in the pedigree.
  contents,
  /// The number of steps to use in the #link("https://en.wikipedia.org/wiki/Force-directed_graph_drawing", [force-directed graph drawing]). For larger pedigrees, this may need to be several hundred. -> int
  convergence-time: 100,
  /// The visual minimum height of each generation. -> int | float
  generation-height: 1,
  /// The length used on the #cetz-link("api/internal/canvas/#length", [CeTZ canvas]). Scales the pedigree relative to #raw("1cm", lang: "typc"). -> length
  length: 1cm,
  /// Whether to add Roman numerals indicating generation number to the left side of the pedigree.
  /// ```examplec
  /// >>> set text(font: "libertinus serif")
  /// >>> import pedigrypst: *
  /// pedigree(generation-labels: true, length: 1.5cm, {
  ///   individual(1, 1, "male")
  /// })
  /// ```
  /// ```examplec
  /// >>> set text(font: "libertinus serif")
  /// >>> import pedigrypst: *
  /// pedigree(generation-labels: false, length: 1.5cm, {
  ///   individual(1, 1, "male")
  /// })
  /// ```
  /// -> bool
  generation-labels: true,
  /// Returns CeTZ content to add to the canvas after the pedigree is drawn.
  /// -> function | none
  draw: none,
  /// The #cetz-link("basics/styling", [CeTZ style]) to give to the outline of all individuals. Must be a dictionary.
  /// ```examplec
  /// >>> set text(font: "libertinus serif")
  /// >>> import pedigrypst: *
  /// pedigree(
  /// >>>  length: 4cm,
  /// >>>  generation-labels: false,
  ///   stroke-style: (
  ///     paint: blue,
  ///     dash: "dashed",
  ///   ),
  ///   {
  ///     individual(1, 1, "male", label: none)
  ///   }
  /// )
  /// ```
  ///  -> dictionary
  stroke-style: (:),
  /// The color to give to the empty part of all individuals.
  /// ```examplec
  /// >>> set text(font: "libertinus serif")
  /// >>> import pedigrypst: *
  /// pedigree(
  /// >>>  length: 4cm,
  /// >>>  generation-labels: false,
  ///   empty-style: yellow,
  ///   {
  ///     individual(1, 1, "female", fill: "left", label: none)
  ///   }
  /// )
  /// ```
  /// -> color | none | auto
  empty-style: auto,
  /// The color to give to the filled part of all individuals.
  /// ```examplec
  /// >>> set text(font: "libertinus serif")
  /// >>> import pedigrypst: *
  /// pedigree(
  /// >>>  length: 4cm,
  /// >>>  generation-labels: false,
  ///   fill-style: orange,
  ///   {
  ///     individual(1, 1, "male", fill: "left", label: none)
  ///   }
  /// )
  /// ```
  /// -> color | none | auto
  fill-style: auto,
  /// The #cetz-link("basics/styling", [CeTZ style]) to give to all deceased crosses. Must be a dictionary.
  /// ```examplec
  /// >>> set text(font: "libertinus serif")
  /// >>> import pedigrypst: *
  /// pedigree(
  /// >>>  length: 4cm,
  /// >>>  generation-labels: false,
  ///   dead-style: (thickness: 4pt),
  ///   {
  ///     individual(1, 1, "female", dead: true, label: none)
  ///   }
  /// )
  /// ```
  /// -> dictionary
  dead-style: (:),
  /// The #cetz-link("basics/styling", [CeTZ style]) to give to all adoption brackets. Must be a dictionary.
  /// ```examplec
  /// >>> set text(font: "libertinus serif")
  /// >>> import pedigrypst: *
  /// pedigree(
  /// >>>   length: 4cm,
  /// >>>   generation-labels: false,
  ///   adopted-style: (paint: red),
  ///   {
  ///     individual(1, 1, "male", adopted: true, label: none)
  ///   }
  /// )
  /// ```
  /// -> dictionary
  adopted-style: (:),
  /// The #cetz-link("basics/styling", [CeTZ style]) to give to all propositi. Must be a dictionary.
  /// ```examplec
  /// >>> set text(font: "libertinus serif")
  /// >>> import pedigrypst: *
  /// pedigree(
  /// >>>   length: 4cm,
  /// >>>   generation-labels: false,
  ///   propositus-style: (paint: blue.lighten(30%)),
  ///   {
  ///     individual(1, 1, "female", propositus: true, label: none)
  ///   }
  /// )
  /// ```
  /// -> dictionary
  propositus-style: (:),
  /// The #cetz-link("basics/styling", [CeTZ style]) to give to all duplicate lines. Must be a dictionary. Defaults to being dashed.
  /// ```examplec
  /// >>> set text(font: "libertinus serif")
  /// >>> import pedigrypst: *
  /// pedigree(
  /// >>>   length: 4cm,
  /// >>>   generation-labels: false,
  ///   duplicate-curve-style: (thickness: 8pt),
  ///   {
  ///     duplicate(1, "i1-1", bezier: -1)
  ///     individual(1, 1, "male", label: none)
  ///   }
  /// )
  /// ```
  /// -> dictionary
  duplicate-curve-style: (:),
  /// The #cetz-link("basics/styling", [CeTZ style]) to give to all twin lines. Must be a dictionary.
  /// ```examplec
  /// >>> set text(font: "libertinus serif")
  /// >>> import pedigrypst: *
  /// pedigree(
  /// >>>   length: 2cm,
  /// >>>   generation-labels: false,
  ///   twin-style: (paint: red),
  ///   {
  ///     individual(1, 1, "male")
  ///     individual(2, 1, "female")
  ///     individual(2, 2, "male")
  ///     twins("i2-1", "i2-2")
  ///     children("i1-1", "t1")
  ///   }
  /// )
  /// ```
  /// -> dictionary
  twin-style: (:),
  /// The #cetz-link("basics/styling", [CeTZ style]) to give to the monozygocity indicator of all twins. Must be a dictionary.
  /// ```examplec
  /// >>> set text(font: "libertinus serif")
  /// >>> import pedigrypst: *
  /// pedigree(
  /// >>>   length: 2cm,
  /// >>>   generation-labels: false,
  ///   monozygotic-style: (paint: green, thickness: 2pt),
  ///   {
  ///     individual(1, 1, "male")
  ///     individual(2, 1, "female")
  ///     individual(2, 2, "male")
  ///     twins("i2-1", "i2-2", monozygotic: true)
  ///     children("i1-1", "t1")
  ///   }
  /// )
  /// ```
  /// -> dictionary
  monozygotic-style: (:),
  /// The #cetz-link("basics/styling", [CeTZ style]) to give to the union line of all unions. Must be a dictionary.
  /// ```examplec
  /// >>> set text(font: "libertinus serif")
  /// >>> import pedigrypst: *
  /// pedigree(
  /// >>>   length: 4cm,
  /// >>>   generation-labels: false,
  ///   union-style: (thickness: 8pt),
  ///   {
  ///     individual(1, 1, "female")
  ///     individual(1, 2, "male")
  ///     union("i1-1", "i1-2")
  ///   }
  /// )
  /// ```
  /// -> dictionary
  union-style: (:),
  /// The #cetz-link("basics/styling", [CeTZ style]) to give to the separation indicators of all unions. Must be a dictionary.
  /// ```examplec
  /// >>> set text(font: "libertinus serif")
  /// >>> import pedigrypst: *
  /// pedigree(
  /// >>>   length: 4cm,
  /// >>>   generation-labels: false,
  ///   divorced-style: (paint: green),
  ///   {
  ///     individual(1, 1, "female")
  ///     individual(1, 2, "male")
  ///     union("i1-1", "i1-2", divorced: 2)
  ///   }
  /// )
  /// ```
  /// -> dictionary
  divorced-style: (:),
  /// The #cetz-link("basics/styling", [CeTZ style]) to give to the no children indicator for all children. Must be a dictionary.
  /// ```examplec
  /// >>> set text(font: "libertinus serif")
  /// >>> import pedigrypst: *
  /// pedigree(
  /// >>>   length: 3cm,
  /// >>>   generation-labels: false,
  ///   no-children-style: (paint: red),
  ///   {
  ///     individual(1, 1, "male")
  ///     individual(1, 2, "female")
  ///     union("i1-1", "i1-2")
  ///     children("u1", infertile: true)
  ///   }
  /// )
  /// ```
  /// -> dictionary
  no-children-style: (:),
  /// The #cetz-link("basics/styling", [CeTZ style]) to give to all lines of descent. Must be a dictionary.
  /// ```examplec
  /// >>> set text(font: "libertinus serif")
  /// >>> import pedigrypst: *
  /// pedigree(
  /// >>>   length: 2.5cm,
  /// >>> generation-labels: false,
  ///   line-of-descent-style: (thickness: 4pt),
  ///   {
  ///     individual(1, 1, "male")
  ///     individual(1, 2, "female")
  ///     individual(2, 1, "female")
  ///     individual(2, 2, "male")
  ///     union("i1-1", "i1-2")
  ///     children("u1", "i2-1", "i2-2")
  ///   }
  /// )
  /// ```
  /// -> dictionary
  line-of-descent-style: (:),
  /// The #cetz-link("basics/styling", [CeTZ style]) to give to all sibling lines. Must be a dictionary.
  /// ```examplec
  /// >>> set text(font: "libertinus serif")
  /// >>> import pedigrypst: *
  /// pedigree(
  /// >>>   length: 2.5cm,
  /// >>>   generation-labels: false,
  ///   sibling-line-style: (thickness: 4pt),
  ///   {
  ///     individual(1, 1, "male")
  ///     individual(1, 2, "female")
  ///     individual(2, 1, "female")
  ///     individual(2, 2, "male")
  ///     union("i1-1", "i1-2")
  ///     children("u1", "i2-1", "i2-2")
  ///   }
  /// )
  /// ```
  /// -> dictionary
  sibling-line-style: (:),
  /// The #cetz-link("basics/styling", [CeTZ style]) to give to all child lines. Must be a dictionary.
  /// ```examplec
  /// >>> set text(font: "libertinus serif")
  /// >>> import pedigrypst: *
  /// pedigree(
  /// >>>   length: 2.5cm,
  /// >>>   generation-labels: false,
  ///   child-line-style: (paint: purple, thickness: 3pt),
  ///   {
  ///     individual(1, 1, "male")
  ///     individual(1, 2, "female")
  ///     individual(2, 1, "female")
  ///     individual(2, 2, "male")
  ///     union("i1-1", "i1-2")
  ///     children("u1", "i2-1", "i2-2")
  ///   }
  /// )
  /// ```
  /// -> dictionary
  child-line-style: (:),
) = {
  import "processing.typ": *
  import "resolve.typ": *
  import "draw.typ": draw-pedigree
  if contents == none {
    contents = (:)
  }

  let length-scale = length / 1cm // for scaling other things, like font size

  let data = (:)
  let data = process-individuals(data, contents)
  let data = process-duplicates(data, contents)
  let data = process-twins(data, contents)
  let data = process-unions(data, contents)
  let data = process-childrens(data, contents)

  let (offsets, childrens-x-bounds) = resolve-overlaps(data, convergence-time)

  let draw-data = (
    offsets: offsets,
    childrens-x-bounds: childrens-x-bounds,
    default-generation-height: generation-height,
    length: length,
    length-scale: length-scale,
    generation-labels: generation-labels,
    draw: draw,
    default-stroke-style: stroke-style,
    default-empty-style: empty-style,
    default-fill-style: fill-style,
    default-dead-style: dead-style,
    default-adopted-style: adopted-style,
    default-propositus-style: propositus-style,
    default-duplicate-curve-style: duplicate-curve-style,
    default-twin-style: twin-style,
    default-monozygotic-style: monozygotic-style,
    default-union-style: union-style,
    default-divorced-style: divorced-style,
    default-no-children-style: no-children-style,
    default-line-of-descent-style: line-of-descent-style,
    default-sibling-line-style: sibling-line-style,
    default-child-line-style: child-line-style,
  )
  return draw-pedigree(data, draw-data)
}

/// Creates a single individual in a pedigree.
#let individual(
  /// The generation of the individual, starting from #raw("1", lang: "typc"). -> int
  generation,
  /// The ordinality of the individual within its generation, starting from #raw("1", lang: "typc"). This is used only for the label and to reference this individual. -> int
  ind-number,
  /// The shape of the individual. Must be #raw("\"male\"", lang: "typc"), #raw("\"female\"", lang: "typc"), #raw("\"unknown\"", lang: "typc"), or #raw("\"miscarriage\"", lang: "typc").
  /// ```examplec
  /// >>> set text(font: "libertinus serif")
  /// >>> import pedigrypst: *
  /// pedigree(
  /// >>> length: 2cm,
  /// >>> generation-labels: false,
  ///   {
  ///     individual(1, 1, "male", label: `male`)
  ///     individual(1, 2, "female", label: `female`)
  ///     individual(2, 1, "unknown", label: `unknown`)
  ///     individual(2, 2, "miscarriage", label: `miscarriage`)
  ///   }
  /// )
  /// ```
  /// -> str
  sex,
  /// The pattern of filling the individual. Must be #raw("\"empty\"", lang: "typc"), #raw("\"filled\"", lang: "typc"), #raw("\"unknown\"", lang: "typc"), #raw("\"dot\"", lang: "typc"), #raw("\"left\"", lang: "typc"), #raw("\"right\"", lang: "typc"), #raw("\"up\"", lang: "typc"), #raw("\"down\"", lang: "typc"), or use quadrant notation.
  ///
  /// #link("https://en.wikipedia.org/wiki/Quadrant_(plane_geometry)", [Quadrant]) notation involves placing the capitalized Roman numerals of a quadrant, in order, separated by hyphens. For example, #raw("\"I-III-IV\"", lang: "typc") is valid quadrant notation.
  /// ```examplec
  /// >>> set text(font: "libertinus serif")
  /// >>> import pedigrypst: *
  /// pedigree(
  /// >>>   length: 2cm,
  /// >>>   generation-labels: false,
  ///   {
  ///     individual(1, 1, "male", fill: "empty", label: `empty`)
  ///     individual(1, 2, "female", fill: "filled", label: `filled`)
  ///     individual(1, 3, "female", fill: "unknown", label: `unknown`)
  ///     individual(1, 4, "unknown", fill: "dot", label: `dot`)
  ///     individual(2, 1, "male", fill: "left", label: `left`)
  ///     individual(2, 2, "female", fill: "right", label: `right`)
  ///     individual(2, 3, "female", fill: "up", label: `up`)
  ///     individual(2, 4, "unknown", fill: "down", label: `down`)
  ///     individual(3, 1, "male", fill: "I", label: `I`)
  ///     individual(3, 2, "female", fill: "I-III", label: `I-III`)
  ///     individual(3, 3, "female", fill: "I-III-IV", label: `I-III-IV`)
  ///     individual(3, 4, "unknown", fill: "II-IV", label: `II-IV`)
  ///   }
  /// )
  /// ```
  /// -> str
  fill: "empty",
  /// Whether to draw the deceased indicator on the individual. Can be #raw("true", lang: "typc"), #raw("false", lang: "typc"), #raw("\"true\"", lang: "typc"), #raw("\"false\"", lang: "typc"), #raw("\"single\"", lang: "typc"), and #raw("\"double\"", lang: "typc").
  ///
  /// #raw("true", lang: "typc"), #raw("\"true\"", lang: "typc"), and #raw("\"single\"", lang: "typc") all create one cross up and to the right, and #raw("\"double\"", lang: "typc") creates another cross up and to the left.
  /// ```examplec
  /// >>> set text(font: "libertinus serif")
  /// >>> import pedigrypst: *
  /// pedigree(
  /// >>>   length: 3cm,
  /// >>>   generation-labels: false,
  ///   {
  ///     individual(1, 1, "male", dead: false, label: `false`)
  ///     individual(1, 2, "female", dead: "single", label: `single`)
  ///     individual(1, 3, "female", dead: "double", label: `double`)
  ///   }
  /// )
  /// ```
  /// -> bool | str
  dead: false,
  /// Whether to draw the adopted brackets around the individual. Can be #raw("true", lang: "typc"), #raw("false", lang: "typc"), #raw("\"true\"", lang: "typc"), #raw("\"false\"", lang: "typc"), and #raw("\"alt\"", lang: "typc").
  ///
  /// #raw("true", lang: "typc") and #raw("\"true\"", lang: "typc") draw whole brackets around the individual, while #raw("\"alt\"", lang: "typc") draws brackets with two slits near the middle.
  /// ```examplec
  /// >>> set text(font: "libertinus serif")
  /// >>> import pedigrypst: *
  /// pedigree(
  /// >>>   length: 3cm,
  /// >>>   generation-labels: false,
  ///   {
  ///     individual(1, 1, "female", adopted: false, label: `false`)
  ///     individual(1, 2, "male", adopted: true, label: `true`)
  ///     individual(1, 3, "unknown", adopted: "alt", label: `alt`)
  ///   }
  /// )
  /// ```
  /// -> bool | str
  adopted: false,
  /// Whether to draw a propositus. If the alignment is unspecified, the propositus will go in the bottom-left corner.
  /// ```examplec
  /// >>> set text(font: "libertinus serif")
  /// >>> import pedigrypst: *
  /// pedigree(
  /// >>>   length: 4cm,
  /// >>>   generation-labels: false,
  ///   {
  ///     individual(1, 1, "unknown", propositus: false, label: `false`)
  ///     individual(1, 2, "female", propositus: true, label: `true`)
  ///     individual(2, 1, "male", propositus: top, label: `top`)
  ///     individual(2, 2, "female", propositus: bottom + right, label: `bottom + right`)
  ///   }
  /// )
  /// ```
  /// -> bool | alignment
  propositus: false,
  /// The label to place beneath the individual. If auto, the individual's generation and ind-number will be shown.
  /// ```examplec
  /// >>> set text(font: "libertinus serif")
  /// >>> import pedigrypst: *
  /// pedigree(
  /// >>>   length: 3cm,
  /// >>>   generation-labels: false,
  ///   {
  ///     individual(1, 1, "male", label: auto, in-label: `auto`)
  ///     individual(1, 2, "female", label: none, in-label: `none`)
  ///     individual(1, 3, "male", label: [:3], in-label: `[:3]`)
  ///   }
  /// )
  /// ```
  /// -> content | none | auto
  label: auto,
  /// Content to put inside of the individual.
  /// ```examplec
  /// >>> set text(font: "libertinus serif")
  /// >>> import pedigrypst: *
  /// pedigree(
  /// >>>   length: 4cm,
  /// >>>   generation-labels: false,
  ///   {
  ///     individual(1, 1, "male", in-label: none, label: `none`)
  ///     individual(1, 2, "female", in-label: [:3], label: `[:3]`)
  ///   }
  /// )
  /// ```
  /// -> content | none
  in-label: none,
  /// The #cetz-link("basics/styling", [CeTZ style]) to give to the outline of the individual. Must be a dictionary.
  /// ```examplec
  /// >>> set text(font: "libertinus serif")
  /// >>> import pedigrypst: *
  /// pedigree(
  /// >>>  length: 4cm,
  /// >>>  generation-labels: false,
  ///   {
  ///     individual(1, 1, "male", label: none, stroke-style: (paint: blue, dash: "dashed"))
  ///   }
  /// )
  /// ```
  /// -> dictionary
  stroke-style: (:),
  /// The color to give to the empty part of all individuals.
  /// ```examplec
  /// >>> set text(font: "libertinus serif")
  /// >>> import pedigrypst: *
  /// pedigree(
  /// >>>  length: 4cm,
  /// >>>  generation-labels: false,
  ///   {
  ///     individual(1, 1, "female", fill: "left", label: none, empty-style: yellow)
  ///   }
  /// )
  /// ```
  /// -> color | none | auto
  empty-style: auto,
  /// The color to give to the filled part of all individuals.
  /// ```examplec
  /// >>> set text(font: "libertinus serif")
  /// >>> import pedigrypst: *
  /// pedigree(
  /// >>>  length: 4cm,
  /// >>>  generation-labels: false,
  ///   {
  ///     individual(1, 1, "male", fill: "left", label: none, fill-style: orange)
  ///   }
  /// )
  /// ```
  /// -> color | none | auto
  fill-style: auto,
  /// The #cetz-link("basics/styling", [CeTZ style]) to give to all deceased crosses. Must be a dictionary.
  /// ```examplec
  /// >>> set text(font: "libertinus serif")
  /// >>> import pedigrypst: *
  /// pedigree(
  /// >>>  length: 4cm,
  /// >>>  generation-labels: false,
  ///   {
  ///     individual(1, 1, "female", dead: true, label: none, dead-style: (thickness: 4pt))
  ///   }
  /// )
  /// ```
  /// -> dictionary
  dead-style: (:),
  /// The #cetz-link("basics/styling", [CeTZ style]) to give to all adoption brackets. Must be a dictionary.
  /// ```examplec
  /// >>> set text(font: "libertinus serif")
  /// >>> import pedigrypst: *
  /// pedigree(
  /// >>>   length: 4cm,
  /// >>>   generation-labels: false,
  ///   {
  ///     individual(1, 1, "male", adopted: true, label: none, adopted-style: (paint: red))
  ///   }
  /// )
  /// ```
  /// -> dictionary
  adopted-style: (:),
  /// The #cetz-link("basics/styling", [CeTZ style]) to give to all propositi. Must be a dictionary.
  /// ```examplec
  /// >>> set text(font: "libertinus serif")
  /// >>> import pedigrypst: *
  /// pedigree(
  /// >>>   length: 4cm,
  /// >>>   generation-labels: false,
  ///   {
  ///     individual(1, 1, "female", propositus: true, label: none, propositus-style: (paint: blue.lighten(30%)))
  ///   }
  /// )
  /// ```
  /// -> dictionary
  propositus-style: (:),
) = {
  return ((
    type: "individual",
    generation: generation,
    ind-number: ind-number,
    sex: sex,
    fill: fill,
    dead: dead,
    adopted: adopted,
    propositus: propositus,
    label: label,
    in-label: in-label,
    stroke-style: stroke-style,
    empty-style: empty-style,
    fill-style: fill-style,
    dead-style: dead-style,
    adopted-style: adopted-style,
    propositus-style: propositus-style,
  ),)
}

/// Creates a lighter copy of an individual and shows its link to it using a curved line.
/// ```examplec
/// >>> set text(font: "libertinus serif")
/// >>> import pedigrypst: *
/// pedigree(
/// >>>   length: 2cm,
/// >>>   generation-labels: false,
///   {
///     individual(1, 1, "male")
///     individual(1, 2, "female")
///     individual(2, 1, "female")
///     individual(2, 2, "female")
///     individual(2, 3, "male")
///     duplicate(2, "i2-1", bezier: 0.42)
///     // right here ^
///     individual(3, 1, "female")
///     union("i1-1", "i1-2")
///     union("i2-2", "i2-3")
///     union("i2-3", "d1")
///     children("u1", "i2-1", "i2-2")
///     children("u2", "i3-1")
///     children("u3")
///   }
/// )
/// ```
#let duplicate(
  /// The generation to place the individual in. -> int
  generation,
  /// The individual reference to the individual this duplicate is duplicating. -> str
  individual,
  /// Determines the control point of the bezier for the curved line. If #raw("none", lang: "typc"), the curved line will not be drawn.
  ///
  /// If the duplicate is to the right of the duplicated individual, positive values will curve the line upwards. If the duplicate is to the left of the duplicated individual, positive values will curve the line downwards.
  /// ```examplec
  /// >>> set text(font: "libertinus serif")
  /// >>> import pedigrypst: *
  /// pedigree(
  /// >>>   length: 2cm,
  /// >>>   generation-labels: false,
  ///   {
  ///     individual(1, 1, "male", label: `0`)
  ///     duplicate(1, "i1-1", bezier: 0)
  ///     duplicate(1, "i1-4", bezier: 0)
  ///     individual(1, 4, "female", label: `0`)
  ///     individual(2, 1, "female", label: `1`)
  ///     duplicate(2, "i2-1", bezier: 1)
  ///     duplicate(2, "i2-4", bezier: 1)
  ///     individual(2, 4, "male", label: `1`)
  ///     individual(3, 1, "unknown", label: `none`)
  ///     duplicate(3, "i3-1", bezier: none)
  ///   }
  /// )
  /// ```
  /// -> int | float | none
  bezier: 0.5,
  /// The content to place next to the curve.
  /// ```examplec
  /// >>> set text(font: "libertinus serif")
  /// >>> import pedigrypst: *
  /// pedigree(
  /// >>>   length: 2cm,
  /// >>>   generation-labels: false,
  ///   {
  ///     individual(1, 1, "male")
  ///     duplicate(1, "i1-1", label: [Duplication])
  ///   }
  /// )
  /// ```
  /// -> content | none
  label: none,
  /// The #cetz-link("basics/styling", [CeTZ style]) to give to the curved line. Must be a dictionary. Defaults to being dashed.
  /// ```examplec
  /// >>> set text(font: "libertinus serif")
  /// >>> import pedigrypst: *
  /// pedigree(
  /// >>>   length: 4cm,
  /// >>>   generation-labels: false,
  ///   {
  ///     duplicate(1, "i1-1", bezier: -1, curve-style: (thickness: 8pt))
  ///     individual(1, 1, "male", label: none)
  ///   }
  /// )
  /// ```
  /// -> dictionary
  curve-style: (:),
  /// The amount to brighten the duplicate by.
  /// ```examplec
  /// >>> set text(font: "libertinus serif")
  /// >>> import pedigrypst: *
  /// pedigree(
  /// >>>   length: 4cm,
  /// >>>   generation-labels: false,
  ///   {
  ///     individual(1, 1, "male", fill: "filled")
  ///     duplicate(1, "i1-1", lightness: 10%)
  ///     duplicate(1, "i1-1", lightness: 80%)
  ///   }
  /// )
  /// ```
  /// -> ratio
  lightness: 50%,
) = {
  return ((
    type: "duplicate",
    generation: generation,
    individual: individual,
    bezier: bezier,
    label: label,
    curve-style: curve-style,
    lightness: lightness,
  ),)
}

/// Creates twins
/// ```examplec
/// >>> set text(font: "libertinus serif")
/// >>> import pedigrypst: *
/// pedigree(
/// >>>   length: 2cm,
/// >>>   generation-labels: false,
///   {
///     individual(1, 1, "male")
///     individual(1, 2, "female")
///     individual(2, 1, "female")
///     individual(2, 2, "female")
///     twins("i2-1", "i2-2", monozygotic: true)
///     union("i1-1", "i1-2")
///     children("u1", "t1")
/// })
/// ```
#let twins(
  /// Multiple individual or duplicate references to place in the twins. Can have more than two items. -> str
  ..individuals,
  /// Whether to draw the monozygocity indicator between each pair of twins. If not an array, it is converted into an array of length #raw("1", lang: "typc"). The length of the array should be one less than the number of twins.
  ///
  /// Each item of the array can be #raw("true", lang: "typc"), #raw("false", lang: "typc"), #raw("\"true\"", lang: "typc"), #raw("\"false\"", lang: "typc"), or #raw("\"unknown\"", lang: "typc"). If #raw("true", lang: "typc") or #raw("\"true\"", lang: "typc"), a horizontal line will be drawn near the sibling line. If #raw("\"unknown\"", lang: "typc"), a question mark will be drawn between the individuals.
  /// ```examplec
  /// >>> set text(font: "libertinus serif")
  /// >>> import pedigrypst: *
  /// pedigree(
  /// >>>   length: 2cm,
  /// >>>   generation-labels: false,
  ///   {
  ///     individual(1, 1, "male")
  ///     individual(1, 2, "female")
  ///     individual(2, 1, "male", in-label: `true`)
  ///     individual(2, 2, "male")
  ///     individual(2, 3, "female", in-label: text(`unknown`, size: 7pt))
  ///     individual(2, 4, "female")
  ///     twins("i2-1", "i2-2", monozygotic: (true,))
  ///     twins("i2-3", "i2-4", monozygotic: ("unknown",))
  ///     union("i1-1", "i1-2")
  ///     children("u1", "t1", "t2")
  ///   }
  /// )
  /// ```
  /// -> bool | str | array
  monozygotic: false,
  /// The label to place on the sibling line above the center of the twins.
  /// ```examplec
  /// >>> set text(font: "libertinus serif")
  /// >>> import pedigrypst: *
  /// pedigree(
  /// >>>   length: 2cm,
  /// >>>   generation-labels: false,
  ///   {
  ///     individual(1, 1, "male", label: none)
  ///     individual(2, 1, "female")
  ///     individual(2, 2, "male")
  ///     individual(2, 3, "male")
  ///     twins("i2-2", "i2-3", label: [Twins])
  ///     children("i1-1", "i2-1", "t1")
  ///   }
  /// )
  /// ```
  /// -> content | none
  label: none,
  /// The #cetz-link("basics/styling", [CeTZ style]) to draw all of the twin lines for these twins with. Must be a dictionary.
  /// ```examplec
  /// >>> set text(font: "libertinus serif")
  /// >>> import pedigrypst: *
  /// pedigree(
  /// >>>   length: 2cm,
  /// >>>   generation-labels: false,
  ///   {
  ///     individual(1, 1, "male")
  ///     individual(2, 1, "female")
  ///     individual(2, 2, "male")
  ///     twins("i2-1", "i2-2", style: (paint: red))
  ///     children("i1-1", "t1")
  ///   }
  /// )
  /// ```
  /// -> dictionary
  style: (:),
  /// The #cetz-link("basics/styling", [CeTZ style]) to draw the monozygocity indicators for these twins with. Must be a dictionary.
  /// ```examplec
  /// >>> set text(font: "libertinus serif")
  /// >>> import pedigrypst: *
  /// pedigree(
  /// >>>   length: 2cm,
  /// >>>   generation-labels: false,
  ///   {
  ///     individual(1, 1, "male")
  ///     individual(2, 1, "female")
  ///     individual(2, 2, "male")
  ///     twins("i2-1", "i2-2", monozygotic: true, monozygotic-style: (paint: green, thickness: 2pt))
  ///     children("i1-1", "t1")
  ///   }
  /// )
  /// ```
  /// -> dictionary
  monozygotic-style: (:),
) = {
  if type(monozygotic) != array {
    monozygotic = (monozygotic,)
  }

  return ((
    type: "twin",
    individuals: individuals.pos(),
    monozygotic: monozygotic,
    label: label,
    style: style,
    monozygotic-style: monozygotic-style,
  ),)
}

/// Creates a union between two individuals. It does not specify the children, only the two individuals.
/// ```examplec
/// >>> set text(font: "libertinus serif")
/// >>> import pedigrypst: *
/// pedigree(
/// >>>   length: 4cm,
/// >>>   generation-labels: false,
///   {
///     individual(1, 1, "male")
///     individual(1, 2, "female")
///     union("i1-1", "i1-2")
///   }
/// )
/// ```
#let union(
  /// The first individual reference of the union. -> str
  individual-1,
  /// The second individual reference of the union. -> str
  individual-2,
  /// Whether to draw the union with double lines, indicating a #link("https://en.wikipedia.org/wiki/Consanguinity", [consanguineous]) relationship.
  /// ```examplec
  /// >>> set text(font: "libertinus serif")
  /// >>> import pedigrypst: *
  /// pedigree(
  /// >>>   length: 4cm,
  /// >>>   generation-labels: false,
  ///   {
  ///     individual(1, 1, "male")
  ///     individual(1, 2, "female")
  ///     union("i1-1", "i1-2", consanguineous: true)
  ///   }
  /// )
  /// ```
  /// -> bool
  consanguineous: false,
  /// Whether to draw a cross indicating divorce through the union.
  ///
  /// Can be #raw("true", lang: "typc"), #raw("false", lang: "typc"), #raw("0", lang: "typc"), #raw("1", lang: "typc"), or #raw("2", lang: "typc"). If it is #raw("true", lang: "typc") or #raw("1", lang: "typc"), then one cross will be drawn. If it is #raw("2", lang: "typc"), then two crosses will be drawn.
  /// ```examplec
  /// >>> set text(font: "libertinus serif")
  /// >>> import pedigrypst: *
  /// pedigree(
  /// >>>   length: 3cm,
  /// >>>   generation-labels: false,
  ///   {
  ///     individual(1, 1, "male", in-label: `true`)
  ///     individual(1, 2, "female")
  ///     individual(2, 1, "female", in-label: `2`)
  ///     individual(2, 2, "male")
  ///     union("i1-1", "i1-2", divorced: true)
  ///     union("i2-1", "i2-2", divorced: 2)
  ///   }
  /// )
  /// ```
  /// -> bool | int
  divorced: false,
  /// The label to place above the union line.
  /// ```examplec
  /// >>> set text(font: "libertinus serif")
  /// >>> import pedigrypst: *
  /// pedigree(
  /// >>>   length: 3cm,
  /// >>>   generation-labels: false,
  ///   {
  ///     individual(1, 1, "male")
  ///     individual(1, 2, "male")
  ///     union("i1-1", "i1-2", label: [Gay\*])
  ///   }
  /// )
  /// ```
  /// -> content | none
  label: none,
  /// The #cetz-link("basics/styling", [CeTZ style]) to give to the union line of this unions. Must be a dictionary.
  /// ```examplec
  /// >>> set text(font: "libertinus serif")
  /// >>> import pedigrypst: *
  /// pedigree(
  /// >>>   length: 4cm,
  /// >>>   generation-labels: false,
  ///   {
  ///     individual(1, 1, "female")
  ///     individual(1, 2, "male")
  ///     union("i1-1", "i1-2", style: (thickness: 8pt))
  ///   }
  /// )
  /// ```
  /// -> dictionary
  style: (:),
  /// The #cetz-link("basics/styling", [CeTZ style]) to give to the separation indicators of this unions. Must be a dictionary.
  /// ```examplec
  /// >>> set text(font: "libertinus serif")
  /// >>> import pedigrypst: *
  /// pedigree(
  /// >>>   length: 4cm,
  /// >>>   generation-labels: false,
  ///   {
  ///     individual(1, 1, "female")
  ///     individual(1, 2, "male")
  ///     union("i1-1", "i1-2", divorced: 2, divorced-style: (paint: green))
  ///   }
  /// )
  /// ```
  /// -> dictionary
  divorced-style: (:)
) = {
  return ((
    type: "union",
    individual-1-id: individual-1,
    individual-2-id: individual-2,
    consanguineous: consanguineous,
    divorced: divorced,
    label: label,
    style: style,
    divorced-style: divorced-style,
  ),)
}

/// Creates a line of descent, a sibling line, and child lines from a union or individual to any number of children.
/// ```examplec
/// >>> set text(font: "libertinus serif")
/// >>> import pedigrypst: *
/// pedigree(
/// >>>   length: 2cm,
/// >>>   generation-labels: false,
///   {
///     individual(1, 1, "male", label: none)
///     individual(2, 1, "female")
///     individual(2, 2, "female")
///     individual(2, 3, "male")
///     children("i1-1", "i2-1", "i2-2", "i2-3")
///   }
/// )
/// ```
#let children(
  /// A union reference, individual reference, or duplicate reference that specifies where the line of descent should be drawn from. -> str
  parents,
  /// Multiple individual references, duplicate references, or twin references that specify what is a child of the parents. If empty, only the line of descent and a horizontal line indicating no children is drawn. -> str
  ..children,
  /// If no children are present, this specifies whether to draw an additional horizontal line beneath the no-children indicator.
  /// ```examplec
  /// >>> set text(font: "libertinus serif")
  /// >>> import pedigrypst: *
  /// pedigree(
  /// >>>   length: 4cm,
  /// >>>   generation-labels: false,
  ///   {
  ///     individual(1, 1, "male", label: none, in-label: `false`)
  ///     individual(1, 2, "female", label: none, in-label: `true`)
  ///     children("i1-1", infertile: false)
  ///     children("i1-2", infertile: true)
  ///   }
  /// )
  /// ```
  /// -> bool
  infertile: false,
  /// The content to put on the sibling line (if possible) next to the line of descent.
  /// ```examplec
  /// >>> set text(font: "libertinus serif")
  /// >>> import pedigrypst: *
  /// pedigree(
  /// >>>   length: 3cm,
  /// >>>   generation-labels: false,
  ///   {
  ///     individual(1, 1, "male")
  ///     individual(1, 2, "female")
  ///     individual(2, 1, "unknown")
  ///     individual(2, 2, "male")
  ///     union("i1-1", "i1-2")
  ///     children("u1", "i2-1", "i2-2", label: [Hello])
  ///   }
  /// )
  /// ```
  /// -> content | none
  label: none,
  /// The #cetz-link("basics/styling", [CeTZ style]) to give to the no children indicator for this children. Must be a dictionary.
  /// ```examplec
  /// >>> set text(font: "libertinus serif")
  /// >>> import pedigrypst: *
  /// pedigree(
  /// >>>   length: 3cm,
  /// >>>   generation-labels: false,
  ///   {
  ///     individual(1, 1, "male")
  ///     individual(1, 2, "female")
  ///     union("i1-1", "i1-2")
  ///     children("u1", infertile: true, no-children-style: (paint: red))
  ///   }
  /// )
  /// ```
  /// -> dictionary
  no-children-style: (:),
  /// The #cetz-link("basics/styling", [CeTZ style]) to give to the line of descent. Must be a dictionary.
  /// ```examplec
  /// >>> set text(font: "libertinus serif")
  /// >>> import pedigrypst: *
  /// pedigree(
  /// >>>   length: 2.5cm,
  /// >>> generation-labels: false,
  ///   {
  ///     individual(1, 1, "male")
  ///     individual(1, 2, "female")
  ///     individual(2, 1, "female")
  ///     individual(2, 2, "male")
  ///     union("i1-1", "i1-2")
  ///     children("u1", "i2-1", "i2-2", line-of-descent-style: (thickness: 4pt))
  ///   }
  /// )
  /// ```
  /// -> dictionary
  line-of-descent-style: (:),
  /// The #cetz-link("basics/styling", [CeTZ style]) to give to the sibling line. Must be a dictionary.
  /// ```examplec
  /// >>> set text(font: "libertinus serif")
  /// >>> import pedigrypst: *
  /// pedigree(
  /// >>>   length: 2.5cm,
  /// >>>   generation-labels: false,
  ///   {
  ///     individual(1, 1, "male")
  ///     individual(1, 2, "female")
  ///     individual(2, 1, "female")
  ///     individual(2, 2, "male")
  ///     union("i1-1", "i1-2")
  ///     children("u1", "i2-1", "i2-2", sibling-line-style: (thickness: 4pt))
  ///   }
  /// )
  /// ```
  /// -> dictionary
  sibling-line-style: (:),
  /// The #cetz-link("basics/styling", [CeTZ style]) to give to the child line. The styles must be dictionaries. If a dictionary is given, the style will be applied to all child lines. If an array is given with the same length as the number of children, each style will be applied to the corresponding child line.
  /// ```examplec
  /// >>> set text(font: "libertinus serif")
  /// >>> import pedigrypst: *
  /// pedigree(
  /// >>>   length: 2.5cm,
  /// >>>   generation-labels: false,
  ///   {
  ///     individual(1, 1, "male")
  ///     individual(1, 2, "female")
  ///     individual(2, 1, "female")
  ///     individual(2, 2, "male")
  ///     individual(3, 1, "female")
  ///     individual(3, 2, "male")
  ///     individual(4, 1, "male")
  ///     individual(4, 2, "female", adopted: "alt")
  ///     union("i1-1", "i1-2")
  ///     union("i3-1", "i3-2")
  ///     children("u1", "i2-1", "i2-2", child-line-style: (paint: purple, thickness: 3pt))
  ///     children("u2", "i4-1", "i4-2", child-line-style: ((:), (dash: "dashed")))
  ///   }
  /// )
  /// ```
  /// -> dictionary
  child-line-style: (:),
) = {
  if type(child-line-style) != array {
    child-line-style = (child-line-style,) * children.pos().len()
  }

  return ((
    type: "children",
    parents-id: parents, // union id or individual id
    children: children.pos(),
    infertile: infertile,
    label: label,
    no-children-style: no-children-style,
    line-of-descent-style: line-of-descent-style,
    sibling-line-style: sibling-line-style,
    child-line-style: child-line-style,
  ),)
}
