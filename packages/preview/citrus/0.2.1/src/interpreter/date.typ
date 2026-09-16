// citrus - Date Handler
//
// Handles <date> CSL element.

#import "../core/mod.typ": apply-formatting, apply-text-case, finalize
#import "../data/collapsing.typ": num-to-suffix
#import "../text/dates.typ": (
  date-has-component, format-date-part, format-date-with-form,
  parse-bibtex-date,
)

/// Convert year-suffix to letter string
/// Handles both numeric (0, 1, 2) and legacy string formats
#let _suffix-to-string(suffix) = {
  if suffix == none or suffix == "" { return "" }
  if type(suffix) == int { return num-to-suffix(suffix) }
  str(suffix)
}

/// Check if year-suffix should be auto-appended to this date
/// CSL spec: "By default, the year-suffix is appended the first year rendered
/// through cs:date... but its location can be controlled by explicitly
/// rendering the 'year-suffix' variable using cs:text"
#let _should-append-year-suffix(ctx) = {
  // Get year-suffix value from context
  let suffix = ctx.at("year-suffix", default: none)
  if suffix == none or suffix == "" { return false }

  // Check if style has explicit year-suffix rendering
  // If has-explicit-year-suffix is true, don't auto-append
  let has-explicit = ctx.at("has-explicit-year-suffix", default: false)
  if has-explicit { return false }

  // Check if we've already appended year-suffix in this render pass
  let done-vars = ctx.at("done-vars", default: ())
  if "__year-suffix-done" in done-vars { return false }
  let already-done = ctx.at("year-suffix-done", default: false)
  if already-done { return false }

  true
}

