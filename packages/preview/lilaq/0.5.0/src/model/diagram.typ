
#import "../assertations.typ"
#import "../utility.typ": if-auto
#import "../bounds.typ": update-bounds, place-with-bounds
#import "../process-styles.typ": update-stroke, process-margin, process-grid-arg, twod-ify-alignment
#import "../logic/process-coordinates.typ": transform-point


#import "legend.typ": legend as lq-legend, _place-legend-with-bounds
#import "grid.typ": grid as lq-grid
#import "title.typ": title as lq-title, _place-title-with-bounds
#import "label.typ": label as lq-label
#import "axis.typ": axis as lq-axis, draw-axis, _axis-compute-limits, _axis-generate-ticks

#import "../logic/transform.typ": create-trafo

#import "../style/styling.typ": init as cycle-init, style, process-cycles-arg
#import "../style/map.typ": petroff10
#import "@preview/elembic:1.1.1" as e

#let debug = false



/// Creates a new diagram. 
/// 
/// -> lq.diagram
#let diagram(
  
  /// The width of the diagram. This can be
  /// - A `length`; in this case, it defines just the width of the data area,
  ///   excluding axes, labels, title etc.
  /// - A `ratio` or `relative` where the ratio part is relative to the width 
  ///   of the parent that the diagram is placed in. This is not allowed if the
  ///   parent has an unbounded width, e.g., a page with `width: auto`.  
  /// -> length | relative
  width: 6cm,
  
  /// The height of the diagram. This can be
  /// - A `length`; in this case, it defines just the height of the data area,
  ///   excluding axes, labels, title etc.
  /// - A `ratio` or `relative` where the ratio part is relative to the height 
  ///   of the parent that the diagram is placed in. This is not allowed if the
  ///   parent has an unbounded height, e.g., a page with `height: auto`.  
  /// -> length | relative
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
  /// of one of the built-in scales `"linear"`, `"log"`, `"symlog"`, and 
  /// `"datetime"`. 
  /// 
  /// If left at `auto`, the scale will be set to `"datetime"` if any of the 
  /// plots uses datetime coordinates and `"linear"` otherwise. 
  /// -> auto | str | lq.scale
  xscale: auto,
  
  /// Sets the scale of the $y$-axis. This may be a @scale object or the name
  /// of one of the built-in scales `"linear"`, `"log"`, `"symlog"`, and 
  /// `"datetime"`. 
  /// 
  /// If left at `auto`, the scale will be set to `"datetime"` if any of the 
  /// plots uses datetime coordinates and `"linear"` otherwise. 
  /// -> auto | str | lq.scale
  yscale: auto,

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
    axis = lq-axis(kind: kind, label: label, scale: scale, lim: lim, ..axis, ..plots)
  }

  let margin = if kind == "x" {
    (lower-margin: margin.left, upper-margin: margin.right)
  } else {
    (lower-margin: margin.bottom, upper-margin: margin.top)
  }

  axis.lim = _axis-compute-limits(axis, is-independant: true, ..margin)

  
  let normalized-trafo = create-trafo(axis.scale.transform, ..axis.lim)
  axis.normalized-transform = normalized-trafo
  
  axis
}


#let fill-in-transforms(axes, width, height) = {
  let xaxis = axes.at(0)
  let yaxis = axes.at(1)
  axes.map(axis => {
    let normalized-trafo = if axis.plots.len() > 0 { // is independent axis
      create-trafo(axis.scale.transform, ..axis.lim)
    } else { // is dependent axis
      let model-axis = if axis.kind == "x" { xaxis } else { yaxis }
      a => (model-axis.normalized-transform)((axis.functions.inv)(a))
    }

    axis.transform = if axis.kind == "x" {
      x => normalized-trafo(x) * width
    } else {
      y => (1 - normalized-trafo(y)) * height
    }
    axis
  })
}

