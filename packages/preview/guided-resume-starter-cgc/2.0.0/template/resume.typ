#import "@preview/guided-resume-starter-cgc:2.0.0": *

#show: resume.with(
  author: "Dr. Emmit \"Doc\" Brown",
  location: "Hill Valley, CA",
  contacts: (
    [#link("mailto:sample_resume@chaoticgood.computer")[Email]],
    [#link("https://chaoticgood.computer")[Website]],
    [#link("https://github.com/spelkington")[GitHub]],
    [#link("https://linkedin.com/in/spelkington")[LinkedIn]],
  ),
  // footer: [#align(center)[#emph[References available on request]]]
)

= Education
#edu(
  institution: "University of California, Berkeley",
  date: "Aug 1953",
  location: "Berkeley, CA",
  degrees: (
    ("Ph.D.", "Theoretical Physics"),
  ),
)

#edu(
  institution: "University of Colombia",
  date: "Aug 1948",
  gpa: "3.9 of 4.0, Summa Cum Laude",
  degrees: (
    ("Bachelor's of Science", "Nuclear Engineering"),
    ("Minors", "Automobile Design, Arabic"),
    ("Focus", "Childcare, Education")
  ),
)

= Skills
#skills((
  ("Expertise", (
    [Theoretical Physics],
    [Time Travel],
    [Nuclear Material Management],
    [Student Mentoring],
    // [Ethics],
    // [Hair Cair],
    // [Jumpsuit Design],
    // [Conflict Resolution],
  )),
  ("Software", (
    [AutoDesk CAD],
    [Delorean OS],
    [Windows 1],
    // [Microsoft Word],
    // [Car Maintenance],
  )),
  ("Languages", (
    [C++],
    [C Language],
    [MatLab],
    [Punch Cards],
    // [Python],
    // [C\#]
  )),
))


= Experience
#exp(
  role: "Theoretical Physics Consultant",
  project: "Doc Brown's Garage",
  date: "June 1953 - Oct 2015",
  location: "Hill Valley, CA",
  summary: "Specializing in development of time travel devices and student tutoring",
  details: [
    - Lead development of time travel devices, resulting in the ability to travel back and forth through time
    - Managed and executed a budget of \$14 million dollars gained from an unexplained family fortune
    - Oversaw QA testing for time travel devices, minimizing risk of maternal time-travel related incidents
  ]
)

#exp(
  role: "Teaching Assistant",
  project: "University of Colombia, Wernher von Braun Lab",
  date: "Oct 1949 - June 1953",
  summary: "Integrating German scientists' curriculi for undergraduate audiences",
  details: [
    - Assisted in designing physics course structure and assignments in English, Spanish and German
    - Designed confidential rocket designs used in NASA Space Race initiatives and the Apollo Program
    - Developed and executed university DEI initiatives and onboarding programs for transfer professors
  ]
)


= Projects
#exp(
  role: link("https://www.imdb.com/title/tt0088763/")[The Delorean],
  project: "Doc Brown's Garage",
  date: "May 1954 - June 1985",
  summary: "A stylish and fully-featured vehicle capable of time travel - with mixed results",
  details: [
    - Designed vehicle modifications allowing for time travel and *37% increased cup holder capacity*
    - Ethically sourced materials from various international Colombian and Libyan providers
    - Coordinated business relationships with potential clients and interested parties
  ]
)

#exp(
  role: "Doc Brown's Mega Cup-o-Matic",
  project: "Doc Brown's Garage",
  date: "October 1949 - June 1953",
  details: [
    - Filed a patent for a new type of car cupholder, for storing cups of nuclear material up to 1L
    - Developed nuclear hazard procedures for high school students interested in time and nuclear physics
  ]
)


= Volunteering
#exp(
  role: "Student Advisor",
  project: "Doc's Kidz After-School Child Care Service",
  date: "May 1954 - June 1985",
  summary: "Giving random highschoolers hands-on experience in live nuclear engineering",
  details: [
    - Created community initiative to teach local student(s) about the wonders of nuclear physics
    - Provided interesting time travel research opportunities for students to add to their college applications
  ]
)