#import "@preview/clean-fuh:0.1.0": *
#import "glossary.typ": glossary-entries

#show: clean-fuh.with(
  title: "Evaluation von Typst zur Erstellung einer Abschlussarbeit",
  authors: (
    (name: "Max Mustermann", student-id: "1111", degree: "B.Sc.", course-of-studies: "Praktische Informatik", city: "Hagen"),
    // (name: "Juan Pérez", student-id: "2222", degree: "B.Sc.",course-of-studies: "Data Science", city: "Barcelona"),
  ),
  companies: (
    (name: "ABC GmbH", city: "Hagen", country: "Germany"), 
    // (name: "ABC S.L.", city: "Barcelona", country: "Spain")
  ),
  type-of-thesis: "Masterarbeit",
  bibliography: bibliography("sources.bib"),
  date: datetime.today(),
  glossary: glossary-entries, // displays the glossary terms defined in "glossary.typ"
  language: "de", // en, de
  supervisor: (first: "Dr. Bruce Banner", second: "Prof. Dr. Daniel Düsentrieb"),
  university: "FernUniversität in Hagen",
  faculty: "Mathematik und Informatik",
  startdate: datetime(day:1, month:10, year:2023),
  enddate: datetime(day:30, month:9, year:2024),
  // logo: none, // specify a logo to display it on the title page
  show-gender-notice: true,
  show-confidentiality-statement: false,
  show-declaration-of-authorship: false,
)

// Edit this content to your liking

= Einleitung

#lorem(100)

#lorem(80)

#lorem(120)

= Erläuterungen

Im folgenden werden einige nützliche Elemente und Funktionen zum Erstellen von Typst-Dokumenten mit diesem Template erläutert.

== Ausdrücke und Abkürzungen

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