// Europass CV example — Finnish (fi).
// Persona of Suomalainen nationality.  Demonstrates lang="fi" end to end.
// Gender option used here: "female"
#import "@preview/rasko-europass:1.0.0": cv-entry, europass-cv, l

#show: europass-cv.with(
  lang: "fi",
  title: "Curriculum Vitae — Aino Virtanen",
  author: "Aino Virtanen",

  name: "Aino Virtanen",
  photo: "assets/photo-placeholder.svg",
  photo-alt: l("fi").at("photo-alt"),
  address: "Example Street 1",
  city: "Helsinki",
  phone: "+00 000 000 000",
  email: "fi@europass.example",
  nationality: "Suomalainen",
  date-of-birth: "01/01/1990",
  gender: "female",

  work-experience: (
    cv-entry(
      date-start: "2021", date-end: "",
      title: "Senior-ohjelmistoinsinööri",
      organization: "European Tech Solutions",
      location: "Helsinki",
      description: [- Johti kuuden insinöörin tiimiä cloud-native-palveluissa.],
    ),
  ),
  education: (
    cv-entry(
      date-start: "2013", date-end: "2015",
      title: "DI, tietojenkäsittelytekniikka",
      organization: "Aalto-yliopisto",
      location: "Helsinki",
    ),
  ),

  mother-tongue: "Suomi",
  other-languages: (
    (lang: "Englanti", listening: "C1", reading: "C1",
     interaction: "B2", production: "B2", writing: "C1"),
  ),
  digital-skills: [- Python, Docker, Kubernetes, PostgreSQL],

  signature-place: "Helsinki",
  signature-date: "2025",
)
