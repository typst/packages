#import "@preview/moderner-cv:0.1.2": *

#show: moderner-cv.with(
  name: "Jane Doe",
  lang: "en",
  social: (
    // predefined socials: phone, email, github, linkedin, x, bluesky
    email: "jane.doe@example.com",
    github: "jane-doe",
    linkedin: "jane-doe",
    // custom socials: (icon, link, body)
    // any fontawesome icon can be used: https://fontawesome.com/search
    website: ("link", "https://example.me", "example.me"),
  ),
)

= Education

#cv-entry(
  date: [2021 -- 2024],
  title: [M.Sc. Ophiology],
  employer: [Cobra Creek College],
)[3.9/4.0]
#cv-entry(
  date: [2018 -- 2021],
  title: [B.Sc. Herpetology],
  employer: [Serpentis University],
)[4.0/4.0]

= Experience

#cv-entry(
  date: [4/2022 -- 7/2023],
  employer: [The Snake Company],
  title: [Snake Specialist],
  [#linebreak()#text(10pt, lorem(30))],
)
#cv-entry(
  date: [4/2022 -- 7/2023],
  employer: [Viper Ventures],
  title: [Working Student],
  [#linebreak()#text(10pt, lorem(30))],
)

= Programming Skills

#cv-double-item[
  Languages
][
  Python
][
  Technologies
][
  Conda, Boa, Rattler-build
]

= Languages

#cv-double-item[English][Native][French][Fluent]
#cv-line[Dutch][Advanced]

= Hobbies

#cv-list-double-item[Snake Spotting][Collecting Venom]
