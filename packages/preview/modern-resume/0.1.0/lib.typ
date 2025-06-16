#let colors = (
  primary: rgb("#313C4E"),
  secondary: rgb("#222A33"),
  accentColor: rgb("#449399"),
  text-primary: black,
  text-secondary: rgb("#7C7C7C"),
  text-tertiary: white,
)
#let page-margin = 16pt
#let text-size = (
  super-large: 24pt,
  large: 14pt,
  normal: 11pt,
  small: 9pt,
)

// assets contains the base paths to folders for icons, images, ...
#let assets = (
  icons: "assets/icons"
)

// joinPath joins the arguments to a valid system path.
#let joinPath(..parts) = {
  let path = ""
  let pathSeparator = "/"
  for part in parts.pos() {
    if part.at(part.len() - 1) == pathSeparator {
      path += part
    } else {
      path += part + pathSeparator
    }
  }
  return path
}

// Load an icon by 'name' and set its color.
#let icon(
  name,
  color: white,
  baseline: 0.125em,
  height: 1.0em,
  width: 1.25em) = {
    let svgFilename = name + ".svg"
    let svgFilepath = joinPath(assets.icons, svgFilename)
    let originalImage = read(svgFilepath)
    let colorizedImage = originalImage.replace(
      "#ffffff",
      color.to-hex(),
    )
    box(
      baseline: baseline,
      height: height,
      width: width,
      image.decode(colorizedImage)
    )
}

// infoItem returns a content element with an icon followed by text.
#let infoItem(iconName, msg) = {
  text(colors.text-tertiary, [#icon(iconName, baseline: 0.25em) #msg])
}

// circularAvatarImage returns a rounded image with a border.
#let circularAvatarImage(img) = {
  block(
    radius: 50%,
    clip: true,
    stroke: 4pt + colors.accentColor,
    width: 2cm
  )[
    #img
  ]
}

#let headline(name, title, bio, avatar: none) = {
  grid(
    columns: (1fr, auto),
    align(bottom)[
      #text(colors.text-tertiary, name, size: text-size.super-large)\
      #text(colors.accentColor, title)\
      #text(colors.text-tertiary, bio)
    ],
    if avatar != none {
      circularAvatarImage(avatar)
    }
  )
}

// contactDetails returns a grid element with neatly organized contact details.
#let contactDetails(contactOptionsDict) = {
  if contactOptionsDict.len() == 0 {
    return
  }
  let contactOptionKeyToIconMap = (
    linkedin: "linkedin",
    email: "envelope",
    github: "github",
    mobile: "mobile",
    location: "location-dot",
    website: "globe",
  )

  // Evenly distribute the contact options among two columns.
  let contactOptionDictPairs = contactOptionsDict.pairs()
  let midIndex = calc.ceil(contactOptionsDict.len() / 2)
  let firstColumnContactOptionsDictPairs = contactOptionDictPairs.slice(0, midIndex)
  let secondColumnContactOptionsDictPairs = contactOptionDictPairs.slice(midIndex)

  let renderContactOptions(contactOptionDictPairs) = [
    #for (key, value) in contactOptionDictPairs [
        #infoItem(contactOptionKeyToIconMap.at(key), value)\
      ]
  ]

  grid(
    columns: (.5fr, .5fr),
    renderContactOptions(firstColumnContactOptionsDictPairs),
    renderContactOptions(secondColumnContactOptionsDictPairs),
  )
}

#let headerRibbon(color, content) = {
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

#let header(author, job-title, bio: none, avatar: none, contact-options: ()) = {
  grid(
    columns: 1,
    rows: (auto, auto),
    headerRibbon(
      colors.primary,
      headline(author, job-title, bio, avatar: avatar)
    ),
    headerRibbon(colors.secondary, contactDetails(contact-options))
  )
}

#let pill(msg, fill: false) = {
  let content
  if fill {
    content = rect(
      fill: colors.primary.desaturate(1%),
      radius: 15%)[
        #text(colors.text-tertiary)[#msg]
      ]
  } else {
    content = rect(
      stroke: 1pt + colors.text-secondary.desaturate(1%),
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
  label: "Courses") = [
  #text(size: text-size.large)[*#title*]\
  #subtitle\
  #text(style: "italic")[
    #text(colors.accentColor)[#date-from - #date-to]\
    #if facility-description != "" [
      #set text(colors.text-secondary)
      #facility-description\
    ]
    #text(colors.accentColor)[#label]\
  ]
  #task-description
]

// experience-edu renders a content block for educational experience.
#let experience-edu(..args) = {
  experience(..args, label: "Courses")
}

// experience-work renders a content block for work experience.
#let experience-work(..args) = {
  experience(..args, label: "Achievements/Tasks")
}

// project renders a content block for a project.
#let project(title: "", description: "", subtitle: "", date-from: "", date-to: "") = {
  let date = ""
  if date-from != "" and date-to != "" {
    date = text(style: "italic")[(#date-from - #date-to)]
  } else if date-from != "" {
    date = text(style: "italic")[(#date-from)]
  }

  text(size: text-size.large)[#title #date\ ]
  if subtitle != "" {
      set text(colors.text-secondary, style: "italic")
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
  set list(marker: (text(colors.accentColor)[•], text(colors.accentColor)[--]))

  // Set the heading.
  show heading: it => {
    set text(colors.accentColor)
    pad(bottom: 0.5em)[
      #underline(stroke: 2pt + colors.accentColor, offset: 0.25em)[
        #upper(it.body)
      ]
    ]
  }

  // A typical icon for outbound links. Use for hyperlinks.
  let linkIcon(..args) = {
    icon("arrow-up-right-from-square", ..args, width: 1.25em / 2, baseline: 0.125em * 3)
  }

  // Header
  {
    show link: it => [
      #it #linkIcon()
    ]
    header(author, job-title, bio: bio, avatar: avatar, contact-options: contact-options)
  }

  // Main content
  {
    show link: it => [
      #it #linkIcon(color: colors.accentColor)
    ]
    pad(
      left: page-margin,
      right: page-margin,
      top: 8pt
    )[#columns(2, body)]
  }
}
