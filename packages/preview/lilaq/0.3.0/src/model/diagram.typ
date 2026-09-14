
#import "../process-styles.typ": update-stroke, process-margin, process-grid-arg
#import "../assertations.typ"
#import "../logic/scale.typ"
#import "../logic/transform.typ": create-trafo
#import "legend.typ": legend as lq-legend, _place-legend-with-bounds
#import "grid.typ": grid as lq-grid

#import "axis.typ": axis, draw-axis, _axis-compute-limits, _axis-generate-ticks
#import "../algorithm/ticking.typ"
#import "../bounds.typ": *
#import "title.typ": title as lq-title
#import "label.typ": label as lq-label
#import "../utility.typ": if-auto

#let debug = false
#import "../style/styling.typ": init as cycle-init, style, process-cycles-arg
#import "../style/map.typ": petroff10
#import "../libs/elembic/lib.typ" as e



/// Creates a new diagram. 
/// 
/// -> lq.diagram
#let diagram(
  
  /// The width of the diagram's data area (excluding axes, labels etc.). 
  /// -> length
  width: 6cm,
  
  /// The height of the diagram's data area (excluding axes, labels, title etc.). 
  /// -> length
  height: 4cm,

  /// The title for the diagram. Use a @title object for more options. 
  /// -> lq.title | str | content | none
  title: none,

  /// Options to pass to the @legend constructor. If set to `none`, no legend is
  /// shown.
  /// 
  /// Alternatively, a legend with entirely custom entries can be created and 
  /// given here. 
  /// -> none | dictionary | lq.legend
  legend: (:),

  /// Data limits along the $x$-axis. Expects `auto` or a tuple `(min, max)` 
  /// where `min` and `max` may individually be `auto`. Also see @axis.lim. 
  /// -> auto | array
  xlim: auto,
  
  /// Data limits along the $y$-axis. Expects `auto` or a tuple `(min, max)` 
  /// where `min` and `max` may individually be `auto`. Also see @axis.lim. 
  /// -> auto | array
  ylim: auto,

  /// Label for the $x$-axis. Use a @label object for more options. 
  /// -> lq.label | content
  xlabel: none,

  /// Label for the $y$-axis. Use a @label object for more options. 
  /// -> lq.label | content
  ylabel: none,

  /// Options to apply to the grid. A `stroke`, `color`, or `length` argument 
  /// directly sets the grid stroke while a `dictionary` with the possible keys
  /// `stroke`, `stroke-sub`, and `z-index` gives more fine-grained control. 
  /// Setting this parameter to `none` removes the grid entirely. 
  /// See @grid for more details. 
  /// -> auto | none | dictionary | stroke | color | length
  grid: auto,

  /// Sets the scale of the $x$-axis. This may be a @scale object or the name
  /// of one of the built-in scales `"linear"`, `"log"`, `"symlog"`.
  /// -> str | lq.scale
  xscale: "linear",
  
  /// Sets the scale of the $y$-axis. This may be a @scale object or the name
  /// of one of the built-in scales `"linear"`, `"log"`, `"symlog"`.
  /// -> str | lq.scale
  yscale: "linear",

  /// Configures the $x$-axis through a dictionary of arguments to pass to the 
  /// constructor of the axis. See @axis for available options. 
  /// -> none | dictionary
  xaxis: (:),
  
  /// Configures the $y$-axis through a dictionary of arguments to pass to the
  /// constructor of the axis. See @axis for available options. 
  /// -> none | dictionary
  yaxis: (:),

  /// Configures the automatic margins of the diagram around the data. If set 
  /// to `0%`, the outer-most data points align tightly with the edges of the 
  /// diagram (as long as the axis limits are left at `auto`). Otherwise, the
  /// margins are computed in percent of the covered range along an axis (in
  /// scaled coordinates). 
  /// 
  /// The margins can be set individually for each side by passing a dictionary
  /// with the possible keys
  /// - `left`, `right`, `top`, `bottom` for addressing individual sides,
  /// - `x`, `y` for left/right and top/bottom combined sides, and
  /// - `rest` for all sides not specified by any of the above. 
  /// 
  /// -> ratio | dictionary
  margin: 6%,
  
  /// Style cycle to use for this diagram. Check out the 
  /// #link("tutorials/cycles")[cycles tutorial] for more information. 
  /// The elements of a cycle array should either be 
  /// - all functions as described in the tutorial, or
  /// - all of type `color` (e.g., one of the maps under `lq.color.map`), or
  /// - all of type `dictionary` with possible keys `color`, `stroke`, and 
  ///   `mark`. 
  ///   
  /// -> array
  cycle: petroff10,

  /// How to fill the background of the data area. 
  /// -> none | color | gradient | tiling 
  fill: none,

  /// Plot objects like @plot, @bar, @scatter, @contour etc. and additional 
  /// @axis objects. 
  /// -> any
  ..children

) = {}



