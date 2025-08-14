/// Formats a programming language name in monospace font
/// - name (str): The name of the programming language
/// -> content: The formatted language name
#let lang(name) = raw(name)

/// Determines the priority threshold based on target page count
/// - pages (int): Target number of pages (1 or 2)
/// -> int: Maximum priority level to show
#let priority-threshold(pages) = if pages == 1 { 1 } else { 2 }

/// Determines if content should be displayed based on priority and page target
/// - priority (int): Content priority level (1-5)
/// - pages (int): Target number of pages
/// -> bool: Whether to show the content
#let should-show(priority, pages) = priority <= priority-threshold(pages)

/// Formats a date range string
/// - start (str): Start date
/// - end (str, none): End date or none for current
/// -> str: Formatted date range
#let format-date-range(start, end) = {
  if end != none { start + " - " + end } else { start + " - current" }
}

#let filter-prioritized-items(items, threshold) = {
  items
    .filter(item => {
      if type(item) == dictionary and "priority" in item {
        item.priority <= threshold
      } else { true }
    })
    .map(item => {
      if type(item) == dictionary and "content" in item {
        item.content
      } else { item }
    })
}

#let entry-grid(left-top, right-top, left-bottom, right-bottom) = {
  grid(
    columns: (1fr, auto),
    align: (left, right),
    row-gutter: 0.4em,
    left-top, right-top,
    left-bottom, right-bottom,
  )
}

#let render-entry-block(header, items) = {
  block(breakable: false)[
    #header
    #if items.len() > 0 {
      v(-0.3em)
      list(..items)
    }
  ]
}

#let circular-profile(path, radius: 1.5em, offset: 1em) = {
  let size = radius * 2
  box(
    move(
      dy: offset,
      block(
        height: size,
        width: size,
        clip: true,
        radius: radius,
        image(path, fit: "cover"),
      ),
    ),
  )
}

/// Main resume template function
/// - name (str): Full name
/// - email (str): Email address 
/// - website (str): Website URL (without https://)
/// - phone (str): Phone number
/// - profile-image (str, none): Path to profile image file
/// - target-pages (int): Target page count (1 or 2)
/// - font (str): Font family name
/// - theme (str): Color theme ("default", "blue", "green")
/// - body (content): Document content
/// -> content: Complete formatted resume
#let resume(
  name: "",
  email: "",
  website: "",
  phone: "",
  profile-image: none,
  target-pages: 2,
  font: "Fira Sans",
  theme: "default",
  body,
) = {
  let margins = if target-pages == 1 { 0.75in } else { 0.85in }
  
  let theme-colors = (
    default: (accent: gray, text: black),
    blue: (accent: blue.darken(20%), text: black),
    green: (accent: green.darken(30%), text: black),
  )
  
  let colors = theme-colors.at(theme, default: theme-colors.default)

  set page(paper: "a4", margin: margins)
  set text(font: font, size: 11pt, fill: colors.text)
  set par(justify: true, leading: 0.9em)
  set heading(numbering: none)

  show raw: set text(font: "Fira Code", size: 1.1em)
  show link: underline.with(stroke: colors.accent)

  grid(
    columns: (2fr, 1fr),
    align: (left, right),
    [
      #text(size: 22pt, weight: "bold")[#name]
      #if profile-image != none [
        #h(0.5em)#circular-profile(profile-image, radius: 2em, offset: 1em)
      ]
    ],
    text(size: 10pt)[
      #link("mailto:" + email) \
      #link(website) \
      #link("tel:" + phone)
    ],
  )

  let pages-state = state("target-pages", target-pages)
  pages-state.update(target-pages)
  body
}

/// Creates a resume section with priority filtering
/// - title (str): Section title
/// - priority (int): Section priority (1-5)
/// - body (content): Section content
/// -> content: Formatted section or empty if filtered out
#let section(title, priority: 1, body) = context {
  let pages = state("target-pages").get()

  if should-show(priority, pages) [
    #heading(level: 2, smallcaps(title))
    #body
  ]
}

