#import "@preview/octique:0.1.1": *
#import "@preview/uniwarn:0.1.1" as uniwarn

#let to-string(content) = {
  if type(content) == str {
    content
  } else if content.has("text") {
    to-string(content.text)
  } else if content.has("children") {
    content.children.map(to-string).join("")
  } else if content.has("body") {
    to-string(content.body)
  } else if content.has("child") {
    to-string(content.child)
  } else if content == [ ] {
    " "
  } else {
    ""
  }
}

#let namespace = "ams-cv"

#uniwarn.register-namespace(namespace)

#let warn = uniwarn.warning.with(
  namespace: namespace,
  prefix: "[" + namespace + "] ",
)

/// Generate the building blocks of your cv
/// - name (str):
/// - title (content): Your current job title
/// - additional-info (content, none): Optional information to show under your
///   title
/// - summary (content): A summary to show under your socials
/// - email (str): Your email address, this is added to the document metadata
/// - socials (dictionary): Maps a social platform label (e.g. `Website`, `Github`)
///   to a tuple of `(url, display-content)`, where `url` is the link target
///   (e.g. `mailto:`, `tel:`, or `https://`) and `display-content` is the
///   rendered label
/// - colors (dictionary):Theme colors, with keys `foreground`, `muted`, and
///   `accent`, each a `color`
/// - font-size (length):
/// - font-family (str):
#let generate-blocks(
  name: "Jane Doe",
  title: [Full-stack Developer],
  additional-info: [Based in Madrid, Spain (UTC+1)],
  summary: [Full-stack developer with 3+ years of experience building production
    systems end to end, from frontend interfaces to backend infrastructure and
    DevOps tooling.],
  email: "jane.doe@example.com",
  socials: (
    Website: ("https://example.com", [example.com]),
    Tel: ("tel:+15551234567", [+1 (555) 123-4567]),
    Github: ("https://github.com/janedoe", [\@janedoe]),
  ),
  colors: (
    foreground: rgb("#504945"),
    muted: rgb("#504945").transparentize(85%),
    accent: rgb("#B57614"),
  ),
  font-size: 8pt,
  font-family: "Space Grotesk",
) = {
  let init-cv(body) = {
    /**
     * Set rules
     */
    set document(
      title: "Curriculum Vitae / Resume",
      author: name + " <" + email + ">",
      keywords: ("cv", "resume"),
      date: datetime.today(),
    )

    set text(font: font-family, fill: colors.foreground, size: font-size)

    set page(margin: 24pt)

    /**
     * Show rules
     */
    show link: it => {
      let size = 0.75em
      [#text(it)#octique-inline(
          color: colors.accent,
          width: size,
          height: size,
          baseline: 0em,
          "link-external",
        )]
    }

    show heading.where(level: 4): set text(
      fill: colors.foreground.transparentize(30%),
    )

    body
  }

  /// A section is just a stylized heading
  let section(level: 2, radius: 2pt, body) = block(
    inset: (y: 0.5em),
    outset: (x: 1em),
    above: 1.5em,
    fill: colors.muted,
    width: 100%,
    radius: radius,
    heading(level: level, text(size: font-size, body)),
  )

  /// An activity can be a job position, education, certificate accomplishment,
  /// etc
  /// - right (content, none): What to display on the right side of the
  ///   activity. Can be period of time, level of proficiency, etc.
  /// - level (int): The heading level of an activity to be outlined
  /// - separator (boolean): Show or hide the left and right separator
  /// - separator-params (dictionary): `line` parameters for the separator
  /// - gutter (length): Gap in between the left, separator and right
  let activity(
    right: none,
    level: 3,
    href: none,
    separator: true,
    separator-params: (
      length: 100%,
      stroke: (
        dash: "loosely-dotted",
      ),
    ),
    gutter: 1em,
    body,
  ) = heading(level: level, grid(
    align: horizon,
    gutter: gutter,
    columns: (auto, 1fr, auto),
    if type(href) == type("") { link(href, body) } else { body },
    if separator {
      line(..separator-params)
    } else { none },
    if right != none {
      text(fill: colors.foreground.transparentize(30%), weight: "thin", [#text(
          fill: white.transparentize(100%),
          [ |],
        ) #right])
    } else { none },
  ))

  let socials-block(separator: h(1em)) = (
    [Email: #link("mailto:" + email, email)],
    ..socials.pairs().map(((k, (l, v))) => [#k: #link(l, v)]),
  ).join(separator)

  /// Register one or more skill(s)
  /// - hide (boolean): Hide the skill(s) inline, use only for registration
  /// - separator (content): Inline separator if you are showing multiple skills
  /// - last (content, none): The last inline separator if you are showing multiple skills
  /// - weight (str): The font weight of inline skill(s)
  /// - category (str): Category of the skill(s) to aggregate
  /// - body (content, array): A single skill an array of skills
  let skill(
    hide: false,
    separator: ", ",
    last: none,
    weight: "bold",
    category,
    body,
  ) = {
    if last == none { last = separator }
    let multi = type(body) == array
    let skills = if multi { body } else { (body,) }
    let entry = text.with(weight: weight)
    let content = if multi {
      body.map(skill => entry(skill)).join(separator, last: last)
    } else {
      entry(body)
    }
    [#if not hide { content }#metadata((
        category: category,
        skills: skills,
      ))<skill>]
  }

  /// Show registered skills
  /// - sort (boolean): Sort categories by amount of skills
  let skills(sort: true) = context {
    let skill-dict = (:)
    for skill in query(<skill>) {
      let category = skill.value.category
      if skill-dict.keys().contains(category) {
        let new-skills = skill.value.skills
        let old-skills = skill-dict.at(category)

        let duplicate = new-skills.find(skill => old-skills.contains(skill))
        if (duplicate != none) {
          warn(
            "Found duplicate skill '"
              + to-string(duplicate)
              + "' in '"
              + category
              + "'",
          )
        }

        skill-dict.at(category) += new-skills
      } else {
        skill-dict.insert(skill.value.category, skill.value.skills)
      }
    }

    let skill-list = skill-dict.pairs()
    if sort {
      skill-list = skill-list.sorted(
        key: s => s.last().len(),
        by: (l, r) => l >= r,
      )
    }

    grid(
      columns: (auto, auto),
      align: (right, left),
      gutter: 1em,
      ..skill-list
        .map(((k, v)) => (
          [*#k*: ],
          v
            .dedup()
            .map(skill => box(
              fill: colors.muted,
              inset: (x: 3pt),
              outset: (y: 2pt),
              radius: 2pt,
              skill,
            ))
            .join([, ]),
        ))
        .flatten(),
    )
  }

  let header(profile-image: none, radius: 3pt) = {
    let with-image = profile-image != none

    let content = [
      // name
      = #block(inset: (bottom: 0.2em), text(size: 1.5em, name))

      // job title
      #block(text(size: 1.5em, title))
      #if additional-info != none { additional-info }
      #line(length: 100%, stroke: colors.muted)
      #socials-block()

      #box(heading(level: 2, text(size: font-size)[Summary])) ---
      #summary
    ]

    block(
      fill: colors.muted,
      outset: (x: 1em),
      inset: (y: 1.3em),
      width: 100%,
      radius: radius,
      grid(
        columns: (auto, 1fr),
        gutter: 1em,
        ..if with-image {
          (
            profile-image,
            content,
          )
        } else { (content,) },
      ),
    )
  }

  let profile-block = block.with(radius: 3pt, clip: true)

  (
    header: header,
    section: section,
    activity: activity,
    skill: skill,
    skills: skills,
    profile-block: profile-block,
    init-cv: init-cv,
  )
}
