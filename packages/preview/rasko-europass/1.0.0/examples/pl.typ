// Europass CV example — Polish (pl).
// Persona of Polka nationality.  Demonstrates lang="pl" end to end.
// Gender option used here: "female"
#import "../lib.typ": cv-entry, europass-cv, l

#show: europass-cv.with(
  lang: "pl",
  title: "Curriculum Vitae — Zofia Kowalska",
  author: "Zofia Kowalska",

  name: "Zofia Kowalska",
  photo: "assets/photo-placeholder.svg",
  photo-alt: l("pl").at("photo-alt"),
  address: "Example Street 1",
  city: "Warszawa",
  phone: "+00 000 000 000",
  email: "pl@europass.example",
  nationality: "Polka",
  date-of-birth: "01/01/1990",
  gender: "female",

  work-experience: (
    cv-entry(
      date-start: "2021", date-end: "",
      title: "Starsza inżynier oprogramowania",
      organization: "European Tech Solutions",
      location: "Warszawa",
      description: [- Kierowała sześciuosobowym zespołem inżynierów usług cloud-native.],
    ),
  ),
  education: (
    cv-entry(
      date-start: "2013", date-end: "2015",
      title: "Magister informatyki",
      organization: "Uniwersytet Warszawski",
      location: "Warszawa",
    ),
  ),

  mother-tongue: "Polski",
  other-languages: (
    (lang: "Angielski", listening: "C1", reading: "C1",
     interaction: "B2", production: "B2", writing: "C1"),
  ),
  digital-skills: [- Python, Docker, Kubernetes, PostgreSQL],

  signature-place: "Warszawa",
  signature-date: "2025",
)
