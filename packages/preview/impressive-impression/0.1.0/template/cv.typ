//! NOTE: You may need to install FontAwesome 6 and Open Sans fonts to render this CV correctly.
//! See installation information at: https://github.com/JeppeKlitgaard/impressive-impression

#import "@preview/impressive-impression:0.1.0": (
  cv,
  // Utils
  crop-image,
  colorize-svg-string,
  // Elements
  dot-ratings,
  make-pill,
  make-aside-persona,
  make-aside-grid,
  make-main-content-block,
  make-main-content-block-with-timeline,
  // Theme
  theme-helper,
)

#import "utils.typ": flag, fa-icon-factory, fa-icon-factory-stack
#import "theme.typ": theme

#import "@preview/fontawesome:0.5.0": fa-icon, fa-stack
#import "@preview/nth:1.0.1": nth

#let name = "Dirk Gently"
#let pronouns = "he/him"
#let profile-image = image("assets/profile.png")
#let short-description = [
  Holistic Detective & Interconnectedness Specialist
]

#let th = theme-helper(theme)

#let iconer-stack = fa-icon-factory-stack(theme)
#let iconer = fa-icon-factory(theme)
#let dot-ratings = dot-ratings.with(
  size: 6.5pt,
  spacing: 3.5pt,
  color-active: th("primary-accent-color"),
  color-inactive: th("faint-text-color").transparentize(65%),
)

#let linker(dest, body) = {
  let body-wrapped = [#text(body, fill: th("primary-accent-color"))#h(0.2em)#box(iconer("link", size: 0.7em), height: 0.8em)]
  return link(dest, body-wrapped)
}

#let linker-pdf(dest, body) = {
  let body-prefixed = [#fa-icon("file-pdf")#h(0.2em)#body]
  return linker(dest, body-prefixed)
}

#let read-and-colorize-svg(path, color) = {
  let svg-content = read(path)
  let colored-svg = colorize-svg-string(svg-content, color)
  return colored-svg
}

#let make-main-content-block = make-main-content-block.with(theme: theme)
#let make-main-content-block-with-timeline = make-main-content-block-with-timeline.with(theme: theme)

// Page 1
#let main-content-1 = [
  == Introduction
  #block([
    #set par(justify: true)
    Holistic detective with an unwavering commitment to exploring the fundamental interconnectedness of all things. I combine an unconventional investigative approach with a keen intuition for improbable solutions, engaging confidently with the realms of the paranormal, temporal anomalies, and missing cats.

    My experience spans peculiar cases involving time travel, quantum uncertainty, and reluctant clients. I thrive in unpredictable environments, leveraging resilience and a penchant for eccentric problem-solving to uncover answers that others overlook.
  ])

  == Work Experience
  #make-main-content-block-with-timeline(
    ([Present], [2018]),
    "Founder & Chief Detective",
    supplement: [#link("https://holisticdetective.com", "Holistic Detective Agency")],
    [
      Established and operated a one-of-a-kind agency dedicated to solving mysteries via the interconnectedness of all things.
      - Successfully resolved cases involving missing cats, haunted computers, and spontaneously appearing sofas.
      - Developed proprietary “luck-based” investigative techniques and pioneered random taxi route methodologies.
    ]
  )
  #make-main-content-block-with-timeline(
    ([2018], [2017]),
    "Quantum Cat Retrieval Specialist – Freelance",
    supplement: [#link("https://en.wikipedia.org/wiki/Cambridge", "Various Clients")],
    [
      - Assisted clients in locating pets lost to quantum uncertainty and other improbable circumstances.
      - Collaborated with physicists and veterinarians to develop the Schrödinger Protocol for ambiguous animal recovery.
    ]
  )
  #make-main-content-block-with-timeline(
    ([2017], [2015]),
    "Temporal Anomaly Investigator – Contractor",
    supplement: [#link("https://www.cam.ac.uk/", "St. Cedd’s College")],
    [
      - Investigated and contained time loops, paradoxes, and chronologically misplaced furniture within the college precincts.
      - Published "_A Holistic Guide to Sofa Extraction from Impossible Spaces_" (unofficial circulation).
    ]
  )
  #make-main-content-block-with-timeline(
    ([2016], [2014]),
    "Unconventional Technology Consultant – Part-Time",
    supplement: [#link("https://en.wikipedia.org/wiki/London", "London")],
    [
      - Provided troubleshooting for haunted answering machines, sentient software, and vintage electronics.
      - Implemented holistic diagnostics, improving technology-cohabitation harmony by 47%.
    ]
  )

  == Education
  #make-main-content-block-with-timeline(
    ([2014], [2015]),
    "MSc in Applied Holistic Sciences",
    supplement: [#link("https://www.cam.ac.uk/", "University of Cambridge")],
    [
      Specialised in advanced interconnectedness analytics, time anomaly mitigation, and cross-dimensional case studies.
      - Research thesis: "_The Practical Applications of Quantum Uncertainty in Everyday Detection._"
      - Elected chair of the Society for Random Investigations and Improvised Solutions.
    ]
  )
  #make-main-content-block-with-timeline(
    ([2011], [2014]),
    "BA (Hons) in Holistic Detection",
    supplement: [#link("https://www.cam.ac.uk/", "University of Cambridge")],
    [
      Developed a rigorous understanding of the fundamental interconnectedness of all things.\
      - Focus on quantum paradoxes, time travel theory, and sofa geometry.\
      - President of the Pizza Appreciation Society, founding member of the Parapsychology Club.
    ]
  )
  #make-main-content-block-with-timeline(
    ([2008], [2011]),
    "A-Levels",
    supplement: [#link("https://www.longroad.ac.uk/", "Long Road College")],
    [
      Philosophy, Physics, and Strange Occurrences
      - Achieved top marks in unorthodox reasoning and creative logic.
      - Winner of the “Most Unlikely Solution” award (two consecutive years).
      - Organised the annual Quantum Cat Hide-and-Seek competition.
    ]
  )
]

