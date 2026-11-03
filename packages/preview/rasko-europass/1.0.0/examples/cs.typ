// Europass CV example — Czech (cs).
// Persona of Čech nationality.  Demonstrates lang="cs" end to end.
// Gender option used here: "male"
#import "@preview/rasko-europass:1.0.0": cv-entry, europass-cv, l

#show: europass-cv.with(
  lang: "cs",
  title: "Curriculum Vitae — Jan Novák",
  author: "Jan Novák",

  name: "Jan Novák",
  photo: "assets/photo-placeholder.svg",
  photo-alt: l("cs").at("photo-alt"),
  address: "Example Street 1",
  city: "Praha",
  phone: "+00 000 000 000",
  email: "cs@europass.example",
  nationality: "Čech",
  date-of-birth: "01/01/1990",
  gender: "male",

  work-experience: (
    cv-entry(
      date-start: "2021", date-end: "",
      title: "Senior softwarový inženýr",
      organization: "European Tech Solutions",
      location: "Praha",
      description: [- Vedl tým šesti inžinýrů na cloud-native službách.],
    ),
  ),
  education: (
    cv-entry(
      date-start: "2013", date-end: "2015",
      title: "Ing., informatika",
      organization: "ČVUT v Praze",
      location: "Praha",
    ),
  ),

  mother-tongue: "Čeština",
  other-languages: (
    (lang: "Angličtina", listening: "C1", reading: "C1",
     interaction: "B2", production: "B2", writing: "C1"),
  ),
  digital-skills: [- Python, Docker, Kubernetes, PostgreSQL],

  signature-place: "Praha",
  signature-date: "2025",
)
