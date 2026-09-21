// Europass CV Template for Typst — lib.typ
// Faithful reproduction of the official EU Europass CV (europa.eu/europass).
// Asymmetric 25%/75% grid, EU blue #164194, CEFR language grid, GDPR clause.
// 24-language i18n.  Version 1.0.0 — MIT License.

// ── Colours (Official EU Europass palette) ──────────────────────────────────
#let eu-blue = rgb("#164194")
#let eu-gray = rgb("#575756")
#let eu-light-gray = rgb("#F2F2F2")
#let eu-white = rgb("#FFFFFF")
#let eu-black = rgb("#000000")

// ── Typography ──────────────────────────────────────────────────────────────
// The whole family is vendored in ./fonts so builds are reproducible on any
// machine and never fall back to a locally installed substitute.  Verified:
// Open Sans alone covers all 24 official EU languages (Latin Extended-A/B,
// Greek, Cyrillic) plus Turkish and Vietnamese, so no fallback family is
// needed — and listing only vendored families keeps the build warning-free
// under `--ignore-system-fonts`.
#let body-font = ("Open Sans",)
#let body-size = 10pt
#let name-size = 18pt
#let section-size = 11pt
#let title-size = 10.5pt
#let small-size = 8.5pt

// ── Layout ──────────────────────────────────────────────────────────────────
#let page-margin = (top: 1.8cm, bottom: 1.5cm, left: 1.8cm, right: 1.8cm)
#let col-date = 1fr   // ~25%
#let col-content = 3fr   // ~75%
#let cell-inset = (x: 8pt, y: 5pt)
#let section-gap = 8pt

// ============================================================================
//  i18n  —  24 Official EU Languages (ISO 639-1 codes)
// ============================================================================
// If a language is missing, English is used as a fallback.
// All keys use full names — no language-code collisions.
// ============================================================================

#let i18n = toml("lang.toml")

// ============================================================================
//  LANGUAGE RESOLVER
// ============================================================================
// Returns the label dictionary for `lang`; falls back to English when the
// language code is unknown.
#let l(lang) = if lang in i18n { i18n.at(lang) } else { i18n.at("en") }

// ============================================================================
//  GENDER RESOLVER  (EU-inclusive, localisable, omittable)
// ============================================================================
// `gender` accepts:
//   * none / ""            -> the row is omitted entirely (recommended: many
//                             EU employers and GDPR guidance advise collecting
//                             no gender at all);
//   * a semantic key       -> "male", "female", "other" (non-binary / intersex /
//                             the "X" or German "divers" option), "undeclared"
//                             (a.k.a. "prefer-not-to-say"), rendered as the
//                             localised label for the active language;
//   * any other string     -> passed through verbatim, so a person can state
//                             their identity in their own words.
#let gender-label(lang, value) = {
  if value == none or value == "" {
    none
  } else {
    let t = l(lang)
    let keys = (
      "male": "gender-male",
      "female": "gender-female",
      "other": "gender-other",
      "non-binary": "gender-other",
      "undeclared": "gender-undeclared",
      "prefer-not-to-say": "gender-undeclared",
    )
    let v = str(value)
    if v in keys { t.at(keys.at(v)) } else { value }
  }
}

// ============================================================================
//  ACCESSIBLE CEFR COLOUR RAMP
// ============================================================================
// Six shades ordered A1 -> C2.  The ink colour flips to white from C1 upward so
// that *every* cell keeps a WCAG AA contrast ratio (>= 4.5:1) against its fill.
// This matters for PDF/UA: the level is always announced as real text.
#let cefr-shades = (
  rgb("#EEF2F9"),
  rgb("#DCE5F3"),
  rgb("#C2D1EA"),
  rgb("#9DB3DC"),
  rgb("#4A72BC"),
  rgb("#164194"),
)
#let cefr-ink = (
  rgb("#1A1A1A"),
  rgb("#1A1A1A"),
  rgb("#1A1A1A"),
  rgb("#1A1A1A"),
  eu-white,
  eu-white,
)

