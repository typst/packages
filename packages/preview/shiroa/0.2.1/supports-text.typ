
#let _styled = smallcaps("").func();
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
  }
  let f = it.func()
  if f == _styled {
    plain-text_(it.child)
  } else if f == _equation {
    plain-text_(it.body)
  } else if f == text or f == raw {
    it.text
  } else if f == smartquote {
    if it.double {
      "\""
    } else {
      "'"
    }
  } else if f == _sequence {
    it.children.map(plain-text_).filter(t => type(t) == str).join()
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
