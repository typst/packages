// =============================================================================
// Citation Collapsing
// =============================================================================
// Implements CSL citation collapsing rules:
// - citation-number: [1, 2, 3, 4] → [1-4]
// - year: (Smith 2000, Smith 2001) → (Smith 2000, 2001)
// - year-suffix: (Smith 2000a, Smith 2000b) → (Smith 2000a, b)
// - year-suffix-ranged: (Smith 2000a, b, c) → (Smith 2000a-c)

#import "../core/constants.typ": COLLAPSE

// =============================================================================
// Generic Range Processing
// =============================================================================

/// Process ranges and render collapsed output
///
/// This is a generic function that handles both citation-number and year-suffix
/// range collapsing with the same logic pattern.
///
/// - ranges: Array of (start, end) tuples from collapse-*-ranges
/// - items: Array of items to render
/// - get-key: Function (item) -> key value to match against range start/end
/// - render-single: Function (item) -> content for single items
/// - render-range-start: Function (item) -> content for range start
/// - render-range-end: Function (end-key) -> content for range end (just the suffix part)
/// - delimiter: Delimiter between items
/// - range-delimiter: Delimiter for ranges (default: en-dash)
/// Returns: Array of rendered content parts
/// Process ranges and render collapsed output (index-based)
///
/// - ranges: Array of (start-idx, end-idx) tuples from collapse-numeric-ranges
/// - items: Array of items to render
/// - render-single: Function (item) -> content for single items
/// - render-range-start: Function (item) -> content for range start
/// - render-range-end: Function (item) -> content for range end
/// - range-delimiter: Delimiter for ranges (default: en-dash)
/// Returns: Array of rendered content parts
#let process-ranges(
  ranges,
  items,
  render-single,
  render-range-start,
  render-range-end,
  range-delimiter: "–",
) = {
  let parts = ()

  for r in ranges {
    let start-idx = r.start-idx
    let end-idx = r.end-idx

    if start-idx == end-idx {
      // Single item
      parts.push(render-single(items.at(start-idx)))
    } else if end-idx == start-idx + 1 {
      // Two consecutive - no range notation
      parts.push(render-single(items.at(start-idx)))
      parts.push(render-single(items.at(end-idx)))
    } else {
      // Range of 3+ - render as range
      let start-rendered = render-range-start(items.at(start-idx))
      let end-rendered = render-range-end(items.at(end-idx))
      parts.push([#start-rendered#range-delimiter#end-rendered])
    }
  }

  parts
}

/// Convert year-suffix letter to number (a=0, b=1, ..., z=25, aa=26, ab=27, ...)
#let suffix-to-num(suffix) = {
  if suffix == none or suffix == "" { return none }
  let s = str(suffix).trim()
  if s.len() == 0 { return none }
  if s.len() == 1 {
    let code = s.codepoints().first()
    // a-z: 97-122
    if code >= 97 and code <= 122 {
      code - 97
    } else {
      none
    }
  } else if s.len() == 2 {
    // aa=26, ab=27, ..., az=51, ba=52, ...
    let c1 = s.codepoints().at(0)
    let c2 = s.codepoints().at(1)
    if c1 >= 97 and c1 <= 122 and c2 >= 97 and c2 <= 122 {
      26 + (c1 - 97) * 26 + (c2 - 97)
    } else {
      none
    }
  } else {
    none
  }
}

/// Convert number back to year-suffix letter
#let num-to-suffix(n) = {
  if n < 26 {
    str.from-unicode(97 + n)
  } else {
    let n2 = n - 26
    (
      str.from-unicode(97 + calc.quo(n2, 26))
        + str.from-unicode(97 + calc.rem(n2, 26))
    )
  }
}

/// Collapse consecutive year-suffix indices into ranges
///
/// Example: (0, 1, 2, 4) → ((0, 2), (4, 4)) representing (a-c, e)
/// Input: Array of numeric indices (0=a, 1=b, etc) or none values
/// Returns: Array of (start, end) tuples with numeric indices
#let collapse-suffix-ranges(suffix-indices) = {
  if suffix-indices.len() == 0 { return () }

  // Filter out none values and ensure integers
  let nums = suffix-indices.filter(n => n != none and type(n) == int)
  if nums.len() == 0 { return () }

  // Sort numbers
  let sorted = nums.sorted()

  let ranges = ()
  let start = sorted.first()
  let end = start

  for i in range(1, sorted.len()) {
    let num = sorted.at(i)
    if num == end + 1 {
      end = num
    } else {
      ranges.push((start: start, end: end))
      start = num
      end = num
    }
  }

  ranges.push((start: start, end: end))
  ranges
}

