#import "@preview/linguify:0.5.0": linguify

/// Renders the figure, table, and listing indices if enabled.
///
/// This function checks the `enabled` flag of each index (`figure-index`,
/// `table-index`, `listing-index`). If any are enabled, it generates an
/// outlined outline section for each enabled type:
/// - Figures
/// - Tables
/// - Listings
///
/// Default titles are localized via `linguify`:
/// - Figures: `linguify("indices-figures")`
/// - Tables: `linguify("indices-tables")`
/// - Listings: `linguify("indices-listings")`
///
/// Users can override these defaults by providing a `title` in each index
/// dictionary. After rendering any indices, a page break is inserted.
///
/// Parameters:
/// - figure-index (dictionary, default:
///     (enabled: false, title: "")
///   ):
///     Controls rendering of the figure index.
///
/// - table-index (dictionary, default:
///     (enabled: false, title: "")
///   ):
///     Controls rendering of the table index.
///
/// - listing-index (dictionary, default:
///     (enabled: false, title: "")
///   ):
///     Controls rendering of the listing index.
///
/// Returns:
/// - content:
///     One or more outlined indices (figures, tables, listings)
///     followed by a page break, or empty content if none are enabled.
///
/// Example:
/// ```typst
/// #_render-indices-of-everything(
///   figure-index: (enabled: true, title: [Figures]),
///   table-index: (enabled: true),
///   listing-index: (enabled: false),
/// )
/// ```
#let _render-indices-of-everything(
  figure-index: (
    enabled: false,
    title: ""
  ),
  table-index: (
    enabled: false,
    title: ""
  ),
  listing-index: (
    enabled: false,
    title: ""
  )
) = {
  let default-titles = (
    figure-title: linguify("indices-figures"),
    table-title: linguify("indices-tables"),
    listing-title: linguify("indices-listings")
  )

  let fig-t(kind) = figure.where(kind: kind)
  if figure-index.enabled or table-index.enabled or listing-index.enabled {
    show outline: set heading(outlined: true)
    context {
      let imgs = figure-index.enabled
      let tbls = table-index.enabled
      let lsts = listing-index.enabled
      if imgs {
        outline(
          title: figure-index.at("title", default: default-titles.figure-title),
          target: fig-t(image),
        )
      }
      if tbls {
        outline(
          title: table-index.at("title", default: default-titles.table-title),
          target: fig-t(table),
        )
      }
      if lsts {
        outline(
          title: listing-index.at("title", default: default-titles.listing-title),
          target: fig-t(raw),
        )
      }
      if imgs or tbls or lsts {
        pagebreak()
      }
    }
  }
}

