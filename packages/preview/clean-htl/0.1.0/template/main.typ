#import "@preview/clean-htl:0.1.0": *

#show: htl-notes.with(
  title: "Thema",
  subject: "Fach",
  student: "Vorname Nachname",
  class: "1cHEL",
  teacher: "Lehrer",
  date: datetime.today(), // fixes Datum eintragen, z.B. datetime(year: 2026, month: 9, day: 24)
)

= Kapitel

Text mit #hl[Highlight].

$ R = U / I $

#definition[Definition]

#remember[Merksatz]
