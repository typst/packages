#let linked-text(value, link-prefix: "", text: "") = {
  if value != "" {
    let display = if text != "" {
      text
    } else {
      value
    }

    if link-prefix != "" {
      link(link-prefix + value)[#display]
    } else {
      display
    }
  }
}

// Generic two by two component for resume
#let generic-two-by-two(
  top-left: "",
  top-right: "",
  bottom-left: "",
  bottom-right: "",
) = {
  [
    #top-left #h(1fr) #top-right \
    #bottom-left #h(1fr) #bottom-right
  ]
}

// Generic one by two component for resume
#let generic-one-by-two(
  left: "",
  right: "",
) = {
  [
    #left #h(1fr) #right
  ]
}

// Cannot just use normal --- ligature because ligatures are disabled for good reasons
#let dates-helper(
  start-date: "",
  end-date: "",
) = {
  if start-date == "" {
    end-date
  } else {
    start-date + " " + sym.dash.em + " " + end-date
  }
}