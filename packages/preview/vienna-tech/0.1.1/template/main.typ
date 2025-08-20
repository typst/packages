#import "@preview/vienna-tech:0.1.1": *

#show "Typst": fancy-typst
#show "LaTeX": fancy-latex

// Useing the configuration
#show: tuw-thesis.with(
  title: [Instruktionen zur Abfassung der Bachelorarbeit],
  thesis-type: [Bachelorarbeit],
  lang: "de",
  authors: (
    (
      name: "Vorname Nachname", 
      email: "email@email.com",
      matrnr: "12345678",
      date: datetime.today().display("[day] [month repr:long] [year]"),
    ),
  ),
  abstract: include "abstract.typ",
  toc:true,
  bibliography: bibliography("assets/refs.bib"), 
  appendix: include "appendix.typ", 
    )

// Some Example Content has already been created for you, to show you how to use the configuration
// and to give you some useful information about the structure of a Bachelor Thesis
// You can delete this content and start writing your own content

// Main Content
= Einleitung
Die Bachelorarbeit kann in Deutsch oder Englisch verfasst werden. 
Die Länge darf 12 Seiten nicht unterschreiten und 30 Seiten nicht 
überschreiten (exkl. Anhang).
Nach dem Titel der Arbeit werden der Autor und darauf eine Kurzfassung 
angeführt. 
Danach beginnt der Hauptteil der Arbeit. 
Die Bachelorarbeit hat keine Titelseite und nur bei Bedarf ein 
Inhaltsverzeichnis (zwischen Kurzfassung und Kapitel 1).

Der Titel der Arbeit wird in dem Konfigurationsbefehl `tuw-thesis` angegeben, ebenso wie der Name des/der Autors/Autoren, die E-Mailadresse, die Matrikelnummer und das Datum.
Durch den Konfigurationsbefehl wird nicht nur der Typografische Stil der Arbeit festgelegt, sondern es wird auch der Titelblock, das Inhalts- und das Literaturverzeichnis generiert. 

#include "sections.typ"