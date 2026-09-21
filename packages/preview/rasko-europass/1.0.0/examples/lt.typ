// Europass CV example — Lithuanian (lt).
// Persona of Lietuvis nationality.  Demonstrates lang="lt" end to end.
// Gender option used here: "male"
#import "../lib.typ": cv-entry, europass-cv, l

#show: europass-cv.with(
  lang: "lt",
  title: "Curriculum Vitae — Jonas Kazlauskas",
  author: "Jonas Kazlauskas",

  name: "Jonas Kazlauskas",
  photo: "assets/photo-placeholder.svg",
  photo-alt: l("lt").at("photo-alt"),
  address: "Example Street 1",
  city: "Vilnius",
  phone: "+00 000 000 000",
  email: "lt@europass.example",
  nationality: "Lietuvis",
  date-of-birth: "01/01/1990",
  gender: "male",

  work-experience: (
    cv-entry(
      date-start: "2021", date-end: "",
      title: "Vyresnysis programinės įrangos inžinierius",
      organization: "European Tech Solutions",
      location: "Vilnius",
      description: [- Vadovavo šešių inžinierių komandai, kuriančiai cloud-native paslaugas.],
    ),
  ),
  education: (
    cv-entry(
      date-start: "2013", date-end: "2015",
      title: "Informatikos magistras",
      organization: "Vilniaus universitetas",
      location: "Vilnius",
    ),
  ),

  mother-tongue: "Lietuvių",
  other-languages: (
    (lang: "Anglų", listening: "C1", reading: "C1",
     interaction: "B2", production: "B2", writing: "C1"),
  ),
  digital-skills: [- Python, Docker, Kubernetes, PostgreSQL],

  signature-place: "Vilnius",
  signature-date: "2025",
)
