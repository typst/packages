#import "@preview/bureaucrat:0.3.0": letter, indented, signature, colors

#show: letter.with(
  // ── DOCUMENT DATA ───────────────────────────────────────────────────
  subject:        none,
  doc-type:       none,   doc-type-code:  none,     marking:        none,

  date:       "2020-01-20",
  our-ref:    none,       revision: none,
  your-date:  none,       your-ref:   none,

  language: "nb",  // en,nb,nn or custom in labels.toml

  // ── RECIPIENT ───────────────────────────────────────────────────────
  recipient-lead: none,
  recipient: [
    Recip Co
    123 Post Street
    Anytown, USA
  ],
  secondary-address: none, // (lead, content) e.g. ("CC:", [J. Chiles])

  // ── LABEL OVERRIDES ─────────────────────────────────────────────────
  labels: (:),

  // ── SENDER ──────────────────────────────────────────────────────────
  // company: (name: "", department: "", handler: "") OR
  // person: (name: "", address_title: "")
  company: (
    name: "Vandelay Industries",
    department: "Exports department",
    handler: "A. Vandelay"
  ),
  person: none,

  logo: none,     // none or e.g. image("logo.png")

  // ── SENDER'S FULL CONTACT DETAILS (FOOTER) ──────────────────────────
  // ((label, content), (..)) OR [*label* \ content \ *l* \ c],[...]
  footer: (
    ("Postadresse", [Street \ Town]),
    ("Telefon",     "+47 123 45 678"),
    ("E-post",      [#link("mailto:art@vandelay.biz")[art\@vandelay.biz]]),
  ),
  footer-tabs: (0, 2, 4, 6), // edit to fit more columns

  // ── LAYOUT ──────────────────────────────────────────────────────────
  folding-marks: true,  two-sided: false, even-margins: true,
  justify: true,        rules: true,      list-indent: 1,
)

// ── BODY TEXT ───────────────────────────────────────────────────────
// use #indented[content] for indented paragraphs

body

Yours,

#signature()[Art Vandelay \ Architect]
