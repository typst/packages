#import "../logic/scale.typ" as lqscale
#import "../utility.typ": place-in-out, match, match-type, if-auto, if-none
#import "../logic/time.typ"
#import "../logic/tick-locate.typ"
#import "../logic/tick-format.typ"
#import "../bounds.typ": *
#import "../assertations.typ"
#import "../model/label.typ": xlabel, ylabel, label as lq-label
#import "../process-styles.typ": update-stroke, merge-strokes, process-margin
#import "@preview/elembic:1.1.1" as e

#import "tick.typ": tick as lq-tick, tick-label as lq-tick-label
#import "spine.typ": spine

#import "@preview/zero:0.6.1"
#import "@preview/tiptoe:0.4.0"



/// An axis for a diagram. Visually, an axis consists of a _spine_ along the axis 
/// direction, a collection of _ticks_ (and subticks) with _tick labels_ and an
/// _axis label_. 
/// ```typ render
/// #import "@preview/tiptoe:0.4.0"
/// #let line = lq.line.with(tip: tiptoe.straight, stroke: red + .5pt, clip: false)
/// #set text(1.2em)
/// 
/// #lq.diagram(
///   yaxis: none,
///   xaxis: (mirror: none, exponent: 1),
///   xlim: (10, 50),
///   ylim: (-.1, 1),
///   grid: none,
///   height: 1cm,
///   width: 7cm,
///   lq.place(16.5, .7, align: right, text(red)[_ticks_]),
///   line((17, .6), (20,0.1)),
///   line((17, .6), (30,0.1)),
///   lq.place(39, .7, align: right, text(red)[_subticks_]),
///   line((39.5, .6), (42,0)),
///   line((39.5, .6), (44,0)),
///   lq.place(60, .7, text(red)[_exponent_]),
///   line((62, .4), (59,-.1)),
///   lq.place(38, -1.5, align: left, text(red)[_axis label_]),
///   line((37, -1.5), (31,-1.3)),
///   lq.place(23, -1.5, text(red)[_tick label_]),
///   line((23, -1.2), (21,-.8)),
///   lq.place(12, -1.5, text(red)[_spine_]),
///   line((12, -1.2), (15,-.1)),
///   xlabel: $x$
/// )
/// ```
/// 
/// Most often, you will want to configure the main $x$ and $y$ axes by 
/// applying the parameters listed here to @diagram.xaxis and @diagram.yaxis:
/// ```typ
/// // Scoped configuration
/// #show: lq.set-diagram(
///   yaxis: (exponent: 0),
///   xaxis: (position: top)
/// )
/// 
/// // Per-diagram configuration
/// #lq.diagram(
///   yaxis: (exponent: 0),
///   xaxis: (position: top),
///   ..
/// )
/// ```
/// 
/// However, it is also possible to add more axes, please refer to the 
/// #link("tutorials/axis")[axis tutorial] for more details. 
/// 
/// 
/// 
/// The built-in _tick formatters_ use the Typst package
/// #link("https://typst.app/universe/package/zero")[Zero] for displaying
/// numbers. This makes it possible to define a consistent number format 
/// throughout the entire document, including tables, in-text quantities,
/// and figures. 
/// 
#let axis(

  /// Sets the scale of the axis. This may be a @scale object or the name of 
  /// one of the built-in scales `"linear"`, `"log"`, `"symlog"`, and 
  /// `"datetime"`. 
  /// 
  /// If left at `auto`, the scale will be set to `"datetime"` if any of the 
  /// plots uses datetime coordinates and `"linear"` otherwise. 
  /// -> auto | str | lq.scale
  scale: auto, 

  /// Data limits of the axis. This can be used to fix the minimum and/or maximum value
  /// displayed along this axis. This parameter expects `auto` or a tuple `(min, max)` 
  /// where `min` and `max` can also be `auto`. If a limit is `auto`, it will be 
  /// automatically computed from all plots associated with this axis and @diagram.margin 
  /// will be applied. If the minimum is larger than the maximum, the scale is inverted
  /// and if `min` and `max` coincide, the range will be automatically expanded. 
  /// Also see @axis.inverted. 
  /// -> auto | array
  lim: auto,

  /// Whether to invert the limits (swap minimum and maximum). Inverting is 
  /// applied regardless of whether the limits are set manually or computed automatically. 
  /// -> bool
  inverted: false,

  /// Label for the axis. Use a @label object for more options. 
  /// -> content | lq.label
  label: none,

  /// The kind of the axis. 
  /// -> "x" | "y"
  kind: "x", 

  /// Where to place this axis. This can be 
  /// - one of the sides of the diagram (`top` or `bottom` for $x$-axes, 
  ///   `left` or `right` for $y$-axes), 
  /// - a `float` coordinate value on the other axis,
  /// - a `length` or `relative`,
  /// - or a combination of the first and second/third option through a dictionary 
  ///   with the keys `align` and `offset`. 
  /// 
  /// More on axis placement can be found in the tutorial section
  /// #link("tutorials/axis#placement-and-mirrors")[Axis − Placement and mirrors]. 
  /// -> auto | alignment | float | relative | dictionary
  position: auto, 

  /// Whether to mirror the axis (and which parts of it), i.e., whether to show
  /// the axis ticks also on the side opposite of the one specified with 
  /// @axis.position. 
  /// 
  /// When set to `auto`, mirrors are deactivated automatically when either a 
  /// secondary axis is added or @axis.position is set to something else than 
  /// one of the four diagram sides. 
  /// 
  /// More control is granted through a dictionary with the possible keys `ticks` 
  /// and `tick-labels` to individually activate or deactivate those. 
  /// 
  /// More on axis mirrors can be found in the tutorial section
  /// #link("tutorials/axis#placement-and-mirrors")[Axis − Placement and mirrors]. 
  /// -> auto | bool | dictionary
  mirror: auto,

  /// Instead of using the tick locator, specifies the tick locations explicitly
  /// and optionally the tick labels. This can be an array with just the tick
  /// location or tuples of tick location and label, or a dictionary with the 
  /// keys `ticks` and `labels`, containing arrays of equal length. When `ticks` 
  /// is `none`, no ticks are displayed. If it is `auto`, the `tick-locator` is 
  /// used. 
  /// 
  /// Check out the #link("tutorials/ticks")[tutorial on ticks] for tips on how 
  /// to work with ticks. 
  /// -> auto | array | dictionary | none
  ticks: auto, 

  /// Instead of using the tick locator, specifies the tick positions explicitly
  /// and optionally the tick labels.
  /// 
  /// Also see the #link("tutorials/ticks")[tutorial on ticks]. 
  /// -> auto | none | int
  subticks: auto,

  /// Passes the parameter `tick-distance` to the tick locator. The linear tick
  /// locator respects this setting and sets the distance between consecutive 
  /// ticks accordingly. If `tick-args` already contains an entry `tick-distance`, 
  /// it takes precedence. 
  /// -> auto | float
  tick-distance: auto, 

  /// Offset for all ticks on this axis. The offset is subtracted from all ticks 
  /// and shown at the end of the axis (if it is not 0). An offset can be used 
  /// to avoid overly long tick labels and to focus on the relative distance 
  /// between data points. 
  /// 
  /// If `none` or a value of type `content`, the offset is just displayed and 
  /// has no effect on how the data is presented. 
  /// -> auto | int | float | content | none
  offset: auto,

  /// Exponent for all ticks on this axis. All ticks are divided by 
  /// $10^\mathrm{exponent}$ and the $10^\mathrm{exponent}$ is shown at the end
  /// of the axis (if the exponent is not 0). This setting can be used to avoid
  /// overly long tick labels. 
  /// 
  /// In combination with logarithmic tick locators, `none` can be used to 
  /// force writing out all numbers without scientific notation. 
  /// -> auto | none | int | "inline"
  exponent: auto,

  /// Threshold for automatic exponents. 
  /// -> int
  auto-exponent-threshold: 3,

  /// The tick locator for the regular ticks. 
  /// Also see the tutorial section 
  /// #link("tutorials/ticks#locating-ticks")[Ticks − Locating ticks]. 
  /// -> auto | function
  locate-ticks: auto,
  
  /// The formatter for the (major) ticks. 
  /// Also see the tutorial section 
  /// #link("tutorials/ticks#formatting-ticks")[Ticks − Formatting ticks]. 
  /// -> auto | function
  format-ticks: auto,
  
  /// The tick locator for the subticks. 
  /// Also see the tutorial section 
  /// #link("tutorials/ticks#locating-ticks")[Ticks − Locating ticks]. 
  /// -> auto | function
  locate-subticks: auto,
  
  /// The formatter for the subticks. 
  /// Also see the tutorial section 
  /// #link("tutorials/ticks#displaying-subtick-labels")[Ticks − Displaying subticks labels]. 
  /// -> auto | none | function
  format-subticks: none,

  /// An array of extra ticks to display. The ticks can be positions given as `float` data values or @tick instances. 
  /// -> array
  extra-ticks: (), 

  /// The formatter for the extra ticks. 
  format-extra-ticks: none,

  /// Arguments to pass to the tick locator. 
  /// -> dictionary
  tick-args: (:),

  /// Arguments to pass to the subtick locator. 
  /// -> dictionary
  subtick-args: (:),
  
  /// Specifies conversions between the data and the ticks. This can be used to
  /// configure a secondary axis to display the same data in a different unit, 
  /// e.g., the main axis displays the velocity of a particle while the 
  /// secondary axis displays the associated energy. In this case, one would 
  /// pick `functions: (x => m*x*x, y => calc.sqrt(y/m))` with some constant
  /// `m`. Note that the first function computes the _forward_ direction while
  /// the second function computes the _backward_ direction (and is thus the _inverse_ of the forward conversion). The user needs to 
  /// ensure that the two functions are really inverses of each other. 
  /// By default, this parameter resolves to the identity.
  /// 
  /// Learn more in the tutorial section #link("tutorials/axis#dependent-axes")[Axis − Dependent axes].  
  /// -> auto | array
  functions: auto,

  /// If set to `true`, the entire axis is hidden, including ticks and labels
  /// and no space is reserved for it. However, logical parameters like 
  /// @axis.scale, @axis.lim, @axis.inverted, @axis.ticks, and similar still
  /// take effect and tick positions are still located and passed to @grid. 
  /// 
  /// Setting @diagram.xaxis or @diagram.yaxis to `none` effectively sets this 
  /// parameter to `true`. 
  /// -> bool
  hidden: false,

  /// How to stroke the spine of the axis. If not `auto`, this is forwarded to 
  /// @spine.stroke. 
  /// -> auto | stroke
  stroke: auto,

  /// Places an arrow tip on the axis spine. This expects a mark as specified by
  /// the #link("https://typst.app/universe/package/tiptoe")[Tiptoe package]. 
  /// If not `auto`, this is forwarded to @spine.tip. 
  /// -> auto | none | tiptoe.mark
  tip: auto,

  /// Places an arrow tail on the axis spine. This expects a mark as specified by 
  /// the #link("https://typst.app/universe/package/tiptoe")[Tiptoe package]. 
  /// If not `auto`, this is forwarded to @spine.toe. 
  /// -> auto | none | tiptoe.mark
  toe: auto,

  filter: (value, distance) => true,

  /// Plot objects to associate with this axis, see the tutorial section 
  /// #link("tutorials/axis#independent-axes-twin-axes")[Axis − Independent axes]. 
  /// This parameter is mutually exclusive with @axis.functions (which would make the axis dependent) and @axis.lim. 
  /// 
  /// Automatic limits are then computed according to this 
  /// axis and transformation of the plot data is linked to the scaling of
  /// this axis. 
  /// -> any
  ..plots
  
) = {
  assertations.assert-no-named(plots)
  plots = plots.pos()
  if "tick-distance" not in tick-args {
    tick-args.tick-distance = tick-distance
  }
  
  if scale == auto {
    scale = "linear"

    for plot in plots {
      if "axis-id" in plot { plot = plot.plot }
      if "datetime" in plot and plot.datetime.at(kind, default: false) {
        scale = "datetime"
        break
      }
    }
    if type(lim) == array and datetime in lim.map(type) {
      scale = "datetime"
    }
  }

  if type(scale) == str {
    assert(scale in lqscale.scales, message: "Unknown scale " + scale)
    scale = lqscale.scales.at(scale)
  }
  assert(kind in ("x", "y"), message: "The `kind` of an axis can only be `x` or `y`")
  let orthogonal-offset = 0pt


  if position == auto {
    if kind == "x" { position = bottom }
    else if kind == "y" { position = left }
  } else if type(position) in (int, float, length, relative, ratio) {
    if kind == "x" { 
      orthogonal-offset = position
      position = bottom 
    }
    else if kind == "y" { 
      orthogonal-offset = position
      position = left 
    }
    if mirror == auto { mirror = none }
  } else if type(position) == dictionary {
    assertations.assert-dict-keys(position, mandatory: ("align", "offset"))

    
    if kind == "x" { orthogonal-offset = position.offset }
    else if kind == "y" { orthogonal-offset = position.offset }
    position = position.align
    if mirror == auto { mirror = none }
    
    if kind == "x" {
      assert(position in (top, bottom), message: "For x-axes, `position` can only be \"top\" or \"bottom\", got " + repr(position))
    }
    if kind == "y" {
      assert(position in (left, right), message: "For y-axes, `position` can only be \"left\" or \"right\", got " + repr(position))
    }
  } else if type(position) == alignment {
    if kind == "x" {
      assert(position in (top, bottom), message: "For x-axes, `position` can only be \"top\" or \"bottom\", got " + repr(position))
    }
    if kind == "y" {
      assert(position in (left, right), message: "For y-axes, `position` can only be \"left\" or \"right\", got " + repr(position))
    }
  } else {}

  if ticks != auto {
    if type(ticks) == dictionary {
      assert("ticks" in ticks, message: "When passing a dictionary for `ticks`, you need to provide the keys \"ticks\" and optionally \"labels\"")
      locate-ticks = tick-locate.manual.with(ticks: ticks.ticks.zip(ticks.labels))
      if "labels" in ticks {
        format-ticks = tick-locate.format-ticks-manual 
      }
    } else if type(ticks) == array {
      if ticks.len() > 0 and type(ticks.first()) == array {
        // let (ticks, labels) = array.zip(..ticks)
        locate-ticks = tick-locate.manual.with(ticks: ticks)
        format-ticks = tick-format.manual 
      } else {
        locate-ticks = tick-locate.manual.with(ticks: ticks)
      }
    } else if ticks == none {
      locate-ticks = none
      format-ticks = none
    } else { assert(false, message: "The parameter `ticks` may either be an array or a dictionary")}
  }
  
  if locate-ticks == auto {
    locate-ticks = if-none(scale.locate-ticks, tick-locate.linear)
  }
  if format-ticks == auto {
    format-ticks = match(
      scale.name,
      "linear", () => tick-format.linear,
      "log", () => tick-format.log.with(base: scale.base),
      "symlog", () => tick-format.symlog.with(base: scale.base, threshold: scale.threshold, linscale: scale.linscale),
      "datetime", () => tick-format.datetime,
      default: () => tick-format.naive
    )
  }
  if subticks == none {
    locate-subticks = none
  } else if type(subticks) == int {
    locate-subticks = tick-locate.subticks-linear.with(num: subticks)
  } else if subticks != auto {
    assert(false, message: "Unsupported argument type `" + str(type(subticks)) + "` for parameter `subticks`")
  }
  if locate-subticks == auto {
    locate-subticks = if-none(scale.locate-subticks, none)
  }
  let is-independent = functions == auto
  if functions == auto { 
    functions = (x => x, x => x) 
  } else {
    assert(
      type(functions) == array and functions.map(type) == (function, function), 
      message: "The parameter `functions` for `axis()` expects an array of two functions, a forward and an inverse function."
    )
    assert(
      plots.len() == 0, 
      message: "An `axis` can either be created with `functions` or with `..plots` but not both. "
    )
    assert(
      lim == auto, 
      message:  "A dependent `axis` with `functions` is not allowed to have manual axis limits. "
    )
  }

  if type(lim) == array {
    assert.eq(lim.len(), 2, message: "Limit arrays must contain exactly two items")
    lim = lim.map(
      lim => if type(lim) == datetime {
        time.to-seconds(lim).first()
      } else {
        lim
      }
    )
  } else if lim == auto { 
    lim = (auto, auto)
  } else {
    assert(false, message: "Unsupported limit specification")
  }

  let data-limits = (
    // Limits computed from all plots associated with this axis
    x0: lim.at(0), x1: lim.at(1), 
    // Whether these limits are tight or whether they allow margins to be added
    tight-x0: true, tight-x1: true 
  )

  if is-independent and auto in lim {

    let plot-limits = plots
      .map(plot => plot.at(kind + "limits")())
      .filter(x => x != none)

    if plot-limits.len() == 0 {
      if scale.identity != 0 {
        (data-limits.x0, data-limits.x1) = (scale.identity,) * 2
      } else {
        (data-limits.x0, data-limits.x1) = (0, 1)
      }
    } else {

      let retrieve-limit(index, comp) = plot-limits.fold(
        (auto, true),
        ((prev-lim, tight), plot-limit) => {
          let new-lim = plot-limit.at(index)
          let new-tight = type(new-lim) == fraction
          if new-tight { new-lim = new-lim / 1fr }

          if new-lim != none and (prev-lim == auto or comp(prev-lim, new-lim)) {
            return (new-lim, new-tight)
          }
          (prev-lim, tight)
        }
      )

      if data-limits.x0 == auto {
        (data-limits.x0, data-limits.tight-x0) = retrieve-limit(0, (x, new) => new < x)
      }
      if data-limits.x1 == auto {
        (data-limits.x1, data-limits.tight-x1) = retrieve-limit(1, (x, new) => new > x)
      }

    }
    if data-limits.x0 == auto {
      data-limits.x0 = scale.identity
    }
    if data-limits.x1 == auto {
      data-limits.x1 = if scale.identity == 0 { 1 } else { scale.identity }
    }
  }

  if type(mirror) == bool {
    if mirror { mirror = (ticks: true) }
    else { mirror = none }
  } else if type(mirror) == dictionary {
    for key in mirror.keys() {
      assert(key in ("ticks", "tick-labels"), message: "When passing a dictionary to `axis.mirror`, only the keys \"ticks\" and \"tick-labels\" are valid, got \"" + key + "\"")
    }
  }


  
  (
    type: "axis",
    scale: scale,
    lim: lim,
    data-limits: data-limits,
    functions: (forward: functions.at(0), inv: functions.at(1)),
    label: label,
    stroke: stroke,
    kind: kind,
    position: position,
    orthogonal-offset: orthogonal-offset,
    mirror: mirror,
      
    locate-ticks: locate-ticks,
    format-ticks: format-ticks,
    locate-subticks: locate-subticks,
    format-subticks: format-subticks,
    extra-ticks: extra-ticks,
    format-extra-ticks: format-extra-ticks,

    filter: filter,

    tick-args: tick-args,
    subtick-args: subtick-args,

    offset: offset,
    exponent: exponent,
    auto-exponent-threshold: auto-exponent-threshold,
    plots: plots,
    hidden: hidden,
    tip: tip,
    toe: toe,

    inverted: inverted
  )
}

