#import "subsection.typ": subsection

/// Creates a generic section with a title, some text content, and some subsections.
/// 
/// -> content
#let section(
  /// -> str | none
  title: none,
  /// -> array
  subsections: ()
) = {
  if title != none {
    [== #title]
  }

  line()
  subsections.map(x => subsection(..x)).join()
}
