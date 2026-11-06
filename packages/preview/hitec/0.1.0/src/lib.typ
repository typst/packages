#import "layouts/doc.typ": doc
#import "pages/title-block.typ": title-block
#import "pages/title-page.typ": title-page

/// All functions and variables to be used in the technical report.
///
/// -> dictionary
#let documentclass(
  /// Title of the report
  ///
  /// -> content | string
  title: [],
  /// Name(s) of Author(s)
  ///
  /// -> string | array
  author: "",
  /// Name of Company/Institution
  ///
  /// -> content | string
  company: [],
  /// Confidentiality Level
  ///
  /// -> content | string
  confidential: [],
  /// Date of submission
  ///
  /// -> datetime
  date: datetime.today(),
  /// Enable double-sided printing
  ///
  /// -> bool
  double-sided: true,
  /// Add margins to binding side for printing
  ///
  /// -> bool
  print: true,
) = {
  return (
    // Metadata
    title: title,
    author: author,
    company: company,
    confidential: confidential,
    date: date,
    double-sided: double-sided,
    print: print,
    // Layouts
    doc: (..args) => {
      doc(
        ..args,
        title: title,
        author: author,
        company: company,
        confidential: confidential,
        date: date,
        double-sided: double-sided,
        print: print,
      )
    },
    // Pages
    title-block: (..args) => {
      title-block(
        ..args,
        title: title,
        author: author,
        company: company,
        confidential: confidential,
        date: date,
        print: print,
      )
    },
    title-page: (..args) => {
      title-page(
        ..args,
        title: title,
        author: author,
        company: company,
        confidential: confidential,
        date: date,
        double-sided: double-sided,
      )
    },
  )
}
