// Europass CV example — Dutch (nl).
// Persona of Nederlander nationality.  Demonstrates lang="nl" end to end.
// Gender option used here: omitted
#import "../lib.typ": cv-entry, europass-cv, l

#show: europass-cv.with(
  lang: "nl",
  title: "Curriculum Vitae — Daan de Vries",
  author: "Daan de Vries",

  name: "Daan de Vries",
  photo: "assets/photo-placeholder.svg",
  photo-alt: l("nl").at("photo-alt"),
  address: "Example Street 1",
  city: "Amsterdam",
  phone: "+00 000 000 000",
  email: "nl@europass.example",
  nationality: "Nederlander",
  date-of-birth: "01/01/1990",

  work-experience: (
    cv-entry(
      date-start: "2021", date-end: "",
      title: "Senior software-engineer",
      organization: "European Tech Solutions",
      location: "Amsterdam",
      description: [- Leidde een team van zes engineers voor cloud-native diensten.],
    ),
  ),
  education: (
    cv-entry(
      date-start: "2013", date-end: "2015",
      title: "Master informatica",
      organization: "Universiteit van Amsterdam",
      location: "Amsterdam",
    ),
  ),

  mother-tongue: "Nederlands",
  other-languages: (
    (lang: "Engels", listening: "C1", reading: "C1",
     interaction: "B2", production: "B2", writing: "C1"),
  ),
  digital-skills: [- Python, Docker, Kubernetes, PostgreSQL],

  signature-place: "Amsterdam",
  signature-date: "2025",
)
