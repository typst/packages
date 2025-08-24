#let prefix = "acronym-state-"
#let acros = state("acronyms", none)

#let init-acronyms(acronyms) = {
  acros.update(acronyms)
}

// Check if an acronym exists
#let is-valid(acr) = {
  acros.display(acronyms => {
    if acr not in acronyms {
      panic(acr + " is not a key in the acronyms dictionary.")
      return false
    }
  })
  return true
}

// Display acronym as clickable link
#let display-link(acr, text) = {
  if is-valid(acr) {
    link(label("acronym-" + acr), text)
  }
}

// Display acronym
#let display(acr, text, link: true) = {
  if link {
    display-link(acr, text)
  } else {
    text
  }
}

// Display acronym in short form
#let acrs(acr, plural: false, link: true) = {
  if plural {
    display(acr, acr + "s", link: link)
  } else {
    display(acr, acr, link: link)
  }
}
// Display acronym in short plural form
#let acrspl(acr, link: true) = {
  acrs(acr, plural: true, link: link)
}

// Display acronym in long form
#let acrl(acr, plural: false, link: true) = {
  acros.display(acronyms => {
    if is-valid(acr) {
      let defs = acronyms.at(acr)
      if type(defs) == "string" {
        if plural {
          display(acr, defs + "s", link: link)
        } else {
          display(acr, defs, link: link)
        }
      } else if type(defs) == "array" {
        if defs.len() == 0 {
          panic("No definitions found for acronym " + acr + ". Make sure it is defined in the dictionary passed to #init-acronyms(dict)")
        }
        if plural {
          if defs.len() == 1 {
            display(acr, defs.at(0) + "s", link: link)
          } else if defs.len() == 2 {
            display(acr, defs.at(1), link: link)
          } else {
            panic("Definitions should be arrays of one or two strings. Definition of " + acr + " is: " + type(defs))
          }
        } else {
          display(acr, defs.at(0), link: link)
        }
      } else {
        panic("Definitions should be arrays of one or two strings. Definition of " + acr + " is: " + type(defs))
      }
    }
  })
}
// Display acronym in long plural form
#let acrlpl(acr, link: true) = {
  acrl(acr, plural: true, link: link)
}

// Display acronym for the first time
#let acrf(acr, plural: false, link: true) = {
  if plural {
    display(acr, [#acrlpl(acr) (#acr\s)], link: link)
  } else {
    display(acr, [#acrl(acr) (#acr)], link: link)
  }
  state(prefix + acr, false).update(true)
}
// Display acronym in plural form for the first time
#let acrfpl(acr, link: true) = {
  acrf(acr, plural: true, link: link)
}

// Display acronym. Expands it if used for the first time
#let acr(acr, plural: false, link: true) = {
  state(prefix + acr, false).display(seen => {
    if seen {
      if plural {
        acrspl(acr, link: link)
      } else {
        acrs(acr, link: link)
      }
    } else {
      if plural {
        acrfpl(acr, link: link)
      } else {
        acrf(acr, link: link)
      }
    }
  })
}

// Display acronym in the plural form. Expands it if used for the first time.
#let acrpl(acronym, link: true) = {
  acr(acronym, plural: true, link: link)
}

// Print an index of all the acronyms and their definitions.
#let print-acronyms(language, acronym-spacing) = {
  heading(level: 1, outlined: false, numbering: none)[#if (language == "de") {
      [Abkürzungsverzeichnis]
    } else {
      [List of Acronyms]
    }]

  acros.display(acronyms => {
    let acronym-keys = acronyms.keys()

    let max-width = 0pt
    for acr in acronym-keys {
      let result = measure(acr).width

      if (result > max-width) {
        max-width = result
      }
    }

    let acr-list = acronym-keys.sorted()

    for acr in acr-list {
      grid(
        columns: (max-width + 0.5em, auto),
        gutter: acronym-spacing,
        [*#acr#label("acronym-" + acr)*], [#acrl(acr, link: false)],
      )
    }
  })
}