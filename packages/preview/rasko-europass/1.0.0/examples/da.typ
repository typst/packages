// Europass CV example — Danish (da).
// Persona of Dansk nationality.  Demonstrates lang="da" end to end.
// Gender option used here: "female"
#import "../lib.typ": cv-entry, europass-cv, l

#show: europass-cv.with(
  lang: "da",
  title: "Curriculum Vitae — Mette Jensen",
  author: "Mette Jensen",

  name: "Mette Jensen",
  photo: "assets/photo-placeholder.svg",
  photo-alt: l("da").at("photo-alt"),
  address: "Example Street 1",
  city: "København",
  phone: "+00 000 000 000",
  email: "da@europass.example",
  nationality: "Dansk",
  date-of-birth: "01/01/1990",
  gender: "female",

  work-experience: (
    cv-entry(
      date-start: "2021", date-end: "",
      title: "Senior softwareingeniør",
      organization: "European Tech Solutions",
      location: "København",
      description: [- Ledede et team på seks ingeniører inden for cloud-native tjenester.],
    ),
  ),
  education: (
    cv-entry(
      date-start: "2013", date-end: "2015",
      title: "Cand.it i datalogi",
      organization: "Københavns Universitet",
      location: "København",
    ),
  ),

  mother-tongue: "Dansk",
  other-languages: (
    (lang: "Engelsk", listening: "C1", reading: "C1",
     interaction: "B2", production: "B2", writing: "C1"),
  ),
  digital-skills: [- Python, Docker, Kubernetes, PostgreSQL],

  signature-place: "København",
  signature-date: "2025",
)
