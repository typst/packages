// =============================================================================
// clean-print-cv — A Typst CV template
//
// Design:  Clean, text-focused, fully print-friendly. Zero color fills.
//          Centered header, left-aligned body.
//          Accent bar on section headings (O'Reilly chapter feel).
//          Muted metadata, generous whitespace (Chirpy blog style).
// Palette: HR/recruiter-optimized monochromatic deep blue.
// Data:    YAML-driven — edit cv-data.yaml, not this file.
// Usage:   #import "@preview/clean-print-cv:0.1.0": *
// Compile: typst compile main.typ
// =============================================================================

// ---------------------------------------------------------------------------
// Theme Colors
// ---------------------------------------------------------------------------
#let primary    = rgb("#2b4c7e")   // deep blue — headings, name, accent bars
#let accent     = rgb("#3d6098")   // steel blue — company names, bullets
#let body-color = rgb("#1a1a1a")   // near-black — body text
#let muted      = rgb("#666666")   // medium gray — dates, locations, metadata
#let rule-color = rgb("#d0d0d0")   // light gray — hairline separators
#let dot-empty  = rgb("#c5cad3")   // unfilled language dots

// ---------------------------------------------------------------------------
// Theme Sizes
// ---------------------------------------------------------------------------
#let name-size       = 20pt
#let title-size      = 10pt
#let section-size    = 10.5pt
#let body-size       = 9.5pt
#let small-size      = 8.5pt
#let contact-size    = 8.5pt

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------
#let bullet-marker(content) = {
  text(fill: accent, size: 6pt)[#sym.circle.filled]
  h(5pt)
  content
}

#let contact-sep = {
  h(5pt)
  text(fill: rule-color, size: 8pt)[#sym.bar.v]
  h(5pt)
}

// ---------------------------------------------------------------------------
// Section heading — left-aligned accent bar (O'Reilly chapter style)
// ---------------------------------------------------------------------------
#let section-heading(title) = {
  v(10pt)  // generous gap from previous section
  block(width: 100%)[
    #grid(
      columns: (3pt, auto),
      column-gutter: 8pt,
      // Left accent bar
      block(
        width: 3pt,
        height: section-size + 2pt,
        fill: primary,
        radius: 1pt,
      ),
      // Title text
      text(
        size: section-size,
        weight: "bold",
        fill: primary,
      )[#upper(title)],
    )
    #v(-4pt)  // rule hugs the heading tightly
    #line(length: 100%, stroke: 0.4pt + rule-color)
  ]
  v(2pt)  // small gap to content — heading owns its content
}

// ---------------------------------------------------------------------------
// Header — centered, print-friendly, zero ink waste
// ---------------------------------------------------------------------------
#let cv-header(personal) = {
  // Name — centered, the visual anchor
  align(center)[
    #text(
      size: name-size,
      weight: "bold",
      fill: primary,
      tracking: 1.5pt,
    )[#upper(personal.name)]
  ]
  v(2pt)
  // Title — centered, muted italic subtitle
  align(center)[
    #text(
      size: title-size,
      fill: muted,
      style: "italic",
    )[#personal.title]
  ]
  v(5pt)
  // Thin rule
  line(length: 100%, stroke: 0.8pt + primary)
  v(4pt)
  // Contact row — centered
  align(center)[
    #set text(size: contact-size, fill: muted)
    #personal.email
    #contact-sep
    #personal.phone
    #contact-sep
    #personal.location
    #if personal.linkedin != "" [
      #contact-sep
      #personal.linkedin
    ]
    #if personal.github != "" [
      #contact-sep
      #personal.github
    ]
    #if personal.at("website", default: "") != "" [
      #contact-sep
      #personal.website
    ]
  ]
  v(1pt)
  line(length: 100%, stroke: 0.3pt + rule-color)
}

// ---------------------------------------------------------------------------
// Professional Summary
// ---------------------------------------------------------------------------
#let cv-summary(summary-text) = {
  block(breakable: false)[
    #section-heading("Professional Summary")
    #block(width: 100%, inset: (left: 2pt))[
      #text(size: body-size, fill: body-color)[#summary-text]
    ]
  ]
}

// ---------------------------------------------------------------------------
// Technical Skills
// ---------------------------------------------------------------------------
#let cv-skills(skills) = {
  block(breakable: false)[
    #section-heading("Technical Skills")
    #for group in skills {
      block(width: 100%, inset: (left: 2pt, bottom: 3pt))[
        #text(size: body-size, weight: "bold", fill: primary)[#group.category:]
        #h(5pt)
        #text(size: small-size, fill: body-color)[
          #group.items.join("  |  ")
        ]
      ]
    }
  ]
}

