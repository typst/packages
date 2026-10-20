// Shared primitives: letters, colors, document states, plain-text extraction.

#let LETTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".clusters()
#let key-color = rgb("#0a7d33")

// Document-wide mode ("exam" | "key"), set by exam-doc; read by inline blanks.
#let mode-state = state("quizforge-mode", "key")
// Armed per fill-in-the-blank question in bank/constructor mode.
#let q-state = state("quizforge-question", none)
#let blank-counter = counter("quizforge-blank")

// Element kinds that carry no prose — skipped during text extraction so that
// markers, state updates, and context nodes never leak into hashes or CSVs.
#let _INVISIBLE = ("metadata", "context", "update", "counter-update", "state-update")

// Best-effort plain-text extraction from content, for CSV fields, document
// titles, and stable question-id hashes.
#let plaintext(v) = {
  if v == none { return "" }
  if type(v) == str { return v }
  if type(v) != content { return str(v) }
  if v.has("text") {
    // usually a string, but e.g. math `op` elements store CONTENT here
    let t = v.text
    return if type(t) == str { t } else { plaintext(t) }
  }
  if v.has("children") {
    let parts = v.children.map(plaintext).join()
    return if parts == none { "" } else { parts }
  }
  let f = repr(v.func())
  if f in _INVISIBLE { return "" }
  if f == "smartquote" {
    return if v.at("double", default: true) { "\"" } else { "'" }
  }
  if v.has("body") { return plaintext(v.body) }
  if f in ("space", "linebreak", "parbreak") { return " " }
  repr(v)
}
