// ═══════════════════════════════════════════════════════════
//  CV — Typst Template  |  Dark theme + accent color
//
//  Everything you need to customize is in the CONFIGURATION
//  section below. The layout code starts after the separator.
// ═══════════════════════════════════════════════════════════


// ───────────────────────────────────────────────────────────
//  CONFIGURATION
// ───────────────────────────────────────────────────────────

// Accent color — change this single line to retheme the whole CV
#let ACCENT = rgb("#F2CF00")

// Profile photo — replace photo.png with your own image file
#let photo = "photo.png"

// Identity
#let full_name  = "First Last"
#let job_title  = "JOB TITLE"

// Contact
#let email     = "email@example.com"
#let telephone = "00 00 00 00 00"
#let city      = "City, Country"
#let github    = "github.com/username"

// Profile summary
#let summary = "Your profile summary goes here. Describe who you are, what drives you, and what sets you apart — keep it concise and punchy."

// Skills — (category label, list of items)
#let skills = (
  ("Category 1", ("Skill A", "Skill B", "Skill C")),
  ("Category 2", ("Skill D", "Skill E")),
  ("Category 3", ("Skill F", "Skill G", "Skill H")),
  ("Category 4", ("Skill I", "Skill J")),
  ("Category 5", ("Skill K", "Skill L", "Skill M")),
)

// Hobbies — (icon, label)
#let hobbies = (
  ("⌨", "Hobby 1"),
  ("◎", "Hobby 2"),
  ("⚙", "Hobby 3"),
)

// Languages — (language, level, highlight)
// Set highlight to true to display the level in the accent color
#let languages = (
  ("French", "Native",       true),
  ("English", "Professional", false),
)

// Work experience — most recent first
#let experiences = (
  (
    title:   "Job Title",
    company: "Company Name",
    period:  "MM.YYYY — Present",
    location: "city or website",
    points: (
      "Description of your main mission or achievement.",
      "Second key point for this role.",
      "Third point — result, impact, or technology used.",
    ),
  ),
  (
    title:   "Job Title",
    company: "Company Name",
    period:  "MM.YYYY — MM.YYYY",
    location: "city or website",
    points: (
      "Description of your main mission or achievement.",
      "Second key point for this role.",
    ),
  ),
)

// Education — most recent first
#let education = (
  (
    degree: "Degree or Certification Name",
    school: "Institution · City",
    period: "YYYY — YYYY",
  ),
  (
    degree: "Degree or Certification Name",
    school: "Institution · City",
    period: "YYYY — YYYY",
  ),
)


// ───────────────────────────────────────────────────────────
//  LAYOUT — no need to edit below unless tweaking the design
// ───────────────────────────────────────────────────────────

#set page(
  paper: "a4",
  margin: 0pt,
  fill: rgb("#000000"),
)

#set text(
  font: "DejaVu Sans",
  size: 9pt,
  fill: rgb("#E0E0E0"),
)

#set par(leading: 0.58em, justify: false)

// ─── Color palette ───────────────────────────────────────────
#let BK     = rgb("#000000")
#let PANEL  = rgb("#0D0D0D")
#let BORDER = rgb("#1E1E1E")
#let ADIM   = rgb("#2A2400")   // very dark accent (tag background)
#let AMID   = rgb("#4A4100")   // dark accent (decorative line)
#let WHITE  = rgb("#FFFFFF")
#let LGRAY  = rgb("#CCCCCC")
#let MGRAY  = rgb("#888888")

// ─── Helpers ─────────────────────────────────────────────────
#let dim(content) = text(fill: MGRAY, size: 8pt)[#content]