#let xaxis = axis.with(kind: "x")
#let yaxis = axis.with(kind: "y")


/// Computes the axis limits of one axis (x or y). For each plot, `xlimits()` 
/// and `ylimits()` is called. Plots whose limit functions return `none`  
/// will be ignored. 
/// If there are no plots or all calls to `xlimits()` and 
/// `ylimits()` return `none`, the limits are set to `(0,0)`.
///
/// Regardless of this, a zero-width range is enlarged by calling 
/// `next(min, -1)` and `next(max, 1)`. 
/// Finally lower and upper margins are applied. 
///
#let _axis-compute-limits(
  axis, 
  margin: 0%,
  default-lim: (0, 1),
  is-independent: auto
) = {

  if is-independent == auto {
    is-independent = axis.plots.len() > 0
  }
  
  let (x0, x1, tight-x0, tight-x1) = axis.data-limits
  
  if not is-independent and auto in axis.lim {
    (x0, x1) = default-lim.map(axis.functions.forward)
  }
  if x0 == x1 {
    x0 = (axis.scale.inverse)((axis.scale.transform)(x0) - 1)
    x1 = (axis.scale.inverse)((axis.scale.transform)(x1) + 1)
  }


  if axis.inverted {
    (x0, x1) = (x1, x0)
  }

  let k0 = (axis.scale.transform)(x0)
  let k1 = (axis.scale.transform)(x1)
  let D = k1 - k0

  margin = process-margin(margin)
  // Apply margins
  margin = if axis.kind == "x" { 
    (lower: margin.left, upper: margin.right)
  } else {
    (lower: margin.bottom, upper: margin.top)
  }
  if not tight-x0 {
    x0 = (axis.scale.inverse)(k0 - D * margin.lower/100%)
  }
  if not tight-x1 {
    x1 = (axis.scale.inverse)(k1 + D * margin.upper/100%)
  }

  return (x0, x1)
}


