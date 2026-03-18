/// A dictionary of papers sizes as they are accepted by `page`.
///
/// Taken from `page.rs`
#let page-sizes = (
  // ---------------------------------------------------------------------- //
  // ISO 216 A Series
  a0:  (w: 841.0mm, h: 1189.0mm),
  a1:  (w: 594.0mm, h:  841.0mm),
  a2:  (w: 420.0mm, h:  594.0mm),
  a3:  (w: 297.0mm, h:  420.0mm),
  a4:  (w: 210.0mm, h:  297.0mm),
  a5:  (w: 148.0mm, h:  210.0mm),
  a6:  (w: 105.0mm, h:  148.0mm),
  a7:  (w:  74.0mm, h:  105.0mm),
  a8:  (w:  52.0mm, h:   74.0mm),
  a9:  (w:  37.0mm, h:   52.0mm),
  a10: (w:  26.0mm, h:   37.0mm),
  a11: (w:  18.0mm, h:   26.0mm),

  // ISO 216 B Series
  iso-b1: (w: 707.0mm, h: 1000.0mm),
  iso-b2: (w: 500.0mm, h:  707.0mm),
  iso-b3: (w: 353.0mm, h:  500.0mm),
  iso-b4: (w: 250.0mm, h:  353.0mm),
  iso-b5: (w: 176.0mm, h:  250.0mm),
  iso-b6: (w: 125.0mm, h:  176.0mm),
  iso-b7: (w:  88.0mm, h:  125.0mm),
  iso-b8: (w:  62.0mm, h:   88.0mm),

  // ISO 216 C Series
  iso-c3: (w: 324.0mm, h: 458.0mm),
  iso-c4: (w: 229.0mm, h: 324.0mm),
  iso-c5: (w: 162.0mm, h: 229.0mm),
  iso-c6: (w: 114.0mm, h: 162.0mm),
  iso-c7: (w:  81.0mm, h: 114.0mm),
  iso-c8: (w:  57.0mm, h:  81.0mm),

  // DIN D Series (extension to ISO)
  din-d3: (272.0mm, 385.0mm),
  din-d4: (192.0mm, 272.0mm),
  din-d5: (136.0mm, 192.0mm),
  din-d6: ( 96.0mm, 136.0mm),
  din-d7: ( 68.0mm,  96.0mm),
  din-d8: ( 48.0mm,  68.0mm),

  // SIS (used in academia)
  sis-g5: (w: 169.0mm, h: 239.0mm),
  sis-e5: (w: 115.0mm, h: 220.0mm),

  // ANSI Extensions
  ansi-a: (w: 216.0mm, h:  279.0mm),
  ansi-b: (w: 279.0mm, h:  432.0mm),
  ansi-c: (w: 432.0mm, h:  559.0mm),
  ansi-d: (w: 559.0mm, h:  864.0mm),
  ansi-e: (w: 864.0mm, h: 1118.0mm),

  // ANSI Architectural Paper
  arch-a:  (w: 229.0mm, h:  305.0mm),
  arch-b:  (w: 305.0mm, h:  457.0mm),
  arch-c:  (w: 457.0mm, h:  610.0mm),
  arch-d:  (w: 610.0mm, h:  914.0mm),
  arch-e1: (w: 762.0mm, h: 1067.0mm),
  arch-e:  (w: 914.0mm, h: 1219.0mm),

  // JIS B Series
  jis-b0:  (w: 1030.0mm, h: 1456.0mm),
  jis-b1:  (w:  728.0mm, h: 1030.0mm),
  jis-b2:  (w:  515.0mm, h:  728.0mm),
  jis-b3:  (w:  364.0mm, h:  515.0mm),
  jis-b4:  (w:  257.0mm, h:  364.0mm),
  jis-b5:  (w:  182.0mm, h:  257.0mm),
  jis-b6:  (w:  128.0mm, h:  182.0mm),
  jis-b7:  (w:   91.0mm, h:  128.0mm),
  jis-b8:  (w:   64.0mm, h:   91.0mm),
  jis-b9:  (w:   45.0mm, h:   64.0mm),
  jis-b10: (w:   32.0mm, h:   45.0mm),
  jis-b11: (w:   22.0mm, h:   32.0mm),

  // SAC D Series
  sac-d0: (w: 764.0mm, h: 1064.0mm),
  sac-d1: (w: 532.0mm, h:  760.0mm),
  sac-d2: (w: 380.0mm, h:  528.0mm),
  sac-d3: (w: 264.0mm, h:  376.0mm),
  sac-d4: (w: 188.0mm, h:  260.0mm),
  sac-d5: (w: 130.0mm, h:  184.0mm),
  sac-d6: (w:  92.0mm, h:  126.0mm),

  // ISO 7810 ID
  iso-id-1: (w: 85.6mm, h:  53.98mm),
  iso-id-2: (w: 74.0mm, h: 105.0mm),
  iso-id-3: (w: 88.0mm, h: 125.0mm),

  // ---------------------------------------------------------------------- //
  // Asia
  asia-f4: (w: 210.0mm, h: 330.0mm),

  // Japan
  jp-shiroku-ban-4: (w: 264.0mm, h: 379.0mm),
  jp-shiroku-ban-5: (w: 189.0mm, h: 262.0mm),
  jp-shiroku-ban-6: (w: 127.0mm, h: 188.0mm),
  jp-kiku-4:        (w: 227.0mm, h: 306.0mm),
  jp-kiku-5:        (w: 151.0mm, h: 227.0mm),
  jp-business-card: (w:  91.0mm, h:  55.0mm),

  // China
  cn-business-card: (w: 90.0mm, h: 54.0mm),

  // Europe
  eu-business-card: (w: 85.0mm, h: 55.0mm),

  // French Traditional (AFNOR)
  fr-tellière:          (w: 340.0mm, h: 440.0mm),
  fr-couronne-écriture: (w: 360.0mm, h: 460.0mm),
  fr-couronne-édition:  (w: 370.0mm, h: 470.0mm),
  fr-raisin:            (w: 500.0mm, h: 650.0mm),
  fr-carré:             (w: 450.0mm, h: 560.0mm),
  fr-jésus:             (w: 560.0mm, h: 760.0mm),

  // United Kingdom Imperial
  uk-brief:    (w: 406.4mm, h: 342.9mm),
  uk-draft:    (w: 254.0mm, h: 406.4mm),
  uk-foolscap: (w: 203.2mm, h: 330.2mm),
  uk-quarto:   (w: 203.2mm, h: 254.0mm),
  uk-crown:    (w: 508.0mm, h: 381.0mm),
  uk-book-a:   (w: 111.0mm, h: 178.0mm),
  uk-book-b:   (w: 129.0mm, h: 198.0mm),

  // Unites States
  us-letter:         (w: 215.9mm,  h: 279.4mm),
  us-legal:          (w: 215.9mm,  h: 355.6mm),
  us-tabloid:        (w: 279.4mm,  h: 431.8mm),
  us-executive:      (w:  84.15mm, h: 266.7mm),
  us-foolscap-folio: (w: 215.9mm,  h: 342.9mm),
  us-statement:      (w: 139.7mm,  h: 215.9mm),
  us-ledger:         (w: 431.8mm,  h: 279.4mm),
  us-oficio:         (w: 215.9mm,  h: 340.36mm),
  us-gov-letter:     (w: 203.2mm,  h: 266.7mm),
  us-gov-legal:      (w: 215.9mm,  h: 330.2mm),
  us-business-card:  (w:  88.9mm,  h:  50.8mm),
  us-digest:         (w: 139.7mm,  h: 215.9mm),
  us-trade:          (w: 152.4mm,  h: 228.6mm),

  // ---------------------------------------------------------------------- //
  // Other
  newspaper-compact:    (w: 280.0mm, h: 430.0mm),
  newspaper-berliner:   (w: 315.0mm, h: 470.0mm),
  newspaper-broadsheet: (w: 381.0mm, h: 578.0mm),
  presentation-16-9:    (w: 297.0mm, h: 167.0625mm),
  presentation-4-3:     (w: 280.0mm, h: 210.0mm),
)
