// Imports
#import "@preview/brilliant-cv:3.1.2": cv-section, cv-entry, h-bar
#let metadata = toml("../metadata.toml")
#let cv-section = cv-section.with(metadata: metadata)
#let cv-entry = cv-entry.with(metadata: metadata)


#cv-section("Abschlüsse")

#cv-entry(
  title: [Master of Data Science],
  society: [Universität von Kalifornien, Los Angeles],
  date: [2018 - 2020],
  location: [USA],
  logo: image("../assets/logos/ucla.png"),
  description: list(
    [Dissertation: Vorhersage der Kundenabwanderung in der Telekommunikationsbranche mit Hilfe von Algorithmen des maschinellen Lernens und Netzwerkanalyse],
    [Kurs: Big-Data-Systeme und -Technologien #h-bar() Data Mining und Exploration #h-bar() Natural Language Processing],
  ),
)

#cv-entry(
  title: [Bachelors of Science in Informatik],
  society: [Universität von Kalifornien, Los Angeles],
  date: [2018 - 2020],
  location: [USA],
  logo: image("../assets/logos/ucla.png"),
  description: list(
    [Dissertation: Erforschung des Einsatzes von Algorithmen des maschinellen Lernens zur Vorhersage von Aktienkursen: Eine vergleichende Studie von Regressions- und Zeitreihenmodellen],
    [Kurs: Datenbanksysteme #h-bar() Rechnernetze #h-bar() Softwaretechnik #h-bar() Künstliche Intelligenz],
  ),
)
