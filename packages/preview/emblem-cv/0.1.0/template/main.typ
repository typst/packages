// Emblem CV. Replace the details below with your own and delete what you do not
// need; every section here is optional. The accent colour is set once, on the
// line after this comment, and everything picks it up from there.

#import "@preview/emblem-cv:0.1.0": *

#let accent = "#2f4a3f"

#show: resume.with(
  author: "Nadia Haddad",
  font: "HK Grotesk",
  font-size: 10.5pt,
  paper: "a4",
  margin: 1.5cm,
)

// `initials` draws the filled monogram that anchors the header. Give it two
// letters. For a picture instead, pass image bytes: `photo: read("portrait.jpg",
// encoding: none)`; a bare path would be resolved inside the package.
#masthead(
  author: "Nadia Haddad",
  profession: "Brand Strategist",
  initials: "NH",
  accent-color: accent,
  contact: [
    nadia.haddad\@example.com
    #h(0.6em) | #h(0.6em) +44 20 7946 0311
    #h(0.6em) | #h(0.6em) London, UK
    #h(0.6em) | #h(0.6em) #link("https://example.com/nadia")[example.com/nadia]
  ],
)

#cv-section("Profile", accent-color: accent)

Brand strategist working mostly with businesses that have outgrown the identity
they started with. The work is usually less about a new logo than about deciding
what the company is willing to stop saying. Most of my work ends up being
read aloud in a room, so it has to survive being said out loud.

#cv-section("Experience", accent-color: accent)

#emblem-entry(
  title: "Brand Strategy Lead",
  subtitle: "Fold and Field",
  dates: "2021 - Present",
  location: "London, UK",
)[
  - Led repositioning for 14 clients, from first workshop to launch, including
    three companies going through a merger at the same time.
  - Built the studio's naming and messaging practice from nothing to roughly a
    third of fee income in two years.
  - Set up the post-launch tracking that turned brand work from a matter of
    taste into something the client could see moving.
]

#emblem-entry(
  title: "Senior Strategist",
  subtitle: "Marchand Studio",
  dates: "2018 - 2021",
  location: "London, UK",
)[
  - Ran research and positioning for consumer clients in food, retail and
    fitness, typically alongside a two-person design team.
  - Wrote the tone-of-voice guidelines still in use at four former clients.
  - Introduced the studio's first structured debrief, which turned scattered
    client feedback into something the design team could act on.
]

#emblem-entry(
  title: "Strategist",
  subtitle: "Colefax Brand Consultancy",
  dates: "2016 - 2018",
  location: "Bristol, UK",
)[
  - Qualitative research, competitor audits and the first draft of most decks.
]

#cv-section("Selected Work", accent-color: accent)

#emblem-entry(
  title: "Wilder Kitchen",
  subtitle: "Full repositioning and renaming ahead of national listing",
  dates: "2023",
  meta: "Design Week Award, shortlisted",
)[]

#emblem-entry(
  title: "Harrow Mutual",
  subtitle: "Messaging framework for a 120-year-old insurer",
  dates: "2022",
)[]

#emblem-entry(
  title: "Ostley and Vane",
  subtitle: "Naming and identity for a spin-out legal practice",
  dates: "2021",
)[]

#cv-section("Education", accent-color: accent)

#emblem-entry(
  title: "University of the Arts London",
  subtitle: "MA Applied Imagination",
  dates: "2015 - 2016",
  location: "London, UK",
)[]

#emblem-entry(
  title: "University of Bristol",
  subtitle: "BA English",
  dates: "2012 - 2015",
  location: "Bristol, UK",
)[]

#cv-section("Skills", accent-color: accent)

*Strategy* \
Positioning, naming, messaging architecture, qualitative research, workshop
facilitation, brand tracking.

*Working with* \
Figma, Notion, Keynote, and whichever research panel the client already pays for.

#cv-section("Languages", accent-color: accent)

#emblem-language(language: "English", level: "Native")
#emblem-language(language: "Arabic", level: "Native")
#emblem-language(language: "Italian", level: "Conversational")
