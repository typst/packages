#let c-thm = counter("theorem")
#let c-lem = counter("lemma")
#let c-cor = counter("corollary")
#let c-def = counter("definition")
#let c-rmk = counter("remark")
#let c-xmp = counter("example")
#let c-list = (c-thm, c-lem, c-cor, c-def, c-rmk, c-xmp)
#let kind-list = ("theorem", "lemma", "corollary", "definition", "remark", "example")

#let parvirtual = {
"" 
context v(-par.spacing -  measure("").height)
}

// user adjustable parameters by state variables,
// variables are named with a long name to avoid conflict with other user-defined variables
// users are not supposed to access these variables
#let dingli-inpackage-numbering-level = state("dingli-inpackage-numbering-level-int", 0)
#let dingli-inpackage-vertical-padding = state("dingli-inpackage-vertical-padding-array", (2em, 2em))

// numbering format of theorems,
// users are not supposed to access this
#let dingli-inpackage-numbering-format = {
  (..nums) => {
    let level = dingli-inpackage-numbering-level.get()
    if level == 0 {
      return ""
    } else {
      let l = nums.pos()
      if l.len() > level{
        l = l.slice(0,level)
      } else {
        while l.len() < level {
          l.push(0)
        }
      }
      return l.map(str).join(".") + "."
    }
  }
}

// basic theorem styles
#let theorem(
  kind: "theorem", 
  pre: "Theorem", 
  count: c-thm, 
  indent: false,
  ..name,
  body,
) = {
  let numbering = dingli-inpackage-numbering-format
  let thmnumber = context count.get().at(0)
  let thm-name = name.pos()
  return (figure({
    count.step()
    block[
    #if indent {
    parvirtual
    }
    #if thm-name == () {[
      *#pre #context counter(heading).display(numbering)#thmnumber.*#h(0.4em)
    ]} else {[
      *#pre #context counter(heading).display(numbering)#thmnumber* (#thm-name.at(0))*.*#h(0.4em)
    ]}
    #body]
  }, kind: kind, supplement: pre))
}
  
#let remark(
  kind: "remark", 
  pre: "Remark", 
  count: c-rmk, 
  indent: false,
  body,
) = {
  context v(dingli-inpackage-vertical-padding.get().at(0), weak: true)
  block[
  #if indent {
    parvirtual
  }
  _#pre._#h(0.4em)
  #body]
  context v(dingli-inpackage-vertical-padding.get().at(0), weak: true)
}

#let proof(body, pre: "Proof", count: c-thm, indent: none) = {
  context v(dingli-inpackage-vertical-padding.get().at(0), weak: true)
  block[
  #if indent != none {
  parvirtual
  }
  _#pre._#h(0.4em)
  #body  
  #box(width: 2em)
  #h(1fr)
  $qed$
  ]
  parvirtual
  context v(dingli-inpackage-vertical-padding.get().at(1), weak: true)
}

// derived styles
#let lemma = theorem.with(kind: "lemma", pre: "Lemma", count: c-lem)
#let corollary = theorem.with(kind: "corollary", pre: "Corollary", count: c-cor)
#let definition = theorem.with(kind: "definition", pre: "Definition", count: c-def)
#let example = theorem.with(kind: "example", pre: "Example", count: c-xmp)


#let dingli = theorem.with(pre: "定理", count: c-thm, indent: true)
#let yinli = lemma.with(pre: "引理", indent: true)
#let tuilun = corollary.with(pre: "推论", indent: true)
#let dingyi = definition.with(pre: "定义", indent: true)
#let lizi = example.with(pre: "例", indent: true)
#let zhengming = proof.with(pre: "证明", indent: true)

// show rules
#let dingli-rules(doc, level: 0, upper: 2em, lower: 2em) = {
  dingli-inpackage-numbering-level.update(level)
  dingli-inpackage-vertical-padding.update((upper, lower))
  show heading: it => {
    if it.level <= level {
      for c in c-list {
        c.update(0)
      }
      for k in kind-list {
        counter(figure.where(kind: k)).update(0)
      }
    }
    it
  } 
  show figure: it => {
    if it.kind in kind-list {
      v(upper, weak: true)
      set align(start)
      set block(breakable: true)
      it
      parvirtual
      v(lower, weak: true)
    } else {
      it
    }
  }
  show ref: it => {
    if it.element == none{
      it
    } else if it.element.func() == figure and it.element.kind in kind-list{
      link(
        it.element.location()
      )[#it.element.supplement #dingli-inpackage-numbering-format(..counter(heading).at(it.element.location()))#counter(figure.where(kind: it.element.kind)).at(it.element.location()).at(0)]
    } else {
      it
    }
  }
  doc
}
