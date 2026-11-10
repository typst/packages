// ============================================================================
// biblio.typ — motor próprio de citações + bibliografia ABNT (abntex2-alf)
//
// Substitui bibliography()+CSL do Typst para obter o que o motor nativo não
// permite: backref ("Citado na(s) página(s): …"), caixa correta na forma
// narrativa (\citeonline) e sufixo de desambiguação a/b/c compartilhado entre
// as formas parentética e narrativa. A SAÍDA replica o abntex2-alf 1:1.
// ============================================================================

#let _CM = <ppgsi-cite-mark>
#let _blue = rgb(41, 5, 195) // \definecolor{blue}{RGB}{41,5,195} do modelo

// ---------------------------------------------------------------------------
// PARSER BibTeX (subconjunto: @tipo{chave, campo = {valor} | "valor" | token})
// ---------------------------------------------------------------------------

#let _strip-comments(s) = s.split("\n").filter(l => not l.trim().starts-with("%")).join("\n")

#let _is-ws(c) = c == " " or c == "\t" or c == "\n" or c == "\r"

#let _skip-ws(cp, i) = {
  while i < cp.len() and _is-ws(cp.at(i)) { i += 1 }
  i
}

#let _read-braced(cp, i) = {
  // pré: cp.at(i) == "{". Devolve (interior, índice-após-"}").
  let depth = 1
  let out = ""
  i += 1
  while i < cp.len() and depth > 0 {
    let c = cp.at(i)
    if c == "{" { depth += 1; out += c }
    else if c == "}" { depth -= 1; if depth > 0 { out += c } }
    else { out += c }
    i += 1
  }
  (out, i)
}

#let _read-quoted(cp, i) = {
  // pré: cp.at(i) == "\"". Devolve (interior, índice-após-"\"").
  let out = ""
  let depth = 0
  i += 1
  while i < cp.len() {
    let c = cp.at(i)
    if c == "\"" and depth == 0 { i += 1; break }
    if c == "{" { depth += 1 }
    if c == "}" { depth -= 1 }
    out += c
    i += 1
  }
  (out, i)
}

#let _read-bare(cp, i) = {
  let out = ""
  while i < cp.len() and not (cp.at(i) in (",", "}")) { out += cp.at(i); i += 1 }
  (out.trim(), i)
}

#let _read-value(cp, i) = {
  i = _skip-ws(cp, i)
  let c = cp.at(i, default: "")
  if c == "{" { _read-braced(cp, i) }
  else if c == "\"" { _read-quoted(cp, i) }
  else { _read-bare(cp, i) }
}

#let _read-token(cp, i, stops) = {
  let out = ""
  while i < cp.len() and not (cp.at(i) in stops) { out += cp.at(i); i += 1 }
  (out, i)
}

#let _parse-bib(content) = {
  let cp = _strip-comments(content).clusters()
  let n = cp.len()
  let i = 0
  let entries = (:)
  while i < n {
    // próximo "@"
    while i < n and cp.at(i) != "@" { i += 1 }
    if i >= n { break }
    i += 1 // pula "@"
    let parts = _read-token(cp, i, ("{", "(")) // tipo
    let etype = lower(parts.at(0).trim())
    i = parts.at(1)
    if i >= n { break }
    i += 1 // pula "{"
    i = _skip-ws(cp, i)
    let kp = _read-token(cp, i, (",", "}")) // chave
    let key = kp.at(0).trim()
    i = kp.at(1)
    if cp.at(i, default: "") == "," { i += 1 }
    let fields = (:)
    while i < n {
      i = _skip-ws(cp, i)
      if cp.at(i, default: "") == "}" { i += 1; break }
      let np = _read-token(cp, i, ("=", ",", "}")) // nome do campo
      let name = lower(np.at(0).trim())
      i = np.at(1)
      if cp.at(i, default: "") != "=" {
        // entrada malformada / sem "=" — aborta este campo
        if cp.at(i, default: "") == "," { i += 1 }
        continue
      }
      i += 1 // pula "="
      let vp = _read-value(cp, i)
      i = vp.at(1)
      if name != "" { fields.insert(name, vp.at(0).trim()) }
      i = _skip-ws(cp, i)
      if cp.at(i, default: "") == "," { i += 1 }
    }
    if key != "" { entries.insert(key, (type: etype, fields: fields)) }
  }
  entries
}

