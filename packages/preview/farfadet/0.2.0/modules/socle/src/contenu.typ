// contenu.typ (farfadet-socle) — outils sur les contenus : vide ? texte brut ?
// Lus par farfadet-didactique et farfadet-modele
// (`bf-vide` ne force plus modele à importer didactique).

#let _sequence = [a *b*].func()
#let _espace = [ ].func()

/// Contenu vide (none, [], espaces) ?
#let bf-vide(c) = {
  if c == none or c == auto { return true }
  if type(c) == str { return c.trim() == "" }
  if type(c) != content { return false }
  if c.func() == _espace { return true }
  if c.func() == _sequence { return c.children.all(bf-vide) }
  c == []
}

/// Texte brut approximatif d'un contenu, paragraphes séparés par « ¶ » ; formules résumées
/// par « ( » si elles descendent sous la ligne de base (parenthèses, fractions, indices), « x » sinon.
#let bf-brut(c) = {
  if c == none { return "" }
  if type(c) == str { return c }
  if type(c) != content { return "" }
  let f = c.func()
  if f == math.equation {
    let r = repr(c.body)
    return if r.contains("[(]") or r.contains("[[]") or r.contains("frac(") or r.contains("b: ") or r.contains("root(") { "(" } else { "x" }
  }
  if f == parbreak or f == list.item or f == enum.item { return "¶" + if c.has("body") { bf-brut(c.body) } else { "" } }
  if c.has("text") { return c.text }
  if c.has("children") { return c.children.map(bf-brut).join("") }
  if c.has("body") { return bf-brut(c.body) }
  if c.has("child") { return bf-brut(c.child) }
  if f == _espace { return " " }
  ""
}
