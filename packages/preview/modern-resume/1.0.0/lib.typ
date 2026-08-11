#import "utils.typ": join-path
#let page-margin = 16pt

#let text-size = (
  super-large: 24pt,
  large: 14pt,
  normal: 11pt,
  small: 9pt,
)

// assets contains the paths to template resources (icons, ...).
#let assets = (
  // icons defines the path to the icons folder.
  icons: "assets/icons",
)

// Default theme colors
#let default-theme = (
  primary: rgb("#313C4E"),
  secondary: rgb("#222A33"),
  accentColor: rgb("#449399"),
  textPrimary: rgb("#000000"),
  textSecondary: rgb("#7C7C7C"),
  textMuted: rgb("#ffffff"),
)

// icon loads an icon resource by 'name' with the requested color (currently only supports SVG).
#let icon(
  name,
  color: white,
  baseline: 0.125em,
  height: 1.0em,
  width: 1.25em) = {
    let svgFilename = name + ".svg"
    let svgFilepath = join-path(assets.icons, svgFilename)
    let originalImage = read(svgFilepath)
    let colorizedImage = originalImage.replace(
      "#ffffff",
      color.to-hex(),
    )
    box(
      baseline: baseline,
      height: height,
      width: width,
      image(bytes(colorizedImage))
    )
}

// info-item returns a content element with an icon followed by text.
#let info-item(icon-name, msg, theme: default-theme) = {
  text(theme.textMuted, [#icon(icon-name, baseline: 0.25em) #msg])
}

// circular-avatar-image returns a rounded image with a border.
#let circular-avatar-image(img, theme: default-theme) = {
  block(
    radius: 50%,
    clip: true,
    stroke: 4pt + theme.accentColor,
    width: 2cm
  )[
    #img
  ]
}

#let headline(name, title, bio, avatar: none, theme: default-theme) = {
  grid(
    columns: (1fr, auto),
    align(bottom)[
      #text(theme.textMuted, name, size: text-size.super-large)\
      #text(theme.accentColor, title)\
      #text(theme.textMuted, bio)
    ],
    if avatar != none {
      circular-avatar-image(avatar, theme: theme)
    }
  )
}

// contact-details returns a grid element with neatly organized contact details.
#let contact-details(contact-options-dict, theme: default-theme) = {
  if contact-options-dict.len() == 0 {
    return
  }
  let contact-option-key-to-icon-map = (
    linkedin: "linkedin",
    email: "envelope",
    github: "github",
    mobile: "mobile",
    location: "location-dot",
    website: "globe",
  )

  // Evenly distribute the contact options among two columns.
  let contact-option-dict-pairs = contact-options-dict.pairs()
  let mid-index = calc.ceil(contact-options-dict.len() / 2)
  let first-column-contact-options-dict-pairs = contact-option-dict-pairs.slice(0, mid-index)
  let second-column-contact-options-dict-pairs = contact-option-dict-pairs.slice(mid-index)

  let render-contact-options(contact-option-dict-pairs) = [
    #for (key, value) in contact-option-dict-pairs [
        #info-item(contact-option-key-to-icon-map.at(key), value, theme: theme)\
      ]
  ]

  grid(
    columns: (.5fr, .5fr),
    render-contact-options(first-column-contact-options-dict-pairs),
    render-contact-options(second-column-contact-options-dict-pairs),
  )
}

#let header-ribbon(color, content) = {
  block(
    width: 100%,
    fill: color,
    inset: (
      left: page-margin,
      right: 8pt,
      top: 8pt,
      bottom: 8pt,
    ),
    content
  )
}

#let header(author, job-title, bio: none, avatar: none, contact-options: (), theme: default-theme) = {
  grid(
    columns: 1,
    rows: (auto, auto),
    header-ribbon(
      theme.primary,
      headline(author, job-title, bio, avatar: avatar, theme: theme)
    ),
    header-ribbon(theme.secondary, contact-details(contact-options, theme: theme))
  )
}

#let pill(msg, fill: false, theme: default-theme) = {
  let content
  if fill {
    content = rect(
      fill: theme.primary.desaturate(1%),
      radius: 15%)[
        #text(theme.textMuted)[#msg]
      ]
  } else {
    content = rect(
      stroke: 1pt + theme.textSecondary.desaturate(1%),
      radius: 15%)[#msg]
  }
  [
    #box(content)~
  ]
}

#let experience(
  title: "",
  subtitle: "",
  facility-description: "",
  task-description: "",
  date-from: "Present",
  date-to: "Present",
  label: "Courses",
  theme: default-theme) = [
  #text(size: text-size.large)[*#title*]\
  #subtitle\
  #text(style: "italic")[
    #text(theme.accentColor)[#date-from - #date-to]\
    #if facility-description != "" [
      #set text(theme.textSecondary)
      #facility-description\
    ]
    #text(theme.accentColor)[#label]\
  ]
  #task-description
]


// project renders a content block for a project.
#let project(title: "", description: "", subtitle: "", date-from: "", date-to: "", theme: default-theme) = {
  let date = ""
  if date-from != "" and date-to != "" {
    date = text(style: "italic")[(#date-from - #date-to)]
  } else if date-from != "" {
    date = text(style: "italic")[(#date-from)]
  }

  text(size: text-size.large)[#title #date\ ]
  if subtitle != "" {
      set text(theme.textSecondary, style: "italic")
      text()[#subtitle\ ]
  }
  if description != "" {
    [#description]
  }
}


#let modern-resume(
  // The person's full name as a string.
  author: "John Doe",

  // A short description of your profession.
  job-title: [Data Scientist],

  // A short description about your background/experience/skills, or none.
  bio: none,
  // A avatar that is pictures in the top-right corner of the resume, or none.
  avatar: none,

  // A list of contact options, defaults to an empty set.
  contact-options: (),
  
  // Custom theme, defaults to the default theme.
  theme: default-theme,

  // The resume's content.
  body
) = {
  // Set document metadata.
  set document(title: "Resume of " + author, author: author)

  // Set the body font.
  set text(font: "Roboto", size: text-size.normal)

  // Configure the page.
  set page(
    paper: "a4",
    margin: (
      top: 0cm,
      left: 0cm,
      right: 0cm,
      bottom: 1cm,
    ),
  )

  // Set the marker color for lists.
  set list(marker: (text(theme.accentColor)[•], text(theme.accentColor)[--]))

  // Set the heading.
  show heading: it => {
    set text(theme.accentColor)
    pad(bottom: 0.5em)[
      #underline(stroke: 2pt + theme.accentColor, offset: 0.25em)[
        #upper(it.body)
      ]
    ]
  }

  // A typical icon for outbound links. Use for hyperlinks.
  let link-icon(..args) = {
    icon("arrow-up-right-from-square", ..args, width: 1.25em / 2, baseline: 0.125em * 3)
  }

  // Header
  {
    show link: it => [
      #it #link-icon()
    ]
    header(author, job-title, bio: bio, avatar: avatar, contact-options: contact-options, theme: theme)
  }

  // Main content
  {
    show link: it => [
      #it #link-icon(color: theme.accentColor)
    ]
    pad(
      left: page-margin,
      right: page-margin,
      top: 8pt
    )[#columns(2, body)]
  }
}
