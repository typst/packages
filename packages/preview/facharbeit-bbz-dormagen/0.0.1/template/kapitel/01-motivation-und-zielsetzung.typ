#import "../_system/ui.typ": bild, einfache-tabelle, hinweisbox, definition, beispiel, merke
#import "../_system/utils.typ": a3-seite

= Motivation und Zielsetzung

Herzlichen Glückwunsch! Sie haben sich entschieden, Ihre Facharbeit mit Typst zu schreiben. Das ist eine hervorragende Wahl. Typst ist ein modernes, blitzschnelles Satzsystem, das Ihre Arbeit aussehen lässt, als käme sie frisch aus einem professionellen Verlagshaus.

== Der Sinn einer Facharbeit
Bevor es an die Technik geht, hier ein kurzer Reminder, worum es in dieser Arbeit eigentlich geht: An der Fachschule für Wirtschaft sollen Sie beweisen, dass Sie ein reales, kaufmännisches Problem aus der Praxis (z. B. im Bereich SCM oder bei der Auswahl von ERP-Systemen) erkennen, es strukturiert bearbeiten und *wirtschaftlich sinnvoll lösen* können. Nutzen Sie dafür exakt die Methoden und Instrumente, die Sie im Unterricht gelernt haben. Die Facharbeit ist quasi Ihr "Gesellenstück" der Betriebswirtschaft! (Für die methodischen und formalen Grundlagen des wissenschaftlichen Arbeitens empfiehlt sich als Standardwerk @theisen2021[S. 45ff]).

Dieses Dokument dient Ihnen dabei als interaktives Handbuch. Es ist selbst in Form einer Facharbeit verfasst, um Ihnen direkt am "lebenden Objekt" zu zeigen, wie Sie die Vorlage für Ihre eigenen Zwecke einsetzen. Die in diesem Handbuch gezeigten Tabellen, Formeln und Diagramme sind *Muster*, die Sie gerne kopieren, anpassen und für Ihre eigene Arbeit verwenden dürfen.

== Das System arbeitet für Sie
Sie können Ihre Facharbeit natürlich auch in einer klassischen Textverarbeitung (wie Microsoft Word) schreiben. Wenn Sie sich jedoch für Typst entscheiden, nimmt Ihnen das System einen Großteil der lästigen Arbeit ab:

- *Die globalen Einstellungen:* Die Formatierung (Seitenränder, Schriftgrößen, Zeilenabstände, Tabellendesigns) ist in dieser Vorlage bereits zu 100 % nach den strengen formalen Vorgaben des Berufsbildungszentrums voreingestellt. Sie müssen nichts mehr layouten! (Für typografische Standards siehe auch @forssman2004[S. 120f]).
- *Absolute Stabilität:* Nichts verrutscht. In Word führt das Verschieben eines Bildes oft dazu, dass das gesamte Layout der nächsten 10 Seiten zerstört wird. Typst hält das Layout stoisch zusammen.
- *Vollautomatik:* Inhalts-, Abbildungs- und Literaturverzeichnis werden absolut fehlerfrei und ohne manuelle Updates automatisch generiert. Dies ist insbesondere bei einer Vielzahl von Quellen enorm hilfreich @logistikheute2023[S. 14].

Ihre einzige Aufgabe lautet: *Schreiben Sie einen hervorragenden Text!* Den Rest übernimmt die Maschine. Auch rechtliche Aspekte oder fachspezifische Literatur (wie @muenko2023[S. 112] oder Lexika wie @klaus2012[S. 80]) lassen sich so mühelos zitieren.

== Die goldene Regel: Was Sie bearbeiten dürfen (und was nicht!)
Diese Vorlage ist durch ein automatisches System geschützt, das von den Gutachtern zur technischen Korrektur verwendet wird. Damit Ihre Abgabe nicht wegen formaler Manipulation beanstandet wird, gelten folgende Regeln:

- *Ihre Spielwiese:* Sie bearbeiten *ausschließlich* die Datei `St_Vorlage.typ` (für Ihren Text), die Datei `St_Individualisierungen.typ` (für Ihre Metadaten wie Name und Thema) und Ihre `St_Facharbeit.bib` (für die Literatur).
- *Die Tabu-Zone:* Der Ordner `_system/` enthält die programmierte Layout-Engine. Sie dürfen diese Dateien unter *keinen Umständen* bearbeiten! Jeder Versuch, das Layout zu manipulieren (z. B. um Seitenränder zu verkleinern, damit mehr Text auf die Seite passt), wird vom Prüf-System bei der Abgabe vollautomatisch erkannt und rot markiert.
- *Der "Anti-Schusselfehler"-Test:* Sie *müssen* die Platzhalter in `St_Individualisierungen.typ` zwingend mit Ihren eigenen Daten überschreiben. Wenn Sie aus Versehen den Namen "Max Mustermann" stehen lassen, blockiert das Prüf-System.
