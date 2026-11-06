#import "components.typ": absender_block, digitaler_absender_block, empfaenger_block, digitaler_empfaenger_block, geschaeftszeile_block, digitales_datum_block, signatur_block
#import "../input.typ": normalize-record, select-alias, validate-postal-record
#import "../defaults.typ": defaults as shared-defaults, merge
#import "../appearance.typ": resolve-postal-appearance
#import "layout.typ": falz_und_locher_marken, seiten_footer

/// A DIN 5008-style letter with optional postal and digital components.
///
/// English names are the canonical interface. The postal layout is the default;
/// for a screen-only PDF, combine `digital-sender`, `address-window: false`, and
/// `fold-marks: false`.
///
/// ```example
/// #show: letter.with(
///   sender: (name: "Alex Example", street: "Example Street 1", postal-code-city: "12345 Example City"),
///   recipient: (name: "Research Office", street: "Sample Road 2", postal-code-city: "54321 Sample City"),
///   date: "2026-10-27",
///   subject: "Appointment request",
///   language: "en",
/// )
/// Dear Research Office,
///
/// Could we arrange an appointment?
/// ```
///
/// - sender (dictionary): your details
///   - name (str): your name or company
///   - care-of (str, none): extra line such as c/o
///   - street (str): street and number
///   - postal-code-city (str): postal code and city
///   - phone (str): phone number; optional
///   - email (str): email address; optional
///   - website (str): website without `https://`; optional, digital sender only
///   - logo (none, content): logo content such as `image("logo.pdf", width: 3cm)`
/// - recipient (dictionary): who receives the letter; accepts `name`, `care-of`,
///   `street`, `postal-code-city`, and the optional `country`
/// - date (str, none): date text. Omitting it uses the compilation date formatted
///   as `YYYY-MM-DD`; set an explicit date for reproducible correspondence.
///   `none` does not hide the date—use `show-date: false` for that.
/// - show-date-label (bool): show the `Date`/`Datum` label above the date;
///   defaults to true
/// - subject (str): subject line; defaults to an empty line
/// - reference-line (array): one `(label, value)` pair or an array of pairs,
///   such as `(("Label", "Value"), ("Other", "Value"))`
/// - enclosure-list (array): enclosure names to print without embedding files
/// - attachments (array): PDF path strings to embed after the letter
/// - postal-mark (str): postal note such as "Registered mail"
/// - signature-addition (str): title or department below the signer name
/// - language (str): `"de"` (default) or `"en"`; controls labels and Typst language
/// - theme (str, none): `neutral` (default), `slate`, `soft-jade`, `soft-slate`,
///   `warm-editorial`, `plum`, or `soft-rose`
/// - config (dictionary): appearance overrides for `page.paper`, `page.margin`,
///   `typography.font`, `size`, `leading`, `justify`, and `hyphenate`;
///   `colors.bg-paper`, `brand-primary`, and `text-main`; and `links.color` and
///   `url-color`. Unknown groups or keys are rejected. For example:
///   `config: (typography: (font: "STIX Two Text", size: 10pt), page: (paper: "a4"))`.
///   Defaults are A4, Inter 11pt, 0.65em leading, justified text, and the
///   neutral letter palette; the `config` argument accepts only the keys above.
/// - font (str): body font family; defaults to `"Inter"`
/// - signature (bool): include the signing rule and sender name; defaults to true
/// - fold-marks (bool): include two fold marks and one punch mark; defaults to true
/// - address-window (bool): use the window-envelope recipient field; defaults to true
/// - page-numbers (bool): show continuation-page numbers; defaults to true
/// - digital-sender (bool): use the compact digital sender header; defaults to false
/// - date-right (bool): use the standalone right-aligned date when no reference
///   fields exist; defaults to true
/// - justify (bool): justify body paragraphs; defaults to true
/// - show-sender (bool), show-recipient (bool), show-date (bool),
///   show-subject (bool): include those blocks; all default to true. Hiding the
///   date does not hide separately supplied reference-line fields.
/// - paper (str, dictionary): page size; defaults to `"a4"`. A dictionary with
///   `width` and `height` supplies a custom page size.
/// - margins (dictionary): page margins; partial overrides are allowed
/// - font-size (length): body text size; defaults to `11pt`
/// - line-spacing (length): body leading and the basis for default block gaps;
///   defaults to `0.65em`
/// - block-spacing (dictionary): overrides for `sender-recipient`,
///   `sender-date`, `sender-subject`, `sender-body`, `recipient-date`,
///   `recipient-subject`, `recipient-body`, `date-subject`, `subject-body`,
///   `date-body`, and `signature` gaps, including the matching gaps used when
///   earlier blocks are hidden
/// - subject-size (length): subject text size; defaults to `11.5pt`
/// - digital-sender-height (length): reserved digital header height; defaults to `19mm`
/// - body (content): the letter text, including salutation and closing
///
/// German compatibility aliases remain available: `absender`, `empfaenger`,
/// `datum`, `geschaeftszeile`, `betreff`, `anlagenverzeichnis`, `anlagen`,
/// `signatur_zusatz`, `postvermerk`, `lang`, `signatur`, `falzmarken`,
/// `adressfenster`, `seitenzahlen`, `digitaler_absender`, `datum_rechts`,
/// `datum_label_anzeigen`,
/// `blocksatz`, `absender_anzeigen`, `empfaenger_anzeigen`, `datum_anzeigen`,
/// `betreff_anzeigen`, `papier`, `seitenraender`, `schriftgroesse`,
/// `zeilenabstand`, `abstaende`, `betreff_groesse`, and
/// `digitaler_absender_hoehe`. German nested address fields are `zusatz`,
/// `strasse`, `plz_ort`, `telefon`, and `land`. Supplying both spellings of the
/// same value produces a field-specific conflict error.
#let brief(
  absender: none,
  empfaenger: none,
  datum: none,
  geschaeftszeile: none,
  betreff: none,
  anlagenverzeichnis: none,
  anlagen: none,
  signatur_zusatz: none,
  signatur: none,
  postvermerk: none,
  lang: none,
  sender: none,
  recipient: none,
  date: none,
  show-date-label: none,
  reference-line: none,
  subject: none,
  enclosure-list: none,
  attachments: none,
  signature-addition: none,
  postal-mark: none,
  language: none,
  signature: none,
  fold-marks: none,
  address-window: none,
  page-numbers: none,
  digital-sender: none,
  date-right: none,
  justify: none,
  show-sender: none,
  show-recipient: none,
  show-date: none,
  show-subject: none,
  paper: none,
  margins: none,
  font-size: none,
  line-spacing: none,
  block-spacing: none,
  subject-size: none,
  digital-sender-height: none,
  theme: "neutral",
  config: (:),
  font: "Inter",
  falzmarken: none,
  adressfenster: none,
  seitenzahlen: none,
  digitaler_absender: none,
  datum_rechts: none,
  datum_label_anzeigen: none,
  blocksatz: none,
  absender_anzeigen: none,
  empfaenger_anzeigen: none,
  datum_anzeigen: none,
  betreff_anzeigen: none,
  papier: none,
  seitenraender: none,
  schriftgroesse: none,
  zeilenabstand: none,
  abstaende: none,
  betreff_groesse: none,
  digitaler_absender_hoehe: none,
  body
) = {
  assert(type(config) == dictionary, message: "Letter config must be a dictionary.")
  let absender = normalize-record(
    absender,
    sender,
    (name: "name", care-of: "zusatz", street: "strasse", postal-code-city: "plz_ort", phone: "telefon"),
    (name: "", zusatz: none, strasse: "", plz_ort: "", telefon: "", email: "", website: "", logo: none),
    "sender",
  )
  let empfaenger = normalize-record(
    empfaenger,
    recipient,
    (name: "name", care-of: "zusatz", street: "strasse", postal-code-city: "plz_ort", country: "land"),
    (name: "", zusatz: none, strasse: "", plz_ort: "", land: ""),
    "recipient",
  )
  validate-postal-record(absender, "Sender", ("name", "strasse", "plz_ort", "telefon", "email", "website"), nullable-fields: ("zusatz",), content-fields: ("logo",))
  validate-postal-record(empfaenger, "Recipient", ("name", "strasse", "plz_ort", "land"), nullable-fields: ("zusatz",))
  let datum = select-alias(datum, date, "datum", "date", datetime.today().display("[year]-[month]-[day]"))
  let datum_label_anzeigen = select-alias(datum_label_anzeigen, show-date-label, "datum_label_anzeigen", "show-date-label", true)
  let geschaeftszeile = select-alias(geschaeftszeile, reference-line, "geschaeftszeile", "reference-line", ())
  if type(geschaeftszeile) == array and geschaeftszeile.len() == 2 and geschaeftszeile.all(value => type(value) == str) {
    geschaeftszeile = (geschaeftszeile,)
  }
  let betreff = select-alias(betreff, subject, "betreff", "subject", "")
  let anlagenverzeichnis = select-alias(anlagenverzeichnis, enclosure-list, "anlagenverzeichnis", "enclosure-list", ())
  let anlagen = select-alias(anlagen, attachments, "anlagen", "attachments", ())
  let signatur_zusatz = select-alias(signatur_zusatz, signature-addition, "signatur_zusatz", "signature-addition", "")
  let postvermerk = select-alias(postvermerk, postal-mark, "postvermerk", "postal-mark", "")
  let lang = select-alias(lang, language, "lang", "language", "de")
  let signatur = select-alias(signatur, signature, "signatur", "signature", true)
  let falzmarken = select-alias(falzmarken, fold-marks, "falzmarken", "fold-marks", true)
  let adressfenster = select-alias(adressfenster, address-window, "adressfenster", "address-window", true)
  let seitenzahlen = select-alias(seitenzahlen, page-numbers, "seitenzahlen", "page-numbers", true)
  let digitaler_absender = select-alias(digitaler_absender, digital-sender, "digitaler_absender", "digital-sender", false)
  let datum_rechts = select-alias(datum_rechts, date-right, "datum_rechts", "date-right", true)
  let blocksatz = select-alias(blocksatz, justify, "blocksatz", "justify", true)
  let absender_anzeigen = select-alias(absender_anzeigen, show-sender, "absender_anzeigen", "show-sender", true)
  let empfaenger_anzeigen = select-alias(empfaenger_anzeigen, show-recipient, "empfaenger_anzeigen", "show-recipient", true)
  let datum_anzeigen = select-alias(datum_anzeigen, show-date, "datum_anzeigen", "show-date", true)
  let betreff_anzeigen = select-alias(betreff_anzeigen, show-subject, "betreff_anzeigen", "show-subject", true)
  let papier = select-alias(papier, paper, "papier", "paper", "a4")
  let seitenraender = select-alias(seitenraender, margins, "seitenraender", "margins", (:))
  let schriftgroesse = select-alias(schriftgroesse, font-size, "schriftgroesse", "font-size", 11pt)
  let zeilenabstand = select-alias(zeilenabstand, line-spacing, "zeilenabstand", "line-spacing", 0.65em)
  let abstaende = select-alias(abstaende, block-spacing, "abstaende", "block-spacing", (:))
  let betreff_groesse = select-alias(betreff_groesse, subject-size, "betreff_groesse", "subject-size", 11.5pt)
  let digitaler_absender_hoehe = select-alias(digitaler_absender_hoehe, digital-sender-height, "digitaler_absender_hoehe", "digital-sender-height", 19mm)
  assert(lang in ("de", "en"), message: "Letter language must be `de` or `en`.")
  assert(type(papier) == str or type(papier) == dictionary, message: "Letter `paper` must be a paper name or a page-size dictionary.")
  assert(type(seitenraender) == dictionary, message: "Letter `margins` must be a dictionary.")
  assert(type(schriftgroesse) == length, message: "Letter `font-size` must be a length.")
  assert(type(zeilenabstand) == length, message: "Letter `line-spacing` must be a length.")
  assert(type(abstaende) == dictionary, message: "Letter `block-spacing` must be a dictionary.")
  assert(type(betreff_groesse) == length, message: "Letter `subject-size` must be a length.")
  assert(type(digitaler_absender_hoehe) == length, message: "Letter `digital-sender-height` must be a length.")
  for (field, value) in (("date", datum), ("subject", betreff), ("signature-addition", signatur_zusatz), ("postal-mark", postvermerk)) {
    assert(type(value) == str, message: "Letter field `" + field + "` must be a string.")
  }
  assert(type(geschaeftszeile) == array and geschaeftszeile.all(row =>
    type(row) == array and row.len() == 2 and row.all(v => type(v) == str)),
    message: "Letter reference-line must be an array of two-string pairs.")
  assert(type(anlagenverzeichnis) == array and anlagenverzeichnis.all(item => type(item) == str),
    message: "Letter enclosure-list must be an array of strings.")
  assert(type(anlagen) == array and anlagen.all(path => type(path) == str),
    message: "Letter attachments must be an array of PDF path strings.")
  for (field, value) in (("signature", signatur), ("fold-marks", falzmarken), ("address-window", adressfenster), ("page-numbers", seitenzahlen), ("digital-sender", digitaler_absender), ("date-right", datum_rechts), ("show-date-label", datum_label_anzeigen), ("justify", blocksatz), ("show-sender", absender_anzeigen), ("show-recipient", empfaenger_anzeigen), ("show-date", datum_anzeigen), ("show-subject", betreff_anzeigen)) {
    assert(type(value) == bool, message: "Letter `" + field + "` option must be a boolean.")
  }
  let seitenraender = (
    left: 25mm,
    right: 20mm,
    top: 25mm,
    bottom: 25mm,
    ..seitenraender,
  )
  let appearance-defaults = merge(shared-defaults, (
    page: (paper: "a4", margin: (left: 25mm, right: 20mm, top: 25mm, bottom: 25mm)),
    typography: (font: "Inter", size: 11pt, leading: 0.65em, justify: true, hyphenate: false),
    colors: (brand-primary: black, text-main: black),
  ))
  let c = resolve-postal-appearance(
    appearance-defaults,
    theme,
    (page: (paper: papier, margin: seitenraender), typography: (font: font, size: schriftgroesse, leading: zeilenabstand, justify: blocksatz)),
    config,
  )
  let zeilenabstand = c.typography.leading
  let spacing-aliases = (
    "sender-recipient": "absender_empfaenger",
    "sender-date": "absender_datum",
    "sender-subject": "absender_betreff",
    "sender-body": "absender_text",
    "recipient-date": "empfaenger_datum",
    "recipient-subject": "empfaenger_betreff",
    "recipient-body": "empfaenger_text",
    "date-subject": "datum_betreff",
    "subject-body": "betreff_text",
    "date-body": "datum_text",
    "signature": "signatur",
  )
  let spacing-overrides = (:)
  for (key, value) in abstaende {
    spacing-overrides.insert(spacing-aliases.at(key, default: key), value)
  }
  let abstaende = (
    absender_empfaenger: 3 * zeilenabstand,
    absender_datum: 4 * zeilenabstand,
    absender_betreff: 4 * zeilenabstand,
    absender_text: 2 * zeilenabstand,
    empfaenger_datum: 4 * zeilenabstand,
    empfaenger_betreff: 4 * zeilenabstand,
    empfaenger_text: 2 * zeilenabstand,
    datum_betreff: 2 * zeilenabstand,
    betreff_text: 2 * zeilenabstand,
    datum_text: 2 * zeilenabstand,
    signatur: 5 * zeilenabstand,
    ..spacing-overrides,
  )
  let has-reference-block = datum_anzeigen or geschaeftszeile.len() > 0

  let strings = if lang == "de" {
    (
      tel: "Tel.",
      email: "E-Mail",
      datum: "Datum",
      anlagen: "Anlagen",
      betreff: betreff,
      page: "Seite",
      of: "von",
    )
  } else {
    (
      tel: "Phone",
      email: "Email",
      datum: "Date",
      anlagen: "Attachments",
      betreff: if betreff == "" { "Subject" } else { betreff },
      page: "Page",
      of: "of",
    )
  }

  // Stile konfigurieren
  set text(font: c.typography.font, size: c.typography.size, lang: lang, hyphenate: c.typography.hyphenate, fill: c.colors.text-main, weight: "regular")
  set par(leading: zeilenabstand, justify: c.typography.justify)
  set list(spacing: zeilenabstand)
  set page(
    paper: c.page.paper,
    margin: c.page.margin,
    fill: c.colors.bg-paper,
    background: if falzmarken { falz_und_locher_marken() } else { none },
    footer: if seitenzahlen { seiten_footer(strings) } else { none },
  )
  show link: it => text(fill: if type(it.dest) == str { c.links.url-color } else { c.links.color }, underline(it))

  // Heading show rules — headings match body size (11pt), only differ by weight/style.
  // This keeps the Betreff (11.5pt bold) as the visually dominant element per DIN 5008.
  show heading.where(level: 1): it => block(below: 0.65em)[
    #set text(weight: "bold", size: 11pt)
    #it
  ]
  show heading.where(level: 2): it => block(below: 0.65em)[
    #set text(weight: "bold", size: 11pt)
    #it
  ]
  show heading.where(level: 3): it => block(below: 0.65em)[
    #set text(weight: "bold", size: 11pt)
    #it
  ]
  show heading.where(level: 4): it => block(below: 0.65em)[
    #set text(weight: "italic", size: 11pt)
    #it
  ]

  // Dokumentenstruktur aufbauen
  if absender_anzeigen {
    if digitaler_absender {
      digitaler_absender_block(absender, hoehe: digitaler_absender_hoehe)
    } else {
      absender_block(absender, zeilenabstand, strings)
    }
  }
  if absender_anzeigen {
    if empfaenger_anzeigen {
      v(abstaende.absender_empfaenger)
    } else if has-reference-block {
      v(abstaende.absender_datum)
    } else if betreff_anzeigen {
      v(abstaende.absender_betreff)
    } else {
      v(abstaende.absender_text)
    }
  }
  if empfaenger_anzeigen {
    if adressfenster {
      empfaenger_block(absender, empfaenger, postvermerk, strings)
    } else {
      digitaler_empfaenger_block(empfaenger)
    }
  }
  if empfaenger_anzeigen {
    if has-reference-block {
      v(abstaende.empfaenger_datum)
    } else if betreff_anzeigen {
      v(abstaende.empfaenger_betreff)
    } else {
      v(abstaende.empfaenger_text)
    }
  }
  if has-reference-block {
    if datum_anzeigen and datum_rechts and geschaeftszeile.len() == 0 {
      digitales_datum_block(datum, strings, show-label: datum_label_anzeigen)
    } else {
      geschaeftszeile_block(
        geschaeftszeile,
        if datum_anzeigen { datum } else { none },
        zeilenabstand,
        strings,
        show-date-label: datum_label_anzeigen,
      )
    }
  }
  if has-reference-block {
    if betreff_anzeigen {
      v(abstaende.datum_betreff)
    } else {
      v(abstaende.datum_text)
    }
  }
  if betreff_anzeigen {
    block(width: 100%)[
      #set text(weight: "bold", size: betreff_groesse, fill: c.colors.brand-primary)
      #betreff
    ]
    v(abstaende.betreff_text)
  }

  // Inhalt aus main.typ
  body

  // Abschluss-Segmente
  if signatur {
    signatur_block(absender.name, signatur_zusatz, zeilenabstand, abstaende.signatur)
  }

  let enclosure-names = if anlagenverzeichnis.len() > 0 { anlagenverzeichnis } else { anlagen }
  if enclosure-names.len() > 0 {
    v(3 * zeilenabstand)
    block(breakable: false, [
      #text(weight: "bold", size: 10pt)[#strings.anlagen:] \
      #v(0.5em)
      #list(..enclosure-names.map(a => text(size: 9.5pt)[#a]))
    ])

    // PDF-Anhänge rendern
    for pdf_pfad in anlagen {
      set page(margin: 0mm, background: none, header: none, footer: none)
      image(pdf_pfad, width: 100%, height: 100%)
    }
  }
}
