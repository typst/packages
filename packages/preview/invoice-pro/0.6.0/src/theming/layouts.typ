// Layouts ("page masters") are PLAIN DATA. Standard area names (marks,
// letterhead, address, info, references, title, continuation, page-number,
// footer) that a layout omits are injected as empty stubs by `complete-layout`,
// so looks and patches that name them work on every layout.
//
// Window layouts list the `envelopes` they are designed for. The recipient box of
// every window layout shows at least 5 lines (US: 4) of recipient text with 2 mm
// clearance in EVERY declared envelope, whatever position the folded sheet takes
// inside it (tests/envelopes.typ). Sources and tolerances: REPORT.md of the
// country-layouts study. `theme.custom.proof(true)` draws the windows on the page.
#import "layout-ops.typ": derive

// --- envelope catalogue ------------------------------------------------------------
// Window anchors are measured on the envelope FRONT with the flap edge on top, the
// way manufacturers state them ("from the bottom", "from the right"). `fold: auto`
// uses the layout's fold marks; a C5 takes the sheet folded once (148.5 mm), a C4
// takes it flat.
#let _half = (148.5mm,)
/// Pins the fold scheme on envelopes that fold with the layout (`fold: auto`), so the
/// fit stays right when the printed marks are switched off (`marks(none)`).
#let folded(folds, ..envs) = (
  envs
    .pos()
    .map(e => if e.at("fold", default: auto) == auto {
      e + (fold: folds)
    } else { e })
)
#let envelope = (
  // DE/AT: DIN 680 (via DIN 5008 literature); high confidence for DL/C6/5, medium for C5/C4
  din-dl: (
    name: "din-dl",
    size: (220mm, 110mm),
    window: (left: 20mm, bottom: 15mm, width: 90mm, height: 45mm),
    note: "DL, DIN 680",
  ),
  din-c6-5: (
    name: "din-c6-5",
    size: (229mm, 114mm),
    window: (left: 20mm, bottom: 15mm, width: 90mm, height: 45mm),
    note: "C6/5, DIN 680",
  ),
  din-c5-a: (
    name: "din-c5-a",
    size: (229mm, 162mm),
    fold: _half,
    window: (left: 20mm, bottom: 77mm, width: 90mm, height: 45mm),
    note: "C5, DIN 680 form A",
  ),
  din-c5-b: (
    name: "din-c5-b",
    size: (229mm, 162mm),
    fold: _half,
    window: (left: 20mm, bottom: 60mm, width: 90mm, height: 45mm),
    note: "C5, DIN 680 form B",
  ),
  din-c4-a: (
    name: "din-c4-a",
    size: (229mm, 324mm),
    fold: (),
    window: (left: 20mm, top: 40mm, width: 90mm, height: 55mm),
    note: "C4, DIN 680 form A",
  ),
  din-c4-b: (
    name: "din-c4-b",
    size: (229mm, 324mm),
    fold: (),
    window: (left: 20mm, top: 57mm, width: 90mm, height: 55mm),
    note: "C4, DIN 680 form B",
  ),
  // CH: Elco product data (current) and INKA "Schweizer Postnormen für Fensterkuverts" (SN 010 130)
  ch-c5-6-right: (
    name: "ch-c5-6-right",
    size: (229mm, 114mm),
    window: (right: 12mm, bottom: 21mm, width: 100mm, height: 45mm),
    note: "C5/6 window right (Elco, INKA)",
  ),
  ch-c5-right: (
    name: "ch-c5-right",
    size: (229mm, 162mm),
    fold: _half,
    window: (right: 12mm, bottom: 65mm, width: 100mm, height: 45mm),
    note: "C5 window right (Elco, INKA)",
  ),
  ch-c5-6-left: (
    name: "ch-c5-6-left",
    size: (229mm, 114mm),
    window: (right: 109mm, bottom: 25mm, width: 100mm, height: 45mm),
    note: "C5/6 window left, SN old (INKA)",
  ),
  ch-c5-6-left-din: (
    name: "ch-c5-6-left-din",
    size: (229mm, 114mm),
    window: (right: 119mm, bottom: 15mm, width: 90mm, height: 45mm),
    note: "C5/6 window left, DIN position (Elco Proclima)",
  ),
  ch-c5-left: (
    name: "ch-c5-left",
    size: (229mm, 162mm),
    fold: _half,
    window: (right: 109mm, bottom: 65mm, width: 100mm, height: 45mm),
    note: "C5 window left (Elco, INKA)",
  ),
  // FR / IT / ES: right windows (manufacturer data, medium confidence)
  fr-dl-right: (
    name: "fr-dl-right",
    size: (220mm, 110mm),
    window: (right: 20mm, bottom: 20mm, width: 100mm, height: 45mm),
    note: "DL 110x220, window 45x100 20BI/20BD (GPV, Antalis)",
  ),
  fr-c5-right: (
    name: "fr-c5-right",
    size: (229mm, 162mm),
    fold: _half,
    window: (right: 20mm, bottom: 62mm, width: 100mm, height: 45mm),
    note: "C5 162x229, window 45x100 62BI/20BD (GPV, Antalis)",
  ),
  it-11x23-right: (
    name: "it-11x23-right",
    size: (230mm, 110mm),
    window: (right: 16mm, bottom: 16mm, width: 100mm, height: 40mm),
    note: "busta 11x23, finestra 4x10 (Blasetti)",
  ),
  es-americano-right: (
    name: "es-americano-right",
    size: (225mm, 115mm),
    window: (right: 20mm, bottom: 20mm, width: 100mm, height: 45mm),
    note: "sobre americano 115x225, ventana 45x100 pos. 20/20 (Arpon)",
  ),
  es-americano-right-25: (
    name: "es-americano-right-25",
    size: (225mm, 115mm),
    window: (right: 25mm, bottom: 25mm, width: 100mm, height: 45mm),
    note: "sobre americano 115x225, ventana 45x100 at 25/25 (print template)",
  ),
  // UK: BS 4264 DL as quoted in the literature, a common DL variant, a C5 (A4 folded once)
  uk-dl: (
    name: "uk-dl",
    size: (220mm, 110mm),
    window: (left: 20mm, top: 53mm, width: 93mm, height: 39mm),
    note: "DL, BS 4264 (20 mm in, 53 mm from top)",
  ),
  uk-dl-22: (
    name: "uk-dl-22",
    size: (220mm, 110mm),
    window: (left: 18mm, bottom: 22mm, width: 93mm, height: 39mm),
    note: "DL variant (18 in, 22 up)",
  ),
  uk-c5: (
    name: "uk-c5",
    size: (229mm, 162mm),
    fold: _half,
    window: (left: 20mm, bottom: 60mm, width: 90mm, height: 44mm),
    note: "C5, window 90x44 at 20 in, 60 up",
  ),
  // US: #10 (4 1/8 x 9 1/2 in), USPS-recommended window 1 1/8 x 4 1/2 in at 7/8 in left
  us-10: (
    name: "us-10",
    size: (9.5in, 4.125in),
    window: (left: 0.875in, bottom: 0.5in, width: 4.5in, height: 1.125in),
    note: "#10, window 1 1/8 x 4 1/2 in at 7/8 in left, 1/2 in bottom",
  ),
  us-10-5-8: (
    name: "us-10-5-8",
    size: (9.5in, 4.125in),
    window: (left: 0.875in, bottom: 0.625in, width: 4.5in, height: 1.125in),
    note: "#10 variant, window 5/8 in from bottom",
  ),
)

