#let mathblock(blocktitle: none, counter: none, numbering: "1.1", prefix: auto, titlix: title => [(#title)], suffix: none, bodyfmt: body => body, ..global_block_args) = {
  // check if blocktitle was provided
  if blocktitle == none {
    panic("You have created a `mathblock` without a `blocktitle`. Please provide a `blocktitle` like \"Theorem\" or \"Lemma\" or \"Proof\".")
  }

  // set the default prefix
  if prefix == auto {
    if counter == none {
      prefix = [*#blocktitle.*]
    } else {
      prefix = (counter) => [*#blocktitle #counter.*]
    }
  }

  // check consistency of `counter` and `prefix`
  if counter == none and type(prefix) == function {
    panic("You have created a `mathblock` without a `counter` but with a `prefix` that accepts a counter. This is inconsistent. If you want a counter, then provide it with the `counter` argument (see documentation). If you don't want a counter, then you need to set a `prefix` that doesn't depend on a counter (see documentation).")
  } else if counter != none and type(prefix) != function {
    panic("You have created a `mathblock` with a `counter` but with a `prefix` that doesn't depend on a counter. This is inconsistent. If you don't want a counter, then remove the `counter` argument. If you want a counter, then set a prefix that depends on a counter (see documentation).")
  }

  // wrap native counter
  if counter != none and type(counter) != dictionary {
    counter = (
      step: (..args) => { counter.step(..args) },
      get: (..args) => { counter.get(..args) },
      at: (..args) => { counter.at(..args) },
      display: (..args) => { counter.display(..args) },
    )
  }

  // return the environment for the user
  if counter != none {
    return (title: none, numbering: numbering, prefix: prefix, titlix: titlix, suffix: suffix, bodyfmt: bodyfmt, number: auto, ..local_block_args, body) => {
      figure(kind: "great-theorem-counted", supplement: blocktitle, outlined: false)[#block(width: 100%, ..global_block_args.named(), ..local_block_args.named())[
        #if number == auto [
          // step and counter
          #(counter.step)()
          #{number = context (counter.display)(numbering)}
          // store counter so reference can get counter value
          // NOTE: alternatively could store result of counter.get(), but then it would take one more layout iteration
          #metadata((loc) => { std.numbering(numbering, ..((counter.at)(loc))) })
          #label("great-theorems:numberfunc")
        ] else [
          // store manual number for reference
          #metadata((loc) => number)
          #label("great-theorems:numberfunc")
        ]
        // show content
        #prefix(number)
        #if title != none [#titlix(title)]
        #bodyfmt(body)
        #suffix
        #parbreak()
      ]]
    }
  } else {
    return (title: none, numbering: numbering, prefix: prefix, titlix: titlix, suffix: suffix, bodyfmt: bodyfmt, ..local_block_args, body) => {
      figure(kind: "great-theorem-uncounted", supplement: blocktitle, outlined: false)[#block(width: 100%, ..global_block_args.named(), ..local_block_args.named())[
        // show content
        #prefix
        #if title != none [#titlix(title)]
        #bodyfmt(body)
        #suffix
        #parbreak()
      ]]
    }
  }
}

#let proofblock(blocktitle: "Proof", prefix: text(style: "oblique", [Proof.]), prefix_with_of: of => text(style: "oblique", [Proof of #of.]), suffix: [#h(1fr) $square$], bodyfmt: body => body, ..global_block_args) = {
  // return the environment for the user
  return (of: none, prefix: prefix, prefix_with_of: prefix_with_of, suffix: suffix, bodyfmt: bodyfmt, ..local_block_args, body) => {
    if type(of) == label {
      of = ref(of)
    }
    
    figure(kind: "great-theorem-uncounted", supplement: blocktitle, outlined: false)[#block(width: 100%, ..global_block_args.named(), ..local_block_args.named())[
      // show content
      #if of != none [#prefix_with_of(of)] else [#prefix]
      #bodyfmt(body)
      #suffix
      #parbreak()
    ]]
  }
}

#let great-theorems-init(body) = {
  show figure.where(kind: "great-theorem-counted"): set align(start)
  show figure.where(kind: "great-theorem-counted"): set block(breakable: true)
  show figure.where(kind: "great-theorem-counted"): fig => fig.body

  show figure.where(kind: "great-theorem-uncounted"): set align(start)
  show figure.where(kind: "great-theorem-uncounted"): set block(breakable: true)
  show figure.where(kind: "great-theorem-uncounted"): fig => fig.body

  show ref: it => {
    if it.element != none and it.element.func() == figure and it.element.kind == "great-theorem-counted" {
      let supplement = if it.citation.supplement != none { it.citation.supplement } else { it.element.supplement }
      let data = query(selector(label("great-theorems:numberfunc")).after(it.target)).first()
      let numberfunc = data.value
      link(it.target, [#supplement #numberfunc(data.location())])
    } else if it.element != none and it.element.func() == figure and it.element.kind == "great-theorem-uncounted" {
      let supplement = if it.citation.supplement != none { it.citation.supplement } else { it.element.supplement }
      link(it.target, [#supplement])
    } else {
      it
    }
  }

  body
}
