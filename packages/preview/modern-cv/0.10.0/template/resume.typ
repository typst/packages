#import "@preview/modern-cv:0.10.0": *

#show: resume.with(
  author: (
    firstname: "John",
    lastname: "Smith",
    email: "js@example.com",
    homepage: "https://example.com",
    phone: "(+1) 111-111-1111",
    github: "ptsouchlos",
    gitlab: "ptsouchlos",
    bitbucket: "DeveloperPaul123",
    twitter: "typstapp",
    bluesky: "ptsou.bsky.social",
    mastodon: "devpaul",
    scholar: "",
    orcid: "0000-0000-0000-000X",
    birth: "January 1, 1990",
    linkedin: "Example",
    address: "111 Example St. Example City, EX 11111",
    positions: (
      "Software Engineer",
      "Software Architect",
      "Developer",
    ),
    custom: (
      (
        text: "Youtube Channel",
        icon: "youtube",
        link: "https://example.com",
      ),
    ),
  ),
  keywords: ("Engineer", "Architect"),
  description: "John complete resume",
  profile-picture: image("assets/profile.png"),
  date: datetime.today().display(),
  language: "en",
  colored-headers: true,
  show-footer: false,
  show-address-icon: true,
  paper-size: "us-letter",
  contact-items-separator: box[#h(2pt)#text("|")#h(2pt)],
)

#include "sections/projects.typ"
#include "sections/experience.typ"
#include "sections/skills.typ"
#include "sections/education.typ"
