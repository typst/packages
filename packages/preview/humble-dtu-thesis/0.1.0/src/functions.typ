//---- Template File Inclusion ----
#let include-files(file-list) = {
  if file-list.len() != 0 {
    let files = file-list.values()
  
    for file in files {
      file
    }
  }
}

// ---- Notes Functionality ----
#let todoes = state("todo", [])  // Initialize with empty content instead of ()

#let add-note(content) = {
  // Create the formatted note block
  let formatted-note = block(
    width: 100%,
    fill: yellow,
    radius: 0.5em,
    stroke: black,
    inset: (top: 0.5em, bottom: 0.5em, left: 1em, right: 1em),
    outset: (top: 0.5em, bottom: 0.5em),
    if type(content) == numbering and content.len() > 1
    [
        *Note:*
        #content
    ]
    else
    [ *Note:* #content ]
  )
  
  // Store the formatted note directly
  todoes.update(t => t + formatted-note + v(0.5em))
  
  formatted-note
}

#let show-all-notes() = {
  let notes = context todoes.final()
  if notes != [] {
    block(
      width: 100%,
      inset: 1em,
      stroke: black,
      radius: 0.5em,
      [
        #text(weight: "bold")[All Notes:]
        #v(0.5em)
        #notes
      ]
    )
  }
}

//---- Custom Top Level Head(ings/lines)  ----
#let custom-heading(it) = [
  #set align(left)
  #set text(weight: "bold", size: 1.8em)

  // Numbering and title on the same line
  #if it.numbering != none {
    set text(fill: blue) // Chapter number color
    counter(heading).display(it.numbering) + h(3pt)  // Space after numbering
  }
  #text(it.body)
  #v(-12pt)
  #line(length: 100%, stroke: 2pt + rgb("#555555"))
]

//---- Custom Footer
#let numbering-headline(c)={
  if c.numbering!= none{
    return numbering(c.numbering,..counter(heading).at(c.location()))
  }
  return ""
}

#let current-h(level: 1)={
  let elems = query(selector(heading.where(level: level)).after(here()))

  if elems.len() != 0 and elems.first().location().page() == here().page(){
    return [#numbering-headline(elems.first()) #elems.first().body] 
  } else {
    elems = query(selector(heading.where(level: level)).before(here()))
    if elems.len() != 0 {
      return [#numbering-headline(elems.last()) #elems.last().body] 
    }
  }
  return ""
}

#let apply-custom-footer() = {
 set page(footer: context{
    if calc.rem(here().page(), 2) == 0 [  
      #align(left, text(current-h(), size: 10pt))
    ] else [  
      #align(right, current-h(level: 2))
    ]
  })
}

// // Alternative version of Custom Footer, with non changing sides
// #set page(footer: context {
//   let selector = selector(heading.where(level: 1)).before(here())
//   let level = counter(selector)
//   let headings = query(selector)

//   if headings.len() == 0 {
//     return
//   }

//   // Get the last level 1 heading correctly
//   let heading = headings.filter(it => it.level == 1).last()

//   if heading.numbering != none {
//     counter(page).display()
//     h(1fr)
//     level.display(heading.numbering) + ""
//     h(5pt)
//     heading.body
//   }
// })


