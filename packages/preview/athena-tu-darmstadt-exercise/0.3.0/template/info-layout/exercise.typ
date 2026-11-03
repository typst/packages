#import "../common/format.typ": format-date, text-roboto
#import "utils.typ": resolve-term

/// The default version of the title subline.
///
/// *Possible `info` items:*
/// - `term`: The current term (types: #str)
/// - `date`: A date related to the exercise (types: #str, #datetime)
/// - `sheet`: The number of this sheet/exercise (types: #int)
///
/// - additional (content,none): Additional content to be displayed after the previous options
/// -> function
#let exercise(additional: none) = (info, dict) => {
  if "term" in info {
    resolve-term(info.term, info, dict)
    linebreak()
  }
  if "date" in info {
    format-date(info.date, dict.locale)
    linebreak()
  }
  if "sheet" in info {
    [#dict.sheet #info.sheet]
    linebreak()
  }
  additional
}
