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
| CXS      | `#cxs(...)`     |
| Praat    | `#praat(...)`   |
| SIL      | `#sil(...)`     |
| X-SAMPA  | `#xsampa(...)`  |

They all return the converted value as a [`string`][typst-str] and accept the set of same parameters:

| Parameter | Type                  | Positional / Named | Default | Description                                                                                                |
|-----------|-----------------------|--------------------|---------|------------------------------------------------------------------------------------------------------------|
| `value`   | [`string`][typst-str] | positional         |         | Main input to the function. Usually the transcription in the corresponsing ASCII-based notation.           |
| `reverse` | [`bool`][typst-bool]  | named              | `false` | Reverses the conversion. Pass Unicode IPA into `value` to get the corresponsing ASCII-based notation back. |

### Examples

All examples use the Swiss German word [⟨Chuchichäschtli⟩ [ˈχʊ.χːi.ˌχæʃːt.lɪ]][chuchichäschtli] for the conversion.

```typst
#import "@preview/ascii-ipa:2.1.0": *

// returns "ˈχʊ.χːi.ˌχæʃːt.lɪ"
#branner("'XU.X:i.,Xae)S:t.lI")

// returns "'XU.X:i.,Xae)S:t.lI"
#branner("ˈχʊ.χːi.ˌχæʃːt.lɪ", reverse: true)

// returns "ˈχʊ.χːi.ˌχæʃːt.lɪ"
#cxs("'XU.X:i.,X&S:t.lI")

// returns "'XU.X:i.,X&S:t.lI"
#cxs("ˈχʊ.χːi.ˌχæʃːt.lɪ", reverse: true)

// returns "ˈχʊ.χːi.ˌχæʃːt.lɪ"
#praat("\\'1\\cf\\hs.\\cf\\:f.\\'2\\ae\\sh\\:ft.l\\ic")

// returns "\\'1\\cf\\hs.\\cf\\:f.\\'2\\ae\\sh\\:ft.l\\ic"
#praat("ˈχʊ.χːi.ˌχæʃːt.lɪ", reverse: true)

// returns "ˈχʊ.χːi.ˌχæʃːt.lɪ"
#sil("}x=u<x=:i}}x=a<s=:tli=")

// returns "}x=u<x=:i}}x=a<s=:tli="
#sil("ˈχʊ.χːi.ˌχæʃːt.lɪ", reverse: true)

// returns "ˈχʊ.χːi.ˌχæʃːt.lɪ"
#xsampa("\"XUX:i%X{S:tlI")

// returns "\"XUX:i%X{S:tlI"
#xsampa("ˈχʊ.χːi.ˌχæʃːt.lɪ", reverse: true)
```

### With `raw`

You can also use [`raw`][typst-raw] for the conversion.
This is useful if the notation uses a lot of backslashes.

```typst
#import "@preview/ascii-ipa:2.1.0": praat

// regular string
#praat("\\'1\\cf\\hs.\\cf\\:f.\\'2\\ae\\sh\\:ft.l\\ic")

// raw
#praat(`\'1\cf\hs.\cf\:f.\'2\ae\sh\:ft.l\ic`)
```

Note: `raw` will not play nicely with notations that use ``` ` ``` a lot.

### Convenience `show`-rule

You can use a `show`-rule to automatically turn `raw`-blocks into converted IPA.
The following example will turn any inline-`raw` into X-SAMPA converted IPA, unless the `<code>` label is added.
It also properly rescales the font size to match surrounding text, since `raw` uses a 20% smaller font size for its monospaced text by default.
This is done for aesthetic reasons, you can read more here:

- https://github.com/typst/typst/issues/1331
- https://github.com/typst/typst/issues/6302

