// Content fitting utilities adapted from Touying's fit-to-height and
// fit-to-width helpers.
//
// Touying: https://github.com/touying-typ/touying
// Original fitting work credited there to Andreas Kröpelin / Polylux PR #91
// and ntjess. Adaptation from Touying 0.7.4, commit a8abe0d.
// Used under the MIT License; see THIRD_PARTY_LICENSES.md.
#import "shared.typ": fail
#import "incremental/analysis.typ": max-step
#import "note/analysis.typ": has-note

#let reflow-scale(ratio, body) = scale(
  ratio,
  body,
  origin: top + left,
  reflow: true,
)

// Content already at its allocation measures as exactly `natural-ratio`, so
// that is the boundary between growing and shrinking rather than a tunable.
#let natural-ratio = 100%

// Measurement is not exact: a cell whose content fits to within a rounding
// error reports a ratio a hair off `natural-ratio`, and rescaling on that would
// resize content that was already correct. The tolerance is a numerical guard,
// not a design knob, which is why it is not configurable.
#let fit-tolerance = 0.05%

#let should-scale(ratio, grow, shrink) = (
  (shrink and ratio < natural-ratio - fit-tolerance)
    or (grow and ratio > natural-ratio + fit-tolerance)
)

// A fitter only has a problem to solve inside a real allocation. Under
// `measure` there is none: the region is reported unbounded, and a `1fr`
// height inside it resolves to zero. Both degenerate cases would drive the
// ratios to infinity or zero and make the refinement steps divide by zero, so
// the fitters detect them and return the body untouched. This is a routine
// path, not an edge case: `steps.replace` measures its alternatives, captions
// measure their frame, the speaker thumbnail measures a whole slide, and
// overflow observation measures every cell whenever it is switched on.
#let unsolvable(length) = (
  float.is-infinite(length.pt()) or float.is-nan(length.pt()) or length <= 0pt
)

// The one scale factor that brings a measured `size` into the space available
// on the axes that constrain it. `auto` leaves an axis unconstrained, and an
// axis whose measurement is zero constrains nothing, so a body with no extent
// on either axis reports the natural ratio and is left alone. Both public
// fitters and the speaker-view thumbnail derive their factor here, so the
// geometry is stated once.
#let fit-ratio(size, width: auto, height: auto) = {
  let ratios = ()
  if width != auto and size.width > 0pt {
    ratios.push(width / size.width)
  }
  if height != auto and size.height > 0pt {
    ratios.push(height / size.height)
  }
  if ratios.len() == 0 {
    return natural-ratio
  }
  calc.min(..ratios) * 100%
}

// Typst offers no numeric accessor for a `fraction`, so the only way to read
// one is to render it and parse the result: `repr(3fr)` is the string "3fr".
// Scaling by this factor first keeps the fractional digits that a bare `repr`
// would round away, and dividing it back out restores the value. The two uses
// below must stay the same number, which is why it is named once.
#let fraction-precision = 1000000

// Drops the trailing "fr" that `repr` appends.
#let fraction-unit-length = 2

#let size-to-pt(size, container-dimension) = {
  let resolved = size
  if type(size) == fraction {
    let fraction-text = repr(size * fraction-precision)
    resolved = float(
      fraction-text.slice(0, fraction-text.len() - fraction-unit-length),
    ) / fraction-precision
  }
  if type(resolved) in (int, float, ratio) {
    container-dimension * resolved
  } else {
    measure(v(resolved)).height
  }
}

// A width or height option resolved against the region that hosts it. `none`
// and `auto` both mean "use the whole region".
#let resolve-extent(value, container-dimension) = if value in (none, auto) {
  container-dimension
} else {
  size-to-pt(value, container-dimension)
}

#let limit-content-width(body, container-size) = box(
  width: calc.min(container-size.width, measure(body).width),
  body,
)

// Fits content to a width, shrinking or growing it only when requested.
#let fit-to-width(
  width: 1fr,
  grow: true,
  shrink: true,
  body,
) = layout(layout-size => {
  if unsolvable(layout-size.width) {
    return body
  }
  let content-width = measure(body).width
  let available-width = size-to-pt(width, layout-size.width)
  if unsolvable(available-width) {
    return body
  }
  let ratio = fit-ratio(
    (width: content-width, height: 0pt),
    width: available-width,
  )
  if content-width != 0pt and should-scale(ratio, grow, shrink) {
    reflow-scale(ratio, box(body, width: content-width))
  } else {
    body
  }
})

// Fits content to a finite height and width, scaling it geometrically.
#let fit-to-height(
  height: 1fr,
  width: auto,
  grow: true,
  shrink: true,
  body,
) = {
  let fitted = layout(container-size => {
    if unsolvable(container-size.width) or unsolvable(container-size.height) {
      return body
    }
    // A fractional height means "the space this block is given", which is the
    // whole region here; the enclosing `block(height: height)` below makes the
    // allocation real.
    let available-height = if type(height) == fraction {
      container-size.height
    } else {
      size-to-pt(height, container-size.height)
    }
    if unsolvable(available-height) {
      return body
    }
    let boxed-content = limit-content-width(body, container-size)
    let size = measure(boxed-content)
    if size.height == 0pt or size.width == 0pt {
      return body
    }

    let available-width = resolve-extent(width, container-size.width)
    if unsolvable(available-width) {
      return body
    }
    let ratio = fit-ratio(size, width: available-width, height: available-height)

    if should-scale(ratio, grow, shrink) {
      reflow-scale(ratio, boxed-content)
    } else {
      body
    }
  })
  if type(height) == fraction {
    block(height: height, fitted)
  } else {
    fitted
  }
}

