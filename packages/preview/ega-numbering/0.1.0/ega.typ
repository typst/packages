#let ega-counter = counter("ega")

#let parvirtual = {
"" 
context v(-par.spacing -  measure("").height)
}

// user adjustable parameters by state variables,
// variables are named with a long name to avoid conflict with other user-defined variables
// users are not supposed to access these variables
#let ega-inpackage-numbering-level = state("dingli-inpackage-numbering-level-int", 0)
#let ega-inpackage-vertical-padding = state("dingli-inpackage-vertical-padding-array", (2em, 2em))

// numbering format of theorems,
// users are not supposed to access this
#let ega-inpackage-numbering-format = {
  (..nums) => {
    let level = ega-inpackage-numbering-level.get()
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

// basic paragraph styles
#let num-par(
  indent: false,
  ..description,
  body,
) = {
  let numbering = ega-inpackage-numbering-format
  let parnumber = context ega-counter.get().at(0)
  let par-description = description.pos()
  return (figure({
    ega-counter.step()
    block[
    #if indent {
    parvirtual
    }
    #if par-description == () {[
      *#context counter(heading).display(numbering)#parnumber.*#h(0.4em)
    ]} else {[
      *#context counter(heading).display(numbering)#parnumber. #par-description.at(0).* #h(0.4em)
    ]}
    #body]
  }, kind: "ega-par", supplement: none))
}
  

// show rules
#let ega-rules(level: 0, upper: 2em, lower: 2em, body) = {
  ega-inpackage-numbering-level.update(level)
  ega-inpackage-vertical-padding.update((upper, lower))
  show heading: it => {
    if it.level <= level {
      ega-counter.update(0)
      counter(figure.where(kind: "ega-par")).update(0)
    }
    it
  } 
  show figure: it => {
    if it.kind == "ega-par" {
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
    } else if it.element.func() == figure and it.element.kind == "ega-par"{
      link(
        it.element.location()
      )[#it.element.supplement #ega-inpackage-numbering-format(..counter(heading).at(it.element.location()))#counter(figure.where(kind: it.element.kind)).at(it.element.location()).at(0)]
    } else {
      it
    }
  }
  body
}