// Normalise a CEFR code to upper case.  Typst has no `str.upper()`, so the
// single leading letter is mapped explicitly ("b1" -> "B1").
#let cefr-norm(code) = {
  let s = str(code)
  let out = s
  for pair in (("a", "A"), ("b", "B"), ("c", "C")) {
    if s.starts-with(pair.at(0)) { out = pair.at(1) + s.slice(1) }
  }
  out
}

// Map a CEFR code to its 0-based rank.  Unknown/empty codes yield none.
// Note: `array.position` takes a *predicate*, not a value.
#let cefr-rank(code, levels) = {
  if code == none or code == "" { none } else {
    let n = cefr-norm(code)
    levels.position(x => x == n)
  }
}

// ============================================================================
//  SEMANTIC HEADINGS  (a11y: real H1/H2/H3 tags + PDF outline bookmarks)
// ============================================================================
// PDF/UA-1 rejects documents without a document outline, so every section title
// is a genuine `heading` element rather than merely styled text.  The visual
// Europass look is restored with show rules inside `europass-cv`.
#let section-header(lang, key) = heading(level: 2, l(lang).at(key))
#let sub-header(body) = heading(level: 3, outlined: false, body)

// ============================================================================
//  DATE HELPER
// ============================================================================
// Joins a start/end pair into the Europass "From – Until" string.
#let date-str(start, end) = {
  let s = if start == none { "" } else { str(start) }
  let e = if end == none { "" } else { str(end) }
  if s == "" { e } else if e == "" { s } else { s + " – " + e }
}

// ============================================================================
//  PUBLIC API — semantic helpers
// ============================================================================
// These are the only functions an end user needs.  They return grid cells, so
// the caller never has to touch the column geometry.
// ============================================================================

// ── cv-entry ────────────────────────────────────────────────────────────────
// One row of the Work Experience / Education grid.
//
//   #cv-entry(
//     date-start: "Jan 2021", date-end: "Present",
//     title: "Senior Developer", organization: "Acme SpA", location: "Milan",
//     description: [ - led a team of six … ],
//   )
//
// `title` becomes an H3, so assistive technology can jump straight to a job.
#let cv-entry(
  date-start: "",
  date-end: "",
  title: "",
  organization: "",
  location: "",
  description: none,
) = {
  // Build the "Organisation, Location" line from whichever parts are present.
  let where = (
    if organization != "" { organization } else { none },
    if location != "" { location } else { none },
  )
    .filter(x => x != none)
    .join(", ")

  (
    grid.cell(align: top + left, inset: cell-inset)[
      #text(fill: eu-gray, size: small-size, weight: "bold")[
        #date-str(date-start, date-end)
      ]
    ],
    grid.cell(align: top + left, inset: cell-inset)[
      #if title != "" { sub-header(title) }
      #if where != "" {
        text(fill: eu-gray, size: body-size, style: "italic")[#where]
        v(2pt)
      }
      #if description != none {
        text(fill: eu-gray, size: body-size)[#description]
      }
    ],
  )
}

