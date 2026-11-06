#import "@preview/scienceicons:0.1.0": orcid-icon

#let resume(
  author: "",
  jobtitle: "",
  author-position: left,
  personal-info-position: left,
  pronouns: "",
  location: "",
  nationality: "",
  email: "",
  github: "",
  linkedin: "",
  phone: "",
  personal-site: "",
  orcid: "",
  accent-color: "#000000",
  font: "New Computer Modern",
  paper: "us-letter",
  author-font-size: 20pt,
  font-size: 10pt,
  lang: "en",
  header: "horizontal",
  // Pass `read("your-photo.jpg", encoding: none)` (or `none`).
  profile-image: none,
  body,
) = {
  assert(
    header in ("horizontal", "vertical"),
    message: "header must be \"horizontal\" or \"vertical\", got: " + repr(header),
  )
  assert(
    profile-image == none or header == "vertical",
    message: "profile-image requires header: \"vertical\"",
  )
  assert(
    profile-image == none or type(profile-image) == bytes,
    message: "profile-image must be bytes, e.g. read(\"your-photo.jpg\", encoding: none)",
  )

  // Sets document metadata
  set document(author: author, title: author)

  // Document-wide formatting, including font and margins
  set text(
    // LaTeX style font
    font: font,
    size: font-size,
    lang: lang,
    // Disable ligatures so ATS systems do not get confused when parsing fonts.
    ligatures: false,
  )

  // Reccomended to have 0.5in margin on all sides
  set page(
    margin: 0.5in,
    paper: paper,
  )

  // Link styles
  show link: underline

  // Accent Color Styling
  show heading: set text(
    fill: rgb(accent-color),
  )

  show link: set text(
    fill: rgb(accent-color),
  )

  // Name will be aligned left, bold and big
  show heading.where(level: 1): it => [
    #set align(author-position)
    #set text(
      weight: 700,
      size: author-font-size,
    )
    #pad(it.body)
  ]

  // Personal Info Helper
  let contact-item(value, prefix: "", link-type: "") = {
    if value != "" {
      if link-type != "" {
        link(link-type + value)[#(prefix + value)]
      } else {
        value
      }
    }
  }

  let items = (
    contact-item(pronouns),
    contact-item(phone, link-type: "tel:"),
    contact-item(location),
    contact-item(nationality),
    contact-item(email, link-type: "mailto:"),
    contact-item(github, link-type: "https://"),
    contact-item(linkedin, link-type: "https://"),
    contact-item(personal-site, link-type: "https://"),
    contact-item(orcid, prefix: [#orcid-icon(color: rgb("#AECD54"))orcid.org/], link-type: "https://orcid.org/"),
  )

  if header == "horizontal" {
    // Level 1 Heading
    [= #(author)]
    // Personal Info — the job title (if any) is folded into the same
    // block as the contact line, so the gap between them matches the
    // line spacing used in the vertical header. No extra top padding, so
    // the gap after the name also matches the vertical header.
    pad(
      align(personal-info-position)[
        #if jobtitle != "" [
          #text(weight: 700, size: 1.2em, fill: rgb(accent-color))[#jobtitle] \
        ]
        #{
          items.filter(x => x != none).join("  |  ")
        }
      ],
    )
  } else {
    // Vertical case: name/contact info on the left, an optional profile
    // photo on the right.
    // The job title is folded into the same line-broken text flow as the
    // contact info below (rather than being a heading) so the gap after it
    // matches the gap between contact info lines instead of using heading
    // block spacing.
    let jobtitle-line = if jobtitle != "" {
      text(weight: 700, size: 1.2em, fill: rgb(accent-color))[#jobtitle]
    }
    let lines = (jobtitle-line, ..items).filter(x => x != none)

    let author-block = [
      = #(author)
      #lines.join("\n")
    ]

    if profile-image != none {
      context {
        // Match the photo's height to the text block next to it.
        let photo-size = measure(author-block).height
        grid(
          columns: (1fr, photo-size),
          column-gutter: 25pt,
          author-block,
          box(
            width: photo-size,
            height: photo-size,
            radius: photo-size / 2,
            clip: true,
            stroke: 1pt + rgb(accent-color),
            image(profile-image, width: photo-size, height: photo-size, fit: "cover"),
          ),
        )
      }
    } else {
      author-block
    }
  }

  // Main body.
  set par(justify: true)

  // Small caps for the remaining section titles
  show heading.where(level: 2): it => [
    #pad(top: 0pt, bottom: -10pt, [#smallcaps(it.body)])
    #line(length: 100%, stroke: 1pt)
  ]

  body
}

// Generic two by two component for resume
#let generic-two-by-two(
  top-left: "",
  top-right: "",
  bottom-left: "",
  bottom-right: "",
) = {
  [
    #top-left #h(1fr) #top-right \
    #bottom-left #h(1fr) #bottom-right
  ]
}

// Generic one by two component for resume
#let generic-one-by-two(
  left: "",
  right: "",
) = {
  [
    #left #h(1fr) #right
  ]
}

// Cannot just use normal --- ligature because ligatures are disabled for good reasons
#let dates-helper(
  start-date: "",
  end-date: "",
) = {
  // The original had an em dash here which imo doesn't look as good (may even be incorrect)
  // There shouldn't be additional spaces either.
  start-date + "--" + end-date
}

// Section components below
#let edu(
  institution: "",
  dates: "",
  degree: "",
  gpa: "",
  location: "",
  // Makes dates on upper right like rest of components
  consistent: false,
) = {
  if consistent {
    // edu-constant style (dates top-right, location bottom-right)
    generic-two-by-two(
      top-left: strong(institution),
      top-right: dates,
      bottom-left: emph(degree),
      bottom-right: emph(location),
    )
  } else {
    // original edu style (location top-right, dates bottom-right)
    generic-two-by-two(
      top-left: strong(institution),
      top-right: location,
      bottom-left: emph(degree),
      bottom-right: emph(dates),
    )
  }
}

#let work(
  title: "",
  dates: "",
  company: "",
  location: "",
) = {
  generic-two-by-two(
    top-left: strong(title),
    top-right: dates,
    bottom-left: company,
    bottom-right: emph(location),
  )
}

#let project(
  role: "",
  name: "",
  url: "",
  dates: "",
) = {
  generic-one-by-two(
    left: {
      if role == "" {
        [*#name* #if url != "" and dates != "" [ (#link("https://" + url)[#url])]]
      } else {
        [*#role*, #name #if url != "" and dates != "" [ (#link("https://" + url)[#url])]]
      }
    },
    right: {
      if dates == "" and url != "" {
        link("https://" + url)[#url]
      } else {
        dates
      }
    },
  )
}

#let certificates(
  name: "",
  issuer: "",
  url: "",
  date: "",
) = {
  [
    *#name*, #issuer
    #if url != "" {
      [ (#link("https://" + url)[#url])]
    }
    #h(1fr) #date
  ]
}

#let extracurriculars(
  activity: "",
  dates: "",
) = {
  generic-one-by-two(
    left: strong(activity),
    right: dates,
  )
}
