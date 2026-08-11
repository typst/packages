
#import "../assertations.typ"
#import "../utility.typ": if-auto
#import "../bounds.typ": update-bounds, place-with-bounds
#import "../process-styles.typ": update-stroke, process-grid-arg, twod-ify-alignment, process-margin , resolve-em-length
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



/// Creates a new diagram containing all plots that are passed as arguments. 
/// A comprehensive list of available plot functions can be found at 
/// #link("plot-types")[Plot Types]. 
/// 
/// All plots need to be wrapped in a diagram in order to be displayed. 
/// 
/// ```example
/// #lq.diagram(
///   title: [Trigonometric Functions],
///   xlabel: $x$,
///   ylabel: $y$,
///   lq.plot(lq.linspace(0, 10), calc.sin),
///   lq.plot(lq.linspace(0, 10), x => calc.cos(x) / 2)
/// )
/// ```
#let diagram(
  
  /// The width of the diagram. This can be one of the following:
  /// - A `length`, defining just the width of the data area,
  ///   excluding axes, labels, title, etc. To set a `length` including 
  ///   everything, use `0% + length`, see the next option. 
  /// - A `ratio` or `relative` where the ratio part is relative to the width 
  ///   of the parent that the diagram is placed in. This includes axes, labels, 
  ///   title, etc. This is not allowed if the parent has an unbounded width, 
  ///   e.g., a page with `width: auto`.  
  /// - Or `auto` in which case the width is computed automatically based on 
  ///   @diagram.aspect-ratio. 
  /// -> length | relative | auto
  width: 6cm,
  
  /// The height of the diagram. This can be one of the following:
  /// - A `length`, defining just the height of the data area,
  ///   excluding axes, labels, title, etc. To set a `length` including 
  ///   everything, use `0% + length`, see the next option. 
  /// - A `ratio` or `relative` where the ratio part is relative to the height 
  ///   of the parent that the diagram is placed in. This includes axes, labels, 
  ///   title, etc. This is not allowed if the parent has an unbounded height, 
  ///   e.g., a page with `height: auto`.  
  /// - Or `auto` in which case the height is computed automatically based on 
  ///   @diagram.aspect-ratio. 
  /// -> length | relative | auto
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
  /// constructor of the axis. See @axis for available options. Setting this to
  /// `none` hides the axis by effectively setting @axis.hidden to `true`. 
  /// -> none | dictionary
  xaxis: (:),
  
  /// Configures the $y$-axis through a dictionary of arguments to pass to the
  /// constructor of the axis. See @axis for available options. Setting this to
  /// `none` hides the axis by effectively setting @axis.hidden to `true`. 
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

  /// Fixes the aspect ratio of  data coordinates. 
  /// For example, when plotting a graph, fixing the aspect ratio ensures
  /// that a unit distance on the x-axis is visually equal to a unit distance 
  /// on the y-axis. This is particularly useful for visualizing data where the
  /// relative proportions are important, such as in scatter plots or heatmaps.
  /// 
  /// After setting an aspect ratio there are two ways how it can be realized. 
  /// 1. By adjusting the dimensions of the diagram area, i.e., the width or 
  ///    height. Select this method by setting one of @diagram.width and 
  ///    @diagram.height to `auto`.
  /// 2. By adjusting the margins of the diagram. Select this method by leaving
  ///    both @diagram.width and @diagram.height at fixed (relative) lengths.
  ///
  /// -> none | float
  aspect-ratio: none,

  /// Style cycle to use for this diagram. Check out the 
  /// #link("tutorials/cycles")[cycles tutorial] for more information. 
  /// The elements of a cycle array should either be 
  /// - all of type `color` (e.g., one of the maps from `lq.color.map`), or
  /// - all of type `dictionary` with possible keys `color`, `stroke`, and 
  ///   `mark`, or
  /// - all of type `function` as described in the tutorial. 
  ///   
  /// -> array
  cycle: petroff10,

  /// How to fill the background of the data area. 
  /// -> none | color | gradient | tiling 
  fill: none,

  /// How to compute the bounding box of a diagram. See also the tutorial 
  /// #link("tutorials/plot-grids#strict-or-relaxed-bounds")[Plot grids − Strict or relaxed bounds?].  
  /// - `"strict"`: The bounds are computed as the precise bounding box of the 
  ///   diagram. The exact behavior for text bounds also depends on the setting 
  ///   of #link("https://typst.app/docs/reference/text/text/#parameters-top-edge")[`text.top-edge`]
  ///   and #link("https://typst.app/docs/reference/text/text/#parameters-bottom-edge")[`text.bottom-edge`]. 
  /// - `"relaxed"`: Tick labels of a horizontal axis are allowed to hang into the page margins
  ///   at the right and left of a diagram and tick labels of a vertical axis 
  ///   may spill out at the top and bottom. Like this, the spines can line up
  ///   with the main text body, even when the first and last tick sit on the 
  ///   far edges of an axis. Sometimes, this can give a cleaner look. 
  /// - `"data-area"`: The bounds are simply the data area. 
  /// -> "relaxed" | "strict" | "data-area"
  bounds: "strict",

  /// Plot objects like @plot, @bar, @scatter, @contour etc. and additional 
  /// @axis objects. 
  /// -> any
  ..children

) = {}





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