/// Generates all ticks and subticks as well as their labels for an axis. 
/// 
/// -> dictionary
#let _axis-generate-ticks(
  /// The axis object. 
  /// -> lq.axis
  axis, 
  
  /// The length with which the axis will be displayed. This is for example used to determine automatic tick distances. 
  /// -> length
  length: 3cm
) = {
  let ticks = ()
  let tick-labels
  let subticks = ()
  let subtick-labels
  let (exp, offset) = (axis.exponent, axis.offset)

  axis.tick-args.num-ticks-suggestion = match(
    axis.kind,
    "x", length / (3.3em.to-absolute()),
    "y", length / (2em.to-absolute())
  )
  let (x0, x1) = axis.lim
  

  if x1 < x0 {
    // (x1, x0) = (x0, x1)
  } else if x0 == x1 {
    assert(
      false, 
      message: "Cannot generate ticks for empty range [" + str(x0) +", " + str(x1) + "]"
    )
  }


  if axis.locate-ticks != none {

    let tick-result = (axis.locate-ticks)(x0, x1, ..axis.tick-args)
    ticks = tick-result.ticks
    
    let format-result = if axis.format-ticks != none {
      (axis.format-ticks)(
        tick-result.ticks,
        tick-info: tick-result, 
        exponent: axis.exponent, 
        offset: if type(offset) in (int, float) or offset == auto { offset } else { 0 }, 
        auto-exponent-threshold: axis.auto-exponent-threshold,
        min: x0, 
        max: x1
      )
    }

    if type(format-result) == array {
      tick-labels = format-result
    } else if type(format-result) == dictionary {
      assertations.assert-dict-keys(
        format-result,
        mandatory: ("labels",),
        optional: ("offset", "exponent")
      )
      tick-labels = format-result.labels
      if "exponent" in format-result {
        exp = format-result.exponent
      }
      if "offset" in format-result and offset == auto {
        offset = format-result.offset
      }
    } else if format-result != none {
      assert(
        false, 
        message: "The tick formatter must either return an array of labels or a dictionary with the keys \"labels\", \"exponent\", and \"offset\". Found " + repr(format-result)
      )
    }
    if exp == auto { exp = 0 }
    if offset == auto { offset = 0 }

    if axis.locate-subticks != none {
      let subtick-result = (axis.locate-subticks)(x0, x1, ..tick-result, ..axis.subtick-args)

      subticks = subtick-result.ticks
      subtick-labels = if axis.format-subticks != none {
        (axis.format-subticks)(
          subticks, 
          tick-info: subtick-result,
          exponent: axis.exponent, 
          offset: axis.offset
        )
      }
      if type(subtick-labels) == dictionary {
        subtick-labels = subtick-labels.labels
      }
    }
  } 

  return (
    ticks: ticks,
    tick-labels: tick-labels,
    subticks: subticks,
    subtick-labels: subtick-labels,
    exp: exp,
    offset: offset
  )
}


