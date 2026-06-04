// Acrostiche package for Typst
// Author: Grizzly


#let acros = state("acronyms",none)
#let init-acronyms(acronyms) = {
  acros.update(acronyms)
}


#let display-def(plural: false, acr) = {
  // Display the definition of an acronym by fetching it in the "acronyms" state's value (should be a dictionary).

  // First, grab the dictionary of definitions of acronyms from the "acronyms" state
  context{ 
    let acronyms = state("acronyms",none).get()
    if acr in acronyms{
      let defs = acronyms.at(acr)
      if type(defs) == "string"{ // If user defined only one version and forgot the trailing comma the type is string
        if plural{panic("You requested the plural version of the acronym but it seems like you only provided the singular version in #init-acronyms(dict)")}
        else{defs} // All is good, we return the definition found as the singular version
      }
      else if type(defs) == "array"{
        if defs.len() == 0{ // The user could have provided an empty array, unlikely but possible.
          panic("No definitions found for acronym "+acr+". Make sure it is defined in the dictionary passed to #init-acronyms(dict)")
        }else if acronyms.at(acr).len() == 1{ // User provided only one version, we make the plural by adding an "s" at the end.
          if plural{acronyms.at(acr).at(0)+"s"}
          else{acronyms.at(acr).at(0)}
        }else{ // User provided more than one version. We assume the first is singular and the second is plural. All other are useless.
          if plural{acronyms.at(acr).at(1)}
          else{acronyms.at(acr).at(0)}
        }
      }else{
        panic("Definitions should be arrays of one or two strings. Definition of "+acr+ " is "+defs+" of type: "+type(defs))
      }
    }else{
      panic(acr+" is not a key in the acronyms dictionary.")
    }
  }
  
}

#let acr(acr) = {
  // Display an acronym in the singular form. Expands it if used for the first time.
  
  // Generate the key associated with this acronym
  let state-key = "acronym-state-" + acr
  // Test if the state for this acronym already exists and if the acronym was already used
  // to choose what to display.
  context if state(state-key,false).get(){
    acr
  }else{
    [#display-def(plural: false, acr) (#acr)]
  }
  // Now change the state to true because the acronym was already used.
  state(state-key,false).update(true)
}

#let acrpl(acr) = {
  // Display an acronym in the singular form. Expands it if used for the first time.
  
  // Generate the key associated with this acronym
  let state-key = "acronym-state-" + acr
  // Test if the state for this acronym already exists and if the acronym was already used
  // to choose what to display.
  context if state(state-key,false).get(){
    [#acr\s]
  }else{
    [#display-def(plural: true, acr) (#acr\s)]
  }
  // Now change the state to true because the acronym was already used.
  state(state-key,false).update(true)
}

#let acrfull(acr) = {
  //Intentionally display an acronym in its full form. Does not expand it and does not update state.
  [#display-def(plural: false, acr)]
}

#let acrfullpl(acr) = {
  //Intentionally display an acronym in its full form in plural. Does not expand it and does not update state.
  [#display-def(plural: true, acr)]
}


#let reset-acronym(acr) = { 
  // Reset a specific acronym. It will be expanded on next use.
    state("acronym-state-" + acr, false).update(false)
}

#let reset-all-acronyms() = { 
  // Reset all acronyms. They will all be expanded on the next use.
  context{
    let acronyms = state("acronyms",none).get()
    for acr in acronyms.keys() {
      state("acronym-state-" + acr, false).update(false)
    }
  }
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

  context{
    let acronyms = state("acronyms",none).get()
    
    // Updated
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
  }
}

