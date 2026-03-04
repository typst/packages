// Next-gen Ott integration for Typst.
//
// This file expects a WASM plugin at `typst/plugins/ott.wasm` that exports:
// - `parse_rules(bytes) -> bytes` returning CBOR render items
// - `compile_spec(bytes) -> bytes` returning CBOR `{id, roots, default_root}`
// - `parse_term(id_bytes, root_bytes, term_bytes) -> bytes` returning UTF-8 Typst math code (without `$...$`)

#import "@preview/curryst:0.5.0": rule, prooftree

#let _ott_wasm = plugin("plugins/ott.wasm")

#let _decode(spec) = {
  // Typst 0.14+: `cbor(bytes)` decodes CBOR bytes into Typst values.
  cbor(_ott_wasm.parse_rules(bytes(spec)))
}

#let _rawline(s) = raw(s, block: false)

#let render_grammar(nonterminal, alternatives, comment: none) = {
  let alts = alternatives
  if alts.len() == 0 {
    return block[#_rawline(nonterminal + " ::= ")]
  }

  let cells = (
    _rawline(nonterminal), _rawline("::="), _rawline(alts.at(0)),
    ..alts.slice(1).map(alt => ([], _rawline("|"), _rawline(alt))),
  ).flatten()

  let tbl = table(
    columns: (auto, auto, 1fr),
    align: (left, center, left),
    inset: (x: 0pt, y: 0.1em),
    ..cells,
  )

  if comment == none {
    tbl
  } else {
    block[
      #tbl
      #text(size: 0.85em, fill: gray.darken(20%))[#comment]
    ]
  }
}

#let render_rule(name, premises, conclusion, comment: none) = {
  let prem = premises.map(p => _rawline(p))
  let concl = _rawline(conclusion)

  // Curryst: first positional arg is conclusion, rest are premises.
  prooftree(
    rule(
      name: _rawline(name),
      concl,
      ..prem,
    )
  )
}

#let render(spec) = {
  let doc = _decode(spec)
  let out = ()

  for it in doc.items {
    if it.kind == "section" {
      out += (heading(level: 3)[#it.title],)
    } else if it.kind == "grammar" {
      out += (render_grammar(it.nonterminal, it.alternatives, comment: it.comment),)
    } else if it.kind == "rule" {
      out += (render_rule(it.name, it.premises, it.conclusion, comment: it.comment),)
    } else {
      out += (raw("[ott] unknown render item kind: " + str(it.kind), block: true),)
    }

    out += (v(0.8em),)
  }

  out
}

#let _body_text(body) = {
  if type(body) == str {
    body
  } else if type(body) == content {
    if body.func() == raw {
      body.text
    } else if body.has("text") {
      if type(body.text) == str {
        body.text
      } else {
        _body_text(body.text)
      }
    } else if body.has("children") {
      body.children.map(_body_text).join()
    } else if body.has("body") {
      _body_text(body.body)
    } else {
      ""
    }
  } else {
    repr(body)
  }
}

/// Compile an Ott spec (string) into a term parser function.
///
/// The returned value is a function that can be called as `#ott[term]`.
#let ott-spec(spec, root: auto) = {
  let info = cbor(_ott_wasm.compile_spec(bytes(spec)))
  let id = info.id
  let chosen = if root == auto { info.default_root } else { root }

  body => {
    let term = _body_text(body).trim()
    assert.ne(term, "", message: "ott[...] term is empty")

    let code = str(_ott_wasm.parse_term(bytes(str(id)), bytes(chosen), bytes(term)))
    // Turn Typst math code into real math content.
    eval("$" + code + "$")
  }
}

/// Load an Ott spec and return a term parser function.
///
/// Due to Typst's path resolution rules, you typically call this as:
/// `#let ott = ott-file(read("path/to/spec.ott"), root: "...")`.
#let ott-file(spec, root: auto) = ott-spec(spec, root: root)