#let generate-grid(axis-info, xaxis, yaxis, grid: auto) = {
  grid = process-grid-arg(grid)

  lq-grid(
    axis-info.x.subticks.map(xaxis.transform),
    sub: true,
    kind: "x",
    ..grid
  )
  lq-grid(
    axis-info.y.subticks.map(yaxis.transform),
    sub: true,
    kind: "y",
    ..grid
  )
  lq-grid(
    axis-info.x.ticks.map(xaxis.transform),
    sub: false,
    kind: "x",
    ..grid
  )
  lq-grid(
    axis-info.y.ticks.map(yaxis.transform),
    sub: false,
    kind: "y",
    ..grid
  )
}


#let generate-legend(legend, legend-entries, e-get) = {
  if legend != none and (legend-entries.len() > 0 or e.eid(legend) == e.eid(lq-legend)) {
    let (legend-content, legend-bounds) = _place-legend-with-bounds(
      legend, legend-entries, e-get
    )

    (
      content: legend-content,
      bounds: legend-bounds
    )
  }
}



#let generate-plots(
  plots, cycle, width, height, axes, only-bounds: false
) = {
  let (xaxis, yaxis) = axes.slice(0, 2)

  let transform(x, y) = (
    (xaxis.transform)(x), 
    (yaxis.transform)(y), 
  )
  cycle = process-cycles-arg(cycle)

  let update-bounds = update-bounds.with(width: width, height: height)

  let bounds = (left: 0pt, right: width, top: 0pt, bottom: height)
  let artists = ()
  let legend-entries = ()
  let cycle-index = 0

  for plot in plots {
    let transform = transform

    if type(plot) == dictionary and "axis-id" in plot {
      let axis = axes.at(plot.axis-id + 2)
      transform = if axis.kind == "x" {
        (x, y) => ((axis.transform)(x), (yaxis.transform)(y))
      } else {
        (x, y) => ((xaxis.transform)(x), (axis.transform)(y))
      }
      plot = plot.plot
    }

    if plot.at("id", default: none) == "place" and not plot.clip {
      let (px, py) = transform-point(plot.x, plot.y, transform)
      let (_, place-bounds) = place-with-bounds(
        plot.body, dx: px, dy: py, 
        content-alignment: twod-ify-alignment(plot.align)
      )
      bounds = update-bounds(bounds, place-bounds)
    }


    let takes-part-in-cycle = not plot.at("ignores-cycle", default: true)
    let cycle-style = cycle.at(calc.rem(cycle-index, cycle.len()))

    if not only-bounds {
      let plotted-plot = {
        show: cycle-init
        show: cycle-style
        (plot.plot)(plot, transform)
      }
      
      if takes-part-in-cycle {
        cycle-index += 1
      }

      if plot.at("clip", default: true) { 
        plotted-plot = place(
          box(width: width, height: height, clip: true, plotted-plot)
        )
      }
      artists.push((content: plotted-plot, z: plot.at("z-index", default: 2)))
    }

    
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


  (
    legend-entries: legend-entries,
    artists: artists,
    bounds: bounds
  )
}




#let attempt-layout(
  width, height, 
  it: (:), axes: (), plots: (), e-get: none, 
  auto-height: true, auto-width: true,
  available-size: (0pt, 0pt)
) = {
  axes = fill-in-transforms(axes, width, height)
  let (xaxis, yaxis) = axes.slice(0, 2)

  let get-settable-field(element, object, field) = {
    e.fields(object).at(field, default: e-get(element).at(field))
  }

  let bounds = (left: 0pt, right: width, top: 0pt, bottom: height)
  let update-bounds = update-bounds.with(width: width, height: height)

  let tickings = axes.map(axis => 
    _axis-generate-ticks(
      axis, 
      length: if axis.kind == "x" { width } else { height }
    )
  )

  for (axis, ticking) in axes.zip(tickings) {
    let (_, axis-bounds) = draw-axis(
      axis, ticking, e-get: e-get, orthogonal-axis-transform: (if axis.kind == "x" { yaxis} else {xaxis}).transform
    )
    bounds = axis-bounds.fold(bounds, update-bounds)
  }

  if it.title != none {
    let (_, title-bounds) = _place-title-with-bounds(
      it.title, get-settable-field, width, height
    )
    bounds = update-bounds(bounds, title-bounds)
  }

  let (legend-entries, bounds: plot-bounds) = generate-plots(
    plots, it.cycle, width, height, 
    axes, only-bounds: true
  )
  bounds = update-bounds(bounds, plot-bounds)

  let legend = generate-legend(it.legend, legend-entries, e-get)
  if legend != none {
    bounds = update-bounds(bounds, legend.bounds)
  }

  if auto-width {
    width = available-size.width - bounds.right + bounds.left + width
  }
  if auto-height {
    height = available-size.height - bounds.bottom + bounds.top + height
  }
  return (width, height, tickings)
}



