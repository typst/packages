/// *Internal function.* Returns whether the current page is one where a chapter begins. This is
/// used for styling headers and footers.
///
/// This function is contextual.
///
/// -> bool
#let is-chapter-page() = {
  // all chapter headings
  let chapters = query(heading.where(level: 1))
  // return whether one of the chapter headings is on the current page
  chapters.any(c => c.location().page() == here().page())
}

// this is an imperfect workaround, see
// - https://github.com/typst/typst/issues/2722
// - https://github.com/typst/typst/issues/4438
// it requires manual insertion of `#chapter-end()` at the end of each chapter

#let _chapter_end = <thesis-chapter-end>
/// Inserts an invisible marker that marks the end of a chapter. This is used for determining
/// whether a page is empty and thus whether it should have header and footer.
///
/// -> content
#let chapter-end() = [#metadata(none) #_chapter_end]
/// *Internal function.* Returns whether the current page is empty. This is determined by checking
/// whether the current page is between the previous chapter's end and the next chapter's beginning.
/// This is used for styling headers and footers.
///
/// This function is contextual.
///
/// -> bool
#let is-empty-page() = {
  // page where the next chapter begins
  let next-chapter = {
    let q = query(heading.where(level: 1).after(here()))
    if q.len() != 0 {
      q.first().location().page()
    }
  }

  // page where the current chapter ends
  let current-chapter-end = {
    let q = query(heading.where(level: 1).before(here()))
    if q.len() != 0 {
      let current-chapter = q.last()
      let q = query(selector(_chapter_end).after(current-chapter.location()))
      if q.len() != 0 {
        q.first().location().page()
      }
    }
  }

  if next-chapter == none or current-chapter-end == none {
    return false
  }

  // return whether we're between two chapters
  let p = here().page()
  current-chapter-end < p and p < next-chapter
}

/// *Internal function.* Checks whether all chapters and chapter ends are placed properly. The
/// document should contain an alternating sequence of chapters and chapter ends; if a chapter
/// doesn't have an end or vice-versa, this can lead to wrongly displayed/hidden headers and footers.
///
/// The result of this function is invisible if it succeeds.
///
/// -> content
#let enforce-chapter-end-placement() = context {
  let ch-sel = heading.where(level: 1)
  let end-sel = selector(_chapter_end)

  let chapters-and-ends = query(ch-sel.or(end-sel))

  let at-page(item) = "on page " + str(item.location().page())
  let ch-end-assert(check, message) = {
    if not check {
      panic(message() + " (hint: set `strict-chapter-end: false` to build anyway and inspect the document)")
    }
  }

  for chunk in chapters-and-ends.chunks(2) {
    // the first of each pair must be a chapter
    let ch = chunk.first()
    ch-end-assert(
      ch.func() == heading,
      () => "extra chapter-end() found " + at-page(ch)
    )

    // each chapter must come in a pair
    ch-end-assert(
      chunk.len() == 2,
      () => "no chapter-end() for chapter " + at-page(ch)
    )

    // the second item in the pair must be a chapter end
    let end = chunk.last()
    ch-end-assert(
      end.func() == metadata,
      () => "new chapter " + at-page(end) + " before the chapter " + at-page(ch) + " ended"
    )
  }
}

/// *Internal function.* This is intended to be called in a section show rule. It returns whether
/// that section is the first in the current chapter
///
/// This function is contextual.
///
/// -> bool
#let is-first-section() = {
  // all previous headings
  let prev = query(selector(heading).before(here(), inclusive: false))
  // returns whether the previous heading is a chapter heading
  prev.len() != 0 and prev.last().level == 1
}

// the following function is from
// https://github.com/EpicEricEE/typst-plugins/blob/b13b0e1bc30beba65ff19d029e2dad61239a2819/outex/src/outex.typ#L1-L27
// Copyright (c) 2023 Eric Biedert, MIT License

/// Repeat the given content to fill the full space. In contrast to the built-in ```typc repeat()```
/// function, this can produce exact and aligned gaps.
///
/// - gap (length, none): The gap between repeated items.
/// - justify (bool): Whether to increase the gap to justify the items.
/// - body (content): the content to repeat
/// -> content
#let repeat(
  gap: none,
  justify: false,
  body
) = layout(size => style(styles => {
  let pt(length) = measure(h(length), styles).width
  let width = measure(body, styles).width
  let amount = calc.floor(pt(size.width + gap) / pt(width + gap))

  let gap = if not justify { gap } else {
    (size.width - amount * width) / (amount - 1)
  }

  let items = ((box(body),) * amount)
  if type(gap) == length and gap != 0pt {
    items = items.intersperse(h(gap))
  }

  items.join()
}))