// ---------------------------------------------------------------------------
// AUTORES
// ---------------------------------------------------------------------------

#let _split-authors(field) = field.split(regex("\s+and\s+")).map(s => s.trim()).filter(s => s != "")

#let _name-parts(raw) = {
  // devolve (family, given)
  let nm = raw.trim()
  if "," in nm {
    let p = nm.split(",")
    (p.at(0).trim(), p.slice(1).join(",").trim())
  } else {
    let toks = nm.split(regex("\s+")).filter(t => t != "")
    if toks.len() == 0 { ("", "") }
    else if toks.len() == 1 { (toks.at(0), "") }
    else { (toks.last(), toks.slice(0, toks.len() - 1).join(" ")) }
  }
}

#let _initials(given) = given.split(regex("\s+")).filter(t => t != "").map(t => upper(t.clusters().at(0, default: "")) + ".").join(" ")

// "SOBRENOME, I. N." (lista da bibliografia)
#let _format-name(raw) = {
  let np = _name-parts(raw)
  let fam = upper(np.at(0))
  let ini = _initials(np.at(1))
  if ini == "" { fam } else { fam + ", " + ini }
}

#let _authors-bib(field) = _split-authors(field).map(_format-name).join("; ")

#let _families(field) = _split-authors(field).map(raw => _name-parts(raw).at(0))

#let _titlecase(s) = {
  let t = lower(s)
  if t.len() == 0 { t } else { upper(t.clusters().at(0)) + t.clusters().slice(1).join() }
}

// Autor de citação: >3 autores → "Primeiro et al." (et al. itálico).
// caixa = "upper" (parentético) | "title" (narrativo).
#let _cite-authors(field, caixa: "upper", narrativo: false) = {
  let fams = _families(field)
  let aplica = if caixa == "upper" { f => upper(f) } else { f => _titlecase(f) }
  if fams.len() == 0 {
    []
  } else if fams.len() > 3 {
    [#aplica(fams.at(0)) #emph[et al.]]
  } else if narrativo {
    // narrativo: "A", "A e B", "A, B e C"
    if fams.len() == 1 { aplica(fams.at(0)) }
    else {
      let ini = fams.slice(0, fams.len() - 1).map(aplica).join(", ")
      [#ini e #aplica(fams.last())]
    }
  } else {
    // parentético: "A; B; C"
    fams.map(aplica).join("; ")
  }
}

// ---------------------------------------------------------------------------
// DESAMBIGUAÇÃO (sufixo a/b/c por ordem de PRIMEIRA citação)
// ---------------------------------------------------------------------------

#let _year(entry) = entry.fields.at("year", default: "")

#let _ay-key(entry) = {
  let fams = _families(entry.fields.at("author", default: ""))
  lower(fams.at(0, default: "")) + "|" + _year(entry)
}

#let _cite-order(markers) = {
  let order = ()
  for m in markers { if m.value not in order { order.push(m.value) } }
  order
}

#let _suffixes(order, entries) = {
  let groups = (:)
  for k in order {
    if k in entries {
      let ay = _ay-key(entries.at(k))
      groups.insert(ay, groups.at(ay, default: ()) + (k,))
    }
  }
  let smap = (:)
  for (ay, ks) in groups {
    if ks.len() > 1 {
      for (idx, k) in ks.enumerate() { smap.insert(k, numbering("a", idx + 1)) }
    }
  }
  smap
}

// ---------------------------------------------------------------------------
// ESTADO + MARCADORES
// ---------------------------------------------------------------------------

#let _bibsrc = state("ppgsi-bibsrc", "")
#let register-bib(content) = _bibsrc.update(content)
#let _entries() = _parse-bib(_bibsrc.get())
#let _mark(k) = [#metadata(k)<ppgsi-cite-mark>]

// ---------------------------------------------------------------------------
// CITAÇÕES PÚBLICAS
// ---------------------------------------------------------------------------