/// Collapse consecutive numeric citations into ranges (by index)
///
/// CSL spec: Only increasing ranges collapse. Duplicates break ranges.
/// Example: (1, 2, 3, 5, 7, 8, 9) → ((start-idx: 0, end-idx: 2), ...)
/// Example: (1, 2, 2, 3, 4) → (idx 0), (idx 1), (idx 2-4) - first 2 alone, then 2-4 range
/// Example: (1, 2, 3, 3, 4, 5) → (idx 0-2), (idx 3-5) - 1-3 range, then 3-5 range
/// Returns array of (start-idx, end-idx) tuples - indices into original array
#let collapse-numeric-ranges(numbers) = {
  if numbers.len() == 0 { return () }

  let ranges = ()
  let i = 0

  while i < numbers.len() {
    let start-idx = i
    let start-val = numbers.at(i)
    let end-idx = i
    let end-val = start-val

    // Look ahead to build range - stop at duplicate or gap
    let j = i + 1
    while j < numbers.len() {
      let num = numbers.at(j)
      if num == end-val + 1 {
        // Strictly increasing - extend range
        end-idx = j
        end-val = num
        j += 1
      } else {
        // Duplicate (num == end-val) or gap (num > end-val + 1) - stop
        break
      }
    }

    // Output the range we built
    ranges.push((start-idx: start-idx, end-idx: end-idx))
    i = j
  }

  ranges
}

