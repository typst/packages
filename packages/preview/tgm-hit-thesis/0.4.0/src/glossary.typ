#import "libs.typ": glossarium
#import glossarium: make-glossary, gls, agls, glspl

#let _glossary_entries = state("thesis-glossary-entries")

#let register-glossary(..entries) = {
  assert.eq(entries.named(), (:), message: "no named arguments allowed")
  let entries = entries.pos()
  glossarium.register-glossary(entries)
  _glossary_entries.update(entries)
}

/// Stores a glossary entry for this thesis. One call to this function is equivalent to one array
/// entry in Glossarium's ```typc print-glossary()```'s main parameter.
///
/// -> content
#let glossary-entry(
  /// The key with which the glossary entry can be referenced; must be unique.
  /// -> string
  key,
  /// Mandatory; the short form of the entry shown after the term has been first defined.
  /// -> string
  short: none,
  /// The long form of the term, displayed in the glossary and on the first citation of the term.
  /// -> string | content
  long: none,
  /// The description of the term.
  /// -> string | content
  description: none,
  /// The pluralized short form of the term.
  /// -> string | content
  plural: none,
  /// The pluralized long form of the term.
  /// -> string | content
  longplural: none,
  /// The group the term belongs to. The terms are displayed by groups in the glossary.
  /// -> string
  group: none,
) = {
  assert(short != none or long != none, message: "short or long form of glossary-entry is mandatory")

  let entry = (
    key: key,
    short: short,
    long: long,
    description: description,
    plural: plural,
    longplural: longplural,
    group: group,
  )
  let entry = for (k, v) in entry {
    if v != none {
      ((k): v)
    }
  }

  entry
}

/// Displays a glossary of the entries added via @@glossary-entry().
///
/// -> content
#let print-glossary(
  /// A (level 1) heading that titles this glossary. If the glossary is empty, the title is not shown.
  /// -> content
  title: none,
  /// Any extra parameters to the glossarium function of the same name.
  /// -> arguments
  ..args,
) = context {
  let entries = _glossary_entries.get()

  if glossarium.there-are-refs() or args.named().at("show-all", default: false) {
    title
  }

  glossarium.print-glossary(entries, ..args)
}
