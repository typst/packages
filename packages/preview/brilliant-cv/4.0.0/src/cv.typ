/*
 * Functions for the CV template
 */

#import "@preview/fontawesome:0.6.0": *
#import "./utils/injection.typ": _inject
#import "./utils/styles.typ": (
  _awesome-colors, _latin-font-list, _latin-header-font, _regular-colors,
  _resolve-accent-color, _set-accent-color, h-bar,
)

/// Metadata state to avoid passing metadata to every function
#let cv-metadata = state("cv-metadata", none)

/// Create header style functions
/// -> dictionary
#let _header-styles(
  header-font,
  regular-colors,
  accent-color,
  header-info-font-size,
) = (
  first-name: str => text(
    font: header-font,
    size: 32pt,
    weight: "light",
    fill: regular-colors.darkgray,
    str,
  ),
  last-name: str => text(font: header-font, size: 32pt, weight: "bold", str),
  info: str => text(size: header-info-font-size, fill: accent-color, str),
  quote: str => text(
    size: 10pt,
    weight: "medium",
    style: "italic",
    fill: accent-color,
    str,
  ),
)

/// Personal info icons mapping
/// -> dictionary
#let _personal-info-icons = (
  phone: fa-phone(),
  email: fa-envelope(),
  linkedin: fa-linkedin(),
  homepage: fa-pager(),
  github: fa-square-github(),
  gitlab: fa-gitlab(),
  orcid: fa-orcid(),
  researchgate: fa-researchgate(),
  location: fa-location-dot(),
  extraInfo: "",
)

