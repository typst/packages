// dieser Import ist nur für set-responsible notwendig und kann auch ganz am Ende hinzugefügt werden
#import "@preview/bhs-school-bundle:0.3.1": *

#set-responsible([Claudio Landerer])

// heading Funktion anstatt = verwendet um Nummern und Aufnahme in Inhaltsverzeichnis zu unterdrücken
#heading(level: 1, numbering: none, outlined: false)[Einleitende Bemerkungen]
<einleitende-bemerkungen>
#heading(level: 1, numbering: none, outlined: false)[Notationen]
<notationen>
Beschreibung wie Code, Hinweise, Zitate etc. formatiert werden

= Einleitung
<einleitung>

= Projektmanagement
<projektmanagement>
== Metainformationen
<metainformationen>
- Projektteam: \[Auflistung der Team-Mitglieder und ihrer
  Verantwortungsbereiche\]

- Projektbetreuer: \[Auflistung der Projekt-Betreuer\]

- Projektpartner: \[Firmenname, Adresse und Ansprechperson des
  Projektbetreuers\]

== Vorerhebungen
<vorerhebungen>
=== Ist-Zustand
<ist-zustand>
=== Soll-Zustand
<soll-zustand>
=== Projektumfeldanalyse
<projektumfeldanalyse>
- Identifikation der Stakeholder

- Charakterisierung der Stakeholder

- Maßnahmen

- Grafische Darstellung des Umfeldes

=== Risikoanalyse
<risikoanalyse>
- Risikomatrix

== Pflichtenheft
<pflichtenheft>
=== Zielbestimmung
<zielbestimmung>
- Projektbeschreibung

- IST-Zustand

- SOLL-Zustand

- NICHT-Ziele (Abgrenzungskriterien)

=== Produkteinsatz und Umgebung
<produkteinsatz-und-umgebung>
- Anwendungsgebiet

- Zielgruppen

- Betriebsbedingungen

- Hard-/Softwareumgebung

=== Funktionalitäten
<funktionalitäten>
- MUSS-Anforderungen

  - Funktional

  - Nicht-funktional

- KANN-Anforderungen

  - Funktional

  - Nicht-funktional

=== Testszenarien und Testfälle
<testszenarien-und-testfälle>
- Beschreibung der Testmethodik

- Testfall 1

- Testfall 2

- …

=== Liefervereinbarung
<liefervereinbarung>
- Lieferumfang

- Modus

- Verteilung(Deployment)

== Problemanalyse
<problemanalyse>
=== Use-Case-Analyse
<use-case-analyse>
- Use-Cases auf Basis von Benutzerzielen identifizieren:

  - Benutzer eines Systems identifizieren

  - Benutzerziele identifizieren (Interviews)

  - Use-Case-Liste pro Benutzer definieren

- Use-Cases auf Basis von Ereignissen identifizieren:

  - Externes Event triggert einen Prozess

  - Zeitliches Event triggert einen Prozess (Zeitpunkt wird erreicht)

  - State-Event (Zustandsänderung im System triggert einen Prozess)

- Werkzeuge:

  - USE-Case-Beschreibungen (textuell, tabellarisch)

  - USE-Case-Diagramm

  - Aktivitätsdiagramm für den Use-Case (Interaktion zwischen Akteur und
    System abbilden)

  - System-Sequenzdiagramm (Spezialfall eines Sequenzdiagramms: Nur 1
    Akteur und 1 Objekt, das Objekt ist das komplette System, es geht um
    die Input/Output Requirements, die abzubilden sind)

=== Domain-Class-Modelling
<domain-class-modelling>
- \"Dinge\" (Rollen, Einheiten, Geräte, Events etc.) identifizieren, um
  die es im Projekt geht

- ER-Modellierung oder Klassendiagramme

- Zustandsdiagramme (zur Darstellung des Lebenszyklus von Domain-Klassen
  darstellen)

=== User-Interface-Design
<user-interface-design>
- Mockups

- Wireframes

== Planung
<planung>
=== Projektstrukturplan
<projektstrukturplan>
=== Meilensteine
<meilensteine>
=== Ablaufplanung
<ablaufplanung>
Gantt-Chart

