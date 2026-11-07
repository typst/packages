// ╭─────────────────────────────────────────────────────────╮
// │   Norwegian letter / business document in accordance    │
// │                  with NS4129:1995 (A4)                  │
// ╰─────────────────────────────────────────────────────────╯
//
// Project page: 
// https://github.com/turbohanstad/typst-nor-letter
//
// Norsk Standard 4129 (1995) is the latest (!) and most official Norwegian document
// describing norms for business correspondence and other documents like minutes, memos
// or forms. It is primarily designed for professional internal or external communication,
// but can also be used for personal corresponcence with business or government entities.
//
// The norm allows for a complete set of standard metadata like document numbering for both
// parties, as well as a full set of details for the sender (addresses, company registry
// details, bank etc) without cluttering the first page.
//
// Metadata labels sit in a sidecar labels.toml file in Norwegian (bokmål + nynorsk)
// and English. These and inline labels can be customized in the template in order to,
// for example, create recognizable meeting minutes by setting "secretary"/"present"/"absent"
// where "case officer"/"recipient lead"/"copy" would go in a letter.
//
// The standard is flexible, but for business correspondence it is relatively strict
// when it comes to placing of metadata on lines and tab-positions as in this template.
//
// Address placement fits standard window envelopes with an A4 sheet folded in three.
//
// Certain optionals from the standard are included as switches (true/false) in the template:
// - Even margins: Body text set 21.27mm from both right and left edge
// - Double-sided: Leaves space for binding/hole-punching even if right margin is narrower,
//   and avoids text bleeding through the paper unevenly.
// - Fold marks
// - Justified or non-justified body text
// - Inset of bullet points to defined tab-positions
//
// Colors from lib.typ can be used in documents by importing "colors" and setting e.g.
// #text(fill: colors.red)[*WARNING*]
//
// See comments below for metadata fields and switches

// ╭─────────────────────────────────────────────────────────╮
// │            1. Geometric variables and colors            │
// ╰─────────────────────────────────────────────────────────╯

#let ghs = 4.233mm                  // grunnhøydesteg: 1/6", single line
#let gbs = 2.54mm                   // grunnbreddesteg: 1/10", horizontal space

#let L(n) = n * ghs                 // baseline of line n
#let T(n) = 21.27mm + n * 22.86mm   // tabulatorposisjon (T-posisjon) n
#let K(n) = 20mm + n * 22.86mm      // kolonnelinje (K-linje) n, 9/10" apart

#let kvartfet = 0.2mm               // standard line weight

#let colors = ( green: rgb("#009639"), brown: rgb("#B86125"), blue: rgb("#005EB8"), dark-grey: rgb("#717C7D"), black: black, red: rgb("#E4002B"), )

/// Coloured text from the palette
///   #colored("green")[Some text]
#let colored(name, body) = {
  assert(name in colors, message: "colored: unknown colour '" + name + "', expected one of "
    + colors.keys().map(k => "'" + k + "'").join(", "))
  text(fill: colors.at(name), body)
}

// ╭─────────────────────────────────────────────────────────╮
// │                 2. Placement helpers                    │
// ╰─────────────────────────────────────────────────────────╯

/// Place 'body' with baseline on line `l`, at tab `t`.
/// 'shift' moves body horizontally, for mirrored pages with uneven margins
#let at(t, l, body, shift: 0mm) = place(
  top + left,
  dx: T(t) + shift,
  dy: L(l),
  block(width: K(8) - T(t), {
    set text(top-edge: "baseline", bottom-edge: "baseline")
    set par(leading: ghs, spacing: ghs, justify: false)
  body
}),
)

/// Fully indented paragraph (comment, quote etc) at T(t), default T1
///   #indented[MERKNAD: ...]
///   #indented(t: 2)[_"The woods are lovely, dark, and deep_"]
#let indented(body, t: 1) = block(above: 2 * ghs, below: 2 * ghs,
  pad(left: T(t) - T(0), right: T(0), body))