#let axis-constructor = axis

#let create-principle-axis(
  axis, lim, scale,
  kind: "x",
  label,
  plots,
  margin,
  it
) = {
  if axis == none { axis = (hidden: true) }

  if type(axis) == dictionary {
    axis = axis-constructor(kind: kind, label: label, scale: scale, lim: lim, ..axis)
  }
  axis.plots = plots

  let margin = if kind == "x" {
    (lower-margin: margin.left, upper-margin: margin.right)
  } else {
    (lower-margin: margin.bottom, upper-margin: margin.top)
  }

  axis.lim = _axis-compute-limits(axis, is-independant: true, ..margin)

  
  let normalized-scale-trafo = create-trafo(axis.scale.transform, ..axis.lim)
  axis.normalized-scale-trafo = normalized-scale-trafo
  
  if kind == "x" {
    axis.transform = x => normalized-scale-trafo(x) * it.width
  } else {
    axis.transform = y => it.height * (1 - normalized-scale-trafo(y))
  }
  
  return axis
}



#let draw-diagram(it) = {
  set math.equation(numbering: none)
  set curve(stroke: .7pt)
  set line(stroke: .7pt)


  // show: e.show_(
  //   lq-label.with(kind: "y"), 
  //   it => {
  //     set rotate(-90deg)
  //     it
  //   }
  // )
  // Either a plot object or a dict (axis-id: int, plot: dict). 
  let plots = () 
  // solely used for computing limits
  let (xplots, yplots) = ((), ()) 
  // all addtional axes
  let axes = ()

  for child in it.children {
    if type(child) == dictionary {
      if child.at("type", default: "") == "axis" { // an axis
        axes.push(child)
        let axis-id = axes.len() - 1
        if child.plots.len() > 0 {
          plots += child.plots.map(plot => (axis-id: axis-id, plot: plot)) 
          if child.kind == "x" {
            yplots += child.plots
          } else {
            xplots += child.plots
          }
        }
      } else { // just a regular plot
        yplots.push(child)
        xplots.push(child)
        plots.push(child)
      }
    }
  }

  let margin = process-margin(it.margin)

  let xaxis = create-principle-axis(
    kind: "x",
    it.xaxis, it.xlim, it.xscale,
    it.xlabel, xplots, margin, it
  )
  let yaxis = create-principle-axis(
    kind: "y",
    it.yaxis, it.ylim, it.yscale,
    it.ylabel, yplots, margin, it
  )



  
  
  let transform(x, y) = (
    (xaxis.transform)(x), 
    (yaxis.transform)(y), 
  )

  
  let maybe-transform(x, y) = {
    if type(x) in (int, float) { x = (xaxis.transform)(x) }
    if type(y) in (int, float) { y = (yaxis.transform)(y) - it.height }
    return (x, y)
  }
  yaxis.translate = maybe-transform(..yaxis.translate)
  xaxis.translate = maybe-transform(..xaxis.translate)

  let axes-transforms = (none,) * axes.len()
  
  for i in range(axes.len()) {
    let axis = axes.at(i)
    let model-axis = if axis.kind == "x" { xaxis } else { yaxis }
    let has-auto-lim = axis.lim == auto
    let has-auto-lim = false
    let axes-margin = if axis.kind == "x" { 
      (lower-margin: margin.left, upper-margin: margin.right)
    } else {
      (lower-margin: margin.bottom, upper-margin: margin.top)
    }
    axes.at(i).lim = _axis-compute-limits(axis, default-lim: model-axis.lim, ..axes-margin)

    if axis.plots.len() > 0 {
      let other-axis = if axis.kind == "x" {yaxis} else {xaxis}
      let transform
      let scale-trafo = create-trafo(axis.scale.transform, ..axes.at(i).lim)
      if axis.kind == "x" {
        let normalized-x-trafo = scale-trafo
        axes.at(i).transform = x => normalized-x-trafo(x) * it.width
        transform = (x, y) => ((axes.at(i).transform)(x), (yaxis.transform)(y))
      } else {
        let normalized-y-trafo = scale-trafo
        axes.at(i).transform = y => (1 - normalized-y-trafo(y)) * it.height
        transform = (x, y) => ((xaxis.transform)(x), (axes.at(i).transform)(y))
      }
      axes-transforms.at(i) = transform
    } else {
      axes.at(i).transform = if has-auto-lim {model-axis.transform} else {
        let trafo = x => (model-axis.normalized-scale-trafo)((axis.functions.inv)(x))
        if axis.kind == "y" {
          y => it.height * (1 - trafo(y))
        } else {
          x => it.width * trafo(x)
        }
      }
    }
  }

  
  
  e.get(e-get => {
  
  let axis-info = (
    x: (ticking: _axis-generate-ticks(xaxis, length: it.width)), 
    y: (ticking: _axis-generate-ticks(yaxis, length: it.height)), 
    rest: ((:),) * axes.len()
  )
    

  let bounds = (left: 0pt, right: it.width, top: 0pt, bottom: it.height)
  


    
  let diagram = box(
    width: it.width, height: it.height, 
    inset: 0pt, stroke: none, fill: it.fill,
    {
    set align(top + left) // sometimes alignment is messed up


    let update-bounds = update-bounds.with(width: it.width, height: it.height)
    

    let artists = ()
    artists.push((
      content: {
        let x-transform = tick => transform(tick, 1).at(0)
        let y-transform = tick => transform(1, tick).at(1)
        lq-grid(
          axis-info.x.ticking.subticks.map(x-transform),
          true,
          kind: "x",
          ..process-grid-arg(it.grid)
        )
        lq-grid(
          axis-info.y.ticking.subticks.map(y-transform),
          true,
          kind: "y",
          ..process-grid-arg(it.grid)
        )
        lq-grid(
          axis-info.x.ticking.ticks.map(x-transform),
          false,
          kind: "x",
          ..process-grid-arg(it.grid)
        )
        lq-grid(
          axis-info.y.ticking.ticks.map(y-transform),
          false,
          kind: "y",
          ..process-grid-arg(it.grid)
        )
      }, z: e-get(lq-grid).z-index
    ))

    let legend-entries = ()

    let cycle = process-cycles-arg(it.cycle)


    let cycle-index = 0
    for plot in plots {
      let transform = transform

      if type(plot) == dictionary and "axis-id" in plot {
        transform = axes-transforms.at(plot.axis-id)
        plot = plot.plot
      }


      let takes-part-in-cycle = not plot.at("ignores-cycle", default: true)
      let cycle-style = cycle.at(calc.rem(cycle-index, cycle.len()))

      let plotted-plot = {
        show: cycle-init
        show: cycle-style
        (plot.plot)(plot, transform)
      }
      
      if takes-part-in-cycle {
        cycle-index += 1
      }

      if plot.at("clip", default: true) { 
        plotted-plot = place(box(width: it.width, height: it.height, clip: true, plotted-plot))
      }
      artists.push((content: plotted-plot, z: plot.at("z-index", default: 2)))

      
      if "legend" in plot and plot.label != none {
        plot.make-legend = true
        let legend-trafo(x, y) = {
          (x * 100%, (1 - y) * 100%)
        }
        let handle = {
          show: cycle-init
          show: cycle-style
          (plot.plot)(plot, legend-trafo)
        }
        legend-entries.push((
          box(width: 2em, height: .7em, handle),
          plot.label
        ))
      }
    }


    let show-bounds(bounds, clr: red) = {
      place(dx: bounds.left, dy: bounds.top, rect(width: bounds.right - bounds.left, height: bounds.bottom - bounds.top, fill: clr))
    }
    if not debug {
      show-bounds = (args, clr: red) => none
    }

    let minor-axis-style = (
      inset: 2pt,
      outset: 0pt,
      type: "minor"
    )
    let major-axis-style = (
      inset: 4pt,
      outset: 0pt,
      type: "major"
    )
    let get-axis-args(axis) = {
      if axis.kind == "x" { 
        (length: it.width)
      } else {
        (length: it.height)
      }
    }
    let (xaxis-, max-xtick-size) = draw-axis(xaxis, axis-info.x.ticking, major-axis-style, e-get: e-get)
    artists.push((content: xaxis-, z: 20))

    let (yaxis-, max-ytick-size) = draw-axis(yaxis, axis-info.y.ticking, major-axis-style, e-get: e-get)
    artists.push((content: yaxis-, z: 20))
 
    if type(max-ytick-size) == array {
      for b in max-ytick-size {
        bounds = update-bounds(bounds, b)
        show-bounds(b, clr: rgb("#22AA2222"))
      }
      for b in max-xtick-size {
        bounds = update-bounds(bounds, b)
        show-bounds(b, clr: rgb("#AAAA2222"))
      }
    } else {
      padding.left = max-ytick-size
      padding.bottom = max-xtick-size
    }

    for axis in axes {
      let ticking = _axis-generate-ticks(axis, ..get-axis-args(axis))
      let (axis-, axis-bounds) = draw-axis(axis, ticking, major-axis-style, e-get: e-get)
      artists.push((content: axis-, z: 20))

      
      for b in axis-bounds {
        bounds = update-bounds(bounds, b)
        show-bounds(b, clr: rgb("#2222AA22"))
      }
    }
    
    let get-settable-field(element, object, field) = {
      e.fields(object).at(field, default: e-get(element).at(field))
    }

    if it.title != none {
      let title = it.title
      if e.eid(title) != e.eid(lq-title) {
        title = lq-title(title)
      }

      let position = get-settable-field(lq-title, title, "position")
      let dx = get-settable-field(lq-title, title, "dx")
      let dy = get-settable-field(lq-title, title, "dy")
      let pad = get-settable-field(lq-title, title, "pad")

      let wrapper = if position in (top, bottom) {
        box.with(width: it.width)
      } else if position in (left, right) {
        box.with(height: it.height)
      }

      let body = wrapper(title)
      
      let (title, b) = place-with-bounds(body, alignment: position, dx: dx, dy: dy, pad: pad)
      
      artists.push((content: title, z: 20))
      bounds = update-bounds(bounds, b)
    }

    
    if it.legend != none and (legend-entries.len() > 0 or e.eid(it.legend) == e.eid(lq-legend)) {
      let (legend-content, legend-bounds) = _place-legend-with-bounds(it.legend, legend-entries, e-get)

      artists.push((content: legend-content, z: e-get(lq-legend).z-index))

      bounds = update-bounds(bounds, legend-bounds)
    }

    artists.sorted(key: artist => artist.z).map(artist => artist.content).join()
  })
  bounds.bottom -= it.height
  bounds.right -= it.width
  bounds.left *= -1
  bounds.top *= -1
  box(box(inset: bounds, diagram, stroke: if debug {.1pt} else {0pt}), baseline: bounds.bottom)
})
}

