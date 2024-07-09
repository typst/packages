// From typst source crates/typst/src/layout/page.rs
#let papers = (
    // ISO 216 A Series
    a0: (width: 841.0, height: 1189.0),
    a1: (width: 594.0,  height: 841.0),
    a2: (width: 420.0,  height: 594.0),
    a3: (width: 297.0,  height: 420.0),
    a4: (width: 210.0,  height: 297.0),
    a5: (width: 148.0,  height: 210.0),
    a6: (width: 105.0,  height: 148.0),
    a7: (width: 74.0,  height: 105.0),
    a8: (width: 52.0,   height: 74.0),
    a9: (width: 37.0,   height: 52.0),
    a10: (width: 26.0,   height: 37.0),
    a11: (width: 18.0,   height: 26.0),

    // ISO 216 B Series
    iso-b1: (width: 707.0, height: 1000.0),
    iso-b2: (width: 500.0,  height: 707.0),
    iso-b3: (width: 353.0,  height: 500.0),
    iso-b4: (width: 250.0,  height: 353.0),
    iso-b5: (width: 176.0,  height: 250.0),
    iso-b6: (width: 125.0,  height: 176.0),
    iso-b7: (width: 88.0,  height: 125.0),
    iso-b8: (width: 62.0,   height: 88.0),

    // ISO 216 C Series
    iso-c3: (width: 324.0, height: 458.0),
    iso-c4: (width: 229.0, height: 324.0),
    iso-c5: (width: 162.0, height: 229.0),
    iso-c6: (width: 114.0, height: 162.0),
    iso-c7: (width: 81.0, height: 114.0),
    iso-c8: (width: 57.0,  height: 81.0),

    // DIN D Series (extension to ISO)
    din-d3: (width: 272.0, height: 385.0),
    din-d4: (width: 192.0, height: 272.0),
    din-d5: (width: 136.0, height: 192.0),
    din-d6: (width: 96.0, height: 136.0),
    din-d7: (width: 68.0,  height: 96.0),
    din-d8: (width: 48.0,  height: 68.0),

    // SIS (used in academia)
    sis-g5: (width: 169.0, height: 239.0),
    sis-e5: (width: 115.0, height: 220.0),

    // ANSI Extensions
    ansi-a: (width: 216.0,  height: 279.0),
    ansi-b: (width: 279.0,  height: 432.0),
    ansi-c: (width: 432.0,  height: 559.0),
    ansi-d: (width: 559.0,  height: 864.0),
    ansi-e: (width: 864.0, height: 1118.0),

    // ANSI Architectural Paper
    arch-a: (width: 229.0,  height: 305.0),
    arch-b: (width: 305.0,  height: 457.0),
    arch-c: (width: 457.0,  height: 610.0),
    arch-d: (width: 610.0,  height: 914.0),
    arch-e1: (width: 762.0, height: 1067.0),
    arch-e: (width: 914.0, height: 1219.0),

    // JIS B Series
    jis-b0: (width: 1030.0, height: 1456.0),
    jis-b1: (width: 728.0, height: 1030.0),
    jis-b2: (width: 515.0,  height: 728.0),
    jis-b3: (width: 364.0,  height: 515.0),
    jis-b4: (width: 257.0,  height: 364.0),
    jis-b5: (width: 182.0,  height: 257.0),
    jis-b6: (width: 128.0,  height: 182.0),
    jis-b7: (width: 91.0,  height: 128.0),
    jis-b8: (width: 64.0,   height: 91.0),
    jis-b9: (width: 45.0,   height: 64.0),
    jis-b10: (width: 32.0,   height: 45.0),
    jis-b11: (width: 22.0,   height: 32.0),

    // SAC D Series
    sac-d0: (width: 764.0, height: 1064.0),
    sac-d1: (width: 532.0,  height: 760.0),
    sac-d2: (width: 380.0,  height: 528.0),
    sac-d3: (width: 264.0,  height: 376.0),
    sac-d4: (width: 188.0,  height: 260.0),
    sac-d5: (width: 130.0,  height: 184.0),
    sac-d6: (width: 92.0,  height: 126.0),

    // ISO 7810 ID
    iso-id-1: (width: 85.6, height: 53.98),
    iso-id-2: (width: 74.0, height: 105.0),
    iso-id-3: (width: 88.0, height: 125.0),

    // ---------------------------------------------------------------------- //
    // Asia
    asia-f4: (width: 210.0, height: 330.0),

    // Japan
    jp-shiroku-ban-4: (width: 264.0, height: 379.0),
    jp-shiroku-ban-5: (width: 189.0, height: 262.0),
    jp-shiroku-ban-6: (width: 127.0, height: 188.0),
    jp-kiku-4: (width: 227.0, height: 306.0),
    jp-kiku-5: (width: 151.0, height: 227.0),
    jp-business-card: (width: 91.0,  height: 55.0),

    // China
    cn-business-card: (width: 90.0, height: 54.0),

    // Europe
    eu-business-card: (width: 85.0, height: 55.0),

    // French Traditional (width: 
    fr-tellière: (width: 340.0, height: 440.0),
    fr-couronne-écriture: (width: 360.0, height: 460.0),
    fr-couronne-édition: (width: 370.0, height: 470.0),
    fr-raisin: (width: 500.0, height: 650.0),
    fr-carré: (width: 450.0, height: 560.0),
    fr-jésus: (width: 560.0, height: 760.0),

    // United Kingdom Imperial
    uk-brief: (width: 406.4, height: 342.9),
    uk-draft: (width: 254.0, height: 406.4),
    uk-foolscap: (width: 203.2, height: 330.2),
    uk-quarto: (width: 203.2, height: 254.0),
    uk-crown: (width: 508.0, height: 381.0),
    uk-book-a: (width: 111.0, height: 178.0),
    uk-book-b: (width: 129.0, height: 198.0),

    // Unites States
    us-letter: (width: 215.9,  height: 279.4),
    us-legal: (width: 215.9,  height: 355.6),
    us-tabloid: (width: 279.4,  height: 431.8),
    us-executive: (width: 84.15,  height: 266.7),
    us-foolscap-folio: (width: 215.9,  height: 342.9),
    us-statement: (width: 139.7,  height: 215.9),
    us-ledger: (width: 431.8,  height: 279.4),
    us-oficio: (width: 215.9, height: 340.36),
    us-gov-letter: (width: 203.2,  height: 266.7),
    us-gov-legal: (width: 215.9,  height: 330.2),
    us-business-card: (width: 88.9,   height: 50.8),
    us-digest: (width: 139.7,  height: 215.9),
    us-trade: (width: 152.4,  height: 228.6),

    // ---------------------------------------------------------------------- //
    // Other
    newspaper-compact: (width: 280.0,    height: 430.0),
    newspaper-berliner: (width: 315.0,    height: 470.0),
    newspaper-broadsheet: (width: 381.0,    height: 578.0),
    presentation-16-9: (width: 297.0, height: 167.0625),
    presentation-4-3: (width: 280.0,    height: 210.0),
)

// Add some aliases
#papers.insert("16:9", papers.presentation-16-9)
#papers.insert("4:3", papers.presentation-4-3)
