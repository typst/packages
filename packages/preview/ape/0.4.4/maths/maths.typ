#let breakable-or-not(min-size: 120pt, content) = context {
  layout(size => {
    let body = block(width: size.width, content)
    let (height,) = measure(
      body,
    )

    if (height < min-size) {
      block(width: size.width, breakable: false, content)
    } else {
      body
    }
  })
}


#let maths-num-state = state("maths-num")

#let get-maths-count(type) = context {
  if maths-num-state.get() == "normal" {
    let cpt = counter("maths")
    cpt.step()
    let n = cpt.get().at(0) + 1

    [#n]
  }else if maths-num-state.get() == "separate"{
    let cpt = counter("maths-" + type)
    cpt.step()
    let n = cpt.get().at(0) + 1

    [#n]
    
  }
}