=== Abnahmekriterien
<abnahmekriterien>
=== Pläne zur Evaluierung
<pläne-zur-evaluierung>
=== Ergänzungen und zu klärende Punkte
<ergänzungen-und-zu-klärende-punkte>
= Vorstellung des Produktes
<vorstellung-des-produktes>
Vorstellung des fertigen Produktes anhand von Screenshots, Bildern,
Erklärungen.

= Eingesetzte Technologien
<eingesetzte-technologien>
- Alle Technologien, die verwendet wurden.

- Technologien die aus dem Unterricht bekannt sind, nur nennen und deren
  Einsatzzweck im Projekt beschreiben, nicht die Technologien selbst.

- Technologien die aus dem Unterricht nicht bekannt sind, im Detail
  beschreiben incl. deren Einsatz im Projekt

- Fokus aus eingesetzten Frameworks

= Systementwurf
<systementwurf>
== Architektur
<architektur>
=== C4 - Modell
<c4---modell>
Beschreibung der Architektur der Software unter Verwendung des C4
Modells: #link("https://c4model.com/").

Darstellung und Beschreibung der Systemarchitektur.

- statische Zerlegung des Systems in seine physischen Bestandteile
  (Komponenten, Komponentendiagramm)

- (textuelle) Beschreibung des dynamischen Zusammenwirkens aller
  Komponenten

- (textuelle) Beschreibung der Strategie für die Architektur, d. h. wie
  die Architektur in Statik und Dynamik funktionieren soll.

- Verwendung von Referenzarchitekturen bzw. Architekturmustern (als
  Schablonen, z.B. MVC. Plugin, Pipes and Filters)

  - MVC

  - Schichten

  - Pipes

  - Request Broker

  - Service-Oriented

=== Benutzerschnittstellen
<benutzerschnittstellen>
- Design des UIs

- Dialoge, Dialogsteuerung, Ergonomie, Gestaltung, Eingabeüberprüfungen

=== Datenhaltunskonzept
<datenhaltunskonzept>
- Design der Datenbank (ER-Modell)

- Design des Zugriffs auf diese Daten (Datenhaltungskonzept)

- Caching, Transaktionen

=== Konzept für Ausnahmebehandlung
<konzept-für-ausnahmebehandlung>
- Systemweite Festlegung, wie mit Exceptions umgegangen wird

- Exceptions sind primär aus den Bereichen UI, Persistenz,
  Workflow-Management

=== Sicherheitskonzept
<sicherheitskonzept>
Beschreibung aller sicherheitsrelevanten Designentscheidungen

- Design der Security-Elemente

- Design von Safety-Elementen (Fehlertoleranz, Verfügbarkeit etc.)

=== Design der Testumgebung
<design-der-testumgebung>
- wie wird getestet (Unit-Testing, Integrationstesting, Systemtests,
  Akzeptanztests)

- Testumgebung, Testprozess, Teststrategie, Testmethoden, Testfälle

=== Design der Ausführungsumgebung
<design-der-ausführungsumgebung>
- Deployment (DevOps)

- Betrieb (besonders Hoch- und Hertunerfahren der Anwendung)

== Detailentwurf
<detailentwurf>
Design jedes einzelnen USE-Cases

- Design-Klassendiagramme vom Domain-Klassendiagramm ableiten (incl.
  detaillierter Darstellung und Verwendung von Vererbungshierarchichen,
  abstrakten Klassen, Interfaces)

- Sequenzdiagramme vom System-Sequenz-Diagramm ableiten

- Aktivitätsdiagramme

- Detaillierte Zustandsdiagramme für wichtige Klassen

Verwendung von CRC-Cards (Class, Responsibilities, Collaboration) für
die Klassen

- um Verantwortlichkeiten und Zusammenarbeit zwischen Klassen zu
  definieren und

- um auf den Entwurf der Geschäftslogik zu fokussieren

Design-Klassen für jeden einzelnen USE-Case können z.B. sein:

- UI-Klassen

- Data-Access-Klassen

- Entity-Klassen (Domain-Klassen)

- Controller-Klassen

- Business-Logik-Klassen

- View-Klassen

Optimierung des Entwurfs (Modularisierung, Erweiterbarkeit, Lesbarkeit):

- Kopplung optimieren

