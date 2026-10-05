#import "../plain-document.typ": plain-document
#import "../../lib/_mod.typ": *
#import "../../lib/utils/date.typ": custom-date-format

/// #set raw(lang: "typst")
/// Creates a requirements profile (kravprofil) for an elected position. Apply with `#show: kravprofil.with(...)` or `#show: requirements-profile.with(...)`.
///
/// === Notes
/// - A mandate-period row is rendered first, then the body as a preamble, and finally the requirements and merits as a two-column bullet list.
/// - The mandate period defaults to the full calendar year of `year` (Jan 1 – Dec 31) when `mandate` is left at its default `auto`.
///
/// === Example
/// ```typst
/// #import "@preview/dsek:0.1.0": *
/// #import strings: styr
///
/// #show: kravprofil.with(
///   position: styr.ordf, // or a plain string: "Ordförande"
///   requirements: (
///     "Godkänd i B2",
///   ),
///   merits: (
///     "Erfarenhet av projektledning",
///     "Tidigare ordföranderoll i studentförening",
///   ),
///   year: 2025,
///   mandate: (
///     // set to `auto` or omit for default of jan 1 – dec 31
///     from: date(1, 7, 2026),
///     to: date(30, 6, 2027),
///   ),
/// )
///
/// Ordförande leder sektionens styrelse och representerar sektionen utåt.
/// ```
///
/// - position (str, content): The position title, e.g. `"Vice ordförande"` or `strings.medalj.mdlm`.
/// - requirements (array): Mandatory requirements (strings or content).
/// - merits (array): Meritorious qualifications.
/// - mandate (dictionary, auto): Mandate period as `(from: datetime, to: datetime)`.
///                               Set to `auto` to use the full calendar year given by `year`.
/// - year (int): Calendar year used when `mandate: auto`.
/// - lang (str): The language of the document (same format as `text.lang`).
///               Only "sv" and "en" are supported.
/// - date (datetime): The date at which the document was written.
/// - body (content): The body of the document.
///
/// -> content
#let requirements-profile(
  position: none,
  requirements: (),
  merits: (),
  mandate: auto,
  year: datetime.today().year(),
  lang: "sv",
  date: datetime.today(),
  body,
) = {
  required(
    position,
    "position",
    fn: "requirements-profile",
    hint: "the position title, e.g. position: \"Vice ordförande\"",
  )
  required(
    requirements,
    "requirements",
    fn: "requirements-profile",
    hint: "array of requirements, e.g. requirements: (\"Ansvarsfull\", \"Stresshanteringsförmåga\", \"Godkänd i B2an\")",
  )

  let req-profile-name = translate("Kravprofil", "Requirements profile")
  let default-start = datetime(day: 1, month: 1, year: year)
  let default-stop = datetime(day: 31, month: 12, year: year)

  show: plain-document.with(
    title: [#req-profile-name: #position],
    doc-type: req-profile-name,
    lang: lang,
    // meeting: meeting,
    date: date,
  )

  let mandate = if mandate == auto {
    (from: default-start, to: default-stop)
  } else {
    let hint = "use e.g `mandate: (from: date(1, 7, 2026), to: date(31, 6, 2027))`, or set mandate: auto for the full calendar year"
    assert(
      type(mandate) == dictionary,
      message: "mandate must be a dictionary\n  hint: " + hint,
    )
    required-keys(
      mandate,
      ("from", "to"),
      fn: "requirements-profile (mandate)",
      hint: hint,
    )
    mandate
  }

  let from = context custom-date-format(mandate.from, pattern: "medium", lang: text.lang)
  let to = context custom-date-format(mandate.to, pattern: "medium", lang: text.lang)
  grid(
    columns: 2,
    column-gutter: 1em,
    stroke: none,
    [*#translate("Mandatperiod", "Mandate"):*], [#from -- #to],
  )

  body

  set heading(numbering: none)
  set par(justify: false)

  table(
    columns: (1fr, 1fr),
    row-gutter: 0.5em,
    stroke: none,
    translate([== Krav], [== Requirements]), translate([== Meriterande], [== Merits]),
    [#for r in requirements [- #r]], [#for m in merits [- #m]],
  )
}

/// Swedish binding for `requirements-profile`
#let kravprofil = requirements-profile
