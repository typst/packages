#import "spacing.typ": spacing-state

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

// Two-row header block (title/dates over company/location, etc.)
#let generic-two-by-two(
  top-left: "",
  top-right: "",
  bottom-left: "",
  bottom-right: "",
  spacing: auto,
) = context {
  let s = spacing-state.get()
  let body = [
    #text(size: 1em + s.row-delta)[#top-left #h(1fr) #top-right] \
    #text(size: 1em - s.row-delta)[#bottom-left #h(1fr) #bottom-right]
  ]
  if spacing == auto {
    block(width: 100%, above: s.gap, below: s.row, body)
  } else {
    block(width: 100%, spacing: spacing, body)
  }
}

// Single-row header block (project name/links, activity/dates, etc.)
#let generic-one-by-two(
  left: "",
  right: "",
  spacing: auto,
) = context {
  let s = spacing-state.get()
  let body = [
    #left #h(1fr) #right
  ]
  if spacing == auto {
    block(width: 100%, above: s.gap, below: s.row, body)
  } else {
    block(width: 100%, spacing: spacing, body)
  }
}

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
