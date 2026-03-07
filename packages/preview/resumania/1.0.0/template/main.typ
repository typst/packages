#import "@preview/resumania:1.0.0": *

#let author = "Your Name"

#let contacts = contact-section(
  phone: phone("+0 (123) 555-0123"),
  email: email("your.name@example.com"),
  linkedin: url-link(name: "LinkedIn", "example", "https://linkedin.com"),
  github: url-link(name: "GitHub", "example", "https://github.com"),
  location: location[Your Location],
)

#let education = education-section(
  masters: education(
    institution: "Some School",
    location: "Anywhere",
    kind: "M.S.",
    study: "Mechanical Engineering",
    timeframe: datetime(year: 2042, month: 4, day: 2),
    score: 3.44,
    scale: 4.0,
  ),
  undergrad: education(
    institution: "Another School",
    location: "The other place",
    kind: "B.S.",
    study: "Physics",
    timeframe: datetime(year: 2041, month: 4, day: 1),
    score: 3.11,
    scale: 4.0,
  ),
)

#let work = work-section(
  work(
    company: "Some Company",
    location: "Anywhere",
    position: "Mechanical Designer",
    timeframe: (
      start: datetime(year: 2045, month: 08, day: 08),
      end: "Present",
    )
  )[
    - Designed parts to go on aircraft for the future.
    - Ran simulations to ensure parts would meet factors of safety so the final
        product could pass standards.
    - Worked with customers to generate specifications and requirements for the
        aircraft and its features.
  ],
  work(
    company: "A Different Company",
    location: "Somewhere Else",
    position: "Mechanical Engineer Intern",
    timeframe: (
      start: datetime(year: 2040, month: 06, day: 01),
      end: datetime(year: 2040, month: 08, day: 20),
    )
  )[
    - Performed calculations and simulations for structural elements to a space
        elevator that could carry 2 tons of payload.
    - Provided feedback to other engineers regarding the physics behind a space
        elevator and material requirements so it doesn't berak.
  ],
)

#let projects = project-section(
  project(title: "Automatic Pancake Flipper", timeframe: 2044)[
    - Created a machine that automatically flips pancakes
    - Used open-source computer vision libraries to control when the pancakes
        flip.
    - Added input for how brown the panacakes should be.
    - Designed and fabricated everything for the pancake flipper.
    - Collected visual data from more than 123 pancake-making sessions to feed
      the visual model.
  ],
  project(
    title: "Automatic Pancake Maker",
    timeframe: 2043,
  )[
    - Created a machine that automatically makes pancake batter.
    - Used math#sym.trademark to control the robotic arm that picks ingredients.
    - Added a user interface that allows specifying levels of fluffiness,
        alternate ingredients such as blueberries and bananas, and an
        "experiment" mode where it just randomly makes something.
  ],
)

#let skills = skills-section(
  skillset(
    "Simulation",
    "Simulation Software 1",
    "Simulation Design",
    "FEA Software",
  ),
  skillset("Software", "Office Suite", "CAD Software"),
)

#show: resume.with(
  author,
  sections: (contacts, education, work, projects, skills),
)
