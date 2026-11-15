#import "../core/internal.typ": *
#import "../core/native.typ": *
#import "../core/html.typ": _deixis-html-anchor, _deixis-html-link

#let _deixis-render-inline-mark(
  body,
  marker-style: it => super(it),
  marker-position: auto,
  inline-mode: auto,
  stroke: auto,
  fill: auto,
  radius: auto,
  marker-str: none,
  mark-lbl: none,
  body-lbl: none,
  origin: none,
) = {
  _deixis-setup-guard()

  let render-formatting(content, inline-marker: none, is-left: false) = {
    if content == none { return none }

    if inline-mode == "text-fill" {
      assert(type(stroke) != dictionary,
        message: "deixis: text-fill requires a single stroke or none, not edge strokes. Set a mark color separately from body edges.")
      if stroke == none or stroke.paint == auto { return content }
      return text(fill: stroke.paint, content)
    }

    let edges = if type(stroke) == dictionary { deixis-utils.get-stroke(stroke) } else { none }

    let _underline(it, stroke: auto, ..args) = if stroke != none { _std-underline(it, stroke: stroke, ..args) } else {
      it
    }

    let new-body = content
    if inline-mode not in ("none", none) {
      let padding = text-padding
      padding.x *= 2
      let has-marker = inline-marker != none
      if has-marker {
        padding = padding.pairs().map(((key, value)) => (key, value.to-absolute())).to-dict()
      }
      let outer-radius(side) = if type(radius) == dictionary {
        // Keep native corner/side/rest precedence, squaring the adjoining edge.
        radius + if side == left { (top-right: 0pt, bottom-right: 0pt) }
          else { (top-left: 0pt, bottom-left: 0pt) }
      } else { (repr(side): radius) }
      if inline-mode in ("box", "underline") {
        new-body = _underline(stroke: if edges == none { stroke } else { edges.bottom }, offset: padding.bottom, new-body)
      }
      if fill not in (auto, none) {
        new-body = highlight(new-body, fill: fill,
          ..(if has-marker and inline-mode != "highlight" {
            (top-edge: padding.top, bottom-edge: -padding.bottom)
          } else { (:) }),
          radius: if has-marker and inline-mode in ("highlight", "underline") {
            outer-radius(if is-left { right } else { left })
          } else if inline-mode not in ("box", "parentheses") {
            radius
          } else { 0pt })
      }
      let cap-line(side) = box(
        height: 0pt,
        width: padding.x,
        outset: (bottom: padding.bottom, top: padding.top),
        stroke: if edges == none {
          (rest: stroke, (if side == left { "right" } else { "left" }): none)
        } else { edges + ((if side == left { "right" } else { "left" }): none) },
        fill: fill,
        radius: outer-radius(side),
      )
      if has-marker {
        if inline-mode == "box" {
          new-body = _underline(stroke: if edges == none { stroke } else { edges.top },
            offset: -padding.top, new-body)
        }
        // Measure the label-free styled marker: measuring labels or links
        // would make their own locations part of the layout feedback.
        let marker-width = measure(marker-style(marker-str)).width
        let marker-outset = (top: padding.top, bottom: padding.bottom)
        if inline-mode == "highlight" {
          marker-outset = (
            top: measure(text(top-edge: highlight.top-edge, bottom-edge: "baseline", [#sym.zws])).height,
            bottom: measure(text(top-edge: "baseline", bottom-edge: highlight.bottom-edge, [#sym.zws])).height,
          )
        }
        // Paint at the passage baseline, outside native decorations. The
        // marker retains its own ascent, descent and superscript placement.
        let marker-cell = box[
          #box(height: 0pt, width: marker-width, outset: marker-outset,
            stroke: (
              top: if inline-mode == "box" { if edges == none { stroke } else { edges.top } } else { none },
              bottom: if inline-mode in ("box", "underline") { if edges == none { stroke } else { edges.bottom } } else { none },
            ), fill: fill,
            radius: if inline-mode in ("highlight", "underline") { outer-radius(if is-left { left } else { right }) } else { 0pt },
          )#h(-marker-width)#inline-marker
        ]
        new-body = if is-left { [#marker-cell#sym.wj#new-body] } else { [#new-body#sym.wj#marker-cell] }
        if inline-mode in ("box", "parentheses") {
          new-body = [#cap-line(left)#new-body#cap-line(right)]
        }
      } else if inline-mode == "box" {
        new-body = _underline(stroke: if edges == none { stroke } else { edges.top },
          offset: -padding.top, [#cap-line(left)#new-body#cap-line(right)])
      } else if inline-mode == "parentheses" {
        new-body = [#cap-line(left)#new-body#cap-line(right)]
      }
    }
    return new-body
  }

  // HTML has no boxes with outsets or negative spacing: keep native text
  // decorations on the passage and attach the marker after/before it.
  let render-html(content, inline-marker: none, is-left: false) = {
    let decorated = if content == none { none } else if inline-mode == "text-fill" { render-formatting(content) } else {
      let it = content
      if inline-mode in ("box", "underline") and stroke != none { it = _std-underline(it) }
      if fill not in (auto, none) { it = highlight(fill: fill, it) }
      it
    }
    if inline-marker == none { decorated } else if is-left { [#inline-marker#decorated] } else { [#decorated#inline-marker] }
  }

  // Native show-rule scope distinguishes live output from detached sizing.
  // Keep the visible marker/style in measurement without publishing destinations
  // or resolving a link to a body that may not have been laid out yet.
  let emit(detached) = {
    let safe-lbl = if detached { none } else if origin != none { origin }
      else if mark-lbl != none { [#metadata((internal-id: str(mark-lbl).slice("deixis-mark-".len())))<deixis-mark-destination>#metadata(none)#mark-lbl#_deixis-html-anchor(mark-lbl)] } else { none }

    let inline-marker = if detached and (origin != none or mark-lbl != none) and body-lbl != none {
      if marker-str != none { marker-style(marker-str) }
    } else if safe-lbl != none and body-lbl != none {
      if marker-str == none {
        [#safe-lbl]
      } else {
        let body-exists = query(selector(body-lbl)).len() > 0
        let raw-m = marker-style(marker-str)
        if body-exists {
          [#safe-lbl#_deixis-html-link(body-lbl, raw-m)]
        } else {
          [#safe-lbl#raw-m]
        }
      }
    } else {
      none
    }

    let is-left = marker-position in ("left", left)
    let glue = [#h(0pt, weak: true)#sym.wj]
    if _std-target() == "html" {
      return [#if body == none { glue }#render-html(body, inline-marker: inline-marker, is-left: is-left)]
    }
    if body == none {
      if inline-marker != none {
        return [#glue#inline-marker]
      } else {
        return [#glue]
      }
    } else {
      if marker-str != none and inline-marker != none and inline-mode in ("box", "underline", "parentheses", "highlight") {
        return render-formatting(body, inline-marker: inline-marker, is-left: is-left)
      }
      let combined-body = if inline-marker != none {
        if is-left { [#inline-marker#body] } else { [#body#inline-marker] }
      } else { body }

      return render-formatting(combined-body)
    }
  }
  [#metadata(emit)<deixis-inline-mark-output>]
}

// Most existing adapters use this contextual entry point. Repeat marks already
// resolve in context and call the painter directly to avoid another layout pass.
#let _deixis-inline-mark(..args) = context _deixis-render-inline-mark(..args)
