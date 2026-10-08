// The words abntly writes: the running header, the designative words of the illustrations it adds, what goes under
// an illustration, the table that goes on over pages, the titles of the outline and of the list of references, the
// names of a reference with its name (`auto-ref`). They come in the language of the text at the point where they are
// written (`text.lang`, so a passage in English inside a work in Portuguese takes English ones), from src/lang.toml,
// by the package linguify with a database of its own; an unknown language falls back to Portuguese. The `names` of
// the main function, built with `config-names`, replace any of them in any language: that is how a work is written
// in a language the package does not have.

#import "@preview/linguify:0.5.0": linguify-raw

#let database = toml("lang.toml")
// the keys of the words, those of the Portuguese table
#let keys = database.lang.pt.keys()
// the words the author replaced, which the main function sets at the start of the work
#let names = state("abntly-names", (:))

/// Defines the terms of the package to replace, for the `names` parameter of `abntly`. Example:
/// `config-names(chapter: "Unidad", source: "Fuente")`.
///
/// The keys are those of the file `src/lang.toml`: chapter, part, algorithm, frame, source, legend, note, own-work,
/// continues, continuation, conclusion, contents, references. The names used by `auto-ref` can be replaced too:
/// section, subsection, subsubsection, appendix-name, annex-name, equation, page.
///
/// - ..args (arguments): Terms to replace, by key. They accept text or content.
/// -> dictionary
#let config-names(..args) = {
  assert(args.pos().len() == 0,
    message: "config-names: takes only the words to replace, by key; got " + repr(args.pos()))
  let given = args.named()
  for key in given.keys() {
    assert(key in keys, message: "config-names: unknown word " + repr(key) + "; the words are " + keys.join(", "))
  }
  given
}

// a word, as the text it is (inside a `context`): the author's, or the one of the language of the text
#let word-raw(key) = {
  let given = names.get()
  if key in given { given.at(key) } else { linguify-raw(key, from: database) }
}

// a word, as content that reads the language where it lands
#let word(key) = context word-raw(key)