/// Conditionally create bounds, with the sorting depending on the axis position
#let _to-bounds(
  /// Amount of space extending outwards cross the axis
  outwards,
  /// Amount of space extending along the axis (towards left/top)
  start, 
  /// Amount of space extending along the axis (towards right/bottom)
  end,
  /// Amount of space extending inwards cross the axis
  inwards: 0pt,
  // The position/alignment of the axis. 
  pos: bottom
) = {
  if pos == bottom {
    (left: start, right: end, bottom: 100% + outwards, top: 100% - inwards)
  } else if pos == top {
    (left: start, right: end, bottom: inwards, top: -outwards)
  } else if pos == left {
    (left: -outwards, right: inwards, bottom: end, top: start)
  } else if pos == right {
    (left: 100% - inwards, right: 100% + outwards, bottom: end, top: start)
  }
}





// Places a set of ticks together with tick labels. 
// In addition, if `bounds-mode` is set to `"strict"`, the bounds of the tick 
// labels are computed and returned as a bounds rectangle. 
// If `sub: false`, any `axis.extra-ticks` are drawn as well. 
// -> (result: content, bounds: array)
#let place-ticks(

  /// The axis object
  axis,

  /// Ticks to place, an array of data coordinates
  /// -> array
  ticks, 

  /// The tick labels to draw
  /// -> none | array
  labels, 

  /// Where to place the ticks on the diagram. This can differ from @axis.
  /// position when drawing mirrows. 
  /// -> top | bottom | left | right
  position, 

  /// Whether to draw tick labels. 
  display-tick-labels, 

  /// Whether to draw subticks or normal ones. 
  sub: false,

  /// See @diagram.bounds
  bounds-mode: "relaxed",

  e-get: none

) = {
  if labels == none { labels = (none,) * ticks.len() }
  
  let align = position.inv()
  let tick-state = e-get(lq-tick)
  let pad = tick-state.pad
  let factor = if sub { 1 - (tick-state.shorten-sub / 100%) } else { 1 }
  let outset = tick-state.outset * factor
  let inset = tick-state.inset * factor
  let shorten-sub = tick-state.shorten-sub
  let length = inset + outset
  let angle = if align in (top, bottom) { 90deg } else { 0deg }

  let tick-stroke = if-none(
    merge-strokes(
      tick-state.stroke, 
      axis.stroke, (cap: "butt"), 
      e-get(spine).stroke
    ), 
    0.5pt  // can be none when spine.stroke is none
  ) 

  let tline = line(length: length, angle: angle, stroke: tick-stroke)
  let make-tick

  if align == right {
    make-tick = (label, loc) => place(dx: -outset, dy: loc, {tline + place(dx: -length - pad, right + horizon, label)})
  } else if align == left {
    make-tick = (label, loc) => place(dx: -length + outset, dy: loc, {tline + place(dx: length + pad, left + horizon, label)})
  } else if align == top {
    make-tick = (label, loc) => place(dy: -length + outset, dx: loc, {tline + place(dy: length + pad, top + center, label)});
  } else if align == bottom {
    make-tick = (label, loc) => place(dy: -outset, dx: loc, {tline + place(dy: -length - pad, bottom + center, label)})
  }

  
  let lq-tick-label = lq-tick-label.with(sub: sub, kind: axis.kind)
  labels = labels.map(label => if display-tick-labels { lq-tick-label(label) })

  let max-coordinate = (axis.transform)(axis.lim.at(if axis.kind == "x" { 1 } else { 0 }))

  let tick-collection = ticks.zip(labels)
    .map(
      ((tick, label)) => (
        value: tick, label: label, coordinate: (axis.transform)(tick)
      )
    )
    .filter(
      tick => (axis.filter)(
        tick.value, calc.min(tick.coordinate, max-coordinate - tick.coordinate)
      )
    )

  let content = tick-collection
    .map(tick => make-tick(tick.label, tick.coordinate))
    .join()

  for tick in axis.extra-ticks {
    if sub { break }
    let format-ticks = if-none(
      axis.format-ticks,
      tick-format.linear
    )

    if type(tick) in (int, float) {
      tick = lq-tick(
        tick, 
        label: format-ticks((tick,)).labels.first(),
        align: position.inv(),
        kind: axis.kind
      )
    }
    let label = e.fields(tick).at("label", default: none)

    let coordinate = (axis.transform)(e.fields(tick).value)
    if label != none {
      tick-collection.push(
        (value: e.fields(tick).value, coordinate: coordinate, label: label)
      )
    }
    let offset = if axis.kind == "x" { (dx: coordinate) } else { (dy: coordinate) }
    content += place(..offset, {
      show: e.set_(lq-tick, align: position.inv(), kind: axis.kind)
      show e.selector(lq-tick-label): it => {
        if display-tick-labels { it }
      }
      tick
    })
  }


  // Do not return unnecessary bounds 
  if tick-collection.len() == 0 {
    return (none, 0pt, none)
  }


  let cross-extent = outset
  let tick-bounds = _to-bounds(cross-extent, 0%, 100%, pos: position, inwards: inset)


  if display-tick-labels {
    let dimension = if axis.kind == "x" { "height" } else { "width" }
    let other-dimension = if axis.kind == "y" { "height" } else { "width" }


    let label-sizes = tick-collection.map(tick => {
      let size = measure(tick.label)
      let dim = size.at(other-dimension)
      size + (lower: tick.coordinate - dim/2, upper: tick.coordinate + dim/2)
    })

    let label-space = calc.max(0pt, ..label-sizes.map(s => s.at(dimension)))
    let start-space = 0%
    let end-space = 100%

    if bounds-mode == "strict" {
      start-space = calc.min(0pt, ..label-sizes.map(s => s.lower))
      end-space = calc.max(0pt, ..label-sizes.map(s => s.upper))
    }


    cross-extent += label-space
    if label-space > 0pt {
      cross-extent += pad
    }
    tick-bounds = _to-bounds(cross-extent, start-space, end-space, pos: position, inwards: inset)
  }

  // Erase size information from parent (data area). If the data-area is 
  // smaller than the axis, axis elements could otherwise be cropped. 
  content = place(
    box(width: float.inf * 1pt, height: float.inf * 1pt, content)
  )
  
  return (content, cross-extent.to-absolute(), tick-bounds)
}


