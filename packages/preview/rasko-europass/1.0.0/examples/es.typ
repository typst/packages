// Europass CV example — Spanish (es).
// Persona of Española nationality.  Demonstrates lang="es" end to end.
// Gender option used here: "female"
#import "@preview/rasko-europass:1.0.0": cv-entry, europass-cv, l

#show: europass-cv.with(
  lang: "es",
  title: "Curriculum Vitae — Lucía García",
  author: "Lucía García",

  name: "Lucía García",
  photo: "assets/photo-placeholder.svg",
  photo-alt: l("es").at("photo-alt"),
  address: "Example Street 1",
  city: "Madrid",
  phone: "+00 000 000 000",
  email: "es@europass.example",
  nationality: "Española",
  date-of-birth: "01/01/1990",
  gender: "female",

  work-experience: (
    cv-entry(
      date-start: "2021", date-end: "",
      title: "Ingeniera de software sénior",
      organization: "European Tech Solutions",
      location: "Madrid",
      description: [- Dirigió un equipo de seis ingenieros en servicios cloud-native.],
    ),
  ),
  education: (
    cv-entry(
      date-start: "2013", date-end: "2015",
      title: "Máster en Informática",
      organization: "Universidad Complutense de Madrid",
      location: "Madrid",
    ),
  ),

  mother-tongue: "Español",
  other-languages: (
    (lang: "Inglés", listening: "C1", reading: "C1",
     interaction: "B2", production: "B2", writing: "C1"),
  ),
  digital-skills: [- Python, Docker, Kubernetes, PostgreSQL],

  signature-place: "Madrid",
  signature-date: "2025",
)
