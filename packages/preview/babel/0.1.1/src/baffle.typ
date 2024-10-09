#import "@preview/mantys:0.1.4": *
#import "@preview/suiji:0.3.0"
#import "alphabets.typ": alphabets

#let punctuation = ("\`\-=~!@#$%^&*()_+\[\]\\\\;':\",./<>?‘’“”·¿¡؟،।॥⟨⟩‽⸘")

#let letter-counter = counter("letter-counter")

#let to-string(content) = {
  if type(content) == "string" {
    content
  }
  else if content.has("text") and type(content.text) == "string" {
    content.text
  }
  else if content.has("children") {
    content.children.map(to-string).join("")
  }
  else if content.has("body") {
    to-string(content.body)
  }
  else if content == [ ] {
    " "
  }
}

#let baffle-letter(
  input,
  alphabet: "latin-bicameral",
  case-sensitive: true,
  punctuate: true,
  punctuation: punctuation,
  input-word-dividers: (" ",),
  output-word-divider: " ",
  seed: 0,
  as-string: false
) = {
  let letter = to-string(input)
  if letter in input-word-dividers {
    return output-word-divider
  }
  if letter in punctuation and punctuate {
    return letter
  }
  let index = suiji.integers(
    if as-string {
      suiji.gen-rng(seed)
    }
    else {
      suiji.gen-rng(letter-counter.get().first())
    },
    low: 0,
    high: alphabet.at("lowercase").len()
  ).at(1)
  if case-sensitive {
    if letter == lower(letter) { // if the letter is lowercase
      alphabet.at("lowercase").at(index)
    }
    else {
      if not alphabet.keys().contains("uppercase") { // if `case-sensitive` is true but the alphabet doesn’t support letter case
        alphabet.at("lowercase").at(index)
      }
      else {
        alphabet.at("uppercase").at(index)
      }
    }
  }
  else {
    return alphabet.at("lowercase").at(index)
  }
}