// ---------------------------------------------------------------------------
// Experience
// ---------------------------------------------------------------------------
#let experience-entry(exp) = {
  block(width: 100%, breakable: false, inset: (left: 2pt, bottom: 1pt))[
    // Role + Period
    #grid(
      columns: (1fr, auto),
      align: (left, right),
      text(size: body-size, weight: "bold", fill: body-color)[#exp.role],
      text(size: small-size, fill: muted)[#exp.period],
    )
    // Company + Location
    #grid(
      columns: (1fr, auto),
      align: (left, right),
      text(size: small-size, fill: accent, weight: "semibold")[#exp.company],
      text(size: small-size, fill: muted, style: "italic")[#exp.location],
    )
    #v(2pt)
    // Bullets
    #for item in exp.highlights {
      block(inset: (left: 6pt, bottom: 1.5pt))[
        #bullet-marker(text(size: small-size, fill: body-color)[#item])
      ]
    }
  ]
  v(3pt)
}

#let cv-experience(experience) = {
  section-heading("Professional Experience")
  for exp in experience {
    experience-entry(exp)
  }
}

// ---------------------------------------------------------------------------
// Key Projects
// ---------------------------------------------------------------------------
#let cv-projects(projects) = {
  block(breakable: false)[
    #section-heading("Key Projects")
    #for proj in projects {
      block(width: 100%, inset: (left: 2pt, bottom: 3pt))[
        #grid(
          columns: (auto, 1fr),
          align: (left, right),
          text(size: body-size, weight: "bold", fill: body-color)[#proj.name],
          text(size: small-size, fill: muted, style: "italic")[#proj.url],
        )
        #v(1pt)
        #text(size: small-size, fill: body-color)[#proj.description]
      ]
    }
  ]
}

// ---------------------------------------------------------------------------
// Certifications
// ---------------------------------------------------------------------------
#let cv-certifications(certs) = {
  block(breakable: false)[
    #section-heading("Certifications")
    #for cert in certs {
      block(width: 100%, inset: (left: 2pt, bottom: 2pt))[
        #grid(
          columns: (1fr, auto),
          align: (left, right),
          [
            #text(size: body-size, weight: "semibold", fill: body-color)[#cert.name]
            #h(4pt)
            #text(size: small-size, fill: muted)[-- #cert.issuer]
          ],
          text(size: small-size, fill: muted)[#cert.year],
        )
      ]
    }
  ]
}

// ---------------------------------------------------------------------------
// Education
// ---------------------------------------------------------------------------
#let cv-education(education) = {
  block(breakable: false)[
    #section-heading("Education")
    #for edu in education {
      block(width: 100%, inset: (left: 2pt, bottom: 2pt))[
        #grid(
          columns: (1fr, auto),
          align: (left, right),
          text(size: body-size, weight: "bold", fill: body-color)[#edu.degree],
          text(size: small-size, fill: muted)[#edu.period],
        )
        #grid(
          columns: (1fr, auto),
          align: (left, right),
          text(size: small-size, fill: accent, weight: "semibold")[#edu.institution],
          text(size: small-size, fill: muted, style: "italic")[#edu.location],
        )
        #if edu.at("details", default: "") != "" {
          v(1pt)
          text(size: small-size, fill: body-color)[#edu.details]
        }
      ]
    }
  ]
}

// ---------------------------------------------------------------------------
// Languages
// ---------------------------------------------------------------------------
#let cv-languages(languages) = {
  block(breakable: false)[
    #section-heading("Languages")
    #block(width: 100%, inset: (left: 2pt))[
      #grid(
        columns: (1fr,) * calc.min(languages.len(), 3),
        column-gutter: 16pt,
        ..languages.map(lang => {
          let filled = lang.dots
          let empty = 5 - lang.dots
          [
            #text(size: body-size, weight: "semibold", fill: body-color)[#lang.language]
            #h(4pt)
            #text(size: small-size, fill: muted)[#lang.level]
            #v(1pt)
            #text(size: 8pt)[
              #for i in range(filled) [#text(fill: accent)[#sym.circle.filled] ]
              #for i in range(empty) [#text(fill: dot-empty)[#sym.circle.filled] ]
            ]
          ]
        })
      )
    ]
  ]
}

// ---------------------------------------------------------------------------
// Page setup
// ---------------------------------------------------------------------------
#let cv-page-setup(body) = {
  set document(
    title: "Curriculum Vitae",
    author: "",
  )
  set page(
    paper: "a4",
    margin: (top: 28pt, bottom: 24pt, left: 32pt, right: 32pt),
    header: none,
    footer: none,
  )
  set text(
    font: "New Computer Modern",
    size: body-size,
    fill: body-color,
    lang: "en",
  )
  set par(
    justify: true,
    leading: 0.55em,
  )
  body
}
