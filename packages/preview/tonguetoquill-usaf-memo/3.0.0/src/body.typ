// body.typ: Paragraph body rendering for USAF memorandum sections
//
// This module implements the visual rendering of AFH 33-337 compliant
// paragraph bodies with proper numbering, nesting, and formatting.

#import "config.typ": *
#import "utils.typ": *
#import "primitives.typ": render-memo-table

// =============================================================================
// PARAGRAPH NUMBERING UTILITIES
// =============================================================================

/// Gets the numbering format for a specific paragraph level.
///
/// - level (int): Paragraph nesting level (0-based)
/// -> str | function
#let get-paragraph-numbering-format(level) = {
  paragraph-config.numbering-formats.at(level, default: "i.")
}

/// Calculates indentation for USAF-style paragraphs from explicit counter values.
///
/// - level (int): Paragraph nesting level (0-based)
/// - level-counts (dictionary): Maps level index strings to their current counter values
/// -> length
#let calculate-indent-from-counts(level, level-counts) = {
  if level == 0 {
    return 0pt
  }
  let total-indent = 0pt
  for ancestor-level in range(level) {
    let ancestor-value = level-counts.at(str(ancestor-level), default: 1)
    let ancestor-format = get-paragraph-numbering-format(ancestor-level)
    let ancestor-number = numbering(ancestor-format, ancestor-value)
    total-indent += measure([#ancestor-number#"  "]).width
  }
  total-indent
}

/// Calculates fixed indentation for DAF paragraph levels.
///
/// First nested level starts at `nested-first-level-indent` (1in); deeper levels
/// add `nested-step` (0.5in) per additional depth.
///
/// - level (int): Paragraph nesting level (0-based)
/// -> length
#let calculate-daf-indent(level) = {
  if level <= 0 {
    return 0pt
  }
  daf-paragraph.nested-first-level-indent + (level - 1) * daf-paragraph.nested-step
}

/// Resets counter entries from `start` upward to 1 in the level-counts dictionary.
#let reset-levels-from(level-counts, start, max-levels) = {
  for child in range(start, max-levels) {
    level-counts.insert(str(child), 1)
  }
  level-counts
}

