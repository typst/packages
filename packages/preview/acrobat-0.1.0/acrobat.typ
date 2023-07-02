// Provide usefull error message in case the user did not copy-past the proxy functions in the main document
#let acr(..)=panic("It appears proxy functions are not defined in the main document. Please consult the instruction to solve this error.")
#let acrpl(..)=panic("It appears proxy functions are not defined in the main document. Please consult the instruction to solve this error.")
#let print-index(..)=panic("It appears proxy functions are not defined in the main document. Please consult the instruction to solve this error.")
#let get-def(..)=panic("It appears proxy functions are not defined in the main document. Please consult the instruction to solve this error.")
#let reset-all-acronyms(..)=panic("It appears proxy functions are not defined in the main document. Please consult the instruction to solve this error.")


#let reset-acronym(term) = { 
  // Reset a specific acronym. It will be expanded on next use.
    state("acronym-state-" + term, false).update(false)
}

#let full-reset-all-acronyms(acronyms) = { 
  // Reset all acronyms. They will all be expanded on the next use.
  for acr in acronyms.keys() {
    state("acronym-state-" + acr, false).update(false)
  }
}

#let full-get-def(plural: false, acr,acronyms) = {
  // Return the definition of an acronyms
  // Args:
  //  - plural: If true, return the plural form of the definition. Default to false.

  if acr not in acronyms.keys(){
    panic("Acronym "+acr+" is not defined.")
  }
  let value = acronyms.at(acr)
  let definition = ""

  if plural{
    if type(value) == "string"{
      definition = value + "s"
    }else if type(value) == "array"{
      if value.len() == 1{
        definition = value.at(0) + "s"
      }else if value.len() > 1{
        definition = value.at(1)
      }else{
        panic("Definition for acronym "+acr+" is an empty array.")
      }
    }
  }else{
    if type(value) == "string"{
      definition = value
    }else if type(value) == "array" and value.len() > 0{
        definition = value.at(0)
    }else{
      panic("Definition of "+acr+" is not properly defined. It should be a string or an array of strings.")
    }
  }
  definition
}

#let full-acr(acr,acronyms) = {
  // Display an acronym in the singular form. Expands it if used for the first time. 
  if acr in acronyms{
    // Grab definition of the term
    let definition = full-get-def(acr,acronyms)
    // Generate the key associated with this term
    let state-key = "acronym-state-" + acr
    // Create a state to keep track of the expansion of this acronym
    state(state-key,false).display(seen => {if seen{acr}else{[#definition (#acr)]}})
    // Update state to true as it has just been defined
    state(state-key, false).update(true)
  }else{
    panic("Acronym "+acr+" is not defined.")
  }
}



#let full-acrpl(acr,acronyms) = {
  // Display an acronym in the plural form. Expands it if used for the first time. 
  
  if acr in acronyms{
    // Grab definition of the term
    let definition = full-get-def(plural: true, acr,acronyms)
    // Generate the key associated with this term
    let state-key = "acronym-state-" + acr
    // Create a state to keep track of the expansion of this acronym
    state(state-key,false).display(seen => {if seen{acr+"s"}else{[#definition (#acr\s)]}})
    // Update state to true as it has just been defined
    state(state-key, false).update(true)
  }else{
    panic("Acronym "+acr+" is not defined.")
  }
}

#let full-print-index(level: 1, outlined: false, all: true, sorted:"", acronyms) = {
  //Print an index of all the acronyms and their definitions.
  // Args:
  //   level: level of the heading. Default to 1.
  //   outlined: make the index section outlined. Default to false
  //   all: print all acronyms even if not used in the text. Default to true.
  //   sorted: define if and how to sort the acronyms: "up" for alphabetical order, "down" for reverse alphabetical order, "" for no sort (print in the order they are defined). If anything else, sort as "up". Default to ""

  // assert on input values to avoid cryptic error messages
  assert(sorted in ("","up","down"), message:"Sorted must be a string either \"\", \"up\" or \"down\"")

  // Build to acronym list
  let acr-list = acronyms.keys()
  if sorted == ""{
    let acr-list = acronyms.keys()
  }else if sorted!="down"{
    acr-list = acr-list.sorted()
  }else{
    acr-list = acr-list.sorted().rev()
  }
  
  heading(level: level, outlined: outlined)[Acronyms index:]

  
  if all{// Go through the list and print all acronyms
    for acr in acr-list{
      let definition = full-get-def(acr,acronyms)
      table(
        columns: (20%,80%),
        stroke:none,
        [*#acr:*], [#definition\ ]
      )
      v(-15pt) // remove 
    }
    v(15pt)// restore last remove space
    
  }else{// Go through the list but only print used acronyms
      for acr in acr-list{
        let state-key = "acronym-state-" + acr
        let s = state(state-key,false)
        let definition = full-get-def(acr,acronyms)
        locate(loc => {
        if s.final(loc){
          table(
            columns: (20%,80%),
            stroke:none,
            [*#acr:*], [#definition\ ]
          )
          v(-15pt) // remove
        }
      })
      }
      v(15pt) // restore last remove space
  }
}

