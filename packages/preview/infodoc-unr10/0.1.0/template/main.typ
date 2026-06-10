// Information Document (Beschreibungsbogen) — UN-R 10 EMC Type Approval
// Replace all placeholder values with your actual product data.
// See the README for full parameter documentation.

#import "@preview/infodoc-unr10:0.1.0": kba-document

#show: kba-document.with(
  date: "15.06.2025",
  doc-number: "ID-MYPRODUCT-00",

  // Item 1 — Brand / Make
  marke: "My Brand",

  // Item 2 — Type designation: MUST be character-for-character identical
  // across the application form, the test report, and this document.
  typ: "MY-TYPE-100",

  // All approved variants — list completely, including for amendments
  varianten: (
    "MY-TYPE-100-A",
    "MY-TYPE-100-B",
  ),
  handelsbezeichnung: "My Product Name",

  // Item 3 — Type identification
  ident-merkmal: ("Typbezeichnung auf dem Gehäuse", "Type designation on housing"),
  ident-stelle: ("Gehäuseunterseite", "Bottom of housing"),

  // Item 4 — Manufacturer (full name and address)
  hersteller-name-anschrift: "My Company GmbH, Musterstraße 1, 10000 Berlin, Germany",

  // Authorised representative — leave empty string if none
  beauftragter: "",

  // Item 5 — Approval mark: location and method
  genehmigung-stelle-art: ("Klebeschild auf dem Gehäuse", "Adhesive label on the housing"),

  // Item 6 — Assembly plant(s): entity performing the last approval-relevant step
  montagebetriebe: (
    "My Company GmbH, Musterstraße 1, 10000 Berlin, Germany",
  ),

  // Item 7 — Approval category
  // ("Bauteil", "component")  OR  ("Selbstständige technische Einheit", "separate technical unit")
  genehmigt-als: ("Bauteil", "component"),

  // Item 8 — Restrictions: ("keine", "none") for components; list vehicle types for STEs
  beschraenkungen: ("keine", "none"),

  // Item 9 — Rated voltage (nominal value only, NOT a range)
  nennspannung: ("12 V", "neg. ground"),

  // ── Charging system fields (items 10–15) ─────────────────────────────────
  // Uncomment only for REESS charging systems.
  // is-charging-system: true,
  // ladegeraet: "On-board charger",
  // ladestrom: "AC",
  // phasen: "1",
  // frequenz: "50 Hz",
  // max-nennstrom: "16 A",
  // nenn-ladespannung: "230 V",
  // schnittstellen: "IEC 62196-2 Type 2",
  // rsce-wert: "66",
  // ─────────────────────────────────────────────────────────────────────────

  // Annex table — add one entry per supporting document
  anlagen: (
    (
      nr: "1",
      inhalt: "Functional Description",
      doc-nr: "FUN-MYPRODUCT-1.0",
      datum: "15.06.2025",
      rev: "15.06.2025",
      seiten: "3",
    ),
  ),
)
