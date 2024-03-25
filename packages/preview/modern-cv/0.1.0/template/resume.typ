#import "@preview/modern-cv:0.1.0": *

#show: resume.with(
  author: (
      firstname: "John", 
      lastname: "Smith",
      email: "js@example.com", 
      phone: "(+1) 111-111-1111",
      github: "DeveloperPaul123",
      linkedin: "Example",
      address: "111 Example St. Example City, EX 11111",
      positions: (
        "Software Engineer",
        "Software Architect"
      )
  ),
  date: datetime.today().display()
)

= Education

#resume_entry(
  title: "Example University",
  location: "B.S. in Computer Science",
  date: "August 2014 - May 2019",
  description: "Example"
)

#resume_item[
  - #lorem(20)
  - #lorem(15)
  - #lorem(25)  
]

= Experience

#resume_entry(
  title: "Example, Inc.",
  location: "Example City, EX",
  date: "2019 - Present",
  description: "Senior Software Engineer"
)

#resume_item[
  - #lorem(20)
  - #lorem(15)
  - #lorem(25)  
]

#resume_entry(
  title: "Previous Company, Inc.",
  location: "Example City, EX",
  date: "2011 - 2019",
  description: "Software Engineer"
)

#resume_item[
  - #lorem(20)
  - #lorem(15)
  - #lorem(25)  
]

= Projects

#resume_entry(
  title: "Thread Pool C++ Library",
  location: [#github_link("DeveloperPaul123/thread-pool")],
  date: "May 2021 - Present",
  description: "Designer/Developer"
)

#resume_item[
  - Designed and implemented a thread pool library in C++ using the latest C++20 and C++23 features.
  - Wrote extensive documentation and unit tests for the library and published it on Github.
]

#resume_entry(
  title: "  Event Bus C++ Library",
  location: github_link("DeveloperPaul123/eventbus"),
  date: "Sep. 2019 - Present",
  description: "Designer/Developer"
)

#resume_item[
  - Designed and implemented an event bus library using C++17.
  - Wrote detailed documentation and unit tests for the library and published it on Github.
]

= Skills

#resume_skill_item("Programming Languages", (strong("C++"), "Python", "Java", "C#", "JavaScript", "TypeScript"))
#resume_skill_item("Spoken Languages", (strong("English"), "Spanish"))
#resume_skill_item("Programs", (strong("Excel"),"Word"))
