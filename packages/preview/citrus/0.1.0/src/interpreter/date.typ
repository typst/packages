// citrus - Date Handler
//
// Handles <date> CSL element.

#import "../core/mod.typ": finalize
#import "../text/dates.typ": (
  format-date-part, format-date-with-form, parse-bibtex-date,
)

/// Handle <date> element
/// The third parameter is ignored (kept for dispatch table compatibility)
#let handle-date(node, ctx, .._rest) = {
  let attrs = node.at("attrs", default: (:))
  let children = node.at("children", default: ())
  let variable = attrs.at("variable", default: "issued")

  // Parse date based on variable attribute
  let dt = if variable == "issued" {
    parse-bibtex-date(ctx.fields)
  } else if variable == "accessed" {
    // Parse urldate for accessed date
    let urldate = ctx.fields.at("urldate", default: "")
    if urldate != "" {
      parse-bibtex-date((year: urldate, date: urldate))
    } else { none }
  } else if variable == "original-date" {
    // Parse origdate for original-date
    let origdate = ctx.fields.at("origdate", default: "")
    if origdate != "" {
      parse-bibtex-date((year: origdate, date: origdate))
    } else { none }
  } else if variable == "event-date" {
    // Parse eventdate
    let eventdate = ctx.fields.at("eventdate", default: "")
    if eventdate != "" {
      parse-bibtex-date((year: eventdate, date: eventdate))
    } else { none }
  } else {
    // Default to issued
    parse-bibtex-date(ctx.fields)
  }

  // Check for date children (inline date-parts)
  let date-part-nodes = children.filter(c => (
    type(c) == dictionary and c.at("tag", default: "") == "date-part"
  ))

  if dt != none {
    let result = if date-part-nodes.len() > 0 {
      // Use inline date-part specifications
      let parts = ()
      for dp in date-part-nodes {
        let dp-attrs = dp.at("attrs", default: (:))
        let dp-name = dp-attrs.at("name", default: "")
        let dp-form = dp-attrs.at("form", default: "numeric")
        let dp-prefix = dp-attrs.at("prefix", default: "")
        let dp-suffix = dp-attrs.at("suffix", default: "")

        let formatted = format-date-part(dt, dp-name, dp-form, ctx)
        if formatted != "" {
          parts.push([#dp-prefix#formatted#dp-suffix])
        }
      }
      parts.join()
    } else {
      // Use form attribute or default
      let form = attrs.at("form", default: "numeric")
      let date-parts = attrs.at("date-parts", default: "year-month-day")
      format-date-with-form(dt, form, date-parts, ctx)
    }

    finalize(result, attrs)
  } else { [] }
}