```typst
#{
  let font = "Your IPA font here"
  show raw: set text(size: 1em / 0.8)
  show raw.where(block: false): it => {
    if it.at("label", default: none) != <code> { // skip code-labeled raws
      text(font: font, xsampa(it))
    } else {
      it
    }
  }
}

// Example

Chuchichäschtli is pronounced `"XU.X:i.%X{S:t.lI`        // will render ˈχʊ.χːi.ˌχæʃːt.lɪ as normal text
Chuchichäschtli is pronounced `"XU.X:i.%X{S:t.lI` <code> // will render "XU.X:i.%X{S:t.lI as raw code
```

This exact beheviour is provided built-in, so you don't need to define it yourself.

```typst
#import "@preview/ascii-ipa:2.1.0": replace-raw, xsampa
#show: replace-raw(xsampa, font: "Your IPA font here")
```

You can also customize the `skip` label and the `size` if you want, otherwise the above defaults are provided.

## Brackets & Braces

You can easily mark your notation text as different types of brackets or braces.

```typst
#import "@preview/ascii-ipa:2.1.0": *

#phonetic("ˈχʊ.χːi.ˌχæʃːt.lɪ")          // [ˈχʊ.χːi.ˌχæʃːt.lɪ]
#phnt("ˈχʊ.χːi.ˌχæʃːt.lɪ")              // [ˈχʊ.χːi.ˌχæʃːt.lɪ]

#precise("ˈχʊ.χːi.ˌχæʃːt.lɪ")           // ⟦ˈχʊ.χːi.ˌχæʃːt.lɪ⟧
#prec("ˈχʊ.χːi.ˌχæʃːt.lɪ")              // ⟦ˈχʊ.χːi.ˌχæʃːt.lɪ⟧

#phonemic("ˈχʊ.χːi.ˌχæʃːt.lɪ")          // /ˈχʊ.χːi.ˌχæʃːt.lɪ/
#phnm("ˈχʊ.χːi.ˌχæʃːt.lɪ")              // /ˈχʊ.χːi.ˌχæʃːt.lɪ/

#morphophonemic("ˈχʊ.χːi.ˌχæʃːt.lɪ")    // ⫽ˈχʊ.χːi.ˌχæʃːt.lɪ⫽
#mphnm("ˈχʊ.χːi.ˌχæʃːt.lɪ")             // ⫽ˈχʊ.χːi.ˌχæʃːt.lɪ⫽

#indistinguishable("ˈχʊ.χːi.ˌχæʃːt.lɪ") // (ˈχʊ.χːi.ˌχæʃːt.lɪ)
#idst("ˈχʊ.χːi.ˌχæʃːt.lɪ")              // (ˈχʊ.χːi.ˌχæʃːt.lɪ)

#obscured("ˈχʊ.χːi.ˌχæʃːt.lɪ")          // ⸨ˈχʊ.χːi.ˌχæʃːt.lɪ⸩
#obsc("ˈχʊ.χːi.ˌχæʃːt.lɪ")              // ⸨ˈχʊ.χːi.ˌχæʃːt.lɪ⸩

#orthographic("Chuchichäschtli")        // ⟨Chuchichäschtli⟩
#orth("Chuchichäschtli")                // ⟨Chuchichäschtli⟩

#transliterated("Chuchichäschtli")      // ⟪Chuchichäschtli⟫
#trlt("Chuchichäschtli")                // ⟪Chuchichäschtli⟫

#prosodic("ˈχʊ.χːi.ˌχæʃːt.lɪ")          // {ˈχʊ.χːi.ˌχæʃːt.lɪ}
#prsd("ˈχʊ.χːi.ˌχæʃːt.lɪ")              // {ˈχʊ.χːi.ˌχæʃːt.lɪ}
```

[repo]: https://github.com/imatpot/typst-ascii-ipa
[ipa-translate]: https://github.com/tirimid/ipa-translate
[tirimid]: https://github.com/tirimid
[ipa-wikipedia]: https://en.wikipedia.org/wiki/Comparison_of_ASCII_encodings_of_the_International_Phonetic_Alphabet
[typst-str]: https://typst.app/docs/reference/foundations/str/
[typst-bool]: https://typst.app/docs/reference/foundations/bool/
[typst-raw]: https://typst.app/docs/reference/text/raw/
[chuchichäschtli]: https://als.wikipedia.org/wiki/Chuchich%C3%A4schtli
