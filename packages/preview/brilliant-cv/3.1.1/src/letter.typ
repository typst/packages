/*
* Functions for the CV template
*/

#import "./utils/styles.typ": _set-accent-color, _awesome-colors

#let _letter-header(
  sender-address: "Your Address Here",
  recipient-name: "Company Name Here",
  recipient-address: "Company Address Here",
  date: "Today's Date",
  subject: "Subject: Hey!",
  metadata: metadata,
  // New parameter names (recommended)
  awesome-colors: none,
  // Old parameter names (deprecated, for backward compatibility)
  awesomeColors: _awesome-colors,
) = {
  // Backward compatibility logic (remove this block when deprecating)
  let awesome-colors = if awesome-colors != none { 
    awesome-colors 
  } else { 
    // TODO: Add deprecation warning in future version
    awesomeColors 
  }

  let sender-name = metadata.personal.first_name + " " + metadata.personal.last_name

  let accent-color = _set-accent-color(awesome-colors, metadata)

  let letter-header-name-style(str) = {
    text(fill: accent-color, weight: "bold", str)
  }
  let letter-header-address-style(str) = {
    text(fill: gray, size: 0.9em, smallcaps(str))
  }
  let letter-date-style(str) = {
    text(size: 0.9em, style: "italic", str)
  }
  let letter-subject-style(str) = {
    text(fill: accent-color, weight: "bold", underline(str))
  }

  letter-header-name-style(sender-name)
  v(1pt)
  letter-header-address-style(sender-address)
  v(1pt)
  align(right, letter-header-name-style(recipient-name))
  v(1pt)
  align(right, letter-header-address-style(recipient-address))
  v(1pt)
  letter-date-style(date)
  v(1pt)
  letter-subject-style(subject)
  linebreak()
  linebreak()
}

#let _letter-signature(img) = {
  set image(width: 25%)
  linebreak()
  place(right, dx: -5%, dy: 0%, img)
}

#let _letter-footer(metadata) = {
  // Parameters
  let sender-name = metadata.personal.first_name + " " + metadata.personal.last_name
  let letter-footer-text = metadata.lang.at(metadata.language).letter_footer
  let display-footer = metadata.layout.at("footer", default: {}).at("display_footer", default: true)

  if not display-footer {
    return none
  }

  // Styles
  let footer-style(str) = {
    text(size: 8pt, fill: rgb("#999999"), smallcaps(str))
  }

  table(
    columns: (1fr, auto),
    inset: 0pt,
    stroke: none,
    footer-style([#sender-name]),
    footer-style(letter-footer-text),
  )
}