// Parentética, fim de frase: "(AMENTA et al., 2002b; AMENTA et al., 2002c)"
#let cite(..keys) = {
  let ks = keys.pos()
  ks.map(_mark).join()
  context {
    let entries = _entries()
    let smap = _suffixes(_cite-order(query(_CM)), entries)
    let parts = ks.map(k => {
      let e = entries.at(k)
      text(fill: _blue)[#_cite-authors(e.fields.author, caixa: "upper"), #(_year(e) + smap.at(k, default: ""))]
    })
    [(#parts.join[; ])]
  }
}

// Narrativa, meio de frase: "Amenta et al. (2002a)"
#let prose(key) = {
  _mark(key)
  context {
    let entries = _entries()
    let smap = _suffixes(_cite-order(query(_CM)), entries)
    let e = entries.at(key)
    text(fill: _blue)[#_cite-authors(e.fields.author, caixa: "title", narrativo: true) (#(_year(e) + smap.at(key, default: "")))]
  }
}

// ---------------------------------------------------------------------------
// FORMATAÇÃO DE ENTRADAS (por tipo, conforme abntex2-alf.bst)
// ---------------------------------------------------------------------------

#let _g(f, name) = f.at(name, default: "")
#let _endash(s) = s.replace("-", "–")
#let _sentence(s) = _titlecase(s)

// add.period$: só acrescenta "." se ainda não terminar em pontuação de sentença.
#let _dot(s) = if s == "" or s.ends-with(".") or s.ends-with("?") or s.ends-with("!") { s } else { s + "." }

// "Local: Editora" com fallbacks ABNT.
#let _pub-addr(f) = {
  let addr = _g(f, "address")
  let pub = _g(f, "publisher")
  let l = if addr != "" { addr } else { "[S.l.]" }
  let e = if pub != "" { pub } else { "[s.n.]" }
  if addr == "" and pub == "" { "[S.l.: s.n.]" } else { l + ": " + e }
}

#let _edition(f) = {
  let ed = _g(f, "edition")
  if ed == "" { none }
  else if ed.match(regex("^[0-9]")) != none { ed + ". ed." } else { ed }
}