#let aside-content-1 = [
  #make-aside-persona(
    name,
    pronouns: pronouns,
    short-description: short-description,
    image: profile-image,
    theme: theme,
  )

  #make-aside-grid(
    theme: theme,
    iconer-stack("calendar"),
    [March #nth(17, sup: true), 1958],
    iconer-stack("map-marker-alt"),
    [Cambridge, UK],
    iconer-stack("globe"),
    [#link("https://holisticdetective.co.uk", "holisticdetective.co.uk")],
    iconer-stack("phone"),
    [#link("tel:+44 800 PARADOX", [+44 800 PARADOX])],
    iconer-stack("at"),
    [#link("mailto:dirk@holisticdetective.co.uk", "dirk@holisticdetective.co.uk")],
  )

  == Social Network
  #make-aside-grid(
    theme: theme,
    iconer("linkedin"),
    [#link("https://linkedin.com/in/JeppeKlitgaard", "dirkgently")],
    iconer("github"),
    [#link("https://github.com/JeppeKlitgaard", "HolisticDirk")],
  )

  == Languages
  #make-aside-grid(
    columns: 3,
    rows: 12pt,
    align: (horizon + center, horizon + left, horizon + right),
    theme: theme,
    flag("GB"),
    [English],
    dot-ratings(5, 5),
    flag("FR"),
    [French-ish],
    dot-ratings(4, 5),
    flag("GR"),
    [Ancient Greek],
    dot-ratings(3, 5),
  )

  == Hard Skills
  #make-aside-grid(
    columns: 2,
    theme: theme,
    iconer("project-diagram"), [Interconnection Detection],
    iconer("hourglass-half"), [Time Paradox Wrangling],
    iconer("cat"), [Quantum Cat Rescue],
    iconer("dice"), [Luck-as-a-Service],
    iconer("rocket"), [Interdimensional Travel],
  )

  == Soft Skills
  #make-aside-grid(
    columns: 2,
    theme: theme,
    iconer("lightbulb"), [Intuitive Hunching],
    iconer("sun"), [Stubborn Optimism],
    iconer("hat-wizard"), [Charming Eccentricity],
    iconer("comment-dots", solid: true), [Persurasive Rambling],
  )
]