- Kohäsion optimieren

- SOLID

- Entwurfsmuster einsetzen

= Implementierung
<implementierung>
#set-responsible([NEMI])
Detaillierte Beschreibung der Implementierung aller Teilkomponenten der
Software entlang der zentralsten Use-Cases:

- GUI-Implementierung

- Controllerlogik

- Geschäftslogik

- Datenbankzugriffe

- GUI-Implementierung

- Controllerlogik

- Geschäftslogik

- Datenbankzugriffe

- GUI-Implementierung

- Controllerlogik

- Geschäftslogik

- Datenbankzugriffe

- GUI-Implementierung

- Controllerlogik

- Geschäftslogik

- Datenbankzugriffe

Detaillierte Beschreibung der Teststrategie (Testdriven Development):

- UNIT-Tests (Funktional)

- Integrationstests

Zu Codesequenzen:

- kurze Codesequenzen direkt im Text (mit Zeilnnummern auf die man in
  der Beschreibung verweisen kann)

- lange Codesequenzen in den Anhang (mit Zeilennummer) und darauf
  verweisen

= Deployment
<deployment>
- Umsetzung der Ausführungsumgebung

- Deployment

- DevOps-Thema

= Tests
<tests>
== Systemtests
<systemtests>
Systemtests aller implementierten Funktionalitäten lt. Pflichtenheft

- Beschreibung der Teststrategie

- Testfall 1

- Testfall 2

- Tesfall 3

- …

== Akzeptanztests
<akzeptanztests>
= Evaluation
<evaluation>
== Projektevaluation
<projektevaluation>
Vergleich des geplanten und tatsächlichen zeitlichen Ablaufes.

== Produktevaluation
<produktevaluation>
Vergleich der geplanten und tatsächlich umgesetzten
Produktfunktionalitäten.

== Resümee
<resümee>
Erkenntnisse der einzelnen Autoren.

= Benutzerhandbuch
<benutzerhandbuch>
falls im Projekt gefordert

= Betriebswirtschaftlicher Kontext
<betriebswirtschaftlicher-kontext>
BW-Teil

= Zusammenfassung
<zusammenfassung>

- Etwas längere Form des Abstracts

- Detaillierte Beschreibung des Outputs der Arbeit

= Beispielkapitel
<beispielkapitel>

#set-responsible([Stefan Stolz])

== Sonderfunktionen
<sonderfunktionen>

== Beispiele zitieren
<beispiele-zitieren>
Das ist ein Zitat mit Klammern, @resnick_distributed_1996, das
ein Zitat ohne Klammern, um die Autor Namen in einen Satz einzubauen: #cite(label("harel_situating_1991"), form: "prose"). Hier das selbe
Zitat mit einer Seitenangabe und Klammern
@resnick_distributed_1996[S. 42].

Wird ein Absatz aus einer Quelle sinngemäß übernommen (nicht wörtlich),
dann kann nach dem Absatz das entsprechende Zitat in Klammern angeführt
werden. @anastopoulou_constructionism_2012

Wenn ein Zitat im Text angegeben wird, wie z.B. so
#cite(label("beer_rudolf_aspekte_2011"), form: "prose"), können die Klammern weggelassen
werden.

Der folgende Absatz zeigt ein Blockzitat (wörtlich übernommene
Textpassage aus einer Quelle):

#quote(block: true)[
Dr. Heinrich Faust ist ein angesehener Wissenschaftler und Akademiker,
der trotz seiner wissenschaftlichen Studien und einer guten Bildung
seinen Wissensdurst nicht stillen kann. Eines Nachts sitzt er in seinem
Studierzimmer und grübelt über den Sinn des Lebens nach, findet jedoch
keine Antworten. Daraufhin wendet er sich der Geisterwelt zu. Er
beschwört einen Erdgeist, versucht sich den Geistern gleich zu stellen,
was ihm jedoch nicht gelingt. Von Ohnmacht getrieben will er sich das
Leben nehmen. Sein Selbstmordversuch wird jedoch von Glockenläuten zum
Ostertag und seinen Kindheitserinnerungen gestört.

@ackermann_piagets_2001
]

Hier wird ein wörtliches Zitat inline angegeben:
#quote[Das ist ein kleines direktes Zitat.] #cite(label("gohlich_lernen:_2007"))

