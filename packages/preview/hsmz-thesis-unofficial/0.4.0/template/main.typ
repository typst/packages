#import "@preview/hsmz-thesis-unofficial:0.4.0": *
#import "acronyms.typ": acronyms
#import "appendix.typ": appendix-content
#import "summary.typ": abstract, management-summary

// All parameters and their defaults are described in the README:
// https://typst.app/universe/package/hsmz-thesis-unofficial
#show: hsmz-thesis-unofficial.with(
  // thesis data
  thesis-type: "Masterarbeit",
  title: "Untersuchung der Auswirkungen von [Thema] auf [Bereich] unter besonderer Berücksichtigung von [Aspekt] in [Kontext]",
  degree-program: "IT-Management M. Sc.",
  submission-date: datetime(year: 2026, month: 1, day: 1),
  supervisor: "Prof. Dr. Muster",
  author: (
    name: "Max Mustermann",
    matriculation-number: "1234567",
    address: (street: "Musterstraße 1", zip: "55128", city: "Mainz"),
    // scanned signature; remove this line to leave space for a handwritten signature
    signature-image: image("assets/sample-signature.png"),
  ),
  // option of the declaration of originality agreed with your supervisor: 1, 2 or 3
  ai-declaration-option: 1,
  // restriction notice (Sperrvermerk); set show-restriction-notice: false if you don't need one
  company: "Musterfirma",
  confidentiality-period: datetime(year: 2036, month: 1, day: 1),
  // contents
  acronyms: acronyms,
  symbols: (
    ($a, b$, [Katheten eines rechtwinkligen Dreiecks]),
    ($c$, [Hypotenuse eines rechtwinkligen Dreiecks]),
  ),
  bibliography: bibliography("literature.bib"),
  appendix: appendix-content,
  abstract: abstract,
  management-summary: management-summary,
  // settings
  show-management-summary: false,
  show-abstract: true,
  // while writing: watermark, list of open todos (#todo[...]) and length checks; set to false for the final version
  draft: false,
)

= Einleitung

Eine Thesis zum Thema #acr("IT") an der Hochschule Mainz. Abkürzungen werden bei der ersten Verwendung
ausgeschrieben, danach steht nur noch die Abkürzung: #acr("IT").

== Forschungsfrage

Quellen werden mit `@schlüssel` zitiert @wildeForschungsmethodenWirtschaftsinformatikEmpirische2007, mit
Seitenangabe @wildeForschungsmethodenWirtschaftsinformatikEmpirische2007[S.~282] oder im Satz:
#cite(<wildeForschungsmethodenWirtschaftsinformatikEmpirische2007>, form: "prose") untersuchen die
Forschungsmethoden der Wirtschaftsinformatik.#footnote[Fußnoten stehen am Seitenende, im Blocksatz und mit hängendem
  Einzug.]

== Aufbau der Arbeit

@tab:aufbau zeigt, wie Tabellen mit Beschriftung und Anmerkung eingefügt werden. In @sec:theorie werden die
Grundlagen dargestellt, in @sec:methodik das Vorgehen.

#figure(
  table(
    columns: 2,
    [Kapitel], [Inhalt],
    [1], [Einleitung],
    [2], [Theorie],
    [3], [Methodik],
  )
    + figure-note[Eigene Darstellung.],
  caption: [Aufbau der Arbeit],
) <tab:aufbau>

= Theorie <sec:theorie>

Formeln in einem eigenen Absatz werden nummeriert und im Formelverzeichnis aufgeführt. Die verwendeten Symbole
stehen im Symbolverzeichnis. Nach dem Satz des Pythagoras gilt @eq:pythagoras:

$ a^2 + b^2 = c^2 $ <eq:pythagoras>

@fig:entwicklung zeigt, wie Abbildungen eingefügt werden.

#figure(
  image("assets/sample-figure.svg", width: 80%) + figure-note[Eigene Darstellung mit fiktiven Beispieldaten.],
  caption: [Anteil der Unternehmen mit Cloud-Nutzung],
) <fig:entwicklung>

= Methodik <sec:methodik>

Quellcode wird als Codeblock eingefügt:

```python
def mittelwert(werte):
    return sum(werte) / len(werte)
```

= Ergebnisse

= Diskussion und Fazit
