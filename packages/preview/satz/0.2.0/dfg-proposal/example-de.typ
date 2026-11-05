// DFG 53.01 — 09/26. Replace every placeholder before submission.
// Keep the prescribed headings; consult the official form for instructions.
#import "../lib.typ": dfg-proposal, dfg-supplement, dfg-publications, proposal-budget

#show: dfg-proposal.with(
  applicant: [Example Applicant, Example University, Example City],
  project: [Example Research Project],
  language: "german",
)

= Ausgangslage

[Text]

*Stand der Forschung und eigene Vorarbeiten*

[Text]

= Ziele und Arbeitsprogramm

[Text]

== Voraussichtliche Gesamtdauer des Projekts

[Text]

== Ziele

[Text]

== Arbeitsprogramm inkl. vorgesehener Untersuchungsmethoden

[Text]

== Umgang mit Forschungsdaten

[Text]

== Relevanz von Geschlecht und/oder Diversität im Forschungsvorhaben

[Text]

= Projekt- und themenbezogenes Literaturverzeichnis

// Cite publications in sections 1–2, then uncomment:
// #dfg-publications("lit.bib", size: 9pt)
[Literature / Literatur]

#dfg-supplement()

= Begleitinformationen zum Forschungskontext

[Text]

== Angaben zu ethischen und/oder rechtlichen Aspekten des Vorhabens

[Text]

=== Allgemeine ethische Aspekte und Verpflichtungen

[Text]

=== Erläuterungen zu den vorgesehenen Untersuchungen bei Versuchen an Tieren

[Text]

=== Erläuterungen zu Forschungsvorhaben an genetischen Ressourcen (oder darauf bezogenem traditionellem Wissen) aus dem Ausland

[Text]

=== Erläuterungen zu möglichen sicherheitsrelevanten Aspekten

[Text]

==== „Dual-Use Research of Concern“; Außenwirtschaftsrecht

[Text]

==== Risiken in internationalen Kooperationen

[Text]

=== Reflexion zu ökologischen Nachhaltigkeitsaspekten in der Planung und Durchführung des Vorhabens

[Text]

== Angaben zur Dienststellung

[Text]

== Angaben zur Erstantragstellung

[Text]

== Zusammensetzung der Projektarbeitsgruppe

[Text]

== Zusammenarbeit mit Wissenschaftler\*innen in Deutschland in diesem Projekt

[Text]

== Zusammenarbeit mit Wissenschaftler\*innen im Ausland in diesem Projekt

[Text]

== Wissenschaftler\*innen, mit denen in den letzten drei Jahren wissenschaftlich zusammengearbeitet wurde

[Text]

== Projektrelevante Zusammenarbeit mit erwerbswirtschaftlichen Unternehmen

[Text]

== Projektrelevante Beteiligungen an erwerbswirtschaftlichen Unternehmen

[Text]

== Apparative Ausstattung

[Text]

== Weitere Antragstellungen

[Text]

== Weitere Angaben

[Text]

= Beantragte Module/Mittel

[Text]

== Basismodul

[Text]

=== Personalmittel

#proposal-budget((
  (description: [Research associate, 12 months], unit-cost: 500000, quantity: 12),
  (description: [Student assistant, 6 months], unit-cost: 45000, quantity: 6),
), language: "german")

=== Sachmittel

[Text]

==== Geräte bis 10.000 Euro, Software und Verbrauchsmaterial

[Text]

==== Reisemittel

[Text]

==== Mittel für wissenschaftliche Gäste (ausgenommen Mercator-Fellow)

[Text]

==== Mittel für Versuchstiere

[Text]

==== Sonstige Mittel

[Text]

==== Publikationsmittel

[Text]

=== Investitionsmittel

[Text]

==== Geräte über 10.000 Euro

[Text]

==== Großgeräte über 50.000 Euro

[Text]

== Modul Eigene Stelle

[Text]

== Modul Vertretung

[Text]

== Modul Rotationsstellen

[Text]

== Modul Mercator Fellow

[Text]

== Modul Projektspezifische Workshops

[Text]

== Modul Wissenschaftskommunikation

[Text]

== Modul Pauschale für Chancengleichheitsmaßnahmen

[Text]