/// Format collapsed numeric citations
///
/// - ranges: Array of (start, end) tuples from collapse-numeric-ranges
/// - items: Original items with supplements (for locator handling)
/// - delimiter: Delimiter between items
/// - range-delimiter: Delimiter for ranges (default: en-dash)
/// - number-prefix: Prefix for each number (e.g., "[")
/// - number-suffix: Suffix for each number (e.g., "]")
/// Returns: Formatted content
#let format-collapsed-numeric(
  ranges,
  items,
  delimiter: ", ",
  range-delimiter: "–",
  number-prefix: "",
  number-suffix: "",
) = {
  let parts = ()

  // Helper to format a single number with prefix/suffix
  let fmt-num(n) = number-prefix + str(n) + number-suffix

  for r in ranges {
    if r.start == r.end {
      // Single item
      let item = items.find(it => it.order == r.start)
      if item != none and item.supplement != none {
        parts.push([#fmt-num(r.start): #item.supplement])
      } else {
        parts.push(fmt-num(r.start))
      }
    } else if r.end == r.start + 1 {
      // Two consecutive items - don't use range
      let item1 = items.find(it => it.order == r.start)
      let item2 = items.find(it => it.order == r.end)

      if item1 != none and item1.supplement != none {
        parts.push([#fmt-num(r.start): #item1.supplement])
      } else {
        parts.push(fmt-num(r.start))
      }

      if item2 != none and item2.supplement != none {
        parts.push([#fmt-num(r.end): #item2.supplement])
      } else {
        parts.push(fmt-num(r.end))
      }
    } else {
      // Range of 3+ items
      // Check if any items in range have supplements - if so, don't collapse
      let has-supplements = (
        items
          .filter(it => (
            it.order >= r.start and it.order <= r.end and it.supplement != none
          ))
          .len()
          > 0
      )

      if has-supplements {
        // Don't collapse, list individually
        let n = r.start
        while n <= r.end {
          let item = items.find(it => it.order == n)
          if item != none and item.supplement != none {
            parts.push([#fmt-num(n): #item.supplement])
          } else {
            parts.push(fmt-num(n))
          }
          n += 1
        }
      } else {
        // Collapse to range
        parts.push(fmt-num(r.start) + range-delimiter + fmt-num(r.end))
      }
    }
  }

  parts.join(delimiter)
}

/// Collapse year-suffix citations
///
/// Example: ("2000a", "2000b", "2000c") → "2000a, b, c"
/// - year-items: Array of (year, suffix, supplement) tuples with same base year
/// - delimiter: Delimiter between suffixes
/// Returns: Formatted content
#let collapse-year-suffix(year-items, delimiter: ", ") = {
  if year-items.len() == 0 { return "" }

  let first = year-items.first()
  let base-year = first.year

  // Get all suffixes
  let parts = year-items.map(it => {
    let suffix-part = it.suffix
    if it.supplement != none {
      [#suffix-part: #it.supplement]
    } else {
      suffix-part
    }
  })

  // Format: "2000a, b, c"
  [#base-year#parts.join(delimiter)]
}

/// Collapse year-suffix with ranges
///
/// Example: ("2000a", "2000b", "2000c") → "2000a-c"
/// - year-items: Array of (year, suffix, supplement) tuples with same base year
/// - delimiter: Delimiter between non-ranged suffixes
/// - range-delimiter: Delimiter for ranges (default: en-dash)
/// Returns: Formatted content
#let collapse-year-suffix-ranged(
  year-items,
  delimiter: ", ",
  range-delimiter: "–",
) = {
  if year-items.len() == 0 { return "" }

  let first = year-items.first()
  let base-year = first.year

  // Check if suffixes form a consecutive sequence (a, b, c, etc.)
  let suffixes = year-items.map(it => it.suffix)

  // Convert suffixes to numbers (a=0, b=1, etc.)
  let suffix-nums = suffixes.map(s => {
    if s.len() == 1 {
      let code = s.to-unicode().first()
      if code >= 97 and code <= 122 {
        // lowercase a-z
        code - 97
      } else {
        none
      }
    } else {
      none
    }
  })

  // Check if we have any supplements (can't collapse ranges with supplements)
  let has-supplements = year-items.filter(it => it.supplement != none).len() > 0

  if has-supplements or suffix-nums.contains(none) {
    // Fall back to non-ranged collapse
    return collapse-year-suffix(year-items, delimiter: delimiter)
  }

  // Find ranges in suffix numbers
  let ranges = collapse-numeric-ranges(suffix-nums)

  let parts = ()
  for r in ranges {
    let start-char = str.from-unicode(r.start + 97)
    let end-char = str.from-unicode(r.end + 97)

    if r.start == r.end {
      parts.push(start-char)
    } else if r.end == r.start + 1 {
      // Two consecutive - don't use range
      parts.push(start-char)
      parts.push(end-char)
    } else {
      // Range of 3+
      parts.push(start-char + range-delimiter + end-char)
    }
  }

  [#base-year#parts.join(delimiter)]
}

/// Group items by author and return both groups and ordering
///
/// - items: Array of citation items with author field
/// Returns: (by-author: dict, author-order: array of (author, pos) pairs)
#let _group-by-author(items) = {
  // Group items by author
  let by-author = (:)
  for item in items {
    let author = item.at("author", default: "")
    if author not in by-author {
      by-author.insert(author, ())
    }
    by-author.at(author).push(item)
  }

  // Track first occurrence position of each author
  let author-first-pos = (:)
  for (i, item) in items.enumerate() {
    let author = item.at("author", default: "")
    if author not in author-first-pos {
      author-first-pos.insert(author, i)
    }
  }

  // Sort authors by first occurrence
  let author-order = author-first-pos.pairs().sorted(key: ((k, v)) => v)

  (by-author: by-author, author-order: author-order)
}

/// Apply cite grouping to reorder items
///
/// CSL spec: "Grouped cites maintain their relative order, and are moved
/// to the original location of the first cite of the group."
///
/// Example: (Doe 1999; Smith 2002; Doe 2006) → (Doe 1999, 2006; Smith 2002)
///
/// - items: Array of citation items with author field
/// Returns: Reordered items array
#let apply-cite-grouping(items) = {
  if items.len() <= 1 { return items }

  let grouped = _group-by-author(items)

  // Build result: authors ordered by their first occurrence
  let result = ()
  for (author, _) in grouped.author-order {
    let author-items = grouped.by-author.at(author)
    for item in author-items {
      result.push(item)
    }
  }

  result
}

/// Apply collapsing to a list of citations based on CSL collapse mode
///
/// - items: Array of citation items with (key, order, author, year, suffix, supplement)
/// - collapse-mode: CSL collapse attribute value
/// - enable-grouping: Whether cite grouping is enabled (via cite-group-delimiter or collapse)
/// - delimiter: Normal delimiter
/// - cite-group-delimiter: Delimiter for grouped items (same author)
/// - year-suffix-delimiter: Delimiter for year suffixes
/// - after-collapse-delimiter: Delimiter after collapsed group
/// - name-year-delimiter: Delimiter between author name and year (from CSL group delimiter)
/// Returns: Formatted collapsed content
#let apply-collapse(
  items,
  collapse-mode,
  enable-grouping: false,
  delimiter: ", ",
  cite-group-delimiter: ", ",
  year-suffix-delimiter: ", ",
  after-collapse-delimiter: none,
  name-year-delimiter: " ",
) = {
  // Apply cite grouping if enabled (reorder items)
  let grouped-items = if enable-grouping or collapse-mode != none {
    apply-cite-grouping(items)
  } else {
    items
  }

  if collapse-mode == none {
    // Grouping only (no collapsing) - still need to format with group delimiter
    if enable-grouping and grouped-items.len() > 1 {
      let grouped = _group-by-author(grouped-items)

      let author-parts = ()
      for (author, _) in grouped.author-order {
        let author-items = grouped.by-author.at(author)
        // Use author-display from first item for display (fall back to author string)
        let first-item = author-items.first()
        let display-author = first-item.at("author-display", default: author)
        let years = author-items.map(it => {
          let year-str = (
            str(it.at("year", default: "")) + it.at("suffix", default: "")
          )
          if it.supplement != none {
            [#year-str: #it.supplement]
          } else {
            year-str
          }
        })
        author-parts.push([#display-author#name-year-delimiter#years.join(
            cite-group-delimiter,
          )])
      }
      return author-parts.join(delimiter)
    }

    // No grouping or single item
    return grouped-items
      .map(it => {
        if it.supplement != none {
          if it.at("formatted", default: none) != none {
            [#it.formatted: #it.supplement]
          } else {
            [#it.order: #it.supplement]
          }
        } else {
          if it.at("formatted", default: none) != none {
            it.formatted
          } else {
            str(it.order)
          }
        }
      })
      .join(delimiter)
  }

  if collapse-mode == COLLAPSE.citation-number {
    // Numeric collapsing: [1, 2, 3] → [1-3]
    let numbers = grouped-items.map(it => it.order)
    let ranges = collapse-numeric-ranges(numbers)
    return format-collapsed-numeric(ranges, grouped-items, delimiter: delimiter)
  }

  if (
    collapse-mode == COLLAPSE.year
      or collapse-mode == COLLAPSE.year-suffix
      or collapse-mode == COLLAPSE.year-suffix-ranged
  ) {
    // Group by author (already reordered by cite grouping)
    let grouped = _group-by-author(grouped-items)

    let author-parts = ()

    // Iterate in first-occurrence order
    for (author, _) in grouped.author-order {
      let author-items = grouped.by-author.at(author)
      // Use author-display from first item for display (fall back to author string)
      let first-item = author-items.first()
      let display-author = first-item.at("author-display", default: author)

      if collapse-mode == COLLAPSE.year {
        // Year collapsing: just show author once with all years
        let years = author-items
          .map(it => {
            let year-str = (
              str(it.at("year", default: "")) + it.at("suffix", default: "")
            )
            if it.supplement != none {
              [#year-str: #it.supplement]
            } else {
              year-str
            }
          })
          .filter(y => y != "" and y != []) // Filter out empty years
        if years.len() > 0 {
          author-parts.push([#display-author#name-year-delimiter#years.join(
              cite-group-delimiter,
            )])
        } else {
          // All years empty - just show author
          author-parts.push(display-author)
        }
      } else {
        // year-suffix or year-suffix-ranged: group by base year too
        let by-year = (:)
        for item in author-items {
          let year = str(item.at("year", default: ""))
          if year not in by-year {
            by-year.insert(year, ())
          }
          by-year
            .at(year)
            .push((
              year: year,
              suffix: item.at("suffix", default: ""),
              supplement: item.supplement,
            ))
        }

        let year-parts = ()
        for (year, year-items) in by-year.pairs() {
          if year-items.len() == 1 {
            let it = year-items.first()
            let year-str = year + it.suffix
            if it.supplement != none {
              year-parts.push([#year-str: #it.supplement])
            } else {
              year-parts.push(year-str)
            }
          } else if collapse-mode == COLLAPSE.year-suffix-ranged {
            year-parts.push(collapse-year-suffix-ranged(
              year-items,
              delimiter: year-suffix-delimiter,
            ))
          } else {
            year-parts.push(collapse-year-suffix(
              year-items,
              delimiter: year-suffix-delimiter,
            ))
          }
        }

        author-parts.push(
          [#display-author#name-year-delimiter#year-parts.join(
              cite-group-delimiter,
            )],
        )
      }
    }

    let final-delimiter = if after-collapse-delimiter != none {
      after-collapse-delimiter
    } else {
      delimiter
    }

    return author-parts.join(final-delimiter)
  }

  // Unknown collapse mode, fall back to simple join
  items
    .map(it => {
      if it.supplement != none {
        [#it.order: #it.supplement]
      } else {
        str(it.order)
      }
    })
    .join(delimiter)
}
