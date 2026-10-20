#import "@preview/medieval-resume:0.1.0": *

// Define your personal information
#show: medieval-resume.with(
  author: "Mx. Example Sample",
  // make this as short as possible
  degree: "Ph. Doc.",
  website: "https://example.com",
  email: "example@example.com",
  phonenumber: "+00 123456789",
  lang: "en",

  fonts: "sans-serif",
)

#title()

// A section similar to the description environment
#cv-section(title: [Personal Information])[
  // Use #date with any datetime to format the date accurately with the current text locale
  / Birth: #date("1999-12-31"), Null Island
  / Nationality: Earth
]

#cv-section(title: [Education])[
  // Create a heading describing a place of education.
  #education-heading(
    department: [Department of Computer Science, Electrical Engineering and Information Technology, Stuttgart University],
    degree: [M.Sc. in Computer Linguistics],
    startdate: 2020,
    enddate: [2023 #estimated],
  )
  - Some interesting information about this program (can also be in a normal paragraph instead of a list)

  // You can add more sections with additional #education-heading ...
]

#cv-section(title: [Work and Internships])[
  // A heading describing a place of work, very similar to #education-heading
  #job-heading(
    company: [Imaginary Company AB],
    job: [Internship software development],
    startdate: "2023-05-01",
    enddate: "2025-02-03",
  )
  - Interesting information about the place of work
]

#cv-section(title: [Personal Projects])[
  // A heading describing a project, similar to #job-heading and #education-heading
  #project(
    project-link: "https://example.com/project",
    title: [Example Project],
    startdate: 2022,
    description: [An Example project demonstrating an example],
  )
]

// A section similar to the itemize environment
#cv-section(title: [Strengths])[
  - *Being an example*
  - *Being a good example*
]

