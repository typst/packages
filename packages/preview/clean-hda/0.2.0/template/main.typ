#import "@preview/clean-hda:0.2.0": *
#import "glossary.typ": glossary-entries
#import "@preview/abbr:0.3.0"

#abbr.load("abbr.csv") // import to load the abbreviations from a CSV file beforehand

#show: clean-hda.with(
  title: "Evaluation von Typst zur Erstellung einer Abschlussarbeit",
  subtitle: "Untertitel für einer Arbeit",
  authors: (
    (name: "Max Mustermann", student-id: "7654321", course-of-studies: "Informatik", course: "Masterthesis", city:"Darmstadt"),
  ),
  type-of-thesis: "Bachelorarbeit",
  at-university: true, // if true the company name on the title page and the confidentiality statement are hidden
  bibliography: bibliography("sources.bib"),
  date: datetime.today(),
  glossary: glossary-entries, // displays the glossary terms defined in "glossary.typ"
  language: "de", // en, de
  supervisor: (ref: "Prof. Dr. Margaret Hamilton", co-ref: "Prof. Dr. Daniel Düsentrieb"),
  university: "Hochschule Darmstadt - University of Applied Sciences",
  university-location: "Darmstadt",
  university-short: "h_da",
  abbr-page-break: false, // if true, the abbreviations list starts on a new page after the table of contents
)

// Edit this content to your liking

= Einleitung

#lorem(100)

#lorem(80)

#lorem(120)

= Erläuterungen

Im folgenden werden einige nützliche Elemente und Funktionen zum Erstellen von Typst-Dokumenten mit diesem Template erläutert.

== Ausdrücke und Abkürzungen
Nutzer haben die Möglichkeit, Abkürzungen und Glossar-Einträge zu definieren und diese dann im Text zu referenzieren.
Es können bei Bedarf auch beide Mechanismen parallel genutzt werden.


=== Abbreviations Referenzen

Abkürzungen können mit dem `abbr`-Package definiert und verwendet werden. In der zugehörigen #link("https://typst.app/universe/package/abbr/", "Dokumentation") werden noch weitere Varianten für Abkürzungen gezeigt.
Dort ist auch im Detail erläutert, wie Abkürzungen definiert werden können.

Hier ein Beispiel für die Verwendung von Abkürzungen mit der Funktion von Pluralisierung:

Das @API ist eine weit verbreitete. @HTTP ist eine übliches Protokoll für die Kommunikation.
Mehrere @API:pla können zusammen verwendet werden um komplexe Anwendungen zu erstellen.


=== Glossar Referenzen

Verwende die `gls`-Funktion, um Ausdrücke aus dem Glossar einzufügen, die dann dorthin verlinkt werden. Ein Beispiel dafür ist: 

Im diesem Kapitel wird eine #gls("Softwareschnittstelle") beschrieben. Man spricht in diesem Zusammenhang auch von einem #gls("API"). Die Schnittstelle nutzt Technologien wie das #gls("HTTP").

Das Template nutzt das `glossarium`-Package für solche Glossar-Referenzen. In der zugehörigen #link("https://typst.app/universe/package/glossarium/", "Dokumentation") werden noch weitere Varianten für derartige Querverweise gezeigt. Dort ist auch im Detail erläutert, wie das Glossar aufgebaut werden kann.

== Listen

Es gibt Aufzählungslisten oder nummerierte Listen:

- Dies
- ist eine
- Aufzählungsliste

+ Und
+ hier wird
+ alles nummeriert.

== Abbildungen und Tabellen

Abbildungen und Tabellen (mit entsprechenden Beschriftungen) werden wie folgt erstellt.

=== Abbildungen

#figure(caption: "Eine Abbildung", image(width: 4cm, "assets/ts.svg"))

=== Tabellen

#figure(
  caption: "Eine Tabelle",
  table(
    columns: (1fr, 50%, auto),
    inset: 10pt,
    align: horizon,
    table.header(
      [],
      [*Area*],
      [*Parameters*],
    ),

    text("cylinder.svg"),
    $ pi h (D^2 - d^2) / 4 $,
    [
      $h$: height \
      $D$: outer radius \
      $d$: inner radius
    ],

    text("tetrahedron.svg"), $ sqrt(2) / 12 a^3 $, [$a$: edge length],
  ),
)<table>

== Programm Quellcode

Quellcode mit entsprechender Formatierung wird wie folgt eingefügt:

#figure(
  caption: "Ein Stück Quellcode",
  sourcecode[```ts
    const ReactComponent = () => {
      return (
        <div>
          <h1>Hello World</h1>
        </div>
      );
    };

    export default ReactComponent;
    ```],
)


== Verweise

Für Literaturverweise verwendet man die `cite`-Funktion oder die Kurzschreibweise mit dem \@-Zeichen:
- `#cite(form: "prose", <iso18004>)` ergibt: \ #cite(form: "prose", <iso18004>)
- Mit `@iso18004` erhält man: @iso18004

Tabellen, Abbildungen und andere Elemente können mit einem Label in spitzen Klammern gekennzeichnet werden (die Tabelle oben hat z.B. das Label `<table>`). Sie kann dann mit `@table` referenziert werden. Das ergibt im konkreten Fall: @table

= Fazit

#lorem(50)

#lorem(120)

#lorem(80)