// Places axis attachments like exponent and offset (if present)
// -> (result: content | none, bounds: dictionary | none)
#let place-attachments(
  /// The axis object.
  axis, 
  // The evaluated exponent value returned from the tick formatter.
  // -> int
  exp, 
  // The evaluated offset value returned from the tick formatter.
  // -> auto | int | float | content
  offset, 
  /// Where the axis is placed on the diagram. This can differ from @axis.
  /// position when drawing mirrows. 
  /// -> top | bottom | left | right
  position, 
) = {


  let attachment = none
  if type(offset) in (int, float) and offset != 0 {
    attachment += zero.num(positive-sign: true, offset)
  } else if offset not in (0, auto) {
    attachment += offset
  }
  if type(exp) == int and exp != 0 {
    attachment += {
      show "X": none
      zero.num("Xe" + str(exp))
    }
  }

  if attachment == none {
    return (none, none)
  }
  let args
  if axis.kind == "x" {
    args = (
      dx: .5em, dy: 0pt,
      alignment: bottom + right, 
      content-alignment: horizon + left
    )
    if position == top {
      args.dy -= 100%
    }
  } else if axis.kind == "y" {
    args = (
      dx: 0pt, dy: -.5em,
      alignment: top + left, 
      content-alignment: center + bottom
    )
    if position == right {
      args.dx += 100%
    }
  }

  place-with-bounds(attachment, ..args)
}


