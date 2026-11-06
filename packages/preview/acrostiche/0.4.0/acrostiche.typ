// Acrostiche package for Typst
// Author: Grizzly


#let acros = state("acronyms",none)
#let init-acronyms(acronyms) = {
  let states = (:)
  for (acr, defs) in acronyms{
    let data = (defs, false)
    states.insert(acr,data)
  }
  acros.update(states)
}

#let display-def(plural: false, acr) = {
  // Display the definition of an acronym by fetching it in the "acronyms" state's value (should be a dictionary).

  // First, grab the dictionary of definitions of acronyms from the "acronyms" state
  context{ 
    let acronyms = acros.get()
    if acr in acronyms{
      let defs = acronyms.at(acr).at(0)
      if type(defs) == "string"{ // If user defined only one version and forgot the trailing comma the type is string
        if plural{panic("You requested the plural version of the acronym but it seems like you only provided the singular version in #init-acronyms(dict)")}
        else{defs} // All is good, we return the definition found as the singular version
      }
      else if type(defs) == "array"{
        if defs.len() == 0{ // The user could have provided an empty array, unlikely but possible.
          panic("No definitions found for acronym "+acr+". Make sure it is defined in the dictionary passed to #init-acronyms(dict)")
        }else if defs.len() == 1{ // User provided only one version, we make the plural by adding an "s" at the end.
          if plural{defs.at(0)+"s"}
          else{defs.at(0)}
        }else{ // User provided more than one version. We assume the first is singular and the second is plural. All other are useless.
          if plural{defs.at(1)}
          else{defs.at(0)}
        }
      }else{
        panic("Definitions should be arrays of one or two strings. Definition of "+acr+ " is "+defs+" of type: "+type(defs))
      }
    }else{
      panic(acr+" is not a key in the acronyms dictionary.")
    }
  }
  
}

#let acr(acr, plural:false) = {
  // Display an acronym in the singular form by default. Expands it if used for the first time.
  
  // Generate the key associated with this acronym
  let state-key = "acronym-state-" + acr
  // Test if the state for this acronym already exists and if the acronym was already used
  // to choose what to display.
  context{
    let data = acros.get()
    if acr in data{
      let short = if plural{[#acr\s]}else{acr}
      if data.at(acr).at(1){
        short
      }else{
        [#display-def(plural: plural, acr)~(#short)]
      }
      data.at(acr).at(1) = true
    }else{
      panic("You requested the acronym "+acr+" that you did not define first.")
    }
    acros.update(data)
  }
}

#let acrpl(acronym) = {acr(acronym,plural:true)} // argument renamed acronym to differentiate with function acr

#let acrfull(acr) = {
  //Intentionally display an acronym in its full form. Do not update state.
  [#display-def(plural: false, acr) (#acr)]
}

#let acrfullpl(acr) = {
  //Intentionally display an acronym in its full form in plural. Do not update state.
  [#display-def(plural: true, acr) (#acr\s)]
}

// define shortcuts


#let reset-acronym(acr) = { 
  // Reset a specific acronym. It will be expanded on next use.
  context{
    let data = acros.get()
    if acr in data{
      data.at(acr).at(1) = false
    }else{
      panic("You requested the acronym "+acr+" that you did not define first.")
    }
    acros.update(data)
  }
}

#let reset-all-acronyms() = { 
  // Reset all acronyms. They will all be expanded on the next use.
  context{
    let acronyms = acros.get()
    for acr in acronyms.keys(){
      reset-acronym(acr)
    }
  }
}

// Define shortcuts
#let acrf(acr) = {acrfull(acr)}
#let acrfpl(acr) = {acrfullpl(acr)}
#let racr(acr) = {reset-acronym(acr)}
#let raacr() = reset-all-acronyms()


#let print-index(level: 1, numbering: none, outlined: false, sorted:"",
                 title:"Acronyms Index", delimiter:":", row-gutter: 2pt, used-only: false) = {
  //Print an index of all the acronyms and their definitions.
  // Args:
  //   level: level of the heading. Default to 1.
  //   outlined: make the index section outlined. Default to false
  //   sorted: define if and how to sort the acronyms: "up" for alphabetical order, "down" for reverse alphabetical order, "" for no sort (print in the order they are defined). Default to "".
  //   title: set the title of the heading. Default to "Acronyms Index". Passing an empty string will result in removing the heading.
  //   delimiter: String to place after the acronym in the list. Defaults to ":"
  //   used-only: if true, only include in the index the acronyms that are used in the document. Warning, if you reset acronyms and don't used them after, they may not appear.

  // assert on input values to avoid cryptic error messages
  assert(sorted in ("","up","down"), message:"Sorted must be a string either \"\", \"up\" or \"down\"")

  if title != ""{
    heading(level: level, numbering: numbering, outlined: outlined)[#title]
  }

  context{
    let acronyms = acros.get()
    
    // Updated
    // Build acronym list
    let acr-list = acronyms.keys()

    if used-only{
      // Select only acronyms where state is true at the end of the document.
      // TODO Ideally, the code would check if the acronym is used anywhere in the document,
      // but I don't know how to do that yet. Feel free to propose changes.
      let used-acr-list = ()
      for acr in acr-list{
        if acros.final().at(acr).at(1) {
          used-acr-list.push(acr)
        }
      }
      acr-list = used-acr-list
    }

    // FEATURE: allow ordering by occurences position in the document. Not sure if possible yet.

    // order list depending on the sorted argument
    if sorted=="down"{
      acr-list = acr-list.sorted().rev()
    }else if sorted=="up"{
      acr-list = acr-list.sorted()
    }
  
    // print the acronyms
    table(
      columns: (20%,80%),
      stroke: none,
      row-gutter: row-gutter,
      ..for acr in acr-list{
        let desc = if type(acronyms.at(acr).at(0)) == array {
          acronyms.at(acr).at(0).at(0)
        } else {acronyms.at(acr).at(0)}
        ([*#acr#delimiter*], desc)
      }
    )
  }
}