#let create-main-axis(
  axis, lim, scale,
  kind: "x",
  label,
  plots,
  it
) = {
  if axis == none { axis = (hidden: true) }

  if type(axis) == dictionary {
    axis = lq-axis(kind: kind, label: label, scale: scale, lim: lim, ..axis, ..plots)
  }
  
  axis
}




#let do-adjust-dimensions-for-aspect-ratio(diagram) = {
  diagram.width == auto or diagram.height == auto
}

#let do-adjust-margins-for-aspect-ratio(diagram) = {
  not do-adjust-dimensions-for-aspect-ratio(diagram)
}


// Computes axis limits and transforms. 
#let fill-in-transforms(axes, width, height, it: none) = {
  assert(it != none, message: "Internal error: Missing diagram options when filling in axis transforms.")

  let main-margin = process-margin(it.margin)

  if it.aspect-ratio != none and do-adjust-margins-for-aspect-ratio(it) {
    let (xaxis, yaxis) = axes.slice(0, 2)

    let xlim = _axis-compute-limits(xaxis, margin: main-margin, is-independent: true)
    let ylim = _axis-compute-limits(yaxis, margin: main-margin, is-independent: true)

    let b = width / calc.abs(xlim.at(1) - xlim.at(0))
    let a = height / calc.abs(ylim.at(1) - ylim.at(0))
    let ratio = b / a / it.aspect-ratio

    if ratio > 1 {
      let auto-count = xaxis.lim.filter(l => l == auto).len()
      assert(auto-count > 0, message: "Cannot realize an aspect ratio of " + str(it.aspect-ratio) + " with fixed x limits.")
      let r = (100% + main-margin.left + main-margin.right) * (ratio  - 1)
      main-margin.left += r / auto-count
      main-margin.right += r / auto-count
    } else if ratio < 1 {
      let auto-count = yaxis.lim.filter(l => l == auto).len()
      assert(auto-count > 0, message: "Cannot realize an aspect ratio of " + str(it.aspect-ratio) + " with fixed y limits.")
      let r = (1 / ratio - 1) * (100% + main-margin.top + main-margin.bottom)
      main-margin.top += r / auto-count
      main-margin.bottom += r / auto-count
    }
  }
  
  let update-axis(axis, xaxis: none, yaxis: none, margin: it.margin) = {
    let normalized-trafo
    
    if axis.plots.len() > 0 or xaxis == none { // is independent axis
      axis.lim = _axis-compute-limits(
        axis, is-independent: true, margin: margin
      )
      normalized-trafo = create-trafo(axis.scale.transform, ..axis.lim)
      // need to store this for main axis 
      // so other axes can take it as model:
      axis.normalized-transform = normalized-trafo 
    } else { // is dependent axis
      let model-axis = if axis.kind == "x" { xaxis } else { yaxis }
      axis.lim = _axis-compute-limits(
        axis, default-lim: model-axis.lim, margin: margin
      )
      normalized-trafo = a => (model-axis.normalized-transform)((axis.functions.inv)(a))
    }

    axis.transform = if axis.kind == "x" {
      x => normalized-trafo(x) * width
    } else {
      y => (1 - normalized-trafo(y)) * height
    }
    axis
  }

  let (xaxis, yaxis) = axes.slice(0, 2).map(update-axis.with(margin: main-margin))

  (xaxis, yaxis) + axes.slice(2).map(update-axis.with(xaxis: xaxis, yaxis: yaxis))
}


