#let toggle(
  title,
  open: true,
  heading: 0,
  indentation: true,
  body
) = {

  // Icon
  let icon-open = "▼"
  let icon-closed = "▶"
  let icon = if open { icon-open } else { icon-closed }

  // Identation 
  let default-identation = {
    if heading == 1 { 1.4em } 
    else if heading == 2 { 1.4em }
    else if heading == 3 { 1.4em }
    else if heading == 0 { 1.4em }
    else { 1.4em }
  }
  let child-indent = {
    if indentation {
      default-identation
    } else {
      0pt // No indentation
    }
  }
  
  // Layout
  let icon-size = {
    if heading == 0 { 0.6em } 
    else if heading == 3 { 0.7em }
    else if heading == 2 { 0.8em }
    else if heading == 1 { 0.85em }
    else { 0.8em }
  }
  let icon-title-space = {
    if heading == 0 { 0.3em } 
    else if heading == 3 { 0.4em }
    else if heading == 2 { 0.4em }
    else if heading == 1 { 0.5em }
    else { 0.1em }
  }
  let icon-vertical-offset = {
    if open {
      if heading == 0 { 1.0em } 
      else if heading == 3 { 1.00em }
      else if heading == 2 { 0.9em }
      else if heading == 1 { 0.92em }
      else { 0.65em }
    } else {
      if heading == 0 { 1.0em } 
      else if heading == 3 { 1.0em }
      else if heading == 2 { 0.9em }
      else if heading == 1 { 0.85em }
      else { 0.65em }
    }
  }
  let heading-size = {
    if heading == 1 { 1.2em }
    else if heading == 2 { 1.14em }
    else if heading == 3 { 1.05em }
    else { 1em }
  }
  let title-weight = {
    if heading == 1 { 600 }
    else if heading == 2 { 600 }
    else if heading == 3 { 600 }
    else if heading == 0 { 400 }
    else { 400 }
  }
    
  // Toggle icon
  let toggle-icon = box(
    width: 0.6em,
    height: 0.75em,
    baseline: -0.9em + icon-vertical-offset,
    inset: (right: 1.5em, y: 0em),
    fill: none,
    text(size: icon-size, weight: "medium", icon)
  )
  
  // Title
  let title-content = {
    par[
        // ▶ This is a toggle
        #toggle-icon // Icon ('▶')
        #h(icon-title-space) // Horizontal space (' ')
        #text(
          size: heading-size, 
          weight: title-weight, 
          title
        ) // Title ('This is a toggle')
    ]
  }
  
  // Children Content (Body)
  let body-content = { 
    if open {
      block(
        above: 1em, // 1 par 
        below: 1em,
        inset: (left: child-indent, x: 0.5em),
        text(
          size: 1em, 
          weight: 400, 
          body
        ) // body (with default font size and weight)
        
      )
    } else {
      [] // If 'closed' -> Show nothing
    }
  }
  
  title-content + body-content
}