// Page 2
#let main-content-2 = [
  == Awards
  #[
    #set par(spacing: 0.0em, leading: 0.3em)

    #make-main-content-block-with-timeline(
      [2021],
      [Lifetime Achievement in Holistic Detection],
      supplement: [Self-Awarded],
      [],
      title-as-heading: false,
      timeline-line-gap: 0pt,
    )
    #make-main-content-block-with-timeline(
      [2018],
      "Holistic Detective of the Year",
      supplement: [British Association of Unorthodox],
      [],
      title-as-heading: false,
      timeline-line-gap: 0pt,
    )
    #make-main-content-block-with-timeline(
      [2020],
      "Outstanding Coincidence Resolution",
      supplement: [Society for Applied Serendipity],
      [],
      title-as-heading: false,
      timeline-line-gap: 0pt,
    )
    #make-main-content-block-with-timeline(
      [2015],
      [#nth(2, sup: true) Place, Annual Sofa Relocation Challenge],
      supplement: [Royal Society of Furniture Physics],
      [],
      title-as-heading: false,
      timeline-line-gap: 0pt,
    )
  ]

  #v(-0.8em)
  == Other Certifications
  #make-main-content-block-with-timeline(
    [2013],
    [Certified Interdimensional Liaison],
    supplement: [UK Council of Multiversal Affairs],
    [A\*(a\*) grade],
    timeline-line-gap: 0pt,
  )
  #make-main-content-block-with-timeline(
    [2018],
    [Chronological Irregularity Investigator],
    supplement: [Temporal Anomaly Bureau],
    [Registration valid until January #nth(3), 2318.]
  )

  == Association and Voluntary Work
  #make-main-content-block-with-timeline(
    ([2020], [2019]),
    "Chair of the Board",
    supplement: [Sofa Displacement Prevention Society],
    [
      Leads strategic initiatives to address and investigate the mysterious phenomena of sofas becoming inexplicably stuck in stairwells and hallways across the UK.
    ]
  )
  #make-main-content-block-with-timeline(
    ([Present], [2020]),
    "Temporal Confusion Helpline Advisor",
    supplement: [Society for Safe Timekeeping],
    [
      Offers comfort and pragmatic (if peculiar) solutions to individuals experiencing minor chronological disturbances.
      - Provides advice on time loops, déjà vu, and misplaced temporal objects.
    ]
  )
  #make-main-content-block-with-timeline(
    ([2018], [2016]),
    "Midnight Ghost Walk Guide",
    supplement: [#link("https://www.camden.gov.uk/", "Camden Borough Historical Society")],
    [
      Led educational (and occasionally interactive) tours on local hauntings and spectral residents.
    ]
  )

  == References
  #make-main-content-block-with-timeline(
    [2023],
    "Honourable Lord Marmaduke Whiskerson III",
    supplement: [Pet Extraordinaire],
    [
      "_Impeccable pet recovery, albeit numerous unexpected surcharges_"\
      Letter of recommendation available upon request.
    ],
    timeline-line-gap: 0pt,
  )

  #make-main-content-block-with-timeline(
    [2020],
    "Dr Thelma Quibble",
    supplement: [Chair, Institute for Chronological Mishaps],
    [
      "_While he may be chronologically impaired, his insights into time-related phenomena are unparalleled._"\
      Letter of recommendation available here: #linker-pdf("https://timetraveler.wiki/", "dr_quibble.pdf")
    ],
    timeline-line-gap: 0pt,
  )

  == Other Documents
  #[
    #set text(size: 9pt)

    #grid(
      columns: 2,
      align: (left, left),
      column-gutter: 2em,
      row-gutter: 6pt,

      [Chronological Irregularity Inspector Certificate], linker-pdf("https://www.google.com/", "cert_chron_irreg.pdf"),
      [Interdimensional Relations Diploma], linker-pdf("https://www.google.com/", "diploma_inter_rels.pdf"),
    )

  ]

  // Footer
  #v(1fr)
  #grid(
    columns: (1fr, 2fr, 1fr),
    align: (center + horizon, center + horizon, center + horizon),
    {
      let today = datetime.today()
      let day = nth(today.display("[day padding:none]"), sup: true)
      let month = today.display("[month repr:long]")
      let year = today.display("[year]")
      text([#month #day, #year], fill: th("secondary-text-color"), weight: "semibold")
    },
    [
      #image("assets/signature.svg", height: 3em)
    ],
    text(name,
      fill: th("secondary-text-color"),
      weight: "semibold",
    ),
  )
]

#let aside-content-2 = [
  #make-aside-persona(
    name,
    short-description: short-description,
    theme: theme,
  )

  == Detection Techniques
  #make-aside-grid(
    columns: 3,
    align: (horizon + center, horizon + left, horizon + right),
    theme: theme,
    iconer("taxi"), [Taxi Logic], dot-ratings(5, 5),
    iconer("cat"), [Cat Sense], dot-ratings(4, 5),
    iconer("hourglass-half"), [Time Reversal], dot-ratings(4, 5),
    iconer("pizza-slice"), [Pizza Stakeout], dot-ratings(5, 5),
    iconer("project-diagram"), [Clue Weaving], dot-ratings(3, 5),
    iconer("ghost"), [Paranormal], dot-ratings(2, 5),
    iconer("lightbulb"), [Hunch Jumping], dot-ratings(4, 5),
    iconer("dice"), [Dumb Luck], dot-ratings(5, 5),
    iconer("question"), [Wild Guessing], dot-ratings(3, 5),
  )

  == Problem Solving Skills
  #make-aside-grid(
    columns: 3,
    align: (horizon + center, horizon + left, horizon + right),
    theme: theme,
    iconer("microchip"), [Tech Taming], dot-ratings(3, 5),
    iconer("hammer"), [Percussive], dot-ratings(4, 5),
    iconer("ruler"), [Non-Euclidean], dot-ratings(2, 5),
    iconer("power-off"), [Rebooting], dot-ratings(5, 5),
  )

  == Case Portfolio
  #let pill = body => make-pill(body, theme)

  #pill("Wandering Cat")
  #pill("Poltergeists")
  #pill("Tea Time Paradox")
  #pill("Ghosts")
  #pill("Sofa Teleportation")
  #pill("Dodos")
  #pill("Haunted Hog")
  #pill("Rickshaws")
  #pill("Vanishing Pizza")
  #pill("Time Loops")
  #pill("Ghost Wi-Fi")
  #pill("Haunts")
  #pill("Perpetual Coincidence")
  #pill("Broken Time")
  #pill("Raining Fish")
  #pill("Evasive Shadow")
  #pill("Psychic Postcard")
  #pill("Cat Relocation")
  #pill("Burial Sites")
  #pill("Mythical Creatures")
]

// Generate CV
#cv(
  theme: theme,
  paper: "a4",
  pages-content: (
    ("left": aside-content-1, "main": main-content-1),
    ("left": aside-content-2, "main": main-content-2),
  ),
)