// ── language-grid ───────────────────────────────────────────────────────────
// The official CEFR self-assessment table.
//
//   #language-grid(
//     mother-tongue: "Italian",
//     others: (
//       (lang: "English", listening: "C1", reading: "C1",
//        interaction: "B2", production: "B2", writing: "C1"),
//     ),
//   )
//
// a11y: this is a real `table` with `table.header()` (tagged Table/THead/TH/
// TBody/TD) plus a caption that names the table, and every level is emitted as
// text — never as a colour-only bar.
#let language-grid(mother-tongue: "", others: (), lang: "en") = {
  let t = l(lang)
  let levels = t.at("levels")

  // Skill columns, in official Europass order.
  let skills = (
    (key: "listening", group: "understanding"),
    (key: "reading", group: "understanding"),
    (key: "interaction", group: "speaking"),
    (key: "production", group: "speaking"),
    (key: "writing", group: "writing"),
  )

  block(width: 100%)[
    // Optional mother-tongue line above the grid (as in the official layout).
    #if mother-tongue != "" {
      text(fill: eu-gray, size: body-size)[
        #text(weight: "bold")[#t.at("mother-tongue"): ]#mother-tongue
      ]
      v(5pt)
    }

    // CEFR legend, rendered *before* the data so a screen reader meets the
    // scale explanation first.  (`table.caption` does not exist in Typst 0.15 —
    // captions belong to `figure` — and a numbered figure caption would be
    // clutter here, since the left-column "Other language(s)" label already
    // names this table in reading order.)
    #text(fill: eu-gray, size: 7.5pt)[
      #t.at("self-assessment") · #levels.at(0)/#levels.at(1) = #t.at("basic-user") ·
      #levels.at(2)/#levels.at(3) = #t.at("independent-user") ·
      #levels.at(4)/#levels.at(5) = #t.at("proficient-user")
    ]
    #v(4pt)

    #table(
      columns: (1.15fr,) + (1fr,) * 5,
      align: center + horizon,
      inset: (x: 3pt, y: 3pt),
      stroke: 0.4pt + eu-white,
      fill: eu-light-gray,

      // Two-row header: Understanding spans 2, Speaking spans 2, Writing 1.
      table.header(
        table.cell(rowspan: 2, align: left + horizon, inset: (x: 4pt, y: 3pt))[
          #text(fill: eu-blue, weight: "bold", size: small-size)[#t.at(
            "other-lang",
          )]
        ],
        table.cell(colspan: 2)[
          #text(fill: eu-blue, weight: "bold", size: small-size)[#t.at(
            "understanding",
          )]
        ],
        table.cell(colspan: 2)[
          #text(fill: eu-blue, weight: "bold", size: small-size)[#t.at(
            "speaking",
          )]
        ],
        table.cell(rowspan: 2)[
          #text(fill: eu-blue, weight: "bold", size: small-size)[#t.at(
            "writing",
          )]
        ],
        text(fill: eu-gray, size: 7.5pt)[#t.at("listening")],
        text(fill: eu-gray, size: 7.5pt)[#t.at("reading")],
        text(fill: eu-gray, size: 7.5pt)[#t.at("spoken-interact")],
        text(fill: eu-gray, size: 7.5pt)[#t.at("spoken-prod")],
      ),

      // One body row per language.  Built functionally — Typst forbids mutating
      // a captured array inside a closure, and `flatten` takes no mapper.  Each
      // language maps to its 6 cells, then the result is flattened one level.
      ..others
        .map(o => (
          table.cell(align: left + horizon, inset: (x: 4pt, y: 3pt))[
            #text(fill: rgb("#1F1F1F"), weight: "bold", size: body-size)[#o.at(
              "lang",
            )]
          ],
          ..skills.map(s => {
            let code = o.at(s.key, default: "")
            let rank = cefr-rank(code, levels)
            table.cell(
              fill: if rank != none { cefr-shades.at(rank) } else { eu-white },
              stroke: 0.4pt + eu-white,
            )[
              #text(
                fill: if rank != none { cefr-ink.at(rank) } else { eu-gray },
                weight: "bold",
                size: small-size,
              )[#code]
            ]
          }),
        ))
        .flatten(),
    )
  ]
}

// ── skill-row ───────────────────────────────────────────────────────────────
// A label/value pair inside the Personal Skills grid.  Always returns two cells
// (never `none`), so callers can push it unconditionally.
#let skill-row(lang, label-key, value) = (
  grid.cell(align: top + left, inset: cell-inset)[
    #text(fill: eu-gray, weight: "bold", size: small-size)[#l(lang).at(
      label-key,
    )]
  ],
  grid.cell(align: top + left, inset: cell-inset)[
    #text(fill: eu-gray, size: body-size)[#value]
  ],
)

// ============================================================================
//  MAIN TEMPLATE — europass-cv()
// ============================================================================
// The single entry point for end users.  Every parameter has a default, so a
// caller only supplies what they need.
// ============================================================================

