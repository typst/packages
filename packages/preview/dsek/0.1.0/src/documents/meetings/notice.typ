#import "../plain-document.typ": plain-document
#import "../../lib/_mod.typ": *
#import "../../lib/utils/date.typ": custom-date-format

/// #set raw(lang: "typst")
/// Creates a meeting notice/summons (kallelse) document. Apply with `#show: kallelse.with(...)` or `#show: notice.with(...)`.
///
/// === Notes
/// - A "Tid och plats" / "Time and location" block is automatically prepended to the body.
/// - The body can include either free-form text or a numbered list using bracket syntax
///   `- [Action] Item name` similar to the `agenda` function.
///
///   - The action label (e.g. `Beslut`, `Information`) goes inside the brackets; leave the
///     brackets empty for no action (e.g. for OFMÖ / OFMA).
///     If any item does not begin with brackets, the whole list is left unformatted (no error).
///   - Links attached to an item (using `+ #link("link.com")` in a sublist to an item)
///     are collected into the Annex / Bilaga column and numbered in order of appearance.
///     Referring to the same link more than once gives it the same number. A link written
///     with a custom label (display text different from the URL) is shown as-is and is not numbered.
///
/// === Example
/// ```typst
/// #import "@preview/dsek:0.1.0": *
/// #import strings: styr
///
/// #show: kallelse.with(
///   meeting: "S05",
///   time: date(15, 3, 2025, time: (13, 0)),
///   location: [E:A, LTH],
///   authors: (
///     // position defaults to "Sektionsmedlem" / "Guild member",
///     // message defaults to "Lund, dag som ovan" / "Lund, day as above"
///     (name: "Truls Teknolog", position: styr.ordf),
///   ),
/// )
///
/// Kära Sektionsmedlemmar,
///
/// idag har vi den stora äran att än en gång få kalla er till sektionsmöte.
/// Tyvärr räckte inte budgeten till fika, men vi hoppas att ni kommer ändå.
///
/// - [] OFMÖ // [] = no action label
/// - [Sång] Sektionshymn
///   + #link("https://dsek.se/hymn")[Text]    // link shown in Bilaga / Annex column with label Text
/// - [Beslut] Val av justerare
/// - [Information] Ekonomisk status
///   + #link("https://dsek.se/rambudget")     // numbered: 1
///   + #link("https://dsek.se/detaljbudget")  // numbered: 2
/// - [Beslut] Motion: Jag tycker sektionen borde ha Financial Times
///   + #link("https://dsek.se/rambudget")     // numbered: 1 (same link)
/// - [] OFMA
/// ```
///
/// - meeting (str, content): The meeting for which the document was written, e.g. `"HTM1"`.
/// - authors (array): Signatories. Each signatory dict must have at least the key `name`, optionally `message`, `position` and `signature`.
/// - time (datetime): Meeting date and time. Use `date()`, e.g. `date(15, 3, 2025, time: (13, 0))`.
/// - location (str, content): Meeting venue, e.g. `[E:1124]`.
/// - adjournment (datetime, dict): Optional planned adjournment, shown in the time/location block.
///                                 Either a `date(...)` or a dictionary `(date: date(...), location: [...])`.
/// - meeting-type (content, auto): The type of meeting, e.g. `"Styrelsemöte"` or `"Studierådsmöte"`.
///                           If set to `auto`, the meeting type is detected from the the `meeting`
///                           parameter -- `SXX` gives "Styrelsemöte" and `SRDXX` gives "Studierådsmöte"
///                           (where `X` is a digit).
/// - lang (str): The language of the document (same format as `text.lang`).
///               Only "sv" and "en" are supported.
/// - date (datetime): The date at which the document was written.
/// - body (content): The body of the document.
///
/// -> content
#let notice(
  meeting: none,
  authors: (),
  time: none,
  location: none,
  adjournment: none,
  meeting-type: auto,
  lang: "sv",
  date: datetime.today(),
  body,
) = {
  required(location, "location", fn: "notice", hint: "meeting venue, e.g. location: [E:1124]")
  required(authors, "authors", fn: "notice", hint: "list of author dicts, e.g. authors: ((name: \"Truls Teknolog\"),)")
  required(time, "time", fn: "notice", hint: "use the date() helper, e.g. time: date(15, 3, 2026, time: (12, 15))")

  let notice-name = translate("Kallelse", "Notice")
  let meeting-time = context custom-date-format(time, pattern: "full", lang: text.lang)
  let meeting-type = detect-meeting-type(meeting, meeting-type)

  show: plain-document.with(
    title: [#notice-name #translate("till", "for") #meeting-type #meeting, #meeting-time],
    date: date,
    lang: lang,
    meeting: meeting,
    doc-type: notice-name,
  )

  set document(title: [#notice-name #meeting #time.year()])

  heading(
    numbering: none,
    depth: 2,
    translate("Tid och plats", "Time and location"),
  )
  v(0.5em)

  let date-fmt(time) = context [
    #let day = custom-date-format(time, pattern: "full", lang: text.lang)
    #let time = translate(
      time.display("[hour repr:24]:[minute]"),
      time.display("[hour repr:12]:[minute] [period]"),
    )
    #day.replace(regex("^\w"), m => upper(m.text))
    #translate([klockan], [at])
    #time
  ]

  let time-and-date = (
    [*#translate("Tid", "Time"):*],
    date-fmt(time),
    [*#translate("Plats", "Location"):*],
    location,
  )

  if adjournment != none {
    let hint = "use either a single `date(...)` or a dictionary `(date: date(...), location: [...])`"
    time-and-date.push([*#translate("Ajourneringsdag", "Adjournment day")*:])
    time-and-date.push({
      if type(adjournment) == datetime {
        date-fmt(adjournment)
      } else if type(adjournment) == dictionary {
        required-keys(
          adjournment,
          ("date", "location"),
          hint: hint,
        )
        [
          #date-fmt(adjournment.date)
          #context translate-str("i", "in")
          #adjournment.location
        ]
      } else {
        assert(false, message: hint)
      }
    })

    //   if type(adjournment) == datetime {
    //   date-fmt(adjournment)
    // } else [
    //   #adjournment
    // ])
  }

  grid(
    columns: (auto, 1fr),
    stroke: none,
    row-gutter: 1em,
    column-gutter: 1em,
    ..time-and-date
  )

  show list: agenda-fmt.with(make-heading: true)
  v(1.5em)
  body
  author-signatures(authors)
}

/// Swedish binding for `notice`
#let kallelse = notice
