#import "@preview/htlwienwest-da:0.1.1": *

/// Diplomarbeits-Konfiurationen
///
/// Alle Parameter müssen ausgefüllt werden um das Dokument zu generieren
///
/// Parameter:
///  - titel: string
///  - schuljahr: string 
///  - abteilung: string
///  - unterschrifts-datum: string
///  - autoren: list(dict)
///     - vorname: string
///     - nachname: string
///     - klasse: string
///     - betreuer: dict
///       - name: string | content
///       - geschlecht: "male" | "female"
///     - aufgaben: content
///  - kurzfassung: content
///  - abstract: content
///  - vorwort: content
///  - danksagung: content
///  - anhang: content | none
///  - literaturverzeichnis: function
#show: diplomarbeit.with(
  titel: "Titel der Diplomarbeit",
  abteilung: "Informationstechnologie",
  schuljahr: "2023/24",
  unterschrifts-datum: "20.04.2024",
  autoren: (
   (
     vorname: "Hans", nachname: "Mustermann",
     klasse: "5AHITN",
     betreuer: (name: "Dr. Walter Turbo", geschlecht: "male"),
     aufgaben: [
       #lorem(100)
     ]
   ),
   (
     vorname: "Herta", nachname: "Musterfrau",
     klasse: "5AHITN",
     betreuer: (name: "Dipl.-Ing Hans Kreisel", geschlecht: "male"),
     aufgaben: [
       #lorem(100)
     ]
   ),
   (
     vorname: "Daniel", nachname: "Düsentrieb",
     klasse: "5AHITN",
     betreuer: (name: "DI. Sandra Antrieb", geschlecht: "female"),
     aufgaben: [
       #lorem(100)
     ]
   ),
  ),
  kurzfassung: [
    Die Kurzfassung muss die folgenden Inhalte darlegen (§8, Absatz 5 Prüfungsordnung): Thema, Fragestellung, Problemformulierung, wesentliche Ergebnisse. Sie soll einen prägnanten Überblick über die Arbeit geben.

    Umfang: maximal 1 Seite
    
    Zur Aufgabenstellung: von welchem Wissens- oder Entwicklungsstand wird ausgegangen
    bzw. welche Ergebnisse gibt es bereits? Welches Ziel soll erreicht werden? Warum und für wen ist das definierte Ziel von Interesse?
    
    Zur Umsetzung: auf welche fachtheoretischen/-praktischen Grundlagen wurde zurückgegriffen? Welche Lösungsansätze/Methoden wurden gewählt? Warum gerade diese?
    
    Zu den Ergebnissen: Worin besteht der Beitrag zur Lösung der Aufgabenstellung? Was wurdeerreicht? Wurde die Arbeit bei Wettbewerben eingereicht?

    *Hinweis:* Falls die Diplomarbeits-Konfiuration wegen zu viel Text unübersichtlich wird, könnt ihr mit `include "<datei>.typ"` eine Typst-Datei inkludieren, in die der entsprechende Text steht. Als Beispiel dient die _anhang_ Konfiguration.
  ],
  abstract: [
    Englische Version der Kurzfassung (siehe #link(<Kurzfassung>)[_Kurzfassung_])
  ],
  vorwort: [
    Perönlicher Zugang zum Thema. Gründe für die Themenwahl.
  ],
  danksagung: [
    Dank an Personen, die bei der Erstellung der Arbeit unterstützt haben.
  ],
  anhang: include "anhang.typ", // entfernen falls nicht benötigt
  literaturverzeichnis: bibliography.with("literaturverzeichnis.bib")
)



// ---------------- Hauptdokument ------------------

= Einleitung
#autor[Name-1]

