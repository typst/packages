
#let _equation = $1$.func();
#let _sequence = [].func();

/// Collect text content of element recursively into a single string
/// https://discord.com/channels/1054443721975922748/1088371919725793360/1138586827708702810
/// https://github.com/Myriad-Dreamin/shiroa/issues/55
#let plain-text_(it) = {
  if type(it) == str {
    return it
  } else if it == [ ] {
    return " "
  } else if it == none {
    return ""
  } else if it.has("child") {
    return plain-text_(it.child)
  } else if it.has("body") {
    return plain-text_(it.body)
  } else if it.has("children") {
    return it.children.map(plain-text_).join()
  } else if it.has("text") {
    return it.text
  }

  let f = it.func()
  if f == smartquote {
    if it.double {
      "\""
    } else {
      "'"
    }
  } else if f == parbreak {
    "\n\n"
  } else if f == linebreak {
    "\n"
  } else if f == image {
    it.alt + ""
  } else {
    ""
  }
}

#let plain-text(it) = {
  let res = plain-text_(it)
  if res == none {
    ""
  } else {
    res
  }
}
