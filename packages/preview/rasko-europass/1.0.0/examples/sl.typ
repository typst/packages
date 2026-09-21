// Europass CV example — Slovenian (sl).
// Persona of Slovenka nationality.  Demonstrates lang="sl" end to end.
// Gender option used here: "female"
#import "../lib.typ": cv-entry, europass-cv, l

#show: europass-cv.with(
  lang: "sl",
  title: "Curriculum Vitae — Maja Novak",
  author: "Maja Novak",

  name: "Maja Novak",
  photo: "assets/photo-placeholder.svg",
  photo-alt: l("sl").at("photo-alt"),
  address: "Example Street 1",
  city: "Ljubljana",
  phone: "+00 000 000 000",
  email: "sl@europass.example",
  nationality: "Slovenka",
  date-of-birth: "01/01/1990",
  gender: "female",

  work-experience: (
    cv-entry(
      date-start: "2021", date-end: "",
      title: "Višja programska inženirka",
      organization: "European Tech Solutions",
      location: "Ljubljana",
      description: [- Vodila je šestčlansko ekipo inženirjev na cloud-native storitvah.],
    ),
  ),
  education: (
    cv-entry(
      date-start: "2013", date-end: "2015",
      title: "Magisterij iz informatike",
      organization: "Univerza v Ljubljani",
      location: "Ljubljana",
    ),
  ),

  mother-tongue: "Slovenščina",
  other-languages: (
    (lang: "Angleščina", listening: "C1", reading: "C1",
     interaction: "B2", production: "B2", writing: "C1"),
  ),
  digital-skills: [- Python, Docker, Kubernetes, PostgreSQL],

  signature-place: "Ljubljana",
  signature-date: "2025",
)
