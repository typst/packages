// Europass CV example — Bulgarian (bg).
// Persona of Българин nationality.  Demonstrates lang="bg" end to end.
// Gender option used here: "male"
#import "@preview/rasko-europass:1.0.0": cv-entry, europass-cv, l

#show: europass-cv.with(
  lang: "bg",
  title: "Curriculum Vitae — Георги Иванов",
  author: "Георги Иванов",

  name: "Георги Иванов",
  photo: "assets/photo-placeholder.svg",
  photo-alt: l("bg").at("photo-alt"),
  address: "Example Street 1",
  city: "София",
  phone: "+00 000 000 000",
  email: "bg@europass.example",
  nationality: "Българин",
  date-of-birth: "01/01/1990",
  gender: "male",

  work-experience: (
    cv-entry(
      date-start: "2021", date-end: "",
      title: "Старши софтуерен инженер",
      organization: "European Tech Solutions",
      location: "София",
      description: [- Ръководи екип от шест инженери по cloud-native услуги.],
    ),
  ),
  education: (
    cv-entry(
      date-start: "2013", date-end: "2015",
      title: "Магистър по информатика",
      organization: "Софийски университет",
      location: "София",
    ),
  ),

  mother-tongue: "Български",
  other-languages: (
    (lang: "Английски", listening: "C1", reading: "C1",
     interaction: "B2", production: "B2", writing: "C1"),
  ),
  digital-skills: [- Python, Docker, Kubernetes, PostgreSQL],

  signature-place: "София",
  signature-date: "2025",
)
