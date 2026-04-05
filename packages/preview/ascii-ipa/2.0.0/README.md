# `ascii-ipa`

🔄 ASCII / IPA conversion for Typst

This package allows you to easily convert different ASCII representations of the International Phonetic Alphabet (IPA) to and from the IPA.
It also offers some minor utilities to make phonetic transcriptions easier to use overall.
The package is being maintained [here][repo].

Note: This is an extended port of the [`ipa-translate`][ipa-translate] Rust crate by [tirimid][tirimid]'s conversion features into native Typst.
Most conversions are implemented according to [this Wikipedia article][ipa-wikipedia] which in turn relies of the official specifications of the respective ASCII representations.

## Conversion

The package supports multiple ASCII representations for the IPA with one function each:

| Notation | Function name   |
|----------|-----------------|
| Branner  | `#branner(...)` |
| Praat    | `#praat(...)`   |
| SIL      | `#sil(...)`     |
| X-SAMPA  | `#xsampa(...)`  |

They all return the converted value as a [`string`][typst-str] and accept the set of same parameters:

| Parameter | Type                  | Positional / Named | Default | Description                                                                                                |
|-----------|-----------------------|--------------------|---------|------------------------------------------------------------------------------------------------------------|
| `value`   | [`string`][typst-str] | positional         |         | Main input to the function. Usually the transcription in the corresponsing ASCII-based notation.           |
| `reverse` | [`bool`][typst-bool]  | named              | `false` | Reverses the conversion. Pass Unicode IPA into `value` to get the corresponsing ASCII-based notation back. |

### Examples

All examples use the Swiss German word [⟨Chuchichäschtli⟩ [ˈχʊχːiˌχæʃːtlɪ]][chuchichäschtli] for the conversion.

```typst
#import "@preview/ascii-ipa:2.0.0": *

// returns "ˈχʊχːiˌχæʃːtlɪ"
#branner("'XUX:i,Xae)S:tlI")

// returns "'XUX:i,Xae)S:tlI"
#branner("ˈχʊχːiˌχæʃːtlɪ", reverse: true)

// returns "ˈχʊχːiˌχæʃːtlɪ"
#praat("\\'1\\cf\\hs\\cf\\:f\\'2\\ae\\sh\\:ftl\\ic")

// returns "\\'1\\cf\\hs\\cf\\:f\\'2\\ae\\sh\\:ftl\\ic"
#praat("ˈχʊχːiˌχæʃːtlɪ", reverse: true)

// returns "ˈχʊχːiˌχæʃːtlɪ"
#sil("}x=u<x=:i}}x=a<s=:tli=")

// returns "}x=u<x=:i}}x=a<s=:tli="
#sil("ˈχʊχːiˌχæʃːtlɪ", reverse: true)

// returns "ˈχʊχːiˌχæʃːtlɪ"
#xsampa("\"XUX:i%X{S:tlI")

// returns "\"XUX:i%X{S:tlI"
#xsampa("ˈχʊχːiˌχæʃːtlɪ", reverse: true)
```

### With `raw`

You can also use [`raw`][typst-raw] for the conversion.
This is useful if the notation uses a lot of backslashes.

```typst
#import "@preview/ascii-ipa:2.0.0": praat

// regular string
#praat("\\'1\\cf\\hs\\cf\\:f\\'2\\ae\\sh\\:ftl\\ic")

// raw
#praat(`\'1\cf\hs\cf\:f\'2\ae\sh\:ftl\ic`)
```

Note: `raw` will not play nicely with notations that use ``` ` ``` a lot.

## Brackets & Braces

You can easily mark your notation text as different types of brackets or braces.

```typst
#import "@preview/ascii-ipa:2.0.0": *

#phonetic("prʲɪˈvʲet") // [prʲɪˈvʲet]
#phnt("prʲɪˈvʲet")     // [prʲɪˈvʲet]

#precise("prʲɪˈvʲet") // ⟦prʲɪˈvʲet⟧
#prec("prʲɪˈvʲet")    // ⟦prʲɪˈvʲet⟧

#phonemic("prɪvet") // /prɪvet/
#phnm("prɪvet")     // /prɪvet/

#morphophonemic("prɪvet") // ⫽prɪvet⫽
#mphnm("prɪvet")          // ⫽prɪvet⫽

#indistinguishable("prʲɪˈvʲet") // (prʲɪˈvʲet)
#idst("prʲɪˈvʲet")              // (prʲɪˈvʲet)

#obscured("prʲɪˈvʲet") // ⸨prʲɪˈvʲet⸩
#obsc("prʲɪˈvʲet")     // ⸨prʲɪˈvʲet⸩

#orthographic("привет") // ⟨привет⟩
#orth("привет")         // ⟨привет⟩

#transliterated("privyet") // ⟪privyet⟫
#trlt("privyet")           // ⟪privyet⟫

#prosodic("prʲɪˈvʲet") // {prʲɪˈvʲet}
#prsd("prʲɪˈvʲet")     // {prʲɪˈvʲet}
```

[repo]: https://github.com/imatpot/typst-ascii-ipa
[ipa-translate]: https://github.com/tirimid/ipa-translate
[tirimid]: https://github.com/tirimid
[ipa-wikipedia]: https://en.wikipedia.org/wiki/Comparison_of_ASCII_encodings_of_the_International_Phonetic_Alphabet
[typst-str]: https://typst.app/docs/reference/foundations/str/
[typst-bool]: https://typst.app/docs/reference/foundations/bool/
[typst-raw]: https://typst.app/docs/reference/text/raw/
[chuchichäschtli]: https://als.wikipedia.org/wiki/Chuchich%C3%A4schtli
