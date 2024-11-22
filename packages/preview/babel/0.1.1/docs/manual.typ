#import "@preview/fontawesome:0.4.0": *
#import "@preview/mantys:0.1.4": *
#import "@preview/metalogo:1.0.2": LaTeX
#import "@preview/suiji:0.3.0"
#import "@preview/wrap-it:0.1.0": *

#import "@preview/babel:0.1.1": *
#import "../assets/logo.typ": logo
#import "../src/alphabets.typ": alphabets, maze

#let redcell = table.cell.with(fill: rgb("#FFCCCC"))
#let grncell = table.cell.with(fill: rgb("#CCDDAA"))
#let ylwcell = table.cell.with(fill: rgb("#EEEEBB"))

// By default Mantys sets the font on the title page; this is a way around that.
#let gentium-titlepage(..args) = {
  set text(font: ("Gentium Plus", "Noto Emoji"))
  show raw: set text(font: "Iosevka") // https://typeof.net/Iosevka/
  titlepage(..args, toc: false)
}
#show: mantys.with(
  titlepage: gentium-titlepage,
  title: "Babel",
  ..toml("../typst.toml"),
  abstract: [
    #align(center, text(size: 32pt, logo()))

    This package provides functions that replace actual text with random characters, which is useful for redacting confidential information or sharing the design and structure of an existing document without disclosing the content itself.
    A variety of ready-made sets of characters for replacement are available (#alphabets.len() in total), representing diverse writing systems, codes, notations and symbols.
    Some of these are more conservative (such as emulating redaction using a wide black pen) and many are more whimsical, as demonstrated by the following example:

    #example[```
      #baffle(alphabet: "welsh")[Hello]. My #tippex[name] is #baffle(alphabet: "underscore")[Inigo Montoya]. You #baffle(alphabet: "alchemy")[killed] my #baffle(alphabet: "shavian")[father]. Prepare to #redact[die].

      Using show rules strings, regular expressions and other selectors can be redacted automatically:

      #show "jan Maja": baffle.with(alphabet: "sitelen-pona")
      #show regex("[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*"): baffle.with(alphabet: "maze-3") 

      I’m jan Maja, and my email is `foo@digitalwords.net`.
    ```]
  ],
  examples-scope: (
    baffle: baffle,
    redact: redact,
    tippex: tippex,
    redcell: redcell,
    grncell: grncell,
    ylwcell: ylwcell,
    alert: mty.alert,
  ),
)


#set text(font: (("Gentium Plus", "Noto Emoji")))
#show regex("[⟨⟩]"): it => {text(font: "Gentium Basic", it)} // for some reason the Gentium Plus glyphs look horrible 𓂜
#show raw: set text(font: "Iosevka") // https://typeof.net/Iosevka/
#set raw(theme: "tokyonight_day.tmTheme") // https://github.com/folke/tokyonight.nvim/blob/main/extras/sublime/tokyonight_day.tmTheme
#show link: it => [#it#text(fill: rgb("#993333"))[°]]
#show figure.where(kind: table): set figure.caption(position: top)
#set heading(supplement: "§")
#set table(stroke: none)

#let hbo = text.with(font: "SBL Hebrew", lang: "he")

= Introduction

== Purpose and usage scenarios

At times one wishes to make portions of text (or the whole text) hidden from the recipient:

- The most common case is when redacting confidential information.
  Traditionally this is done by overwriting portions of text with a wide black pen and photocopying the result.
- Another usage scenario is sharing the design and structure of a document, but not the text itself.
  While _lorem ipsum_#footnote[
    Typst provides a built-in function for this, #link("https://typst.app/docs/reference/text/lorem/")[`lorem()`], which outputs pseudo-Latin.
    For a Japanese blind text generator, see #link("https://typst.app/universe/package/roremu")[#package[roremu]].
  ] blocks help when demonstrating the design of a template~— replacing places where actual text would go with placeholder text~— when sharing the way a particular existing document looks they are less helpful, since in order to use them one would have to make a copy of the document and manually substitute text with placeholder text of more or less the same length, which is tiresome and prone to errors.

In addition, playing with various contemporary, historical and constructed writing systems is a special kind of geeky fun…
While the package does have serious, practical use, most of the provided alphabets (@alphabets) are there just for fun.

One thing I ask you to avoid is using #package[Babel] for mocking cultures, as often done with mimicry typefaces such as #link("https://en.wikipedia.org/wiki/Faux_Cyrillic")[Faux Cyrillic], #link("https://en.wikipedia.org/wiki/Faux_Hebrew")[Faux Hebrew] or #link("https://en.wikipedia.org/wiki/Wonton_font")[Wonton font], which have more than subtle racist undertone. This package is a celebration of the variety and diversity of writing#footnote[
  Just look at @alphabets! Human beings~— as well as Klingons and Elves…~— came up with so many different graphic symbols to represent sounds and ideas it’s mind-boggling.
].

If you wish to share the Typst source files of your document, not just the precompiled output, a tool called #link("https://github.com/frozolotl/typst-mutilate")[_Typst Mutilate_] might be useful for you.
Unlike #package[Babel], it is not a Typst package but an external tool, written in Rust.
It replaces the content of a Typst document with random words selected from a wordlist or random characters (similarly to Babel), changing the document in place (so make sure to run it on a _copy_!).
As a package for Typst, #package[Babel] cannot change your source files.

== Name

Have a seat, it’s story time.
#package[Babel] is named so as a wordplay on two things: the Biblical myth of the Tower of Babel and the #link("https://ctan.org/pkg/babel")[#LaTeX package] sharing the same name.
For anyone who isn’t familiar with the story, here is the full fragment (Genesis 11.1–9):

#let verse(number) = [#super(number) ]
#let hl = highlight.with(fill: eastern.transparentize(85%), radius: 1pt)
#[
  #set text(size: 10pt)
  #table(
    columns: (65%, 35%),
    gutter: 0.75em,
    [
      #show "YHWH": smallcaps[Yhwh]
      #verse("1")Now all the earth was of one language and one set-of-words.
      #verse("2")And it was when they migrated to the east that they found a valley in the land of Shin’ar and settled there.
      #verse("3")They said, each one to his neighbor: Come-now! Let us bake bricks and let us burn them well-burnt! —;For them brick-stone was like building-stone, and raw-bitumen was for them like red-mortar.
      #verse("4")And they said: Come-now! Let us build ourselves a city and a tower, its top in the heavens, and let us make ourselves a name, lest we be scattered over the face of all the earth!
      #verse("5")But YHWH came down to look over the city and the tower that the humans were building.
      #verse("6")YHWH said: Here, [they are] one people with one language for them all, and this is [merely] the first of their doings— now there will be no barrier for them in all that they scheme to do!
      #verse("7")#hl[Come-now! Let us go down and there let us baffle their language, so that no one will understand the language of his neighbor.]
      #verse("8")So YHWH scattered them from there over the face of all the earth, and they had to stop building the city.
      #verse("9")#hl[Therefore its name was called Bavel/Babble, for there YHWH baffled the language of all the earth-folk, and from there, YHWH scattered them over the face of all the earth.]
    ],
    hbo[
      #verse("1")וַיְהִ֥י כׇל־הָאָ֖רֶץ שָׂפָ֣ה אֶחָ֑ת וּדְבָרִ֖ים אֲחָדִֽים׃
      #verse("2")וַיְהִ֖י בְּנׇסְעָ֣ם מִקֶּ֑דֶם וַֽיִּמְצְא֥וּ בִקְעָ֛ה בְּאֶ֥רֶץ שִׁנְעָ֖ר וַיֵּ֥שְׁבוּ שָֽׁם׃
      #verse("3")וַיֹּאמְר֞וּ אִ֣ישׁ אֶל־רֵעֵ֗הוּ הָ֚בָה נִלְבְּנָ֣ה לְבֵנִ֔ים וְנִשְׂרְפָ֖ה לִשְׂרֵפָ֑ה וַתְּהִ֨י לָהֶ֤ם הַלְּבֵנָה֙ לְאָ֔בֶן וְהַ֣חֵמָ֔ר הָיָ֥ה לָהֶ֖ם לַחֹֽמֶר׃
      #verse("4")וַיֹּאמְר֞וּ הָ֣בָה ׀ נִבְנֶה־לָּ֣נוּ עִ֗יר וּמִגְדָּל֙ וְרֹאשׁ֣וֹ בַשָּׁמַ֔יִם וְנַֽעֲשֶׂה־לָּ֖נוּ שֵׁ֑ם פֶּן־נָפ֖וּץ עַל־פְּנֵ֥י כׇל־הָאָֽרֶץ׃
      #verse("5")וַיֵּ֣רֶד יְהֹוָ֔ה לִרְאֹ֥ת אֶת־הָעִ֖יר וְאֶת־הַמִּגְדָּ֑ל אֲשֶׁ֥ר בָּנ֖וּ בְּנֵ֥י הָאָדָֽם׃
      #verse("6")וַיֹּ֣אמֶר יְהֹוָ֗ה הֵ֣ן עַ֤ם אֶחָד֙ וְשָׂפָ֤ה אַחַת֙ לְכֻלָּ֔ם וְזֶ֖ה הַחִלָּ֣ם לַעֲשׂ֑וֹת וְעַתָּה֙ לֹֽא־יִבָּצֵ֣ר מֵהֶ֔ם כֹּ֛ל אֲשֶׁ֥ר יָזְמ֖וּ לַֽעֲשֽׂוֹת׃
      #verse("7")#hl[הָ֚בָה נֵֽרְדָ֔ה וְנָבְלָ֥ה שָׁ֖ם שְׂפָתָ֑ם אֲשֶׁר֙ לֹ֣א יִשְׁמְע֔וּ אִ֖ישׁ שְׂפַ֥ת רֵעֵֽהוּ׃]
      #verse("8")וַיָּ֨פֶץ יְהֹוָ֥ה אֹתָ֛ם מִשָּׁ֖ם עַל־פְּנֵ֣י כׇל־הָאָ֑רֶץ וַֽיַּחְדְּל֖וּ לִבְנֹ֥ת הָעִֽיר׃
      #verse("9")#hl[עַל־כֵּ֞ן קָרָ֤א שְׁמָהּ֙ בָּבֶ֔ל כִּי־שָׁ֛ם בָּלַ֥ל יְהֹוָ֖ה שְׂפַ֣ת כׇּל־הָאָ֑רֶץ וּמִשָּׁם֙ הֱפִיצָ֣ם יְהֹוָ֔ה עַל־פְּנֵ֖י כׇּל־הָאָֽרֶץ׃]
    ]
  )
]

The myth explains why people are scattered everywhere and why they speak different languages, and it also provides folk etymology for the name of the city of Babylon (#hbo[בָּבֶל] _Bāḇel_): #hbo[בָּלַ֥ל] _bālal_ ‘he mixed, he confounded’ in verse~9 and #hbo[וְנָבְלָ֥ה] _wə-nāḇlâ_ ‘and let us mix, and let us confound’ in verse~7 (both from the root #hbo[ב־ל־ל] _√BLL_ ‘to mix, to confound, to confuse’) sounds a bit like #hbo[בָּבֶל] _Bāḇel_ ‘Babel’.#footnote[
  Interestingly, the Babylonian Akkadian name which is the basis for the Hebrew name is 𒆍𒀭𒊏𒆠 _Bābilim_ ‘(lit.) the gate of the gods’.
  Even more interestingly, there is evidence this Akkadian interpretation of the name (as ‘the gate of the gods’) itself was a Semitic folk etymology on a non-Semitic name!
  This is all very… confusing, how people mix up things.
]
Everett Fox translated these verbs brilliantly in the #link("https://www.sefaria.org.il/Genesis.11?ven=The_Five_Books_of_Moses,_by_Everett_Fox._New_York,_Schocken_Books,_1995&lang=bi")[_Schocken Bible_], with the English verb _baffle_, where all other translation I looked at have _confound_ or _confuse_.
This is the reason for choosing that translation for the above excerpt and the name #cmd("baffle") for the main function provided by #package[Babel].

Now, idea of the Tower of Babel as the explanatory myth behind linguistic diversity still persists in contemporary culture, as demonstrated by the Babel fish in Douglas Adams’s _the Hitchhiker's Guide to the Galaxy_, the dictionary and machine-translation software _Babylon_ and the #LaTeX package #link("https://ctan.org/pkg/babel")[_Babel_].
Fittingly, the Babel #LaTeX package enhances the capabilities of localisation and internationalisation.
With our Typst #package[Babel] I chose to take the other connotation, of confusion, bafflement and mixing 🙃

== Logo

#wrap-content(
  column-gutter: 0.5em,
  text(size: 16pt, logo()),
  [
    The logo features a minimalist icon of the Tower of Babel or a ziggurat; see @licence for attribution.
    The background colour is the same shade of turquoise used by #package[Mantys].
  ]
)

== Copyright and licence <licence>

The this package is released under #link("https://spdx.org/licenses/MIT-0.html")[MIT-0].

#package[Babel]’s logo features an #link("https://thenounproject.com/icon/babel-2526388/")[image] by #link("https://andrejskirma.com/")[Andrejs Kirma] which is released under CC~BY-3.0.
    I attribute them willingly, as I find the graphics very fitting for the logo.
    Go check #link("https://thenounproject.com/creator/andrejs/")[their other icons].

== Versioning and stability <ver>

#package[Babel] follows the Semantic Versioning scheme (#link("https://semver.org/spec/v2.0.0.html")[SemVer 2.0.0]).
While it is fully usable in its current form (version `0.*.*`), changes to the API might occur in future versions.
This should not pose a problem:

- When you import a package in Typst you can indicate the version (for example, `#import "@preview/example:0.1.0"`), so no surprises should occur.
- Changes to the API will be clearly indicated in the documentation.#footnote[
    If the characters replaced by the package change between versions, this is not counted as a change: the whole point is the actual identity of the random characters is, well, random.
    Changes to the alphabets (@alphabets) are also considered minor.
  ]

== Participation and contact <contact>

If there is anything that doesn’t work well or any feature you want added or changed, don’t hesitate to #link("https://codeberg.org/afiaith/babel/issues")[open an issue] on the Git repository, and I will do my best to make the package more useful for you and others.
If you want to contribute code/documentation (changes, additions, corrections, improvements, etc. no matter how small or large), #link("https://codeberg.org/afiaith/babel/pulls")[pull requests] are very welcome; thanks!

In particular, contributions of alphabets (`src/alphabets.yaml`) are welcome.
This version contains #alphabets.len()~(!) alphabets, but like Pokémon, you gotta catch ’em all… When choosing a font for the script of your alphabet:
  - If only basic Latin characters are used, don’t set a font.
  - If the new alphabet uses a script already represented on #package[Babel], prefer the font already in use (for example, Gentium Plus for Latin, Greek and Cyrillic, SBL Hebrew for Hebrew,~…).
  - Prefer free, gratis and libre open-source fonts (FLOSS).
  - Prefer serif#footnote[
      Admittedly, for many scripts Noto Sans is the only good FLOSS option.
    ] fonts (wherever serif makes sense) that go well with Gentium Plus.

