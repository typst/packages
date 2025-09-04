// Imports
#import "@preview/brilliant-cv:2.0.6": cvSection, cvEntry
#let metadata = toml("../metadata.toml")
#let cvSection = cvSection.with(metadata: metadata)
#let cvEntry = cvEntry.with(metadata: metadata)


#cvSection("Esperienze di lavoro")

#cvEntry(
  title: [Direttore di Data Science],
  society: [XYZ Corporation],
  logo: image("../src/logos/xyz_corp.png"),
  date: [2020 - Presente],
  location: [San Francisco, CA],
  description: list(
    [Guido un team di data scientist e analisti per sviluppare e implementare strategie basate sui dati, sviluppo modelli predittivi e algoritmi per supportare il processo decisionale in tutta l'organizzazione],
    [Collaboro con la dirigenza esecutiva per identificare opportunità di business e guidare la crescita, implemento le migliori pratiche per la governance dei dati, la qualità e la sicurezza],
  ),
  tags: ("Tag d'esempio qui", "Dataiku", "Snowflake", "SparkSQL"),
)

#cvEntry(
  title: [Data Analyst],
  society: [ABC Company],
  logo: image("../src/logos/abc_company.png"),
  date: [2017 - 2020],
  location: [New York, NY],
  description: list(
    [Analizzo dataset di grandi dimensioni con SQL e Python, collaboro con i team per avere informazioni utili a livello di business],
    [Creo visualizzazioni di dati e dashboard con Tableau, sviluppo e gestisco pipeline di dati con AWS],
  ),
)

#cvEntry(
  title: [Tirocinio in Data Analysis],
  society: [PQR Corporation],
  logo: image("../src/logos/pqr_corp.png"),
  date: [Summer 2017],
  location: [Chicago, IL],
  description: list([Ho collaborato alla pulizia, all'elaborazione e all'analisi dei dati utilizzando Python ed Excel, ho partecipato alle riunioni del team e ho contribuito alla pianificazione e all'esecuzione del progetto]),
)
