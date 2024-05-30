// IMPORTS
#import "@preview/structured-uib:0.1.0": *
#import "@preview/codedis:0.1.0": code

// TEMPLATE SETTINGS
#show: report.with(
  task-no: "1",
  task-name: "Måling og behandling av måledata",
  authors: (
    "Student Enersen",
    "Student Toersen", 
    "Student Treersen"
  ),
  mails: (
    "student.enersen@student.uib.no", 
    "student.toersen@student.uib.no", 
    "student.treersen@student.uib.no"
  ),
  group: "1-1",
  date: "29. Apr. 2024",
  supervisor: "Professor Professorsen",
)

// INNHOLDSFORTEGNELSE
#outline()


// 1. MÅLSETTING
= Oppgavens målsetting <chap.målsetting>
Hva gjør vi og hvorfor? Kanskje vi får bruk for @eq.cool? Eller koden fra @code.litt_kode i @chap.kode?

$
  f(x) = (pi e^(i x))
$<eq.cool>


// 2. MÅLEOPPSTILLING
= Beskrivelse av måleoppstilling <chap.måleoppstilling>
Hvordan gjorde vi det? Jo, bare se på @fig.katapult!

#figure(
  caption: [En liten katapult #footnote([Den er egt. ganske stor!]).], 
  image("katapult.png", width: 30%)
)<fig.katapult>


// 3. UTFØRELSE
= Utførelse og målinger <chap.utførelse>
Hva fikk vi? Er $pi = 3.14$? Diskusjonen finnes i @chap.konklusjon.

#figure(
  caption: [Bare litt data], 
  table(
    columns: 3,
    [*Data 1*], [*Data 2*], [*Data 3*],
    [420],      [1337],     [1999]
  )
)<tabl.data>


// 4. KONKLUSJON
= Konklusjon og diskusjon <chap.konklusjon>
Hvorfor skjedde det som skjedde? Hvorfor fikk vi det vi fikk i @tabl.data? Kanskje vi finner svaret i Newtons Principa Matemtika @bibl.newton.


// REFERANSER
#bibliography("references.bib")


// APPENDIKS
#show: appendices

= Kode <chap.kode>
#figure(
  caption: [Bare litt kode], 
  code(read("litt_kode.py"))
)<code.litt_kode>