Not everyone is familiar with Git, so if that is a problem feel free to contact me in any other way; see #link("https://me.digitalwords.net/")[`https://me.digitalwords.net/`] for contact information.

== Disclaimer

I hold no responsibility for anything that may occur as a result of using this package, nor can I guarantee there are no edge cases where text that should have been redacted stays readable (please do report such cases; see @contact).
If you use this package with actual confidential information, please read the manual (especially @limitations), check the results and understand the risks.

= Usage

== Provided functions <functions>

#import "../src/baffle.typ": punctuation
#tidy-module(
  read("../src/baffle.typ"),
  include-examples-scope: true,
  name: "fonts",
  show-outline: false,
  scope: (
    punctuation: punctuation
  )
)

If you frequently use #cmd("baffle") with certain parameters, defining an alias of your own makes things simpler, easier, and more elegant; for example:

#example(```
#let tp = baffle.with(alphabet: "sitelen-pona", punctuate: false, output-word-divider: "\u{200b}")
Hi! #tp[this!] and #tp[that…] are confidential.
```)

=== Using show rules <show-rules>

While surrounding segments of commands is useful for short amounts of text, applying commands to long segments~— or even the whole document~— is cumbersome.
Fortunately, Typst provides us with a clever solution for that: show rules.
Consider the following example:

#example[```
This text is shown as plaintext.

