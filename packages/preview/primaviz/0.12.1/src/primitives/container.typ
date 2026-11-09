// container.typ - Chart container wrapper

#import "../theme.typ": *
#import "./title.typ": draw-title

/// Fallback inset for non-theme contexts (e.g. heatmap overhead calc).
/// Charts should use theme.container-inset instead.
#let container-inset = 8pt

/// Space between a chart and a legend beside it.
#let legend-gap = 10pt

// Wraps a chart body in a box with optional background/border, a title and
// subtitle, and a legend (above, below or beside the body, per
// `theme.legend-position`).
//
// The container is as tall as what it holds: title block, legend and a
// `height`-tall body, laid out and measured by Typst itself, so nothing has to be
// reserved for them and nothing can overflow or leave a dead band. A legend
// beside the body adds its width (`legend-width`: `auto`, the default, is the
// legend's own width); when it is taller than the body the container grows to it.
// Light and dark themes render at the same outer size: the border takes the same
// inset in both.
//
// - width, height: size of the body (the chart without title, legend or inset)
// - legend: legend content, or `none`
// - legend-width: width of a legend beside the body: a length, or `auto` to
//   measure the legend
// - extra-legend-separation: extra space between legend and body
#let chart-container(width, height, title, theme, legend: none, legend-width: auto, extra-legend-separation: 0pt, subtitle: none, radius: 0pt, body) = {
  let pad = theme.at("container-inset", default: container-inset)
  let lp = theme.legend-position
  let side-legend = (lp == "right" or lp == "left") and legend != none
  let gap = if side-legend { legend-gap } else { 0pt }
  let build(legend-width) = box(
    width: if side-legend { width + gap + legend-width + 2 * pad } else { width + 2 * pad },
    fill: theme.background,
    stroke: theme.border,
    inset: pad,
    radius: radius,
  )[
    // Charts are sized by the theme, not the document: pin the ambient text
    // size (Typst's default) and the flow spacing that follows from it, so the
    // gaps between title, legend and body and the leading of a wrapped legend
    // don't shift with the document's `set text(size: ..)`.
    #set text(size: 11pt)
    #set par(leading: 0.65em, spacing: 1.2em)
    #draw-title(title, theme, subtitle: subtitle)
    #if lp == "top" and legend != none {
      legend
      v(extra-legend-separation)
    }
    #if lp == "right" and legend != none {
      context {
        let legend-h = measure(width: legend-width, legend).height
        // Center legend relative to chart; allow negative dy when legend is taller
        let legend-dy = (height - legend-h) / 2
        let content-h = calc.max(height, legend-h)
        // Shift both chart and legend down if legend extends above chart
        let base-dy = if legend-dy < 0pt { -legend-dy } else { 0pt }
        box(width: width + legend-gap + legend-width, height: content-h)[
          #place(left + top, dy: base-dy, box(width: width, height: height, body))
          #place(left + top, dx: width + legend-gap + extra-legend-separation, dy: base-dy + legend-dy,
            box(width: legend-width, legend))
        ]
      }
    } else if lp == "left" and legend != none {
      context {
        let legend-h = measure(width: legend-width, legend).height
        let legend-dy = (height - legend-h) / 2
        let content-h = calc.max(height, legend-h)
        let base-dy = if legend-dy < 0pt { -legend-dy } else { 0pt }
        box(width: width + legend-gap + legend-width, height: content-h,)[
          #place(left + top, dy: base-dy + legend-dy, dx: -extra-legend-separation,
            box(width: legend-width, legend))
          #place(left + top, dx: legend-width + legend-gap, dy: base-dy,
            box(width: width, height: height, body))
        ]
      }
    } else {
      body
      if legend != none and lp == "bottom" {
        v(extra-legend-separation)
        legend
      }
    }
  ]
  // A legend beside the body, as wide as its content
  if side-legend and legend-width == auto {
    context build(measure({ set text(size: 11pt); set par(leading: 0.65em, spacing: 1.2em); legend }).width)
  } else {
    build(legend-width)
  }
}
