// =======================================================================
// DATEI: defaults.typ
// ZWECK: Standardwerte (Defaults): Enthält Fallback-Werte für alle Benutzervariablen, falls diese in der Konfiguration gelöscht wurden.
// =======================================================================

// ╔══════════════════════════════════════════════════════════════════════════╗
// ║                                                                          ║
// ║   St_Individualisierungen.typ                                            ║
// ║   Zentrale Datei für ALLE persönlichen und gestalterischen Einstellungen ║
// ║                                                                          ║
// ║   ANLEITUNG:                                                             ║
// ║   • Text in Anführungszeichen ("...") → einfach umschreiben              ║
// ║   • true = EIN, false = AUS                                              ║
// ║   • // am Zeilenanfang = Zeile ist deaktiviert                           ║
// ║   • // entfernen = Zeile wird aktiviert                                  ║
// ║   • Zahlenwerte (z. B. 14cm) → frei anpassbar                           ║
// ║   • Pro Auswahlgruppe immer NUR EINE Zeile ohne // lassen!               ║
// ║                                                                          ║
// ╚══════════════════════════════════════════════════════════════════════════╝


// ═══════════════════════════════════════════════════════════════════════════
// TEIL A: ZWINGEND AUSZUFÜLLENDE DATEN
//         (Prüfen und ändern Sie hier Ihre persönlichen Daten)
// ═══════════════════════════════════════════════════════════════════════════

// ── A.1 Institution & Rahmen ───────────────────────────────────────────────
#let schulname = "Berufsbildungszentrum Dormagen"
#let bildungsgang = "Fachschule für Wirtschaft, Schwerpunkt Logistik"
#let fach = "Logistische Geschäftsprozesse"

// ── A.2 Prüfung & Korrektur ────────────────────────────────────────────────
// Anrede: "Herr" oder "Frau" (Berufsbezeichnung passt sich automatisch an)
#let pruefer-anrede = "Herr"
#let pruefer-name = "U. Wennmann"
#let fachlehrer-anrede = ""      // Optional (z.B. "Frau")
#let fachlehrer-name = ""        // Optional (z.B. "M. Muster")

// Zweitkorrektur: true = wird angezeigt, false = wird ausgeblendet
#let mit-zweitkorrektur = true
#let zweitkorrektor-anrede = "Frau"
#let zweitkorrektor-name = "S. Becker"

// ── A.3 Angaben zur Arbeit ─────────────────────────────────────────────────
#let art-der-arbeit = "Facharbeit"
#let titel = "Anfertigen einer wissenschaftlichen Facharbeit mit dem webbasierten Satzsystem Typst"
#let untertitel = ""
#let abgabeort = "Dormagen"
#let abgabedatum = "01. April 2026"
#let mit-sperrvermerk = false

// ── A.4 Persönliche Daten ──────────────────────────────────────────────────
#let student-anrede = "Herr"          // "Herr" oder "Frau"
#let vorname = "Max"
#let nachname = "Mustermann"
#let schuelernummer = ""
#let klasse = "FW25A"

// ── A.5 Betrieb (optional – leer lassen, wenn nicht benötigt) ──────────────
#let ausbildungsbetrieb = "DormLog oHG, Dormagen"


// ═══════════════════════════════════════════════════════════════════════════
// TEIL B: DOKUMENTEN-STEUERUNG & BARRIEREFREIHEIT
// ═══════════════════════════════════════════════════════════════════════════

// Übersicht für Studierende drucken (vergleicht Originalwerte mit Anpassungen)
#let uebersichtsseite-drucken = true
#let uebersicht-wasserzeichen = true

// Große Schrift für sehbehinderte Leser
//   false = normale Größe (10–10,5 pt)
//   true  = alles mindestens 12 pt (empfohlen bei Sehschwäche)
#let large-print = false

// Sollen die römischen Seitenzahlen in den Verzeichnissen in Klammern stehen? z. B. (i) statt i
//   true  = (i), (ii), (iii)...
//   false = i, ii, iii...
#let klammern-um-roemische-seiten = false

// Muster in Diagrammen für S/W-Drucker (Schraffuren statt Farben)
//   true  = Muster an (empfohlen für Kyocera S/W-Drucker)
//   false = Muster aus (für Farblaser-Kopierer)
#let sw-patterns = false

// Symbole bei Ampelfarben: ✓ (grün), ○ (gelb), ✗ (rot)
//   true  = Symbole werden angezeigt (hilft bei S/W und Farbenblindheit)
//   false = nur Farbe, keine Symbole
#let ampel-symbole = true


// ═══════════════════════════════════════════════════════════════════════════
// TEIL C: FARBEN
//         Alle Farben im OKLCH-Modell.
// ═══════════════════════════════════════════════════════════════════════════

// ── C.1 Hauptfarbe ─────────────────────────────────────────────────────────
#let main-color = oklch(28%, 0.055, 258deg)
#let primärfarbe = main-color
#let box-rand-breite = 2pt
#let box-rand-farbe = main-color.lighten(30%)
#let caption-size = 0.9em
#let quellen-size = 0.85em

