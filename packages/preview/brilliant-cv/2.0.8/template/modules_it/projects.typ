// Imports
#import "@preview/brilliant-cv:2.0.6": cvSection, cvEntry
#let metadata = toml("../metadata.toml")
#let cvSection = cvSection.with(metadata: metadata)
#let cvEntry = cvEntry.with(metadata: metadata)


#cvSection("Progetti")

#cvEntry(
  title: [Data Analyst volontario],
  society: [ABC Nonprofit Organization],
  date: [2019 - Present],
  location: [New York, NY],
  description: list(
    [Analizzo i dati sui donatori e sulla raccolta fondi per identificare tendenze e opportunità di crescita],
    [Creo visualizzazioni di dati e dashboard per comunicare informazioni al consiglio di amministrazione],
    [Collaboro con altri volontari per sviluppare e implementare strategie basate sui dati],
  ),
)