// Footer blocks print at the fine size in the secondary text colour, including
// free content cells (text defaults are area data, so a patch can change them).
// Every built-in layout computes its bottom margin (margin.bottom: auto): the
// tallest footer stack + footer-descent + footer-clearance (5 mm), at least 20 mm.
#let _fine = (size: t => t.sizes.fine, fill: t => t.colors.text-muted)
// Line spacing is area data too (`par`), so a look can change it on any layout:
// address and letterhead blocks set tight, the legal footer tighter.
#let _tight = (leading: 0.5em)
#let _fine-par = (leading: 0.45em)
#let _footer = (
  place: "footer",
  stationery: true,
  text: _fine,
  par: _fine-par,
  parts: ("company", "contact", "registration", "bank-account"),
  arrange: (columns: (1fr, 1fr, 1fr, 1fr)),
)
#let _running = (
  continuation: (place: "header", pages: "rest", parts: ("continuation",)),
  page-number: (place: "footer", parts: ("page-number",), align: right),
)
#let _marks = (place: "background", parts: ("marks",))

/// DIN 5008:2020 form A, A4, left window (DL, C6/5, C5, C4 per DIN 680). STABLE.
/// The recipient zone is the DIN one (44.7-72 mm); text stops at 100 mm (DL window
/// minus the 10 mm sideways play of an A4 in a DL).
#let din-5008-a = (
  name: "din-5008-a",
  paper: "a4",
  margin: (top: 20mm, right: 20mm, bottom: auto, left: 25mm),
  marks: (fold: (87mm, 192mm), punch: 148.5mm, left: 5mm, length: 2.5mm), // stroke: hairline + text colour
  envelopes: folded(
    (87mm, 192mm),
    envelope.din-dl,
    envelope.din-c6-5,
    envelope.din-c5-a,
    envelope.din-c4-a,
  ),
  areas: (
    marks: _marks,
    letterhead: (
      left: 25mm,
      top: 8mm,
      width: 165mm,
      height: 19mm,
      stationery: true,
      par: _tight,
      parts: ("logo", "sender"),
      arrange: (columns: (1fr, auto), align: (left + horizon, right + top)),
    ),
    address: (
      left: 20mm,
      top: 27mm,
      width: 85mm,
      height: 45mm,
      inset: (left: 5mm, right: 5mm),
      par: _tight,
      parts: ("return-address", "recipient"),
      gap: 0pt,
      arrange: (rows: (17.7mm, 27.3mm), align: (left + bottom, left + top)),
    ),
    info: (
      left: 125mm,
      top: 32mm,
      width: 75mm,
      height: 40mm,
      parts: ("sender-details",),
    ),
    references: (place: "before", parts: ("references",)),
    title: (place: "before", parts: ("title",)),
    continuation: _running.continuation,
    page-number: _running.page-number,
    footer: _footer,
  ),
)

