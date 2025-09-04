

#let not-none(el) = el != none
// #let strip-final(s, character) = if s.ends-with(character) { s.slice(0, -1) } else { s }

#let final-character(s) = {
  if type(s) == str and s.len() > 0 {
    return s.at(-1)
  } else if type(s) == text {
    return s.text //.at(-1)
  } else {
    return none
  }
}

#let fjoin(connector, format: it => it, add-space: true, finish-with-connector: false, ..xx) = {
  let xs = xx.pos()
  let parts = () // acts as a stringbuffer, so fjoin can run in linear time
  let empty = true
  let rightmost-nonempty-index = -1

  // find rightmost index of value that is not none
  for (i, x) in xs.enumerate() {
    if x != none {
      rightmost-nonempty-index = i
    }
  }
  
  // do the actual formatting
  for (i, x) in xs.enumerate() {
    if x != none {
      parts.push(x)
      empty = false

      if i < rightmost-nonempty-index {
        if final-character(x) != connector {
          parts.push(connector)
        }

        if add-space {
          parts.push(" ")
        }
      }
    }
  }

  if empty {
    none
  } else {
    if finish-with-connector {
      parts.push(connector)
    }
    let ret = parts.join("")
    format(ret)
  }
}

// !#fjoin(".", "foo.", "bar", "baz")!

#let commas(..x) = fjoin(",", ..x)
#let periods(..x) = fjoin(".", ..x)
#let spaces(..x) = fjoin("", ..x)
#let epsilons(..x) = fjoin("", ..x, add-space: false)
#let first-of(..x) = {
  let xs = x.pos()
  let index = xs.position(not-none)
  if index == none { none } else { xs.at(index) }
}

#let value = (
  "authors": "Author and Author",
  "url": "http://www.google.de",
  "title": "My paper",
  "booktitle": "Proceedings of XY",
  "year": "2025",
  "editor": "The Editor"
)

#let f(format-str) = {
  let re = regex("\{([^\}]+)\}")
  let error = "!!!FAIL!!!"
  let ret = format-str.replace(re, match => {
    let capt = match.captures.at(0)
    value.at(capt, default: error)
  })

  if ret.contains(error) { none } else { ret }
} 


#let formatted = periods(
  f("{authors}"),
  f("\"{title}\""),
  commas(spaces("In:", f("_{booktitle}_")), f("{editor}, eds.")),
  commas(f("{series}"), f("{volume}")),
  commas(f("{publisher}"), f("{location}"), f("{year}"))
)

#eval(formatted, mode: "markup")

    /*
      periods(
        [#authors],
        [_#url-title(reference)_],
        commas(
          [#howpublished}, #year]
        )
      )

      periods(
        #authors,
        ["#title"],
        spaces([In:], [_#booktitle_], [(#editor, eds.)]),
        commas(#series, #volume),
        commas(#publisher, #location, #year)
      )

      - need to be able to call Typst functions
      - drop all elements where any part cannot be evaluated (e.g. missing #editor)
      - make all fields available as variables
      - aggregate through spaces, commas, periods joiners
      - joiners should take care of final dots and such
      - pybtex has "first_of" to do authors and editors
    */