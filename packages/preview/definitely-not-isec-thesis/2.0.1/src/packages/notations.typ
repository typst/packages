// Acrostiche package for Typst
// Author: Grizzly
// License: MIT
// https://typst.app/universe/package/acrostiche

// Downstream version with extra patches and rename to notation
// Patches: ecomaikgolf

#let notat = state("notations",none)
#let init-notations(notations) = {
  let states = (:)
  for (acr, defs) in notations{
    // Add metadata to each entry.
    // first boolean is "is it already defined?", used to know if expansion is needed.
    // second boolean is "was it used before in the document?", used for the used-only filtering in the index.
    let data = (defs, false, false)
    states.insert(acr,data)
  }
  notat.update(states)
}

#let display-ntt-short(acr, plural: false) = {
  // Display the short version of the requested notation.
  // In most cases, the short version is the passed notation itself.
  // In the case of advanced dictionary definitions, the short version is defined with the 'short' and 'short-pl' keys.
  context{
    let notations = notat.get()
    if acr in notations{
      let defs = notations.at(acr).at(0)
      if type(defs) == dictionary {
        if plural {
          if "short-pl" in defs{
            defs.at("short-pl")
          }else{
            [#acr\s]
          }
        }else{
          if "short" in defs{
            defs.at("short")
          }else{acr}
        }
      }else{
        if plural{
          [#acr\s]
        }
        else{acr}
      }
    }else{
      panic("Could not display the short version of an notation not defined: "+acr)
    }
  }
}

#let display-ntt-def(acr, plural: false) = {
  // Display the definition of an notation by fetching it in the "notations" state's value (should be a dictionary).
  //
  // First, grab the dictionary of definitions of notations from the "notations" state
  context{
    let notations = notat.get()
    if acr in notations{
      let defs = notations.at(acr).at(0)

      // The Definition is a string============
      if type(defs) == str { // If user defined only one version and forgot the trailing comma the type is string
        if plural{panic("You requested the plural version of the notation but it seems like you only provided the singular version in #init-notations(dict)")}
        else{defs} // All is good, we return the definition found as the singular version
      }

      // The Definition is an array ============
      else if type(defs) == array {
        if defs.len() == 0{ // The user could have provided an empty array, unlikely but possible.
          panic("No definitions found for notation "+acr+". Make sure it is defined in the dictionary passed to #init-notations(dict)")
        }else if defs.len() == 1{ // User provided only one version, we make the plural by adding an "s" at the end.
          if plural{defs.at(0)+"s"}
          else{defs.at(0)}
        }else{ // User provided more than one version. We assume the first is singular and the second is plural. All other are useless.
          if plural{defs.at(1)}
          else{defs.at(0)}
        }

      // The Definition is a dictionary ============
      }else if type(defs) == dictionary {
        if plural{
          if "long-pl" in defs{
            defs.at("long-pl")
          }else{
            panic("The dictionary of definitions supplied for the key "+acr+" does not contain a plural definition with the key 'long-pl'.")
          }
        }else{
          if "long" in defs{
            defs.at("long")
          }else{
            panic("The dictionary of definitions supplied for the key "+acr+" does not contain a cingular definition with the key 'long'.")
          }
        }
      }else{
        panic("Definitions should be a string, an array, or a dictionary. Definition of "+acr+ " is of type: "+type(defs))
      }
    }else{
      panic(acr+" is not a key in the notations dictionary.")
    }
  }

}

#let mark-att-used(acr) = {
  // Mark an notation as used.

  // Generate the key associated with this notation
  let state-key = "notation-state-" + acr
  notat.update(data => {
      let ndata = data
      // Change both booleans to mark it used until reset AND in the overall document.
      ndata.at(acr).at(1) = true
      ndata.at(acr).at(2) = true
      ndata
    }
  )
}