/// DIN 5008 form B: letterhead zone 45 mm, window at 45 mm (DL, C6/5, C5). STABLE.
/// A flat A4 in a C4 form-B envelope shows 4 recipient lines in the worst position.
#let din-5008-b = derive(din-5008-a, (
  layout: (
    name: "din-5008-b",
    marks: (fold: (105mm, 210mm)),
    envelopes: folded(
      (105mm, 210mm),
      envelope.din-dl,
      envelope.din-c6-5,
      envelope.din-c5-b,
    ),
    areas: (
      letterhead: (height: 37mm),
      address: (top: 45mm),
      info: (top: 50mm),
    ),
  ),
))

/// A4, window RIGHT: France, Italy, Spain (DL 110x220, busta 11x23, sobre
/// americano 115x225, C5 folded once). One box that shows in all of them.
/// EXPERIMENTAL (manufacturer data; NF Z 11-001 itself not consulted).
#let a4-window-right = (
  name: "a4-window-right",
  paper: "a4",
  margin: (top: 20mm, right: 20mm, bottom: auto, left: 20mm),
  body-top: 99mm, // below the lowest DL-class window edge (95 mm), so no body text shows through
  marks: (fold: (105mm, 210mm), punch: 148.5mm, left: 5mm, length: 2.5mm),
  envelopes: folded(
    (105mm, 210mm),
    envelope.fr-dl-right,
    envelope.fr-c5-right,
    envelope.it-11x23-right,
    envelope.es-americano-right,
    envelope.es-americano-right-25,
  ),
  areas: (
    marks: _marks,
    letterhead: (
      left: 20mm,
      top: 12mm,
      width: 170mm,
      height: 30mm,
      stationery: true,
      par: _tight,
      parts: ("logo", "sender"),
      arrange: (columns: (1fr, auto), align: (left + horizon, right + top)),
    ),
    address: (
      left: 114mm,
      top: 57mm,
      width: 72mm,
      height: 23mm,
      inset: (left: 2mm),
      par: _tight,
      parts: ("recipient",),
    ),
    info: (
      left: 20mm,
      top: 57mm,
      width: 85mm,
      height: 30mm,
      parts: ("reference-list",),
    ),
    title: (place: "before", parts: ("title",)),
    continuation: _running.continuation,
    page-number: _running.page-number,
    footer: _footer,
  ),
)