// ── C.2 Kategoriefarben (für Diagramme mit mehreren Datenreihen) ───────────
#let accent-1 = oklch(36%, 0.055, 258deg)     // Dunkelblau
#let accent-2 = oklch(48%, 0.055, 258deg)     // Mittelblau
#let accent-3 = oklch(60%, 0.055, 258deg)     // Hellblau
#let accent-4 = oklch(72%, 0.045, 258deg)     // Sehr helles Blau
#let accent-5 = oklch(84%, 0.035, 258deg)     // Fast weißes Blau
#let accent-6 = oklch(96%, 0.025, 258deg)     // Hintergrund-Ton

// ── C.3 Tabellen-Farben ────────────────────────────────────────────────────
#let header-bg = oklch(90%, 0.03, 255deg)      // Hintergrund der Kopfzeile
#let zebra-bg = oklch(98%, 0.01, 255deg)     // Hintergrund jede 2. Zeile

// ── C.4 Diagramm-Farben ────────────────────────────────────────────────────
#let data-label-bg = oklch(99%, 0.002, 250deg)    // Hintergrund hinter Zahlen

// ── C.5 Ampelfarben (Nutzwertanalyse, KPI-Bewertung) ───────────────────────
#let color-1st = oklch(72%, 0.15, 145deg)     // Platz 1 / positiv  → Grün
#let color-2nd = oklch(95%, 0.15, 95deg)      // Platz 2 / neutral  → Gelb (ARIS-Gelb)
#let color-3rd = oklch(65%, 0.18, 25deg)      // Platz 3 / negativ  → Rot

// ── C.6 Spezifische Farben (z.B. eEPK Diagramme) ───────────────────────────
#let eepk-ev-fill   = oklch(85%, 0.06, 20deg)    // Ereignis Füllung (rosa)
#let eepk-ev-stroke = oklch(70%, 0.12, 20deg)    // Ereignis Rand
#let eepk-fn-fill   = oklch(90%, 0.13, 145deg)   // Funktion Füllung (grün)
#let eepk-fn-stroke = oklch(72%, 0.16, 145deg)   // Funktion Rand
#let eepk-org-fill  = oklch(95%, 0.15, 95deg)    // Organisationseinheit (kräftiges gelb)
#let eepk-org-stroke= oklch(80%, 0.15, 95deg)    // Organisationseinheit Rand
#let eepk-sys-fill  = oklch(91%, 0.04, 250deg)   // Anwendungssystem (blau)
#let eepk-sys-stroke= oklch(76%, 0.09, 250deg)   // Anwendungssystem Rand
#let eepk-xor-fill  = oklch(100%, 0, 0deg)       // Operatoren Füllung (XOR, AND, OR)
#let eepk-xor-stroke= main-color                 // Operatoren Rand
#let eepk-edge      = oklch(20%, 0.01, 250deg)   // Kanten / Pfeile


// ═══════════════════════════════════════════════════════════════════════════
// TEIL D: DOKUMENTEIGENSCHAFTEN (PDF METADATEN)
//         Entspricht den 5 Tabs in Adobe Acrobat Reader
// ═══════════════════════════════════════════════════════════════════════════

// ── Tab 1: Beschreibung (Description) ──────────────────────────────────────
#import "version.typ": template-version
#let pdf-titel = titel               // Verknüpft automatisch mit "titel" aus Teil A
#let pdf-autor = vorname + " " + nachname
#let pdf-thema = fach
#let pdf-stichwoerter = ("Facharbeit", "BBZ Dormagen", "Fachschule für Wirtschaft, Schwerpunkt Logistik")
#let pdf-erstellt-mit = "Typst"
#let pdf-vorlagen-version = template-version
#let pdf-sprache = "de-DE"
#let pdf-status = "Entwurf"

// ── Tab 2: Sicherheit (Security) ───────────────────────────────────────────
// Typst unterstützt aktuell nativ keine PDF-Verschlüsselung oder Einschränkungen.
// Dieses Feld dient konzeptionell als Platzhalter.
#let pdf-security = "Keine Einschränkungen"

// ── Tab 3: Schriften (Fonts) ───────────────────────────────────────────────
// In Typst werden alle verwendeten Schriften automatisch ins PDF eingebettet.
#let embed-fonts = true

// ── Tab 4: Ansicht beim Öffnen (Initial View) ──────────────────────────────
// Konzeptionelles Feld. Derzeit steuert der PDF-Reader die Standardansicht.
#let pdf-initial-view = "Fit Width" // z.B. "Fit Page", "Fit Width"

// ── Tab 5: Benutzerdefiniert (Custom) ──────────────────────────────────────
// Konzeptionelle Felder für zusätzliche Metadaten, die in zukünftigen
// Typst-Versionen als benutzerdefinierte XMP-Daten übergeben werden könnten.
#let pdf-bildungsgang = bildungsgang
#let pdf-matrikelnummer = schuelernummer