#let europass-cv(
  // ── Language & PDF/UA metadata ────────────────────────────────────────────
  lang: "en",
  title: "", // PDF document title (a11y); defaults to `name`
  author: "", // PDF author      (a11y); defaults to `name`

  // ── Personal information ──────────────────────────────────────────────────
  name: "",
  photo: none, // e.g. "photo.jpg"; none omits it
  photo-alt: "Portrait photograph", // required for PDF/UA-1
  address: "",
  postal-code: "",
  city: "",
  country: "",
  phone: "",
  email: "",
  website: "",
  nationality: "",
  date-of-birth: "",
  // Gender is optional and inclusive.  Use none/"" to omit the row entirely,
  // a semantic key ("male", "female", "other", "undeclared") for a localised
  // label, or any free string to state it in your own words.
  gender: none,

  // ── Sections ──────────────────────────────────────────────────────────────
  work-experience: (), // array of cv-entry(..) results
  education: (), // array of cv-entry(..) results

  // ── Personal skills ───────────────────────────────────────────────────────
  mother-tongue: "",
  other-languages: (), // array passed to language-grid(others:)
  digital-skills: none,
  comm-skills: none,
  org-skills: none,
  job-skills: none,
  other-skills: none,
  driving-licence: none,

  // ── GDPR self-declaration ─────────────────────────────────────────────────
  declaration: true, // set false to omit the legal clause
  signature-place: "",
  signature-date: "",

  // ── Optional extra content ────────────────────────────────────────────────
  // MUST stay a required *positional* parameter with no default: that is what
  // makes `#show: europass-cv.with(..)` work (Typst passes the document body
  // positionally, and a default value would make it named-only and fail).
  // Anything written below the show rule in main.typ lands here.
  body,
) = {
  let t = l(lang)

  // ── a11y: document metadata (PDF/UA-1 requires a non-empty title) ─────────
  set document(
    title: if title != "" { title } else { name },
    author: if author != "" { author } else { name },
  )

  // ── a11y: `lang` tags the whole document so screen readers pick the right
  //          pronunciation rules; PDF/UA-1 fails without it. ─────────────────
  set page(paper: "a4", margin: page-margin)
  set text(font: body-font, size: body-size, fill: eu-gray, lang: lang)
  set par(leading: 0.62em, justify: false, spacing: 0.45em)
  set list(marker: text(fill: eu-blue)[–])

  // ── Restore the Europass look on top of semantic headings ─────────────────
  show heading.where(level: 1): it => {
    set text(fill: eu-blue, weight: "bold", size: name-size)
    block(width: 100%, below: 2pt, it)
  }
  show heading.where(level: 2): it => {
    set text(fill: eu-blue, weight: "bold", size: section-size)
    block(width: 100%, below: 6pt)[
      #it
      #v(1pt)
      #line(length: 100%, stroke: 0.6pt + eu-blue)
    ]
  }
  show heading.where(level: 3): it => {
    set text(fill: rgb("#1F1F1F"), weight: "bold", size: title-size)
    // Extra breathing room between an entry title (e.g. "Senior Software
    // Engineer") and the organisation/location line that follows it.
    block(width: 100%, below: 5pt, it)
  }

  // ── Name + optional photo (top masthead) ──────────────────────────────────
  // The H1 guarantees a document outline exists, which PDF/UA-1 demands.
  {
    let has-photo = photo != none
    grid(
      columns: if has-photo { (1fr, auto) } else { (1fr,) },
      column-gutter: 12pt,
      align: (left, right),
      // Always emit an H1: fall back to the PDF title when `name` is empty.
      heading(level: 1, if name != "" { name } else if title != "" {
        title
      } else { "Curriculum Vitae" }),
      if has-photo {
        image(photo, width: 30mm, height: 38mm, fit: "cover", alt: photo-alt)
      },
    )
  }
  v(6pt)

  // ── Build the two-column grid ─────────────────────────────────────────────
  // `grid` (not `table`) is deliberate: the date/content split is presentational,
  // so it is tagged as layout Divs and screen readers never announce a bogus
  // data table.  Verified: `grid` still breaks correctly across pages.
  //
  // Typst forbids mutating a captured array inside a closure, so every helper
  // below *returns* cells and the final array is assembled by spreading.

  // Section heading row.  The left cell stays empty so the vertical rule runs
  // unbroken from the top of the page to the bottom.
  let section-cells(key) = (
    grid.cell(align: top + left, inset: cell-inset)[],
    grid.cell(align: top + left, inset: cell-inset)[#section-header(lang, key)],
  )

  // Label (left) / value (right) row; collapses to nothing when empty.
  let kv-cells(label, value) = if (
    label != "" and value != none and value != ""
  ) {
    (
      grid.cell(align: top + left, inset: cell-inset)[
        #text(fill: eu-gray, weight: "bold", size: small-size)[#label]
      ],
      grid.cell(align: top + left, inset: cell-inset)[
        #text(fill: eu-gray, size: body-size)[#value]
      ],
    )
  } else { () }

  // A heading followed by its cv-entry rows; empty when there are no entries.
  let dated-cells(key, entries) = if entries.len() > 0 {
    (..section-cells(key), ..entries.flatten())
  } else { () }

  // ── Personal information values ───────────────────────────────────────────
  // Contact details become real links so they are announced as actionable.
  let addr = (
    if address != "" { address } else { none },
    if postal-code != "" { postal-code } else { none },
    if city != "" { city } else { none },
    if country != "" { country } else { none },
  )
    .filter(x => x != none)
    .join(", ")

  let email-cell = if email != "" { link("mailto:" + email, email) } else { "" }
  let web-cell = if website != "" {
    link(
      if website.starts-with("http") { website } else { "https://" + website },
      website,
    )
  } else { "" }

  // ── Personal skills cells ─────────────────────────────────────────────────
  let skill-items = (
    (key: "digital-skills", value: digital-skills),
    (key: "comm-skills", value: comm-skills),
    (key: "org-skills", value: org-skills),
    (key: "job-skills", value: job-skills),
    (key: "other-skills", value: other-skills),
    (key: "driving-licence", value: driving-licence),
  ).filter(item => item.value != none and item.value != "")

  let lang-cells = if other-languages.len() > 0 {
    (
      grid.cell(align: top + left, inset: cell-inset)[
        #text(fill: eu-gray, weight: "bold", size: small-size)[#t.at(
          "other-lang",
        )]
      ],
      grid.cell(align: top + left, inset: cell-inset)[
        #language-grid(others: other-languages, lang: lang)
      ],
    )
  } else { () }

  let skills-cells = if (
    mother-tongue != "" or lang-cells.len() > 0 or skill-items.len() > 0
  ) {
    (
      ..section-cells("personal-skills"),
      ..kv-cells(t.at("mother-tongue"), mother-tongue),
      ..lang-cells,
      ..skill-items
        .map(item => skill-row(lang, item.key, item.value))
        .flatten(),
    )
  } else { () }

  // ── Assemble every row in reading order ───────────────────────────────────
  let rows = (
    ..section-cells("personal-info"),
    ..kv-cells(t.at("address"), addr),
    ..kv-cells(t.at("phone"), phone),
    ..kv-cells(t.at("email"), email-cell),
    ..kv-cells("Web", web-cell),
    ..kv-cells(t.at("nationality"), nationality),
    ..kv-cells(t.at("date-of-birth"), date-of-birth),
    ..kv-cells(t.at("gender"), gender-label(lang, gender)),
    ..dated-cells("work-exp", work-experience),
    ..dated-cells("education", education),
    ..skills-cells,
  )

  // ── Render the grid; x==1 draws the iconic vertical blue rule ─────────────
  grid(
    columns: (col-date, col-content),
    stroke: (x, y) => if x == 1 { (left: 0.6pt + eu-blue) } else { none },
    ..rows,
  )

  // ── Optional user-supplied content (rendered inside the same rules) ───────
  if body != [] {
    v(10pt)
    body
  }

  // ── GDPR / DPR 445 self-declaration ───────────────────────────────────────
  if declaration {
    v(14pt)
    line(length: 100%, stroke: 0.6pt + eu-blue)
    v(5pt)
    text(fill: eu-gray, size: small-size)[#t.at("declaration")]

    if signature-place != "" or signature-date != "" {
      v(10pt)
      grid(
        columns: (1fr, 1fr),
        column-gutter: 12pt,
        text(fill: eu-gray, size: small-size)[
          #if signature-place != "" [#t.at("place"): #signature-place]
        ],
        text(fill: eu-gray, size: small-size)[
          #if signature-date != "" [#t.at("date"): #signature-date]
        ],
      )
      v(16pt)
      block(width: 55mm)[
        #line(length: 100%, stroke: 0.5pt + eu-gray)
        #v(2pt)
        #text(fill: eu-gray, size: small-size)[#t.at("signature")]
      ]
    }
  }
}
