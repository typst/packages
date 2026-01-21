#let richcounter(identifier: none, inherited_levels: 0, inherited_from: heading) = {
  // create the underlying counter for the rich counter
  let cntr = counter(identifier)
  // get the parent counter
  let parent_cntr = if type(inherited_from) == dictionary {
    if inherited_levels == 0 { inherited_levels = inherited_from.inherited_levels + 1 }
    
    inherited_from.raw
  } else if type(inherited_from) == counter {
    inherited_from
  } else {
    counter(inherited_from)
  }

  // helper function for `sync`
  let rel_slice(num) = num.slice(0, calc.min(num.len(), inherited_levels))
  
  // updates the underlying counter if the relevant levels of the parent counter changed
  let sync = () => {
    let num = cntr.get()
    let rel_parent_num = rel_slice(parent_cntr.get())
    if rel_slice(num) < rel_parent_num or num.len() <= inherited_levels {
      cntr.update(rel_parent_num + (inherited_levels - rel_parent_num.len() + 1)*(0,))
    }
  }

  // `step` function for this counter
  let step = (depth: 1) => {
    context sync()
    cntr.step(level: inherited_levels + depth)
  }

  // `display` function for this counter
  let display = (numbering_style) => {
    sync()
    context cntr.display(numbering_style)
  }
  
  return (raw: cntr, step: step, display: display, inherited_levels: inherited_levels)
}