- Kurzbeschreibung: Wie lautet das Thema? Welche Hintergründe gibt es zu diesem Thema? Was ist schon darüber bekannt?
- Beschreibung der Leistung: Was ist das Ziel der Arbeit? Für wen hat die Arbeit Relevanz? Hinweis auf Kooperationspartner. Welche Themenstellung soll mit der Arbeit bearbeitet werden?
- Darstellung der Vorgehensweise: In welche Kapitel ist die Arbeit gegliedert? Wie ist sie aufgebaut? Was behandeln die einzelnen Kapitel (kurz)?

= Haupteil \#1
#autor[Name-2]

In den Kapiteln des Hauptteils legen die einzelnen Schüler*innen Ihre Vorgehensweise und Ergebnisse dar. Je nach Aufgabenstellung können die folgenden (aber auch andere) Punkte behandelt werden:

- Theorie
  - Begriffe definieren und erklären
  - Theorien beschreiben, kommentieren, miteinander vergleichen, evaluieren
  - Ev. Vorhandene Ergebnisse beschreiben und interpretieren
- Empirischer Teil: Darstellung der Daten und Auswertungsmethoden
  - Ausgewählte Daten beschreiben
  - Erhebungsverfahren/-methoden beschreiben
  - Eigene Ergebnisse darstellen, interpretieren, evaluieren
  - Problemlösungen darstellen
  - Auswirkungen der Ergebnisse diskutieren
- Praktischer Teil: Beschreibung des Produkterstellungsprozesses
  - Zielgruppe und Methoden beschreiben
  - Entwicklungsprozess beschreiben
  - Schwierigkeiten beschreiben und Lösungswege aufzeigen
  - Anwendungsaspekte des Produkts vorstellen
  - Unterschiede zu anderen/ähnlichen Produkten herausarbeiten
Die konkrete Struktur des Hauptteils hängt von der jeweiligen Themenstellung ab.



= Haupteil \#2
Dieses Kapitel ist nur dazu da, um die gestalterischen Elemente (Überschriften, Tabellen, Abbildungen, Literaturverweise, etc.) beispielhaft darzustellen.

== Typst

#let typst = box(height: 12pt, baseline: 4pt, image("abbildungen/typst.svg"))

Ihr verwendet die Typesetting-Sprache #typst um die Diplomarbeit zu formatieren. Die Sprache ist äußerst mächtig, enthält jedoch auch sehr einfache Sprachkonstrukte um die gängigsten Formatierungen zu bewerkstelligen. 

Falls ihr Dinge benötigt die über die kurze Beschreibung dieses Kapitels hinausgeht, seht euch die #link("https://typst.app/docs")[Dokumentation] an.

== Textgestaltung

#typst stellt folgende syntax für übliche Textgestaltung zur Verfügung:
- `*fetter Text*` wird zu *fetter Text*

- `_kursiver Text_` wird zu _kursiver Text_
- #raw("`raw Text`") wird zu `raw Text`
- `#underline[unterstrichener Text]` wird zu #underline[unterstrichener Text]

Weitere Funktionen findet ihr in der #link("https://typst.app/docs/reference/text/")[Dokumentation].
  

== Unterkapitel

Wenn möglich bitte nur maximal drei Ebenen an Gliederung verwenden, damit die Arbeit übersichtlich bleibt. Um eine Überschrift zu schreiben beginnt die Zeile mit ein oder mehreren `=` gefolgt von der Überschrift selbst. Z.B.: `== Überschrift der Ebene zwei`.

== Ausgearbeitet von
#autor[Name-1]

Unter den Kapiteln der Ebenen 1 und 2 muss angemerkt sein, wer dieses Kapitel erstellt hat.
Dafür direkt nach der Überschrift die Funktion `#autor[<name>]` aufrufen. 

Der Autor/die Autorin eines Kapitels muss nur angegeben werden, wenn er sich vom vorherigen unterscheidet. Wenn zum Beispiel das komplette Kapitel 2 von Hans Mustermann geschrieben wurde, dann muss bei 2.1, 2.2, etc. kein Name angegeben werden.


== Aufzählungen

Für Aufzählungen sollen die auch hier verwendeten Aufzählungspunkte verwendet werden:
- Ebene 1
  - Ebene 2
  - Ebene 2
    - Ebene 3