/// A4, window LEFT without the DIN return-address zone: United Kingdom (DL per BS 4264
/// and a common variant, C5 folded once). Royal Mail: 2 mm clear inside the window
/// after tapping the letter on all four edges. EXPERIMENTAL.
#let a4-window-left = (
  name: "a4-window-left",
  paper: "a4",
  margin: (top: 20mm, right: 20mm, bottom: auto, left: 20mm),
  body-top: 96mm, // below the lowest DL window edge (92 mm)
  marks: (fold: (105mm, 210mm), punch: 148.5mm, left: 5mm, length: 2.5mm),
  envelopes: folded(
    (105mm, 210mm),
    envelope.uk-dl,
    envelope.uk-dl-22,
    envelope.uk-c5,
  ),
  areas: (
    marks: _marks,
    letterhead: (
      left: 20mm,
      top: 12mm,
      width: 170mm,
      height: 34mm,
      stationery: true,
      par: _tight,
      parts: ("logo", "sender"),
      arrange: (columns: (1fr, auto), align: (left + horizon, right + top)),
    ),
    address: (
      left: 20mm,
      top: 60mm,
      width: 75mm,
      height: 21mm,
      inset: (left: 4mm),
      par: _tight,
      parts: ("recipient",),
    ),
    info: (
      left: 120mm,
      top: 52mm,
      width: 70mm,
      height: 35mm,
      parts: ("reference-list",),
    ),
    title: (place: "before", parts: ("title",)),
    continuation: _running.continuation,
    page-number: _running.page-number,
    footer: _footer,
  ),
)

/// US Letter, #10 single-window envelope. EXPERIMENTAL.
/// Z-fold with a 3 7/8 in top panel (marks), so the packet (3 7/8 in) leaves 1/4 in of
/// play in the 4 1/8 in envelope; equal thirds leave 0.46 in and only 3 lines show.
/// USPS (DMM 601.6.3) wants 1/8 in clear around the address after the tap test.
#let us-letter-10 = (
  name: "us-letter-10",
  paper: "us-letter",
  margin: (top: 0.75in, right: 0.75in, bottom: auto, left: 0.875in),
  body-top: 96mm, // below the #10 window edge with the sheet pushed up (92.1 mm)
  marks: (
    fold: (3.875in, 7.5in),
    punch: none,
    left: 0.2in,
    length: 0.12in,
    stroke: 0.25pt + luma(60%),
  ),
  envelopes: folded((3.875in, 7.5in), envelope.us-10),
  areas: (
    marks: _marks,
    letterhead: (
      left: 0.875in,
      top: 0.5in,
      width: 6.875in,
      height: 1.2in,
      stationery: true,
      par: _tight,
      parts: ("sender", "logo"),
      arrange: (columns: (1fr, auto), align: (left + top, right + top)),
    ),
    address: (
      left: 0.875in,
      top: 2.58in,
      width: 3.6in,
      height: 0.72in,
      inset: (left: 0.125in),
      par: _tight,
      parts: ("recipient",),
    ),
    info: (
      right: 0.75in,
      top: 2in,
      width: 2.6in,
      height: 1.2in,
      parts: ("reference-list",),
    ),
    title: (place: "before", parts: ("title",)),
    continuation: _running.continuation,
    page-number: _running.page-number,
    footer: _footer + (parts: ("contact",), arrange: (columns: (1fr,))),
  ),
)