#let resolve-dimensions-aspect-ratio(
  xaxis, yaxis, 
  // diagram object with fields `width` and `height`, and `aspect-ratio`. 
  // When one of these dimensions is `auto`, `aspect-ratio` is used for computing the other dimension, respectively. 
  it: none,
  // Width and height as lengths. If not `auto`, these are used instead of 
  // `diagram.width` and `diagram.height` for computing the other dimension. This is necessary when `diagram.width` or `diagram.height` are relative lengths because in this case, the automatic dimension could not be resolved.
  width: auto, height: auto,
) = {
  assert(it != none, message: "Internal error: Missing diagram options when resolving proportional lengths.")
  if width == auto { width = it.width }
  if height == auto { height = it.height }

  if it.width != auto and it.height != auto {
    return (width, height)
  }

  assert(
    it.aspect-ratio != none,
    message: "An aspect ratio must be specified when one of the dimensions of a diagram is set to `auto`."
  )

  // x/yaxis.normalized-transform do not exist yet (and can only be computed 
  // later when the dimensions are resolved), so we need to create them here
  // temporarily.
  // Note that in the case where dimensions need to be resolved, the 
  // margins/limits are already fixed because the aspect ratio 
  // is only realized through dimension adjustment and not margin adjustment. 
  // This is why the following step is allowed. 
  let create-normalized-trafos(axis) = (
    create-trafo(
      axis.scale.transform, 
      .._axis-compute-limits(axis, is-independent: true, margin: it.margin)
    )
  )
  
  let (tx, ty) = (xaxis, yaxis).map(create-normalized-trafos)
  

  if it.height == auto {
    assert(
      it.width != auto, 
      message: "Only the width or the height of a diagram can be specified in terms of the other through an aspect ratio but not both at the same time."
    )

    height = it.aspect-ratio * width * (tx(1) - tx(2)) / (ty(1) - ty(2))
  } else if it.width == auto {
    width = it.aspect-ratio * height * (ty(1) - ty(2)) / (tx(1) - tx(2))
  }
  (width, height)
}



