// Europass CV example — French (fr).
// Persona of Française nationality.  Demonstrates lang="fr" end to end.
// Gender option used here: "undeclared"
#import "@preview/rasko-europass:1.0.0": cv-entry, europass-cv, l

#show: europass-cv.with(
  lang: "fr",
  title: "Curriculum Vitae — Camille Dubois",
  author: "Camille Dubois",

  name: "Camille Dubois",
  photo: "assets/photo-placeholder.svg",
  photo-alt: l("fr").at("photo-alt"),
  address: "Example Street 1",
  city: "Paris",
  phone: "+00 000 000 000",
  email: "fr@europass.example",
  nationality: "Française",
  date-of-birth: "01/01/1990",
  gender: "undeclared",

  work-experience: (
    cv-entry(
      date-start: "2021", date-end: "",
      title: "Ingénieure logiciel senior",
      organization: "European Tech Solutions",
      location: "Paris",
      description: [- A dirigé une équipe de six ingénieurs sur des services cloud natifs.],
    ),
  ),
  education: (
    cv-entry(
      date-start: "2013", date-end: "2015",
      title: "Master en informatique",
      organization: "Université Paris-Cité",
      location: "Paris",
    ),
  ),

  mother-tongue: "Français",
  other-languages: (
    (lang: "Anglais", listening: "C1", reading: "C1",
     interaction: "B2", production: "B2", writing: "C1"),
  ),
  digital-skills: [- Python, Docker, Kubernetes, PostgreSQL],

  signature-place: "Paris",
  signature-date: "2025",
)
