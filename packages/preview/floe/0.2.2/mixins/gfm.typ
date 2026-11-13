// ============================================================================
// FLOE DESIGN SYSTEM — GITHUB FLAVORED MARKDOWN (GFM) MIXIN (mixins/gfm.typ)
// Direct Cmarker / Markdown Interoperability Layer
// Automatically maps GFM Alert Blocks (> [!NOTE], > [!WARNING], etc.) to Floe UI Alerts
// ============================================================================
#import "../core/lib.typ": *
#import "../primitives/lib.typ": alert
#import "../components/alerts.typ": note, tip, warning, pitfall

/// Direct GFM Alert Primitives
#let gfm-note(body)      = note(body)
#let gfm-tip(body)       = tip(body)
#let gfm-important(body) = alert(variant: "tip", title: "IMPORTANT", body)
#let gfm-warning(body)   = warning(body)
#let gfm-caution(body)   = pitfall(title: "CAUTION", body)

/// Composable show rule to style quotes and map GFM alert blocks from cmarker / Pandoc
#let with-gfm-theme(body) = {
  // Editorial Blockquotes & GFM Callout Transformer
  show quote: it => {
    // Elegant editorial pull quote styling for regular quotes
    block(
      width: 100%,
      fill: slate-50,
      stroke: (left: 2.5pt + floe-cyan),
      radius: (right: radii.sm),
      inset: (x: 12pt, y: 8pt),
      above: 1.1em,
      below: 1.1em,
    )[
      #set text(font: fonts.serif, style: "italic", size: 10pt, fill: slate-800)
      #it.body
    ]
  }

  body
}
