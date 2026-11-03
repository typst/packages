// =============================================================================
// azubinachweis — training record sheets for the German apprenticeship system
//
// Three document kinds:
//   nachweis(..)      Wochenbericht  — weekly report, sections with bullet lists
//   tagesbericht(..)  Tagesbericht   — daily report, one table row per date
//   deckblatt(..)     Deckblatt      — cover sheet of the record book
//
// Every label, colour, spacing and font is overridable; the defaults produce
// the plain grey layout.
//
// Naming: public parameters are German, because they name the sections of a
// German form and must match the labels printed on it. Everything internal —
// helpers, locals, comments, error messages — is English.
// =============================================================================

// -----------------------------------------------------------------------------
// Labels
// -----------------------------------------------------------------------------

/// Every label used by the layout. Pass individual overrides through the
/// `bezeichnungen` parameter of the document functions rather than replacing
/// this dictionary; the two are merged. Replacing the labels is also how the
/// sheet is run in another language.
/// -> dictionary
#let standard-bezeichnungen = (
  // header fields
  name: "Name",
  ausbildungsjahr: "Ausbildungsjahr",
  zeitraum: "Zeitraum",
  abteilung: "Abteilung",
  beruf: "Ausbildungsberuf",
  fachrichtung: "Fachrichtung/Schwerpunkt",
  betrieb: "Ausbildungsbetrieb",
  ausbilder: "Verantwortliche/r Ausbilder/in",
  heft: "Heft-Nr.",
  adresse: "Adresse",
  geburtsdatum: "Geburtsdatum",
  beginn: "Beginn der Ausbildung",
  ende: "Ende der Ausbildung",
  // sections
  taetigkeiten: "Tätigkeitsbericht",
  unterweisungen: "Unterweisungen, betrieblicher Unterricht",
  schule: "Schulbericht",
  bemerkungen: "Bemerkungen des Ausbilders",
  weiteres: "Weitere Berichte",
  // daily table
  datum: "Datum",
  tag: "Tag",
  taetigkeit: "Tätigkeit",
  stunden: "Std.",
  summe: "Gesamt",
  // footer
  unterschrift-zusatz: "(Unterschrift und Datum)",
  deckblatt-titel: "Ausbildungsnachweis",
)

/// Default labels of the two signature fields.
/// -> array
#let standard-unterschriften = ("Auszubildender", "Ausbilder")

// -----------------------------------------------------------------------------
// Internal helpers
// -----------------------------------------------------------------------------

// Empty means: nothing passed, empty string, empty array, empty content.
#let _empty(value) = (
  value == none or value == "" or value == () or value == []
)

// Resolve content block number i. A non-empty block wins; an empty block []
// falls back to the named argument, so single blocks can be skipped:
//   #nachweis(..)[][- second one only]
#let _block(blocks, i, named) = {
  if blocks.len() > i and not _empty(blocks.at(i)) { blocks.at(i) } else { named }
}

// A sink parameter swallows misspelled named arguments silently, so report
// them instead of letting them pass without effect.
#let _check(extra) = {
  let unknown = extra.named().keys()
  assert(
    unknown.len() == 0,
    message: "azubinachweis: unknown argument "
      + unknown.map(k => "\"" + k + "\"").join(", "),
  )
}