/// Generate personal info section
/// -> content
#let _make-header-info(personal-info, icons, custom-icons) = {
  let n = 1
  for (k, v) in personal-info {
    // A dirty trick to add linebreaks with "linebreak" as key in personalInfo
    if k == "linebreak" {
      n = 0
      linebreak()
      continue
    }
    if k.contains("custom") {
      let awesome-icon = v.at("awesomeIcon", default: "")
      let text = v.at("text", default: "")
      let link-value = v.at("link", default: "")
      // Look up pre-loaded image from custom-icons dict (passed via cv.with())
      let icon = custom-icons.at(k, default: none)
      if icon != none {
        icon = box(width: 10pt, {
          set image(width: 100%)
          icon
        })
      } else if awesome-icon != "" {
        icon = fa-icon(awesome-icon)
      }
      box({
        icon
        h(5pt)
        if link-value != "" {
          link(link-value)[#text]
        } else {
          text
        }
      })
    } else if v != "" {
      box({
        // Adds icons
        icons.at(k)
        h(5pt)
        // Adds hyperlinks
        if k == "email" {
          link("mailto:" + v)[#v]
        } else if k == "linkedin" {
          link("https://www.linkedin.com/in/" + v)[#v]
        } else if k == "github" {
          link("https://github.com/" + v)[#v]
        } else if k == "gitlab" {
          link("https://gitlab.com/" + v)[#v]
        } else if k == "homepage" {
          link("https://" + v)[#v]
        } else if k == "orcid" {
          link("https://orcid.org/" + v)[#v]
        } else if k == "researchgate" {
          link("https://www.researchgate.net/profile/" + v)[#v]
        } else if k == "phone" {
          link("tel:" + v.replace(" ", ""))[#v]
        } else {
          v
        }
      })
    }
    // Adds hBar
    if n != personal-info.len() {
      h-bar()
    }
    n = n + 1
  }
}

/// Create header name section.
///
/// When `display-name` is non-none it is rendered as a single styled string
/// (in the `first-name` light style) and replaces the split first/last
/// presentation. When `display-name` is none, the conventional Latin
/// "first (light) + last (bold)" split is used.
/// -> content
#let _make-header-name-section(
  styles,
  display-name,
  first-name,
  last-name,
  personal-info,
  header-quote,
  custom-icons,
) = {
  table(
    columns: 1fr,
    inset: 0pt,
    stroke: none,
    row-gutter: 6mm,
    if display-name != none {
      (styles.first-name)(display-name)
    } else [#(styles.first-name)(first-name) #h(5pt) #(styles.last-name)(
        last-name,
      )],
    [#(styles.info)(_make-header-info(
      personal-info,
      _personal-info-icons,
      custom-icons,
    ))],
    ..if header-quote != none { ([#(styles.quote)(header-quote)],) },
  )
}

/// Create header photo section. When `profile-photo` is `none` the column
/// collapses to a fixed-height spacer regardless of `display-profile-photo`.
/// -> content
#let _make-header-photo-section(
  display-profile-photo,
  profile-photo,
  profile-photo-radius,
) = {
  set image(height: 3.6cm)
  if display-profile-photo and profile-photo != none {
    box(profile-photo, radius: profile-photo-radius, clip: true)
  } else {
    v(3.6cm)
  }
}

/// Create header table
/// -> content
#let _make-header(contents, columns, align) = {
  table(
    columns: columns,
    inset: 0pt,
    stroke: none,
    column-gutter: 15pt,
    align: align + horizon,
    ..contents,
  )
}

/// Insert the header section of the CV.
///
/// - metadata (array): the metadata read from the TOML file.
/// - profile-photo (content): the profile photo image.
/// - header-font (array): the font of the header.
/// - regular-colors (array): the regular colors of the CV.
/// - awesome-colors (array): the awesome colors of the CV.
/// - custom-icons (dictionary): pre-loaded image objects for custom personal info entries.
/// -> content
#let _cv-header(
  metadata,
  profile-photo,
  header-font,
  regular-colors,
  awesome-colors,
  custom-icons,
) = {
  // Parameters
  let header-alignment = eval(metadata.layout.header.header_align)
  // Schema validation (incl. v2 inject migration guard) happens at the
  // cv() / letter() entry point, so by the time we read inject here it's
  // already been verified to not contain v2 keys.
  let inject = metadata.at("inject", default: (:))
  let custom-ai-prompt-text = inject.at("custom_ai_prompt_text", default: none)
  let keywords = inject.at("injected_keywords_list", default: ())
  let personal-info = metadata.personal.info
  let first-name = metadata.personal.first_name
  let last-name = metadata.personal.last_name
  let header-quote = metadata.at("header_quote", default: none)
  let display-profile-photo = metadata.layout.header.display_profile_photo
  let profile-photo-radius = eval(metadata.layout.header.at(
    "profile_photo_radius",
    default: "50%",
  ))
  let header-info-font-size = eval(metadata.layout.header.at(
    "info_font_size",
    default: "10pt",
  ))
  let accent-color = _set-accent-color(_awesome-colors, metadata)

  // display_name overrides the Latin split (first light + last bold) with a
  // single styled string. Use this for CJK profiles or any profile where the
  // split feels wrong.
  let display-name = metadata.personal.at("display_name", default: none)

  // Injection
  _inject(
    custom-ai-prompt-text: custom-ai-prompt-text,
    keywords: keywords,
  )

  // Create styles
  let styles = _header-styles(
    header-font,
    regular-colors,
    accent-color,
    header-info-font-size,
  )

  // Create components
  let name-section = _make-header-name-section(
    styles,
    display-name,
    first-name,
    last-name,
    personal-info,
    header-quote,
    custom-icons,
  )

  let photo-section = _make-header-photo-section(
    display-profile-photo,
    profile-photo,
    profile-photo-radius,
  )

  // Render header
  if display-profile-photo and profile-photo != none {
    _make-header(
      (name-section, photo-section),
      (auto, 20%),
      header-alignment,
    )
  } else {
    _make-header(
      (name-section,),
      (auto,),
      header-alignment,
    )
  }
}

/// Insert the footer section of the CV.
///
/// - metadata (array): the metadata read from the TOML file.
/// -> content
#let _cv-footer(metadata) = {
  // Parameters
  let first-name = metadata.personal.first_name
  let last-name = metadata.personal.last_name
  let footer-text = metadata.at("cv_footer", default: "")
  let display-page-counter = metadata
    .layout
    .at("footer", default: {})
    .at("display_page_counter", default: false)
  let display-footer = metadata
    .layout
    .at("footer", default: {})
    .at("display_footer", default: true)

  if not display-footer {
    return none
  }

  // Styles
  let footer-style(str) = {
    text(size: 8pt, fill: rgb("#999999"), smallcaps(str))
  }

  if display-page-counter {
    table(
      columns: (1fr, 1fr, 1fr),
      inset: -5pt,
      stroke: none,
      align(left, footer-style([#first-name #last-name])),
      align(center, footer-style(footer-text)),
      align(right, footer-style(counter(page).display())),
    )
  } else {
    table(
      columns: (1fr, auto),
      inset: -5pt,
      stroke: none,
      footer-style([#first-name #last-name]), footer-style(footer-text),
    )
  }
}

/// Add the title of a section.
///
/// The visual treatment of the title is driven by `[layout.section]` in the
/// profile metadata. Three modes are supported:
///
/// - `"first-letters"` (default): the first `title_highlight_letters` characters
///   of the title are rendered in the accent color, the rest in black. This is
///   the conventional Latin-script appearance.
/// - `"full"`: the entire title is rendered in the accent color. Use this for
///   CJK / non-Latin scripts where splitting the first N codepoints feels
///   unnatural.
/// - `"none"`: the entire title is rendered in black, no accent highlighting.
///
/// Per-section overrides: pass `highlight` and/or `highlight_letters` to
/// override the metadata defaults for a single section.
///
/// - title (str): The title of the section.
/// - highlight (str): (optional) override `[layout.section].title_highlight`.
///   Accepts `"first-letters"`, `"full"`, or `"none"`.
/// - highlight_letters (int): (optional) override `[layout.section].title_highlight_letters`.
/// - color (color): (optional) override the accent color for this section.
/// - metadata (dictionary): (optional) the metadata read from the TOML file.
/// - awesome-colors (array): (optional) the awesome colors of the CV.
///
/// ```example
/// >>> #set text(font: "Source Sans 3")
/// #block(width: 300pt)[
///   #cv-section("Professional Experience", metadata: _metadata)
/// ]
/// ```
/// -> content
#let cv-section(
  title,
  highlight: none,
  highlight_letters: none,
  color: none,
  metadata: none,
  awesome-colors: _awesome-colors,
) = context {
  let metadata = if metadata != none { metadata } else { cv-metadata.get() }

  let section-cfg = metadata.layout.at("section", default: (:))
  let mode = if highlight != none {
    highlight
  } else {
    section-cfg.at("title_highlight", default: "first-letters")
  }
  let letters = if highlight_letters != none {
    highlight_letters
  } else {
    section-cfg.at("title_highlight_letters", default: 3)
  }

  let before-section-skip = eval(metadata.layout.at(
    "before_section_skip",
    default: "1pt",
  ))
  let accent-color = _resolve-accent-color(color, awesome-colors, metadata)

  let section-title-style(str, color: black) = {
    text(size: 16pt, weight: "bold", fill: color, str)
  }

  v(before-section-skip)
  block(
    sticky: true,
    [#if mode == "full" {
        section-title-style(title, color: accent-color)
      } else if mode == "none" {
        section-title-style(title, color: black)
      } else {
        // "first-letters" (default)
        let highlighted-text = title.slice(0, calc.min(letters, title.len()))
        let normal-text = title.slice(calc.min(letters, title.len()))
        section-title-style(highlighted-text, color: accent-color)
        section-title-style(normal-text, color: black)
      }
      #h(2pt)
      #box(width: 1fr, line(stroke: 0.9pt, length: 100%))],
  )
}

/// Prepare common entry parameters
/// -> dictionary
#let _prepare-entry-params(metadata, awesome-colors, color: none) = {
  // Common parameter calculations
  let accent-color = _resolve-accent-color(color, awesome-colors, metadata)
  let before-entry-skip = eval(metadata.layout.at(
    "before_entry_skip",
    default: 1pt,
  ))
  let before-entry-description-skip = eval(metadata.layout.at(
    "before_entry_description_skip",
    default: 1pt,
  ))
  // Default date column width. Profiles whose locale needs more room
  // (zh, fr, it, ...) should set [layout] date_width explicitly.
  let date-width = eval(metadata.layout.at("date_width", default: "3.6cm"))

  return (
    accent-color: accent-color,
    before-entry-skip: before-entry-skip,
    before-entry-description-skip: before-entry-description-skip,
    date-width: date-width,
    awesome-colors: awesome-colors,
  )
}

/// Create entry style functions
/// -> dictionary
#let _entry-styles(accent-color, before-entry-description-skip) = (
  a1: str => text(size: 10pt, weight: "bold", str),
  a2: str => align(right, text(
    weight: "medium",
    fill: accent-color,
    style: "oblique",
    str,
  )),
  b1: str => text(
    size: 8pt,
    fill: accent-color,
    weight: "medium",
    smallcaps(str),
  ),
  b2: str => align(right, text(
    size: 8pt,
    weight: "medium",
    fill: gray,
    style: "oblique",
    str,
  )),
  dates: dates => [
    #set list(marker: [])
    #dates
  ],
  description: str => text(
    fill: _regular-colors.lightgray,
    {
      v(before-entry-description-skip)
      str
    },
  ),
  tag: str => align(center, text(size: 8pt, weight: "regular", str)),
)

/// Create entry tag list
/// -> content
#let _create-entry-tag-list(tags, tag-style) = {
  for tag in tags {
    box(
      inset: (x: 0.25em),
      outset: (y: 0.25em),
      fill: _regular-colors.subtlegray,
      radius: 3pt,
      tag-style(tag),
    )
    h(5pt)
  }
}

/// Core entry rendering function
/// -> content
#let _make-cv-entry(
  entry-type,
  params,
  title: none,
  society: none,
  date: none,
  location: none,
  description: none,
  logo: "",
  tags: (),
  metadata: metadata,
) = {
  // Extract parameters
  let accent-color = params.accent-color
  let before-entry-skip = params.before-entry-skip
  let before-entry-description-skip = params.before-entry-description-skip
  let date-width = params.date-width

  // Create styles
  let styles = _entry-styles(accent-color, before-entry-description-skip)

  // Layout settings
  let display-logo = metadata.layout.entry.display_logo
  let society-first-setting = metadata.layout.entry.display_entry_society_first

  v(before-entry-skip)

  if entry-type == "full" {
    // Full entry layout (original cv-entry logic)
    table(
      columns: (1fr, date-width),
      inset: 0pt,
      stroke: 0pt,
      gutter: 6pt,
      align: (x, y) => if x == 1 { right } else { auto },
      table(
        columns: (if display-logo and logo != "" { 4% } else { 0% }, 1fr),
        inset: 0pt,
        stroke: 0pt,
        align: horizon,
        column-gutter: if display-logo and logo != "" { 4pt } else { 0pt },
        if logo == "" [] else {
          set image(width: 100%)
          logo
        },
        table(
          columns: auto,
          inset: 0pt,
          stroke: 0pt,
          row-gutter: 6pt,
          align: auto,
          {
            (styles.a1)(if society-first-setting { society } else { title })
          },
          {
            (styles.b1)(if society-first-setting { title } else { society })
          },
        ),
      ),
      table(
        columns: auto,
        inset: 0pt,
        stroke: 0pt,
        row-gutter: 6pt,
        align: auto,
        (styles.a2)(if society-first-setting { location } else {
          (styles.dates)(date)
        }),
        (styles.b2)(if society-first-setting { (styles.dates)(date) } else {
          location
        }),
      ),
    )
    if description != "" and description != none {
      (styles.description)(description)
    }
    _create-entry-tag-list(tags, styles.tag)
  } else if entry-type == "start" {
    // Entry start layout (original cv-entry-start logic)
    if display-logo and logo != "" {
      // With logo: 3-column layout
      table(
        columns: (4%, 1fr, date-width),
        inset: 0pt,
        stroke: 0pt,
        gutter: 6pt,
        align: horizon,
        {
          set image(width: 100%)
          logo
        },
        (styles.a1)(society),
        (styles.a2)(location),
      )
    } else {
      // Without logo: 2-column layout (matches cv-entry alignment)
      table(
        columns: (1fr, date-width),
        inset: 0pt,
        stroke: 0pt,
        gutter: 6pt,
        align: horizon,
        (styles.a1)(society), (styles.a2)(location),
      )
    }
    v(-10pt)
  } else if entry-type == "continued" {
    // Entry continued layout (original cv-entry-continued logic)
    // If the date contains a linebreak, use legacy side-to-side layout
    let multiple-dates
    if type(date) == content {
      multiple-dates = if linebreak() in date.fields().children { true } else {
        false
      }
    } else {
      multiple-dates = false
    }

    if not multiple-dates {
      table(
        columns: (1fr, date-width),
        inset: 0pt,
        stroke: 0pt,
        gutter: 6pt,
        align: auto,
        {
          (styles.b1)(title)
        },
        (styles.b2)((styles.dates)(date)),
      )
      if description != "" and description != none {
        (styles.description)(description)
      }
      _create-entry-tag-list(tags, styles.tag)
    } else {
      table(
        columns: (1fr, date-width),
        inset: 0pt,
        stroke: 0pt,
        gutter: 6pt,
        align: auto,
        {
          (styles.b1)(title)
          if description != "" and description != none {
            (styles.description)(description)
          }
        },
        (styles.b2)((styles.dates)(date)),
      )
      (styles.description)(description)
      _create-entry-tag-list(tags, styles.tag)
    }
  }
}



/// Add an entry to the CV.
///
/// When `display_entry_society_first = true` is set in `metadata.toml`, the `society`
/// field appears bold/first and `title` appears as the subtitle. When `false` (the
/// default), the `title` field is bold/first and `society` is the subtitle.
///
/// - title (str): The title of the entry (role or position).
/// - society (str): The society of the entry (company, university, etc.).
/// - date (str | content): The date(s) of the entry.
/// - location (str): The location of the entry.
/// - description (array): The description of the entry. It can be a string or an array of strings.
/// - logo (image): The logo of the society. If empty, no logo will be displayed.
/// - tags (array): The tags of the entry.
/// - metadata (array): (optional) the metadata read from the TOML file.
/// - awesome-colors (array): (optional) the awesome colors of the CV.
///
/// ```example
/// >>> #set text(font: "Source Sans 3")
/// #block(width: 300pt)[
///   #cv-entry(
///     title: [Data Analyst],
///     society: [ABC Company],
///     date: [2017 - 2020],
///     location: [New York, NY],
///     description: list(
///       [Analyzed datasets with SQL and Python],
///     ),
///     tags: ("Python", "SQL"),
///     metadata: _metadata,
///   )
/// ]
/// ```
/// -> content
#let cv-entry(
  title: "Title",
  society: "Society",
  date: "Date",
  location: "Location",
  description: "",
  logo: "",
  tags: (),
  color: none,
  metadata: none,
  awesome-colors: _awesome-colors,
) = context {
  let metadata = if metadata != none { metadata } else { cv-metadata.get() }
  let params = _prepare-entry-params(metadata, awesome-colors, color: color)

  _make-cv-entry(
    "full",
    params,
    title: title,
    society: society,
    date: date,
    location: location,
    description: description,
    logo: logo,
    tags: tags,
    metadata: metadata,
  )
}

/// Add the start of an entry to the CV. Use this together with one or more
/// `cv-entry-continued` calls to list multiple roles at the same company.
/// The start renders the company name and location, while each continued entry
/// adds a role with its own dates, description, and tags.
///
/// *Requires* `display_entry_society_first = true` in `metadata.toml`.
///
/// - society (str): The society of the entry (company, university, etc.).
/// - location (str): The location of the entry.
/// - logo (image): The logo of the society. If empty, no logo will be displayed.
/// - metadata (array): (optional) the metadata read from the TOML file.
/// - awesome-colors (array): (optional) the awesome colors of the CV.
///
/// ```example
/// >>> #set text(font: "Source Sans 3")
/// #block(width: 300pt)[
///   #cv-entry-start(
///     society: [XYZ Corporation],
///     location: [San Francisco, CA],
///     metadata: _metadata,
///   )
///   #cv-entry-continued(
///     title: [Data Scientist],
///     date: [2017 - 2020],
///     description: list(
///       [Analyzed large datasets with SQL and Python],
///     ),
///     metadata: _metadata,
///   )
/// ]
/// ```
/// -> content
#let cv-entry-start(
  society: "Society",
  location: "Location",
  logo: "",
  color: none,
  metadata: none,
  awesome-colors: _awesome-colors,
) = context {
  let metadata = if metadata != none { metadata } else { cv-metadata.get() }
  if not metadata.layout.entry.display_entry_society_first {
    panic("display_entry_society_first must be true to use cv-entry-start")
  }

  let params = _prepare-entry-params(metadata, awesome-colors, color: color)

  _make-cv-entry(
    "start",
    params,
    society: society,
    location: location,
    logo: logo,
    metadata: metadata,
  )
}

/// Add a continued entry to the CV. Must be used after a `cv-entry-start` call
/// to add an additional role at the same company. Multiple `cv-entry-continued`
/// calls can follow a single `cv-entry-start`.
///
/// *Requires* `display_entry_society_first = true` in `metadata.toml`.
///
/// - title (str): The title of the entry (role or position).
/// - date (str | content): The date(s) of the entry.
/// - description (str | array): The description of the entry. Can be a string or an array of strings.
/// - tags (array): The tags of the entry.
/// - color (color): (optional) override the accent color for this entry.
/// - metadata (array): (optional) the metadata read from the TOML file.
/// - awesome-colors (array): (optional) the awesome colors of the CV.
/// -> content
#let cv-entry-continued(
  title: "Title",
  date: "Date",
  description: "",
  tags: (),
  color: none,
  metadata: none,
  awesome-colors: _awesome-colors,
) = context {
  let metadata = if metadata != none { metadata } else { cv-metadata.get() }
  if not metadata.layout.entry.display_entry_society_first {
    panic("display_entry_society_first must be true to use cv-entry-continued")
  }

  let params = _prepare-entry-params(metadata, awesome-colors, color: color)

  _make-cv-entry(
    "continued",
    params,
    title: title,
    date: date,
    description: description,
    tags: tags,
    metadata: metadata,
  )
}

