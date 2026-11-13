/// Layout module for APA 7th Edition.
///
/// Implements page geometry, 1-inch margins, running heads, and page numbers
/// following the official Publication Manual of the American Psychological
/// Association (7th ed.) and Typst's Universal Access / PDF/UA-1 guidelines.

/// Normalizes the running head string for professional papers:
/// - Converted to uppercase.
/// - Truncated to a maximum of 50 characters (including spaces and punctuation).
#let format-running-head(title) = {
  if title == none or title == "" {
    return none
  }
  let text-str = if type(title) == str {
    title
  } else {
    // If content is passed, fallback representation
    repr(title)
  }
  let upper-str = upper(text-str)
  if upper-str.len() > 50 {
    upper-str.slice(0, 50)
  } else {
    upper-str
  }
}

/// Applies APA 7 page layout, margins, and headers to the document.
///
/// Parameters:
/// - paper-type: "student" | "professional".
///   - "student": No running head in the header; only page number flush right.
///   - "professional": Running head flush left (ALL CAPS, max 50 chars), page number flush right.
/// - running-head: Shortened title string for the running head (professional papers).
/// - paper-size: "us-letter" (8.5in x 11in) or "a4" (210mm x 297mm). Default is "us-letter".
/// - body: The content of the document.
#let apply-layout(
  paper-type: "student",
  running-head: none,
  paper-size: "us-letter",
  body,
) = {
  // APA 7 specifies 1 inch (2.54 cm) margins on all sides.
  let page-margin = (
    top: 1in,
    bottom: 1in,
    left: 1in,
    right: 1in,
  )

  let clean-running-head = if paper-type == "professional" {
    format-running-head(running-head)
  } else {
    none
  }

  // Header construction:
  // In Typst, content placed in page(header: ...) is automatically tagged as
  // a PDF artifact, ensuring screen readers do not repetitively announce
  // page numbers during continuous body text reading (WCAG / PDF/UA-1).
  let page-header = context {
    let page-num = counter(page).display("1")
    if paper-type == "professional" and clean-running-head != none {
      grid(
        columns: (1fr, auto),
        align: (left + bottom, right + bottom),
        clean-running-head,
        page-num,
      )
    } else {
      align(right + bottom, page-num)
    }
  }

  set page(
    paper: paper-size,
    margin: page-margin,
    header: page-header,
    header-ascent: 0.5in,
    footer: none,
  )

  // APA 7 page numbering starts on the title page as page 1.
  counter(page).update(1)

  body
}