#let tag(t) = box(
  fill: ADIM,
  radius: 3pt,
  inset: (x: 5pt, y: 2.5pt),
  stroke: (paint: ACCENT, thickness: 0.4pt),
)[#text(fill: ACCENT, size: 7.5pt, weight: "bold")[#t]]

#let skillgroup(cat, items) = {
  text(fill: MGRAY, size: 7pt, tracking: 1pt)[#upper(cat)]
  v(2pt)
  for item in items {
    tag(item)
    h(3pt)
  }
  v(4pt)
}

#let ctact(ico, txt) = grid(
  columns: (10pt, 1fr),
  gutter: 6pt,
  align: horizon,
  text(fill: ACCENT, size: 9pt)[#ico],
  text(fill: LGRAY, size: 7.8pt)[#txt],
)

#let sec(title) = {
  v(4pt)
  grid(
    columns: (auto, 6pt, 1fr),
    align: horizon,
    gutter: 0pt,
    box(fill: ACCENT, width: 3pt, height: 10pt, radius: 1pt)[],
    h(6pt),
    text(fill: WHITE, weight: "bold", size: 9pt, tracking: 1.5pt)[#upper(title)],
  )
  v(2pt)
  line(length: 100%, stroke: (paint: BORDER, thickness: 0.7pt))
  v(5pt)
}

#let xp(title, company, period, location, points) = {
  grid(
    columns: (1fr, auto),
    align: (left, right),
    text(fill: WHITE, weight: "bold", size: 8.5pt)[#title],
    text(fill: MGRAY, size: 7.5pt)[#period],
  )
  v(1pt)
  if location != "" [#text(fill: ACCENT, size: 8pt, weight: "bold")[#company]#h(5pt)#text(fill: MGRAY, size: 7.5pt)[— #location]] else [#text(fill: ACCENT, size: 8pt, weight: "bold")[#company]]
  v(3pt)
  for p in points {
    grid(
      columns: (7pt, 1fr),
      gutter: 3pt,
      align: (top, top),
      text(fill: ACCENT, size: 7.5pt)[▸],
      text(fill: LGRAY, size: 8pt)[#p],
    )
    v(1.5pt)
  }
  v(6pt)
}

// ─── Sidebar ─────────────────────────────────────────────────
#let sidebar = box(
  fill: PANEL,
  width: 67mm,
  height: 297mm,
)[
  #box(fill: ACCENT, width: 100%, height: 5pt)[]

  #box(inset: (x: 15pt, top: 14pt, bottom: 12pt), width: 100%)[

    #v(4pt)
    #align(center)[
      #box(
        width: 64pt,
        height: 64pt,
        radius: 50%,
        stroke: (paint: ACCENT, thickness: 2pt),
        clip: true,
      )[
        #image(photo, width: 64pt, height: 64pt, fit: "cover")
      ]
    ]
    #v(5pt)
    #align(center)[
      #text(fill: WHITE, weight: "bold", size: 12pt)[#full_name]
      #linebreak()
      #v(2pt)
      #box(
        fill: ACCENT,
        inset: (x: 7pt, y: 3pt),
        radius: 3pt,
      )[#text(fill: BK, weight: "bold", size: 7pt, tracking: 1pt)[#job_title]]
    ]
    #v(6pt)
    #line(length: 100%, stroke: (paint: ACCENT, thickness: 0.8pt))
    #v(6pt)

    #text(fill: ACCENT, weight: "bold", size: 7.5pt, tracking: 1.5pt)[CONTACT]
    #v(4pt)
    #ctact("✉", email)
    #v(2pt)
    #ctact("✆", telephone)
    #v(2pt)
    #ctact("⌂", city)
    #v(2pt)
    #ctact("⌥", github)

    #v(6pt)
    #line(length: 100%, stroke: (paint: BORDER, thickness: 0.7pt))
    #v(6pt)

    #text(fill: ACCENT, weight: "bold", size: 7.5pt, tracking: 1.5pt)[SKILLS]
    #v(4pt)
    #for (cat, items) in skills {
      skillgroup(cat, items)
    }

    #v(6pt)
    #line(length: 100%, stroke: (paint: BORDER, thickness: 0.7pt))
    #v(6pt)

    #text(fill: ACCENT, weight: "bold", size: 7.5pt, tracking: 1.5pt)[HOBBIES]
    #v(4pt)
    #for item in hobbies {
      grid(
        columns: (10pt, 1fr),
        gutter: 5pt,
        align: horizon,
        text(fill: ACCENT, size: 9pt)[#item.at(0)],
        text(fill: LGRAY, size: 8pt)[#item.at(1)],
      )
      v(2pt)
    }

    #v(6pt)
    #line(length: 100%, stroke: (paint: BORDER, thickness: 0.7pt))
    #v(6pt)

    #text(fill: ACCENT, weight: "bold", size: 7.5pt, tracking: 1.5pt)[LANGUAGES]
    #v(4pt)
    #for (i, lang) in languages.enumerate() {
      grid(
        columns: (1fr, auto),
        text(fill: WHITE, size: 8pt)[#lang.at(0)],
        if lang.at(2) {
          text(fill: ACCENT, size: 7.5pt, weight: "bold")[#lang.at(1)]
        } else {
          text(fill: MGRAY, size: 7.5pt)[#lang.at(1)]
        },
      )
      if i < languages.len() - 1 { v(2pt) }
    }

  ]
]

// ─── Main content ─────────────────────────────────────────────
#let main = box(
  fill: BK,
  width: 143mm,
  height: 297mm,
  clip: true,
)[
  #box(fill: ACCENT, width: 100%, height: 5pt)[]

  #box(inset: (left: 16pt, right: 14pt, top: 10pt, bottom: 10pt), width: 100%)[

    #grid(
      columns: (1fr, auto),
      align: (top, bottom),
      stack(
        spacing: 4pt,
        text(fill: WHITE, weight: "bold", size: 22pt, tracking: -0.5pt)[#full_name],
        grid(
          columns: (auto, 8pt, 1fr),
          align: horizon,
          box(fill: ACCENT, inset: (x: 9pt, y: 4pt), radius: 3pt)[
            #text(fill: BK, weight: "bold", size: 9pt, tracking: 0.5pt)[#job_title]
          ],
          [],
          line(length: 100%, stroke: (paint: AMID, thickness: 1pt)),
        ),
      ),
      stack(
        dir: ltr,
        spacing: 4pt,
        box(width: 5pt, height: 5pt, fill: ACCENT)[],
        box(width: 5pt, height: 5pt, fill: AMID)[],
        box(width: 5pt, height: 5pt, fill: ADIM)[],
      ),
    )

    #text(fill: WHITE, size: 8.5pt)[#summary]

    #sec("Work Experience")

    #for e in experiences {
      xp(e.title, e.company, e.period, e.location, e.points)
    }

    #sec("Education")

    #for (i, f) in education.enumerate() {
      grid(
        columns: (1fr, auto),
        text(fill: WHITE, weight: "bold", size: 8.5pt)[#f.degree],
        dim[#f.period],
      )
      text(fill: LGRAY, size: 7.5pt)[#f.school]
      if i < education.len() - 1 { v(4pt) }
    }

  ]
]

// ─── Page assembly ────────────────────────────────────────────
#grid(
  columns: (67mm, 143mm),
  sidebar,
  main,
)
