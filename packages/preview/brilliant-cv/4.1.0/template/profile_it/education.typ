// Imports
#import "@preview/brilliant-cv:4.1.0": cv-entry, cv-section, h-bar


#cv-section("Istruzione")

#cv-entry(
  title: [Master in Data Science],
  society: [Aurora State University],
  date: [2018 - 2020],
  location: [Aurora, WA],
  logo: image("../assets/logos/aurora_state.png"),
  description: list(
    [Tesi: Previsione del tasso di abbandono dei clienti nel settore delle telecomunicazioni mediante algoritmi di apprendimento automatico e analisi delle reti],
    [Corsi: Sistemi e tecnologie basati su Big Data #h-bar() Data Mining #h-bar() Natural language processing],
  ),
)

#cv-entry(
  title: [Laurea in informatica],
  society: [Aurora State University],
  date: [2014 - 2018],
  location: [Aurora, WA],
  logo: image("../assets/logos/aurora_state.png"),
  description: list(
    [Tesi: Esplorazione di algoritmi di apprendimento automatico per prevedere i prezzi delle azioni: uno studio comparativo di modelli di regressione e serie temporali],
    [Corsi: Sistemi di database #h-bar() Reti di calcolatori #h-bar() Ingegneria del software #h-bar() Intelligenza artificiale],
  ),
)
