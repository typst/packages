#import "@preview/fontawesome:0.6.0": *

/// A two-column CV template matching the nabcv design.
///
/// - name (str): Full name displayed in the header.
/// - headline (str, none): Tagline shown below the name.
/// - location (str, none): Location shown below the headline.
/// - keywords (array, none): Tag badges shown in the header.
/// - email (str, none): Email address.
/// - phone (str, none): Phone number.
/// - address (str, array, none): Physical address (string or array of lines).
/// - profiles (array, none): Social profiles. Each entry: (network, username).
/// - summary (str, none): Summary section text.
/// - motivation (str, none): Motivation section text.
/// - experience (array, none): Experience entries.
/// - education (array, none): Education entries.
/// - awards (array, none): Award entries.
/// - courses (array, none): Course entries.
/// - skills (array, none): Skill groups. Each entry: (group, items).
/// - values (array, none): Values list.
/// - hobbies (array, none): Hobbies list.
/// - references (str, array, none): References text or list.
/// - publications (array, none): Publication entries.
/// - theme (dictionary): Override any theme colour. Keys: primary, secondary,
///   accent, links, sidebar-bg, summary.
/// - text-size (dictionary): Override any font size.
/// - font-family (dictionary): Override any font family.
/// - font-weight (dictionary): Override any font weight.
/// - show-timeline (bool): Toggle timeline on/off for experience/education.
/// - justify-sidebar (bool): Toggle sidebar text justification.
/// - skill-icons (dictionary): Map skill group names to FontAwesome icon names.
/// - section-icons (dictionary): Override any section FontAwesome icon name.
///   Keys match section keys. Defaults e.g. experience: "suitcase".
/// - bullet-icon (str): FontAwesome icon name used for all list bullets.
/// - address-icon (str): FontAwesome icon name used for the address field.
/// - doi-icon (str): FontAwesome icon name used for DOI links in publications.
/// - month-names (array): 12 month abbreviation strings for date formatting.
/// - date-separator (str): String placed between start and end dates.
/// - profiles-config (dictionary): Map of network name to (icon, url-base) dict.
///   Add any network: (Mastodon: (icon: "mastodon", url-base: "https://mastodon.social/@")).
/// - sidebar-sections (array): Ordered list of sidebar section keys to render.
///   Valid keys: "contact", "skills", "values", "hobbies", "references", "publications".
/// - main-sections (array): Ordered list of main column section keys to render.
///   Valid keys: "summary", "motivation", "experience", "education", "awards", "courses".
/// - section-titles (dictionary): Override any section display title.
///   Keys match section keys above. Defaults are all-caps e.g. "HONORS & AWARDS".
/// - photo (content, none): Profile photo, e.g. image("assets/avatar.png").
///   Rendered as a circle at the top of the sidebar.
/// - photo-size (ratio): Diameter of the circular photo as a fraction of sidebar width.
/// - body (content): Optional content appended after the CV.
#let cv(
  name: "",
  headline: none,
  location: none,
  keywords: none,
  email: none,
  phone: none,
  address: none,
  profiles: none,
  summary: none,
  motivation: none,
  experience: none,
  education: none,
  awards: none,
  courses: none,
  skills: none,
  values: none,
  hobbies: none,
  references: none,
  publications: none,
  theme: (:),
  text-size: (:),
  font-family: (:),
  font-weight: (:),
  show-timeline: true,
  justify-sidebar: false,
  photo: none,
  photo-size: 70%,
  skill-icons: (:),
  section-icons: (:),
  bullet-icon: "angle-right",
  address-icon: "location-dot",
  doi-icon: "external-link",
  month-names: (
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
  ),
  date-separator: " – ",
  profiles-config: (
    LinkedIn: (icon: "linkedin", url-base: "https://linkedin.com/in/"),
    GitHub: (icon: "github", url-base: "https://github.com/"),
  ),
  sidebar-sections: (
    "photo",
    "contact",
    "skills",
    "values",
    "hobbies",
    "references",
    "publications",
  ),
  main-sections: (
    "summary",
    "motivation",
    "experience",
    "education",
    "awards",
    "courses",
  ),
  section-titles: (:),
  body,
) = {
  // --- Default theme ---
  let t = (
    (
      primary: rgb("#000000"),
      secondary: rgb("#0D47A1"),
      accent: rgb("#000000"),
      links: rgb("#1565C0"),
      sidebar-bg: rgb("#F5F1ED"),
      summary: rgb("#6B6B6B"),
    )
      + theme
  )

  // --- Text sizes ---
  let ts = (
    (
      header-name: 32pt,
      header-headline: 14pt,
      header-location: 9pt,
      header-tags: 10pt,
      section-title: 11.5pt,
      body: 10pt,
      sidebar: 10pt,
      entry-text: 10pt,
      entry-highlight: 9.8pt,
      entry-bullet-icon: 7pt,
      entry-date: 8pt,
      entry-location: 8pt,
      publication-doi: 8pt,
      summary: 9.6pt,
    )
      + text-size
  )

  // --- Font families ---
  let ff = (
    (
      header-name: "IBM Plex Sans",
      header-headline: "IBM Plex Sans",
      header-location: "IBM Plex Sans",
      header-tags: "IBM Plex Sans",
      section-title: "IBM Plex Sans",
      body: "IBM Plex Sans",
      entry-text: "IBM Plex Sans",
      entry-highlight: "IBM Plex Sans",
      summary: "IBM Plex Sans",
    )
      + font-family
  )

  // --- Font weights ---
  let fw = (
    (
      body: "light",
      header-name: "bold",
      header-headline: "regular",
      header-location: "regular",
      section-title: "bold",
      header-tags: "bold",
      subsection-title: "bold",
      skill-group: "bold",
      entry-title: "bold",
      entry-position: "regular",
      entry-date: "regular",
      entry-location: "regular",
      entry-highlight: "light",
      entry-highlight-bold: "medium",
      entry-bullet-icon: "regular",
      contact: "light",
      summary: "regular",
    )
      + font-weight
  )

  // --- Gaps ---
  let gap = (
    sidebar-section-above: 15pt,
    sidebar-section-below: 12pt,
    sidebar-contact-between-items: -6pt,
    sidebar-skill-between-items: 4pt,
    sidebar-values-between-items: -5pt,
    sidebar-hobbies-between-items: -5pt,
    sidebar-publication-between-items: 5pt,
    main-section-above: 10pt,
    main-section-below: 10pt,
    main-entry-above: 5pt,
    main-entry-below: 12pt,
    main-entry-title-to-date: -4pt,
    main-entry-date-to-location: -3pt,
    main-entry-highlights-above: 15pt,
    main-entry-highlights-indent: 2mm,
    subsection-above: 15pt,
    subsection-below: 13pt,
    subsection-entry-below: 5pt,
    header-name-below: 0pt,
    header-headline-below: -2pt,
    header-to-content: 8pt,
    header-tags-stack: 0.35em,
    column-gutter: 0.5cm,
    section-indent: 2.5mm,
    icon-to-text: 0.5em,
    icon-to-text-tight: 0.2em,
    icon-to-text-tiny: 0.25em,
  )

  // --- Timeline ---
  let tl = (
    dot-size: 7pt,
    dot-color: rgb("#B0B0B0"),
    line-width: 1.3pt,
    line-color: rgb("#F5F1ED"),
    dot-to-content: 8pt,
    last-dot-gap: 3.5pt,
  )

  // --- Badge ---
  let badge = (inset: 3pt, radius: 3pt)

  // --- Layout ---
  let layout = (
    margin-left: 0.4in,
    margin-right: 0.4in,
    margin-top: 0.4in,
    margin-bottom: 0.4in,
    sidebar-width: 30%,
    sidebar-left-pad: 0pt,
    sidebar-right-pad: 6pt,
  )

  // --- Computed layout ---
  let page-width = 8.5in
  let content-width = page-width - layout.margin-left - layout.margin-right
  let sidebar-absolute = content-width * layout.sidebar-width
  let sidebar-bg-width = (
    layout.margin-left + sidebar-absolute + gap.column-gutter / 2
  )

  // --- Per-section style overrides ---
  let text-style = (:)
  let text-fill = (summary: t.summary)

  // --- Utilities ---
  let section-text(section) = body => {
    set text(
      font: ff.at(section, default: ff.body),
      weight: fw.at(section, default: fw.body),
      size: ts.at(section, default: ts.body),
      style: text-style.at(section, default: "normal"),
      fill: text-fill.at(section, default: t.primary),
    )
    body
  }

  let parse-markup(str) = {
    let parts = ()
    let chars = str.clusters()
    let i = 0
    let current = ""
    while i < chars.len() {
      let char = chars.at(i)
      if char == "*" {
        if current != "" {
          parts.push(current)
          current = ""
        }
        i += 1
        let bold-text = ""
        while i < chars.len() and chars.at(i) != "*" {
          bold-text += chars.at(i)
          i += 1
        }
        if i < chars.len() {
          parts.push(text(weight: fw.entry-highlight-bold, bold-text))
          i += 1
        }
      } else if char == "_" {
        if current != "" {
          parts.push(current)
          current = ""
        }
        i += 1
        let italic-text = ""
        while i < chars.len() and chars.at(i) != "_" {
          italic-text += chars.at(i)
          i += 1
        }
        if i < chars.len() {
          parts.push(emph(italic-text))
          i += 1
        }
      } else {
        current += char
        i += 1
      }
    }
    if current != "" { parts.push(current) }
    parts.join()
  }

  let format-date(start, end) = {
    let fmt(date) = {
      if date == none { return "" }
      if date == "present" { return "Present" }
      let s = str(date)
      if s.len() == 7 {
        let parts = s.split("-")
        month-names.at(int(parts.at(1)) - 1) + " " + parts.at(0)
      } else { s }
    }
    let s = fmt(start)
    let e = fmt(end)
    if s != "" and e != "" { s + date-separator + e } else if s != "" {
      s
    } else if (
      e != ""
    ) { e } else { "" }
  }

  // --- Components ---
  let icon-list(icon, items, spacing: 0pt) = {
    set par(justify: true)
    for (i, item) in items.enumerate() {
      grid(
        columns: (auto, 1fr),
        column-gutter: gap.icon-to-text,
        text(
          size: ts.entry-bullet-icon,
          weight: fw.entry-bullet-icon,
          fa-icon(icon),
        ),
        text(
          font: ff.entry-highlight,
          size: ts.entry-highlight,
          weight: fw.entry-highlight,
          parse-markup(item),
        ),
      )
      if i < items.len() - 1 { v(spacing) }
    }
  }

  let sidebar-section(icon, title, body) = {
    block(above: gap.sidebar-section-above, below: gap.sidebar-section-below)[
      #text(
        font: ff.section-title,
        size: ts.section-title,
        weight: fw.section-title,
        fill: t.secondary,
      )[
        #fa-icon(icon) #title
      ]
    ]
    block(above: 0pt, below: gap.sidebar-section-above, body)
  }

  let main-section(icon, title, body) = {
    block(above: gap.main-section-above, below: 0pt)[
      #h(gap.section-indent)
      #text(
        font: ff.section-title,
        size: ts.section-title,
        weight: fw.section-title,
        fill: t.secondary,
      )[
        #fa-icon(icon) #title
      ]
    ]
    v(gap.main-section-below)
    block(above: 0pt, below: gap.main-section-below, body)
  }

  let subsection(icon, title, body) = {
    block(above: gap.subsection-above, below: gap.subsection-below)[
      #text(weight: fw.subsection-title, fill: t.primary)[
        #h(gap.section-indent)
        #fa-icon(icon)
        #h(gap.icon-to-text)
        #title
      ]
      #v(gap.subsection-below)
      #body
    ]
  }

  let tag-badge(label) = box(
    fill: t.secondary,
    inset: badge.inset,
    radius: badge.radius,
    text(
      fill: white,
      font: ff.header-tags,
      size: ts.header-tags,
      weight: fw.header-tags,
      label,
    ),
  )

  let text-block(section, content) = {
    pad(left: gap.section-indent)[
      #set par(justify: true, leading: 0.65em)
      #show: section-text(section)
      #content
    ]
  }

  let entry(
    title,
    date,
    subtitle: none,
    location: none,
    summary: none,
    highlights: (),
    show-tl: false,
    is-first: false,
    is-last: false,
  ) = {
    let entry-inner = {
      v(gap.main-entry-above)
      grid(
        columns: (1fr, auto),
        [
          #text(
            font: ff.entry-text,
            size: ts.entry-text,
            weight: fw.entry-title,
            title,
          )#if (
            subtitle != none
          ) [, #text(font: ff.entry-text, size: ts.entry-text, weight: fw.entry-position, subtitle)]
          #if summary != none [
            #v(gap.main-entry-title-to-date)
            #text(
              font: ff.entry-text,
              size: ts.entry-text,
              fill: t.accent,
              summary,
            )
          ]
        ],
        [
          #align(right)[
            #text(
              font: ff.entry-text,
              size: ts.entry-date,
              weight: fw.entry-date,
              fill: t.accent,
              date,
            )
            #if location != none [
              #v(gap.main-entry-date-to-location)
              #text(
                font: ff.entry-text,
                size: ts.entry-location,
                weight: fw.entry-location,
                fill: t.accent,
                location,
              )
            ]
          ]
        ],
      )
      if highlights.len() > 0 {
        pad(left: gap.main-entry-highlights-indent)[
          #block(above: gap.main-entry-highlights-above)[
            #icon-list(bullet-icon, highlights)
          ]
        ]
      }
    }

    if show-tl {
      pad(left: gap.section-indent + tl.dot-size / 2 - tl.line-width / 2)[
        #grid(
          columns: (tl.line-width, 1fr),
          column-gutter: tl.dot-size / 2
            - tl.line-width / 2
            + tl.dot-to-content,
          grid.cell(fill: tl.line-color)[
            #let dot-y = gap.main-entry-above + 1pt
            #place(center + top, dy: dot-y)[
              #circle(radius: tl.dot-size / 2, fill: tl.dot-color, stroke: none)
            ]
            #if is-first {
              place(center + top)[
                #rect(width: tl.line-width + 2pt, height: dot-y, fill: white)
              ]
            }
            #if is-last {
              place(
                center + top,
                dy: dot-y + tl.dot-size / 2 + tl.last-dot-gap,
              )[
                #rect(width: tl.line-width + 2pt, height: 200pt, fill: white)
              ]
            }
          ],
          {
            entry-inner
            v(gap.main-entry-below)
          },
        )
      ]
    } else {
      pad(left: gap.section-indent)[
        #entry-inner
        #v(gap.main-entry-below)
      ]
    }
  }

  let list-entry(title, date, description: none, show-bullet: false) = {
    let bullet-offset = if show-bullet {
      ts.entry-bullet-icon + gap.icon-to-text
    } else { 0pt }
    pad(left: gap.section-indent)[
      #block(above: 0pt, below: gap.subsection-entry-below)[
        #pad(left: bullet-offset)[
          #if show-bullet {
            place(dx: -bullet-offset)[
              #text(
                size: ts.entry-bullet-icon,
                weight: fw.entry-bullet-icon,
                fa-icon(bullet-icon),
              )
            ]
          }
          #grid(
            columns: (1fr, auto),
            text(weight: "regular", size: ts.entry-text, title),
            text(size: ts.entry-date, weight: fw.entry-date, date),
          )
          #v(-5pt)
          #if description != none and description != "" {
            text(style: "italic", size: ts.entry-text, description)
          }
          #v(3pt)
        ]
      ]
    ]
  }

  // --- Section titles ---
  let st = (
    (
      contact: "CONTACT",
      skills: "SKILLS",
      values: "VALUES",
      hobbies: "HOBBIES",
      references: "REFERENCES",
      publications: "PUBLICATIONS",
      summary: "SUMMARY",
      motivation: "MOTIVATION",
      experience: "EXPERIENCE",
      education: "EDUCATION",
      awards: "HONORS & AWARDS",
      courses: "COURSES",
    )
      + section-titles
  )

  // --- Section icons ---
  let si = (
    (
      contact: "address-card",
      skills: "gears",
      values: "seedling",
      hobbies: "mug-hot",
      references: "user-check",
      publications: "chart-line",
      summary: "user",
      motivation: "lightbulb",
      experience: "suitcase",
      education: "graduation-cap",
      awards: "trophy",
      courses: "chalkboard-teacher",
    )
      + section-icons
  )

  // --- Skill icon defaults ---
  let ski = (
    (
      "Domain Knowledge": "brain",
      "Programming": "terminal",
      "DevOps & Cloud": "server",
      "Specialized Software": "cogs",
      "Soft Skills": "handshake-angle",
      "Languages": "language",
    )
      + skill-icons
  )

  // --- Sidebar section renderers ---
  let sidebar-renderers = (
    photo: () => {
      if photo != none {
        let sidebar-content-width = (
          sidebar-absolute - layout.sidebar-left-pad - layout.sidebar-right-pad
        )
        let d = sidebar-content-width * photo-size
        pad(top: 0pt, bottom: gap.sidebar-section-below)[
          #align(center)[
            #box(width: d, height: d, clip: true, radius: 50%, photo)
          ]
        ]
      }
    },
    contact: () => sidebar-section(si.contact, st.contact)[
      #show: section-text("contact")
      #show link: set text(fill: t.primary)
      #if phone != none [
        #fa-icon("phone") #h(gap.icon-to-text-tight) #phone \
        #v(gap.sidebar-contact-between-items)
      ]
      #if email != none [
        #fa-icon("envelope") #h(gap.icon-to-text-tight) #link(
          "mailto:" + email,
        )[#email] \
        #v(gap.sidebar-contact-between-items)
      ]
      #if profiles != none {
        for profile in profiles {
          let cfg = profiles-config.at(profile.network, default: none)
          if cfg != none [
            #fa-icon(cfg.icon) #h(gap.icon-to-text-tight) #link(
              cfg.url-base + profile.username,
            )[#profile.username]
            #h(gap.icon-to-text)
          ]
        }
      }
      #if address != none [
        \ #v(-4pt)
        #box(grid(
          columns: (auto, 1fr),
          column-gutter: gap.icon-to-text,
          fa-icon(address-icon),
          if type(address) == array { address.join(linebreak()) } else {
            address
          },
        ))
      ]
    ],
    skills: () => {
      if skills != none {
        sidebar-section(si.skills, st.skills)[
          #show: section-text("skills")
          #for skill in skills [
            #text(weight: fw.skill-group)[
              #let icon = ski.at(skill.group, default: none)
              #if icon != none [
                #fa-icon(icon) #h(gap.icon-to-text) #skill.group
              ] else [
                #skill.group
              ]
            ] \
            #v(0pt)
            #if type(skill.items) == array [
              #skill.items.join(linebreak())
            ] else [
              #skill.items
            ] \
            #v(gap.sidebar-skill-between-items)
          ]
        ]
      }
    },
    values: () => {
      if values != none {
        sidebar-section(si.values, st.values)[
          #show: section-text("values")
          #icon-list(
            bullet-icon,
            values,
            spacing: gap.sidebar-values-between-items,
          )
        ]
      }
    },
    hobbies: () => {
      if hobbies != none [
        #block(
          above: gap.sidebar-section-above,
          below: gap.sidebar-section-below,
        )[
          #text(
            font: ff.section-title,
            size: ts.section-title,
            weight: fw.section-title,
            fill: t.secondary,
          )[
            #fa-icon(si.hobbies) #st.hobbies
          ]
        ]
        #block(above: 0pt, below: gap.sidebar-section-above)[
          #show: section-text("hobbies")
          #icon-list(
            bullet-icon,
            hobbies,
            spacing: gap.sidebar-hobbies-between-items,
          )
        ]
      ]
    },
    references: () => {
      if references != none {
        sidebar-section(si.references, st.references)[
          #show: section-text("references")
          #if type(references) == str [
            #references
          ] else [
            #icon-list(
              bullet-icon,
              references,
              spacing: gap.sidebar-values-between-items,
            )
          ]
        ]
      }
    },
    publications: () => {
      if publications != none {
        sidebar-section(si.publications, st.publications)[
          #show: section-text("publications")
          #for pub in publications [
            #pub.title
            #if pub.at("doi", default: none) != none [
              #linebreak()
              #text(size: ts.publication-doi)[
                #link("https://doi.org/" + pub.doi)[
                  #fa-icon(doi-icon) #h(gap.icon-to-text-tiny) doi:#pub.doi
                ]
              ]
            ]
            #v(gap.sidebar-publication-between-items)
          ]
        ]
      }
    },
  )

  // --- Main column section renderers ---
  let main-renderers = (
    summary: () => {
      if summary != none {
        main-section(si.summary, st.summary)[
          #text-block("summary", summary)
        ]
      }
    },
    motivation: () => {
      if motivation != none {
        main-section(si.motivation, st.motivation)[
          #text-block("motivation", motivation)
        ]
      }
    },
    experience: () => {
      if experience != none {
        main-section(si.experience, st.experience)[
          #show: section-text("experience")
          #stack(spacing: 0pt, ..experience
            .enumerate()
            .map(((i, exp)) => entry(
              exp.company,
              format-date(exp.start_date, exp.end_date),
              subtitle: exp.at("position", default: none),
              location: exp.at("location", default: none),
              summary: exp.at("summary", default: none),
              highlights: if exp.at("highlights", default: none) != none {
                exp.highlights
              } else { () },
              show-tl: show-timeline,
              is-first: i == 0,
              is-last: i == experience.len() - 1,
            )))
        ]
      }
    },
    education: () => {
      if education != none {
        main-section(si.education, st.education)[
          #show: section-text("education")
          #stack(spacing: 0pt, ..education
            .enumerate()
            .map(((i, edu)) => entry(
              edu.company,
              format-date(edu.start_date, edu.end_date),
              subtitle: edu.at("position", default: none),
              location: edu.at("location", default: none),
              summary: edu.at("summary", default: none),
              highlights: if edu.at("highlights", default: none) != none {
                edu.highlights
              } else { () },
              show-tl: show-timeline,
              is-first: i == 0,
              is-last: i == education.len() - 1,
            )))
        ]
      }
    },
    awards: () => {
      if awards != none {
        main-section(si.awards, st.awards)[
          #show: section-text("awards")
          #for award in awards {
            let date-str = if award.at("date", default: none) != none {
              format-date(award.date, none)
            } else {
              format-date(award.start_date, award.end_date)
            }
            list-entry(
              award.name,
              date-str,
              description: if award.at("summary", default: none) != none {
                parse-markup(award.summary)
              },
              show-bullet: true,
            )
          }
        ]
      }
    },
    courses: () => {
      if courses != none {
        main-section(si.courses, st.courses)[
          #show: section-text("courses")
          #for course in courses {
            let date-str = if course.at("date", default: none) != none {
              format-date(course.date, none)
            } else {
              format-date(course.start_date, course.end_date)
            }
            list-entry(
              course.name,
              date-str,
              description: if course.at("summary", default: none) != none {
                course.summary
              },
              show-bullet: true,
            )
          }
        ]
      }
    },
  )

  // --- Sidebar ---
  let build-sidebar() = [
    #set text(size: ts.sidebar)
    #set par(justify: justify-sidebar)
    #pad(left: layout.sidebar-left-pad, right: layout.sidebar-right-pad)[
      #for section-name in sidebar-sections {
        let render = sidebar-renderers.at(section-name, default: none)
        if render != none { render() }
      }
    ]
  ]

  // --- Main column ---
  let build-main() = [
    // HEADER
    #grid(
      columns: (1fr, auto),
      column-gutter: gap.icon-to-text,
      [
        #h(gap.section-indent - 0.5mm)
        #text(
          font: ff.header-name,
          size: ts.header-name,
          weight: fw.header-name,
          fill: t.primary,
        )[#name]
        #v(gap.header-name-below)
        #pad(left: gap.section-indent, right: 0pt)[
          #text(
            font: ff.header-headline,
            size: ts.header-headline,
            weight: fw.header-headline,
            fill: t.accent,
          )[
            #if headline != none { headline.replace("*", "") }
          ]
        ]
        #v(gap.header-headline-below)
        #h(gap.section-indent)
        #text(
          font: ff.header-location,
          size: ts.header-location,
          weight: fw.header-location,
        )[#if location != none { location }]
      ],
      [
        #if keywords != none and keywords.len() > 0 {
          v(0.3em)
          align(right)[
            #stack(
              dir: ttb,
              spacing: gap.header-tags-stack,
              ..keywords.map(tag => tag-badge(tag)),
            )
          ]
        }
      ],
    )

    #v(gap.header-to-content)

    #for section-name in main-sections {
      let render = main-renderers.at(section-name, default: none)
      if render != none { render() }
    }
  ]

  // --- Page setup ---
  set page(
    paper: "us-letter",
    margin: (
      left: layout.margin-left,
      right: layout.margin-right,
      top: layout.margin-top,
      bottom: layout.margin-bottom,
    ),
    background: place(top + left, rect(
      width: sidebar-bg-width,
      height: 100% + layout.margin-top + layout.margin-bottom,
      fill: t.sidebar-bg,
    )),
  )
  set text(font: ff.body, size: ts.body, weight: fw.body)
  set par(justify: false, leading: 0.65em)
  show link: set text(fill: t.links)

  // --- Assembly ---
  grid(
    columns: (layout.sidebar-width, 1fr),
    column-gutter: gap.column-gutter,
    build-sidebar(), build-main(),
  )
  body
}