/// A4 digital-only: no window, no marks, everything flows. STABLE.
#let a4-digital = (
  name: "a4-digital",
  paper: "a4",
  margin: (top: 18mm, right: 20mm, bottom: auto, left: 20mm),
  marks: none,
  areas: (
    letterhead: (
      place: "before",
      stationery: true,
      par: _tight,
      parts: ("logo", "sender"),
      inset: (bottom: 6mm),
      arrange: (columns: (1fr, auto), align: (left + horizon, right + top)),
    ),
    title: (place: "before", parts: ("title",), inset: (bottom: 4mm)),
    address: (
      place: "before",
      par: _tight,
      parts: ("recipient", "reference-list"),
      inset: (bottom: 8mm),
      arrange: (columns: (1fr, 1fr), align: (left + top, left + top)),
    ),
    continuation: _running.continuation,
    page-number: _running.page-number,
    // the legal footer with `contact`, the only place a digital invoice prints
    // the sender's `extra` (phone, email): columns weighted by what they hold
    // (the register column carries the longest lines, as in `bold`); an empty
    // part, e.g. without `extra`, gives up its column
    footer: _footer
      + (
        arrange: (
          columns: (0.75fr, 1.05fr, 1.4fr, 1.25fr),
          skip-empty: true,
        ),
      ),
  ),
)

/// US Letter digital-only. STABLE. Letter is 17.6 mm shorter than A4, so the top
/// margin is the usual US 1/2 in (a4-digital: 18 mm): a small invoice stays on one page.
#let us-letter-digital = derive(a4-digital, (
  layout: (
    name: "us-letter-digital",
    paper: "us-letter",
    margin: (top: 0.5in),
  ),
))

/// Swiss SN 010130, window RIGHT (C5/6 and C5 per Elco/INKA). EXPERIMENTAL.
/// Folds 99/192 mm: the second fold is the QR-bill perforation line, so a payment
/// part is never folded through; the 105 mm bottom panel sets the packet height.
/// It reserves NO QR-bill zone and prints no slip: a 4-item invoice fits on one
/// page. The zone is an explicit opt-in, `reserve-qr-bill(layout)` (0.6.x preview).
#let sn-010130-right = (
  name: "sn-010130-right",
  paper: "a4",
  margin: (top: 20mm, right: 18mm, bottom: auto, left: 22mm),
  marks: (fold: (99mm, 192mm), punch: 148.5mm, left: 5mm, length: 2.5mm),
  envelopes: folded(
    (99mm, 192mm),
    envelope.ch-c5-6-right,
    envelope.ch-c5-right,
  ),
  areas: (
    marks: _marks,
    letterhead: (
      left: 22mm,
      top: 15mm,
      width: 80mm,
      height: 30mm,
      stationery: true,
      par: _tight,
      parts: ("logo", "sender"),
    ),
    address: (
      left: 118mm,
      top: 54mm,
      width: 80mm,
      height: 24mm,
      inset: (left: 2mm),
      par: _tight,
      parts: ("recipient",),
    ),
    info: (
      left: 22mm,
      top: 54mm,
      width: 80mm,
      height: 30mm,
      parts: ("reference-list",),
    ),
    title: (place: "before", parts: ("title",)),
    continuation: _running.continuation,
    page-number: _running.page-number,
    footer: _footer,
  ),
)

