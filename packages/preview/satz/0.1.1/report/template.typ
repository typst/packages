// Report template — thin wrapper around the unified satz class.

#import "../class.typ": personal

/// A simple report — articles, protocols, lab notes, whatever.
///
/// It wraps `personal(kind: "report")`. You get numbered headings,
/// a table of contents, and a bibliography out of the box.
/// Need binding correction for a thesis? Call `personal(kind: "thesis")` instead.
///
/// - body (content): your text
/// - config (dictionary): tweak fonts, colors, margins ...
///
/// ```example
/// #show: report.with(
///   config: (typography: (font: "EB Garamond"), colors: (brand-primary: blue))
/// )
/// = Introduction
/// #lorem(100)
/// ```
#let report(body, config: (:)) = {
  personal(kind: "report", config: config, body)
}
