# hannes-thesis

An academic template, designed for final reports, Bachelor theses, and Master
theses.

## Example usage

```typst
#show: thesis.with(
  title: "Meine Typst Thesis",
  subtitle: "Eine persönliche Vorlage von Hannes",
  lang: "de",
  authors: (
    (
      name: "Johannes Knoll",
      email: "johannes.knoll@tha.de",
      studiengang: "Informatik Bachelor",
      matrikelnr: "Mat.-Nr. 1234567",
    ),
  ),

  logo: image("assets/THA_Logo_S_Red_RGB.svg", width: 80%),
  footer-logo: image("assets/THA_Wordmark_S_Red_RGB.svg", width: 25%),

  outlines: (
    outline(title: [Abkürzungsverzeichnis], target: figure.where(kind: image)),
    outline(title: [Abbildungsverzeichnis], target: figure.where(kind: image)),
    outline(title: [Tabellenverzeichnis], target: figure.where(kind: table)),
    outline(title: [Quellcode], target: figure.where(kind: raw)),
  ),

  bibliography: bibliography("refs.bib"),
  toc: outline(title: [Custom Outline Title]),
)
 
```
