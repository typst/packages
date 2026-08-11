// Acrostiche package for Typst
// Author: Grizzly


//// Initialize and validate acronyms

#let __acrostiche_allowed_definitions = ("short", "short-pl", "long", "long-pl")

#let __complete-acronym-entry-dict(key, definitions) = {
  if "long" not in definitions {
    panic(
      "\"long\" should always be present, contact maintainer of the package.",
    )
  }
  // if there is no short definition we use the key as acronym
  if "short" not in definitions {
    definitions.insert("short", key)
  }
  // for plural add an s if they are not explicitly provided
  if "short-pl" not in definitions {
    definitions.insert("short-pl", [#definitions.at("short")\s])
  }
  if "long-pl" not in definitions {
    definitions.insert("long-pl", [#definitions.at("long")\s])
  }

  definitions
}


#let __validate-acronym-entry(key, definitions) = {
  let entry = (:)

  if type(definitions) == str {
    // if definitions is a single str it is the long definiton
    entry.insert("long", definitions)
  } else if type(definitions) == array {
    // if definitions is an array it is the long and optionally long-plural definition
    let n_defs = definitions.len()
    if n_defs == 0 {
      panic(
        ("No definitions found for acronym " + acr + ". ")
          + "Make sure it is defined in the dictionary passed to #init-acronyms()",
      )
    } else if n_defs > 2 {
      // alternatively ignore additional entries?
      panic(
        "Too many definitions, only 2 definitions allowed when using an array",
      )
    }
    for (key, def) in ("long", "long-pl").zip(definitions) {
      entry.insert(key, def)
    }
  } else if type(definitions) == dictionary {
    // if definitions is a dictionary

    // at least the long definition must exist
    if "long" not in definitions {
      panic(
        "The \"long\" definition must be defined when using a dictionary to define the acronym",
      )
    }
    for (key, def) in definitions {
      if key in __acrostiche_allowed_definitions {
        entry.insert(key, def)
      } else {
        // alternatively ignore additional keys?
        panic(
          "Illegal definition. Allowed definitions are: "
            + __acrostiche_allowed_definitions.join(", "),
        )
      }
    }
  } else {
    // invalid input type for definitions
    panic(
      "Definitions should be a str, an array, or a dictionary. "
        + ("Definition of " + acr + " is of type: " + repr(type(defs))),
    )
  }

  __complete-acronym-entry-dict(key, entry)
}

/// Dictionary of defined acronyms.
///
/// Each enty consists of the acronym definitions, whether it will be expanded on next usage, and whether it was used.
#let _acronyms = state("acrostiche-acronyms", none)

/// Whether an acronym index was inserted in the document.
#let _acrostiche-index = state("acrostiche-index", false)

/// Initialize acronyms and validate their definitions.
///
/// - acronyms (dictionary): Acronyms to initialize
#let init-acronyms(acronyms) = {
  let states = (:)
  for (acr, defs) in acronyms {
    // Add metadata to each entry.
    let data = (__validate-acronym-entry(acr, defs), false, false)
    states.insert(acr, data)
  }
  _acronyms.update(states)
}


//// Display acronyms

/// Capitalize the first letter of the acronym definition.
///
/// Capitalizes the first letter if the definition is a string else panics.
#let _capitalize-first(string) = {
  // return the passed string with the first letter capitalized and the rest unchanged
  if not type(string) == str {
    panic(
      "Trying to capitalize the first letter of a non-string element: "
        + (string + " (" + repr(type(string)) + ")."),
    )
  }
  (upper(string.first()), string.slice(1)).join("")
}

/// Display the short version of the acronym
///
/// - acr (string): Acronym key
/// - plural (bool): Plural version of the acronym
#let display-short(acr, plural: false) = {
  context {
    let acronyms = _acronyms.get()
    if acr in acronyms {
      let defs = acronyms.at(acr).at(0)
      if plural {
        defs.at("short-pl")
      } else {
        defs.at("short")
      }
    } else {
      panic(
        "Could not display the short version of an undefined acronym: " + acr,
      )
    }
  }
}

