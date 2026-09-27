// Europass CV example — Portuguese (pt).
// Persona of Português nationality.  Demonstrates lang="pt" end to end.
// Gender option used here: "male"
#import "@preview/rasko-europass:1.0.0": cv-entry, europass-cv, l

#show: europass-cv.with(
  lang: "pt",
  title: "Curriculum Vitae — João Silva",
  author: "João Silva",

  name: "João Silva",
  photo: "assets/photo-placeholder.svg",
  photo-alt: l("pt").at("photo-alt"),
  address: "Example Street 1",
  city: "Lisboa",
  phone: "+00 000 000 000",
  email: "pt@europass.example",
  nationality: "Português",
  date-of-birth: "01/01/1990",
  gender: "male",

  work-experience: (
    cv-entry(
      date-start: "2021", date-end: "",
      title: "Engenheiro de software sénior",
      organization: "European Tech Solutions",
      location: "Lisboa",
      description: [- Liderou uma equipa de seis engenheiros em serviços cloud-native.],
    ),
  ),
  education: (
    cv-entry(
      date-start: "2013", date-end: "2015",
      title: "Mestrado em Engenharia Informática",
      organization: "Universidade de Lisboa",
      location: "Lisboa",
    ),
  ),

  mother-tongue: "Português",
  other-languages: (
    (lang: "Inglês", listening: "C1", reading: "C1",
     interaction: "B2", production: "B2", writing: "C1"),
  ),
  digital-skills: [- Python, Docker, Kubernetes, PostgreSQL],

  signature-place: "Lisboa",
  signature-date: "2025",
)