/// Swiss SN 010130 with the window on the LEFT (C5/6 with the DIN
/// window position as sold today, C5, DL). Derived: the address and info swap sides
/// (setting `left` clears `right` and vice versa).
#let sn-010130-left = derive(sn-010130-right, (
  layout: (
    name: "sn-010130-left",
    body-top: 97mm, // below the DIN-position C5/6 window edge (93 mm)
    envelopes: folded(
      (99mm, 192mm),
      envelope.ch-c5-6-left-din,
      envelope.ch-c5-left,
      envelope.din-dl,
    ),
    areas: (
      address: (left: 20mm, width: 72mm, height: 26mm),
      info: (left: 125mm, width: 67mm),
    ),
  ),
))

/// The reserved Swiss QR-bill zone: 210 x 105 mm at the bottom edge of the last
/// page, brand-immune (regulated font, black on white); the footer moves above it.
#let _qr-bill-zone = (
  place: "after",
  float: true,
  isolate: true,
  left: 0mm,
  width: 210mm,
  height: 105mm,
  parts: ("qr-bill",),
)

/// 0.6.x PREVIEW, opt-in: `layout` plus the reserved Swiss QR-bill zone, e.g.
/// `layout: theme.layout.reserve-qr-bill(theme.layout.sn-010130-right)`.
/// Until the QR-bill component ships, the zone shows a PLACEHOLDER slip (receipt
/// and payment part outlines, no QR code), and it may need a page of its own. The
/// layout keeps its name; the `lint/qr-bill-paper` check wants A4 portrait paper.
/// -> dictionary
#let reserve-qr-bill(layout) = (
  layout + (areas: layout.areas + (qr-bill: _qr-bill-zone))
)

/// A4 digital with a full-bleed letterhead BAND (40 mm, logo above the name) for
/// looks that fill it (prestige). The band hosts required parts, so it is a FIXED
/// first-page area (tagged for PDF/UA; a background area would be an untagged
/// artifact) and pushes the body down. Title, recipient and references flow below.
/// Digital-first: office printers leave a 4-5 mm unprintable rim. EXPERIMENTAL.
#let a4-band = (
  name: "a4-band",
  paper: "a4",
  margin: (top: 20mm, right: 22mm, bottom: auto, left: 22mm),
  marks: none,
  body-gap: 8mm,
  areas: (
    letterhead: (
      left: 0mm,
      top: 0mm,
      width: 100%,
      height: 40mm,
      stationery: true,
      par: _tight,
      parts: ("logo", "sender"),
      arrange: "stack",
      align: center + horizon,
      gap: 3mm,
    ),
    title: (place: "before", parts: ("title",), inset: (bottom: 4mm)),
    address: (
      place: "before",
      par: _tight,
      parts: ("recipient", "reference-list"),
      inset: (bottom: 6mm),
      arrange: (columns: (1fr, 1fr), align: (left + top, left + top)),
    ),
    continuation: _running.continuation,
    page-number: _running.page-number,
    footer: _footer,
  ),
)

/// US Letter with the full-bleed band (see a4-band). EXPERIMENTAL.
#let us-letter-band = derive(a4-band, (
  layout: (name: "us-letter-band", paper: "us-letter"),
))

/// No furniture: sender, title and recipient in the flow, the legal register
/// block in the footer (the successor of `blank`). STABLE.
#let plain = (
  name: "plain",
  paper: "a4",
  marks: none,
  areas: (
    letterhead: (
      place: "before",
      par: _tight,
      parts: ("sender",),
      inset: (bottom: 4mm),
    ),
    title: (place: "before", parts: ("title",)),
    address: (
      place: "before",
      par: _tight,
      parts: ("recipient",),
      inset: (bottom: 4mm),
    ),
    footer: (
      place: "footer",
      parts: ("registration",),
      text: _fine,
      par: _fine-par,
    ),
  ),
)

// --- layout by region -------------------------------------------------------------
// `invoice(theme: ..)` without `layout:` lets the preset pick its page master from the
// SENDER's region (env.region: the sender's country, else the locale's region): the
// envelope stock and the paper belong to the sender. An explicit `layout:` always wins.

