// Europass CV example — Italian (it).
// Persona of Italiana nationality.  Demonstrates lang="it" end to end.
// Gender option used here: "female"
#import "@preview/rasko-europass:1.0.0": cv-entry, europass-cv, l

#show: europass-cv.with(
  lang: "it",
  title: "Curriculum Vitae — Giulia Bianchi",
  author: "Giulia Bianchi",

  name: "Giulia Bianchi",
  photo: "assets/photo-placeholder.svg",
  photo-alt: l("it").at("photo-alt"),
  address: "Example Street 1",
  city: "Roma",
  phone: "+00 000 000 000",
  email: "it@europass.example",
  nationality: "Italiana",
  date-of-birth: "01/01/1990",
  gender: "female",

  work-experience: (
    cv-entry(
      date-start: "2021", date-end: "",
      title: "Ingegnera software senior",
      organization: "European Tech Solutions",
      location: "Roma",
      description: [- Ha guidato un team di sei ingegneri su servizi cloud-native.],
    ),
  ),
  education: (
    cv-entry(
      date-start: "2013", date-end: "2015",
      title: "Laurea magistrale in Ingegneria informatica",
      organization: "Sapienza Università di Roma",
      location: "Roma",
    ),
  ),

  mother-tongue: "Italiano",
  other-languages: (
    (lang: "Inglese", listening: "C1", reading: "C1",
     interaction: "B2", production: "B2", writing: "C1"),
  ),
  digital-skills: [- Python, Docker, Kubernetes, PostgreSQL],

  signature-place: "Roma",
  signature-date: "2025",
)