Und danach geht es gleich wieder direkt weiter. 

== Beispiele Abbildungen
<beispiele-abbildungen>
Auf diese Weise kann man zum Beispiel in typst auf die
#link(<fig:ArduExample>)[13.1] verweisen. Die Kennung für den Verweis
vergibt man selbst mit dem "label" Kommando bei der Abbildung.

Jede Abbildung muss nicht nur mindestens einen Verweis im Text haben. Es
wird außerdem eine Bildunterschrift verlangt. Für diese ist festgesetzt,
dass die Abbildungsunterschrift alleine ausreichend sein muss, um zu
verstehen, was am Bild zu erkennen ist.

Der nächste wichtige Punkt sind die Quellenangaben bei Abbildungen. Der
Author muss zu jeder Abbildung die notwendigen Rechte haben und idealer
Weise gibt man diese bei der Abbildung mit an. In
#link(<fig:ArduExample>)[13.1] auf Seite sieht man das.

Es ist wichtig zu verstehen, dass typst die Positionierung von
Abbildungen übernimmt. Man definiert die Abbildung über begin-figure
dort, wo man die Abbildung in etwa haben möchte, den Rest übernimmt
typst

#figure(
  image("./typst_media/figures/Arduino_Example.jpg", width: 72%),
  caption: [
    Hintergrund: Arduino Board; Vordergrund: eine Lichterreihe und ein
    Lichtsensor (Fotowiderstand); In diesem Beispiel wird die
    Lichterreiche je nach Helligkeit des Umgebungslichtes gesteuert.
    Durch leichte Modifikationen kann man damit eine Lichtschranke oder
    auch eine Helligkeitssteuerung für das Smartphone simulieren.
  ]
)
<fig:ArduExample>

==== Beispiele Tabellen
<beispiele-tabellen>
#link(<tbl:lineBreak>)[13.1] ist ein Beispiel für eine einfache Tabelle
mit Zeilenumbruch, #link(<tbl:shiftReg>)[13.2] für eine aufwändigere
Tabelle mit einer Abbildung und Überschrift.

<tbl:lineBreak>
#figure( 
  table(
    columns: 2,
    align: left,
    [Use Case], [Opret Server],
    [Scenarie], [At oprette en server med bestemte regler som tillader folk at spille zusammen. More Text more text More Text],
  ),
  caption: [Einfache Tabelle mit Zeilenumbruch],
)

<tbl:shiftReg>
#figure(
    stack(
      image("./typst_media/figures/shift_reg.png", width: 28%),
      table(
        columns: 2,
        align: left,
        inset: 6pt,
        [$V_(c c)$],
        [Positive supply voltage],
        [GND],
        [Ground],
        [SER IN],
        [Daten Pin],
        [SRCK],
        [Clock Pin],
        [RCK],
        [Latch Pin],
        [$overline(S R C L R)$],
        [Wenn #strong[shift-register clear] LOW ist, werden die input Register
        gelöscht],
        [$overline(G)$],
        [Wenn #strong[output enable] HIGH ist, werden die Daten im Output
        Buffer LOW gehalten],
      ),
    ),
    caption: [Aufwändige Tabelle mit Abbildung und Caption],
)

Tabellen sind in typst sehr kompliziert zu erzeugen. Alternativ kann man
die Tabellen auch in einem anderen Programm gestalten und als Bild
wieder einfügen. Dieses Bild kann dann innerhalb von begin-Table
verwendet werden. Bedenke aber, dass die Tabellen in typst zu erzeugen
der saubere Weg ist.

== Beispiele Listen
<beispiele-listen>
Im Folgenden wird eine Liste gezeigt:

- Ich weiß, dass viele Geräte des täglichen Lebens durch Computer
  gesteuert werden und kann für mich relevante nennen und nutzen.

  + Und jetzt eine Numerierung

  + Und jetzt eine Numerierung

- Ich kann wichtige Bestandteile eines Computersystems (Eingabe-,
  Ausgabegeräte und Zentraleinheit) benennen, kann ihre Funktionen
  beschreiben und diese bedienen.

Und jetzt eine Numerierung:

