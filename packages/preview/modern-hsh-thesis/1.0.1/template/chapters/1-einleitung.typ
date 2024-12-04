#import "../customFunctions.typ": *


= Template

Ein vollständiges Beispiel ist auf GitHub zu finden: #link("https://github.com/MrToWy/Bachelorarbeit")[HIER KLICKEN].

In diesem Template für die #hsh können sowohl .yaml-Dateien @harry, als auch .bib-Dateien @typst verwenden werden.

== Codebeispiel <code-abschnitt>

Für Code @code1 und Bilder können Funktionen aus der `customFunctions.typ` verwendet werden.

#code-figure("Caption", <code1>, "code")

== Use Cases

#use-case(1, "Erster Usecase")[
  Der Use Case beschreibt, wie....
][
  Beispielakteur
][
  Beispielvorbedingung
][
  1. Schritt 1
  2. Schritt 2
]<use-case-info-degree>

== anforderungen

Anforderungen können in Tabellen dargestellt werden.

#task(title: [Aus @code-abschnitt ergeben sich folgende Anforderungen:])[
#narrow-track("Beispiel 1", type: "F", label: <example1>)[Lorem ipsum.] #linebreak()
#narrow-track("Beispiel 2", type: "F", label: <example2>)[Lorem ipsum.] #linebreak()
]

Auf die Anforderungen kann ebenfalls referenziert werden. @example1