#let folding-dict = e.types.wrap(dictionary, fold: old-fold => (a, b) => a + b)

#let diagram = e.element.declare(
  "diagram",
  prefix: "lilaq",

  display: draw-diagram, 

  fields: (
    e.field("children", e.types.any, required: true),
    e.field("width", length, default: 6cm),
    e.field("height", length, default: 4cm),
    e.field("title", e.types.union(none, str, content, lq-title), default: none),
    e.field("legend", e.types.option(e.types.union(dictionary, lq-legend)), default: (:)),
    e.field("xlim", e.types.wrap(e.types.union(auto, array), fold: none), default: auto),
    e.field("ylim", e.types.wrap(e.types.union(auto, array), fold: none), default: auto),
    e.field("xlabel", e.types.option(e.types.union(lq-label, str, content)), default: none),
    e.field("ylabel", e.types.option(e.types.union(lq-label, str, content)), default: none),
    e.field("grid", e.types.union(auto, none, dictionary, stroke, color, length), default: auto),
    e.field("xscale", e.types.union(str, dictionary), default: "linear"),
    e.field("yscale", e.types.union(str, dictionary), default: "linear"),
    e.field("xaxis", e.types.option(folding-dict), default: (:)),
    e.field("yaxis", e.types.option(folding-dict), default: (:)),
    e.field("margin", e.types.union(ratio, dictionary), default: 6%),
    e.field("cycle", e.types.wrap(e.types.array(e.types.union(function, color, dictionary)), fold: none), default: petroff10),
    e.field("fill", e.types.option(e.types.paint), default: none),
  ),

  parse-args: (default-parser, fields: none, typecheck: none) => (args, include-required: false) => {
    let args = if include-required {
      let values = args.pos()
      arguments(values, ..args.named())
    } else if args.pos() == () {
      args
    } else {
      assert(false, message: "element 'diagram': unexpected positional arguments\n  hint: these can only be passed to the constructor")
    }

    default-parser(args, include-required: include-required)
  },
)