/// Handle <date> element
/// The third parameter is ignored (kept for dispatch table compatibility)
#let handle-date(node, ctx, .._rest) = {
  // Support suppress-year for year-suffix collapse
  // But still render year-suffix if present (for implicit year-suffix styles)
  if ctx.at("suppress-year", default: false) {
    // Check if we should render just the year-suffix
    // But only for the first date element (use __year-suffix-done to prevent double emission)
    let suffix = ctx.at("year-suffix", default: none)
    let has-explicit = ctx.at("has-explicit-year-suffix", default: false)
    let already-done = ctx.at("year-suffix-done", default: false)
    let done-vars = ctx.at("done-vars", default: ())
    if already-done or "__year-suffix-done" in done-vars {
      return []
    }
    if suffix != none and suffix != "" and not has-explicit {
      // Render only the year-suffix letter (without the year)
      return _suffix-to-string(suffix)
    }
    return []
  }

  let attrs = node.at("attrs", default: (:))
  let children = node.at("children", default: ())
  let variable = attrs.at("variable", default: "issued")

  // Check for literal date first (e.g., "in press", "forthcoming")
  // CSL-JSON: { "issued": { "literal": "(in press)" } }
  let literal-date = ctx.fields.at("literal", default: "")
  if literal-date != "" {
    return finalize(literal-date, attrs)
  }

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
    // Check if we should auto-append year-suffix
    let append-suffix = _should-append-year-suffix(ctx)
    let year-suffix = if append-suffix {
      _suffix-to-string(ctx.at("year-suffix", default: none))
    } else { "" }

    // Get date source fields for component checking
    let date-fields = if variable == "issued" {
      ctx.fields
    } else if variable == "accessed" {
      // Use accessed-* fields if available, otherwise fall back to urldate
      let accessed-year = ctx.fields.at("accessed-year", default: "")
      if accessed-year != "" {
        (
          year: accessed-year,
          month: ctx.fields.at("accessed-month", default: ""),
          day: ctx.fields.at("accessed-day", default: ""),
          date: ctx.fields.at("urldate", default: ""),
        )
      } else {
        let urldate = ctx.fields.at("urldate", default: "")
        if urldate != "" { (year: urldate, date: urldate) } else { (:) }
      }
    } else if variable == "original-date" {
      let origdate = ctx.fields.at("origdate", default: "")
      if origdate != "" { (year: origdate, date: origdate) } else { (:) }
    } else if variable == "event-date" {
      let eventdate = ctx.fields.at("eventdate", default: "")
      if eventdate != "" {
        (
          year: ctx.fields.at("event-year", default: ""),
          month: ctx.fields.at("event-month", default: ""),
          day: ctx.fields.at("event-day", default: ""),
          date: eventdate,
          end-year: ctx.fields.at("event-end-year", default: ""),
          end-month: ctx.fields.at("event-end-month", default: ""),
          end-day: ctx.fields.at("event-end-day", default: ""),
        )
      } else { (:) }
    } else {
      ctx.fields
    }

    // Build inline date-part overrides dictionary
    let inline-overrides = (:)
    for dp in date-part-nodes {
      let dp-attrs = dp.at("attrs", default: (:))
      let dp-name = dp-attrs.at("name", default: "")
      if dp-name != "" {
        inline-overrides.insert(dp-name, dp-attrs)
      }
    }

    // Determine if we have a localized date format (form attribute)
    let form = attrs.at("form", default: none)

    let result = if form != none {
      // Use localized date format with inline overrides
      let date-parts-attr = attrs.at("date-parts", default: "year-month-day")
      let date-result = format-date-with-form(
        dt,
        form,
        date-parts-attr,
        ctx,
        fields: date-fields,
        overrides: inline-overrides,
      )
      // For localized dates, append year-suffix at the end
      if year-suffix != "" {
        [#date-result#year-suffix]
      } else {
        date-result
      }
    } else if date-part-nodes.len() > 0 {
      // Non-localized date with explicit date-part children
      let parts = ()
      let year-rendered = false
      let date-delimiter = attrs.at("delimiter", default: "")
      let end-fields = (
        year: date-fields.at("end-year", default: ""),
        month: date-fields.at("end-month", default: ""),
        day: date-fields.at("end-day", default: ""),
      )
      let raw-end = date-fields.at("raw-end-year", default: "")
      let has-end = (
        raw-end == "0"
          or end-fields.year != ""
          or end-fields.month != ""
          or end-fields.day != ""
      )
      let end-dt = if has-end { parse-bibtex-date(end-fields) } else { none }

      if has-end {
        let start-parts = ()
        let end-parts = ()
        let meta = ()
        for dp in date-part-nodes {
          let dp-attrs = dp.at("attrs", default: (:))
          let dp-name = dp-attrs.at("name", default: "")
          // CSL spec: month defaults to "long", day/year default to "numeric"
          let default-form = if dp-name == "month" { "long" } else { "numeric" }
          let dp-form = dp-attrs.at("form", default: default-form)
          let dp-prefix = dp-attrs.at("prefix", default: "")
          let dp-suffix = dp-attrs.at("suffix", default: "")
          let dp-text-case = dp-attrs.at("text-case", default: "")
          let dp-range-delim = dp-attrs.at("range-delimiter", default: "–")

          let has-start = date-has-component(date-fields, dp-name)
          let has-end-part = date-has-component(end-fields, dp-name)
          if not has-start and not has-end-part {
            continue
          }

          let format-attrs = (..dp-attrs, text-case: none)
          let start-core = if has-start {
            let formatted = format-date-part(dt, dp-name, dp-form, ctx)
            if formatted != "" and dp-text-case != "" {
              formatted = apply-text-case(
                formatted,
                (text-case: dp-text-case),
                ctx: ctx,
              )
            }
            if formatted != "" {
              formatted = apply-formatting(formatted, format-attrs)
            }
            if formatted != "" { [#dp-prefix#formatted] } else { "" }
          } else { "" }
          let start-content = if start-core != "" {
            [#start-core#dp-suffix]
          } else { "" }

          let end-core = if raw-end == "0" {
            ""
          } else if has-end-part {
            let formatted-end = format-date-part(end-dt, dp-name, dp-form, ctx)
            if formatted-end != "" and dp-text-case != "" {
              formatted-end = apply-text-case(
                formatted-end,
                (text-case: dp-text-case),
                ctx: ctx,
              )
            }
            if formatted-end != "" {
              formatted-end = apply-formatting(formatted-end, format-attrs)
            }
            if formatted-end != "" { [#dp-prefix#formatted-end] } else { "" }
          } else { "" }
          let end-content = if end-core != "" {
            [#end-core#dp-suffix]
          } else { "" }

          if start-content != "" { start-parts.push(start-content) }
          if end-content != "" { end-parts.push(end-content) }

          let start-val = if has-start {
            date-fields.at(dp-name, default: "")
          } else { "" }
          let end-val = if raw-end == "0" {
            "0"
          } else if has-end-part {
            end-fields.at(dp-name, default: "")
          } else { "" }
          meta.push((
            range-delimiter: dp-range-delim,
            start: start-val,
            end: end-val,
            start-core: start-core,
            start-content: start-content,
            end-content: end-content,
          ))
        }

        let diff-idx = none
        for i in range(0, meta.len()) {
          let m = meta.at(i)
          if m.end != "" and m.start != m.end {
            diff-idx = i
          }
        }

        if diff-idx != none {
          let range-delim = meta.at(diff-idx).range-delimiter
          let start-prefix-parts = ()
          let prefix-meta = meta.slice(0, diff-idx + 1)
          for i in range(0, prefix-meta.len()) {
            let m = prefix-meta.at(i)
            let part = if i == diff-idx and m.start-core != "" {
              m.start-core
            } else {
              m.start-content
            }
            if part != "" { start-prefix-parts.push(part) }
          }
          let start-prefix = start-prefix-parts.join(date-delimiter)
          let end-combined = if raw-end == "0" {
            ""
          } else {
            let end-prefix = meta
              .slice(0, diff-idx + 1)
              .map(m => m.end-content)
              .filter(x => x != "")
              .join(date-delimiter)
            let suffix = meta
              .slice(diff-idx + 1, meta.len())
              .map(m => {
                if m.start == m.end and m.start-content != "" {
                  m.start-content
                } else {
                  m.end-content
                }
              })
              .filter(x => x != "")
              .join(date-delimiter)
            if suffix == "" {
              end-prefix
            } else if end-prefix == "" {
              suffix
            } else {
              [#end-prefix#date-delimiter#suffix]
            }
          }
          return finalize([#start-prefix#range-delim#end-combined], attrs)
        }
      }
      for dp in date-part-nodes {
        let dp-attrs = dp.at("attrs", default: (:))
        let dp-name = dp-attrs.at("name", default: "")
        // CSL spec: month defaults to "long", day/year default to "numeric"
        let default-form = if dp-name == "month" { "long" } else { "numeric" }
        let dp-form = dp-attrs.at("form", default: default-form)
        let dp-prefix = dp-attrs.at("prefix", default: "")
        let dp-suffix = dp-attrs.at("suffix", default: "")
        let dp-text-case = dp-attrs.at("text-case", default: "")

        // Check if the date actually has this component
        if not date-has-component(date-fields, dp-name) {
          continue
        }

        let format-attrs = (..dp-attrs, text-case: none)
        let formatted = format-date-part(dt, dp-name, dp-form, ctx)
        if formatted != "" and dp-text-case != "" {
          formatted = apply-text-case(
            formatted,
            (text-case: dp-text-case),
            ctx: ctx,
          )
        }
        if formatted != "" {
          formatted = apply-formatting(formatted, format-attrs)
        }
        if formatted != "" {
          // Auto-append year-suffix after the first year part
          if dp-name == "year" and not year-rendered and year-suffix != "" {
            year-rendered = true
            parts.push([#dp-prefix#formatted#year-suffix#dp-suffix])
          } else {
            parts.push([#dp-prefix#formatted#dp-suffix])
          }
        }
      }
      parts.join(date-delimiter)
    } else {
      // Use form attribute or default
      let form = attrs.at("form", default: "numeric")
      let date-parts = attrs.at("date-parts", default: "year-month-day")
      let date-result = format-date-with-form(
        dt,
        form,
        date-parts,
        ctx,
        fields: date-fields,
      )
      // For localized dates, append year-suffix at the end (year is typically last)
      if year-suffix != "" {
        [#date-result#year-suffix]
      } else {
        date-result
      }
    }

    finalize(result, attrs)
  } else { [] }
}
