// Shared document-wide constants and package metadata.
// Paths here are relative to lib/, so the package root is one level up.

#import "includes.typ" as inc

// Heading / typography metrics shared across every document type.
#let space-after-heading = 0.8em
#let chapter-font-size = 1.5em
#let chapter-font-weight = 700
#let body-font-size = 11pt

// Background fill used behind inline code and code listings.
#let _luma-background = luma(250)

// ── Title / subtitle length budget ──────────────────────────────────────────
// Maximum number of lines a title (resp. subtitle) may wrap to before the "title
// too long" warning box appears. These are the SINGLE knobs governing overflow
// detection across EVERY document type. The verdict is always measured against
// one reference cover — the bachelor thesis (the narrowest, strictest layout, ~35
// characters per line at its 24pt title) — so the same title is flagged (or not)
// identically on the thesis, report, document, exec-summary, tb-assignment and
// poster (see lib/overflow.typ). A title that fits the thesis fits them all.
// Lower for stricter/shorter titles; raise to tolerate longer ones.
#let max-title-lines = 1     // title: one line on the thesis reference (≈35 chars)
#let max-subtitle-lines = 2  // subtitle: up to two lines
// (the exec-summary blurb uses a measured overflow check, not a length budget;
//  see summary-too-long() in lib/overflow.typ)

// Canonical programme name (note the lowercase "systèmes"), as the default
// `programme:` value so the spelling stays consistent. Two forms: bare, and with
// the "(ISC)" suffix — pick per document type.
#let programme-name = "Informatique et systèmes de communication"
#let programme-name-isc = programme-name + " (ISC)"

// The five ISC majors, each with its localized label. French is canonical; the
// English/German labels follow it. Single source of truth used by every cover so
// the spelling can no longer drift between document types (it used to: thesis said
// "Security", exec "Computer security", the poster "Data Engineering").
#let majors = (
  (fr: "Informatique logicielle",          en: "Software engineering", de: "Software Engineering"),
  (fr: "Systèmes informatiques embarqués", en: "Embedded systems",     de: "Embedded systems"),
  (fr: "Sécurité informatique",            en: "Computer security",    de: "IT-Sicherheit"),
  (fr: "Réseaux et systèmes",              en: "Networks and systems", de: "Netzwerke und Systeme"),
  (fr: "Ingénierie des données",           en: "Data engineering",     de: "Data Engineering"),
)

// Every accepted label across the three languages — for validation + messages.
#let major-labels = majors.map(m => (m.fr, m.en, m.de)).flatten().dedup()

// A "no major given" value: project()/poster() use different empties as default.
#let _major-empty(m) = m == none or m == "" or m == ()

// Assert a user-supplied major is one of the known labels (in any language).
// Empty is allowed. Used as the early guard in project()/isc-poster().
#let validate-major(major) = {
  assert(
    _major-empty(major) or major in major-labels,
    message: "Unknown major " + repr(major) + ". Pick one (any language): " + major-labels.join(", "),
  )
}

// Resolve a user-supplied major (given in any language, or empty) to the label
// for `lang`, so the cover always shows the major in the document's language.
// Reuses validate-major so the valid set can't drift between the two.
#let resolve-major(major, lang) = {
  if _major-empty(major) { return "" }
  validate-major(major)
  let hit = majors.find(m => major in (m.fr, m.en, m.de))
  hit.at(lang, default: hit.en)
}

// Re-exported convenience handles.
#let global-keywords = inc.global-keywords
#let version = toml("../typst.toml").package.version
