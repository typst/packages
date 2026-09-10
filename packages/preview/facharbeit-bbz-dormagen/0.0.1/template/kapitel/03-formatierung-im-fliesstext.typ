#import "../_system/ui.typ": bild, einfache-tabelle, hinweisbox, definition, beispiel, merke
#import "../_system/utils.typ": a3-seite

= Formatierung im Fließtext

Wenn die technische Infrastruktur steht, beginnen Sie mit dem Schreiben. Die Formatierung von Texten lässt sich in Typst sehr intuitiv und ohne verschachtelte Menüs vornehmen. Dieser Ansatz ermöglicht es Ihnen, sich voll und ganz auf den Inhalt Ihrer Arbeit zu konzentrieren.

== Grundlegende Formatierungen
Ihre wichtigsten Werkzeuge für den normalen Text sind Sonderzeichen:

- Das ist *fetter Text* (geschrieben mit `*Sternchen*`).
- Das ist _kursiver Text_ (geschrieben mit `_Unterstrichen_`).

#hinweisbox(titel: "Typografische Feinheiten (Kapitälchen & Gedankenstrich)")[
  Im Rahmen eines professionellen Layouts finden häufig Kapitälchen Anwendung. Diese eignen sich exzellent zur Hervorhebung von Autoren- oder Firmennamen im Fließtext. In Typst nutzen Sie dafür den Befehl `#smallcaps("Text")`.
  
  *Mikrotypografie-Tipp:* Verwenden Sie für einen echten Gedankenstrich (den sogenannten Halbgeviertstrich) immer zwei Bindestriche hintereinander (`--`). Typst wandelt diese automatisch in einen langen Gedankenstrich (–) um. Ein einzelner Bindestrich (`-`) sollte nur für Trennungen oder Doppelnamen verwendet werden!
]

== Listen und Checkboxen
Die Erstellung von Aufzählungen gestaltet sich äußerst unkompliziert. Setzen Sie einfach einen Bindestrich `-` oder ein Pluszeichen `+` für nummerierte Listen. Ein Leerzeichen bewirkt eine Einrückung in die nächste Ebene.

So geben Sie es ein:
```typst
- Ebene 1: Hauptkategorie
  - Ebene 2: Unterkategorie
    - Ebene 3: Detailpunkt
- Ebene 1: Zurück zur Hauptkategorie

+ Erster Schritt
+ Zweiter Schritt
```

Und so sieht das Ergebnis aus:
- Ebene 1: Hauptkategorie
  - Ebene 2: Unterkategorie
    - Ebene 3: Detailpunkt
- Ebene 1: Zurück zur Hauptkategorie
  
+ Erster Schritt
+ Zweiter Schritt

Interaktive Checkboxen für To-do-Listen lassen sich ebenfalls leicht abbilden. (Tipp: Ein `\` am Ende der Zeile erzwingt einen manuellen Zeilenumbruch):

So geben Sie es ein:

```typst
[x] Installation von Typst \
[x] Vorlage herunterladen \
[ ] Facharbeit schreiben
```

Und so sieht das Ergebnis aus: \

[x] Installation von Typst \
[x] Vorlage herunterladen \
[ ] Facharbeit schreiben \

== Silbentrennung steuern (Profi-Tipp)
Typst bricht Wörter am Zeilenende grundsätzlich automatisch nach den Regeln der deutschen Rechtschreibung um. Zuweilen erfolgt die Trennung jedoch typografisch ungünstig, beispielsweise bereits nach lediglich zwei Buchstaben (wie bei `Lo-gistik`). Dies liegt an dem im Hintergrund verwendeten Wörterbuch, das nach reinen Silben und nicht nach optischer Ästhetik trennt. Eine generelle Abschaltung solcher Trennungen ist nicht vorgesehen.

Für ein makelloses Schriftbild stehen Ihnen stattdessen zwei manuelle Werkzeuge zur Verfügung:
1. *Umbruch erzwingen/erlauben:* Schreiben Sie `-?` mitten in ein Wort (z. B. `Logis-?tik`), um Typst zu sagen: *"Wenn du dieses Wort trennen musst, dann darfst du es AUSSCHLIESSLICH an dieser Stelle tun!"*
2. *Umbruch komplett verbieten:* Wenn ein Wort oder eine kurze Wortgruppe (wie `BBZ Dormagen` oder E-Mail-Adressen) am Zeilenende _niemals_ getrennt werden darf, setzen Sie es in eine schützende Box: `#box[BBZ Dormagen]`. 

== Mathematische Formeln
Die Darstellung mathematischer Formeln gestaltet sich in Typst äußerst komfortabel. Setzen Sie die entsprechenden Ausdrücke hierzu lediglich zwischen zwei Dollarzeichen `$`.

Ein Beispiel für die Grundrechenarten:
```typst

$ 5 + 3 - 2 * 4 / 2 = 4 $

```

Ergebnis: $ 5 + 3 - 2 * 4 / 2 = 4 $

Betriebswirtschaftliche Formeln, z. B. für den Deckungsbeitrag:
```typst

$ "DB" = p - k_v $

$ "DB" = "Stückerlös" - "variable Stückkosten" $
```

Ergebnis:

$ "DB" = p - k_v $

$ "DB" = "Stückerlös" - "variable Stückkosten" $

Sie können diese Formeln in Ihrem eigenen Dokument gerne kopieren und die Buchstaben (`DB`, `p`, `k_v`) einfach durch Ihre eigenen Variablen ersetzen!

== Besonderheiten der Seitennummerierung (Paginierung)
Wenn Sie Ihre Facharbeit erstellen, werden Ihnen womöglich bestimmte Besonderheiten in der Seitennummerierung auffallen. Diese sind jedoch keine Fehler der Vorlage, sondern folgen den strengen Richtlinien des wissenschaftlichen Buchsatzes:

1. *Leere Seiten (Vakatseiten):* Wenn Sie Ihre Arbeit im Duplex-Druck (Vorder- und Rückseite) konfigurieren, beginnen neue Hauptkapitel (sowie Verzeichnisse) immer auf einer rechten Seite (einer ungeraden Seitenzahl). Endet das vorherige Kapitel bereits auf einer rechten Seite, fügt das System automatisch eine leere linke Seite ein, um den Rhythmus zu wahren. Diese Vakatseiten werden bei der Gesamtseitenzahl mitgezählt, bleiben aber gemäß typografischen Regeln komplett weiß (sie erhalten weder eine Kopfzeile noch eine aufgedruckte Seitenzahl).
2. *Ausblenden der Kopfzeile:* Auf den Seiten, auf denen ein neues Hauptkapitel beginnt, wird die Kopfzeile bewusst ausgeblendet. Dies verhindert eine unschöne Tautologie (Dopplung), da die Überschrift sonst direkt unter der Kopfzeile stehen würde.
3. *DIN A3-Seiten im Anhang:* Für sehr große Tabellen oder komplexe Prozessdiagramme (wie BPMN) können Sie im Anhang Querformat-Seiten in DIN A3 einbinden. Die Regel lautet hier, dass die Seitenzahl auch auf einem A3-Blatt an derselben relativen Position stehen muss wie auf einer A4-Seite, damit sie beim Falten deckungsgleich ist. 

Nutzen Sie für A3-Seiten im Anhang einfach folgenden Befehl, der all diese Positionierungen automatisch für Sie übernimmt:
```typst
#a3-seite[
  = Großer Projektplan
  // Hier kommt Ihr breiter Inhalt
]
```