/// Display the long definition of the acronym
///
/// - acr (string): Acronym key
/// - plural (bool): Plural version of the definition
/// - cap (bool): Capitalize the first letter if the definition is a string
#let display-def(acr, plural: false, cap: false) = {
  context {
    let acronyms = _acronyms.get()
    if acr in acronyms {
      let defs = acronyms.at(acr).at(0)
      let def = if plural {
        defs.at("long-pl")
      } else {
        defs.at("long")
      }
      if cap {
        def = _capitalize-first(def)
      }
      return def
    } else {
      panic(
        "Could not display the definition of an undefined acronym: " + acr,
      )
    }
  }
}

/// Display the full version (long + short) of the acronym
///
/// - acr (string): Acronym key
/// - plural (bool): Plural version of the definition
/// - cap (bool): Capitalize the first letter if the definition is a string
#let display-full(acr, plural: false, cap: false) = {
  [#display-def(acr, plural: plural, cap: cap)~(#display-short(acr, plural: plural))]
}

/// Mark an acronym as used.
///
/// - acr (string): Acronym key
#let mark-acr-used(acr) = {
  _acronyms.update(data => {
    let ndata = data
    // Change both booleans to mark it used until reset AND in the overall document.
    ndata.at(acr).at(1) = true
    ndata.at(acr).at(2) = true
    ndata
  })
}

/// Display an acronym.
///
/// Expands the acronym if it is used for the first time.
///
/// - acr (string): Acronym key
/// - plural (bool): Plural version of the definition
/// - cap (bool): Capitalize the first letter if the definition is a string
#let acr(acr, plural: false, cap: false) = {
  // Test if the state for this acronym already exists and if the acronym was already used
  // to choose what to display.
  context {
    let acronyms = _acronyms.get()
    if acr in acronyms {
      let already-used = acronyms.at(acr).at(1)
      if already-used {
        let short = display-short(acr, plural: plural)
        // test if a clickable index is used in the document to add a link in the acronym
        if _acrostiche-index.final() {
          short = link(label("acrostiche-" + acr), short)
        }
        short
      } else {
        display-full(acr, plural: plural, cap: cap)
      }
    } else {
      panic("Cannot reference an undefined acronym: " + acr)
    }
  }
  mark-acr-used(acr)
}

// argument renamed acronym to differentiate with function acr

/// Display plural version of an acronym
#let acrpl(acronym) = acr(acronym, plural: true)
/// Display capitalized version of an acronym
#let acrcap(acronym) = acr(acronym, plural: false, cap: true)

// Intentionally display an acronym in its full form. Do not update state.

/// Display full version of an acronym
#let acrfull(acr) = display-full(acr, plural: false, cap: false)
/// Display full, plural version of an acronym
#let acrfullpl(acr) = display-full(acr, plural: true, cap: false)
/// Display full, capitalized version of an acronym
#let acrfullcap(acr) = display-full(acr, plural: false, cap: true)
/// Display full, plural, capitalized version of an acronym
#let acrfullplcap(acr) = display-full(acr, plural: true, cap: true)

/// Reset an acronym.
///
/// Resetting an acronym leads to its expansion on next use.
/// It will be included in the index even after resetting if it was used before.
///
/// - acr (string): acronym key
#let reset-acronym(acr) = {
  context {
    if not acr in _acronyms.get() {
      panic("Cannot reset an undefined acronym: " + acr)
    }
  }

  _acronyms.update(data => {
    let ndata = data
    ndata.at(acr).at(1) = false
    ndata
  })
}

/// Reset all acronyms.
///
/// This leads to their expansion on next usage.
/// Acronyms that have been reset will still be included in the index if they have been used before.
#let reset-all-acronyms() = {
  context {
    for acr in _acronyms.get().keys() {
      reset-acronym(acr)
    }
  }
}


//// Define shortcuts

