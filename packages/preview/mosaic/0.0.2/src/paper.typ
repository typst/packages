// The deck's slide size, resolved once and carried as concrete dimensions.
//
// Mosaic needs the slide size as figures, not merely as a page argument: the
// `speaker` and `notes` outputs re-render every slide as a scaled thumbnail on
// A4, so the renderer must know the source dimensions while laying out a page
// of a different size. Typst exposes no way to read a named paper's dimensions
// back, so a bare Typst paper name cannot be accepted here. Give one of the
// aliases below, or an explicit `(width, height)`.
#import "shared.typ": fail

#let default-paper = "16-9"

// The exact dimensions of Typst's own `presentation-16-9` and
// `presentation-4-3` papers. Stated here so the page and the thumbnail agree:
// deriving the page from a Typst preset while sizing the thumbnail from a
// separately written figure let the two drift apart, and they had. The
// thumbnail was built at 10in by 7.5in for a page that is 280mm by 210mm, so a
// slide's content reflowed at one width and was displayed at another.
#let paper-aliases = (
  "16-9": (width: 297mm, height: 167.0625mm),
  "4-3": (width: 280mm, height: 210mm),
)

#let paper-error = (
  "setup paper must be "
    + paper-aliases.keys().map(repr).join(", ")
    + ", or a dictionary with width and height"
)

#let resolve-paper(value) = {
  if type(value) == str {
    if value not in paper-aliases {
      fail(paper-error)
    }
    return paper-aliases.at(value)
  }
  if (
    type(value) != dictionary
      or value.keys().sorted() != ("height", "width")
      or type(value.width) != length
      or type(value.height) != length
  ) {
    fail(paper-error)
  }
  value
}