#let attempt-layout(
  width, height, 
  it: (:), axes: (), plots: (), e-get: none, 
  auto-height: true, auto-width: true,
  available-size: (width: 0pt, height: 0pt),
  draw-axis: draw-axis
) = {
  (width, height) = resolve-dimensions-aspect-ratio(
    ..axes.slice(0, 2), 
    width: width, height: height, 
    it: it,
  )

  axes = fill-in-transforms(axes, width, height, it: it)
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
      axis, ticking, e-get: e-get, 
      orthogonal-axis-transform: (if axis.kind == "x" { yaxis } else { xaxis }).transform,
      bounds-mode: it.bounds
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



  let xaxis = create-main-axis(
    kind: "x",
    it.xaxis, it.xlim, it.xscale,
    it.xlabel, xplots, it
  )
  let yaxis = create-main-axis(
    kind: "y",
    it.yaxis, it.ylim, it.yscale,
    it.ylabel, yplots, it
  )

  
  
  
  e.get(e-get => {
    let axes = (xaxis, yaxis) + axes

    let axes-count = (
      x: axes.map(axis => int(axis.kind == "x")).sum(),
      y: axes.map(axis => int(axis.kind == "y")).sum(),
    )
    let draw-axis = draw-axis.with(axes-count: axes-count)
    

    let get-settable-field(element, object, field) = {
      e.fields(object).at(field, default: e-get(element).at(field))
    }




    let it = it
    let tickings = ()


    // In this case, we do not need and want complex layout computation.
    if it.bounds == "data-area" and type(it.width) == relative {
      it.width = it.size.width
    }
    if it.bounds == "data-area" and type(it.height) == relative {
      it.height = it.size.height
    }
    
    // Diagram may have relative/ratio width or height
    if type(it.width) == relative or type(it.height) == relative {
      let attempt-layout = attempt-layout.with(
        auto-width: type(it.width) == relative,
        auto-height: type(it.height) == relative,
        available-size: it.size, it: it, axes: axes, e-get: e-get, plots: plots,
        draw-axis: draw-axis
      )

      let exact-or-guess(length, container-length) = {
        if type(length) == std.length { length }
        else if length == auto { length }
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
      (width, height, tickings) = attempt-layout(width, height)
      if it.pad != auto {
        // Sneaky dimension change for diagram grids to avoid diverging layout. 
        if type(it.width) == relative {
          width -= it.pad.right + it.pad.left
        }
        if type(it.height) == relative {
          height -= it.pad.bottom + it.pad.top
        }
      }

      axes = fill-in-transforms(axes, width, height, it: it)
      (it.width, it.height) = (width, height)

      if it.aspect-ratio != none {
        // need to redo ticking because limits will have changed
        tickings = axes.map(axis => _axis-generate-ticks(axis, length: if axis.kind == "x" { it.width } else { it.height }))
      }

    } else {
      // Resolving needs to be done before filling in transforms because
      // the aspect ratio may change the dimensions.
      let (width, height) = resolve-dimensions-aspect-ratio(..axes.slice(0,2), it: it)
      axes = fill-in-transforms(axes, width, height, it: it)
      (it.width, it.height) = (width, height)

      tickings = axes.map(axis => _axis-generate-ticks(axis, length: if axis.kind == "x" { it.width } else { it.height }))
    }


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
          orthogonal-axis-transform: (if axis.kind == "x" { yaxis } else { xaxis }).transform,
          bounds-mode: it.bounds
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

    if it.bounds == "data-area" {
      bounds = (top: 0pt, bottom: 0pt, left: 0pt, right: 0pt)
    }

    let result = box(
      inset: bounds, 
      diagram, 
      stroke: if debug { 0.1pt } else { none },
      baseline: bounds.bottom
    )
    if it.pad != auto {
      result = pad(result, ..it.pad)
    }
    result + [#metadata(it._grid-pos + bounds)<__lilaq_diagram__>]
  })
}








#let folding-dict = e.types.wrap(dictionary, fold: old-fold => (a, b) => a + b)

#let diagram = e.element.declare(
  "diagram",
  prefix: "lilaq",

  display: it => {
    it.width = resolve-em-length(it.width)
    it.height = resolve-em-length(it.height)

    let result = if type(it.width) == relative or type(it.height) == relative {
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
    

    if sys.version >= version(0, 14, 0) and "target" in std and target() == "html" {
      result = html.frame(result)
    }

    result
  }, 

  fields: (
    e.field("_grid-pos", e.types.wrap(dictionary, fold: none), default: (:)),
    e.field("pad", e.types.any, default: auto),
    e.field("children", e.types.any, required: true),
    e.field("aspect-ratio", e.types.option(float), default: none),
    e.field("width", e.types.union(length, relative, auto), default: 6cm),
    e.field("height", e.types.union(length, relative, auto), default: 4cm),
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
    e.field("bounds", e.types.union("strict", "relaxed", "data-area"), default: "strict"),
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