/// Formats a paragraph (or continuation) with a given indent strategy.
///
/// - body (content): Paragraph content
/// - level (int): Nesting level (0-based)
/// - level-counts (dictionary): Current counter values per level
/// - indent-fn (function): `(level, level-counts) -> length`
/// - continuation (bool): If true, adds number-label width to alignment
/// -> content
#let format-par(body, level, level-counts, indent-fn, continuation: false) = {
  let indent-width = indent-fn(level, level-counts)
  if continuation {
    let current-value = level-counts.at(str(level), default: 1)
    let number-text = numbering(get-paragraph-numbering-format(level), current-value)
    [#h(indent-width + measure([#number-text#"  "]).width)#body]
  } else {
    let current-value = level-counts.at(str(level), default: 1)
    let number-text = numbering(get-paragraph-numbering-format(level), current-value)
    [#h(indent-width)#number-text#"  "#body]
  }
}

// =============================================================================
// PARAGRAPH BODY RENDERING
// =============================================================================
// AFH 33-337 "The Text of the Official Memorandum" §1-12 specifies:
// - Single-space text, double-space between paragraphs
// - Number and letter each paragraph and subparagraph
// - "A single paragraph is not numbered" (§2)
// - First paragraph flush left, never indented
// - Indent sub-paragraphs to align with first character of parent paragraph text
#let render-body(content, auto-numbering: true, memo-style: "usaf") = {
  let PAR_BUFFER = state("PAR_BUFFER")
  PAR_BUFFER.update(())
  let NEST_DOWN = counter("NEST_DOWN")
  NEST_DOWN.update(0)
  let NEST_UP = counter("NEST_UP")
  NEST_UP.update(0)
  let IS_HEADING = state("IS_HEADING")
  IS_HEADING.update(false)
  // Tracks whether the next paragraph is the first block in a list item.
  // When true, the next `show par` captures a numbered item; subsequent
  // paragraphs within the same item are continuations (no new number).
  let ITEM_FIRST_PAR = state("ITEM_FIRST_PAR")
  ITEM_FIRST_PAR.update(false)

  // The first pass parses paragraphs, list items, etc. into standardized arrays
  let first_pass = {
    // Collect pars with nesting level
    show par: p => context {
      let nest_level = NEST_DOWN.get().at(0) - NEST_UP.get().at(0)
      let is_heading = IS_HEADING.get()
      let is_first_par = ITEM_FIRST_PAR.get()

      // Determine if this is a continuation block within a multi-block list item.
      // A continuation is a non-first paragraph inside a list item (nest_level > 0).
      let is_continuation = nest_level > 0 and not is_first_par

      PAR_BUFFER.update(pars => {
        pars.push((
          content: text([#p.body]),
          nest_level: nest_level,
          kind: if is_heading { "heading" } else if is_continuation { "continuation" } else { "par" },
        ))
        pars
      })

      // After the first paragraph of a list item, mark subsequent ones as continuations
      if nest_level > 0 and is_first_par {
        ITEM_FIRST_PAR.update(false)
      }

      p
    }
    // Collect tables — captured as-is without paragraph numbering
    show table: t => context {
      PAR_BUFFER.update(pars => {
        pars.push((
          content: t,
          nest_level: -1,
          kind: "table",
        ))
        pars
      })
      t
    }
    {
      show heading: h => {
        IS_HEADING.update(true)
        [#parbreak()#h.body#parbreak()]
        IS_HEADING.update(false)
      }

      // Convert list/enum items to pars
      // Note: No context wrapper here - state updates don't need it and cause
      // layout convergence issues with many list items
      show enum.item: it => {
        NEST_DOWN.step()
        ITEM_FIRST_PAR.update(true)
        [#parbreak()#it.body#parbreak()]
        NEST_UP.step()
      }
      show list.item: it => {
        NEST_DOWN.step()
        ITEM_FIRST_PAR.update(true)
        [#parbreak()#it.body#parbreak()]
        NEST_UP.step()
      }

      {
        // Typst bug bandaid:
        // `show par` will not collect wrappers unless there is content outside
        // Add zero width space to always have content outside of wrapper
        show strong: it => {
          [#it#sym.zws]
        }
        show emph: it => {
          [#it#sym.zws]
        }
        show underline: it => {
          [#it#sym.zws]
        }
        show raw: it => {
          [#it#sym.zws]
        }
        [#content#parbreak()]
      }
    }
  }
  // Use place() to prevent hidden content from affecting layout flow
  place(hide(first_pass))

  // Second pass: consume par buffer
  //
  // PAR_BUFFER item dictionary layout:
  //   item.content    — the paragraph body or table element
  //   item.nest_level — nesting depth (−1 for tables)
  //   item.kind       — "par", "heading", "table", or "continuation"
  context {
    let heading_buffer = none
    // Only top-level paragraphs count for AFH 33-337 §2 numbering purposes
    let par_count = PAR_BUFFER.get().filter(item => item.kind == "par").len()
    let items = PAR_BUFFER.get()
    let total_count = items.len()

    // Track paragraph numbers per level manually to avoid nested-context
    // counter propagation issues.  Dictionary maps level index (as string)
    // to the current counter value at that level.
    let max-levels = paragraph-config.numbering-formats.len()
    let level-counts = (:)
    for lvl in range(max-levels) {
      level-counts.insert(str(lvl), 1)
    }

    let i = 0
    for item in items {
      i += 1
      let kind = item.kind
      let item_content = item.content

      // Buffer headings for prepend to the next rendered element
      if kind == "heading" {
        heading_buffer = item_content
        continue
      }

      // Prepend buffered heading to the next non-heading element
      if heading_buffer != none {
        if kind == "table" {
          // Tables cannot have inline text prepended; emit heading as
          // a standalone bold line above the table
          blank-line()
          strong[#heading_buffer.]
          heading_buffer = none
        } else {
          item_content = [#strong[#heading_buffer.] #item_content]
          heading_buffer = none
        }
      }

      // Format based on element kind
      let nest_level = item.nest_level
      let indent-fn = if memo-style == "daf" {
        (level, _counts) => calculate-daf-indent(level)
      } else {
        (level, counts) => calculate-indent-from-counts(level, counts)
      }
      let final_par = {
        if kind == "table" {
          render-memo-table(item_content)
        } else if kind == "continuation" {
          // Continuation block within a multi-block list item:
          // indent to align with preceding numbered paragraph's text, no new number.
          // level-counts still holds the value of the preceding numbered paragraph.
          if memo-style == "daf" {
            if nest_level > 0 {
              format-par(item_content, nest_level, level-counts, indent-fn, continuation: true)
            } else {
              item_content
            }
          } else if auto-numbering {
            format-par(item_content, nest_level, level-counts, indent-fn, continuation: true)
          } else if nest_level > 0 {
            format-par(item_content, nest_level - 1, level-counts, indent-fn, continuation: true)
          } else {
            item_content
          }
        } else if memo-style == "daf" {
          if nest_level > 0 {
            let par = format-par(item_content, nest_level, level-counts, indent-fn)
            level-counts.insert(str(nest_level), level-counts.at(str(nest_level), default: 1) + 1)
            level-counts = reset-levels-from(level-counts, nest_level + 1, max-levels)
            par
          } else {
            // DAF top-level paragraphs are unnumbered and first-line indented.
            // Reset nested counters so each new top-level paragraph restarts children.
            level-counts = reset-levels-from(level-counts, 0, max-levels)
            [#h(daf-paragraph.top-first-line-indent)#item_content]
          }
        } else if auto-numbering {
          if par_count > 1 {
            // Apply paragraph numbering per AFH 33-337 §2
            let par = format-par(item_content, nest_level, level-counts, indent-fn)
            level-counts.insert(str(nest_level), level-counts.at(str(nest_level)) + 1)
            level-counts = reset-levels-from(level-counts, nest_level + 1, max-levels)
            par
          } else {
            // AFH 33-337 §2: "A single paragraph is not numbered"
            item_content
          }
        } else {
          // Unnumbered mode: only explicitly nested items (enum/list) get numbered
          if nest_level > 0 {
            let effective_level = nest_level - 1
            let par = format-par(item_content, effective_level, level-counts, indent-fn)
            level-counts.insert(str(effective_level), level-counts.at(str(effective_level)) + 1)
            level-counts = reset-levels-from(level-counts, effective_level + 1, max-levels)
            par
          } else {
            // Base-level paragraphs are flush left with no numbering.
            // Reset all child level counters so subsequent list items restart at 1.
            level-counts = reset-levels-from(level-counts, 0, max-levels)
            item_content
          }
        }
      }

      // If this is the final item, apply AFH 33-337 §11 rule:
      // "Avoid dividing a paragraph of less than four lines between two pages"
      blank-line()
      if i == total_count {
        let available_width = page.width - spacing.margin * 2

        // Use the shared measured line stride used by blank-line spacing.
        let line_height = {
          let cached = LINE_STRIDE.get()
          if cached != none {
            cached
          } else {
            let one-line = measure(par(spacing: 0pt)[x]).height
            measure(par(spacing: 0pt)[x#linebreak()x]).height - one-line
          }
        }
        // Calculate last item's height
        let par_height = measure(final_par, width: available_width).height

        let estimated_lines = calc.ceil(par_height / line_height)

        if estimated_lines < 4 {
          // Short content (< 4 lines): make sticky to keep with signature
          block(sticky: true)[#final_par]
        } else {
          // Longer content (≥ 4 lines): use default breaking behavior
          block(breakable: true)[#final_par]
        }
      } else {
        final_par
      }
    }
  }
}


