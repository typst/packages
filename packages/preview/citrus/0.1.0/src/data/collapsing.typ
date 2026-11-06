// =============================================================================
// Citation Collapsing
// =============================================================================
// Implements CSL citation collapsing rules:
// - citation-number: [1, 2, 3, 4] → [1-4]
// - year: (Smith 2000, Smith 2001) → (Smith 2000, 2001)
// - year-suffix: (Smith 2000a, Smith 2000b) → (Smith 2000a, b)
// - year-suffix-ranged: (Smith 2000a, b, c) → (Smith 2000a-c)

#import "../core/constants.typ": COLLAPSE

/// Collapse consecutive numeric citations into ranges
///
/// Example: (1, 2, 3, 5, 7, 8, 9) → ((1, 3), (5, 5), (7, 9))
/// Returns array of (start, end) tuples
#let collapse-numeric-ranges(numbers) = {
  if numbers.len() == 0 { return () }

  // Sort numbers
  let sorted = numbers.sorted()

  let ranges = ()
  let start = sorted.first()
  let end = start

  for i in range(1, sorted.len()) {
    let num = sorted.at(i)
    if num == end + 1 {
      // Continue the range
      end = num
    } else {
      // End current range, start new one
      ranges.push((start: start, end: end))
      start = num
      end = num
    }
  }

  // Push final range
  ranges.push((start: start, end: end))
  ranges
}

/// Format collapsed numeric citations
///
/// - ranges: Array of (start, end) tuples from collapse-numeric-ranges
/// - items: Original items with supplements (for locator handling)
/// - delimiter: Delimiter between items
/// - range-delimiter: Delimiter for ranges (default: en-dash)
/// Returns: Formatted content
#let format-collapsed-numeric(
  ranges,
  items,
  delimiter: ", ",
  range-delimiter: "–",
) = {
  let parts = ()

  for r in ranges {
    if r.start == r.end {
      // Single item
      let item = items.find(it => it.order == r.start)
      if item != none and item.supplement != none {
        parts.push([#r.start: #item.supplement])
      } else {
        parts.push(str(r.start))
      }
    } else if r.end == r.start + 1 {
      // Two consecutive items - don't use range
      let item1 = items.find(it => it.order == r.start)
      let item2 = items.find(it => it.order == r.end)

      if item1 != none and item1.supplement != none {
        parts.push([#r.start: #item1.supplement])
      } else {
        parts.push(str(r.start))
      }

      if item2 != none and item2.supplement != none {
        parts.push([#r.end: #item2.supplement])
      } else {
        parts.push(str(r.end))
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
            parts.push([#n: #item.supplement])
          } else {
            parts.push(str(n))
          }
          n += 1
        }
      } else {
        // Collapse to range
        parts.push(str(r.start) + range-delimiter + str(r.end))
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
/// Returns: Formatted collapsed content
#let apply-collapse(
  items,
  collapse-mode,
  enable-grouping: false,
  delimiter: ", ",
  cite-group-delimiter: ", ",
  year-suffix-delimiter: ", ",
  after-collapse-delimiter: none,
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
        author-parts.push([#display-author, #years.join(cite-group-delimiter)])
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
        author-parts.push([#display-author, #years.join(cite-group-delimiter)])
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
          [#display-author, #year-parts.join(cite-group-delimiter)],
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
