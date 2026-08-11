#import "../i18n.typ"
#import "util.typ": extract-modifiers-from-end

// https://forum.typst.app/t/how-can-i-modify-the-reference-format-of-equations/1118/8
// Use number from equation, thus automatically adding parentheses
// TODO: because of this, references to math equations cannot be styled anymore with
// `#show ref: set text(fill: red)`, but only with `#show link: ...`
#let math-ref-to-eq-number(r) = {
  let el = r.element
  if el != none and el.func() == math.equation {
    // Override equation references
    // Determine used supplement
    let supp = if r.supplement == auto {
      // Use automatic supplement, localized by Typst to correct language etc.
      el.supplement
    } else if (r.supplement == ""
               or type(r.supplement) == content
               and r.supplement.fields() == (children: ())) {
      // Translate empty supplement (string or content) to #none
      // For example, @eq:example[] will not introduce an extra space.
      none
    } else {
      // Use supplied content
      r.supplement
    }
    // The actual equation reference, being [#supp~#num] or [#num]
    link(el.location(), {
          supp
          if supp != none { sym.space.nobreak }
          // Use the numbering scheme from the equation. Can be changed.
          numbering(el.numbering, ..counter(math.equation).at(el.location()))
        })
  } else {
    r
  }
}

// See also heading-ref
// These functions take the element being referenced, like normal, but they
// also accept more contextual arguments. They are contextual since they don't
// depend on the element being referenced, but on the place where this is called.
#let annex-heading(el, capitalize: false, .._args) = {
  if capitalize { i18n.ref-Annex } else { i18n.ref-annex }
}
#let body-heading(el, capitalize: false, .._args) = {
  if el.level == 1 {
    if capitalize { i18n.ref-Chapter } else { i18n.ref-chapter }
  } else {
    // Call everything else a section
    if capitalize { i18n.ref-Section } else { i18n.ref-section }
  }
}
// Usage: `#set heading(supplement: `body-heading`)`
// Only when combined with heading-ref, of course
#let default-contextual-ref-supplement-handlers(..args) = (
  annex-heading: annex-heading.with(..args),
  body-heading: body-heading.with(..args),
)

// Implement correct referencing to chapters & sections in all *languages*.
// - Depends on where it is used (context) for the *language* and *capitalization*.
//   Only use a capital when asked (see also i18n.typ)
// - Depends on the element being referenced for the correct *(reference) term*
//   (for example 'Annex A' instead of 'Chapter A', depending on:
//   the *level* AND the *supplement* of the referenced element/heading)
/// `#show ref: heading-ref` and `#set heading(supplement: `body-heading`)`
/// Usage in text: `@chap:literatuur:cap` to start the reference with a capital
#let heading-ref(
  r,
  /// Incidental complexity due to Typst limitations. Normally, we would like to
  /// delegate directly to supplement function of the referenced element. This
  /// workaround is needed, because el.supplement is always `content`.
  /// If it is raw content, we assume it's a key from this handler dict.
  /// -> dict
  contextual-supplement-handlers: default-contextual-ref-supplement-handlers(),
  /// The dict of possible modifiers, with a mapping to argument-names and values.
  /// These arguments will be passed to the contextual supplement handlers.
  possible-modifiers: (cap: (capitalize: true), nocap: (capitalize: false)),
  // Future TODO?: pass default arguments to extract-modifiers-from-end
) = {
  // Collect the following modifiers (trick from Glossy, but extended)
  let (key, arg-dict) = extract-modifiers-from-end(str(r.target), possible-modifiers: possible-modifiers)
  let el = if arg-dict.len() > 0 {
    assert(r.supplement == auto, message: "Found modifiers, but the supplement is not auto.")
    assert(r.form == "normal", message: "Found modifiers, but the form is not \"normal\".")
    let a = query(label(key))
    assert(a.len() == 1, message: "The length of array " + repr(a)
                                  + " is not exactly 1 for key " + key + ".")
    a.at(0)
  } else {
    // key hasn't changed, thus element should be found by Typst itself
    r.element
  }
  if el != none and el.func() == heading  and r.supplement == auto and r.form == "normal" {
    let preapplied-supplement = if (type(el.supplement) == content
                                    and el.supplement.func() == raw) {
      // The final supplement function depends on the referenced element
      // The real work is done by delegating (pre-applying the contextual arguments)
      // Sadly, the supplement function cannot be extracted, since it is already applied
      // Thus, an extra indirection needs to be followed with the handlers
      if el.supplement.text not in contextual-supplement-handlers {
        panic("You specified a raw supplement in a statement like e.g. #set heading(supplement: `"
               + el.supplement.text + "`) and use the heading-ref function "
               + "to produce nice references. The raw string " + repr(el.supplement.text)
               + " should be part of the contextual supplement handlers, but it's not. "
               + "The handlers are: " + repr(contextual-supplement-handlers))
      }
      contextual-supplement-handlers.at(el.supplement.text).with(..arg-dict)
    } else {
      el.supplement
    }
    ref(label(key), supplement: preapplied-supplement)
  } else {
    r
  }
}

// When referencing an unnumbered subheading, find the closest numbered heading above.
// Write a reference to the overarching heading, but link to the original subheading.
// TODO: make shorter. Reuses logic from math.equation.
// TODO: this might also be solved by a heading.numbering function which takes
// context into account: don't return a number for the heading, but do for references.
#let unnumbered-subheading-ref(
  r,
  behaviour: "panic", // TODO: refactor when needed...
) = {
  let el = r.element
  if (el != none
      and el.func() == heading
      and el.numbering != none) {
    let nums = counter(heading).at(el.location())

    if std.numbering(el.numbering, ..nums) != none {
      r
    } else if behaviour == "ref-superheading" {
      // Find the first numbered superheading (<-> subheading)
      while std.numbering(el.numbering, ..nums) == none {
        let _ = nums.remove(-1)
      }

      // Determine used supplement - https://forum.typst.app/t/1118/9
      let supp = if r.supplement == auto {
        // Use automatic supplement, localized by Typst to correct language etc.
        el.supplement
      } else if (r.supplement == ""
                 or type(r.supplement) == content
                 and r.supplement.fields() == (children: ())) {
        // Translate empty supplement (string or content) to #none
        // For example, @chap:example[] will not introduce an extra space.
        none
      } else if type(r.supplement) == content {
        // Use supplied content OR function
        r.supplement
      } else if type(r.supplement) == function {
        let f = r.supplement
        f(el)
      } else { panic("Unrecognized supplement, file a bug.") }

      // The actual reference, being [#supp~#num] or [#num]
      link(el.location(), {
        supp
        if supp != none { sym.space.nobreak }
        std.numbering(el.numbering, ..nums)
      })
    } else if behaviour == "panic" {
      panic("cannot reference heading without numbering. Although a numbering "
            + "function is supplied to " + repr(el) + ", it returns none when "
            + "applied to it's heading counter: " + repr(nums))
    } else {
      panic("The numbering function of " + repr(el) +
            " returns none when applied it's heading counter: " + repr(nums) +
            " AND the behaviour is not recognized...")
    }
  } else {
    r
  }
}
