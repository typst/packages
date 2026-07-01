#import "../logic/scale.typ" as lqscale
#import "../utility.typ": place-in-out, match, match-type, if-auto, if-none
#import "../algorithm/ticking.typ"
#import "../bounds.typ": *
#import "../assertations.typ"
#import "../model/label.typ": xlabel, ylabel, label as lq-label
#import "../process-styles.typ": update-stroke, merge-strokes
#import "@preview/elembic:1.1.0" as e

#import "tick.typ": tick as lq-tick, tick-label as lq-tick-label
#import "spine.typ": spine

#import "@preview/zero:0.4.0"
#import "@preview/tiptoe:0.3.1"



/// An axis for a diagram. Visually, an axis consists of a _spine_ along the axis 
/// direction, a collection of ticks/subticks and an axis label. 
/// 
/// By default, a @diagram features two axes: an `x` and a `y` axis which can be 
/// configured directly through @diagram.xaxis and @diagram.yaxis. However, it is 
/// also possible to add more axes, please refer to the 
/// #link("tutorials/axis")[axis tutorial] for more details. 
/// 
/// The built-in tick formatters use the Typst package
/// #link("https://typst.app/universe/package/zero")[Zero] for displaying
/// numbers. This makes it possible to define a consistent number format 
/// throughout the entire document, including tables, in-text quantities,
/// and figures. 
#let axis(

  /// Sets the scale of the axis. This may be a @scale object or the name of 
  /// one of the built-in scales `"linear"`, `"log"`, `"symlog"`.
  /// -> lq.scale | str 
  scale: "linear", 

  /// Data limits of the axis. This can be used to fix the minimum and/or maximum value
  /// displayed along this axis. This parameter expects `auto` or a tuple `(min, max)` 
  /// where `min` and `max` can also be `auto`. If a limit is `auto`, it will be 
  /// automatically computed from all plots associated with this axis and @diagram.margin 
  /// will be applied. If the minimum is larger than the maximum, the scale is inverted
  /// and if `min` and `max` coincide, the range will be automatically increased. 
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
  /// - or a combination of the first and third option through a dictionary 
  ///   with the keys `align` and `offset`. 
  /// 
  /// More on axis placement can be found in the 
  /// #link("tutorials/axis#placement-and-mirrors")[axis tutorial]. 
  /// -> auto | alignment | float | relative | dictionary
  position: auto, 

  /// Whether to mirror the axis, i.e., whether to show the axis ticks also on 
  /// the side opposite of the one specified with @axis.position. When set to 
  /// `auto`, mirroring is only activated when `position: auto`. More control
  /// is granted through a dictionary with the possible keys `ticks` and 
  /// `tick-labels` to individually activate or deactivate those. 
  /// 
  /// More on axis mirrors can be found in the 
  /// #link("tutorials/axis#placement-and-mirrors")[axis tutorial]. 
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
  /// -> auto | float
  offset: auto,

  /// Exponent for all ticks on this axis. All ticks are divided by 
  /// $10^\mathrm{exponent}$ and the $10^\mathrm{exponent}$ is shown at the end
  /// of the axis (if the exponent is not 0). This setting can be used to avoid
  /// overly long tick labels. 
  /// 
  /// In combination with logarithmic tick locators, `none` can be used to 
  /// force writing out all numbers. 
  /// -> auto | none | int | "inline"
  exponent: auto,

  /// Threshold for automatic exponents. 
  /// -> int
  auto-exponent-threshold: 3,

  /// The tick locator for the regular ticks. 
  /// Also see #link("tutorials/ticks#locating-ticks")[locating ticks]. 
  /// -> auto | function
  locate-ticks: auto,
  
  /// The formatter for the (major) ticks. 
  /// Also see #link("tutorials/ticks#formatting-ticks")[formatting ticks]. 
  /// -> auto | function
  format-ticks: auto,
  
  /// The tick locator for the subticks. 
  /// Also see #link("tutorials/ticks#locating-ticks")[locating ticks]. 
  /// -> auto | function
  locate-subticks: auto,
  
  /// The formatter for the subticks. 
  /// Also see #link("tutorials/ticks#displaying-subtick-labels")[displaying subticks]. 
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
  /// `m`. Note that the first function computes the "forward" direction while
  /// the second function computes the "backward" direction. The user needs to 
  /// ensure that the two functions are really inverses of each other. 
  /// By default, this parameter resolves to the identity. 
  /// -> auto | array
  functions: auto,

  /// If set to `true`, the entire axis is hidden. 
  /// -> bool
  hidden: false,

  /// How to stroke the spine of the axis. If not `auto`, this is forwarded to 
  /// @spine.stroke. 
  /// -> auto | stroke
  stroke: auto,

  /// Places an arrow tip on the axis spine. This expects a mark as specified by
  /// the #link("https://typst.app/universe/package/tiptoe")[tiptoe package]. 
  /// If not `auto`, this is forwarded to @spine.tip. 
  /// -> auto | none | tiptoe.mark
  tip: auto,

  /// Places an arrow tail on the axis spine. This expects a mark as specified by 
  /// the #link("https://typst.app/universe/package/tiptoe")[tiptoe package]. 
  /// If not `auto`, this is forwarded to @spine.toe. 
  /// -> auto | none | tiptoe.mark
  toe: auto,

  filter: (value, distance) => true,

  /// Plot objects to associate with this axis. This only applies when this is 
  /// a secondary axis. Automatic limits are then computed according to this 
  /// axis and transformations of the data coordinates linked to the scaling of
  /// this axis. 
  /// -> any
  ..plots
  
) = {
  assertations.assert-no-named(plots)
  plots = plots.pos()
  if "tick-distance" not in tick-args {
    tick-args.tick-distance = tick-distance
  }
  if type(scale) == str {
    assert(scale in lqscale.scales, message: "Unknown scale " + scale)
    scale = lqscale.scales.at(scale)
  }
  assert(kind in ("x", "y"), message: "The `kind` of an axis can only be `x` or `y`")
  let translate = (0pt, 0pt)


  if position == auto {
    if kind == "x" { position = bottom }
    else if kind == "y" { position = left }
  } else if type(position) in (int, float, length, relative, ratio) {
    if kind == "x" { 
      translate = (0pt, position)
      position = bottom 
    }
    else if kind == "y" { 
      translate = (position, 0pt)
      position = left 
    }
    if mirror == auto { mirror = none }
  } else if type(position) == dictionary {
    assertations.assert-dict-keys(position, mandatory: ("align", "offset"))

    
    (position, translate) = (position.align, position.offset)
    if kind == "x" { translate = (0pt, translate) }
    else if kind == "y" { translate = (translate, 0pt) }
    if mirror == auto { mirror = none }
    
    if kind == "x" {
      assert(position in (top, bottom), message: "For x-axes, `position` can only be \"top\" or \"bottom\", got " + repr(position))
    }
    if kind == "y" {
      assert(position in (left, right), message: "For y-axes, `position` can only be \"left\" or \"right\", got " + repr(position))
    }
  } else if type(position) == alignment {
    if mirror == auto { mirror = none }
    
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
      locate-ticks = ticking.locate-ticks-manual.with(ticks: ticks.ticks.zip(ticks.labels))
      if "labels" in ticks {
        format-ticks = ticking.format-ticks-manual 
      }
    } else if type(ticks) == array {
      if ticks.len() > 0 and type(ticks.first()) == array {
        // let (ticks, labels) = array.zip(..ticks)
        locate-ticks = ticking.locate-ticks-manual.with(ticks: ticks)
        format-ticks = ticking.format-ticks-manual 
      } else {
        locate-ticks = ticking.locate-ticks-manual.with(ticks: ticks)
      }
    } else if ticks == none {
      locate-ticks = none
      format-ticks = none
    } else { assert(false, message: "The parameter `ticks` may either be an array or a dictionary")}
  }
  
  if locate-ticks == auto {
    locate-ticks = if-none(scale.locate-ticks, ticking.locate-ticks-linear)
  }
  if format-ticks == auto {
    format-ticks = match(
      scale.name,
      "linear", () => ticking.format-ticks-linear,
      "log", () => ticking.format-ticks-log.with(base: scale.base),
      "symlog", () => ticking.format-ticks-symlog.with(base: scale.base, threshold: scale.threshold, linscale: scale.linscale),
      default: () => ticking.format-ticks-naive
    )
  }
  if subticks == none {
    locate-subticks = none
  } else if type(subticks) == int {
    locate-subticks = ticking.locate-subticks-linear.with(num: subticks)
  } else if subticks != auto {
    assert(false, message: "Unsupported argument type `" + str(type(subticks)) + "` for parameter `subticks`")
  }
  if locate-subticks == auto {
    locate-subticks = if-none(scale.locate-subticks, none)
  }
  let is-independant = plots.len() > 0
  if functions == auto { functions = (x => x, x => x) }
  else {
    assert(type(functions) == array and functions.map(type) == (function, function), message: "The parameter `functions` for `axis()` expects an array of two functions, a forward and an inverse function.")
    assert(plots.len() == 0, message: "An `axis` can either be created with `functions` or with `..plots` but not both. ")
    assert(lim == auto, message:  "A dependent `axis` with `functions` is not allowed to have manual axis limits. ")
  }

  if type(lim) == array {
    assert.eq(lim.len(), 2, message: "Limit arrays must contain exactly two items")
    
  } else if lim == auto { 
    lim = (auto, auto)
  } else {
    assert(false, message: "Unsupported limit specification")
  }

  if mirror == auto {
    mirror = (ticks: true)
  } else if type(mirror) == bool {
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
    functions: (forward: functions.at(0), inv: functions.at(1)),
    label: label,
    stroke: stroke,
    kind: kind,
    position: position,
    translate: translate,
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
  lower-margin: 0%, upper-margin: 0%,
  default-lim: (0, 1),
  is-independant: auto
) = {
  if is-independant == auto {
    is-independant = axis.plots.len() > 0
  }
  let axis-type = match(axis.kind, "x", "x", "y", "y")
  let (x0, x1) = (none, none)
  let (tight0, tight1) = (true, true)
  

  if axis.lim.at(0) != auto { x0 = axis.lim.at(0); tight0 = true }
  if axis.lim.at(1) != auto { x1 = axis.lim.at(1); tight1 = true }
  
  if auto in axis.lim {
    if is-independant {
      let plot-limits = axis.plots.map(plot => plot.at(axis-type + "limits")())
        .filter(x => x != none)
      if plot-limits.len() == 0 {
        (x0, x1) = (0, 1)
        if axis.scale.identity != 0 {
          (x0, x1) = (axis.scale.identity,) * 2
        }
      } else {
        for (plot-x0, plot-x1) in plot-limits {
          let tight-bound = (false, false)
          if type(plot-x0) == fraction { plot-x0 /= 1fr; tight-bound.at(0) = true }
          if axis.lim.at(0) == auto and plot-x0 != none and (x0 == none or plot-x0 < x0) {
            x0 = plot-x0
            tight0 = tight-bound.at(0)
          }
          if type(plot-x1) == fraction { plot-x1 /= 1fr; tight-bound.at(1) = true }
          if axis.lim.at(1) == auto and plot-x0 != none and (x1 == none or plot-x1 > x1) {
            x1 = plot-x1
            tight1 = tight-bound.at(1)
          }
        }
      }
    } else {
      (x0, x1) = default-lim.map(axis.functions.forward)
    }
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

  if not tight0 {
    x0 = (axis.scale.inverse)(k0 - D * lower-margin/100%)
  }
  if not tight1 {
    x1 = (axis.scale.inverse)(k1 + D * upper-margin/100%)
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

  let em = measure(line(length: 1em, angle: 0deg)).width
  axis.tick-args.num-ticks-suggestion = match(
    axis.kind,
    "x", length / (3.3 * em),
    "y", length / (2 * em)
  )
  let (x0, x1) = axis.lim
  

  if x1 < x0 {
    (x1, x0) = (x0, x1)
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
        offset: axis.offset, 
        auto-exponent-threshold: axis.auto-exponent-threshold
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
      if "offset" in format-result {
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



// Draws an axis and its mirror (if any)
#let draw-axis(
  axis,
  tick-info,
  e-get: none
) = {
  if axis.hidden { return (none, ()) }

  let (ticks, tick-labels, subticks, subtick-labels, exp, offset) = tick-info
  

  // Places a set of ticks together with labels
  let place-ticks(
    ticks, 
    labels, 
    // Where to place the ticks on the diagram
    position, 
    // Whether to show tick labels
    display-tick-labels, 
    sub: false,
    kind: "x",
    extra-ticks: ()
  ) = {
    if labels == none { labels = (none,) * ticks.len() }
    
    let align = position.inv()
    let pad = e-get(lq-tick).pad
    let factor = if sub { 1 - (e-get(lq-tick).shorten-sub / 100%) } else { 1 }
    let outset = e-get(lq-tick).outset * factor
    let shorten-sub = e-get(lq-tick).shorten-sub
    let length = e-get(lq-tick).inset * factor + outset
    let angle = if align in (top, bottom) { 90deg } else { 0deg }
  
    let tick-stroke = if-none(
      merge-strokes(
        e-get(lq-tick).stroke, 
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

    let max-value = (axis.transform)(axis.lim.at(if kind == "x" { 1 } else { 0 }))
    
    let lq-tick-label = lq-tick-label.with(sub: sub, kind: kind)

    let content = ticks.zip(labels).map(
      ((tick, label)) => {
        let loc = (axis.transform)(tick)
        if not (axis.filter)(tick, calc.min(loc, max-value - loc)) { return }
        let tick-label = if display-tick-labels { label }
        if tick-label != none {tick-label = lq-tick-label(tick-label)}
        make-tick(tick-label, loc)
      }
    ).join()

  
    for tick in extra-ticks {
      let format-ticks = if-none(
        axis.format-ticks,
        ticking.format-ticks-linear
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
      if label != none { labels.push(label) }

      let loc = (axis.transform)(e.fields(tick).value)
      let offset = if kind == "x" { (dx: loc) } else { (dy: loc) }
      content += place(..offset, {
        show: e.set_(lq-tick, align: position.inv(), kind: axis.kind)
        show e.selector(lq-tick-label): it => {
          if display-tick-labels { it }
        }
        tick
      })
    } // end extra-ticks


    let max-padding = outset
    let max-width = 0pt

    if display-tick-labels {
      let dimension = if axis.kind == "x" { "height" } else { "width" }

      let label-space
      (label-space, max-width) = labels
        .map(label => {
          let measured = measure(label)
          (measured.at(dimension), measured.width)
        })
        .fold(
          (0pt, 0pt),
          ((max-dim, max-w), (next-dim, next-w)) => (calc.max(max-dim, next-dim), calc.max(max-w, next-w)),
        )

      max-padding += label-space
      if label-space > 0pt {
        max-padding += pad
      }
    }

    // Prevent ticks from line-wrapping by boxing them in enough space.
    if kind == "x" {
      content = place(box(width: max-width, content))
    } else {
      content = place(box(width: max-padding, content))
    }
    
    return (content, max-padding)
  }
  

  // Draws a single axis (*or* a mirror)
  let the-axis(
    position: axis.position,
    translate: (0pt, 0pt),
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
      let (tick-content, tick-space) = place-ticks(
        ticks, tick-labels, position, display-tick-labels, kind: kind, extra-ticks: axis.extra-ticks
      )
      content += tick-content
      space = tick-space

      let (subtick-content, _) = place-ticks(
        subticks, subtick-labels, position, display-tick-labels, 
        sub: true, kind: kind
      )
      content += subtick-content

    }


    if display-tick-labels {

      let attachment = none
      if type(offset) in (int, float) and offset != 0 {
        attachment += zero.num(positive-sign: true, offset)
      }
      if type(exp) == int and exp != 0 {
        attachment += {
          show "X": none
          zero.num("Xe" + str(exp))
        }
      }

      if attachment != none {
        let args
        if axis.kind == "x" {
          args = (
            dx: .5em, dy: 0pt,
            alignment: bottom + right, 
            content-alignment: horizon + left
          )
        } else if axis.kind == "y" {
          args = (
            dx: 0pt, dy: -.5em,
            alignment: top + left, 
            content-alignment: center + bottom
          )
        }

        let (attachment-content, attachment-bounds) = place-with-bounds(
          attachment,
          ..args
        )
        content += attachment-content
        attachment-bounds = offset-bounds(attachment-bounds, translate)
        bounds.push(attachment-bounds)
      }
    }
    


    if axis.label != none and display-axis-label {

      space = space.to-absolute()
      
      let label = axis.label
      if e.eid(label) != e.eid(lq-label) {
        let constructor = if kind == "x" { xlabel } else { ylabel }
        label = constructor(label)
      }

      let wrap-label = if position in (top, bottom) {
        box.with(width: 100%)
      } else if position in (left, right) {
        box.with(height: 100%)
      }
      
      let get-settable-field(element, object, field) = {
        e.fields(object).at(field, default: e-get(element).at(field))
      }

      let dx = get-settable-field(lq-label, label, "dx")
      let dy = get-settable-field(lq-label, label, "dy")
      let pad = get-settable-field(lq-label, label, "pad").to-absolute()

      if pad == none { 
        pad = 0pt
      } else { 
        pad += space
      }


      let body = wrap-label(label)
      let size = measure(body)

      let (label-content, _) = place-with-bounds(
        body, alignment: position, dx: dx, dy: dy, pad: pad
      )
      
      content += label-content

      if kind == "x" {
        space = calc.max(space, size.height + pad)
      } else {
        space = calc.max(space, size.width + pad)
      }
    }


    // define box of axis spine
    content += block(
      ..if kind == "y" { (height: 100%, width: 0%) }
        else { (width: 100%, height: 0pt) },
      inset: 0pt, outset: 0pt
    )
    
    let main-bounds = create-bounds()
    let inset = e-get(lq-tick).inset
    if axis.kind == "x" {
      main-bounds.right = 100%
      if position == top {
        main-bounds.top = -space
        main-bounds.bottom = inset
      } else if position == bottom {
        main-bounds.bottom = 100% + space
        main-bounds.top = 100% - inset
      }
    } else {
      main-bounds.bottom = 100%
      if position == left {
        main-bounds.left = -space
        main-bounds.right = inset
      } else if position == right {
        main-bounds.right = 100% + space
        main-bounds.left = 100% - inset
      }
    }
    main-bounds = offset-bounds(main-bounds, translate)
    bounds.push(main-bounds)
    return (content, bounds)
  }



  let (axis-content, bounds) = the-axis(kind: axis.kind, translate: axis.translate)
  let content = place(
    axis.position, 
    axis-content, 
    dx: axis.translate.at(0), 
    dy: axis.translate.at(1)
  )


  if axis.mirror != none {
    let (mirror-axis-content, mirror-axis-bounds) = the-axis(
      kind: axis.kind,
      position: axis.position.inv(),
      translate: axis.translate,
      display-ticks: axis.mirror.at("ticks", default: false),
      display-tick-labels: axis.mirror.at("tick-labels", default: false),
      display-axis-label: axis.mirror.at("label", default: false),
    )
    content += place(axis.position.inv(), mirror-axis-content)
    bounds += mirror-axis-bounds
  }
  
  return (content, bounds)
}
