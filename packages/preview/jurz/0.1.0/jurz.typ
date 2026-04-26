#let init-jurz = (
  two-sided: false, 
  gap: 1em, 
  supplement: "Rz.", 
  reset-level: 0, 
  body
) => {
  // Reset the Rz. in each heading "bigger" (i.e., with a smaller level) than the reset-level
  show heading: it => {
    it
    if (it.level <= reset-level) {
      counter("rz").update(0)
    }
  } 

  // Setup basic settings
  show heading.where(level: 99): set heading(numbering: (..nums) => {
    counter("rz").display()
  }, supplement: supplement, outlined: false)

  // Set up rendering outside the text flow
  show heading.where(level: 99): it => {
    counter("rz").step()
    context {
      // in one-sided layouts, every page is considered to be an even page
      let isOddPage = here().page().bit-and(1) > 0 and two-sided;

      let position = if isOddPage { right } else { left }
      let inner-position = if isOddPage { left } else { right }
      let dx = gap * if isOddPage { 1 } else { -1 }
      
      place(
        position,
        dx: dx,
        place(inner-position, it.body)
      )
    }
  }

  // Display the body
  body
}


#let rz = heading(level: 99, counter("rz").display())
