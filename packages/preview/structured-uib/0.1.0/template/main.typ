// IMPORTS
#import "@preview/structured-uib:0.1.0": *

// TEMPLATE SETTINGS
#show: report.with(
  task_no: "1",
  task_name: "Måling og behandling av måledata",
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

// 1 - MÅLSETTING
= Oppgavens målsetting

// 2 - MÅLEOPPSTILLING
= Beskrivelse av måleoppstilling

// 3 - UTFØRELSE
= Utførelse og målinger

// 4 - KONKLUSJON
= Konklusjon og diskusjon

// REFERANSER (automatisk fyllt ut)
#bibliography("references.bib")

// Appendiks innhold etter denne "show" linjen
#show: appendices  

// APPENDIKS A - KODE
= Kode
