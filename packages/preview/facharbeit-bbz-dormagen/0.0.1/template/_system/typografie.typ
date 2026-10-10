// =======================================================================
// DATEI: typografie.typ
// ZWECK: Typografie: Definiert Schriftarten, Zeilenabstände, Überschriften-Formatierungen (H1-H6) und Link-Styles.
// =======================================================================

// ╔══════════════════════════════════════════════════════════════════════════╗
// ║  TYPOGRAFIE.TYP                                                         ║
// ║  Typografische Korrekturen und Schutzregeln.                            ║
// ║  Diese Datei NICHT bearbeiten, es sei denn, Sie wissen genau,           ║
// ║  was die Regex-Regeln bewirken.                                         ║
// ╚══════════════════════════════════════════════════════════════════════════╝


// ── Geschützte Leerzeichen bei Ziffern ─────────────────────────────────────
// Verhindert Umbruch zwischen Zahl und folgendem Wort (z. B. "5 kg")
#show regex("\d+\.? "): it => it.text.slice(0, -1) + sym.space.nobreak

// ── Paragraphenzeichen ─────────────────────────────────────────────────────
// "§ 12" bleibt zusammen
#show regex("§ "): it => "§" + sym.space.nobreak

// ── Zahlenbereiche ─────────────────────────────────────────────────────────
// "12-15" → "12–15" (En-Dash) und kein Umbruch
#show regex("\d+[-–]+\d+"): it => {
  let text-parts = it.text.split(regex("[-–]+"))
  box(text-parts.at(0) + sym.dash.en + text-parts.at(1))
}

// ── Feste Begriffe (kein Umbruch innerhalb) ────────────────────────────────
#show "BBZ Dormagen": box
#show "Fachschule für Wirtschaft": box
#show "Schwerpunkt Logistik": box

// ── Ligatur-Korrektur (Morphemgrenzen) ─────────────────────────────────────
// Verhindert falsche Ligaturen an Morphemgrenzen (z. B. "Auf-lage" ≠ "Auflage")
#let prefix = "auf|kauf|prüf|tarif|brief|schlaf|tief|wurf|fünf|dorf|chef|lauf|impf|hof|straf"
#let suffix = "lage|leute|liste|labor|lohn|los|leben|laden|flug|linie|lizenz|leitung|leidenschaft|laufzeit|fassung|forderung|führung|form|frage|fall|feld|falle|instanz|institut|info|inhalt|index|intervall|initiative|information|interesse"
#show regex("(?i)\b(" + prefix + ")(" + suffix + ")\b"): it => {
  let lower-t = it.text.clusters().map(lower).join()
  let matched-prefix = prefix.split("|").find(p => lower-t.starts-with(p))
  if matched-prefix != none {
    it.text.slice(0, matched-prefix.len()) + sym.zwnj + it.text.slice(matched-prefix.len())
  } else {
    it
  }
}

// ── Silbentrennungs-Schutz ─────────────────────────────────────────────────
// Kurze Wörter (1–4 Buchstaben) nicht trennen
#show regex("\b\w{1,4}\b"): it => if optimierte-silbentrennung { box(it) } else { it }

// 5-Buchstaben-Wörter nicht trennen (z. B. "Ge-ben" verhindern)
#show regex("\b\w{5}\b"): it => if kurze-woerter-nicht-trennen { box(it) } else { it }

// Spezifische Korrekturen
#show regex("(?i)ex-?trem"): it => if optimierte-silbentrennung { "extrem" } else { it }
#show regex("(?i)per-?fek-?te(r|n|s)?"): it => if optimierte-silbentrennung { box(it.text.replace("-", "")) } else { it }

// ── Abkürzungen binden ─────────────────────────────────────────────────────
// "z. B.", "d. h.", "i. d. R." als Ganzes schützen
#show regex("\b(?:[a-zA-Z]{1,4}\.\s?)+[a-zA-Z]{1,4}\."): it => {
  let parts = it.text.split(".")
  let clean-parts = parts.map(p => p.trim()).filter(p => p != "")
  box(clean-parts.join([.#h(0.12em)]) + ".")
}