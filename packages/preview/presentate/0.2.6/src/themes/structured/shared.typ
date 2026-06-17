#import "../../components/components.typ": is-role, render-transition
#import "../../presentate.typ" as p

/// Applies heading numbering rules to the document.
/// Usage: show: apply-heading-numbering.with(mapping, show-heading-numbering, numbering-format)
#let apply-heading-numbering(mapping, show-heading-numbering, numbering-format, doc) = {
  if show-heading-numbering {
    if numbering-format != auto {
      set heading(outlined: true, numbering: (..nums) => {
        let lvl = nums.pos().len()
        if lvl in mapping.values() {
          numbering(numbering-format, ..nums)
        }
      })
      doc
    } else {
      set heading(outlined: true)
      doc
    }
  } else {
    set heading(numbering: none)
    doc
  }
}

/// Applies the unified transition rule to headings.
/// Usage: show heading: apply-transition-rule.with(mapping, transitions, show-all-sections-in-transition, on-part-change, on-section-change, on-subsection-change)
#let apply-transition-rule(
  mapping,
  transitions,
  show-all-sections-in-transition,
  on-part-change,
  on-section-change,
  on-subsection-change,
  h,
) = {
  let hook = none
  if is-role(mapping, h.level, "part") { hook = on-part-change }
  else if is-role(mapping, h.level, "section") { hook = on-section-change }
  else if is-role(mapping, h.level, "subsection") { hook = on-subsection-change }

  if hook != none {
    hook(h)
  } else {
    let final-trans = transitions
    if show-all-sections-in-transition {
      let all-vis = (part: "all", section: "all", subsection: "all")
      let override = (parts: (visibility: all-vis), sections: (visibility: all-vis), subsections: (visibility: all-vis))
      if type(transitions) == dictionary {
        final-trans = p.utils.merge-dicts(base: transitions, override)
      } else {
        final-trans = override
      }
    }
    render-transition(h, transitions: final-trans, use-short-title: false, max-length: none)
  }
}
