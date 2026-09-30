// ╔══════════════════════════════════════════════════════════════════════════╗
// ║  MAIN.TYP – Hauptdokument der Facharbeit                                ║
// ║                                                                          ║
// ║  Struktur:                                                               ║
// ║  1. Imports                                                              ║
// ║  2. Globale Set-Regeln (Seite, Text, Absatz)                            ║
// ║  3. Typografische Korrekturen (ausgelagert)                             ║
// ║  4. Heading- & Figure-Formatierung                                      ║
// ║  5. Titelblatt                                                          ║
// ║  6. Verzeichnisse                                                       ║
// ║  7. Hauptteil (Kapitel)                                                 ║
// ║  8. Literaturverzeichnis                                                ║
// ║  9. Anhang                                                              ║
// ║  10. Eigenständigkeitserklärung                                         ║
// ╚══════════════════════════════════════════════════════════════════════════╝


// ═══════════════════════════════════════════════════════════════════════════
// 1. IMPORTS (Reihenfolge NICHT ändern!)
// ═══════════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════════════
// 1. IMPORTS
// ═══════════════════════════════════════════════════════════════════════════
// 🛑 BITTE NICHT ÄNDERN 🛑
// Diese Zeilen laden das Layout und die Grundeinstellungen Ihrer Facharbeit.
#import "St_Individualisierungen.typ": *     // Metadaten (HIER TRAGEN SIE IHREN NAMEN EIN!)


#import "_system/template.typ": facharbeit
#import "St_Individualisierungen.typ" as userdata
#import "_system/einstellungen.typ" as einstellungen
#import "_system/ui.typ": bild, einfache-tabelle, hinweisbox, definition, beispiel, merke
#import "_system/utils.typ": a3-seite

#show: facharbeit.with(userdata: userdata, einstellungen: einstellungen)

[] <start-hauptteil>


// =====================================================================
// 1. EINLEITUNG
// =====================================================================
// In der Einleitung wecken Sie das Interesse des Lesers und führen in 
// die Thematik ein. 
// HINWEIS: Formulieren Sie für alle Kapitel eigene, treffende Überschriften!
// =====================================================================

= [Ihre Überschrift für die Einleitung]

[Hier beginnt Ihr Text...]

// --- BEISPIELE FÜR DIE FACHARBEIT ---
// Sie können die folgenden Beispiele einfach löschen oder mit Ihren eigenen Inhalten überschreiben.

Hier ist ein Beispiel für ein Zitat aus dem Literaturverzeichnis: @wittenbrink2019[S. 45]. 
Durch dieses Zitat wird automatisch eine Fußnote erstellt und das Buch taucht im Literaturverzeichnis am Ende der Arbeit auf.

Hier ist ein Beispiel für eine Abbildung. Sie taucht vollautomatisch im Abbildungsverzeichnis auf:
#figure(
  rect(width: 100%, height: 4cm, fill: luma(230))[Platzhalter für Ihr Bild (z.B. ein Screenshot)],
  caption: [Das ist eine Beispielabbildung]
)

Hier ist ein Beispiel für eine Tabelle. Sie landet vollautomatisch im Tabellenverzeichnis:
#figure(
  table(
    columns: 2,
    [*Kategorie*], [*Wert*],
    [Umsatz], [10~000 €],
    [Kosten], [8~000 €]
  ),
  caption: [Das ist eine Beispieltabelle],
  kind: table
)
// ------------------------------------


// =====================================================================
// 2. FIRMENVORSTELLUNG
// =====================================================================
// Firmenvorstellung vor dem Hintergrund des Problems.
// =====================================================================

= [Ihre Überschrift: Firmenvorstellung / Kontext]

[Hier beginnt Ihr Text...]


// =====================================================================
// 3. PROBLEMBESCHREIBUNG
// =====================================================================
// Die eigentlich zu lösende Problembeschreibung (passend zum Titel der 
// Facharbeit); Kennzahlenermittlung, anhand derer der Grad der 
// Problemlösung gemessen werden kann, ...
// =====================================================================

= [Ihre Überschrift: Die Problemstellung]