#let acrf(acr) = acrfull(acr)
#let acrfpl(acr) = acrfullpl(acr)
#let racr(acr) = reset-acronym(acr)
#let raacr() = reset-all-acronyms()

// Define some functions as in the "acronym" package for LaTeX by Tobias Oetiker
// https://ctan.org/pkg/acronym

#let acresetall() = reset-all-acronyms()
#let ac = acr
#let acp(acro) = acr(acro, plural: true)
#let acl(acro) = display-def(acro, plural: false)
#let aclp(acro) = display-def(acro, plural: true)
#let acf(acro) = acrf(acro)
#let acfp(acro) = acrfpl(acro)
#let acs(acro) = display-short(acro, plural: false)
#let acsp(acro) = display-short(acro, plural: true)
#let acused(acr) = mark-acr-used(acr)


/// Print an index of all the acronyms and their definitions.
///
/// - depth (int): Relative nesting of the depth of the index header. See documentation of heading() for details.
/// - numbering (none, string, function): Numbering of the index header. See documentation of numbering() for details.
/// - outlined (bool): Whether to outline the header of the index section. See documentation of heading() for details.
/// - sorted (none, string): Sort the acronyms: "up" for alphabetical order,
///                          "down" for reverse alphabetical order,
///                          none for no sort (print in the order they are defined).
/// - case-sensitive (bool): Whehter to sort the acronyms case-sensitive. Only relevant if sorting is enabled.
/// - title (content): Title of the acronym index.
/// - delimiter (string): Delimiter between acronym and its definition.
/// - row-gutter: Row-gutter argument used to arrange the index in a grid. See documentation of grid() for details.
/// - used-only (bool): Only include the acronyms in the index that are used in the document.
/// - column-ratio (float): A positive float that indicates the width ratio of the first column (acronyms) with respect to the second (definitions).
/// - clickable (bool): Create a clickable link to the acronym definition in the first index if true.
#let print-index(
  depth: 1,
  numbering: none,
  outlined: false,
  sorted: none,
  case-sensitive: true,
  title: "Acronyms Index",
  delimiter: ":",
  row-gutter: 2pt,
  used-only: false,
  column-ratio: 0.25,
  clickable: true,
) = {
  // assert on input values to avoid cryptic error messages
  assert(
    sorted in (none, "up", "down"),
    message: "Sorted must be either none, \"up\" or \"down\"",
  )
  assert(
    0 <= column-ratio,
    message: "\"column-ratio\" must be a positive value.",
  )

  if title != "" {
    heading(depth: depth, numbering: numbering, outlined: outlined)[#title]
  }

  context {
    let acr-list = if used-only {
      // Select only acronyms where state is true at the end of the document.
      _acronyms
        .final()
        .pairs()
        .filter(((_, state)) => state.at(2))
        .map(((acr, _)) => acr)
    } else {
      _acronyms.get().keys()
    }

    // FEATURE: allow ordering by occurences position in the document. Not sure if possible yet.

    // order list depending on the sorted argument
    let sort-key = if case-sensitive { x => x } else { lower }
    if sorted == "down" {
      acr-list = acr-list.sorted(key: sort-key).rev()
    } else if sorted == "up" {
      acr-list = acr-list.sorted(key: sort-key)
    }

    // print the acronyms
    let col1 = column-ratio / (1 + column-ratio)
    let col2 = 1 - col1
    grid(
      columns: (col1 * 100%, col2 * 100%),
      row-gutter: row-gutter,
      ..for acr in acr-list {
        let short = [*#display-short(acr, plural: false)#delimiter*]
        // check if a label for a link should be created and if it is the first acronyms index,
        // since it can not create multiple labels
        if clickable and (not _acrostiche-index.get()) {
          short = [#short#label("acrostiche-" + acr)]
        }
        (short, display-def(acr, plural: false))
      }
    )
    if clickable {
      // set the index state to true to avoid subsequent clickable indexes to have labels
      // that would conflict with the ones just created
      _acrostiche-index.update(true)
    }
  }
}

