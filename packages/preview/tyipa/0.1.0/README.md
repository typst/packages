# TyIPA: Write phonetic transcriptions using the IPA.

TyIPA is a module for working with the International Phonetic Alphabet (the IPA) in Typst, in a _typsty_ style.

TyIPA provides access to a library of IPA symbols via an
interface highly similar to Typst's built-in `std.sym` interface, combined with
diacritic functions covering the large range of accents and diacritical marks
needed for IPA transcription.

TyIPA further provides a convenient text-conversion function that provides
direct unqalified access to IPA symbols and diacritics within an `ipa.text()`
function, similar to how math mode provides unqualified access to symbols from
`std.sym`.

TyIPA relies fully on the Unicode mapping of the IPA and thus on fonts 
correctly and fully implementing the IPA-specific parts of the Unicode standard.
Unlike for example TIPA for LaTeX, TyIPA does not attempt to supplement or
encode its own IPA characters to plug any gaps of fix problems with fonts.

## Usage

Import and start using TyIPA as follows:

```typst
#import "@preview/tyipa:0.1.0" as ipa

Are you a #ipa.text[
  stress-mark.secondary f o upsilon n schwa stress-mark t I esh schwa n
]?

If not, let me tell you that the IPA symbol for a voiceless velar nasal is
#highlight(
    ipa.diac.voiceless-above(
        ipa.sym.n.engma
    )
) -- an engma with a ring above.
```

As you can already glance from the short example above, there are three
principal components that get imported from TyIPA:
- `ipa.sym`: provides access to the symbols of the IPA, following the
   nomenclature for the glyphs (not the phonetic denotation), e.g.
   `ipa.sym.r.turned` for a turned lower-case r.
- `ipa.diac`: provides access to the diacritics of the IPA, named after what
  each diacritic signifies (rather than the name for the glyph), e.g.
  `ipa.sym.nasalized()`.
- `ipa.text()`: a function that takes a string or content argument and
  transliterates this into IPA based on symbol and diacritic names from
  `ipa.sym` and `ipa.diac`. Also takes an option argument `delim` with
  which you can add brackets, e.g. `ipa.text("schwa", delim: "[")` ->
  _[ə]_.

For detailed instructions and a comprehensive listing of all the symbols and
diacritics available, see the [TyIPA Manual available on the GitHub repo](./manual/manual.pdf).

There is also a re-implementation of the 2015 IPA Chart in Typst [here](./ipa-chart.pdf) ([source](./ipa-chart.typ)).