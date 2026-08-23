#import "@preview/fontawesome:0.6.1": *

// ─────────────────────────────────────────────
//  Icons
// ─────────────────────────────────────────────
#let icon-tel = box(fa-icon("phone"))
#let icon-email = box(fa-icon("envelope"))
#let icon-github = box(fa-icon("github"))
#let icon-linkedin = box(fa-icon("linkedin"))
#let icon-webpage = box(fa-icon("globe"))
#let icon-telegram = box(fa-icon("telegram"))
#let icon-location = box(fa-icon("location-dot"))

// ─────────────────────────────────────────────
//  Main resume function
// ─────────────────────────────────────────────
#let resume(
  // ── Identity ──────────────────────────────
  author: "",
  title: "", // Job title / tagline shown under name
  pronouns: "",
  // ── Contact ───2────────────────────────────
  location: "",
  email: "",
  phone: "",
  github: "",
  linkedin: "",
  personal-site: "",
  orcid: "",
  // ── Intro section ─────────────────────────
  // about-title  : heading text ("About me", "À propos", "Profil"…)
  //                set to "" to hide the heading entirely
  // about-beside : content shown beside the photo (~3 lines max)
  // about-below  : optional full-width content shown below the photo row
  about-title: "About me",
  about-beside: [],
  about-below: [],
  // ── Photo ─────────────────────────────────
  show-photo: true,
  photo: "photo.jpg",
  photo-size: 140pt,
  // ── Footer reference line ─────────────────
  // Pinned to the bottom of the page. Set to "" to hide.
  reference: "",
  // ── Colours ───────────────────────────────
  header-color: "#06332a",
  name-color: "#ffdf2b",
  heading-color: "#ffdf2b",
  text-color: "#303f3c",
  photo-border: "#ffffff",
  // ── Typography ────────────────────────────
  font: "Avenir Next",
  author-font-size: 20pt,
  font-size: 10pt,
  // ── Layout ────────────────────────────────
  paper: "a4",
  lang: "en",
  icon: true,
  // ── Banner height override ─────────────────
  // The template estimates banner height from the number of contact items.
  // If the result looks wrong (e.g. a very long personal-site URL causes
  // wrapping), set this to a fixed value like 110pt to override.
  // Leave as `auto` (none) to use the automatic calculation.
  banner-height-override: none,
  body,
) = {
  // ── Document metadata ─────────────────────
  set document(author: author, title: author)

  // ── Global text ───────────────────────────
  set text(
    font: font,
    size: font-size,
    lang: lang,
    ligatures: false,
    fill: white,
  )

  // ── Page ──────────────────────────────────
  let bottom-margin = if reference != "" { 0.6cm } else { 1cm }
  set page(
    margin: (top: 0.8cm, bottom: bottom-margin, left: 1cm, right: 1cm),
    paper: paper,
  )

  // ── Heading styles ────────────────────────
  show heading.where(level: 2): it => [
    #pad(top: 0pt, bottom: -10pt, [#smallcaps(it.body)])
    #line(length: 100%, stroke: 1pt)
  ]
  show heading: set text(fill: rgb(heading-color))
  show heading.where(level: 1): set text(
    fill: rgb(name-color),
  )
  show link: set text(fill: white)
  show heading.where(level: 1): it => [
    #set text(weight: 800, size: author-font-size)
    #pad(it.body)
  ]

  // ── Contact-item helper ───────────────────
  let contact-item(value, prefix: "", link-type: "") = {
    if value == "" { return none }
    let display = if icon { box[#prefix #value] } else { value }
    if link-type != "" { link(link-type + value)[#display] } else { [#display] }
  }

  let items = (
    contact-item(pronouns),
    contact-item(phone, link-type: "tel:", prefix: [#icon-tel ]),
    contact-item(location, prefix: [#icon-location ]),
    contact-item(email, link-type: "mailto:", prefix: [#icon-email ]),
    contact-item(personal-site, link-type: "https://", prefix: [#icon-webpage ]),
    contact-item(github, link-type: "https://github.com/", prefix: [#icon-github ]),
    contact-item(linkedin, link-type: "https://linkedin.com/in/", prefix: [#icon-linkedin ]),
    contact-item(orcid, link-type: "https://orcid.org/"),
  ).filter(x => x != none)

  // ── Banner height calculation ─────────────
  // Layout (all measurements approximate at default 10pt font / a4):
  //   - name + title + separator : ~46pt
  //   - top + bottom inset       : ~20pt
  //   - each contact row         : ~18pt
  //
  // Items are joined on one line. On a4 with 1cm margins and photo column
  // (~150pt), the usable width for the contact row is ~400pt.
  // Each item averages ~110pt (icon + typical text + 4-space gap).
  // We estimate how many items fit per row from that, then derive row count.
  //
  // This is still an estimate — use banner-height-override if it's off.
  let n = items.len()
  let usable-width = if show-photo { 400pt } else { 550pt }
  let avg-item-width = 110pt
  let items-per-row = calc.max(1, calc.floor(usable-width / avg-item-width))
  let contact-rows = calc.ceil(n / items-per-row)

  let banner-height = if banner-height-override != none {
    banner-height-override
  } else {
    62pt + contact-rows * 22pt
  }

  // ── Photo column width ────────────────────
  let photo-col-width = if show-photo { photo-size + 7pt } else { 0pt }

  // ── Banner ────────────────────────────────
  block(
    fill: rgb(header-color),
    height: banner-height,
    inset: 10pt,
    radius: 4pt,
  )[
    #grid(
      columns: (1fr, photo-col-width),
      gutter: if show-photo { 20pt } else { 0pt },
      [
        = #(author)
        #stack(
          spacing: 8pt,
          text(fill: white, weight: 400, size: 12pt, title),
          line(length: 100%, stroke: (paint: white, thickness: 1pt)),
        )
        #block(width: 100%)[
          #set align(center)
          #items.join("    ")
        ]
      ],
      if show-photo [
        #v(45pt - (photo-size / 5))
        #block(
          clip: true,
          radius: 100%,
          height: photo-size,
          width: photo-size,
          fill: rgb("e4e5ea"),
          stroke: (paint: rgb(photo-border), thickness: 3pt),
          [#image(photo, width: 100%)],
        )
      ],
    )
  ]

  show link: set text(fill: rgb(text-color))


  // ── Intro / about ─────────────────────────
  [
    #show heading: set text(fill: rgb(heading-color))
    #set text(fill: rgb(text-color))
    #grid(columns: (1fr, photo-col-width), gutter: 10pt)[
      #if about-title != "" [
        #heading(level: 2, about-title)
      ]
      #about-beside
    ]
    #if about-below != [] [
      #v(-5pt)
      #about-below
    ]
  ]

  // ── Body ──────────────────────────────────
  set par(justify: true)
  show heading: set text(fill: rgb(heading-color))
  set text(fill: rgb(text-color))

  body

  // ── Footer — pinned to bottom of page ─────
  if reference != "" [
    #place(bottom + left)[
      #pad(bottom: 0pt)[
        #set text(size: 9pt, fill: rgb(text-color))
        #emph[#reference]
      ]
    ]
  ]
}

// ─────────────────────────────────────────────
//  Utility helpers
// ─────────────────────────────────────────────

#let generic-two-by-two(
  top-left: "",
  top-right: "",
  bottom-left: "",
  bottom-right: "",
) = [
  #top-left #h(1fr) #top-right \
  #bottom-left #h(1fr) #bottom-right
]

#let generic-one-by-two(left: "", right: "") = [
  #left #h(1fr) #right
]

/// Date range helper. Omit start-date for a single date.
#let dates-helper(start-date: "", end-date: "") = {
  if start-date == "" { end-date } else { start-date + " " + sym.dash.em + " " + end-date }
}

// ─────────────────────────────────────────────
//  Section components
// ─────────────────────────────────────────────

#let edu(
  institution: "",
  dates: "",
  degree: "",
  gpa: "",
  location: "",
  consistent: false,
) = {
  if consistent {
    generic-two-by-two(
      top-left: strong(institution),
      top-right: dates,
      bottom-left: emph(degree),
      bottom-right: emph(location),
    )
  } else {
    generic-two-by-two(
      top-left: strong(institution),
      top-right: location,
      bottom-left: emph(degree),
      bottom-right: emph(dates),
    )
  }
}

#let work(title: "", dates: "", company: "", location: "") = {
  generic-two-by-two(
    top-left: strong(title),
    top-right: dates,
    bottom-left: company,
    bottom-right: emph(location),
  )
}

#let project(role: "", name: "", url: "", dates: "") = {
  generic-one-by-two(
    left: {
      if role == "" {
        [*#name* #if url != "" and dates != "" [(#link("https://" + url)[#url])]]
      } else {
        [*#role*, #name #if url != "" and dates != "" [(#link("https://" + url)[#url])]]
      }
    },
    right: {
      if dates == "" and url != "" { link("https://" + url)[#url] } else { dates }
    },
  )
}

#let certificates(name: "", issuer: "", url: "", date: "") = [
  *#name*, #issuer
  #if url != "" [(#link("https://" + url)[#url])]
  #h(1fr) #date
]

#let extracurriculars(activity: "", dates: "") = {
  generic-one-by-two(left: strong(activity), right: dates)
}
