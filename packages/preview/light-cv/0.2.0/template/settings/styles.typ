#let accent-color = rgb("#007fad");
#let styles = (
  page-style: (
    paper: "a4",
    margin: (
      left: 1cm,
      right: 1cm,
      top: 0.8cm,
      bottom: 0.4cm,
    )
  ),
  colors: (
    accent: accent-color
  ),
  body-style: (
    fonts: ("Source Sans Pro", "Font Awesome 6 Brands", "Font Awesome 6 Free"),
    size: 10pt,
    weight: "regular"
  ),
  list-style: (
    indent: 1em
  ),
  header-style: (
    fonts: ("New Computer Modern Sans"),
    table: (
      columns: (5fr, 1fr),
      column-gutter: 30pt
    ),
    full-name: (
      size: 36pt,
      weight: "bold"
    ),
    job-title: (
      size: 18pt,
      weight: "bold"
    ),
    profile-photo: (
      width: 100pt, 
      height: 100pt, 
      stroke: none, 
      radius: 9999pt,
      image-height: 10.0cm
    ),
    margins: (
      between-info-and-socials: 2.5mm,
      bottom: 3pt
    ),
    socials: (
      column-gutter: 10pt
    )
  ),
  section-style: (
    title: (
      size: 16pt,
      weight: "bold",
      font-color: black 
    ),
    margins: (
      top: 3pt,
      right-to-hline: 2pt,
    )
  ),
  entry-style: (
    table: (
      columns: (5%, 1fr)
    ),
    title: (
      size: 10pt,
      weight: "bold",
      color: black
    ),
    company-or-university: (
      size: 10pt,
      weight: "bold",
      color: accent-color
    ),
    time-and-location: (
      size: 10pt,
      weight: "regular",
      color: black
    ),
    margins: (
      top: 3pt,
      between-logo-and-title: 8pt,
      between-title-and-subtitle: 3pt,
      between-time-and-location: 10pt,
      between-icon-and-text: 5pt
    )
  ),
  skills-style: (
    columns: (18%, 1fr),
    stroke: 1pt + accent-color,
    radius: 20%,
    margins: (
      between-skill-tags: 6pt,
      between-categories: -6pt
    )
  )
)
