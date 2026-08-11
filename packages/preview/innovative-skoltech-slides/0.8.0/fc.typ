/**
 * fc.typ
 *
 * Font config (FC) is a set of routines to adjust font settings.
 */

// Lists of acceptable fonts.
#let font-family = ()
#let font-family-sans = ("Futura PT", "Jost*", "Jost* Semi")
#let font-family-mono = ("Latin Modern Mono", "New Computer Modern Mono")

#let font = (
  Large: 120pt,
  large: 45pt,
  normal: 24pt,
  small: 22pt,
  footnote: 20pt,
  script: 16pt,
)

/**
 * Default font config (FC).
 */
#let font-config-default() = (
  family: (serif: font-family,
           sans: font-family-sans,
           mono: font-family-mono),
  size: font,
)

/**
 * Ensure font config is valid.
 */
#let font-config-ensure(fc) = {
  if fc == none {
    return font-config-default()
  } else if type(fc) == array and fc.len() != 2 {
    return font-config-default()
  } else if type(fc) == dictionary and fc.len() != 2 {
    return font-config-default()
  } else {
    return fc
  }
}

/**
 * Merge auxiliary options to font config structure.
 */
#let font-config-merge(fc, aux) = {
  if "font-family" in aux {
    for kind in ("serif", "sans", "mono") {
      if kind in aux.font-family {
        fc.family.insert(kind, aux.font-family.at(kind))
      }
    }
  }

  if "font-size" in aux {
    // Large, footnote, large, and so on.
    for size in font.keys() {
      if size in aux.font-family {
        fc.family.insert(size, aux.font-family.at(size))
      }
    }
  }

  return fc
}