- Ebene 1

Mehr dazu in der #link("https://typst.app/docs/reference/model/list/")[Typst-Dokumentation].

== Numerierung

Für Nummerierungen gilt dasselbe wie für Aufzählungen.

+ Ebene 1
  + Ebene 2
  + Ebene 2
    + Ebene 3
+ Ebene 1

Mehr dazu in der #link("https://typst.app/docs/reference/model/enum/")[Typst-Dokumentation].

== Tabellen <Tabellen>

Alle Tabellen müssen eine Abbildung sein. Daher muss eine die `table` Funktion innerhalb der `figure` funktion verwendet werden. Wird `figure` nicht verwendet, kommt die Tabelle nicht im Tabellen- und Abbildungsverzeichnis vor.

#figure(
  table(
    inset: 10pt,
    columns: 4,
    [t], [1], [2], [3],
    [y], [0.3s], [0.4s], [0.8s],
  ),
  caption: [Zeit Resultate],
)

Es lohnt sich die dazugehörige Dokumentation auf #link("https://typst.app/docs/reference/model/table/")[typst.app] durchzulesen.

== Abbildungen

Um eine Abbildung einzufügen verwendest die `image` Funktion. Es muss wie bei @Tabellen darauf geachtet werden, dass `figure` runterherum gesetzt wird.

#figure(
  image("abbildungen/demoAbb.jpeg"),
  caption: [Die `image` Funktion nimmt als Parameter den Pfad zur entsprechenden Datei.]
)

Alle `figure` elemente werden in den entsprechenden Verzeichnissen gelistet.


== Source Code

Generell gilt, dass Source Code Ausschnitte durchaus in der Diplomarbeit vorkommen dürfen – allerdings bitte nur wichtige und kurze Teile. Seitenweise Source Code ist nicht erwünscht.

Source Code wird mit `raw`-Blöcken, die mit *#"```"* gestartet werden, hinzugefügt. Um Syntax-Highlighting zu erhalten, muss die Dateiendung hinter *#"```"* angefügt werden.

Sieh dir das folgende C\# Beispiel an:

```cs
namespace MyCoolDiplomaProject
{
  /// <summary>
  /// MainWindow.xaml
  /// </summary>
  public partial class MainWindow : Window
  {
    private ObservableCollection<StorageContainer> st =
                                new ObservableCollection<StorageContainer>();
    public MainWindow()
    {
      InitializeComponent();
      lbliste.ItemsSource = st;
    }
  ...
}
```

Mehr dazu in der #link("https://typst.app/docs/reference/text/raw/")[Typst-Dokumentation].

== Literaturverweise

Quellenangabe können in der Datei `literaturverzeichnis.bib` gespeichert werden. Es wird dabei das *BibTEX* Format verwendet. 

Ein Beispiel für einen Online-Verweis:
```
@online{WinNT,
  author = {MultiMedia LLC},
  title = {{MS Windows NT} Kernel Description},
  year = 1999,
  url = {http://web.archive.org/web/20080207010024/http://www.808multimedia.com/winnt/kernel.htm},
  urldate = {2010-09-30}
}
```
Dieser Verweis kann dann mit `@WinNT` @WinNT referenziert werden und ist dann im Literaturverzeichnis zu finden.


== Kreuzverweise

Neben allen `figure`-Elementen und zu allen Überschriften können `label`s hinzugefügt werden. Die syntax dafür ist `<name>`. 

Beispiele sind
#figure( 
  ```typ
  == Überschrift <HeadingLabel>
  
  #figure(...) <AbbLabel>
  ```,
  caption: [Dieses Codebeispiel ist auch mit einem `label` versehen.]
) <KreuzverweisBeispiel>


Die Labels aus @KreuzverweisBeispiel können dann wie Literaturverweise mit `@HeadingLabel` und `@AbbLabel` referenziert werden.

