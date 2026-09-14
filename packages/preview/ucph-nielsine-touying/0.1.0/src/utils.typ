#import "@preview/touying:0.6.1" as ty

// Helper function to get current section number
#let get-current-section() = {
  context {
    let current-page = here().page()
    let sections = query(heading.where(level: 1))

    if sections.len() == 0 {
      return 0
    }

    let current-section = 0
    for (i, section) in sections.enumerate() {
      if section.location().page() <= current-page {
        current-section = i + 1
      } else {
        break
      }
    }
    current-section
  }
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
          text(weight: "bold", fill: self.colors.primary, section.body)
        } else {
          text(fill: self.colors.neutral-darkest.lighten(30%), section.body)
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
