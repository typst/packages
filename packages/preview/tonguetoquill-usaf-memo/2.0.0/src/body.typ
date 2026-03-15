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
/// AFH 33-337 "The Text of the Official Memorandum" §2: "Number and letter each
/// paragraph and subparagraph" with hierarchical numbering implied by examples.
/// Standard military format follows the pattern: 1., a., (1), (a), etc.
///
/// Returns the appropriate numbering format for AFH 33-337 compliant
/// hierarchical paragraph numbering:
/// - Level 0: "1." (1., 2., 3., etc.)
/// - Level 1: "a." (a., b., c., etc.)
/// - Level 2: "(1)" ((1), (2), (3), etc.)
/// - Level 3: "(a)" ((a), (b), (c), etc.)
/// - Level 4+: Underlined format for deeper nesting
///
/// - level (int): Paragraph nesting level (0-based)
/// -> str | function
#let get-paragraph-numbering-format(level) = {
  paragraph-config.numbering-formats.at(level, default: "i.")
}

/// Calculates indentation width using explicit counter values.
///
/// Computes the exact indentation needed for hierarchical paragraph alignment
/// by measuring the cumulative width of all ancestor paragraph numbers and their
/// spacing. Uses the provided counter values directly (no Typst counter reads).
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
    let width = measure([#ancestor-number#"  "]).width
    total-indent += width
  }
  total-indent
}

/// Formats a numbered paragraph with proper indentation.
///
/// Generates a properly formatted paragraph with AFH 33-337 compliant numbering
/// and indentation. Uses explicit level and counter values to avoid nested-context
/// state propagation issues.
///
/// - body (content): Paragraph content to format
/// - level (int): Paragraph nesting level (0-based)
/// - level-counts (dictionary): Current counter values per level
/// -> content
#let format-numbered-par(body, level, level-counts) = {
  let current-value = level-counts.at(str(level), default: 1)
  let format = get-paragraph-numbering-format(level)
  let number-text = numbering(format, current-value)
  let indent-width = calculate-indent-from-counts(level, level-counts)
  [#h(indent-width)#number-text#"  "#body]
}

/// Formats a continuation paragraph within a multi-block list item.
///
/// Renders a paragraph that belongs to the same list item as the preceding
/// numbered paragraph. The text is indented to align with the first character
/// of the preceding numbered paragraph's text (past the number and spacing),
/// but no new number is generated.
///
/// - body (content): Continuation paragraph content to format
/// - level (int): Paragraph nesting level (0-based)
/// - level-counts (dictionary): Current counter values per level
/// -> content
#let format-continuation-par(body, level, level-counts) = {
  let indent-width = calculate-indent-from-counts(level, level-counts)
  // Add the width of the current level's number + spacing to align with text
  let current-value = level-counts.at(str(level), default: 1)
  let format = get-paragraph-numbering-format(level)
  let number-text = numbering(format, current-value)
  let number-width = measure([#number-text#"  "]).width
  [#h(indent-width + number-width)#body]
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
#let render-body(content, auto-numbering: true) = {
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
      let final_par = {
        if kind == "table" {
          render-memo-table(item_content)
        } else if kind == "continuation" {
          // Continuation block within a multi-block list item:
          // indent to align with preceding numbered paragraph's text, no new number.
          // level-counts still holds the value of the preceding numbered paragraph.
          if auto-numbering {
            format-continuation-par(item_content, nest_level, level-counts)
          } else if nest_level > 0 {
            format-continuation-par(item_content, nest_level - 1, level-counts)
          } else {
            item_content
          }
        } else if auto-numbering {
          if par_count > 1 {
            // Apply paragraph numbering per AFH 33-337 §2
            let par = format-numbered-par(item_content, nest_level, level-counts)
            // Advance counter for this level and reset child levels
            level-counts.insert(str(nest_level), level-counts.at(str(nest_level)) + 1)
            for child in range(nest_level + 1, max-levels) {
              level-counts.insert(str(child), 1)
            }
            par
          } else {
            // AFH 33-337 §2: "A single paragraph is not numbered"
            item_content
          }
        } else {
          // Unnumbered mode: only explicitly nested items (enum/list) get numbered
          if nest_level > 0 {
            let effective_level = nest_level - 1
            let par = format-numbered-par(item_content, effective_level, level-counts)
            level-counts.insert(str(effective_level), level-counts.at(str(effective_level)) + 1)
            for child in range(effective_level + 1, max-levels) {
              level-counts.insert(str(child), 1)
            }
            par
          } else {
            // Base-level paragraphs are flush left with no numbering
            // Reset all child level counters so subsequent list items restart at 1
            for child in range(max-levels) {
              level-counts.insert(str(child), 1)
            }
            item_content
          }
        }
      }

      // If this is the final item, apply AFH 33-337 §11 rule:
      // "Avoid dividing a paragraph of less than four lines between two pages"
      blank-line()
      if i == total_count {
        let available_width = page.width - spacing.margin * 2

        // Use configured paragraph metrics for line height estimation
        let line_height = measure(line(length: spacing.line + spacing.line-height)).width
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