#let show-bounds(bounds, clr: red) = {
  if not debug { return none }
  place(dx: bounds.left, dy: bounds.top, rect(width: bounds.right - bounds.left, height: bounds.bottom - bounds.top, fill: clr))
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
  

  // Elements can be plot objects or plots on an axis: (axis-id: int, plot: dict). 
  let plots = () 
  // solely used for computing limits
  let (xplots, yplots) = ((), ()) 
  // all additional axes
  let axes = ()

  for child in it.children {
    if child == none { continue }
    if type(child) != dictionary {
      panic("Unexpected child `" + repr(child) + "`. Expected a plot or an axis. ")
    }

    if child.at("type", default: "") == "axis" { // is an axis
      axes.push(child)
      
      if child.plots.len() > 0 {
        plots += child.plots.map(plot => (axis-id: axes.len() - 1, plot: plot)) 
        if child.kind == "x" {
          yplots += child.plots
        } else {
          xplots += child.plots
        }
      }
    } else { // is a plot
      yplots.push(child)
      xplots.push(child)
      plots.push(child)
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


  // Compute limits for additional axes
  for i in range(axes.len()) {
    let axis = axes.at(i)
    let axes-margin = if axis.kind == "x" { 
      (lower-margin: margin.left, upper-margin: margin.right)
    } else {
      (lower-margin: margin.bottom, upper-margin: margin.top)
    }

    let model-axis = if axis.kind == "x" { xaxis } else { yaxis }
    axes.at(i).lim = _axis-compute-limits(
      axis, default-lim: model-axis.lim, ..axes-margin
    )
  }

  // Tell additional axes how to transform their coordinates


  
  
  
  e.get(e-get => {
    let axes = (xaxis, yaxis) + axes
    

    let get-settable-field(element, object, field) = {
      e.fields(object).at(field, default: e-get(element).at(field))
    }




    let it = it
    let tickings = ()

    // Diagram may have relative/ratio width or height
    if type(it.width) == relative or type(it.height) == relative {
      let attempt-layout = attempt-layout.with(
        auto-width: type(it.width) != length,
        auto-height: type(it.height) != length,
        available-size: it.size, it: it, axes: axes, e-get: e-get, plots: plots
      )

      let exact-or-guess(length, container-length) = {
        if type(length) == std.length { length }
        else { 0.9 * container-length * length.ratio + length.length.to-absolute() }
      }

      // First guess for diagram area
      let (width, height, ..) = attempt-layout(
        exact-or-guess(it.width, it.size.width), 
        exact-or-guess(it.height, it.size.height), 
      )


      // Now that we have a better guess for the size of the diagram area
      // let us re-evaluate the ticking because maybe our initial guess was really bad. 
      // In this step, we expect the size not too change very substantially,
      // so we fix the ticking now and re-use it again in the final layout step. 
      (it.width, it.height, tickings) = attempt-layout(width, height)

    } else {
      tickings = axes.map(axis => _axis-generate-ticks(axis, length: if axis.kind == "x" { it.width } else { it.height }))
    }

    axes = fill-in-transforms(axes, it.width, it.height)

    let (xaxis, yaxis) = axes.slice(0, 2)

    let bounds = (left: 0pt, right: it.width, top: 0pt, bottom: it.height)
    let update-bounds = update-bounds.with(width: it.width, height: it.height)
    
    let diagram = box(
      width: it.width, height: it.height, 
      inset: 0pt, outset: 0pt,
      stroke: none, fill: it.fill,
      {
      set align(top + left) // sometimes alignment is messed up
      set place(left)       // important for RTL text direction

      let artists = ()


      // GRID
      let axis-info = (
        x: tickings.at(0),
        y: tickings.at(1),
      )
      artists.push((
        content: generate-grid(axis-info, xaxis, yaxis, grid: it.grid), z: e-get(lq-grid).z-index
      ))


      // PLOTS
      let (legend-entries, artists: plot-artists, bounds: plot-bounds) = generate-plots(
        plots, it.cycle, it.width, it.height, 
        axes
      )
      artists += plot-artists
      bounds = update-bounds(bounds, plot-bounds)

      
      // AXES
      for (axis, ticking) in axes.zip(tickings) {
        let (axis-content, axis-bounds) = draw-axis(
          axis, ticking, e-get: e-get, 
          orthogonal-axis-transform: (if axis.kind == "x" { yaxis} else {xaxis}).transform
        )
        artists.push((content: axis-content, z: 20))
        
        axis-bounds.map(show-bounds.with(clr: rgb("#2222AA22"))).join()
        bounds = axis-bounds.fold(bounds, update-bounds)
      }
      
      
      // TITLE
      if it.title != none {
        let (title-content, title-bounds) = _place-title-with-bounds(
          it.title, get-settable-field, it.width, it.height
        )
        
        artists.push((content: title-content, z: 20))
        bounds = update-bounds(bounds, title-bounds)
      }

      
      // LEGEND
      let legend = generate-legend(it.legend, legend-entries, e-get)
      if legend != none {
        artists.push((content: legend.content, z: e-get(lq-legend).z-index))
        bounds = update-bounds(bounds, legend.bounds)
      }


      artists.sorted(key: artist => artist.z).map(artist => artist.content).join()
    })


    bounds.bottom -= it.height
    bounds.right -= it.width
    bounds.left *= -1
    bounds.top *= -1

    box(
      inset: bounds, 
      diagram, 
      stroke: if debug { 0.1pt } else { none },
      baseline: bounds.bottom
    )
  })
}








#let folding-dict = e.types.wrap(dictionary, fold: old-fold => (a, b) => a + b)

#let diagram = e.element.declare(
  "diagram",
  prefix: "lilaq",

  display: it => {
    if type(it.width) == relative or type(it.height) == relative {
      box(layout(size => {
        if type(it.width) == relative {
          // We have an exception for 0% which is useful to fit the _entire_ 
          // diagram to fixed dimensions. 
          assert(
            size.width != float.inf * 1pt or it.width.ratio == 0%, 
            message: "Cannot create diagram with relative width (" + 
              repr(it.width) + ") placed in a container with automatic width"
          )
          size.width = size.width*it.width.ratio + it.width.length.to-absolute()
        }
        if type(it.height) == relative {
          assert(
            size.height != float.inf * 1pt or it.height.ratio == 0%, 
            message: "Cannot create diagram with relative height (" + 
              repr(it.height) + ") placed in a container with automatic height"
          )
          size.height = size.height*it.height.ratio + it.height.length.to-absolute()
        }
        draw-diagram(it + (size: size))
      }))
    } else {
      draw-diagram(it)
    }
  }, 

  fields: (
    e.field("children", e.types.any, required: true),
    e.field("width", e.types.union(length, relative), default: 6cm),
    e.field("height", e.types.union(length, relative), default: 4cm),
    e.field("title", e.types.union(none, str, content, lq-title), default: none),
    e.field("legend", e.types.option(e.types.union(dictionary, lq-legend)), default: (:)),
    e.field("xlim", e.types.wrap(e.types.union(auto, array), fold: none), default: auto),
    e.field("ylim", e.types.wrap(e.types.union(auto, array), fold: none), default: auto),
    e.field("xlabel", e.types.option(e.types.union(lq-label, str, content)), default: none),
    e.field("ylabel", e.types.option(e.types.union(lq-label, str, content)), default: none),
    e.field("grid", e.types.union(auto, none, dictionary, stroke, color, length), default: auto),
    e.field("xscale", e.types.union(auto, str, dictionary), default: auto),
    e.field("yscale", e.types.union(auto, str, dictionary), default: auto),
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
      return (false, "element 'diagram': unexpected positional arguments\n  hint: these can only be passed to the constructor")
    }

    default-parser(args, include-required: include-required)
  },
)