/// Add a skill to the CV.
///
/// - type (str): The type of the skill. It is displayed on the left side.
/// - info (str | content): The information about the skill. It is displayed on the right side. Items can be separated by `#h-bar()`.
///
/// ```example
/// >>> #set text(font: "Source Sans 3")
/// #block(width: 300pt)[
///   #cv-skill(
///     type: [Tech Stack],
///     info: [Python #h-bar() SQL #h-bar() Tableau],
///   )
/// ]
/// ```
/// -> content
#let cv-skill(type: "Type", info: "Info") = {
  let skill-type-style(str) = {
    align(right, text(size: 10pt, weight: "bold", str))
  }
  let skill-info-style(str) = {
    text(str)
  }

  table(
    columns: (17%, 1fr),
    inset: 0pt,
    column-gutter: 10pt,
    stroke: none,
    skill-type-style(type), skill-info-style(info),
  )
  v(-6pt)
}

/// Add a skill with a level to the CV.
///
/// The level is rendered as a row of 5 circles: filled circles for the skill
/// level and empty circles for the remainder (e.g., level 3 shows 3 filled
/// and 2 empty circles).
///
/// - type (str): The type of the skill. It is displayed on the left side.
/// - level (int): The level of the skill (0--5). Rendered as filled/empty circles in the middle column.
/// - info (str | content): The information about the skill. It is displayed on the right side.
///
/// ```example
/// >>> #set text(font: "Source Sans 3")
/// >>> #import "@preview/fontawesome:0.6.0": *
/// #block(width: 300pt)[
///   #cv-skill-with-level(
///     type: [Languages],
///     level: 4,
///     info: [English #h-bar() French #h-bar() Chinese],
///   )
/// ]
/// ```
/// -> content
#let cv-skill-with-level(
  type: "Type",
  level: 3,
  info: "Info",
) = {
  let skill-type-style(str) = {
    align(right, text(size: 10pt, weight: "bold", str))
  }
  let skill-info-style(str) = {
    text(str)
  }
  let skill-level-style(str) = {
    set text(size: 10pt, fill: _regular-colors.darkgray)
    for x in range(0, level) {
      [#fa-icon("circle", solid: true) ]
    }
    for x in range(level, 5) {
      [#fa-icon("circle") ]
    }
  }

  table(
    columns: (17%, auto, 1fr),
    inset: 0pt,
    column-gutter: 10pt,
    stroke: none,
    skill-type-style(type), skill-level-style(level), skill-info-style(info),
  )
  v(-6pt)
}

/// Add a skill tag to the CV.
///
/// - skill (str | content): The skill to be displayed.
///
/// ```example
/// >>> #set text(font: "Source Sans 3")
/// #block(width: 300pt)[
///   #cv-skill-tag([AWS Certified])
///   #cv-skill-tag([Python])
/// ]
/// ```
/// -> content
#let cv-skill-tag(skill) = {
  let entry-tag-style(str) = {
    align(center, text(size: 10pt, weight: "regular", str))
  }
  box(
    inset: (x: 0.5em, y: 0.5em),
    fill: _regular-colors.subtlegray,
    radius: 3pt,
    entry-tag-style(skill),
  )
  h(5pt)
}

/// Add a Honor to the CV.
///
/// - date (str): The date of the honor.
/// - title (str): The title of the honor.
/// - issuer (str): The issuer of the honor.
/// - url (str): The URL of the honor.
/// - location (str): The location of the honor.
/// - awesome-colors (array): (optional) The awesome colors of the CV.
/// - metadata (array): (optional) The metadata read from the TOML file.
///
/// ```example
/// >>> #set text(font: "Source Sans 3")
/// #block(width: 300pt)[
///   #cv-honor(
///     date: [2022],
///     title: [AWS Certified Security],
///     issuer: [Amazon Web Services],
///     location: [Online],
///     metadata: _metadata,
///   )
/// ]
/// ```
/// -> content
#let cv-honor(
  date: "1990",
  title: "Title",
  issuer: "",
  url: "",
  location: "",
  color: none,
  awesome-colors: _awesome-colors,
  metadata: none,
) = context {
  let metadata = if metadata != none { metadata } else { cv-metadata.get() }
  let accent-color = _resolve-accent-color(color, awesome-colors, metadata)

  let honor-date-style(str) = {
    align(right, text(str))
  }
  let honor-title-style(str) = {
    text(weight: "bold", str)
  }
  let honor-issuer-style(str) = {
    text(str)
  }
  let honor-location-style(str) = {
    align(
      right,
      text(weight: "medium", fill: accent-color, style: "oblique", str),
    )
  }

  table(
    columns: (16%, 1fr, 15%),
    inset: 0pt,
    column-gutter: 10pt,
    align: horizon,
    stroke: none,
    honor-date-style(date),
    if issuer == "" {
      honor-title-style(title)
    } else if url != "" {
      [
        #honor-title-style(link(url)[#title]), #honor-issuer-style(issuer)
      ]
    } else {
      [
        #honor-title-style(title), #honor-issuer-style(issuer)
      ]
    },
    honor-location-style(location),
  )
  v(-6pt)
}

/// Add the publications to the CV by reading a bib file.
///
/// When `ref-full` is `true`, all entries in the bib file are displayed.
/// When `ref-full` is `false`, only the entries whose keys appear in
/// `key-list` are included, allowing selective publication lists.
///
/// - bib (bibliography): The `bibliography` object with the path to the bib file.
/// - key-list (list): The list of bib keys to include when `ref-full` is `false`.
/// - ref-style (str): The reference style of the publication list (e.g., `"apa"`).
/// - ref-full (bool): Whether to show all entries (`true`) or only those in `key-list` (`false`).
/// -> content
#let cv-publication(
  bib: "",
  ref-style: "apa",
  ref-full: true,
  key-list: list(),
) = {
  let publication-style(str) = {
    text(str)
  }
  show bibliography: it => publication-style(it)
  set bibliography(title: none, style: ref-style, full: ref-full)

  if ref-full {
    bib
  } else {
    for key in key-list {
      cite(label(key), form: none)
    }
    bib
  }
}

