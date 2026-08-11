// Imports
#import "@preview/brilliant-cv:2.0.6": cvSection, cvEntry, hBar
#let metadata = toml("../metadata.toml")
#let cvSection = cvSection.with(metadata: metadata)
#let cvEntry = cvEntry.with(metadata: metadata)


#cvSection("Istruzione")

#cvEntry(
  title: [Master in Data Science],
  society: [Università della California, Los Angeles],
  date: [2018 - 2020],
  location: [USA],
  logo: image("../src/logos/ucla.png"),
  description: list(
    [Tesi: Previsione del tasso di abbandono dei clienti nel settore delle telecomunicazioni mediante algoritmi di apprendimento automatico e analisi delle reti],
    [Corsi: Sistemi e tecnologie basati su Big Data #hBar() Data Mining #hBar() Natural language processing],
  ),
)

#cvEntry(
  title: [Laurea in informatica],
  society: [Università della California, Los Angeles],
  date: [2018 - 2020],
  location: [USA],
  logo: image("../src/logos/ucla.png"),
  description: list(
    [Tesi: Esplorazione di algoritmi di apprendimento automatico per prevedere i prezzi delle azioni: uno studio comparativo di modelli di regressione e serie temporali],
    [Corsi: Sistemi di database #hBar() Reti di calcolatori #hBar() Ingegneria del software #hBar() Intelligenza artificiale],
  ),
)
