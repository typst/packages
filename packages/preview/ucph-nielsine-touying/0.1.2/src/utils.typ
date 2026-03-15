#import "@preview/touying:0.6.1" as ty

// Helper function to get current section number
#let get-current-section() = {
  let current = ty.utils.current-heading(level: 1)

  if current == none {
    return 0
  }

  // Find its index in the list of sections
  let sections = query(heading.where(level: 1))
  for (i, section) in sections.enumerate() {
    if section == current {
      return i + 1
    }
  }

  0
}

// Add this helper function to generate section links
#let section-links(self) = {
  context {
    let sections = query(heading.where(level: 1))
    let current-section = get-current-section()

    if sections.len() == 0 {
      return []
    }

    sections
      .enumerate()
      .map(((i, section)) => {
        let is-current = (i + 1) == current-section
        let link-text = if is-current {
          text(weight: "bold", fill: self.colors.neutral-darkest.lighten(45%), section.body, size: 12pt)
        } else {
          text(fill: self.colors.neutral-darkest.lighten(30%), section.body, size: 12pt)
        }

        // Create a clickable link to the section
        link(section.location(), link-text)
      })
      .join(text(fill: self.colors.neutral-darkest.lighten(50%), " | "))
  }
}

// Slide counter
#let slide-counter-label(self) = context {
  let current = int(ty.utils.slide-counter.display())
  let last = int(ty.utils.last-slide-counter.display())

  // This works because Touying freezes the slide counter in the appendix
  if current > last {
    text(self.store.footer-appendix-label, style: "italic") + str(current)
  } else {
    ty.utils.slide-counter.display() + " / " + ty.utils.last-slide-number
  }
}

/// Alert content with a primary or self-specified color.
///
/// Example: `config-methods(alert: ty.utils.alert-with-primary-color)`
///
/// -> content
#let alert-bold-color(self: none, body) = text(fill: self.colors.bold-color, body)
