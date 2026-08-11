// Imports
#import "@preview/brilliant-cv:2.0.6": cvSection, cvEntry, hBar
#let metadata = toml("../metadata.toml")
#let cvSection = cvSection.with(metadata: metadata)
#let cvEntry = cvEntry.with(metadata: metadata)


#cvSection("Abschlüsse")

#cvEntry(
  title: [Master of Data Science],
  society: [Universität von Kalifornien, Los Angeles],
  date: [2018 - 2020],
  location: [USA],
  logo: image("../src/logos/ucla.png"),
  description: list(
    [Dissertation: Vorhersage der Kundenabwanderung in der Telekommunikationsbranche mit Hilfe von Algorithmen des maschinellen Lernens und Netzwerkanalyse],
    [Kurs: Big-Data-Systeme und -Technologien #hBar() Data Mining und Exploration #hBar() Natural Language Processing],
  ),
)

#cvEntry(
  title: [Bachelors of Science in Informatik],
  society: [Universität von Kalifornien, Los Angeles],
  date: [2018 - 2020],
  location: [USA],
  logo: image("../src/logos/ucla.png"),
  description: list(
    [Dissertation: Erforschung des Einsatzes von Algorithmen des maschinellen Lernens zur Vorhersage von Aktienkursen: Eine vergleichende Studie von Regressions- und Zeitreihenmodellen],
    [Kurs: Datenbanksysteme #hBar() Rechnernetze #hBar() Softwaretechnik #hBar() Künstliche Intelligenz],
  ),
)