#let _vnp(f) = {
  // ", v. X, n. Y, p. A–B" (só os presentes)
  let out = []
  if _g(f, "volume") != "" { out += [, v. #_g(f, "volume")] }
  if _g(f, "number") != "" { out += [, n. #_g(f, "number")] }
  if _g(f, "pages") != "" { out += [, p. #_endash(_g(f, "pages"))] }
  out
}

#let _thesis-type(f, etype) = {
  let custom = _g(f, "type")
  if custom != "" { custom }
  else if etype == "phdthesis" { "Tese (Doutorado)" }
  else { "Dissertação (Mestrado)" }
}

#let _emdash = " \u{2014} "

#let _render-entry(entry) = {
  let f = entry.fields
  let t = entry.type
  let aut = _authors-bib(_g(f, "author"))
  let yr = _year(entry)

  if t == "article" {
    let out = [#_dot(aut) #_sentence(_g(f, "title")). #emph(_g(f, "journal"))]
    if _g(f, "publisher") != "" { out += [, #_g(f, "publisher")] }
    if _g(f, "address") != "" { out += [, #_g(f, "address")] }
    out += _vnp(f)
    if yr != "" { out += [, #yr] }
    out += [.]
    out

  } else if t == "book" or t == "manual" or t == "techreport" or t == "booklet" {
    let out = [#_dot(aut) #emph(_g(f, "title"))]
    let ed = _edition(f)
    if ed != none { out += [. #ed] }
    if t == "book" {
      out += [. #_pub-addr(f)]
      if yr != "" { out += [, #yr] }
    } else {
      let addr = _g(f, "address")
      out += [. #(if addr != "" { addr } else { "[S.l.]" })]
      if yr != "" { out += [, #yr] }
    }
    if _g(f, "pages") != "" { out += [. #_g(f, "pages") p.] }
    out += [.]
    out

  } else if t == "inbook" or t == "incollection" {
    let out = [#_dot(aut) #_sentence(_g(f, "title")). In: ]
    if t == "inbook" { out += [#"______". ] }
    else if _g(f, "editor") != "" { out += [#_authors-bib(_g(f, "editor")) (Ed.). ] }
    out += [#emph(_g(f, "booktitle"))]
    let ed = _edition(f)
    if ed != none { out += [. #ed] }
    out += [. #_pub-addr(f)]
    if yr != "" { out += [, #yr] }
    if _g(f, "chapter") != "" { out += [. cap. #_g(f, "chapter")] }
    if _g(f, "pages") != "" { out += [, p. #_endash(_g(f, "pages"))] }
    out += [.]
    out

  } else if t == "inproceedings" or t == "conference" {
    let out = [#_dot(aut) #_sentence(_g(f, "title")). In: ]
    if _g(f, "organization") != "" { out += [#upper(_g(f, "organization")). ] }
    else if _g(f, "editor") != "" { out += [#_authors-bib(_g(f, "editor")) (Ed.). ] }
    out += [#emph(_g(f, "booktitle")). #_pub-addr(f)]
    if yr != "" { out += [, #yr] }
    if _g(f, "pages") != "" { out += [. p. #_endash(_g(f, "pages"))] }
    out += [.]
    out

  } else if t == "phdthesis" or t == "mastersthesis" {
    let out = [#_dot(aut) #emph(_g(f, "title")).]
    if _g(f, "pages") != "" { out += [ #_g(f, "pages") f.] }
    out += [ #_thesis-type(f, t)#_emdash#_g(f, "school")]
    if _g(f, "address") != "" { out += [, #_g(f, "address")] }
    if yr != "" { out += [, #yr] }
    out += [.]
    out

  } else if t == "proceedings" {
    let head = if _g(f, "editor") != "" { [#_authors-bib(_g(f, "editor")) (Ed.)] } else { upper(_g(f, "organization")) }
    let out = [#head. #emph(_g(f, "title")). #_pub-addr(f)]
    if yr != "" { out += [, #yr] }
    if _g(f, "pages") != "" { out += [. #_g(f, "pages") p.] }
    out += [.]
    out

  } else {
    // misc / default
    let out = [#_dot(aut) #emph(_g(f, "title"))]
    if _g(f, "howpublished") != "" { out += [. #_g(f, "howpublished")] }
    if yr != "" { out += [, #yr] }
    out += [.]
    if _g(f, "url") != "" { out += [ Disponível em: <#_g(f, "url")>.] }
    out
  }
}

// ---------------------------------------------------------------------------
// BACKREF
// ---------------------------------------------------------------------------

#let _backref(markers, key) = {
  // páginas distintas (valor exibido do contador) + local da 1ª ocorrência (p/ link)
  let seen = (:)
  for m in markers.filter(m => m.value == key) {
    let p = counter(page).at(m.location()).first()
    if str(p) not in seen { seen.insert(str(p), m.location()) }
  }
  let pages = seen.pairs().map(((k, v)) => (p: int(k), loc: v)).sorted(key: x => x.p)
  let n = pages.len()
  let plink(x) = link(x.loc, text(fill: _blue, str(x.p)))
  if n == 0 { [Nenhuma citação no texto.] }
  else if n == 1 { [Citado na página #plink(pages.at(0)).] }
  else {
    let ini = pages.slice(0, n - 1).map(plink).join(", ")
    [Citado #n vezes nas páginas #ini e #plink(pages.last()).]
  }
}

// ---------------------------------------------------------------------------
// LISTA DE REFERÊNCIAS
// ---------------------------------------------------------------------------

#let _padnum(n) = {
  let s = str(n)
  ("0" * (6 - s.len())) + s
}

#let references() = {
  heading(level: 1, numbering: none, supplement: none)[Referências]
  context {
    let entries = _entries()
    let markers = query(_CM)
    let order = _cite-order(markers)
    let idx = (:)
    for (n, k) in order.enumerate() { idx.insert(k, n) }
    let cited = order.filter(k => k in entries)
    let sorted = cited.sorted(key: k => {
      let e = entries.at(k)
      let sa = upper(_authors-bib(_g(e.fields, "author")))
      sa + "\u{1}" + _year(e) + "\u{1}" + lower(_g(e.fields, "title")) + "\u{1}" + _padnum(idx.at(k))
    })
    set par(leading: 0.65em, spacing: 1.3em, first-line-indent: 0pt, justify: true)
    for k in sorted {
      block(_render-entry(entries.at(k)) + " " + _backref(markers, k))
    }
  }
}
