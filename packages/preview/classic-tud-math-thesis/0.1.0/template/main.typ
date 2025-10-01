#import "../src/classic-tud-math-thesis.typ": *

#show: setup-equate.with()

#show: classic-tud-math-thesis.with(
  name: [Ihr Familienname],
  vorname: [Ihr Vorname],
  gebdatum: [Ihr Geburtsdatum],
  ort: [Ihr Geburtsort],
  betreuer: [Vollständiger akad. Titel (z.B. Prof. Dr. rer. nat. habil.) Vorname Familienname Ihres Betreuers / Ihrer Betreuerin],
  betreuer-kurz: [Kurzer akad. Titel (z.B. Prof. Dr.) Vorname Familienname Ihres Betreuers / Ihrer Betreuerin],
  institut: [Institut ihres Betreuers],
  thema: [Titel ihrer Arbeit],
  datum: [tt. mm. jjjj],
  abschluss: "bsc",
  studiengang: [Mathematik oder Technomathematik oder Wirtschaftsmathematik],
  use_default_math_env: true,
)

#heading(numbering: none)[Einleitung]

#lorem(200)

= Mathematik und so
== rechtwinklige Dreiecke und Theoreme

Wir reden zunächst über rechtwinklige Dreiecke. Dafür müssen wir erstmal ein paar Begriffe klären. Wie heißen beispielsweise die einzelnen Seiten? Was kann man damit tun?

#definition(title: [Katheten])[
  In einem rechtwinkligen Dreieck heißen die an den rechten Winkel anliegenden Seiten _Katheten_.
]

#definition[In einem rechtwinkligen Dreieck heißt die dem rechten Winkel gegenüberliegende Seite _Hypotenuse_.]

Wir können dem einzelnen Umgebungen einen Titel geben, welcher dann in Klammern erscheint. Nach diesen Definitionen können wir nun folgenden Satz formulieren.

#satz(title: [Pytagoras])[
  Es seien $a$, $b$ und $c$ die Seitenlängen eines rechtwinkligen Dreiecks, wobei die $a$ und $b$ die Längen der Katheten sind und $c$ die Länge der Hypotenuse, dann gilt $ a^2 +b^2 = c^2 $<pythagoras:eq>
]<pythagoras>

Zu dem @pythagoras befinden sich in @Pythagoras:365Beweise 365 verschiedene Beweise. Die @pythagoras:eq wird an vielen stellen der Mathematik verwendet.

== Gleichungssysteme

In der Mathematik kann man auch Gleichungssysteme formulieren.
$
  a + b - c = 1 #<sys:eq1>\
  a - b + c = 1 #<sys:eq2>
$<sys:label>

Wenn dieses @sys:label mit Labels versehen ist, kann auch die einzelnen Gleichungen @sys:eq1 und @sys:eq2 refferenzieren.
== Fill-Conent
#lorem(300)

= Typst-Tipps

== Dokumentation
Die #link("https://typst.app/docs/")[Typst-Dokumentation]#footnote[Hier ist das Wort mit der Webseite verlinkt] ist hervoragend.

== Wie schreibt man dieses Symbol?
Du kennst ein mathematisches Symbol nicht? Mit #link("https://detypify.quarticcat.com/")[detypify]#footnote[Das Wort ist mit der Webseite verlinkt] kannst du das Symbol einfach zeichnen und der entsprechende Typst-Befehl wird dir angezeigt.

= Drittes Kapitel mit Inhalt
#lorem(40)
== ein Unterkapitel
#lorem(150)
== ein zweites Unterkapitel
#lorem(250)
= Zusammenfassung und Fazit
#lorem(300)

#bibliography("bibliography.bib")
