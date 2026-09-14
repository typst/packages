// Hack: adds heading numbering into PDF bookmark outlines
// Taken from: https://forum.typst.app/t/how-to-display-chapter-numbers-in-pdf-bookmarks/4912/4
// Github issue, might get fixed eventually:
// https://github.com/typst/typst/issues/2416#issue-1947070361

// This code snippet should be placed:
// - AFTER styling (eg. chapters) so link points to above the actual heading, and
// - BEFORE page/line breaks so link points to after the page/line breaks.
#let bookmark-numbering-hack(it) = {
  // Remove original headings from bookmarks. We will add new ones later.
  set heading(bookmarked: false)
  show heading: it => if it.bookmarked {
    // This heading has been processed. Keep it untouched.
    it
  } else if not it.outlined {
    // This heading is not outlined, thus should not be bookmarked. Keep it untouched.
    it
  } else {
    let (numbering, body, ..args) = it.fields()
    let _ = args.remove("label", default: none)

    // Render the numbering manually
    let numbered-body = block({
      if numbering != none { counter(heading).display(numbering) }
      [ ] // space in the bookmark
      body
    })

    { // Add our bookmarked, hidden heading
      show heading: none
      heading(..args, outlined: false, bookmarked: true, numbering: none, numbered-body)
    }

    // regular heading
    it

  }
  it
}
