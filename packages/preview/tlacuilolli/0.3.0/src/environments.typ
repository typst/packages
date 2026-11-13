#let environment-names = (
  theorem: ("Theorem", "Teorema"),
  definition: ("Definition", "Definición"),
  lemma: ("Lemma", "Lema"),
  proposition: ("Proposition", "Proposición"),
  corollary: ("Corollary", "Corolario"),
  axiom: ("Axiom", "Axioma"),
  proof: ("Proof", "Demostración"),
  example: ("Example", "Ejemplo"),
  remark: ("Remark", "Observación"),
)

#let environment-name(kind, lang) = {
  let names = environment-names.at(kind)
  if lang == "es" { names.at(1) } else { names.at(0) }
}

#let environment-block(name, title, body) = {
  let heading = if title == none { name } else { [#name (#title)] }
  block(width: 100%, above: 0.92em, below: 0.92em, breakable: true, align(start)[
    #strong([#heading.]) #body
  ])
}

#let statement(kind, title, lang, numbered, ref-label, body) = context {
  let name = environment-name(kind, if lang == auto { text.lang } else { lang })
  if numbered {
    let figure-kind = "tlacuilolli-" + kind
    let statement-selector = figure.where(kind: figure-kind)
    show statement-selector: it => {
      let value = counter(statement-selector).at(it.location())
      let heading = [#it.supplement~#numbering(it.numbering, ..value)]
      environment-block(heading, title, it.body)
    }
    [#figure(kind: figure-kind, supplement: name, numbering: "1", outlined: false, body)#ref-label]
  } else {
    assert(ref-label == none, message: "only numbered statements support references")
    environment-block(name, title, body)
  }
}

/// Set a theorem with an independent, document-wide sequence.
#let theorem(title: none, lang: auto, numbered: true, ref-label: none, body) = statement("theorem", title, lang, numbered, ref-label, body)
/// Set a definition with an independent, document-wide sequence.
#let definition(title: none, lang: auto, numbered: true, ref-label: none, body) = statement("definition", title, lang, numbered, ref-label, body)
/// Set a lemma with an independent, document-wide sequence.
#let lemma(title: none, lang: auto, numbered: true, ref-label: none, body) = statement("lemma", title, lang, numbered, ref-label, body)
/// Set a proposition with an independent, document-wide sequence.
#let proposition(title: none, lang: auto, numbered: true, ref-label: none, body) = statement("proposition", title, lang, numbered, ref-label, body)
/// Set a corollary with an independent, document-wide sequence.
#let corollary(title: none, lang: auto, numbered: true, ref-label: none, body) = statement("corollary", title, lang, numbered, ref-label, body)
/// Set an axiom with an independent, document-wide sequence.
#let axiom(title: none, lang: auto, numbered: true, ref-label: none, body) = statement("axiom", title, lang, numbered, ref-label, body)
/// Set an example with an independent, document-wide sequence.
#let example(title: none, lang: auto, numbered: true, ref-label: none, body) = statement("example", title, lang, numbered, ref-label, body)
/// Set a remark with an independent, document-wide sequence.
#let remark(title: none, lang: auto, numbered: true, ref-label: none, body) = statement("remark", title, lang, numbered, ref-label, body)

/// Set an unnumbered proof with an optional closing mark.
#let proof(title: none, lang: auto, qed: sym.square.stroked, body) = context {
  let name = environment-name("proof", if lang == auto { text.lang } else { lang })
  let ending = if qed != none { [~#qed] }
  environment-block(name, title, body + ending)
}
