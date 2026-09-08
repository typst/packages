#import "@preview/fontawesome:0.6.2": *

// Per-locale defaults: section-title overrides (only the keys that differ from
// the English defaults) and month abbreviations. Add a locale by adding a key.
#let _locales = (
  fr: (
    titles: (
      skills: "COMPÉTENCES",
      values: "VALEURS",
      hobbies: "LOISIRS",
      references: "RÉFÉRENCES",
      summary: "RÉSUMÉ",
      experience: "EXPÉRIENCE",
      education: "FORMATION",
      awards: "DISTINCTIONS",
      volunteering: "ENGAGEMENTS",
      courses: "FORMATIONS",
    ),
    months: (
      "jan.", "fév.", "mars", "avr.", "mai", "juin",
      "juil.", "août", "sep.", "oct.", "nov.", "déc.",
    ),
  ),
)

/// A two-column CV template matching the polycv design.
///
/// - name (str): Full name displayed in the header.
/// - headline (str, none): Tagline shown below the name.
/// - location (str, none): Location shown below the headline.
/// - keywords (array, none): Tag badges shown in the header.
/// - keywords-lines (int, auto): Number of lines the keyword badges are
///   distributed over, right-aligned like a tag cloud (auto = one per line).
/// - email (str, none): Email address.
/// - phone (str, none): Phone number.
/// - address (str, array, none): Physical address (string or array of lines).
/// - profiles (array, none): Social profiles. Each entry: (network, username).
/// - summary (str, none): Summary section text.
/// - motivation (str, none): Motivation section text.
/// - experience (array, none): Experience entries.
/// - education (array, none): Education entries.
/// - awards (array, none): Award entries.
/// - volunteering (array, none): Volunteering / community involvement entries.
/// - courses (array, none): Course entries.
/// - skills (dictionary, none): Skill groups keyed by a stable name; each value
///   is (title: default key, icon: none, items: string or array).
/// - skill-order (array, none): Group keys to show, in order (omit key = hide).
/// - values (array, none): Values list.
/// - hobbies (array, none): Hobbies list.
/// - references (str, array, none): References text or list.
/// - publications (array, none): Publication entries.
/// - theme (dictionary): Override any theme colour. Keys: primary, secondary,
///   accent, links, sidebar-bg, header-bg, header-rule, sidebar-rule,
///   summary. header-bg fills the header band (white by default; none for
///   fully transparent). With header-band layouts the sidebar tint is
///   dropped; header-rule draws a horizontal rule under the band and
///   sidebar-rule a vertical rule between the columns (both none by
///   default).
/// - text-size (dictionary): Override any font size.
/// - font-family (dictionary): Override any font family.
/// - font-weight (dictionary): Override any font weight.
/// - show-timeline (bool): Toggle the dots + vertical line on/off for
///   experience/education entries.
/// - entry-inline-meta (bool): For experience/education entries, put
///   company, location and dates inline as the title, then the position on
///   the next line (default: company/position inline, date/location right).
/// - justify-sidebar (bool): Toggle sidebar text justification.
/// - section-icons (dictionary): Override any section FontAwesome icon name.
///   Keys match section keys. Defaults e.g. experience: "suitcase".
/// - bullet-icon (str): FontAwesome icon name used for all list bullets.
/// - address-icon (str): FontAwesome icon name used for the address field.
/// - doi-icon (str): FontAwesome icon name used for DOI links in publications.
/// - locale (str): "en" or "fr". Sets the default section titles and month
///   names; both stay overridable via section-titles / month-names.
/// - month-names (array or auto): 12 month abbreviations; auto follows `locale`.
/// - date-separator (str): String placed between start and end dates.
/// - profiles-config (dictionary): Map of network name to (icon, url-base) dict.
///   Add any network: (Mastodon: (icon: "mastodon", url-base: "https://mastodon.social/@")).
/// - sidebar-sections (array): Ordered list of sidebar section keys to render.
///   Valid keys: "contact", "skills", "values", "hobbies", "references", "publications".
/// - main-sections (array): Ordered list of main column section keys to render.
///   Valid keys: "summary", "motivation", "experience", "education", "awards", "volunteering", "courses".
/// - section-titles (dictionary): Override any section display title.
///   Keys match section keys above. Defaults are all-caps e.g. "HONORS & AWARDS".
/// - photo (content, none): Profile photo, e.g. image("assets/avatar.png").
///   Rendered as a circle at the top of the sidebar.
/// - photo-size (ratio): Diameter of the circular photo as a fraction of sidebar width.
/// - show-header-band (bool): Full-width header band layout; the photo (if
///   any) is shown as a circle at the left of the band.
/// - header-band-summary (bool): With show-header-band or ats-split, render
///   the summary inside the header instead of the main column.
/// - header-band-contact (bool): With show-header-band, show the contact
///   line in the band (true) or keep contact in the sidebar (false).
/// - body (content): Optional content appended after the CV.
#let cv(
  name: "",
  headline: none,
  location: none,
  keywords: none,
  keywords-lines: auto,
  email: none,
  phone: none,
  address: none,
  profiles: none,
  summary: none,
  motivation: none,
  experience: none,
  education: none,
  awards: none,
  volunteering: none,
  courses: none,
  skills: none,
  skill-order: none,
  values: none,
  hobbies: none,
  references: none,
  publications: none,
  theme: (:),
  text-size: (:),
  font-family: (:),
  font-weight: (:),
  show-timeline: true,
  entry-inline-meta: false,
  justify-sidebar: false,
  photo: none,
  photo-size: 70%,
  section-icons: (:),
  bullet-icon: "angle-right",
  address-icon: "location-dot",
  doi-icon: "external-link",
  locale: "en",
  month-names: auto,
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
    "volunteering",
    "courses",
  ),
  section-titles: (:),
  show-header-band: false,
  header-band-summary: false,
  header-band-contact: true,
  ats-split: false,
  body,
) = {
  // Month names / section titles come from `locale` (see `_locales`) unless the
  // user passed explicit overrides.
  let month-names = if month-names == auto {
    _locales.at(locale, default: (:)).at(
      "months",
      default: ("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"),
    )
  } else { month-names }

  // --- Default theme ---
  let t = (
    (
      primary: rgb("#000000"),
      secondary: rgb("#0D47A1"),
      accent: rgb("#000000"),
      links: rgb("#1565C0"),
      sidebar-bg: rgb("#F5F1ED"),
      header-bg: white,
      header-rule: none,
      sidebar-rule: none,
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
    ats-header-to-content: 4pt,
    ats-photo-below: 4pt,
    header-band-padding-y: 14pt,
    header-band-rule: 2pt,
    sidebar-rule: 2pt,
    header-band-photo-gap: 24pt,
    header-band-name-below: 12pt,
    header-band-headline-below: 20pt,
    header-tags-stack: 0.35em,
    header-tags-gap: 0.35em,
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
    ats-photo-scale: 75%,
  )

  // --- Computed layout ---
  let page-width = 8.5in
  let content-width = page-width - layout.margin-left - layout.margin-right
  let sidebar-absolute = content-width * layout.sidebar-width
  let sidebar-bg-width = (
    layout.margin-left + sidebar-absolute + gap.column-gutter / 2
  )

  // --- Per-section style overrides ---
  let text-fill = (summary: t.summary)

  // --- Utilities ---
  let section-text(section) = body => {
    set text(
      font: ff.at(section, default: ff.body),
      weight: fw.at(section, default: fw.body),
      size: ts.at(section, default: ts.body),
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

  // Right-aligned badge stack; keywords-lines distributes badges over
  // that many lines (tag-cloud style), auto keeps one badge per line.
  let build-tag-stack() = {
    let n = keywords.len()
    let lines = if keywords-lines == auto { n } else {
      calc.max(1, calc.min(keywords-lines, n))
    }
    let rows = keywords.chunks(calc.ceil(n / lines))
    align(right)[
      #stack(
        dir: ttb,
        spacing: gap.header-tags-stack,
        ..rows.map(row => row.map(tag-badge).join(h(gap.header-tags-gap))),
      )
    ]
  }

  // Inline contact line with FA icons, used in header-band and ats-split
  let build-contact-line() = {
    let items = ()
    if location != none {
      items.push([
        #text(size: ts.header-location * 0.9)[#fa-icon(address-icon)]
        #h(gap.icon-to-text-tiny)
        #text(
          font: ff.header-location,
          size: ts.header-location,
          weight: fw.header-location,
        )[#location]
      ])
    }
    if email != none {
      items.push([
        #text(size: ts.header-location * 0.9)[#fa-icon("envelope")]
        #h(gap.icon-to-text-tiny)
        #link("mailto:" + email)[#text(size: ts.header-location)[#email]]
      ])
    }
    if phone != none {
      items.push([
        #text(size: ts.header-location * 0.9)[#fa-icon("phone")]
        #h(gap.icon-to-text-tiny)
        #text(size: ts.header-location)[#phone]
      ])
    }
    if profiles != none {
      for profile in profiles {
        let cfg = profiles-config.at(profile.network, default: none)
        if cfg != none {
          items.push([
            #text(size: ts.header-location * 0.9)[#fa-icon(cfg.icon)]
            #h(gap.icon-to-text-tiny)
            #link(cfg.url-base + profile.username)[
              #text(size: ts.header-location)[#profile.username]
            ]
          ])
        }
      }
    }
    if items.len() > 0 [
      #show link: set text(fill: t.primary)
      #v(-2pt)
      #text(size: ts.header-location, fill: t.summary)[
        // box() keeps each icon+value pair unbreakable; the line only
        // wraps between items.
        #items.map(box).join([#h(0.4em) · #h(0.4em)])
      ]
    ]
  }

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
    // Optional summary line, shared by both entry layouts.
    let entry-summary = if summary != none {
      [
        #v(gap.main-entry-title-to-date)
        #text(font: ff.entry-text, size: ts.entry-text, fill: t.accent, summary)
      ]
    }

    let entry-header = if entry-inline-meta {
      // Title line: company (left) with location · dates right-aligned;
      // the position then follows on its own line.
      let meta-parts = ()
      if location != none {
        meta-parts.push(text(
          font: ff.entry-text,
          size: ts.entry-location,
          weight: fw.entry-location,
          fill: t.accent,
          location,
        ))
      }
      if date != none and date != "" {
        meta-parts.push(text(
          font: ff.entry-text,
          size: ts.entry-date,
          weight: fw.entry-date,
          fill: t.accent,
          date,
        ))
      }
      [
        #grid(
          columns: (1fr, auto),
          column-gutter: gap.icon-to-text,
          align: (left + horizon, right + horizon),
          text(
            font: ff.entry-text,
            size: ts.entry-text,
            weight: fw.entry-title,
            title,
          ),
          meta-parts.join(text(fill: t.accent)[#h(0.4em)·#h(0.4em)]),
        )
        #if subtitle != none [
          #v(gap.main-entry-date-to-location)
          #text(
            font: ff.entry-text,
            size: ts.entry-text,
            weight: fw.entry-position,
            subtitle,
          )
        ]
        #entry-summary
      ]
    } else {
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
          #entry-summary
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
    }

    let entry-inner = {
      v(gap.main-entry-above)
      entry-header
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

  // --- Section titles: English defaults, locale overrides (from _locales),
  // then any user section-titles on top. ---
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
      volunteering: "VOLUNTEERING",
      courses: "COURSES",
    )
      + _locales.at(locale, default: (:)).at("titles", default: (:))
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
      volunteering: "hand-holding-heart",
      courses: "chalkboard-teacher",
    )
      + section-icons
  )

  // --- Sidebar section renderers ---
  let sidebar-renderers = (
    // Compact education for the narrow sidebar: degree, institution,
    // location and dates stacked, without timeline or right-aligned grid.
    education: () => {
      if education != none {
        sidebar-section(si.education, st.education)[
          #show: section-text("education")
          #for edu in education [
            #text(weight: fw.skill-group)[
              #edu.at("degree", default: edu.at("company", default: ""))
            ] \
            #let inst = edu.at("summary", default: edu.at("institution", default: none))
            #if inst != none [ #inst \ ]
            #let loc = edu.at("location", default: none)
            #let d = format-date(edu.start_date, edu.end_date)
            #if loc != none or d != "" [
              #text(fill: t.accent)[
                #loc#if loc != none and d != "" [ · ]#d
              ]
            ]
            #v(gap.sidebar-skill-between-items)
          ]
        ]
      }
    },
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
        // Show the groups named in skill-order, or all of them (data order).
        let order = if skill-order != none { skill-order } else { skills.keys() }
        sidebar-section(si.skills, st.skills)[
          #show: section-text("skills")
          #for key in order [
            #let group = skills.at(key, default: none)
            #if group != none [
              #let title = group.at("title", default: key)
              #let icon = group.at("icon", default: none)
              #text(weight: fw.skill-group)[
                #if icon != none [
                  #fa-icon(icon) #h(gap.icon-to-text) #title
                ] else [
                  #title
                ]
              ] \
              #v(0pt)
              #if type(group.items) == array [
                #group.items.join(linebreak())
              ] else [
                #group.items
              ] \
              #v(gap.sidebar-skill-between-items)
            ]
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
      if hobbies != none {
        sidebar-section(si.hobbies, st.hobbies)[
          #show: section-text("hobbies")
          #icon-list(
            bullet-icon,
            hobbies,
            spacing: gap.sidebar-hobbies-between-items,
          )
        ]
      }
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

  // Shared renderer for experience/education timelines. Education entries
  // may use degree/institution as aliases for company/summary.
  let timeline-entries(entries) = stack(spacing: 0pt, ..entries
    .enumerate()
    .map(((i, e)) => entry(
      e.at("company", default: e.at("degree", default: "")),
      format-date(e.start_date, e.end_date),
      subtitle: e.at("position", default: none),
      location: e.at("location", default: none),
      summary: e.at("summary", default: e.at("institution", default: none)),
      highlights: if e.at("highlights", default: none) != none {
        e.highlights
      } else { () },
      show-tl: show-timeline,
      is-first: i == 0,
      is-last: i == entries.len() - 1,
    )))

  // Awards/volunteering/courses accept either a single date or a range.
  let flexible-date(e) = if e.at("date", default: none) != none {
    format-date(e.date, none)
  } else {
    format-date(e.start_date, e.end_date)
  }

  // Shared renderer for bulleted list sections (awards, volunteering, courses):
  // one entry per line with name, flexible date, and an optional description.
  let list-section(key, items) = {
    if items != none {
      main-section(si.at(key), st.at(key))[
        #show: section-text(key)
        #for e in items {
          list-entry(
            e.name,
            flexible-date(e),
            description: if e.at("summary", default: none) != none {
              parse-markup(e.summary)
            },
            show-bullet: true,
          )
        }
      ]
    }
  }

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
          #timeline-entries(experience)
        ]
      }
    },
    education: () => {
      if education != none {
        main-section(si.education, st.education)[
          #show: section-text("education")
          #timeline-entries(education)
        ]
      }
    },
    awards: () => list-section("awards", awards),
    volunteering: () => list-section("volunteering", volunteering),
    courses: () => list-section("courses", courses),
  )

  // --- Effective sidebar sections ---
  // Sections already shown in the header are excluded from the sidebar.
  let excluded-sections = if show-header-band {
    ("photo",) + if header-band-contact { ("contact",) } else { () }
  } else if ats-split {
    ("photo",)
  } else { () }
  let effective-sidebar-sections = sidebar-sections.filter(s => (
    s not in excluded-sections
  ))
  let effective-main-sections = if (
    (show-header-band or ats-split) and header-band-summary
  ) {
    main-sections.filter(s => s != "summary")
  } else { main-sections }

  // --- Header band (full-width, above grid, page 1 only) ---
  let build-header-band() = context {
    let with-photo = photo != none
    // Right side: (name + headline | tags) row, then the contact line
    // spanning the full remaining width so it never gets squeezed by the
    // tags column.
    let right-cell = [
      #set par(spacing: 0pt)
      #grid(
        columns: (1fr, auto),
        column-gutter: gap.icon-to-text,
        [
          #text(
            font: ff.header-name,
            size: ts.header-name,
            weight: fw.header-name,
            fill: t.primary,
          )[#name]
          #v(gap.header-band-name-below)
          #text(
            font: ff.header-headline,
            size: ts.header-headline,
            weight: fw.header-headline,
            fill: t.accent,
          )[#if headline != none { headline.replace("*", "") }]
        ],
        [
          #if keywords != none and keywords.len() > 0 {
            v(0.3em)
            build-tag-stack()
          }
        ],
      )
      #if header-band-summary and summary != none [
        #v(gap.header-band-headline-below)
        #set par(justify: true, leading: 0.65em)
        #show: section-text("summary")
        #summary
      ]
      #if header-band-contact [
        #v(gap.header-band-headline-below)
        #build-contact-line()
      ]
    ]
    // Photo diameter matches the measured height of the right side.
    // Two passes: its height depends on the width left over by the photo
    // itself, which is only known after a first guess.
    let photo-cell = if with-photo {
      let d0 = measure(block(width: content-width, right-cell)).height
      let d = measure(block(
        width: content-width - gap.header-band-photo-gap - d0,
        right-cell,
      )).height
      (
        align(horizon)[
          #box(width: d, height: d, clip: true, radius: 50%, photo)
        ],
      )
    } else { () }
    // The rule is the band's last element so the backing rect (measured
    // from the band) ends exactly at the rule: the vertical sidebar rule
    // then starts right under it, forming a clean T junction.
    let band = block(
      width: content-width,
      fill: none,
      stroke: none,
    )[
      #set block(spacing: 0pt)
      #grid(
        columns: if with-photo { (auto, 1fr) } else { (1fr,) },
        column-gutter: gap.header-band-photo-gap,
        ..photo-cell,
        right-cell,
      )
      #v(gap.header-band-padding-y)
      #if t.header-rule != none {
        line(length: 100%, stroke: gap.header-band-rule + t.header-rule)
      }
    ]
    let h = measure(band).height
    [
      // The rect also hides the sidebar strip behind the band; with
      // header-bg: none the strip shows through (fully transparent band).
      #if t.header-bg != none {
        place(
          top + left,
          dx: -layout.margin-left,
          dy: -layout.margin-top,
          rect(
            width: page-width,
            height: layout.margin-top + h,
            fill: t.header-bg,
            stroke: none,
          ),
        )
      }
      #band
      #v(gap.header-to-content)
    ]
  }

  // --- ATS split header (photo | name+headline+contacts+keywords, same column proportions as content) ---
  let build-ats-header() = context {
    // Right column: name, headline, keywords, and optionally the summary.
    let right-content = [
      #grid(
        columns: (1fr, auto),
        column-gutter: gap.icon-to-text,
        [
          // Name shares the same left edge as headline and summary.
          #pad(left: gap.section-indent, right: 0pt)[
            #text(
              font: ff.header-name,
              size: ts.header-name,
              weight: fw.header-name,
              fill: t.primary,
            )[#name]
          ]
          #v(gap.header-name-below)
          #pad(left: gap.section-indent, right: 0pt)[
            #text(
              font: ff.header-headline,
              size: ts.header-headline,
              weight: fw.header-headline,
              fill: t.accent,
            )[#if headline != none { headline.replace("*", "") }]
          ]
          #v(gap.header-headline-below)
        ],
        [
          #if keywords != none and keywords.len() > 0 {
            v(0.3em)
            build-tag-stack()
          }
        ],
      )
      #if header-band-summary and summary != none [
        #pad(left: gap.section-indent)[
          #set par(justify: true, leading: 0.65em)
          #show: section-text("summary")
          #summary
        ]
      ]
    ]
    // Photo grows with the header height (e.g. when the summary is shown),
    // floored at the default size and capped at the sidebar column width.
    let max-d = (
      sidebar-absolute - layout.sidebar-left-pad - layout.sidebar-right-pad
    )
    let default-d = max-d * photo-size * layout.ats-photo-scale
    let right-w = content-width * (100% - layout.sidebar-width) - gap.column-gutter
    let right-h = measure(block(width: right-w, right-content)).height
    let d = calc.min(calc.max(default-d, right-h), max-d)
    grid(
      columns: (layout.sidebar-width, 1fr),
      column-gutter: gap.column-gutter,
      // Left: photo (same padding as sidebar)
      pad(left: layout.sidebar-left-pad, right: layout.sidebar-right-pad)[
        #if photo != none {
          pad(top: 0pt, bottom: gap.ats-photo-below)[
            #align(center)[
              #box(width: d, height: d, clip: true, radius: 50%, photo)
            ]
          ]
        }
      ],
      // Right: name, headline, contacts, keywords (same structure as build-main header)
      [
        #right-content
        #v(gap.ats-header-to-content)
      ],
    )
  }

  // --- Sidebar ---
  let build-sidebar() = [
    #set text(size: ts.sidebar)
    #set par(justify: justify-sidebar)
    #pad(left: layout.sidebar-left-pad, right: layout.sidebar-right-pad)[
      #for section-name in effective-sidebar-sections {
        let render = sidebar-renderers.at(
          section-name,
          default: main-renderers.at(section-name, default: none),
        )
        if render != none { render() }
      }
    ]
  ]

  // --- Main column ---
  let build-main() = [
    // HEADER (skipped when show-header-band or ats-split is active)
    #if not show-header-band and not ats-split [
    #grid(
      columns: (1fr, auto),
      column-gutter: gap.icon-to-text,
      [
        // Name shares the same left edge as headline, location and sections.
        #pad(left: gap.section-indent, right: 0pt)[
          #text(
            font: ff.header-name,
            size: ts.header-name,
            weight: fw.header-name,
            fill: t.primary,
          )[#name]
        ]
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
          build-tag-stack()
        }
      ],
    )

    #v(gap.header-to-content)
    ] // end if not show-header-band

    #for section-name in effective-main-sections {
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
    background: if show-header-band {
      // Header-band layouts drop the sidebar tint. An optional vertical
      // rule between the columns can be enabled via theme.sidebar-rule;
      // on page 1 the header's backing rect covers its top part.
      if t.sidebar-rule != none {
        place(top + left, dx: sidebar-bg-width - gap.sidebar-rule / 2, rect(
          width: gap.sidebar-rule,
          height: 100%,
          fill: t.sidebar-rule,
        ))
      }
    } else {
      place(top + left, rect(
        width: sidebar-bg-width,
        height: 100% + layout.margin-top + layout.margin-bottom,
        fill: t.sidebar-bg,
      ))
    },
  )
  set text(font: ff.body, size: ts.body, weight: fw.body)
  set par(justify: false, leading: 0.65em)
  show link: set text(fill: t.links)

  // --- Assembly ---
  if show-header-band { build-header-band() }
  if ats-split { build-ats-header() }
  grid(
    columns: (layout.sidebar-width, 1fr),
    column-gutter: gap.column-gutter,
    build-sidebar(), build-main(),
  )
  body
}