[Hier beginnt Ihr Text...]


// =====================================================================
// 4. HAUPTTEIL & WIRTSCHAFTLICHE ANALYSE
// =====================================================================
// Was wurde gemacht, um das Problem zu lösen (Vorher-Nachher Messungen, 
// Zeitnahmen, Auswertungen von Tabellen, Datenbanklösung mit MS Access 
// erstellt, Kennzahlenvergleich, ... )
// =====================================================================

= [Ihre Überschrift: Lösungsansatz / Durchführung]

[Hier beginnt Ihr Text...]


// =====================================================================
// 5. WIRTSCHAFTLICHKEIT DER LÖSUNG
// =====================================================================
// Warum ist meine Problemlösung wirtschaftlich sinnvoll? 
// Methodenvielfalt: Break-even-Analyse, Gantt-Diagramm, Nutzwertanalyse 
// mit Spinnwebdiagramm, eEPK, ...
// =====================================================================

= [Ihre Überschrift: Wirtschaftliche Bewertung]

[Hier beginnt Ihr Text...]


// =====================================================================
// 6. FAZIT
// =====================================================================
// Typischerweise die erfolgreiche Einführung der Problemlösung im Betrieb.
// =====================================================================

= [Ihre Überschrift für das Fazit]

[Hier beginnt Ihr Text...]


// =====================================================================
// 7. AUSBLICK
// =====================================================================
// Was man noch in Zukunft verbessern könnte.
// =====================================================================

= [Ihre Überschrift für den Ausblick]

[Hier beginnt Ihr Text...]


// ═══════════════════════════════════════════════════════════════════════════
// 9. LITERATURVERZEICHNIS
// ═══════════════════════════════════════════════════════════════════════════

<ende-hauptteil>
#if einstellungen.duplex-druck { pagebreak(to: "odd") } else { pagebreak() }
#show bibliography: set par(hanging-indent: 1.5em)
#bibliography("St_Facharbeit.bib", title: "Literaturverzeichnis", style: einstellungen.zitierstil, full: einstellungen.literatur-alle-anzeigen)


// ═══════════════════════════════════════════════════════════════════════════
// 10. ANHANG
// ═══════════════════════════════════════════════════════════════════════════

// =====================================================================
// ANHANG
// =====================================================================
// Hier können Sie ergänzende Materialien unterbringen, die den Lesefluss 
// im Hauptteil stören würden, aber für das Verständnis wichtig sind.
// 🟢 HIER DÜRFEN SIE ÄNDERN 🟢
// =====================================================================

#heading(numbering: none, outlined: true)[Anhang]

#heading(level: 2, numbering: none, outlined: true)[Anlage A: Fragebogen-Auswertung (Rohdaten)]
<anlage-auswertung>

#figure(
  caption: [Vollständige Auswertung der Mitarbeiterbefragung 2024],
  kind: table,
  supplement: [Anlage],
  table(
    columns: (1fr, 1fr, 1fr, 1fr),
    [*Abteilung*], [*Teilnehmer*], [*Zufriedenheit*], [*Rücklaufquote*],
    [Einkauf], [12], [85 %], [92 %],
    [Verkauf], [45], [78 %], [88 %],
    [Logistik], [120], [81 %], [95 %],
    [IT], [8], [91 %], [100 %]
  )
)

// ═══════════════════════════════════════════════════════════════════════════
// 11. EIGENSTÄNDIGKEITSERKLÄRUNG
// ═══════════════════════════════════════════════════════════════════════════

#if einstellungen.duplex-druck { pagebreak(to: "odd") } else { pagebreak() }
<start-selbsterklaerung>
#heading(numbering: none, outlined: false)[Eigenständigkeitserklärung]
#v(1em)
Ich erkläre hiermit, dass ich die vorliegende Arbeit selbstständig verfasst und keine anderen als die angegebenen Quellen und Hilfsmittel benutzt habe.

#v(4cm)
Dormagen, #userdata.abgabedatum

#v(2cm)
#line(length: 8cm, stroke: 0.5pt)
#text(size: 10pt)[Unterschrift (#userdata.vorname #userdata.nachname)]



