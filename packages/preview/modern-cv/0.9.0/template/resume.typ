#import "@preview/modern-cv:0.9.0": *

#show: resume.with(
  author: (
    firstname: "John",
    lastname: "Smith",
    email: "js@example.com",
    homepage: "https://example.com",
    phone: "(+1) 111-111-1111",
    github: "DeveloperPaul123",
    twitter: "typstapp",
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
  profile-picture: image("profile.png"),
  date: datetime.today().display(),
  language: "en",
  colored-headers: true,
  show-footer: false,
  show-address-icon: true,
  paper-size: "us-letter",
)

= Experience

#resume-entry(
  title: "Senior Software Engineer",
  location: "Example City, EX",
  date: "2019 - Present",
  description: "Example, Inc.",
  title-link: "https://github.com/DeveloperPaul123",
)

#resume-item[
  - #lorem(20)
  - #lorem(15)
  - #lorem(25)
]

#resume-entry(
  title: "Software Engineer",
  location: "Example City, EX",
  date: "2011 - 2019",
  description: "Previous Company, Inc.",
)

#resume-item[
  // content doesn't have to be bullet points
  #lorem(72)
]

#resume-entry(title: "Intern", location: "Example City, EX")

#resume-item[
  - #lorem(20)
  - #lorem(15)
  - #lorem(25)
]

= Projects

#resume-entry(
  title: "Thread Pool C++ Library",
  location: [#github-link("DeveloperPaul123/thread-pool")],
  date: "May 2021 - Present",
  description: "Designer/Developer",
)

#resume-item[
  - Designed and implemented a thread pool library in C++ using the latest C++20 and C++23 features.
  - Wrote extensive documentation and unit tests for the library and published it on Github.
]

#resume-entry(
  title: "Event Bus C++ Library",
  location: github-link("DeveloperPaul123/eventbus"),
  date: "Sep. 2019 - Present",
  description: "Designer/Developer",
)

#resume-item[
  - Designed and implemented an event bus library using C++17.
  - Wrote detailed documentation and unit tests for the library and published it on Github.
]

= Skills

#resume-skill-item(
  "Programming Languages",
  (
    strong("C++"),
    strong("Python"),
    "Rust",
    "Java",
    "C#",
    "JavaScript",
    "TypeScript",
  ),
)
#resume-skill-item("Spoken Languages", (strong("English"), "Spanish"))
#resume-skill-item(
  "Programs",
  (
    strong("Excel"),
    "Word",
    "Powerpoint",
    "Visual Studio",
  ),
)
// spacing fix, not needed if you use `resume-skill-grid`
#block(below: 0.65em)

// An alternative way of list out your resume skills
// #resume-skill-grid(
//   categories_with_values: (
//     "Programming Languages": (
//       strong("C++"),
//       strong("Python"),
//       "Rust",
//       "Java",
//       "C#",
//       "JavaScript",
//       "TypeScript",
//     ),
//     "Spoken Languages": (
//       strong("English"),
//       "Spanish",
//       "Greek",
//     ),
//     "Programs": (
//       strong("Excel"),
//       "Word",
//       "Powerpoint",
//       "Visual Studio",
//       "git",
//       "Zed"
//     ),
//     "Really Really Long Long Long Category": (
//       "Thing 1",
//       "Thing 2",
//       "Thing 3"
//     )
//   ),
// )

= Education

#resume-entry(
  title: "Example University",
  location: "Example City, EX",
  date: "August 2014 - May 2019",
  description: "B.S. in Computer Science",
)

#resume-item[
  - #lorem(20)
  - #lorem(15)
  - #lorem(25)
]