// ╭─────────────────────────────────────────────────────────╮
// │                3. Letter (main) function                │
// ╰─────────────────────────────────────────────────────────╯

#let translations = toml("../labels.toml")

#let letter(
  // ── Override labels in labels.toml ──────────────────────────────────
  labels: (:),
  // ── Heading above body text ─────────────────────────────────────────
  subject: none,
  // ── Sender field (utgiverfelt) ──────────────────────────────────────
  // Use _either_ company or person
  company: none,        // (name: "", department: "", handler: "")
  person: (name: "H.E. Pennypacker"),         //  (name: "", address_title: "")
  logo: none,           // image file

  // ── Sender's full address details (page 1 footer) ───────────────────
  footer: (),                // Pairs of (label, content) or [*Label* \ line \ *Label* \ line]
  footer-tabs: (0, 2, 4, 6), // T-position of each column
  footer-leading: 3.175mm,   // Fits five lines in grid lines 65-68

  // ── Reference field (referansefelt) ─────────────────────────────────
  date: datetime.today().display("[year]-[month]-[day]"),
  revision: none,
  marking: none,        // e.g. "Fortrolig", "Utkast" – l 03, T4, bold
  doc-type: none,       // e.g. "Melding", "Notat" – l 04, T4
  doc-type-code: none,  // e.g. "F-2001" – l 04, T6
  our-ref: none,
  your-date: none,
  your-ref: none,

  // ── Recipient address field ─────────────────────────────────────────
  recipient-lead: none,     // e.g. [Rekommandert] – bold text above recipient
  recipient: [],            // max 6 lines including lead text
  secondary-address: none,  // right address field (label, content)
                            // e.g. ("Kopi til", [Industridepartementet / P.b. 15 DEP])

  // ── Typography ──────────────────────────────────────────────────────
  font: "Libertinus Serif",
  lead-font: ("Liberation Sans", "DejaVu Sans", "Arial"),
  size: 11pt,
  language: "nb",
  justify: true,

  // ── Layout options ──────────────────────────────────────────────────
  two-sided: false,         // mirror even pages (if even-margins = false)
  folding-marks: false,     // left margin ticks for folding for window envelope
  fold-at: (105mm, 210mm),
  list-indent: 1,           // T-position of bullet lists
  even-margins: false,      // false: wider left margin, true: also wide right
  rules: true,             // rules below header and above footer on p. 1
  rule-stroke: kvartfet,

  body,
) = {

  // ╭─────────────────────────────────────────────────────────╮
  // │    3.1 Set up for company (b2b) or person as sender     │
  // │                     and verify keys                     │
  // ╰─────────────────────────────────────────────────────────╯

  assert(
    (company == none) != (person == none),
    message: "Letter: Fill _either_ 'person' or 'company' (include handler to identify point of contact)",
  )
  let check-keys(dict, arg, allowed) = for key in dict.keys() {
    assert(key in allowed,
      message: "Letter: Unknown key '" + key + "' in '" + arg + "', expected one of "
        + allowed.map(k => "'" + k + "'").join(", "))
  }
  let is-company = company != none
  let sender-name = none
  let sender-department = none
  let handler = none
  if is-company {
    check-keys(company, "company", ("name", "department", "handler"))
    sender-name = company.at("name")
    sender-department = company.at("department", default: none)
    handler = company.at("handler", default: none)
  } else {
    check-keys(person, "person", ("name", "address_title"))
    sender-name = person.at("name")
    sender-department = person.at("address_title", default: none)
  }

  // ╭─────────────────────────────────────────────────────────╮
  // │                   3.2 Derived values                    │
  // ╰─────────────────────────────────────────────────────────╯

  /// Label translations from labels.toml
  let t = translations.at(
    translations.default) + translations.at(language, default: (:)) + labels
  for k in labels.keys() {
    assert(k in translations.at(translations.default),
      message: "letter: unknown label `" + k + "`")
    }
  /// Right margin standard (7mm) or 210mm-K(8) if even margins
  let rmargin = if even-margins { T(0) } else { 210mm - K(8) }
  /// Page numbering "n av max(n)", language-dependent
  let pageno = context t.page.replace(
    "{n}",
    str(counter(page).get().first())).replace("{total}",
    str(counter(page).final().first()))

  // ╭─────────────────────────────────────────────────────────╮
  // │                    3.3 Fixed fields                     │
  // ╰─────────────────────────────────────────────────────────╯

  /// Lead text format (e.g. "Vår referanse", "Your date")
  let lead(it) = text(font: lead-font, size: 6.5pt, it)

  /// Fields function to set up metadata fields, horizontal shifts,
  /// logo placement, folding marks, horizontal rules
  let fields = context {
    /// ── Establish horizontal shift and first page boolean ───────────────
    let first = here().page() == 1
    /// Set shift if two-sided, depending on odd/even page
    let shift = if two-sided and calc.even(here().page()) { rmargin - T(0) } else { 0mm }
    /// Update at function with horizontal shift
    let at = at.with(shift: shift)

    // ── Place logo left of company name (lines 3-6) ─────────────────────
    /// Horizontal shift = 0 if no logo
    let name-shift = 0mm
    if logo != none {
      let x = K(0)   // subtract up to 5 gbs (let x = K(0) - 5 gbs)
      /// define logo box size to fit area
      let logo-box = box(height: L(6) - 10mm, {
        set image(height: 100%)
        logo
      })
      place(top + left, dx: x + shift, dy: 10mm, logo-box)
      // move name and department right to fit logo
      name-shift = calc.max(0mm, x + measure(logo-box).width + 3mm - T(0))
    }

    // ── Company sender names ────────────────────────────────────────────
    if company != none {
      let at-name = at.with(shift: shift + name-shift)
      at-name(0, 4, text(size: 14pt, sender-name))
      if sender-department != none { at-name(0, 5, text(size: 9.5pt, sender-department)) }
      if first and handler != none {
        at(0, 7, lead(t.handler))
        at(0, 8, handler)
      }
    }

    // ── Person sender name ──────────────────────────────────────────────
    if person != none {
      let at-name = at.with(shift: shift + name-shift)
      at-name(0, 5, text(size: 14pt, sender-name))
      if sender-department != none {
        at-name(0, 6, text(size: 9.5pt, sender-department))
      }
    }

    // ── Sender reference and document type/marking fields ───────────────
    if marking != none { at(4, 3, strong(marking)) }
    if doc-type != none { at(4, 4, text(size: 13pt, weight: "bold", doc-type)) }
    if doc-type-code != none { at(6, 4, doc-type-code) }
    at(7, 4, pageno)
    if company != none { at(4, 5, lead(t.our-date)) }; at(4, 6, date)
    if revision != none { at(5, 5, lead(t.revision)) }; at(5, 6, revision)
    if our-ref != none { at(6, 5, lead(t.our-ref)); at(6, 6, our-ref) }

    // ── METADATA FOR FIRST PAGE ONLY ────────────────────────────────────
    // ── Recipient reference fields ──────────────────────────────────────
    if first {
      if your-date != none { at(4, 7, lead(t.your-date)); at(4, 8, your-date) }
      if your-ref != none { at(6, 7, lead(t.your-ref)); at(6, 8, your-ref) }

      // ── Recipient address fields ────────────────────────────────────────
      at(0, 10, { if recipient-lead != none { lead(recipient-lead) } })
      at(0, 11, { recipient })
      // ── Secondary (right) address field ─────────────────────────────────
      if secondary-address != none {
        let content = if type(secondary-address) == array {
          let (label, lines) = secondary-address
          lead(label) + linebreak() + lines
        } else { secondary-address }
        at(4, 10, content)
      }

      // ── Sender address / details for footer ─────────────────────────────
      for (col, tab) in footer.zip(footer-tabs) {
        if type(col) == array { col = [*#col.at(0)* \ #col.at(1)] }
        at(tab, 65, {
          set text(size: 7.5pt)
          set par(leading: footer-leading, spacing: footer-leading)
          show strong: it => text(font: lead-font, size: 6.5pt, weight: "bold", it.body)
          col
        })
      }
    }

    // ── Folding marks and horizontal rules ──────────────────────────────
    if first and folding-marks {
      for y in fold-at {
        place(top + left, dx: 5mm, dy: y, line(length: 2.5mm, stroke: 0.2pt + black))
      }
    }

    let hrule(y) = place(top + left, dx: 20mm + shift, dy: y,
      line(length: K(8) - 20mm, stroke: rule-stroke))

    if rules {
      hrule(if first { L(8) + 1.8mm } else { L(6) + 1.8mm })
      if first { hrule(L(64) + 2mm) }
    }
  }

  // ╭─────────────────────────────────────────────────────────╮
  // │                     3.4 Page setup                      │
  // ╰─────────────────────────────────────────────────────────╯

  set document(title: subject)
  set page(
    paper: "a4",
    margin: if two-sided {
      (inside: T(0), outside: rmargin, top: L(9), bottom: 297mm - L(63))
    } else {
      (left: T(0), right: rmargin, top: L(9), bottom: 297mm - L(63))
    },
    background: fields,
  )

  // ╭─────────────────────────────────────────────────────────╮
  // │                  3.5 Body text styling                  │
  // ╰─────────────────────────────────────────────────────────╯

  // Body text is set with top-edge and bottom-edge on baseline
  // in order to fit on a standard line position of n * ghs
  set text(
    font: font,
    size: size,
    lang: language,
    top-edge: "baseline",
    bottom-edge: "baseline")
  set par(
    justify: justify,
    linebreaks: "optimized",
    leading: ghs,
    spacing: 2 * ghs,        // empty line between paragraphs
    justification-limits: (
      spacing: (min: 80%, max: 140%),
      tracking: (min: -0.012em, max: 0.012em),
    ),
  )

  // ── Headings: body size, bold ───────────────────────────────────────
  show heading: it => block(
    above: 2 * ghs, below: 1 * ghs, text(size: size, strong(it.body))
  )

  // ╭─────────────────────────────────────────────────────────╮
  // │             3.5.1 List markers and indents              │
  // ╰─────────────────────────────────────────────────────────╯

  // List marker is en dash. Lists are indented at T(list-indent), standard
  // is T1. Empty space before top-level list, nested lists follow below
  // without vertical spacing.
  set list(marker: [--], indent: T(list-indent) - T(0), body-indent: 0.8em)
  let list-depth = state("list-depth", 0)
  show list: it => {
    list-depth.update(d => d + 1)
    context if list-depth.get() == 1 { parbreak() }
    it
    list-depth.update(d => d - 1)
  }

  // ╭─────────────────────────────────────────────────────────╮
  // │                   3.6 Letter content                    │
  // ╰─────────────────────────────────────────────────────────╯

  // ── Message field starts on line 18 of first page ───────────────────
  v(L(18) - L(9))
  if subject != none { block(below: 2 * ghs, strong(subject)) }

  body
}

// ╭─────────────────────────────────────────────────────────╮
// │                  4. Signature function                  │
// ╰─────────────────────────────────────────────────────────╯

/// Array of one of two signers four ghs below body, leaving room for handwritten
/// signatures. By convention responsible manager left, case officer (handler) right.
///   #signature[Kel Varnsen]
///   #signature[H.E. Pennypacker \ Industrialist etc][Darren \ NYU intern]
#let signature(first, ..second) = block(above: 4 * ghs, breakable: false,
  grid(columns: (T(4) - T(0), 1fr), first, ..second))
