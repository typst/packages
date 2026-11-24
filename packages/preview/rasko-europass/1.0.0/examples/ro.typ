// Europass CV example — Romanian (ro).
// Persona of Român nationality.  Demonstrates lang="ro" end to end.
// Gender option used here: "male"
#import "@preview/rasko-europass:1.0.0": cv-entry, europass-cv, l

#show: europass-cv.with(
  lang: "ro",
  title: "Curriculum Vitae — Andrei Popescu",
  author: "Andrei Popescu",

  name: "Andrei Popescu",
  photo: "assets/photo-placeholder.svg",
  photo-alt: l("ro").at("photo-alt"),
  address: "Example Street 1",
  city: "București",
  phone: "+00 000 000 000",
  email: "ro@europass.example",
  nationality: "Român",
  date-of-birth: "01/01/1990",
  gender: "male",

  work-experience: (
    cv-entry(
      date-start: "2021", date-end: "",
      title: "Inginer software senior",
      organization: "European Tech Solutions",
      location: "București",
      description: [- A coordonat o echipă de șase ingineri pe servicii cloud-native.],
    ),
  ),
  education: (
    cv-entry(
      date-start: "2013", date-end: "2015",
      title: "Master în informatică",
      organization: "Universitatea din București",
      location: "București",
    ),
  ),

  mother-tongue: "Română",
  other-languages: (
    (lang: "Engleză", listening: "C1", reading: "C1",
     interaction: "B2", production: "B2", writing: "C1"),
  ),
  digital-skills: [- Python, Docker, Kubernetes, PostgreSQL],

  signature-place: "București",
  signature-date: "2025",
)