// Draws an axis and its mirror (if any)
#let draw-axis(
  axis,
  tick-info,
  orthogonal-axis-transform: none,
  e-get: none,
  bounds-mode: "relaxed",
  axes-count: (x: 1, y: 1),
) = {
  if axis.hidden { return (none, ()) }

  if axis.mirror == auto {
    if axes-count.at(axis.kind) > 1 {
      axis.mirror = none
    } else {
      axis.mirror = (ticks: true)
    }
  }

  let (ticks, tick-labels, subticks, subtick-labels, exp, offset) = tick-info
  
  

  // Draws a single axis (*or* a mirror)
  let the-axis(
    position: axis.position,
    display-ticks: true, 
    display-tick-labels: true, 
    display-axis-label: true,
    kind: "x"
  ) = {
    let content = none
    let space = 0pt
    let bounds = ()

    // Draw spine
    if axis.stroke != none {
      // TODO (later): use set rules here
      let args = (:)
      if axis.tip != auto { args.tip = axis.tip }
      if axis.toe != auto { args.toe = axis.toe }
      if axis.stroke != auto { args.stroke = axis.stroke }
      content += place(spine(kind: axis.kind, ..args))
    }

    if display-ticks {
      let (tick-content, tick-space, tick-bounds) = place-ticks(
        axis, ticks, tick-labels, position, display-tick-labels, e-get: e-get, bounds-mode: bounds-mode
      )
      if tick-content != none {
        bounds.push(tick-bounds)
        content += tick-content
      }
      let (subtick-content, subtick-space, subtick-bounds) = place-ticks(
        axis, subticks, subtick-labels, position, display-tick-labels, 
        sub: true, e-get: e-get, bounds-mode: bounds-mode
      )
      if subtick-content != none {
        bounds.push(subtick-bounds)
        content += subtick-content
      }
      space = calc.max(tick-space, subtick-space)
    }


    if display-tick-labels {
      let (att-content, att-bounds) = place-attachments(axis, exp, offset, position)
      if att-content != none {
        content += att-content
        bounds.push(att-bounds)
      }
    }
    


    if axis.label != none and display-axis-label {
      let label = axis.label
      if e.eid(label) != e.eid(lq-label) {
        let constructor = if kind == "x" { xlabel } else { ylabel }
        label = constructor(label)
      }

      
      let get-settable-field(element, object, field) = {
        e.fields(object).at(field, default: e-get(element).at(field))
      }

      let dx = get-settable-field(lq-label, label, "dx")
      let dy = get-settable-field(lq-label, label, "dy")
      let pad = get-settable-field(lq-label, label, "pad")

      if pad == none { 
        pad = 0pt
      } else {
        pad = pad.to-absolute() + space
      }


      let body = if position in (top, bottom) {
        box(width: 100%, height: float.inf*1pt, label)
      } else if position in (left, right) {
        box(height: 100%, width: float.inf * 1pt, label)
      }
      let size = measure(body)

      let (label-content, label-bounds) = place-with-bounds(
        body, alignment: position, dx: dx, dy: dy, pad: pad
      )
      
      content += label-content
      bounds.push(label-bounds)
    }


    // define box of axis spine
    content += block(
      ..if kind == "y" { (height: 100%, width: 0%) }
        else { (width: 100%, height: 0pt) },
      inset: 0pt, outset: 0pt
    )
    
    
    // let draw-bounds(b) = {
    //   place(
    //     dx: b.left, dy: b.top - 100%,
    //     rect(width: b.right - b.left, height: b.bottom - b.top, fill: blue.transparentize(60%))
    //   )
    // }
    // for b in bounds { content += draw-bounds(b) }
    return (content, bounds)
  }


  let orthogonal-offset = axis.orthogonal-offset
  if type(orthogonal-offset) in (int, float) {
    orthogonal-offset = orthogonal-axis-transform(orthogonal-offset)
    
    if axis.position in (bottom,  right) {
      orthogonal-offset -= 100%
    }
  }
  if axis.kind == "x" {
    orthogonal-offset = (0pt, orthogonal-offset)
  } else {
    orthogonal-offset = (orthogonal-offset, 0pt)
  }



  let (axis-content, bounds) = the-axis(kind: axis.kind)
  let content = place(
    axis.position, 
    axis-content, 
    dx: orthogonal-offset.at(0), 
    dy: orthogonal-offset.at(1)
  )


  if axis.mirror != none {
    let (mirror-axis-content, mirror-axis-bounds) = the-axis(
      kind: axis.kind,
      position: axis.position.inv(),
      display-ticks: axis.mirror.at("ticks", default: false),
      display-tick-labels: axis.mirror.at("tick-labels", default: false),
      display-axis-label: axis.mirror.at("label", default: false),
    )
    content += place(axis.position.inv(), mirror-axis-content)
    bounds += mirror-axis-bounds
  }
  
  return (content, bounds.map(b => offset-bounds(b, orthogonal-offset)))
}
