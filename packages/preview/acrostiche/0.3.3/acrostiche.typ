// Acrostiche package for Typst
// Author: Grizzly


#let acros = state("acronyms",none)
#let init-acronyms(acronyms) = {
  acros.update(acronyms)
}

#let reset-acronym(term) = { 
  // Reset a specific acronym. It will be expanded on next use.
    state("acronym-state-" + term, false).update(false)
}

#let reset-all-acronyms() = { 
  // Reset all acronyms. They will all be expanded on the next use.
  state("acronyms",none).display(acronyms=>
    for acr in acronyms.keys() {
      state("acronym-state-" + acr, false).update(false)
  })
}

#let display-def(plural: false, acr) = {
  //
  if plural{
    state("acronyms",none).display(acronyms=>{
      if acr in acronyms{
        let defs = acronyms.at(acr)
        if type(defs) == "string"{ // If user forgot the trailing comma the type is string
          defs
        }else if type(defs)== "array"{
          if acronyms.at(acr).len() == 0{panic("No definitions found for acronym "+acr+". Make sure it is defined in the dictionary passed to #init-acronyms(dict)")
          }else if acronyms.at(acr).len() == 1{
            acronyms.at(acr).at(0)+"s"
          }else{
            acronyms.at(acr).at(1)
          }
        }else{
          panic("Definitions should be arrays of one or two strings. Definition of "+acr+ " is: "+type(defs))
        }
      }else{
        panic(acr+" is not a key in the acronyms dictionary.")
      }
    })
  }else{
    state("acronyms",none).display(acronyms=>{
      if acr in acronyms{
        let defs = acronyms.at(acr)
        if type(defs) == "string"{ // If user forgot the trailing comma the type is string
          defs
        }else if type(defs)== "array"{
          if acronyms.at(acr).len() == 0{panic("No definitions found for acronym "+acr+". Make sure it is defined in the dictionary passed to #init-acronyms(dict)")
          }else{
            acronyms.at(acr).at(0)
          }
        }else{
          panic("Definitions should be arrays of one or two strings. Definition of "+acr+ " is: "+type(defs))
        }
      }else{
        panic(acr+" is not a key in the acronyms dictionary.")
      }
      
      })
  }
}

#let acrfull(acr) = {
  //Intentionally display an acronym in its full form. Does not expand it and does not update state.
  [#display-def(plural: false, acr)]
}

#let acrfullpl(acr) = {
  //Intentionally display an acronym in its full form in plural. Does not expand it and does not update state.
  [#display-def(plural: true, acr)]
}

#let acr(acr) = {
  // Display an acronym in the singular form. Expands it if used for the first time.
  
  // Generate the key associated with this acronym
  let state-key = "acronym-state-" + acr
  // Create a state to keep track of the expansion of this acronym
  state(state-key,false).display(seen => {if seen{acr}else{[#display-def(plural: false, acr) (#acr)]}})
  state(state-key,false).update(true)
}

#let acrpl(acr) = {
  // Display an acronym in the plural form. Expands it if used for the first time. 
    
  // Generate the key associated with this acronym
  let state-key = "acronym-state-" + acr
  // Create a state to keep track of the expansion of this acronym
  state(state-key,false).display(seen => {if seen{acr+"s"}else{[#display-def(plural: true, acr) (#acr\s)]}})
  state(state-key,false).update(true)
}

#let print-index(level: 1, numbering: none, outlined: false, sorted:"",
                 title:"Acronyms Index", delimiter:":", row-gutter: 2pt) = {
  //Print an index of all the acronyms and their definitions.
  // Args:
  //   level: level of the heading. Default to 1.
  //   outlined: make the index section outlined. Default to false
  //   sorted: define if and how to sort the acronyms: "up" for alphabetical order, "down" for reverse alphabetical order, "" for no sort (print in the order they are defined). If anything else, sort as "up". Default to ""
  //   title: set the title of the heading. Default to "Acronyms Index". Passing an empty string will result in removing the heading.
  //   delimiter: String to place after the acronym in the list. Defaults to ":"

  // assert on input values to avoid cryptic error messages
  assert(sorted in ("","up","down"), message:"Sorted must be a string either \"\", \"up\" or \"down\"")

  if title != ""{
    heading(level: level, numbering: numbering, outlined: outlined)[#title]
  }

  state("acronyms",none).display(acronyms=>{
    
    // Build acronym list
    let acr-list = acronyms.keys()

    // order list depending on the sorted argument
    if sorted!="down"{
      acr-list = acr-list.sorted()
    }else{
      acr-list = acr-list.sorted().rev()
    }
  
    // print the acronyms
    table(
      columns: (20%,80%),
      stroke: none,
      row-gutter: row-gutter,
      ..for acr in acr-list{
        let acr-long = acronyms.at(acr)
        let acr-long = if type(acr-long) == array {
          acr-long.at(0)
        } else {acr-long}
        ([*#acr#delimiter*], acr-long)
      }
    )
})
}