/// Window layout per sender region (country-layouts study; confidence: de high, at/ch/
/// fr/es/gb/us medium, it low). Unknown regions get `default` (DIN 5008 form A).
#let by-region = (
  de: din-5008-a,
  at: din-5008-b,
  ch: sn-010130-right,
  fr: a4-window-right,
  it: a4-window-right,
  es: a4-window-right,
  gb: a4-window-left,
  uk: a4-window-left,
  us: us-letter-10,
)
#let _key(region) = if type(region) == str { lower(region) } else { "" }

/// The window-envelope layout for a region code (ISO 3166 alpha-2, any case), e.g.
/// `theme.layout.for-region("ch")` -> sn-010130-right. Unknown or missing regions
/// (none, "base", "nl", ..) fall back to `default`.
/// -> dictionary
#let for-region(region, default: din-5008-a) = by-region.at(
  _key(region),
  default: default,
)

/// Regions whose office paper is US Letter; everything else uses A4.
#let letter-regions = ("us",)

/// The office paper of a region: "us-letter" or "a4" (the fallback).
/// -> str
#let paper-for-region(region) = if _key(region) in letter-regions {
  "us-letter"
} else { "a4" }

/// Digital-only layout for a region: us-letter-digital on Letter paper, else a4-digital.
/// -> dictionary
#let digital-for-region(region) = if paper-for-region(region) == "us-letter" {
  us-letter-digital
} else { a4-digital }

/// The furniture-free layout on the region's paper.
/// -> dictionary
#let plain-for-region(region) = plain + (paper: paper-for-region(region))

// --- experimental layouts of the built-in looks ---------------------------------

/// The brand rail of `a4-sidebar`: logo and supplier on top, the legal register and
/// the bank account pinned to its foot (area = the content box inside the inset).
#let _rail-arrange(ctx, cells, area) = {
  let body = cells.map(((n, c)) => if c == none { [] } else { c })
  let (head, foot) = (body.slice(0, 3), body.slice(3))
  grid(rows: (auto,) * head.len()
      + (1fr,)
      + (auto,) * foot.len(), row-gutter: 6mm, ..head, [], ..foot)
}

/// A4 digital with a brand rail on the left: supplier, contact, legal register and
/// bank account live in a tinted 56 mm column on page 1 (tagged, reading order
/// first); following pages keep the rail as a band with the logo. No window, no
/// marks, no footer (the rail carries the legal data); body column 128 mm.
/// EXPERIMENTAL (default of `corporate`).
#let a4-sidebar = (
  name: "a4-sidebar",
  paper: "a4",
  margin: (top: 20mm, right: 16mm, bottom: auto, left: 66mm),
  marks: none,
  areas: (
    rail: (
      left: 0mm,
      top: 0mm,
      width: 56mm,
      height: 100%,
      reserve: false,
      stationery: true,
      fill: t => t.colors.tint,
      stroke: t => (right: t.strokes.regular + t.colors.accent),
      inset: (x: 7mm, top: 20mm, bottom: 18mm),
      text: (size: 7.5pt, fill: t => t.colors.text-muted),
      par: (leading: 0.5em),
      parts: ("logo", "sender", "contact", "registration", "bank-account"),
      arrange: _rail-arrange,
    ),
    rail-rest: (
      place: "background",
      pages: "rest",
      left: 0mm,
      top: 0mm,
      width: 56mm,
      height: 100%,
      stationery: true,
      fill: t => t.colors.tint,
      stroke: t => (right: t.strokes.regular + t.colors.accent),
      inset: (x: 7mm, top: 20mm),
      parts: ("logo",),
    ),
    title: (place: "before", parts: ("title",), inset: (bottom: 5mm)),
    address: (
      place: "before",
      par: _tight,
      parts: ("recipient", "reference-list"),
      inset: (bottom: 5mm),
      arrange: (columns: (1fr, 1fr), align: (left + top, left + top)),
    ),
    continuation: _running.continuation,
    page-number: _running.page-number,
  ),
)

