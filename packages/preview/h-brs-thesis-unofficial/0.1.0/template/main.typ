#import "@preview/h-brs-thesis-unofficial:0.1.0": template

#show: template.with(
  title: "Einsatz moderner Methoden in der angewandten Informatik",
  authors: "Max Mustermann",
  type-of-work: "Bachelorarbeit",
  date: "01. März 2026",
  info: (
    ("Betreuer:in", "Prof. Dr. Alexandra Kees"),
    ("Zweitgutachter:in", "Prof. Dr. Hartmut Pohl"),
  ),
  show-declaration: true,
  abbr-csv-content: read("abbr.csv"),
)

= Einleitung

Die zunehmende Digitalisierung stellt Unternehmen und Forschungseinrichtungen vor neue Herausforderungen. Bestehende Ansätze zur Datenverarbeitung stoßen dabei häufig an ihre Grenzen, sodass moderne Methoden der angewandten Informatik an Bedeutung gewinnen @mustermann2021.

Ziel dieser Arbeit ist es, geeignete Methoden zu identifizieren, deren Eignung zu bewerten und auf einen konkreten Anwendungsfall zu übertragen. Die Arbeit gliedert sich in einen Grundlagenteil, einen Methodenteil sowie eine abschließende Zusammenfassung.

= Stand der Forschung

== Grundlegende Konzepte

Die Verarbeitung großer Datenmengen erfordert effiziente Algorithmen sowie eine geeignete Systemarchitektur. @mustermann2021 beschreibt hierzu grundlegende Konzepte der Datenmodellierung, die als Ausgangspunkt für die vorliegende Arbeit dienen. @fig-architektur zeigt den schematischen Aufbau einer solchen Architektur.

#figure(
  rect(width: 100%, height: 5cm, fill: luma(230)),
  kind: image,
  caption: [Schematischer Aufbau der Systemarchitektur],
) <fig-architektur>

Aktuelle Forschungsarbeiten zeigen, dass insbesondere verteilte Systeme erhebliche Vorteile gegenüber monolithischen Architekturen bieten @schmidt2022. Die dabei eingesetzten Methoden sind jedoch stark vom jeweiligen Anwendungskontext abhängig.

== Verwandte Arbeiten

#cite(<kees2019>, form: "prose") untersuchen wissenschaftliche Arbeitsmethoden im Informatikbereich und stellen fest, dass eine strukturierte Vorgehensweise maßgeblich zur Qualität der Ergebnisse beiträgt. Diese Erkenntnisse fließen in die Methodik der vorliegenden Arbeit ein.

= Methodik und Anwendung

== Vorgehensweise

Auf Basis der im vorangegangenen Kapitel erarbeiteten Grundlagen wird in diesem Abschnitt ein Lösungsansatz entwickelt. Die Auswahl der eingesetzten Methoden orientiert sich an den Kriterien Skalierbarkeit, Wartbarkeit und Nachvollziehbarkeit. Der zugrundeliegende Ablauf ist in @fig-workflow dargestellt.

#figure(
  rect(width: 100%, height: 5cm, fill: luma(230)),
  kind: image,
  caption: [Ablauf des entwickelten Lösungsansatzes],
) <fig-workflow>

Das entwickelte Konzept wurde prototypisch implementiert und anhand eines realen Datensatzes evaluiert. Die Rohdaten lagen im @CSV Format vor und wurden über eine @REST konforme @API per @HTTP abgerufen. Die Ergebnisse zeigen, dass der gewählte Ansatz die gestellten Anforderungen erfüllt @schmidt2022.

== Ergebnisse

Die durchgeführten Experimente bestätigen die Ausgangshypothese. @tbl-ergebnisse fasst die gemessenen Kennwerte der evaluierten Verfahren zusammen. Im Vergleich zu bestehenden Verfahren konnte eine Verbesserung der Verarbeitungsgeschwindigkeit um durchschnittlich 34~% erzielt werden. Die Genauigkeit blieb dabei auf einem vergleichbaren Niveau. @fig-ergebnisse visualisiert die Laufzeitunterschiede zwischen den drei Verfahren.

#figure(
  rect(width: 100%, height: 5cm, fill: luma(230)),
  kind: image,
  caption: [Laufzeitvergleich der evaluierten Verfahren],
) <fig-ergebnisse>

#figure(
  table(
    columns: (1fr, auto, auto, auto),
    align: (left, center, center, center),
    table.header(
      [*Verfahren*], [*Laufzeit (ms)*], [*Genauigkeit (%)*], [*Speicherbedarf (MB)*],
    ),
    [Baseline],              [142], [87.3], [512],
    [Ansatz A],              [105], [88.1], [480],
    [Ansatz B (vorgeschlagen)], [93],  [88.7], [460],
  ),
  caption: [Vergleich der evaluierten Verfahren],
) <tbl-ergebnisse>

= Zusammenfassung und Ausblick

Die vorliegende Arbeit zeigt, dass moderne Methoden der angewandten Informatik effektiv zur Lösung praxisrelevanter Problemstellungen eingesetzt werden können. Der entwickelte Prototyp belegt die Tragfähigkeit des vorgeschlagenen Ansatzes.

Weiterer Forschungsbedarf besteht hinsichtlich der Übertragbarkeit der Ergebnisse auf andere Domänen sowie der Optimierung des Verfahrens für ressourcenbeschränkte Umgebungen. Eine vertiefte Betrachtung dieser Aspekte bleibt künftigen Arbeiten vorbehalten.

#bibliography("references.bib")
