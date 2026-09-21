// Europass CV example — Slovak (sk).
// Persona of Slovenka nationality.  Demonstrates lang="sk" end to end.
// Gender option used here: "female"
#import "../lib.typ": cv-entry, europass-cv, l

#show: europass-cv.with(
  lang: "sk",
  title: "Curriculum Vitae — Jana Kováčová",
  author: "Jana Kováčová",

  name: "Jana Kováčová",
  photo: "assets/photo-placeholder.svg",
  photo-alt: l("sk").at("photo-alt"),
  address: "Example Street 1",
  city: "Bratislava",
  phone: "+00 000 000 000",
  email: "sk@europass.example",
  nationality: "Slovenka",
  date-of-birth: "01/01/1990",
  gender: "female",

  work-experience: (
    cv-entry(
      date-start: "2021", date-end: "",
      title: "Senior softvérová inžinierka",
      organization: "European Tech Solutions",
      location: "Bratislava",
      description: [- Viedla tím šiestich inžinierov na cloud-native službách.],
    ),
  ),
  education: (
    cv-entry(
      date-start: "2013", date-end: "2015",
      title: "Ing., informatika",
      organization: "STU v Bratislave",
      location: "Bratislava",
    ),
  ),

  mother-tongue: "Slovenčina",
  other-languages: (
    (lang: "Angličtina", listening: "C1", reading: "C1",
     interaction: "B2", production: "B2", writing: "C1"),
  ),
  digital-skills: [- Python, Docker, Kubernetes, PostgreSQL],

  signature-place: "Bratislava",
  signature-date: "2025",
)
