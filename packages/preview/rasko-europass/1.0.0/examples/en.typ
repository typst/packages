// Europass CV example — English (en).
// Persona of Irish nationality.  Demonstrates lang="en" end to end.
// Gender option used here: "female"
#import "@preview/rasko-europass:1.0.0": cv-entry, europass-cv, l

#show: europass-cv.with(
  lang: "en",
  title: "Curriculum Vitae — Aoife Murphy",
  author: "Aoife Murphy",

  name: "Aoife Murphy",
  photo: "assets/photo-placeholder.svg",
  photo-alt: l("en").at("photo-alt"),
  address: "Example Street 1",
  city: "Dublin",
  phone: "+00 000 000 000",
  email: "en@europass.example",
  nationality: "Irish",
  date-of-birth: "01/01/1990",
  gender: "female",

  work-experience: (
    cv-entry(
      date-start: "2021", date-end: "",
      title: "Senior Software Engineer",
      organization: "European Tech Solutions",
      location: "Dublin",
      description: [- Led a team of six engineers on cloud-native services.],
    ),
  ),
  education: (
    cv-entry(
      date-start: "2013", date-end: "2015",
      title: "MSc in Computer Science",
      organization: "Trinity College Dublin",
      location: "Dublin",
    ),
  ),

  mother-tongue: "English",
  other-languages: (
    (lang: "French", listening: "C1", reading: "C1",
     interaction: "B2", production: "B2", writing: "C1"),
  ),
  digital-skills: [- Python, Docker, Kubernetes, PostgreSQL],

  signature-place: "Dublin",
  signature-date: "2025",
)