/// Creates a prioritized item with optional language tags
/// - title (str): Item title
/// - description (str, content): Item description
/// - priority (int): Item priority (1-5)
/// - languages (array): Array of programming language names
/// -> dict: Dictionary with content and priority for filtering
#let pitem(
  title: "",
  description: "",
  priority: 2,
  languages: (),
) = {
  let lang-text = if languages.len() > 0 {
    " (" + languages.map(lang).join(", ") + ")"
  } else { "" }

  (
    content: [*#title:* #description#lang-text],
    priority: priority,
  )
}

/// Creates an experience entry with filtered items
/// - organization (str): Company or organization name
/// - industry (str): Industry or company type
/// - location (str): Location (city, state/country)
/// - title (str): Job title or position
/// - start-date (str): Start date
/// - end-date (str, none): End date or none for current
/// - priority (int): Entry priority (1-5)
/// - items (array): Array of pitem() entries
/// -> content: Formatted experience entry or empty if filtered
#let experience(
  organization: "",
  industry: "",
  location: "",
  title: "",
  start-date: "",
  end-date: none,
  priority: 1,
  items: (),
) = context {
  let pages = state("target-pages").get()

  if not should-show(priority, pages) { return }

  let date-range = format-date-range(start-date, end-date)
  let filtered-items = filter-prioritized-items(items, priority-threshold(pages))

  let header = entry-grid(
    [*#organization* (#industry)],
    [#location],
    text(size: 10pt, style: "italic")[#title],
    text(size: 10pt, style: "italic")[#date-range],
  )

  render-entry-block(header, filtered-items)
}

/// Creates an education entry with courses and activities
/// - organization (str): School or university name
/// - industry (str): Institution type (e.g., "University")
/// - location (str): Location (city, state/country)
/// - degree (str): Degree name and major
/// - thesis (str, none): Thesis title if applicable
/// - start-date (str): Start date
/// - end-date (str, none): End date or none for current
/// - priority (int): Entry priority (1-5)
/// - courses (array): Array of course names
/// - volunteering (str, none): Volunteer activities description
/// -> content: Formatted education entry or empty if filtered
#let education(
  organization: "",
  industry: "",
  location: "",
  degree: "",
  thesis: none,
  start-date: "",
  end-date: none,
  priority: 1,
  courses: (),
  volunteering: none,
) = context {
  let pages = state("target-pages").get()
  if not should-show(priority, pages) { return }

  let date-range = format-date-range(start-date, end-date)

  let format-courses(courses) = {
    if courses.len() == 0 { return none }
    if courses.len() == 1 {
      upper(courses.at(0).at(0)) + courses.at(0).slice(1)
    } else {
      let capitalized = courses.map(c => upper(c.at(0)) + c.slice(1))
      let all-but-last = capitalized.slice(0, -1)
      let last = capitalized.at(-1)
      all-but-last.join(", ") + " and " + last
    }
  }

  let items = ()
  let formatted-courses = format-courses(courses)
  if formatted-courses != none {
    items.push([*Courses:* #formatted-courses.])
  }
  if volunteering != none {
    items.push([*Volunteering:* #volunteering])
  }

  let degree-content = [
    #text(size: 10pt, style: "italic")[#degree]
    #if thesis != none [
      #v(-0.5em)
      #text(size: 9pt, fill: rgb(80, 80, 80))[Thesis: #thesis]
    ]
  ]

  let header = entry-grid(
    [*#organization* (#industry)],
    [#location],
    degree-content,
    text(size: 10pt, style: "italic")[#date-range],
  )

  render-entry-block(header, items)
}

/// Creates a project entry with filtered items
/// - title (str): Project title
/// - organization (str): Associated company or organization
/// - start-date (str): Start date
/// - end-date (str, none): End date or none for current
/// - priority (int): Project priority (1-5)
/// - items (array): Array of project detail items
/// -> content: Formatted project entry or empty if filtered
#let project(
  title: "",
  organization: "",
  start-date: "",
  end-date: none,
  priority: 2,
  items: (),
) = context {
  let pages = state("target-pages").get()
  if not should-show(priority, pages) { return }

  let date-range = format-date-range(start-date, end-date)
  let filtered-items = filter-prioritized-items(items, priority-threshold(pages))

  let header = grid(
    columns: (1fr, auto),
    align: (left, right),
    [*#title* - #organization], emph(date-range),
  )

  render-entry-block(header, filtered-items)
}

/// Creates a skill entry with priority filtering
/// - category (str): Skill category or area
/// - description (str, content): Skill description
/// - priority (int): Skill priority (1-5)
/// -> content: Formatted skill entry or empty if filtered
#let skill(category, description, priority: 2) = context {
  let pages = state("target-pages").get()
  if not should-show(priority, pages) { return }
  [*#category:* #description]
}