#show: baffle.with(alphabet: "astrology")

Now from here on the text is baffled!
```]

Show rules can be used for redacting strings, regular expressions and other selectors automatically (see the #link("https://typst.app/docs/reference/styling/#show-rules")[documentation]):

#example[```
#show "Ramona Flowers": baffle.with(alphabet: "redaction")
#show regex("[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*"): baffle.with(alphabet: "maze-3") 

Her name is Ramona Flowers, and her email is `ramona@flowers.name`.
```]

At the moment (version 0.11.0) there is no way to revoke show rules#footnote[
  It is planned, though.
  See the #link("https://typst.app/docs/roadmap/")[roadmap] and #link("https://github.com/typst/typst/issues/420")[this issue].
].
As a workaround, bracketing the relevant segments can limit the scope of a show rule:

#example[```
This is plaintext.

#[
  #show: baffle

  A baffled part of the document.
]

Plaintext again. 
```]



=== Limitations and considerations <limitations>

==== General matters

===== Educated guesses

From an information-theoretical point of view, the #cmd("baffle") loses a lot of information: it may retain only the length of each word, capitalisation, and punctuation, and each of the three can be turned off.
Unlike encryption, where by definition the plaintext can be deciphered using the proper technique and secret information, here the original text cannot be recovered algorithmically.
Given certain conditions, educated guesses can be made though: for example (and an extreme one at that…), if you see a baffled word that is 27 letters long, you can assume with confidence that it is _electroencephalographically_ if the text deals with neurology or _ethylenediaminetetraacetate_ if it deals with chemistry.
In more realistic scenarios contextual information and the nature of the text (rigid forms are more predictable than literary prose, for example) can assist in making educated guesses.

For maximal obfuscation, turn word division, capitalisation and punctuation off, but realistically I don’t think this is needed, and the result might be less aesthetically pleasing, depending on the alphabet used.

Note that #cmd("baffle") retain information about the length of words in characters#footnote[
  Some alphabets may increase the number of characters, as they include multi-character ‘letters’ (e.g. digraphs).
], not in horizontal length.
This covers some attack vectors involving proportional fonts and kerning, but opens others, based on counting characters.

===== Unintended meanings

Letters are chosen from the alphabets randomly.
In theory, unintended meanings may occur, especially with relatively short words.
Also, note that some scripts (Egyptian hieroglyphs and Phaistos Disc, sitelen sitelen,~…) contain pictograms which might be taboo in your culture.

==== Particular, implementation-dependant matters <particular-limitations>

Limitations concerning the #arg("as-string") argument are discussed in @functions, and those concerning particular alphabets are discussed in @alphabets.

If elements which are included in the table of contents appear within #cmd("baffle"), they appear in plaintext in the PDF table of contents#footnote[
  This is the one accessible using a sidebar or the tab key, depending on the PDF reader, not the one typeset in the document itself.
] unless they are bound within a #cmd("baffle") command with #arg("as-string") set to #value(true), in which case the bound text disappears from the PDF table of contents.
The baffled text in a typeset table of contents (#cmd("outline")) is different to the one used in the headings.

== Provided alphabets <alphabets>

In total #alphabets.len() alphabets are provided by #package[Babel].
‘Alphabet’ is used here in the sense used in formal language theory, not linguistics (neither in the narrow nor the wide sense).#footnote[
  If these distinctions are not clear to you, read the following Wikipedia articles if you’d like to learn about them: #link("https://en.wikipedia.org/wiki/Alphabet")[Alphabet] (linguistics, both senses) and #link("https://en.wikipedia.org/wiki/Alphabet_(formal_languages)")[Alphabet (formal languages)].
]
Many of the ‘alphabets’ below are not alphabets in the linguistic sense.

#let font-icon = text(font: "Linux Libertine", size: 15pt)[_Aa_]

=== Legend

#table(
  columns: 2,
  align: (x, y) => if x == 0 { center } else { left },
  fa-icon("wikipedia-w"),
  [a link to the relevant article in Wikipedia. If anything piques your interest, down to the rabbit hole you go.],
  font-icon,
  [a link to the font used in the example.],
  [`slug`],
  [the string you provide the #arg("alphabet") argument with (`arabic` for Arabic, `alchemy` for Alchemical symbols, …).],
)

=== Notes
- The characters from the output alphabet are chosen at random, which has several implications:
  - Phonotactics is not taken into consideration.
  - The output contains mostly non-words which defy the rules of how words look in the alphabet in question.
  - Letter frequency is also not taken into consideration.
    At most, the vowels or consonants are superficially doubled in order to account for severe disparity in the type:token ratio.
  Because characters are chosen at random final letters have been removed from the Hebrew script and the Canadian Aboriginal syllabics, so they will not occur in incorrect positions.#footnote[
    It’s a better compromise not to represent the final forms than to have them occur in incorrect positions.
  ]
- Some of the scripts~— such as Egyptian and Anatolian hieroglyphs or the sitelen pona and sitelen sitelen scripts~— are normally written with grouping of characters in a non-linear manner. This is not done here, where the glyphs are stringed one after the other in a linear manner.

=== A menu of alphabets

#let rng = suiji.gen-rng(0)

#let sample = "Ni malleviĝu do, kaj Ni konfuzu tie ilian lingvon, por ke unu ne komprenu la parolon de alia. Kaj la Eternulo disigis ilin de tie sur la supraĵon de la tuta tero, kaj ili ĉesis konstrui la urbon."//Tial oni donis al ĝi la nomon Babel, ĉar tie la Eternulo konfuzis la lingvon de la tuta tero kaj de tie la Eternulo disigis ilin sur la supraĵon de la tuta tero."

#let describe-alphabet(slug, alphabet) = [
  #box(
    fill: luma(245),
    inset: 0.75em,
    radius: 0.75em,
  )[
    #strong(alphabet.at("name"))
    #if "native" in alphabet.keys() [
      #h(1em)#[#set text(font: alphabet.at("font")) if "font" in alphabet.keys();#alphabet.at("native")]
    ]
    #h(1fr)
    #text(font: "Iosevka", slug)
    #h(1em)
    #link("https://en.wikipedia.org/wiki/" + alphabet.at("wiki"), fa-icon("wikipedia-w"))
    #if "fonturl" in alphabet.keys() {link(alphabet.at("fonturl"), font-icon)}
    \
    #[
      #set text(lang: alphabet.at("lang")) if "lang" in alphabet.keys()
      #box(
        width: 100%, height: 1.5em, clip: true, baseline: -0.2em,
        // TODO Make less hackish and ugly
        box(width: 1000%, baseline: 1.2em)[
          #baffle(
            sample,
            alphabet: slug,
            punctuate: if "punctuate" in alphabet.keys() {alphabet.at("punctuate")} else {true},
            output-word-divider: if "word-divider" in alphabet.keys() {alphabet.at("word-divider")} else {" "},
            as-string: true,
          )
        ]
      )
    ]
    #v(-0.5em)#if "note" in alphabet.keys() {
      eval(
        mode: "markup",
        alphabet.at("note"),
        scope: (
          maze: maze,
          arg: arg,
          cmd: cmd,
          baffle: baffle,
        ))
    }
  ]
  #v(0.5em)
]

#for pair in alphabets.pairs() {
  describe-alphabet(pair.at(0), pair.at(1))
}