// Title line: either the caller's own, or week, year and name joined up.
#let _title-line(title, week, year, name) = {
  if title != auto { return title }
  let parts = ()
  if week != "" { parts.push[Kalenderwoche #week] }
  if year != "" { parts.push[#year] }
  if name != "" { parts.push[#name] }
  parts.join[ #sym.dash.en ]
}

// The header rows shared by nachweis and tagesbericht, in printing order.
#let _header-fields(labels, name, year, job, field, company, trainer, period, dept, no) = (
  (labels.name, name),
  (labels.ausbildungsjahr, year),
  (labels.beruf, job),
  (labels.fachrichtung, field),
  (labels.betrieb, company),
  (labels.ausbilder, trainer),
  (labels.zeitraum, period),
  (labels.abteilung, dept),
  (labels.heft, no),
)

// Builds the drawing primitives shared by all three document kinds.
#let _parts(labels, line, head-fill, head-ink, ink, padding, border, min-height) = {
  let stroke-style = border + line

  // The one list style of the sheet, applied whichever way a section was
  // written: as an array of strings, or as markup with "-" or "+" in a content
  // block. Typst's own defaults indent differently, so without this the two
  // spellings of the same section would not look alike on the page.
  let list-style = (spacing: 0.75em, body-indent: 0.55em, indent: 0.2em)

  let bullets(items) = list(..list-style, ..items)

  // Strings stay as they are, arrays become bullet lists, content is set in the
  // same style and otherwise passes through untouched.
  let as-content(value) = if type(value) == array { bullets(value) } else {
    set list(..list-style)
    set enum(..list-style)
    value
  }

  // Grey header cell, optionally with the hour count on the right.
  // Deliberately no grid when there are no hours: a 1fr inside would stretch
  // an auto-width table column.
  let head-cell(title, hours: none) = table.cell(fill: head-fill)[
    #if hours == none {
      text(weight: "bold", fill: head-ink)[#title]
    } else {
      grid(
        columns: (1fr, auto),
        text(weight: "bold", fill: head-ink)[#title],
        text(weight: "bold", fill: head-ink)[#hours #labels.stunden],
      )
    }
  ]

  // Section box. With content it grows to fit exactly; without, it keeps the
  // minimum height as a writing area.
  let section(title, content, hours: none, height: min-height) = table(
    columns: (1fr),
    stroke: stroke-style,
    inset: (x: padding, y: 9pt),
    head-cell(title, hours: hours),
    if _empty(content) {
      block(width: 100%, height: height)
    } else {
      block(width: 100%, inset: (y: 2pt))[#as-content(content)]
    },
  )

  // Header table, built from the fields that are actually filled.
  // columns: 1 = one field per row, 2 = two fields per row (half the height)
  //
  // The label column is as wide as the longest label by default, so custom
  // labels cannot break the layout.
  let header-table(fields, label-width: auto, columns: 1) = {
    let filled = fields.filter(f => not _empty(f.at(1)))
    if filled.len() == 0 { return none }

    let build(width) = {
      let cells = ()
      if columns == 2 {
        for i in range(0, filled.len(), step: 2) {
          let (label, value) = filled.at(i)
          cells += (head-cell(label), [#value])
          if i + 1 < filled.len() {
            let (label2, value2) = filled.at(i + 1)
            cells += (head-cell(label2), [#value2])
          } else {
            cells += (table.cell(colspan: 2)[],)
          }
        }
      } else {
        for (label, value) in filled {
          cells += (head-cell(label), [#value])
        }
      }

      table(
        columns: if columns == 2 { (width, 1fr, width, 1fr) } else { (width, 1fr) },
        stroke: stroke-style,
        inset: (x: padding, y: 10pt),
        align: horizon,
        ..cells,
      )
    }

    if label-width != auto {
      build(label-width)
    } else if columns == 2 {
      // Two columns: keep each label column as narrow as possible so the
      // values get the whole remaining width
      build(auto)
    } else {
      context {
        // One column: a calm minimum width that grows with long custom
        // labels rather than wrapping them
        let measured = calc.max(
          ..filled.map(f => measure(text(weight: "bold")[#f.at(0)]).width),
        ) + 2 * padding + 2pt
        build(calc.max(5.4cm, measured))
      }
    }
  }

  // Signature fields at the foot of the page. Unbreakable, so the writing box
  // and its caption never end up on two different pages.
  let signatures(captions, height: 2cm) = {
    let n = captions.len()
    if n == 0 { return none }
    block(breakable: false, width: 100%)[
      #table(
        columns: (1fr,) * n,
        rows: (height, auto),
        stroke: stroke-style,
        inset: (x: padding, y: 9pt),
        align: center + horizon,
        ..([],) * n,
        ..captions.map(c => [
          #text(weight: "bold", fill: head-ink)[#c] \
          #text(size: 0.9em)[#labels.unterschrift-zusatz]
        ]),
      )
    ]
  }

  (
    bullets: bullets,
    as-content: as-content,
    head-cell: head-cell,
    section: section,
    header-table: header-table,
    signatures: signatures,
    stroke-style: stroke-style,
  )
}

// -----------------------------------------------------------------------------
// Fitting
// -----------------------------------------------------------------------------

/// Solve the elastic heights so that a sheet stays on one page.
///
/// A sheet is a linear stack — rigid pieces separated by `luft`, one writing
/// area per empty section, the signature block at the foot — so its height is
/// affine in the three elastic amounts: `base` is the stack with all of them
/// at zero, and `gaps`, `blanks` and `feet` are how many times each occurs.
/// _lay measures those; this is the arithmetic.
///
/// Overflow is spent in a fixed order — writing areas first, because a blank
/// box tolerates it best, then the gaps between sections, then the signature
/// fields — and never past the floors. When even the floors do not fit, the
/// floors are what comes back and the sheet runs onto a second page. That is
/// the honest outcome; the alternative is a form too cramped to write on.
/// -> dictionary
#let _fit(
  base, available,
  gaps, blanks, feet,
  luft, luft-min,
  mindesthoehe, mindesthoehe-min,
  unterschrifthoehe, unterschrifthoehe-min,
) = {
  // em-relative lengths cannot be compared or divided before they are resolved
  let over = (
    base - available
      + gaps * luft.to-absolute()
      + blanks * mindesthoehe.to-absolute()
      + feet * unterschrifthoehe.to-absolute()
  )

  // It fits. Hand the amounts back exactly as they came in — resolving them to
  // absolute lengths here would nudge the rasterisation of a sheet that needed
  // no fitting at all.
  if over <= 0pt {
    return (luft: luft, mindesthoehe: mindesthoehe, unterschrifthoehe: unterschrifthoehe)
  }

  // Past this point the amounts are arithmetic, so resolve them once
  let luft = luft.to-absolute()
  let mindesthoehe = mindesthoehe.to-absolute()
  let unterschrifthoehe = unterschrifthoehe.to-absolute()

  // Shrink one slot towards its floor, returning the new amount and what is
  // left of the overflow.
  let spend(amount, floor, count, over) = {
    if count <= 0 or over <= 0pt { return (amount, over) }
    let room = calc.max(0pt, amount - floor.to-absolute()) * count
    let take = calc.min(room, over)
    (amount - take / count, over - take)
  }

  let (mindesthoehe, over) = spend(mindesthoehe, mindesthoehe-min, blanks, over)
  let (luft, over) = spend(luft, luft-min, gaps, over)
  let (unterschrifthoehe, over) = spend(unterschrifthoehe, unterschrifthoehe-min, feet, over)

  (luft: luft, mindesthoehe: mindesthoehe, unterschrifthoehe: unterschrifthoehe)
}

/// Render `sheet` at its natural elastic amounts, or at shrunken ones when it
/// would otherwise not fit.
///
/// `sheet` takes the three elastic amounts plus `spacer`, which the probes
/// switch off because a `1fr` has no meaning in the unbounded region a
/// measurement happens in. Setting one amount to a unit and measuring again
/// says how many times it occurs, so the counts come out of the layout itself
/// rather than from a second set of rules that could drift away from it: a
/// section added later is counted without touching any of this.
/// -> content
#let _lay(sheet, anpassen, luft, luft-min, mindesthoehe, mindesthoehe-min, unterschrifthoehe, unterschrifthoehe-min) = {
  if not anpassen {
    return sheet(luft: luft, mindesthoehe: mindesthoehe, unterschrifthoehe: unterschrifthoehe)
  }
  layout(size => {
    let probe(l, m, u) = measure(
      block(width: size.width, sheet(luft: l, mindesthoehe: m, unterschrifthoehe: u, spacer: false)),
    ).height

    let unit = 1cm
    let bare = probe(0pt, 0pt, 0pt)

    // How many times each elastic amount occurs, read off the layout itself
    let gaps = calc.round((probe(unit, 0pt, 0pt) - bare) / unit)
    let blanks = calc.round((probe(0pt, unit, 0pt) - bare) / unit)
    let feet = calc.round((probe(0pt, 0pt, unit) - bare) / unit)

    // A measurement carries the block spacing below its last element; a page
    // drops that spacing at the bottom margin. Left in, every sheet would
    // measure one spacing taller than it is and sheets that already fit would
    // be shrunk. Measure the spacing rather than assume it — appending an
    // empty, zero-height block adds exactly one — so the correction follows
    // the font size instead of hard-coding 1.2em of a 10pt body.
    let tail = measure(block(
      width: size.width,
      sheet(luft: 0pt, mindesthoehe: 0pt, unterschrifthoehe: 0pt, spacer: false)
        + block(height: 0pt, width: 100%, []),
    )).height - bare

    let fit = _fit(
      bare - tail, size.height,
      gaps, blanks, feet,
      luft, luft-min,
      mindesthoehe, mindesthoehe-min,
      unterschrifthoehe, unterschrifthoehe-min,
    )
    sheet(
      luft: fit.luft,
      mindesthoehe: fit.mindesthoehe,
      unterschrifthoehe: fit.unterschrifthoehe,
    )
  })
}

// -----------------------------------------------------------------------------
// Weekly report
// -----------------------------------------------------------------------------

/// Weekly training record sheet (Ausbildungsnachweis as Wochenbericht) for the
/// German apprenticeship system, laid out on a single page.
///
/// Sections size themselves to their content; an empty section keeps a
/// fixed-height writing area. Empty header fields are omitted entirely.
///
/// Callable either as a show rule or with trailing content blocks, which map
/// to `[Tätigkeitsbericht][Schulbericht][Bemerkungen]`. A non-empty block wins
/// over the corresponding named argument; an empty block `[]` falls back to it.
///
/// Content parameters accept a string, an array of strings (rendered as a
/// bullet list), or arbitrary content.
///
/// - name (str, content): Name of the apprentice (Auszubildender).
/// - ausbildungsjahr (str, content): Training year (Ausbildungsjahr), e.g. "1. Ausbildungsjahr".
/// - kalenderwoche (str, int): Calendar week number (Kalenderwoche).
/// - jahr (str, int): Year (Jahr).
/// - zeitraum (str, content, none): Period covered (Zeitraum), e.g. "07.09. – 11.09.2026".
/// - abteilung (str, content, none): Department or training area (Abteilung, on IHK
///   forms Ausbildungsbereich).
/// - beruf (str, content, none): Occupation being trained for (Ausbildungsberuf).
/// - fachrichtung (str, content, none): Specialisation (Fachrichtung/Schwerpunkt).
/// - betrieb (str, content, none): Training company (Ausbildungsbetrieb).
/// - ausbilder (str, content, none): Responsible trainer (Verantwortliche/r Ausbilder/in).
/// - heft-nr (str, int, none): Number of the sheet within the record book (Heft-Nr.).
/// - taetigkeiten (str, array, content): Activity report (Tätigkeitsbericht).
///   Also the 1st content block.
/// - unterweisungen (str, array, content, none): Formal instruction periods and
///   in-house lessons (Unterweisungen, betrieblicher Unterricht). Section appears
///   only when filled.
/// - schulbericht (str, array, content): Topics covered at vocational school
///   (Schulbericht, on IHK forms Themen des Berufsschulunterrichts). Also the
///   2nd content block.
/// - bemerkungen (str, array, content): Trainer's remarks (Bemerkungen des
///   Ausbilders). Leave empty to get a blank writing area. Also the 3rd content block.
/// - weiteres (str, array, content, none): Additional closing section (Weitere
///   Berichte). Appears only when filled.
/// - stunden (dictionary): Hours per section (Stunden), with the keys `betrieb`,
///   `unterweisung` and `schule`, e.g. `(betrieb: 28, schule: 8)`.
/// - titel (str, content, auto): Title line. `auto` builds it from week, year and name.
/// - bezeichnungen (dictionary): Overrides individual labels of
///   `standard-bezeichnungen`, e.g. `(schule: "Berufsschule")`.
/// - unterschriften (array): Labels of the signature fields (Unterschriften).
///   `()` omits them.
/// - kopfspalten (int): Header fields per row, 1 or 2. Two halves the header height.
/// - kopfspalte (length, auto): Width of the label column. `auto` is 5.4cm in
///   single-column mode, growing with long custom labels, and as narrow as the
///   labels allow in two-column mode.
/// - unterschrifthoehe (length): Height of the signature fields (Unterschriften).
/// - schrift (str, array): Font family or list of families to try in order.
/// - schriftgroesse (length): Base font size.
/// - titelgroesse (length): Font size of the title line.
/// - linie (color): Border colour.
/// - kopfgrau (color): Background of the header cells.
/// - kopftext (color): Text colour of the header cells.
/// - fliess (color): Body text colour.
/// - rahmen (length): Border thickness.
/// - luft (length): Vertical spacing between sections.
/// - polster (length): Cell padding.
/// - mindesthoehe (length): Height of empty sections, i.e. the writing area.
/// - rand (dictionary): Page margins, passed through to `page(margin: ..)`.
/// - anpassen (bool): Shrink the elastic heights — the writing areas, the gaps
///   between the sections, the signature fields — as far as the floors below
///   allow, so that a sheet that is slightly too tall still comes out on one
///   page. Nothing is shrunk while it already fits, and a sheet that does not
///   fit even at the floors is allowed onto a second page rather than being
///   squeezed into a form too cramped to write on. `false` uses every amount
///   exactly as given.
/// - luft-min (length): Smallest `luft` the fitting may use.
/// - mindesthoehe-min (length): Smallest `mindesthoehe` the fitting may use.
/// - unterschrifthoehe-min (length): Smallest `unterschrifthoehe` the fitting
///   may use.
/// -> content
#let nachweis(
  // header fields — empty ones do not appear
  name: "",
  ausbildungsjahr: "",
  kalenderwoche: "",
  jahr: "",
  zeitraum: none,
  abteilung: none,
  beruf: none,
  fachrichtung: none,
  betrieb: none,
  ausbilder: none,
  heft-nr: none,
  // sections: content, array of strings, or text.
  // taetigkeiten/schulbericht/bemerkungen can also be passed as content
  // blocks after the call, see README.
  taetigkeiten: "",
  unterweisungen: none,
  schulbericht: "",
  bemerkungen: "",
  weiteres: none,
  // hours per section, e.g. (betrieb: 28, schule: 8)
  stunden: (:),
  // labels and structure
  titel: auto,
  bezeichnungen: (:),
  unterschriften: standard-unterschriften,
  kopfspalten: 1,
  kopfspalte: auto,
  unterschrifthoehe: 2cm,
  // appearance
  schrift: ("Arial", "Helvetica", "Liberation Sans", "DejaVu Sans"),
  schriftgroesse: 10pt,
  titelgroesse: 14pt,
  linie: rgb("#b5b5b5"),
  kopfgrau: rgb("#ededed"),
  kopftext: rgb("#000000"),
  fliess: rgb("#1a1a1a"),
  rahmen: 0.5pt,
  luft: 1.27cm,
  polster: 11pt,
  mindesthoehe: 2cm,
  rand: (x: 2.2cm, top: 2cm, bottom: 1.8cm),
  // shrink-to-fit: the floors below are as small as the sheet may get before
  // a second page is preferred to an unusable form
  anpassen: true,
  luft-min: 0.8cm,
  mindesthoehe-min: 1.2cm,
  unterschrifthoehe-min: 1.4cm,
  // content blocks: [Tätigkeitsbericht][Schulbericht][Bemerkungen]
  ..inhalte,
) = {
  _check(inhalte)
  let blocks = inhalte.pos()
  let taetigkeiten = _block(blocks, 0, taetigkeiten)
  let schulbericht = _block(blocks, 1, schulbericht)
  let bemerkungen = _block(blocks, 2, bemerkungen)

  let labels = standard-bezeichnungen + bezeichnungen

  set page(paper: "a4", margin: rand)
  set text(font: schrift, size: schriftgroesse, fill: fliess, lang: "de")
  set par(leading: 0.65em)
  // Every gap in the sheet is an explicit v(luft). Left at its default, the
  // automatic spacing between blocks would add itself on top of each one — and
  // not on top of the gap above the signatures, where the 1fr swallows it — so
  // the gaps would come out unequal. Zero here makes luft mean the distance it
  // says it is, everywhere.
  set block(spacing: 0pt)

  // The sheet as a function of the elastic amounts, so that the probes taken
  // in _lay and the final render go through exactly the same code.
  let sheet(
    luft: luft,
    mindesthoehe: mindesthoehe,
    unterschrifthoehe: unterschrifthoehe,
    spacer: true,
  ) = {
    let (section, header-table, signatures, ..) = _parts(
      labels, linie, kopfgrau, kopftext, fliess, polster, rahmen, mindesthoehe,
    )

    let title = _title-line(titel, kalenderwoche, jahr, name)
    if not _empty(title) {
      text(size: titelgroesse, weight: "bold", fill: kopftext)[#title]
      v(luft)
    }

    header-table(
      _header-fields(
        labels, name, ausbildungsjahr, beruf, fachrichtung,
        betrieb, ausbilder, zeitraum, abteilung, heft-nr,
      ),
      label-width: kopfspalte,
      columns: kopfspalten,
    )

    v(luft)
    section(labels.taetigkeiten, taetigkeiten, hours: stunden.at("betrieb", default: none))

    if not _empty(unterweisungen) {
      v(luft)
      section(
        labels.unterweisungen, unterweisungen,
        hours: stunden.at("unterweisung", default: none),
      )
    }

    v(luft)
    section(labels.schule, schulbericht, hours: stunden.at("schule", default: none))

    v(luft)
    section(labels.bemerkungen, bemerkungen)

    if not _empty(weiteres) {
      v(luft)
      section(labels.weiteres, weiteres)
    }

    // The gap above the signatures is a luft like any other, so that fitting
    // shrinks it instead of letting it vanish: the 1fr alone collapses to zero
    // under pressure and glues the signature block to the section above it.
    v(luft)
    if spacer { v(1fr) }
    signatures(unterschriften, height: unterschrifthoehe)
  }

  _lay(
    sheet, anpassen,
    luft, luft-min,
    mindesthoehe, mindesthoehe-min,
    unterschrifthoehe, unterschrifthoehe-min,
  )
}

// -----------------------------------------------------------------------------
// Daily report
// -----------------------------------------------------------------------------

/// Daily training record sheet (Ausbildungsnachweis as Tagesbericht) with one
/// table row per date, laid out on a single page. The chambers recommend this
/// format for technical trades (gewerblich-technische Ausbildungsberufe).
///
/// Takes every parameter of @@nachweis() except `unterweisungen` and
/// `taetigkeiten`; the activities live in `tage` instead. Trailing content
/// blocks map to `[Schulbericht][Bemerkungen]`.
///
/// - tage (array): Days to list (Tage). Each entry is a dictionary with the keys
///   `datum` (date), `tag` (optional weekday), `inhalt` (the activities, str, array
///   or content) and `stunden` (int, optional). A column is dropped when no day
///   fills it.
/// - summe (bool): Show a total row (Gesamt) beneath the hours column (Stunden).
/// - spalten (dictionary): Column widths, with the keys `datum`, `tag` and `stunden`.
/// - vorspann (str, array, content, none): Optional text above the table (Vorspann).
/// - schulbericht (str, array, content): Topics covered at vocational school
///   (Schulbericht). Also the 1st content block.
/// - bemerkungen (str, array, content): Trainer's remarks (Bemerkungen). Also the
///   2nd content block.
/// - weiteres (str, array, content, none): Additional closing section (Weitere Berichte).
/// - stunden (dictionary): Hours for the school section (Stunden), e.g. `(schule: 8)`.
/// -> content
#let tagesbericht(
  // header fields
  name: "",
  ausbildungsjahr: "",
  kalenderwoche: "",
  jahr: "",
  zeitraum: none,
  abteilung: none,
  beruf: none,
  fachrichtung: none,
  betrieb: none,
  ausbilder: none,
  heft-nr: none,
  // days: array of (datum: .., tag: .., inhalt: .., stunden: ..)
  tage: (),
  summe: true,
  // further sections. schulbericht/bemerkungen can also be passed as content
  // blocks after the call, see README.
  vorspann: none,
  schulbericht: "",
  bemerkungen: "",
  weiteres: none,
  stunden: (:),
  // labels and structure
  titel: auto,
  bezeichnungen: (:),
  unterschriften: standard-unterschriften,
  kopfspalten: 1,
  kopfspalte: auto,
  unterschrifthoehe: 2cm,
  // appearance
  schrift: ("Arial", "Helvetica", "Liberation Sans", "DejaVu Sans"),
  schriftgroesse: 10pt,
  titelgroesse: 14pt,
  linie: rgb("#b5b5b5"),
  kopfgrau: rgb("#ededed"),
  kopftext: rgb("#000000"),
  fliess: rgb("#1a1a1a"),
  rahmen: 0.5pt,
  luft: 1.27cm,
  polster: 11pt,
  mindesthoehe: 2cm,
  spalten: (datum: 2.7cm, tag: 2.3cm, stunden: 1.5cm),
  rand: (x: 2.2cm, top: 2cm, bottom: 1.8cm),
  // shrink-to-fit, see nachweis
  anpassen: true,
  luft-min: 0.8cm,
  mindesthoehe-min: 1.2cm,
  unterschrifthoehe-min: 1.4cm,
  // content blocks: [Schulbericht][Bemerkungen]
  ..inhalte,
) = {
  _check(inhalte)
  let blocks = inhalte.pos()
  let schulbericht = _block(blocks, 0, schulbericht)
  let bemerkungen = _block(blocks, 1, bemerkungen)

  let labels = standard-bezeichnungen + bezeichnungen
  set page(paper: "a4", margin: rand)
  set text(font: schrift, size: schriftgroesse, fill: fliess, lang: "de")
  set par(leading: 0.65em)
  // Every gap in the sheet is an explicit v(luft). Left at its default, the
  // automatic spacing between blocks would add itself on top of each one — and
  // not on top of the gap above the signatures, where the 1fr swallows it — so
  // the gaps would come out unequal. Zero here makes luft mean the distance it
  // says it is, everywhere.
  set block(spacing: 0pt)

  // The sheet as a function of the elastic amounts, see nachweis
  let sheet(
    luft: luft,
    mindesthoehe: mindesthoehe,
    unterschrifthoehe: unterschrifthoehe,
    spacer: true,
  ) = {
    let (section, head-cell, header-table, signatures, as-content, stroke-style, ..) = _parts(
      labels, linie, kopfgrau, kopftext, fliess, polster, rahmen, mindesthoehe,
    )

    let title = _title-line(titel, kalenderwoche, jahr, name)
    if not _empty(title) {
      text(size: titelgroesse, weight: "bold", fill: kopftext)[#title]
      v(luft)
    }

    header-table(
      _header-fields(
        labels, name, ausbildungsjahr, beruf, fachrichtung,
        betrieb, ausbilder, zeitraum, abteilung, heft-nr,
      ),
      label-width: kopfspalte,
      columns: kopfspalten,
    )

    if not _empty(vorspann) {
      v(luft)
      as-content(vorspann)
    }

    // Only show a column when at least one day fills it
    let has-weekday = tage.any(d => d.at("tag", default: none) != none)
    let has-hours = tage.any(d => d.at("stunden", default: none) != none)

    let widths = (spalten.at("datum", default: 2.7cm),)
    if has-weekday { widths.push(spalten.at("tag", default: 2.3cm)) }
    widths.push(1fr)
    if has-hours { widths.push(spalten.at("stunden", default: 1.5cm)) }

    let header-cells = (head-cell(labels.datum),)
    if has-weekday { header-cells.push(head-cell(labels.tag)) }
    header-cells.push(head-cell(labels.taetigkeit))
    if has-hours { header-cells.push(head-cell(labels.stunden)) }

    let rows = ()
    for day in tage {
      rows.push([#day.at("datum", default: "")])
      if has-weekday { rows.push([#day.at("tag", default: "")]) }
      rows.push(as-content(day.at("inhalt", default: "")))
      if has-hours { rows.push(align(center)[#day.at("stunden", default: "")]) }
    }

    // Total row
    if summe and has-hours {
      let total = tage.fold(0, (sum, day) => sum + day.at("stunden", default: 0))
      let leading-cells = if has-weekday { 2 } else { 1 }
      rows += ((table.cell(fill: kopfgrau)[],) * leading-cells)
      rows.push(table.cell(fill: kopfgrau)[
        #text(weight: "bold", fill: kopftext)[#labels.summe]
      ])
      rows.push(table.cell(fill: kopfgrau)[
        #align(center)[#text(weight: "bold", fill: kopftext)[#total]]
      ])
    }

    v(luft)
    table(
      columns: widths,
      stroke: stroke-style,
      inset: (x: polster, y: 9pt),
      align: (x, y) => if y == 0 { left } else { left + top },
      ..header-cells,
      ..rows,
    )

    v(luft)
    section(labels.schule, schulbericht, hours: stunden.at("schule", default: none))

    v(luft)
    section(labels.bemerkungen, bemerkungen)

    if not _empty(weiteres) {
      v(luft)
      section(labels.weiteres, weiteres)
    }

    // The gap above the signatures is a luft like any other, so that fitting
    // shrinks it instead of letting it vanish: the 1fr alone collapses to zero
    // under pressure and glues the signature block to the section above it.
    v(luft)
    if spacer { v(1fr) }
    signatures(unterschriften, height: unterschrifthoehe)
  }

  _lay(
    sheet, anpassen,
    luft, luft-min,
    mindesthoehe, mindesthoehe-min,
    unterschrifthoehe, unterschrifthoehe-min,
  )
}

// -----------------------------------------------------------------------------
// Cover sheet
// -----------------------------------------------------------------------------

/// Cover sheet (Deckblatt) of the record book (Berichtsheft), laid out on a
/// single page.
///
/// Empty fields are omitted. A trailing content block becomes `zusatz`.
/// Labels and appearance parameters are shared with @@nachweis().
///
/// - heft-nr (str, int, none): Number of the record book (Heft-Nr.).
/// - name (str, content): Name of the apprentice (Auszubildender).
/// - geburtsdatum (str, content, none): Date of birth (Geburtsdatum).
/// - adresse (str, content, none): Address (Adresse).
/// - beruf (str, content, none): Occupation being trained for (Ausbildungsberuf).
/// - fachrichtung (str, content, none): Specialisation (Fachrichtung/Schwerpunkt).
/// - betrieb (str, content, none): Training company (Ausbildungsbetrieb).
/// - ausbilder (str, content, none): Responsible trainer (Verantwortliche/r Ausbilder/in).
/// - ausbildungsjahr (str, content, none): Training year (Ausbildungsjahr).
/// - beginn (str, content, none): Start of training (Beginn der Ausbildung).
/// - ende (str, content, none): End of training (Ende der Ausbildung).
/// - unterschriften (array): Labels of the signature fields (Unterschriften).
///   Empty means none.
/// - zusatz (str, array, content, none): Free addition below the table (Zusatz).
///   Also the content block.
/// -> content
#let deckblatt(
  heft-nr: none,
  name: "",
  adresse: none,
  geburtsdatum: none,
  beruf: none,
  fachrichtung: none,
  betrieb: none,
  ausbilder: none,
  ausbildungsjahr: none,
  beginn: none,
  ende: none,
  titel: auto,
  bezeichnungen: (:),
  unterschriften: (),
  zusatz: none,
  kopfspalten: 1,
  kopfspalte: auto,
  unterschrifthoehe: 2cm,
  schrift: ("Arial", "Helvetica", "Liberation Sans", "DejaVu Sans"),
  schriftgroesse: 11pt,
  titelgroesse: 22pt,
  linie: rgb("#b5b5b5"),
  kopfgrau: rgb("#ededed"),
  kopftext: rgb("#000000"),
  fliess: rgb("#1a1a1a"),
  rahmen: 0.5pt,
  luft: 1.27cm,
  polster: 11pt,
  rand: (x: 2.2cm, top: 3.5cm, bottom: 2cm),
  // shrink-to-fit, see nachweis. A cover sheet has no empty sections, so
  // mindesthoehe exists here only to keep the three functions alike.
  anpassen: true,
  mindesthoehe: 2cm,
  luft-min: 0.8cm,
  mindesthoehe-min: 1.2cm,
  unterschrifthoehe-min: 1.4cm,
  // content block: [free addition below the table]
  ..inhalte,
) = {
  _check(inhalte)
  let zusatz = _block(inhalte.pos(), 0, zusatz)

  let labels = standard-bezeichnungen + bezeichnungen
  set page(paper: "a4", margin: rand)
  set text(font: schrift, size: schriftgroesse, fill: fliess, lang: "de")
  set par(leading: 0.65em)
  // Every gap in the sheet is an explicit v(luft). Left at its default, the
  // automatic spacing between blocks would add itself on top of each one — and
  // not on top of the gap above the signatures, where the 1fr swallows it — so
  // the gaps would come out unequal. Zero here makes luft mean the distance it
  // says it is, everywhere.
  set block(spacing: 0pt)

  // The sheet as a function of the elastic amounts, see nachweis
  let sheet(
    luft: luft,
    mindesthoehe: mindesthoehe,
    unterschrifthoehe: unterschrifthoehe,
    spacer: true,
  ) = {
    let (header-table, signatures, as-content, ..) = _parts(
      labels, linie, kopfgrau, kopftext, fliess, polster, rahmen, mindesthoehe,
    )

    align(center)[
      #text(size: titelgroesse, weight: "bold", fill: kopftext)[
        #if titel == auto { labels.deckblatt-titel } else { titel }
      ]
    ]

    v(luft * 2)

    header-table(
      (
        (labels.heft, heft-nr),
        (labels.name, name),
        (labels.geburtsdatum, geburtsdatum),
        (labels.adresse, adresse),
        (labels.beruf, beruf),
        (labels.fachrichtung, fachrichtung),
        (labels.betrieb, betrieb),
        (labels.ausbilder, ausbilder),
        (labels.ausbildungsjahr, ausbildungsjahr),
        (labels.beginn, beginn),
        (labels.ende, ende),
      ),
      label-width: if kopfspalte == auto and kopfspalten == 1 { 6.4cm } else { kopfspalte },
      columns: kopfspalten,
    )

    if not _empty(zusatz) {
      v(luft)
      as-content(zusatz)
    }

    if unterschriften.len() > 0 {
      v(luft)
      if spacer { v(1fr) }
      signatures(unterschriften, height: unterschrifthoehe)
    }
  }

  _lay(
    sheet, anpassen,
    luft, luft-min,
    mindesthoehe, mindesthoehe-min,
    unterschrifthoehe, unterschrifthoehe-min,
  )
}
