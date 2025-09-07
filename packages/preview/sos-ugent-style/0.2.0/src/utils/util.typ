#import "/src/i18n.typ"

// TODO: upstream to Glossy
/// Extract all specified modifiers from the given string.
/// For example used to process:     @chap:literature:cap
///   Typst ref, not part of input __^                ^^^__ modifier
///                                       ^__________^__ separator
///                                   ^^^^^^^^^^^^^^^__ extracted key, including separator
/// Modifiers are extracted case-insensitive (future TODO: maybe case-sensitive option?)
/// -> dict (key: str, arg-dict: dict)
#let extract-modifiers-from-end(
  /// -> str
  key-with-mods,
  /// Mapping from possible modifiers to argument dicts.
  /// Modifiers NEED to be lowercase.
  /// example: (cap: (capitalize: true), nocap: (capitalize: false))
  /// -> dict
  possible-modifiers: (:),
  /// How the modifiers are delineated. Used to split & join.
  /// str | regex
  separator: ":",
  // future TODO(?): add modifier-defaults, which will return the default value
  // of an argument when no modifier with this argument is found.
) = {
  // Collect the following modifiers (trick from Glossy, but extended)
  // Dict of all arguments which will be collected. For each argument, there
  // is a dict mapping the modifier string to the supplied argument. If not found: auto.
  let key_items = key-with-mods.split(separator)
  // Try to find valid modifiers from the end. When not a valid modifier,
  // we assume everything left is part of the key.
  // Return (leftover_key array, argument dict)
  let (leftover_key_items, arg-dict) = key_items
    .rev()
    .fold(
      ((), (:)),
      (accum, item) => {
        if accum.at(0) == () and lower(item) in possible-modifiers {
          let arg = possible-modifiers.at(lower(item))
          let arg-names = arg.keys()
          for arg-name in arg-names {
            if arg-name in accum.at(1) {
              panic("You tried to combine multiple modifiers for the same argument name "
                    + repr(arg-name) + ". Do no combine: "
                    + repr(possible-modifiers.pairs()
                                             .filter(((_, d)) => arg-name in d)
                                             .map(i => i.first())))
            }
          }
          ((), accum.at(1) + arg)
        } else {
          ((item,) + accum.at(0), accum.at(1))
        }
      }
    )
  let key = leftover_key_items.join(separator) // restore original key without modifiers
  // TODO: should we query to check key validity?
  assert((key-with-mods == key and arg-dict == (:))
         or arg-dict.len() > 0,
         message: "The function extract-modifiers misbehaved, file a bug.")
  (key: key, arg-dict: arg-dict)
}


// ugent-dissertation
// Implemented as a literal dict to maximize insight into the returned result.
// This also serves as the validator function of a 'dissertation-info' dict with
// only the pure information.
#let dissertation-info-to-full-sentences(
  title: none,
  subtitle: none,
  wordcount: 0,
  author: none,
  student-number: none,
  /// Array of supervisors
  supervisors: none,
  commissaris: none,
  submitted-for: none,
  academic-year: none,
) = (
  title: title,
  subtitle: subtitle,
  wordcount: i18n.word-count + ": " + wordcount,
  author: author,
  student-number: i18n.student-number + ": " + student-number,
  supervisors: {
    if type(supervisors) == array and supervisors.len() > 1 {
      i18n.supervisors
    } else {
      i18n.supervisor
    }
    ": "
    if type(supervisors) == array {
      supervisors.join(", ")
    } else {
      supervisors
    }
  },
  commissaris: if commissaris != none {
    i18n.commissaris + ": " + commissaris
  },
  submitted-for: submitted-for,
  academic-year: i18n.academic-year + " " + academic-year,
)