#let ntt(acr, plural:false) = {
  // Display an notation in the singular form by default. Expands it if used for the first time.

  // Generate the key associated with this notation
  let state-key = "notation-state-" + acr
  // Test if the state for this notation already exists and if the acronym was already used
  // to choose what to display.
  context{
    let data = notat.get()
    if acr in data{
      text(size: 11pt)[#data.at(acr).at(0).at(0)#label(state-key)]
    }else{
      panic("You requested the notation "+acr+" that you did not define first.")
    }
  }
  mark-att-used(acr)
}

#let nttpl(notation) = {acr(acronym,plural:true)} // argument renamed acronym to differentiate with function acr

#let nttfull(acr) = {
  //Intentionally display an notation in its full form. Do not update state.
  [#display-def(acr, plural: false) (#display-ntt-short(acr))]
}

#let nttfullpl(acr) = {
  //Intentionally display an notation in its full form in plural. Do not update state.
  [#display-def(acr, plural: true) (#display-ntt-short(acr,plural:true))]
}

// define shortcuts


#let reset-notation(acr) = {
  // Reset a specific notation. It will be expanded on next use.
  context{
    let data = notat.get()
    if not acr in data{
      panic("Cannot reset "+acr+", not in the list.")
    }
  }

  notat.update(data => {
      let ndata = data
      ndata.at(acr).at(1) = false
      ndata
    }
  )
}

#let reset-all-notations() = {
  // Reset all notations. They will all be expanded on the next use.
  context{
    let notations = notat.get()
    for acr in notations.keys(){
      reset-notation(acr)
    }
  }
}


// Define shortcuts
#let nttf(acr) = {acrfull(acr)}
#let nttfpl(acr) = {acrfullpl(acr)}
#let rntt(acr) = {reset-notation(acr)}
#let rantt() = reset-all-notations()

// Define some functions as in the "notation" package for LaTeX by Tobias Oetiker
// https://ctan.org/pkg/notation

#let acresetall = reset-all-notations
#let ac = ntt
#let acf(acro) = acrf(acro)
#let acfp(acro) = acrfpl(acro)
#let acs(acro) = display-ntt-short(acro,plural:false)
#let acsp(acro) = display-ntt-short(acro,plural:true)
#let acused(acr) = mark-att-used(acr)



#let print-index-ntt(level: 1, numbering: none, outlined: false, sorted:"",
                 title:"notations Index", delimiter:":", row-gutter: 2pt, used-only: false) = {
  //Print an index of all the notations and their definitions.
  // Args:
  //   level: level of the heading. Default to 1.
  //   outlined: make the index section outlined. Default to false
  //   sorted: define if and how to sort the notations: "up" for alphabetical order, "down" for reverse alphabetical order, "" for no sort (print in the order they are defined). Default to "".
  //   title: set the title of the heading. Default to "notations Index". Passing an empty string will result in removing the heading.
  //   delimiter: String to place after the notation in the list. Defaults to ":"
  //   used-only: if true, only include in the index the notations that are used in the document. Warning, if you reset notations and don't used them after, they may not appear.

  // assert on input values to avoid cryptic error messages
  assert(sorted in ("","up","down"), message:"Sorted must be a string either \"\", \"up\" or \"down\"")

  if title != ""{
    heading(level: level, numbering: numbering, outlined: outlined)[#title]
  }

  context{
    let notations = notat.get()
    let acr-list = notations.keys()

    if used-only{
      // Select only notations where state is true at the end of the document.
      let notations = notat.final()
      let used-acr-list = ()
      for acr in acr-list{
        if notat.final().at(acr).at(2) {
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

    // print the notations
    grid(
      columns: (20%,80%),
      row-gutter: row-gutter,
      ..for acr in acr-list{
        ([*#display-ntt-short(acr, plural:false)#delimiter*], display-def(acr,plural:false))
      }
    )
  }
}

//vim:tabstop=2 softtabstop=2 shiftwidth=2 noexpandtab colorcolumn=81
