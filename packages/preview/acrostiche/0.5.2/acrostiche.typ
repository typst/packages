// Acrostiche package for Typst
// Author: Grizzly


#let acros = state("acronyms",none)
#let init-acronyms(acronyms) = {
  let states = (:)
  for (acr, defs) in acronyms{
    // Add metadata to each entry.
    // first boolean is "is it already defined?", used to know if expansion is needed.
    // second boolean is "was it used before in the document?", used for the used-only filtering in the index.
    let data = (defs, false, false)
    states.insert(acr,data)
  }
  acros.update(states)
}

#let display-short(acr, plural: false) = {
  // Display the short version of the requested acronym.
  // In most cases, the short version is the passed acronym itself.
  // In the case of advanced dictionary definitions, the short version is defined with the 'short' and 'short-pl' keys.
  context{
    let acronyms = acros.get()
    if acr in acronyms{
      let defs = acronyms.at(acr).at(0)
      if type(defs) == dictionary{
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
      panic("Could not display the short version of an acronym not defined: "+acr)
    }
  }
}

#let display-def(acr, plural: false) = {
  // Display the definition of an acronym by fetching it in the "acronyms" state's value (should be a dictionary).
  //
  // First, grab the dictionary of definitions of acronyms from the "acronyms" state
  context{ 
    let acronyms = acros.get()
    if acr in acronyms{
      let defs = acronyms.at(acr).at(0)



      // The Definition is a string============
      if type(defs) == str{ // If user defined only one version and forgot the trailing comma the type is string
        if plural{defs+"s"}
        else{defs} // All is good, we return the definition found as the singular version
      }

      // The Definition is an array ============
      else if type(defs) == array{
        if defs.len() == 0{ // The user could have provided an empty array, unlikely but possible.
          panic("No definitions found for acronym "+acr+". Make sure it is defined in the dictionary passed to #init-acronyms(dict)")
        }else if defs.len() == 1{ // User provided only one version, we make the plural by adding an "s" at the end.
          if plural{defs.at(0)+"s"}
          else{defs.at(0)}
        }else{ // User provided more than one version. We assume the first is singular and the second is plural. All other are useless.
          if plural{defs.at(1)}
          else{defs.at(0)}
        }

      // The Definition is a dictionary ============
      }else if type(defs) == dictionary{
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
        panic("Definitions should be a string, an array, or a dictionary. Definition of "+acr+ " is of type: "+repr(type(defs)))
      }
    }else{
      panic(acr+" is not a key in the acronyms dictionary.")
    }
  }
  
}

#let mark-acr-used(acr) = {
  // Mark an acronym as used.
  
  // Generate the key associated with this acronym
  let state-key = "acronym-state-" + acr
  acros.update(data => {
      let ndata = data
      // Change both booleans to mark it used until reset AND in the overall document.
      ndata.at(acr).at(1) = true
      ndata.at(acr).at(2) = true
      ndata 
    }
  )
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
      let short = display-short(acr, plural: plural)
      if data.at(acr).at(1){
        short
      }else{
        [#display-def(acr, plural: plural)~(#short)]
      }
    }else{
      panic("You requested the acronym "+acr+" that you did not define first.")
    }
  }
  mark-acr-used(acr)
}

#let acrpl(acronym) = {acr(acronym,plural:true)} // argument renamed acronym to differentiate with function acr

#let acrfull(acr) = {
  //Intentionally display an acronym in its full form. Do not update state.
  [#display-def(acr, plural: false) (#display-short(acr))]
}

#let acrfullpl(acr) = {
  //Intentionally display an acronym in its full form in plural. Do not update state.
  [#display-def(acr, plural: true) (#display-short(acr,plural:true))]
}

// define shortcuts


#let reset-acronym(acr) = { 
  // Reset a specific acronym. It will be expanded on next use.
  context{
    let data = acros.get()
    if not acr in data{
      panic("Cannot reset "+acr+", not in the list.")
    }
  }

  acros.update(data => {
      let ndata = data
      ndata.at(acr).at(1) = false
      ndata 
    }
  )
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
#let acrf(acr) = acrfull(acr)
#let acrfpl(acr) = acrfullpl(acr)
#let racr(acr) = reset-acronym(acr)
#let raacr() = reset-all-acronyms()

// Define some functions as in the "acronym" package for LaTeX by Tobias Oetiker
// https://ctan.org/pkg/acronym

#let acresetall = reset-all-acronyms
#let ac = acr
#let acp(acro) = acr(acro,plural:true)
#let acl(acro) = display-def(acro, plural:false)
#let aclp(acro) = display-def(acro, plural:true)
#let acf(acro) = acrf(acro)
#let acfp(acro) = acrfpl(acro)
#let acs(acro) = display-short(acro,plural:false)
#let acsp(acro) = display-short(acro,plural:true)
#let acused(acr) = mark-acr-used(acr)



#let print-index(level: 1, numbering: none, outlined: false, sorted:"",
title:"Acronyms Index", delimiter:":", row-gutter: 2pt, used-only: false, column-ratio: 0.25) = {
  //Print an index of all the acronyms and their definitions.
  // Args:
  //   level: level of the heading. Default to 1.
  //   outlined: make the index section outlined. Default to false
  //   sorted: define if and how to sort the acronyms: "up" for alphabetical order, "down" for reverse alphabetical order, "" for no sort (print in the order they are defined). Default to "".
  //   title: set the title of the heading. Default to "Acronyms Index". Passing an empty string will result in removing the heading.
  //   delimiter: String to place after the acronym in the list. Defaults to ":"
  //   used-only: if true, only include in the index the acronyms that are used in the document. Warning, if you reset acronyms and don't used them after, they may not appear.
  //   column-ratio: a float positive value that indicate the width ratio of the first column (acronyms) with respect to the second (definitions).

  // assert on input values to avoid cryptic error messages
  assert(sorted in ("","up","down"), message:"Sorted must be a string either \"\", \"up\" or \"down\"")
  assert(0 <= column-ratio, message: "\"column-ratio\" must be a positive value.")

  if title != ""{
    heading(level: level, numbering: numbering, outlined: outlined)[#title]
  }

  context{
    

      
    let acronyms = acros.get()
    let acr-list = acronyms.keys()

    if used-only{
      // Select only acronyms where state is true at the end of the document.
      let acronyms = acros.final() 
      let used-acr-list = ()
      for acr in acr-list{
        if acros.final().at(acr).at(2) {
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
    let col1 = column-ratio / (1 + column-ratio)
    let col2 = 1 - col1
    grid(
      columns: (col1 * 100%, col2 * 100%),
      row-gutter: row-gutter,
      ..for acr in acr-list{
        ([*#display-short(acr, plural:false)#delimiter*], display-def(acr,plural:false))
      }
    )
  }
}