/// #alert(color: gray)[
///   ⚠ A technical note: the default of #arg("punctuation") is #value("\"" + punctuation + "\"") and that of #arg("input-word-dividers") is #value((" ",)) (that is, an array containing only a space, `U+0020`); for reasons that have to do with #package[Mantys] or #package[Tidy] the default values are displayed wrongly in this document as #value("punctuation") and #value("(\" \",)") respectively.
/// ]
///
/// Replaces #arg("input") with random characters chosen from a given #arg("alphabet"). Note that depending on the #arg("alphabet") the output might be longer then the input (in case a single letter is replace by a digraph, for example).
///
/// - input (content):
/// The text to be redacted.
/// #example(```
/// #baffle[A _confidential_ text]
/// ```)
///
/// - alphabet (str,dict):
/// Either a slug (a string identifier) referring to the alphabet to be used for the output (options are listed in @alphabets) or a dictionary describing the alphabet, with the following fields:
/// / `lowercase` #strong(delta: -300)[_(required)_]:  an array of strings (each representing one character), from which a random string is drawn for each character in the original text. If the target script is bicameral, use this field for lowercase letters and the `uppercase` field for uppercase ones; otherwise, use only this field.
/// / `uppercase` #strong(delta: -300)[_(optional)_]: an array of the same size as `lowercase`; if the input is bicameral, uppercase letters in the input are matched by uppercase letters from the alphabet.
/// / `font` #strong(delta: -300)[_(optional)_]: the font to typeset the output in.
/// #example(```
/// #baffle(alphabet: "sitelen-pona")[top secret]\
/// #baffle(alphabet: "greek")[top secret]\
/// #baffle(alphabet: (lowercase: ("👍", "👎")))[top secret]
/// ```)
///
/// - case-sensitive (bool):
/// Indicates whether to retain (#value(true)) case sensitivity or ignore (#value(false)) it, making everything lowercase.
/// #example(```
/// #baffle[Hello] vs. #baffle(case-sensitive: false)[Hello]
/// ```)
///
/// - punctuate (bool):
/// Indicates whether to retain (#value(true)) punctuation or ignore (#value(false)) it, treating punctuation marks like regular letters.
/// #example(```
/// #baffle[hello!] vs. #baffle(punctuate: false)[hello!]
/// ```)
///
/// - punctuation (str):
/// A string containing all characters considered a punctuation mark.
///
/// - input-word-dividers (array):
/// The set of characters considered word dividers in the input, to be replaced by #arg("output-word-divider") in the output.
/// #example(```
/// #baffle[hello·world] vs. #baffle(input-word-dividers: ("·",))[hello·world]
/// ```)
/// For writing systems that have spaces between words, leave as it is, but if your input text is Tibetan for example, `("\u{0f0b}", " ")` (_tsek_ and space) might be a better option, otherwise you’d get _very_ long words in the output.
///
/// - output-word-divider (str):
/// A string to which any character in #arg("input-word-dividers") is converted.
/// #example(```
/// #baffle(alphabet: "ugaritic")[два слова] vs. #baffle(alphabet: "ugaritic", output-word-divider: "𐎟")[два слова]
/// ```)
/// Keep `" "` if your target alphabet uses spaces; change to `"\u{200b}"` (zero-width space) if it doesn’t and there is no special word-dividing symbol such is in Ugaritic (zero-width space allows line breaking, whereas an empty string, `""`, does not).
///
/// - set-font (bool):
/// Indicates whether to typeset the output in the surrounding font (#value(false)) or the font suggested by #package[Babel] (#value(true)).
///
/// - seed (int,none):
/// If provided (not #value(none)), used for initialising the random number generator with that seed.
/// #example(```
/// #baffle(seed: 42)[hello] vs. #baffle(seed: 1312)[hello] vs. #baffle(seed: 42)[hello]
/// ```)
///
/// - as-string (bool):
/// Treat the input as a _string_ (as opposed to _content_).
/// This argument exists because of technical limitations of Typst (at least as of version 0.11.0), where some abilities cannot coexist:
/// #let X = redcell[❌]
/// #let V = grncell[⭕]
/// #table(
///   columns: (4fr, 1fr, 1fr),
///   align: (left, center, center),
///   table.header([Feature], [#value(false)], [#value(true)]),
///   table.hline(stroke: 0.05em),
///   [Formatting and complex text capabilities], V, X,
///   [Spaces between formatting groups (see #link("https://github.com/typst/typst/issues/5009")[this issue])], X, [N/A],
///   [Scripts with contextual letter forms], X, V,
///   [Counting of characters], redcell[codepoints], grncell[graphemes],
///   [Changes the table of contents; see @particular-limitations], X, V,
/// )
///
/// The choice between the two modes depends on what you need, and in some cases compromises cannot be avoided; for example, at the moment it’s not possible to apply #cmd("baffle") on a heterogeneous span of formatted Arabic or Devanāgarī text, unless you manually surround each individual homogeneous formatting group with a #cmd("baffle") command where #arg("as-string") is set to #value(true).
///
/// #example(```
/// #table(
/// columns: 3,
/// table.header([Feature], [#arg("as-string")`: `#value(false)], [#arg("as-string")`: `#value(true)]),
/// table.hline(stroke: 0.05em),
/// [Formatting and spaces],
/// ylwcell(baffle(output-word-divider:"@")[one two *three*]),
/// ylwcell(baffle(output-word-divider:"@", as-string: true)[one two *three*]),
/// [Contextual forms],
/// redcell(baffle(alphabet: "arabic")[hello]),
/// grncell(baffle(alphabet: "arabic", as-string: true)[hello]),
/// [Precomposed _â_ (`U+00E2`)],
/// grncell[#baffle(alphabet: "alchemy")[â] (1)],
/// grncell[#baffle(alphabet: "alchemy", as-string: true)[â] (1)],
/// [Combining _â_ (`U+0061 U+0302`)],
/// redcell[#baffle(alphabet: "alchemy")[â] (2)],
/// grncell[#baffle(alphabet: "alchemy", as-string: true)[â] (1)],
/// [Multi-codepoint\ emoji 🇦🇶 (`U+1f1E6 U+1f1F6`)],
/// redcell[#baffle(alphabet: "alchemy")[🇦🇶] (2)],
/// grncell[#baffle(alphabet: "alchemy", as-string: true)[🇦🇶] (1)],
/// )
/// ```)
///
/// -> content
#let baffle(
  input,
  alphabet: "latin-bicameral",
  case-sensitive: true,
  punctuate: true,
  punctuation: punctuation,
  input-word-dividers: (" ",),
  output-word-divider: " ",
  set-font: true,
  seed: none,
  as-string: false,
) = {
  assert(
    alphabet in alphabets.keys() or type(alphabet) != "string",
    message: "The alphabet must be one of the following: [" + alphabets.keys().join(", ") + "]"
  )
  let target-alphabet = if type(alphabet) == "string" {alphabets.at(alphabet)}
  else {alphabet}
  set text(
    font: target-alphabet.font,
    fallback: false,
  ) if set-font and target-alphabet.keys().contains("font")
  let baffle-letter-with-conf = baffle-letter.with(
    alphabet: target-alphabet,
    case-sensitive: case-sensitive,
    punctuate: punctuate,
    punctuation: punctuation,
    input-word-dividers: input-word-dividers,
    output-word-divider: output-word-divider,
  )
  if seed != none {
    letter-counter.update(seed)
  }
  if as-string {
    context {
      let output = ""
      let cnt = letter-counter.get().first()
      for letter in to-string(input).clusters() {
        output = output + baffle-letter-with-conf(letter, seed: seed+cnt, as-string: true)
        cnt = cnt + 1
      }
      letter-counter.update(it => it+to-string(input).clusters().len())
      output
    }
  }
  else {
    show regex("."): letter => {
      context{
        baffle-letter-with-conf(letter)
        letter-counter.step()
      }
    }
    input
  }
}

/// A synonym of #cmd("baffle") with #arg("alphabet") set to `"redaction"`.
///
/// #example(```
/// This is #redact[confidential].
/// ```)
#let redact = baffle.with(alphabet: "redaction")

/// A synonym of #cmd("baffle") with #arg("alphabet") set to `"tippex"`.
///
/// #example(```
/// This is #tippex[confidential].
/// ```)
#let tippex = baffle.with(alphabet: "tippex")