// Scales content as it stands, without offering it a narrower width first.
// Content that reflows would rearrange itself into the region and never need
// scaling; content that cannot, a table or a diagram, keeps its proportions and
// is scaled by whichever axis binds.
#let fit-unwrapped(width, height, grow, shrink, body) = layout(region => {
  if unsolvable(region.width) or unsolvable(region.height) {
    return body
  }
  let available-width = resolve-extent(width, region.width)
  let available-height = resolve-extent(height, region.height)
  if unsolvable(available-width) or unsolvable(available-height) {
    return body
  }
  let size = measure(body)
  let ratio = fit-ratio(size, width: available-width, height: available-height)
  if should-scale(ratio, grow, shrink) {
    reflow-scale(ratio, box(body, width: size.width))
  } else {
    body
  }
})

/// Scales one block of content to the space it is given.
///
/// Mosaic never resizes body content on its own, so a slide holding more than
/// it can show reports an overflow rather than shrinking. `fit` is the explicit
/// per-block exception, for content whose size the author does not control: a
/// wide table, a chart, a generated list, a number meant to fill the slide.
///
/// It measures the content against the region the call sits in and scales it
/// geometrically, so proportions are preserved and the surrounding layout
/// accounts for the new size. With no `width` or `height` it fits the whole
/// region.
///
/// ```typ
/// #mosaic.slide[
///   == A long argument
///   #mosaic.fit(generated-list)
/// ]
/// ```
///
/// Fitting works in cells, in the `background` and `foreground` planes, and in
/// ordinary content. Pass `grow: true` for display type that should fill its
/// cell rather than merely avoid overflowing it:
///
/// ```typ
/// #mosaic.fit(grow: true)[42%]
/// ```
///
/// *Content that must not be re-laid out*
///
/// By default the content is offered the region's width first, so text and
/// lists wrap into the cell and are scaled only if they are still too tall.
/// A table, chart, or diagram would rearrange its own columns instead, which
/// changes the composition rather than its size. Pass `wrap: false` to scale
/// such a block exactly as it stands:
///
/// ```typ
/// #mosaic.fit(wrap: false, my-wide-table)
/// ```
///
/// *Overflow*
///
/// A fitted block cannot overflow, so it emits no `<mosaic-overflow-warning>`
/// record and never fails an `overflow: "error"` compile. A cell that fits its
/// content therefore stops reporting how full it is.
///
/// *Incremental content and speaker notes*
///
/// Fitting measures its body, which means holding it inside a closure that the
/// slide runtime cannot look into. Incremental markers and speaker notes are
/// found by walking the slide's content, so anything inside a fitted block
/// would be invisible to that walk: the reveals would collapse into one frame
/// and the notes would vanish. `fit` rejects such a body rather than dropping
/// it silently. Keep `pause`, `steps`, and `note` outside the fitted block, or
/// fit each revealed part on its own.
///
/// -> content
#let fit(
  /// The content to scale.
  /// -> content
  body,
  /// Width to fit into. `auto` uses the full width of the region.
  /// -> auto | length | relative | fraction
  width: auto,
  /// Height to fit into. `auto` uses the full height of the region.
  /// -> auto | length | relative | fraction
  height: auto,
  /// Let the content re-lay out at the available width before it is measured.
  /// Pass `false` for a block whose own arrangement must be preserved.
  /// -> bool
  wrap: true,
  /// Scale content up when it is smaller than the space available.
  /// -> bool
  grow: false,
  /// Scale content down when it is larger than the space available.
  /// -> bool
  shrink: true,
) = {
  // Measuring means capturing the body in a closure, where the runtime's
  // incremental and note walks cannot reach it. Refusing here is the difference
  // between a diagnostic and a deck that quietly loses its reveals.
  // `has-note` rather than `notes-at(body, 1).len() > 0`: this is a yes/no
  // question, and the extraction form builds an array of every note just to
  // test it for emptiness. A cell with `fit` runs this on every frame.
  if max-step(body) > 1 or has-note(body) {
    fail(
      "fit cannot hold incremental steps or speaker notes; they would be "
        + "invisible to the slide runtime. Move pause, steps, and note outside "
        + "the fitted block, or fit each revealed part separately",
    )
  }
  if not wrap {
    return fit-unwrapped(width, height, grow, shrink, body)
  }
  // A width alone is the one case that must not consult the height: fitting a
  // single line to a column is a width problem, and the region's height would
  // otherwise bind first and shrink it further than asked.
  if width != auto and height == auto {
    fit-to-width(width: width, grow: grow, shrink: shrink, body)
  } else {
    fit-to-height(
      height: if height == auto { 1fr } else { height },
      width: width,
      grow: grow,
      shrink: shrink,
      body,
    )
  }
}
