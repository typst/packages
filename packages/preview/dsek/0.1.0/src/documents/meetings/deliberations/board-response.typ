#import "deliberation.typ": deliberation
#import "../../../lib/_mod.typ": translate

/// #set raw(lang: "typst")
/// Creates a board response (styrelsens svar) document. Apply with `#show: styrelsens-svar.with(...)` or `#show: board-response.with(...)`.
///
/// === Notes
/// - Author signatures are appended automatically through the `authors` parameter.
/// - A paragraph is given extra vertical space before it when it ends with a resolution
///   phrase: Swedish `yrka … på` or `beslut`/`besluta`, or English `move`/`moves`/`decide`.
///
/// === Example
/// ```typst
/// #import "@preview/dsek:0.1.0": *
/// #import strings: styr
///
/// #show: styrelsens-svar.with(
///   title: [3.0 flugor i en smäll],
///   meeting: "HTM1",
///   authors: (
///     // position defaults to "Sektionsmedlem" / "Guild member",
///     // message defaults to "Lund, dag som ovan" / "Lund, day as above"
///     (name: "Truls Teknolog", position: styr.ordf),
///     (name: "Trula Teknolog", message: "För styrelsen"),
///   ),
/// )
///
/// #emoji.thumb.up
///
/// Styrelsen yrkar på // extra space is inserted before this paragraph automatically
/// - att bifalla motionen i sin helhet // becomes: *att* bifalla...
/// ```
///
/// - title (content): The title of the motion being responded to.
/// - meeting (str, content): The meeting for which the motion and response were written, e.g. `"HTM1"`.
/// - authors (array): Signatories. Each signatory dict must have at least the key `name`, optionally `message`, `position` and `signature`.
/// - lang (str): The language of the document (same format as `text.lang`).
///               Only "sv" and "en" are supported.
/// - date (datetime): The date at which the document was written.
/// - body (content): The body of the document.
///
/// -> content
#let board-response(
  title: none,
  meeting: none,
  authors: (),
  lang: "sv",
  date: datetime.today(),
  body,
) = deliberation(
  doc-type: translate("Styrelsens svar", "Board response"),
  title: title,
  meeting: meeting,
  authors: authors,
  lang: lang,
  date: date,
  body,
)

/// Swedish binding for `board-response`
#let styrelsens-svar = board-response
