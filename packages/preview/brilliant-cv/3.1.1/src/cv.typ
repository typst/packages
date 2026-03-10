/*
* Functions for the CV template
*/

#import "@preview/fontawesome:0.6.0": *
#import "./utils/injection.typ": _inject
#import "./utils/styles.typ": _latin-font-list, _latin-header-font, _awesome-colors, _regular-colors, _set-accent-color, h-bar
#import "./utils/lang.typ": _is-non-latin, _default-date-width

/// Metadata state to avoid passing metadata to every function
#let cv-metadata = state("cv-metadata", none)

/// Create header style functions
/// -> dictionary
#let _header-styles(header-font, regular-colors, accent-color, header-info-font-size) = (
  first-name: (str) => text(
    font: header-font,
    size: 32pt,
    weight: "light",
    fill: regular-colors.darkgray,
    str,
  ),
  last-name: (str) => text(font: header-font, size: 32pt, weight: "bold", str),
  info: (str) => text(size: header-info-font-size, fill: accent-color, str),
  quote: (str) => text(size: 10pt, weight: "medium", style: "italic", fill: accent-color, str),
)

/// Extract layout values with defaults
/// -> any
#let _get-layout-value(metadata, key, default) = {
  eval(metadata.layout.at(key, default: default))
}

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
#let _make-header-info(personal-info, icons) = {
  let n = 1
  for (k, v) in personal-info {
    // A dirty trick to add linebreaks with "linebreak" as key in personalInfo
    if k == "linebreak" {
      n = 0
      linebreak()
      continue
    }
    if k.contains("custom") {
      let img = v.at("image", default: "")
      let awesome-icon = v.at("awesomeIcon", default: "")
      let text = v.at("text", default: "")
      let link-value = v.at("link", default: "")
      let icon = ""
      if img != "" {
        icon = img.with(width: 10pt)
      } else {
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
          link("tel:" + v.replace(" ",""))[#v]
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

/// Create header name section
/// -> content
#let _make-header-name-section(styles, non-latin, non-latin-name, first-name, last-name, personal-info, header-quote) = {
  table(
    columns: 1fr,
    inset: 0pt,
    stroke: none,
    row-gutter: 6mm,
    if non-latin {
      (styles.first-name)(non-latin-name)
    } else [#(styles.first-name)(first-name) #h(5pt) #(styles.last-name)(last-name)],
    [#(styles.info)(_make-header-info(personal-info, _personal-info-icons))],
    .. if header-quote != none { ([#(styles.quote)(header-quote)],) },
  )
}

/// Create header photo section
/// -> content
#let _make-header-photo-section(display-profile-photo, profile-photo, profile-photo-radius) = {
  set image(height: 3.6cm)
  if display-profile-photo {
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
/// - header-font (array): the font of the header.
/// - regular-colors (array): the regular colors of the CV.
/// - awesome-colors (array): the awesome colors of the CV.
/// -> content
#let _cv-header(
  metadata,
  profile-photo,
  header-font,
  regular-colors,
  awesome-colors,
) = {
  // Parameters
  let header-alignment = eval(metadata.layout.header.header_align)
  let inject-ai-prompt = metadata.inject.inject_ai_prompt
  let inject-keywords = metadata.inject.inject_keywords
  let keywords = metadata.inject.injected_keywords_list
  let personal-info = metadata.personal.info
  let first-name = metadata.personal.first_name
  let last-name = metadata.personal.last_name
  let header-quote = metadata.lang.at(metadata.language).at("header_quote", default: none)
  let display-profile-photo = metadata.layout.header.display_profile_photo
  let profile-photo-radius = eval(metadata.layout.header.at("profile_photo_radius", default: "50%"))
  let header-info-font-size = eval(metadata.layout.header.at("info_font_size", default: "10pt"))
  let accent-color = _set-accent-color(_awesome-colors, metadata)
  let non-latin-name = ""
  let non-latin = _is-non-latin(metadata.language)
  if non-latin {
    non-latin-name = metadata.lang.non_latin.name
  }

  // Injection
  _inject(
    inject-ai-prompt: inject-ai-prompt,
    inject-keywords: inject-keywords,
    keywords: keywords,
  )

  // Create styles
  let styles = _header-styles(header-font, regular-colors, accent-color, header-info-font-size)
  
  // Create components
  let name-section = _make-header-name-section(
    styles, non-latin, non-latin-name, first-name, last-name, personal-info, header-quote
  )
  
  let photo-section = _make-header-photo-section(display-profile-photo, profile-photo, profile-photo-radius)

  // Render header
  if display-profile-photo {
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
  let footer-text = metadata.lang.at(metadata.language).cv_footer
  let display-page-counter = metadata.layout.at("footer", default: {}).at("display_page_counter", default: false)
  let display-footer = metadata.layout.at("footer", default: {}).at("display_footer", default: true)

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
      footer-style([#first-name #last-name]),
      footer-style(footer-text),
    )
  }

}

/// Add the title of a section.
///
/// NOTE: If the language is non-Latin, the title highlight will not be sliced.
///
/// - title (str): The title of the section.
/// - highlighted (bool): Whether the first n letters will be highlighted in accent color.
/// - letters (int): The number of first letters of the title to highlight.
/// - metadata (array): (optional) the metadata read from the TOML file.
/// - awesome-colors (array): (optional) the awesome colors of the CV.
/// -> content
#let cv-section(
  title,
  highlighted: true,
  letters: 3,
  metadata: none,
  // New parameter names (recommended)
  awesome-colors: none,
  // Old parameter names (deprecated, for backward compatibility)
  awesomeColors: _awesome-colors,
) = context {
  let metadata = if metadata != none { metadata } else { cv-metadata.get() }
  // Backward compatibility logic (remove this block when deprecating)
  let awesome-colors = if awesome-colors != none { 
    awesome-colors 
  } else { 
    // TODO: Add deprecation warning in future version
    // Currently Typst doesn't have a standard warning mechanism for user functions
    awesomeColors 
  }
  
  let lang = metadata.language
  let non-latin = _is-non-latin(lang)
  let before-section-skip = _get-layout-value(metadata, "before_section_skip", 1pt)
  let accent-color = _set-accent-color(awesome-colors, metadata)
  let highlighted-text = title.slice(0, letters)
  let normal-text = title.slice(letters)

  let section-title-style(str, color: black) = {
    text(size: 16pt, weight: "bold", fill: color, str)
  }

  v(before-section-skip)
  if non-latin {
    section-title-style(title, color: accent-color)
  } else {
    if highlighted {
      section-title-style(highlighted-text, color: accent-color)
      section-title-style(normal-text, color: black)
    } else {
      section-title-style(title, color: black)
    }
  }
  h(2pt)
  box(width: 1fr, line(stroke: 0.9pt, length: 100%))
}

/// Prepare common entry parameters
/// -> dictionary
#let _prepare-entry-params(metadata, awesome-colors, awesomeColors) = {
  // Backward compatibility for awesome-colors parameter
  let awesome-colors = if awesome-colors != none {
    awesome-colors
  } else {
    awesomeColors
  }

  let accent-color = _set-accent-color(awesome-colors, metadata)
  let before-entry-skip = eval(metadata.layout.at("before_entry_skip", default: 1pt))
  let before-entry-description-skip = eval(
    metadata.layout.at("before_entry_description_skip", default: 1pt),
  )
  let date-width = metadata.layout.at("date_width", default: none)
  let date-width = if date-width == none {
    _default-date-width(metadata.language)
  } else {
    eval(date-width)
  }

  return (
    accent-color: accent-color,
    before-entry-skip: before-entry-skip,
    before-entry-description-skip: before-entry-description-skip,
    date-width: date-width,
    awesome-colors: awesome-colors,
  )
}

/// Prepare common entry parameters
/// -> dictionary
#let _prepare-entry-params(metadata, awesome-colors, awesomeColors) = {
  // Backward compatibility logic
  let awesome-colors = if awesome-colors != none { 
    awesome-colors 
  } else { 
    // TODO: Add deprecation warning in future version
    awesomeColors 
  }
  
  // Common parameter calculations
  let accent-color = _set-accent-color(awesome-colors, metadata)
  let before-entry-skip = eval(metadata.layout.at("before_entry_skip", default: 1pt))
  let before-entry-description-skip = eval(metadata.layout.at("before_entry_description_skip", default: 1pt))
  let date-width = metadata.layout.at("date_width", default: none)
  let date-width = if date-width == none {
    _default-date-width(metadata.language)
  } else {
    eval(date-width)
  }
  
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
  a1: (str) => text(size: 10pt, weight: "bold", str),
  a2: (str) => align(right, text(weight: "medium", fill: accent-color, style: "oblique", str)),
  b1: (str) => text(size: 8pt, fill: accent-color, weight: "medium", smallcaps(str)),
  b2: (str) => align(right, text(size: 8pt, weight: "medium", fill: gray, style: "oblique", str)),
  dates: (dates) => [
    #set list(marker: [])
    #dates
  ],
  description: (str) => text(
    fill: _regular-colors.lightgray,
    {
      v(before-entry-description-skip)
      str
    },
  ),
  tag: (str) => align(center, text(size: 8pt, weight: "regular", str)),
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
  let accent-color = params.accent-color
  let before-entry-skip = params.before-entry-skip
  let before-entry-description-skip = params.before-entry-description-skip
  let date-width = params.date-width

  let styles = _entry-styles(accent-color, before-entry-description-skip)
  let display-logo = metadata.layout.entry.display_logo
  let society-first-setting = metadata.layout.entry.display_entry_society_first

  v(before-entry-skip)

  if entry-type == "full" {
    table(
      columns: (1fr, date-width),
      inset: 0pt,
      stroke: none,
      gutter: 6pt,
      align: (x, y) => if x == 1 { right } else { auto },
      {
        table(
          columns: (if display-logo and logo != "" { 4% } else { 0% }, 1fr),
          inset: 0pt,
          stroke: none,
          align: horizon,
          column-gutter: if display-logo and logo != "" { 4pt } else { 0pt },
          _set-logo-content(logo),
          table(
            columns: auto,
            inset: 0pt,
            stroke: none,
            row-gutter: 6pt,
            align: auto,
            {
              (styles.a1)(if society-first-setting { society } else { title })
            },
            {
              (styles.b1)(if society-first-setting { title } else { society })
            },
          ),
        )
        (styles.description)(description)
        _create-entry-tag-list(tags, styles.tag)
      },
      table(
        columns: auto,
        inset: 0pt,
        stroke: none,
        row-gutter: 6pt,
        align: auto,
        (styles.a2)(if society-first-setting { location } else { (styles.dates)(date) }),
        (styles.b2)(if society-first-setting { (styles.dates)(date) } else { location }),
      ),
    )
  } else if entry-type == "start" {
    table(
      columns: (if display-logo and logo != "" { 4% } else { 0% }, 1fr, date-width),
      inset: 0pt,
      stroke: none,
      gutter: 6pt,
      align: horizon,
      _set-logo-content(logo),
      (styles.a1)(society),
      (styles.a2)(location),
    )
    v(-10pt)
  } else if entry-type == "continued" {
    let multiple-dates
    if type(date) == content {
      multiple-dates = if linebreak() in date.fields().children { true } else { false }
    } else {
      multiple-dates = false
    }

    if not multiple-dates {
      table(
        columns: (1fr, date-width),
        inset: 0pt,
        stroke: none,
        gutter: 6pt,
        align: auto,
        {
          (styles.b1)(title)
        },
        (styles.b2)((styles.dates)(date)),
      )
      (styles.description)(description)
      _create-entry-tag-list(tags, styles.tag)
    } else {
      table(
        columns: (1fr, date-width),
        inset: 0pt,
        stroke: none,
        gutter: 6pt,
        align: auto,
        {
          (styles.b1)(title)
          (styles.description)(description)
        },
        (styles.b2)((styles.dates)(date)),
      )
      _create-entry-tag-list(tags, styles.tag)
    }
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
        (styles.a2)(if society-first-setting { location } else { (styles.dates)(date) }),
        (styles.b2)(if society-first-setting { (styles.dates)(date) } else { location }),
      ),
    )
    (styles.description)(description)
    _create-entry-tag-list(tags, styles.tag)
    
  } else if entry-type == "start" {
    // Entry start layout (original cv-entry-start logic)
    table(
      columns: (if display-logo and logo != "" { 4% } else { 0% }, 1fr, date-width),
      inset: 0pt,
      stroke: 0pt,
      gutter: 6pt,
      align: horizon,
      if logo == "" [] else {
        set image(width: 100%)
        logo
      },
      (styles.a1)(society),
      (styles.a2)(location),
    )
    v(-10pt)
    
  } else if entry-type == "continued" {
    // Entry continued layout (original cv-entry-continued logic)
    // If the date contains a linebreak, use legacy side-to-side layout
    let multiple-dates
    if type(date) == content {
      multiple-dates = if linebreak() in date.fields().children { true } else { false }
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
      (styles.description)(description)
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
          (styles.description)(description)
        },
        (styles.b2)((styles.dates)(date)),
        )
      _create-entry-tag-list(tags, styles.tag)
    }
  }
}



/// Add an entry to the CV.
///
/// - title (str): The title of the entry.
/// - society (str): The society of the entry (company, university, etc.).
/// - date (str | content): The date(s) of the entry.
/// - location (str): The location of the entry.
/// - description (array): The description of the entry. It can be a string or an array of strings.
/// - logo (image): The logo of the society. If empty, no logo will be displayed.
/// - tags (array): The tags of the entry.
/// - metadata (array): (optional) the metadata read from the TOML file.
/// - awesome-colors (array): (optional) the awesome colors of the CV.
/// -> content
#let cv-entry(
  title: "Title",
  society: "Society",
  date: "Date",
  location: "Location",
  description: "Description",
  logo: "",
  tags: (),
  metadata: none,
  // New parameter names (recommended)
  awesome-colors: none,
  // Old parameter names (deprecated, for backward compatibility)
  awesomeColors: _awesome-colors,
) = context {
  let metadata = if metadata != none { metadata } else { cv-metadata.get() }
  let params = _prepare-entry-params(metadata, awesome-colors, awesomeColors)

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

/// Add the start of an entry to the CV.
///
/// - society (str): The society of the entry (company, university, etc.).
/// - location (str): The location of the entry.
/// - logo (image): The logo of the society. If empty, no logo will be displayed.
/// - metadata (array): (optional) the metadata read from the TOML file.
/// - awesome-colors (array): (optional) the awesome colors of the CV.
/// -> content
#let cv-entry-start(
  society: "Society",
  location: "Location",
  logo: "",
  metadata: none,
  // New parameter names (recommended)
  awesome-colors: none,
  // Old parameter names (deprecated, for backward compatibility)
  awesomeColors: _awesome-colors,
) = context {
  let metadata = if metadata != none { metadata } else { cv-metadata.get() }
  // To use cvEntryStart, you need to set display_entry_society_first to true in the metadata.toml file.
  if not metadata.layout.entry.display_entry_society_first {
    panic("display_entry_society_first must be true to use cvEntryStart")
  }

  let params = _prepare-entry-params(metadata, awesome-colors, awesomeColors)

  _make-cv-entry(
    "start",
    params,
    society: society,
    location: location,
    logo: logo,
    metadata: metadata,
  )
}

#let cv-entry-continued(
  title: "Title",
  date: "Date",
  description: "Description",
  tags: (),
  metadata: none,
  // New parameter names (recommended)
  awesome-colors: none,
  // Old parameter names (deprecated, for backward compatibility)
  awesomeColors: _awesome-colors,
) = context {
  let metadata = if metadata != none { metadata } else { cv-metadata.get() }
  // To use cv-entry-continued, you need to set display_entry_society_first to true in the metadata.toml file.
  if not metadata.layout.entry.display_entry_society_first {
    panic("display_entry_society_first must be true to use cvEntryContinued")
  }
  
  let params = _prepare-entry-params(metadata, awesome-colors, awesomeColors)

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
/// - info (str | content): The information about the skill. It is displayed on the right side. Items can be separated by `#hbar()`.
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
/// - type (str): The type of the skill. It is displayed on the left side.
/// - level (int): The level of the skill. It is displayed in as circles in the middle. The minimum level is 0 and the maximum level is 5.
/// - info (str | content): The information about the skill. It is displayed on the right side.
/// -> content
#let cv-skill-with-level(
  type: "Type",
  level: 3,
  info: "Info"
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
/// -> content
#let cv-honor(
  date: "1990",
  title: "Title",
  issuer: "",
  url: "",
  location: "",
  awesome-colors: _awesome-colors,
  metadata: none,
) = context {
  let metadata = if metadata != none { metadata } else { cv-metadata.get() }
  let accent-color = _set-accent-color(awesome-colors, metadata)

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
/// - bib (bibliography): The `bibliography` object with the path to the bib file.
/// - keyList (list): The list of keys to include in the publication list.
/// - refStyle (str): The reference style of the publication list.
/// - refFull (bool): Whether to show the full reference or not.
/// -> content
#let cv-publication(
  bib: "", 
  // New parameter names (recommended)
  ref-style: "apa", 
  ref-full: true, 
  key-list: list(),
  // Old parameter names (deprecated, for backward compatibility)
  refStyle: "apa", 
  refFull: true, 
  keyList: list()
) = {
  // Backward compatibility logic (remove this block when deprecating)
  let ref-style = if ref-style != "apa" { ref-style } else { refStyle }
  let ref-full = if ref-full != true { ref-full } else { refFull }
  let key-list = if key-list != list() { key-list } else { keyList }
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

// Backward compatibility
#let cvPublication = cv-publication
#let cvEntryStart = cv-entry-start
#let cvEntryContinued = cv-entry-continued
#let cvSkill = cv-skill
#let cvSkillWithLevel = cv-skill-with-level
#let cvSkillTag = cv-skill-tag
#let cvHonor = cv-honor
#let cvSection = cv-section
#let cvEntry = cv-entry