/// `a4-sidebar` on US Letter. EXPERIMENTAL.
#let us-letter-sidebar = derive(a4-sidebar, (
  layout: (name: "us-letter-sidebar", paper: "us-letter"),
))

/// The sidebar layout on the region's paper (US Letter in the US, else A4).
/// -> dictionary
#let sidebar-for-region(region) = if paper-for-region(region) == "us-letter" {
  us-letter-sidebar
} else { a4-sidebar }
/// The band layout on the region's paper: us-letter-band on Letter, else a4-band.
/// -> dictionary
#let band-for-region(region) = if paper-for-region(region) == "us-letter" {
  us-letter-band
} else { a4-band }


/// The header row of the dense layouts: recipient | references | title. A compact
/// title (a stack, like compact's) keeps its natural width in the third column. A
/// title that fills its line (a row with number and date, a banner) would squeeze the
/// two 1fr columns to nothing, so it moves above the row and takes the full width.
/// Any look therefore renders cleanly on a4-dense / us-letter-dense.
#let _dense-arrange(ctx, cells, area) = {
  let gap = ctx
    .theme
    .layout
    .areas
    .at("address", default: (:))
    .at("gap", default: 1em)
  if type(gap) != length { gap = 1em }
  let body(c) = if c == none { [] } else { c }
  let ti = cells.position(((n, c)) => n == "title")
  let others = cells
    .enumerate()
    .filter(((i, _)) => i != ti)
    .map(((i, (n, c))) => body(c))
  let row(items) = grid(
    columns: (1fr,) * calc.max(1, items.len()),
    column-gutter: gap,
    align: left + top,
    ..items,
  )
  if ti == none { return row(others) }
  let title = body(cells.at(ti).at(1))
  layout(size => {
    let w = measure(title, width: size.width).width
    if w <= 0.4 * size.width {
      grid(
        columns: (1fr,) * others.len() + (auto,),
        column-gutter: gap,
        align: left + top,
        ..others,
        title,
      )
    } else {
      // above the row, like the title area of the digital layouts
      stack(spacing: gap, block(width: 100%, title), row(others))
    }
  })
}

/// A4 digital, dense (default of the `compact` preset): narrow margins, a slim
/// letterhead (logo + sender) above ONE header row: recipient | references | title,
/// so a 50-line collective invoice starts high on page 1. No window, no marks; the
/// bottom margin is computed (margin.bottom: auto). EXPERIMENTAL: it exists because a
/// look cannot move parts between areas (0.6: look-level part placement).
#let a4-dense = (
  name: "a4-dense",
  paper: "a4",
  margin: (top: 13mm, right: 14mm, bottom: auto, left: 16mm),
  footer-descent: 25%,
  marks: none,
  areas: (
    letterhead: (
      place: "before",
      stationery: true,
      par: _tight,
      parts: ("logo", "sender"),
      inset: (bottom: 3mm),
      arrange: (columns: (auto, 1fr), align: (left + horizon, left + horizon)),
    ),
    address: (
      place: "before",
      par: _tight,
      parts: ("recipient", "reference-list", "title"),
      inset: (bottom: 5mm),
      arrange: _dense-arrange, // (1fr, 1fr, auto); a wide title moves above
    ),
    continuation: _running.continuation,
    page-number: _running.page-number,
    footer: _footer,
  ),
)

/// US Letter, dense (`compact` in the US). EXPERIMENTAL.
#let us-letter-dense = derive(a4-dense, (
  layout: (name: "us-letter-dense", paper: "us-letter"),
))

/// The dense layout on the region's paper: us-letter-dense on Letter, else a4-dense.
/// -> dictionary
#let dense-for-region(region) = if paper-for-region(region) == "us-letter" {
  us-letter-dense
} else { a4-dense }
