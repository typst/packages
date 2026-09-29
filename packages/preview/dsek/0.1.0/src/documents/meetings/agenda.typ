#import "../plain-document.typ": plain-document
#import "../../lib/_mod.typ": *
#import "../../lib/utils/date.typ": custom-date-format

/// #set raw(lang: "typst")
/// Creates an agenda (föredragningslista) document. Apply with `#show: föredragningslista.with(...)` or `#show: agenda.with(...)`.
///
/// === Notes
/// - The body should include a numbered list using bracket syntax: `- [Action] Item name`.
///   The action label (e.g. `Beslut`, `Information`) goes inside the brackets; leave the
///   brackets empty for no action (e.g. for OFMÖ / OFMA).
///   If any item does not begin with brackets, the whole list is left unformatted (no error).
/// - Links attached to an item (using `+ #link("link.com")` in a sublist to an item)
///   are collected into the Annex / Bilaga column and numbered in order of appearance.
///   Referring to the same link more than once gives it the same number. A link written
///   with a custom label (display text different from the URL) is shown as-is and is not numbered.
///
/// === Example
/// ```typst
/// #import "@preview/dsek:0.1.0": *
/// #import strings: otherpos
///
/// #show: föredragningslista.with(
///   meeting: "HTM1",
///   time: date(15, 3, 2026, time: (17, 15)),
///   authors: (
///     (name: "Truls Teknolog", position: otherpos.talman),
///   ),
/// )
///
/// - [] TFMÖ                                  // [] = no action label
/// - [Sång] Sektionshymn
///   + #link("https://dsek.se/hymn")[Text]    // link shown in Annex / Bilaga column with label "Text"
/// - [Beslut] Val av justerare
/// - [Information] Ekonomisk status
///   + #link("https://dsek.se/rambudget")     // numbered: 1
///   + #link("https://dsek.se/detaljbudget")  // numbered: 2
/// - [Beslut] Motion: Jag tycker sektionen borde ha Financial Times
///   + #link("https://dsek.se/rambudget")     // numbered: 1 (same link)
/// - [] TFMA
/// ```
///
/// - meeting (str, content): The meeting which the agenda outlines, e.g. `"HTM1"`.
/// - time (datetime): Meeting date and time. Use `date()`, e.g. `date(15, 3, 2025, time: (13, 0))`.
/// - meeting-type (content, auto): The type of meeting, e.g. `"Styrelsemöte"` or `"Studierådsmöte"`.
///                                 If set to `auto`, the meeting type is detected from the the `meeting`
///                                 parameter -- `SXX` gives "Styrelsemöte" and `SRDXX` gives "Studierådsmöte"
///                                 (where `X` is a digit).
/// - authors (array): Signatories. Each signatory dict must have at least the key `name`, optionally `message`, `position` and `signature`.
/// - lang (str): The language of the document (same format as `text.lang`).
///               Only "sv" and "en" are supported.
/// - date (datetime): The date at which the document was written.
/// - body (content): The body of the document.
///
/// -> content
#let agenda(
  meeting: none,
  time: none,
  meeting-type: auto,
  authors: (),
  date: datetime.today(),
  lang: "sv",
  body,
) = {
  required(time, "time", fn: "agenda", hint: "use the date() helper, e.g. time: date(15, 3, 2026, time: (12, 15))")
  required(meeting, "meeting", fn: "agenda", hint: "short meeting identifier, e.g. meeting: \"HTM1\"")

  let agenda-name = translate("Föredragningslista", "Agenda")
  let meeting-time = context custom-date-format(time, pattern: "full", lang: text.lang)
  let meeting-type = detect-meeting-type(meeting, meeting-type)

  show: plain-document.with(
    title: [#agenda-name #translate("för", "for") #meeting-type #meeting, #meeting-time],
    date: date,
    lang: lang,
    meeting: meeting,
    doc-type: agenda-name,
  )

  show list: agenda-fmt
  body
  author-signatures(authors)
}

/// Swedish binding for `agenda`
#let föredragningslista = agenda
