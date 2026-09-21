// Europass CV example — Estonian (et).
// Persona of Eestlane nationality.  Demonstrates lang="et" end to end.
// Gender option used here: "female"
#import "../lib.typ": cv-entry, europass-cv, l

#show: europass-cv.with(
  lang: "et",
  title: "Curriculum Vitae — Kadri Tamm",
  author: "Kadri Tamm",

  name: "Kadri Tamm",
  photo: "assets/photo-placeholder.svg",
  photo-alt: l("et").at("photo-alt"),
  address: "Example Street 1",
  city: "Tallinn",
  phone: "+00 000 000 000",
  email: "et@europass.example",
  nationality: "Eestlane",
  date-of-birth: "01/01/1990",
  gender: "female",

  work-experience: (
    cv-entry(
      date-start: "2021", date-end: "",
      title: "Vanemtarkvaraarendaja",
      organization: "European Tech Solutions",
      location: "Tallinn",
      description: [- Juhtis kuueliikmelist inseneride meeskonda cloud-native teenuste väljatöötamisel.],
    ),
  ),
  education: (
    cv-entry(
      date-start: "2013", date-end: "2015",
      title: "Magister informaatikas",
      organization: "Tallinna Tehnikaülikool",
      location: "Tallinn",
    ),
  ),

  mother-tongue: "Eesti",
  other-languages: (
    (lang: "Inglise", listening: "C1", reading: "C1",
     interaction: "B2", production: "B2", writing: "C1"),
  ),
  digital-skills: [- Python, Docker, Kubernetes, PostgreSQL],

  signature-place: "Tallinn",
  signature-date: "2025",
)
