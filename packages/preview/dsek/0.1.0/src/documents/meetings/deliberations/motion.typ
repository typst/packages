#import "deliberation.typ": deliberation

/// #set raw(lang: "typst")
/// Creates a motion document. Apply with `#show: motion.with(...)`.
///
/// === Notes
/// - Author signatures are appended automatically through the `authors` parameter.
/// - A paragraph is given extra vertical space before it when it ends with a resolution
///   phrase: Swedish `yrka … på` or `beslut`/`besluta`, or English `move`/`moves`/`decide`.
///
/// === Example
/// ```typst
/// #import "@preview/dsek:0.1.0": *
/// #import strings: km
///
/// #show: motion.with(
///   title: [Uppdatering av Policy för ekonomi],
///   meeting: "S23",
///   authors: (
///     // position defaults to "Sektionsmedlem" / "Guild member",
///     // message defaults to "Lund, dag som ovan" / "Lund, day as above"
///     (name: "Truls Teknolog", position: km.mastare),
///     (name: "Trula Teknolog", message: "För uppdaterad information"),
///   ),
/// )
///
/// Vi har bytt sektionsbil (igen), så policy för ekonomi bör reflektera detta.
///
/// Vi yrkar på // extra space is inserted before this paragraph automatically
/// - att uppdatera "Policy för ekonomi" enligt bilaga // becomes: *att* uppdatera...
/// ```
///
/// - title (content): The title of the motion.
/// - meeting (str, content): The meeting for which the motion was written, e.g. `"HTM1"`.
/// - authors (array): Signatories. Each signatory dict must have at least the key `name`, optionally `message`, `position` and `signature`.
/// - lang (str): The language of the document (same format as `text.lang`).
///               Only "sv" and "en" are supported.
/// - date (datetime): The date at which the document was written.
/// - body (content): The body of the document.
///
/// -> content
#let motion(
  title: none,
  meeting: none,
  authors: (),
  lang: "sv",
  date: datetime.today(),
  body,
) = deliberation(
  doc-type: "Motion",
  title: title,
  meeting: meeting,
  authors: authors,
  lang: lang,
  date: date,
  body,
)

