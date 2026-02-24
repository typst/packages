#import "@preview/codly:1.2.0": *
#show: codly-init.with()

#codly(languages: (python: (name: "Python", color: rgb("#006699"))))

= Bachelorarbeit
Nach der Einleitung kommt der weitere Text: #lorem(22)

== Textbereich
Der Text sollte die ganze Breite ausfüllen, also im Blocksatz stehen. Die
Silbentrennung soll aktiviert sein. Der erste Absatz ist nicht eingerückt, die
folgenden dann schon.

Typst generiert dieses Einrücken automatisch. #lorem(25)

== Layout, Schriftart, Schriftgrad und Nummerierung

Für diese Arbeit wird das Template `vienna-tech` verwendet, die auf den Stil der
LaTeX Klasse `BachelorBUI.cls` aufbaut, welche auf der TU Website zu finden ist #link("https://www.tuwien.at/cee/edvlabor/lehre/vorlagen").

Der Haupttext ist in 11-Punkt-Schrift und einzeiligem Abstand geschrieben. Die
anderen Schriftgrade sind in der Vorlage definiert. Die Formatierung Kursiv kann
für Hervorhebungen verwendet werden. Von der Formatierung Fett und Unterstrichen
wird jedoch abgeraten. Es sollten in keinem Fall mehr als drei
Überschriftsebenen verwendet werden.

#figure(
  table(
    columns: 4, align: (left, left, left, left), table.hline(), table.header([Überschriftenebene], [Beispiel], [LaTeX - Befehle], [Typst - Befehle]), table.hline(), [Titel (zentriert)], [Instruktionen], "\\title{}", [], [Überschrift 1], [1 Einleitung], "\section{}", "= ", [Überschrift 2], [2.1 Textbereich], "\subsection{}", "== ", [Überschrift 3], [2.1.1 Unterlagen], "\subsubsection{}", "===", table.hline(start: 0),
  ), caption: [Die Tabellenbeschriftung ist normalerweise über der Tabelle. Tabellen sollen
    durchgehend nummeriert sein. Der letzte Satz der Tabellenbeschriftung endet ohne
    Punkt],
)<tab:überschriften>

Die Tabelle sowie deren Beschriftung werden innerhalb der `#figure` Umgebung
erstellt. Die Beschriftung der Tabelle wird als Argument `caption` an die `#figure` Funktion
übergeben. Das Erstellen der Tabelle erfolgt innerhalb der Funktion `#table`.

== Abbildungen und Fotos
Abbildungen sollten digital erstellt sein (keine Handzeichnungen). Diese müssen
dann in der Bachelorarbeit integriert sein. Diagramme sollen gut lesbar erstellt
werden. Der Schriftgrad innerhalb der Abbildungen soll 10-Punkt sein.

Abbildungen sollen durchgehend nummeriert sein. Die Abbildungsbeschriftung ist
immer unterhalb der Abbildung. Der letzte Satz der Abbildungsbeschriftung endet
ohne Punkt. Die Abbildungsbeschriftung soll 10-Punkt-Schrift besitzen. Ein
Beispiel sehen Sie in @fig:winston.

#figure(
  rect(width: 3.5cm, height:5cm), caption: [Dies ist ein Beispiel für eine Abbildungsbeschriftung],
)<fig:winston>

Das Bild sowie dessen Beschriftung werden innerhalb der Funktion `#figure` geschrieben.
Das Einfügen des Bildes erfolgt durch den Befehl `#image`. Die Beschriftung der
Abbildung wird als Argument `caption` an die `#figure` Funktion übergeben, diese
ist nun nach bzw. unterhalb der Abbildung positioniert.

== Formeln
Gleichungen und Formeln sollen generell zentriert in einer eigenen Zeile
platziert werden. Die Gleichungen sollen durchnummeriert werden, wobei die
Gleichungsnummer in Klammer zu stehen hat. Formeln werden einfach in die
zwischen \$ Zeichen gesetzt. Dabei wird die Nummerierung automatisch übernommen.

$
  K_t = (1 - (R^2 dot tau)/(c_a + nu dot tan delta))^4 dot k_1
$

== Fußnoten
Die Fußnotenziffer ist entweder direkt nach dem zu beschreibenden Wort oder nach
einem Satzzeichen angeordnet. Fußnoten werden in den Befehl `#footnote` geschrieben.
#footnote([Dies ist eine Fußnote])

== Referenzierungen und Literaturverzeichnis

Die Liste der Referenzierungen ist mit „Literatur“ betitelt und wird ohne
eigenen Seitenumbruch am Ende der Arbeit positioniert (aber noch vor einem
möglichen Anhang). Die zugehörige Überschrift hat dann keine
Überschriftennummer. Das Literaturverzeichnis wird in Typst durch das verwenden
der Vorlage automatisch erstellt sofern eine _BibTeX_ Datei in der
Konfigurationsfunktion angegeben wurde. Das Literaturverzeichnis wird dann
automatisch am Ende (aber noch vor dem Anhang) eingefügt.

Die Literaturangaben sollen nummeriert angeführt werden. Die Nummerierung selbst
steht innerhalb eckiger Klammern, z.B. @dirac @einstein @knuthwebsite oder
@dirac[p.~27].

//#pagebreak()
Die Quellenangabe kann auch hinter dem Zitat oder inhaltlicher Behauptung wie
folgt angeführt werden: (Name des Erstautor et al. (Jahreszahl)), z.B. (Alberty
et al. (1999)). Dann muss ein geeigneter Literaturstil angegeben werden. Typst
bietet hierfür ein paar Möglichkeiten an. Dazu kann man das Argument `form` an
den Befehl `#cite` übergeben. Der Stil kann individuell durch das `style` Argument
verändert werden.

#let data = ("Stil", "Zitat")
#for elem in ("normal", "prose", "author", "year"){
  data.push(elem)
  data.push(cite(<dirac>, form: elem, style: "copernicus"))
}
#show table.cell.where(y: 0): strong 
#figure(
  table(
    columns: 2,stroke:.7pt,
    ..data
  )
)

In diesem Beispiel wurde der Zitierstil `copernicus` verwendet, jedoch können
noch viele andere verwendet werden.

== Kopfzeile

Die Bachelorarbeit ist für einen doppelseitigen Druck formatiert. Daher befindet
sich in der Kopfzeile außen die Seitennummer (bei geraden Seiten links und bei
ungeraden Seiten rechts) sowie innen der Titel der Arbeit (bei geraden Seiten
rechts und bei ungeraden Seiten links). Dies erfolgt in Konfiguration
automatisch.

== Verwendeter Code

Um in der Arbeit Code darzustellen eignen sich Pakete wie z.B. *Codly*. Damit
wird Code wie folgt dargestellt.



```python
import numpy as np
import matplotlib.pyplot as plt

# define x and claculate y values
x = np.linspace(0,10)
y = np.sin(x)

# Create Plot
fig, ax = plt.subplots()
ax.plot(x,y)
plt.show()
```