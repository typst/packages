// Imports
#import "@preview/brilliant-cv:3.1.1": cv-section, cv-entry, h-bar


#cv-section("Istruzione")

#cv-entry(
  title: [Master in Data Science],
  society: [Università della California, Los Angeles],
  date: [2018 - 2020],
  location: [USA],
  logo: image("../assets/logos/ucla.png"),
  description: list(
    [Tesi: Previsione del tasso di abbandono dei clienti nel settore delle telecomunicazioni mediante algoritmi di apprendimento automatico e analisi delle reti],
    [Corsi: Sistemi e tecnologie basati su Big Data #h-bar() Data Mining #h-bar() Natural language processing],
  ),
)

#cv-entry(
  title: [Laurea in informatica],
  society: [Università della California, Los Angeles],
  date: [2018 - 2020],
  location: [USA],
  logo: image("../assets/logos/ucla.png"),
  description: list(
    [Tesi: Esplorazione di algoritmi di apprendimento automatico per prevedere i prezzi delle azioni: uno studio comparativo di modelli di regressione e serie temporali],
    [Corsi: Sistemi di database #h-bar() Reti di calcolatori #h-bar() Ingegneria del software #h-bar() Intelligenza artificiale],
  ),
)
