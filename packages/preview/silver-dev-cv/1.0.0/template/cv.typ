#import "@preview/silver-dev-cv:1.0.0": *

#show: cv.with(
  font-type: "PT Serif",
  continue-header: "false",
  name: "John Doe",
  address: "City, Country",
  lastupdated: "true",
  pagecount: "true",
  date: "2024-07-03",
  contacts: (
    (text: "your portfolio", link: "https://www.example.com"),
    (text: "your github", link: "https://www.github.com"),
    (text: "your email address", link: "mailto:123@example.com"),
  ),
)

// about
#section[about]
#descript[This section is your opportunity to showcase your profile, what you know to do, and what you seek in your career. You should write a brief overview that highlights your profile's key strengths.]
#sectionsep
//Experience
#section("Experience")
#job(
  position: "Software Engineer",
  institution: [Company's name],
  location: [Location],
  date: "date-date",
  description: [
    - Here you want to show whoever is reading your resume your responsibilities and achievements at the company.
    - Don't just list the techs you used, but rather showcase how you impacted the projects you worked on (even using metrics if applicable).
    - You can use bullet points to format this section, but no more than 5 (with a maximum of 3 lines each).
    - We recommend you list your last 3 professional experiences
  ],
)
#section("Skills")
#oneline-title-item(
  title: "Programming Languages",
  content: [(for example): Python, C++, Java, JavaScript],
)
#sectionsep
#section("Education")
#education(
  institution: [University's Name],
  major: [Your degree],
  date: "date-date",
  location: "Country",
  description: [
    - Write here if you received any awards or academic recognition during your studies
  ],
)
#sectionsep
// Projects
#section("Projects")
#twoline-item(
  entry1: "Project's name",
  entry2: "date",
  description: [This is a good chance to tell the Recruiter/Hiring Manager about a Product you worked on from scratch. It could a web app that helped a local store, a mobile app that solved users needs, etc. The point is to demonstrate your proactivity and sense of ownership.  ],
)
