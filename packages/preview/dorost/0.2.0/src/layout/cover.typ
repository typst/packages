#import "../config.typ": default-colors, default-text

// Content only: callers choose page boundaries and supply every label/identity.
#let cover-page(title, subtitle: none, author: none, date: none, logo: none, details: none) = {
  let slots = ()
  if logo != none { slots.push(logo) }
  slots.push(text(size: 2em, weight: "bold", title))
  if subtitle != none { slots.push(text(size: 1.2em, fill: default-colors.muted, subtitle)) }
  if author != none { slots.push(author) }
  if date != none { slots.push(date) }
  if details != none { slots.push(details) }
  block(width: 100%, stack(dir: ttb, spacing: default-text.paragraph-spacing, ..slots))
}
