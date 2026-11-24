// Example CV using the yaaacv package.
// After installing the package, compile with:  typst compile main.typ

#import "@preview/yaaacv:0.1.0": *

#show: cv.with(language: "en")

#cvheader(
  (
    firstname: [First],
    lastname: [Lastname],
    tagline: [Job Title | \
    One-line personal pitch],
    photo: image("photo.jpg", width: photo-diameter, height: photo-diameter, fit: "cover"),
    linkedin: "handle",
    github: "handle",
    github-pages: none,
    phone: [+00 000 000 00 00],
    email: "your.name@example.com",
    address: [Street 1, 00000 City],
    info: [Born on 01.01.1990 | City, Country],
  ),
)

#section-title[Competences][#fa-tasks]

#keywords(
  keywords-entry("Label", [*Highlight*, plain, plain]),
  keywords-entry("Label", [item, item, item, #cv-link("https://example.com")[linked item]]),
)

#section-title[Experience][#fa-suitcase]

#experience(
  [Month 20XX],
  [Job Title at Company],
  website("https://www.example.com", []),
  [City],
  [Month 20XX],
  [
    One-paragraph summary of role and responsibilities.
    - Achievement or duty one
    - Achievement or duty two
  ],
  ("Tag one", "Tag two", "Tag three"),
)

#empty-separator()

#experience(
  [Month 20XX],
  [Job Title at Company],
  none,
  [City],
  none,
  [
    - One-line responsibility
  ],
  ("Tag one", "Tag two"),
)

#two-column-section(
  {
    section-title[Languages][#fa-globe]
    skills(
      skill("Native language", 6),
      skill("Fluent language", 5),
      skill("Conversational", 3),
    )
  },
  {
    section-title[Interests][#fa-plus]
    v(0.4em)
    [
      - Interest or volunteering one
      - Interest or volunteering two
      - Interest or hobby three
    ]
  },
)

#section-title[Education][#fa-mortar-board]

#scholarship(
  scholarship-entry([*20XX - 20XX*], [
    Degree at #website("https://www.example.edu", [University Name]).
    Thesis on topic X, grade Y.
  ]),
  scholarship-entry([*20XX - 20XX*], [
    Entry-level degree at #website("https://www.example.edu", [School Name])
  ]),
)

#section-title[Projects][#fa-laptop]

#project(
  [Project Name],
  [20XX],
  links: website("https://www.example.com", [example.com]),
  [One-paragraph description of the project and your contribution.],
  ("Tag one", "Tag two", "Tag three"),
)

#project(
  [Project Name],
  [20XX - 20XX],
  links: website("https://www.example.com", [example.com]),
  [
    Description paragraph. \
    Second paragraph after a linebreak.
  ],
  ("Tag one", "Tag two"),
  visible: true,
)