+ Aufzählungspunkt

  + Unteraufzählung

  + Unteraufzählung

    - Und jetzt noch eine Ebene ohne Aufzählung

    - Und jetzt noch eine Ebene ohne Aufzählung

+ Aufzählungspunkt

+ Aufzählungspunkt

+ Aufzählungspunkt

+ Aufzählungspunkt

== Beispiel Symbole
<beispiel-symbole>
Im Internet finden sich umfassende Auflistungen. Hier häufige Beispiele:

Copyright: ©, Trademark: or #super[TM], Registered: , DOLLAR: , EURO: ,
Unendlich: $oo$ (Mathematik Symbol, deshalb in Mathe Umgebung für
Formel), Griechische Symbole: $alpha$, $beta$, ..., Haken: \$\\surd\$

== Formeln
<formeln>
The well known Pythagorean theorem $x^2 plus y^2 eq z^2$ was proved to
be invalid for other exponents. Meaning the next equation has no integer
solutions:

$ x^n plus y^n eq z^n $

Im Folgenden ein Bock mit einfacher #link(<eq:simple>)[\[eq:simple\]]
und komplexer #link(<eq:line1>)[\[eq:complex\]], sowie ein Block mit
mehreren Zeilen #link(<eq:line1>)[\[eq:line1\]] und
#link(<eq:line2>)[\[eq:line2\]].

$ sqrt(a^2 plus b^2) eq c $
<eq:simple>

$ r eq frac(sum_(i eq 0)^n lr((lr((x_i minus m x)) ast.basic lr((y_(i minus d) minus m y)))), sqrt(sum_(i eq 0)^n lr((x_i minus m x))^2) sqrt(sum_(i eq 0)^n lr((y_(i minus d) minus m))^2)) $
<eq:line1>

$ G T C G A C G A A T T C T A G T T C T A G G G T A A A C\
C T T C A A T A C T A C A C T T G C A G G A T C C $
<eq:line2>

== Beispiel Codesequenz
<beispiel-codesequenz>
In #link(<code:qj>)[\[code:qj\]] sieht man ein Quick-Sort-Listing in der
Programmiersprache JAVA. Das Listings-Paket übernimmt die Formatierung
von Codebausteinen und kann in der Präambel nach Belieben auf eine
andere Sprache konfiguriert werden.

=== Quicksort in JAVA
<quicksort-in-java>
#figure(
  kind: "listing",
  supplement: [Quelltext],
  caption: [Quicksort in JAVA],
```java
public class QuickSort {
  public static void main(String[] args) {
    int[] x = { 9, 2, 4, 7, 3, 7, 10 };
    System.out.println(Arrays.toString(x));

    int low = 0;
    int high = x.length - 1;

    quickSort(x, low, high);
    System.out.println(Arrays.toString(x));

  public static void quickSort(int[] arr, int low, int high) {
    if (arr == null || arr.length == 0)
    return;

    if (low >= high)
    return;

    // pick the pivot
    int middle = low + (high - low) / 2;
    int pivot = arr[middle];

    // make left < pivot and right > pivot
    int i = low, j = high;
    while (i <= j) {
    while (arr[i] < pivot) {
      i++;
    }

    while (arr[j] > pivot) {
      j--;
    }

    if (i <= j) {
      int temp = arr[i];
      arr[i] = arr[j];
      arr[j] = temp;
      i++;
      j--;
      }
    }

    // recursively sort two sub parts
    if (low < j)
      quickSort(arr, low, j);

    if (high > i)
      quickSort(arr, i, high); 
  }
}
```
)
<code:qj>

== mermaid Diagramme

@figure:mermaid zeigt eine Abbildung die durch mermaid Code erstellt wurde.

#figure(
  placement: auto,
  mermaid(
    "graph TD; A-->B;",
    base-theme: "default",
    theme: (
      background: "#f4f4f4",
      primary_color: "#ff0000",
    ),
    layout: (
      node_spacing: 50,
    ),
  ),
  caption: [Ein Mermaid Diagramm]
)<figure:mermaid>

= Anhang-Kapitel
<anhang-kapitel>
== Anhang-Section
<anhang-section>
Testtext

#bibliography("./Literatur_Verzeichnis.biblatex.bib", style: "harvard-cite-them-right")
