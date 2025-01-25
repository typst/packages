#import "src/quetta.typ": *

// Define the fonts
#let font-serif = "New Computer Modern"
#let font-sans = "New Computer Modern Sans"
#let font-mono = "New Computer Modern Mono"
#let font-math = "New Computer Modern Math"

// Other useful definitions
#let font-stroke-width = 0pt
#let paragraph-indent = 1em
#let paragraph-skip-b = 1em
#let subsec-skip-1 = 0em
#let subsec-skip-2 = 0.25em
#let link-color = color.rgb(0, 100, 200)

// Document metadata
#let title = "Manual for the quetta (" + quenya[Quetta] + ") module"
#let author = "Florent Michel"
#let keywords = ("Tengwar", "Typst")
#let version = "0.1.0"
#set document(
  title: title,
  author: author,
  keywords: keywords,
  date: auto)
  
// Page format
#set page (
  width: 21cm,
  height: 29.7cm,
  margin: (
    top: 2cm,
    bottom: 2cm,
    inside: 2cm,
    outside: 2cm),
  numbering: "1")

// Table format
#show table: set text(top-edge: "ascender", bottom-edge: "descender")
#set table(
  inset: 5pt, 
  align: center + horizon, 
  stroke: 0.5pt)
  
// Main font
#set text (
  font: font-serif,
  weight: 500,
  fallback: false,
  stroke: font-stroke-width,
  size: 10.5pt)

// Math font
#show math.equation: set text(
  font: font-math,
  weight: 500, 
  stroke: font-stroke-width)

// Paragraph format
#set par(
  justify: true,
  leading: 0.5em,
  spacing: 0.5em,
  first-line-indent: paragraph-indent)

// Link format
#show link: set text(
  link-color,
  stroke: font-stroke-width + link-color)

// Reference format
#show ref: set text(
  link-color,
  stroke: font-stroke-width + link-color)
#let numbering-section(x, depth) = x.slice(0, depth).map(str).join(".")
#show ref: it => {
  let el = it.element
  if el != none and it.func() == ref {
      link(
        el.location(),
        text(link-color, numbering-section(counter(heading).at(el.location()), el.depth)))
  } else {
    it
  }
}

// Headings format
#set heading(numbering: "1.")
#show heading: set text(font: font-sans)
#show heading: it => {
  v(subsec-skip-1)
  it
  v(subsec-skip-2)
}

// Outline format
#set outline(
  indent: true, 
  depth: 2)
#show outline: set text(
  font: font-sans,
  link-color, 
  stroke: link-color + font-stroke-width)
#show outline.entry.where(level: 1): it => {
  v(12pt, weak: true)
  strong(it)
}
 
// List format
#let text-list-sep = 0.5em
#set list(
  tight: false,
  marker: ([•], [‣], [–]),
  indent: 1em,
  spacing: 1em)

// Footnote format
#set footnote.entry(indent: 0pt)
#show footnote: set text(link-color)

// Citation format
#show cite: it => {
  set text(fill: black)
  //show regex("\[|\]"): ""
  show regex("\d+"): set text(fill: link-color)
  it
}

// Code snippet
#let tengwar-snippet(code, margin: 0pt) = context {
  let inset = 3pt
  let radius = 5pt
  set text(bottom-edge: "bounds", top-edge: "bounds")
  let y = eval(code, mode: "code", scope: (quenya: quenya))
  let code-block = raw(code, block: true, lang: none)
  let height-l-t = measure([
      #set text(top-edge: "bounds", bottom-edge: "baseline")
      #box(code-block, inset: 0pt)]).height
  let height-l-b = measure([
      #set text(top-edge: "baseline", bottom-edge: "bounds")
      #box(code-block, inset: 0pt)]).height
  let height-r-t = measure([
      #set text(top-edge: "bounds", bottom-edge: "baseline")
      #box(y, inset: 0pt)]).height
  let height-r-b = measure([
      #set text(top-edge: "baseline", bottom-edge: "bounds")
      #box(y, inset: 0pt)]).height
  let box-l = box(code-block,
                  inset: (top: inset + {if height-r-t > height-l-t {height-r-t - height-l-t} else {0pt}}, 
                          bottom: inset + {if height-r-b > height-l-b {height-r-b - height-l-b} else {0pt}}, 
                          left: inset, 
                          right: inset))
  let box-r = box(y, fill: white, radius: radius,
                  inset: (top: inset + {if height-l-t > height-r-t {height-l-t - height-r-t} else {0pt}}, 
                          bottom: inset + {if height-l-b > height-r-b {height-l-b - height-r-b} else {0pt}}, 
                          left: inset + margin, 
                          right: inset + margin - 1pt))
  box(box-l + box-r,
    inset: 0pt,
    radius: radius, 
    fill: luma(200),
    stroke: luma(200),
    baseline: 28%)
}


// Code block
#set raw(theme: "manual_files/blue.tmTheme")
#show raw.where(lang: "typst-q"): it => [
    #show regex("(#\w+)") : keyword => text(fill: blue, weight: "bold", keyword)
    #show regex("([0-9])") : keyword => text(fill: purple, keyword)
    #show regex("\b(em|pt)\b") : keyword => text(fill: purple, keyword)
    #it
]
#let code-block(it) = {
  set text(top-edge: "bounds", bottom-edge: "bounds")
  block(fill: luma(220), inset: 3pt, breakable: false, width: 100%, raw(it, lang: "typst-q"))
}
#let show-code(code) = {
  v(paragraph-skip-b)
  code-block(code)
  v(paragraph-skip-b)
  eval(code, mode: "markup", scope: (quenya: quenya))
  v(paragraph-skip-b)
}


#if (title != none) {
  align(
    center,
    text(17pt, font: font-sans)[#strong(title)]
    + if (author != "") { v(.5em) + text(15pt, font: "Latin Modern Sans")[#author] }
    + if (version != "") { v(.5em) + text(12pt, font: "Latin Modern Sans")[version #version] }
  )
}

#outline(title: text(fill: black, "Contents" + v(-0.25em)))

= Introduction

== ‘Quetta’?

_‘Quetta’_ (#quenya[Quetta]) means ‘word’ in Quenya @elfdict#footnote[https://www.elfdict.com/w/quetta], one of the fictional languages invented by British writer and philologist J. R. R. Tolkien. 
It thus seemed fitting for a module aimed at making the process of typing these languages easier. 

Words are also, loosely speaking, the base units this module works on, as we shall see in more details below. 
While its general philosophy is to map each symbol used in Tolkien's elvish languages to letters from the Latin alphabet, a few word-wise substitution rules were implemented so that, in _most_ (but probably not all) cases the correct spelling can be obtained by typing the word phonetically. 
For the same reason, the mapping generally works on groups of letters rather than individual ones, at least when there is no natural one-to-one mapping between individual symbols.

== The Tengwar script

A proper introduction to Tengwar is way beyond the scope of this document. 
We refer interested readers to Appendix E of the book @lotr and online references such as #link("https://en.wikipedia.org/wiki/Tengwar")[Wikipedia], #link("https://tolkiengateway.net/wiki/Tengwar")[tolkiengateway.net], #link("https://www.omniglot.com/conscripts/tengwar.htm")[omniglot.com], or #link("https://www.tecendil.com/tengwar-handbook/")[tecendil.com].

In short, Tengwar (#quenya[tengwar] in Quenya mode) is one of the scripts invented by Tolkien, primarily consisting of 36 letters (called _tengwar_; singular: _tengwa_ (#quenya[tengwa])) and diacritics (_tehtar_ (#quenya[tehtar] ; singular: _tehta_ (#quenya[tehta]))). 
There are several ways to relate tengwar to sounds, called _modes_.
This module primarily focuses on the Quenya (#quenya[Quenya]), or ‘classical’, mode, in universe the original way to write tengwar.
Support for the other modes described by Tolkien is planned for a future version.

= How to use

== Requirements

- #link("https://github.com/typst/typst")[Typst] version 1.11.0 or up

- The #link("https://www.fontspace.com/tengwar-annatar-font-f2244")[Tengwar Annatar] fonts version 1.20 (support for other Tengwar fonts is not currently planned).

== Importing the module

To import the module, simply add

#v(paragraph-skip-b)

```typst
#import "<path>/quetta.typ": *
```
#v(paragraph-skip-b)

at the top of your `.typ` file, where `<path>` is the path to the quetta module. 

== Design principles

This module provides one main command for each supported mode—at the moment, only `quenya` is implemented. 
This command takes text (possibly including formatting) as input and performs the following sequence of operations (not necessarily in this order): 

+ Phonetic translation into tengwar and tehtar—for instance, converting `quenya` to #quenya[quen:ya].

+ Application of spelling rules—for instance, converting #quenya[quen:ya] to #quenya[quenya].

+ Conversion of numbers in base 12 and conversion to the tengwar number system (see below)—for instance, `144` becomes #quenya[144].

+ Conversion of punctuation symbols—for instance, `?` becomes #quenya[?].

+ Adjustments to the position of tehtar and to the kerning between some symbols.

#v(0.5em)

Alternative glyphs, when available, can be obtained with the symbol `£`:

#v(paragraph-skip-b)

#tengwar-snippet("quenya[s]") #h(1em) #tengwar-snippet("quenya[£s]") 
#h(1em) #tengwar-snippet("quenya[ss]") #h(1em) #tengwar-snippet("quenya[£ss]") 

#v(paragraph-skip-b)

#tengwar-snippet("quenya[sa]") #h(1em) #tengwar-snippet("quenya[£sa]") 
#h(1em) #tengwar-snippet("quenya[ssa]") #h(1em) #tengwar-snippet("quenya[£ssa]") 

#v(paragraph-skip-b)

#h(-paragraph-indent)For tengwar associated with a sound starting with ‘k’, the standard glyphs are obtained using the spelling ‘c’ for _calma_ (#quenya[c]) or ‘qu’ for _quessë_ (#quenya[qu]), and the alternatives glyphs with a ‘k’ or ‘kw’: 

#v(paragraph-skip-b)

#tengwar-snippet("quenya[c]") #h(1em) #tengwar-snippet("quenya[k]") #h(1em)
#tengwar-snippet("quenya[qu]") #h(1em) #tengwar-snippet("quenya[kw]") 

#v(paragraph-skip-b)

#h(-paragraph-indent)Formatted text is supported, although it is still somewhat experimental: 

#v(paragraph-skip-b)

#tengwar-snippet("quenya[quetta *quetta* _quetta_ _*quetta*_]")

#v(paragraph-skip-b)

#h(-paragraph-indent)For a larger amount of text or more involved formatting, it can be easier to use a `show` rule as follows: 

#v(paragraph-skip-b)

#show-code("#[#show: quenya

  quenya

  #h(1em) *quenya*

  #h(2em) _quenya_
]")

#h(-paragraph-indent)One limitation of the current implementation is that functions changing other style properties such as text color must be called _after_ the conversion function. 
For instance, a centred 16-points italic version of the Quenya word ‘tengwar’ with a blue-green linear gradient may be obtained as follows:

#v(paragraph-skip-b)

#code-block("#set align(center)
#text(size: 16pt, 
      fill: gradient.linear(blue, green)
     )[#box(quenya[_tengwar_])]
]")

#v(paragraph-skip-b)

#[#set align(center)
#text(size: 16pt, 
      fill: gradient.linear(blue, green)
     )[#box(quenya[_tengwar_])]
]

== Quenya (#quenya[Quenya])

=== Generalities<sec-quenya-gen>

The implementation of the Quenya mode mostly follows Reference @tengwar-eruantalince, summarizing information available in Appendix E of @lotr and examples provided in other parts of the book. 
In universe, the Quenya language and pronunciation evolved somewhat between its origins and events described in @lotr; in this implementation, we aim to stay close to the Second Age conventions.
Here are a few basic examples: 

#v(paragraph-skip-b)

#tengwar-snippet("quenya[quenya]")

#tengwar-snippet("quenya[quetta]")

#tengwar-snippet("quenya[tengwar]")

#tengwar-snippet("quenya[namárië]")

#v(paragraph-skip-b)

#h(-paragraph-indent)A full description of the Quenya mode is beyond the scope of this document. As a first approximation, consonant sounds are represented by _tengwar_ as follows#footnote[In these tables, the letter ‘u’ represents the consonant sound ‘w’.]:

#v(paragraph-skip-b)

#h(-paragraph-indent)#box(table(
  columns: (auto, auto),
  table.header(
    [*consonant*], [*tengwa*]
  ),
  "t", quenya[t],
  "nd", quenya[nd],
  "th", quenya[th],
  "nt", quenya[nt],
  "n", quenya[n],
  "r", quenya[r],
))
#box(table(
  columns: (auto, auto),
  table.header(
    [*consonant*], [*tengwa*]
  ),
  "p", quenya[p],
  "mb", quenya[mb],
  "f", quenya[f],
  "mp", quenya[mp],
  "m", quenya[m],
  "v", quenya[v],
))
#box(table(
  columns: (auto, auto),
  table.header(
    [*consonant*], [*tengwa*]
  ),
  "c", quenya[c],
  "ng", quenya[ng],
  "h", quenya[h],
  "nc", quenya[nc],
  "n", quenya[n],
  "y", quenya[y],
))
#box(table(
  columns: (auto, auto),
  table.header(
    [*consonant*], [*tengwa*]
  ),
  "qu", quenya[qu],
  "ngw", quenya[ngw],
  "hw", quenya[hw],
  "nqu", quenya[nqu],
  "ñw", quenya[ñw],
  "w", quenya[w],
))
#box(table(
  columns: (auto, auto),
  table.header(
    [*consonant*], [*tengwa*]
  ),
  "ñ", quenya[ñ],
  "rd", quenya[rd],
  "l", quenya[l],
  "ld", quenya[ld],
  "s", quenya[s],
  "ss", quenya[ss],
))

#v(paragraph-skip-b)

#h(-paragraph-indent)
Different tengwar are used for the same sounds in different situations; see Section~@sec-quenya-subst-rules.
Vowel sounds are generally represented by a _tehta_, placed either on the previous consonant or a short carrier for a short vowel, or a long carrier for a long vowel#footnote[We use an acute accent to denote long vowels. For instance, `a` is rendered as #quenya[a] and `à` as #quenya[á].]:

#v(paragraph-skip-b)

#table(
  columns: (auto, auto, auto),
  table.header(
    [*vowel*], [*short version*], [*long version*]
  ),
  "a", quenya[a], quenya[á], 
  "e", quenya[e], quenya[é], 
  "i", quenya[i], quenya[í], 
  "o", quenya[o], quenya[ó], 
  "u", quenya[u], quenya[ú], 
)

#v(paragraph-skip-b)

Diphthongs of the form _-i_ and _-u_ are obtained by adding a theta to an ‘i-glide’ or ‘u-glide’ symbol: 

#v(paragraph-skip-b)

#table(
  columns: (auto, ) * 6,
  "ai", "oi", "ui", "au", "eu", "iu",  
  quenya[ai], quenya[oi], quenya[ui], 
  quenya[au], quenya[eu], quenya[iu], 
)

=== Substitution rules<sec-quenya-subst-rules>

The equivalences mentioned in Section~@sec-quenya-gen should give an approximate phonetic transcription from the Latin alphabet to tengwar in the Quenya mode. 
This does not mean, however, that the spelling is correct. 
Further substitution rules are required for that; see for instance Reference @tengwar-eruantalince.

#v(text-list-sep)

- As briefly mentioned above, a short vowel sound following a consonant sound is written as a tehta on the latter. For instance, _númen_ (_west_) is written #quenya[númen], with #quenya[me] replacing #quenya[m:e]. This does not apply to long vowels, the second consecutive vowel after a consonant, or (obviously) to a vowel sound at the start of a word.

- If #quenya[r] is followed by a vowel or _y_ and a vowel, it is replaced by #quenya[£r].

- If #quenya[y] follows a consonant, it is replaced by two dots under the corresponding tengwa: #quenya[n:y] → #quenya[ny].

- If a single #quenya[s] follows a consonant, it is replaced by an ‘s-hook’: for instance, #quenya[t:s] → #quenya[ts].

- If #quenya[s] is followed by a short vowel, it is reversed: #quenya[s:a] → #quenya[sa].

- If #quenya[ss] is followed by a short vowel, it is reversed: #quenya[ss:a] → #quenya[ssa].

- If #quenya[h] is part of the consonant cluster _hl_ or _hr_, it is written with a vertical bar as in _hrívë_ (_winter_): #quenya[hrívë].

- If #quenya[h] is not part of the consonant cluster _hl_ or _hr_, nor at the start of a word, it is replaced by #quenya[£h].

- Two successive identical tengwar with no tehta on the first one are replaced by a single tengwa with a wavy line under it. For instance, the word _anna_ (_gift_) is written #quenya[anna], with #quenya[nn] replacing two #quenya[n]s. Similarly, in #quenya[quetta] (_quetta_), #quenya[tt] replaces two #quenya[t]s.

=== Capital letters

There is, as far as I am aware, no standard way to write capital letters in Tengwar. 
One option is to use bold to denote a capital letter: 

#v(paragraph-skip-b)

#tengwar-snippet("quenya[#strong[Va]limar]")

=== Punctuation

The module provides the following punctuation symbols: 

#v(paragraph-skip-b)

#box(table(
  columns: (auto, ) * 10,
  strong("input"), ",", ".", "-", "—", "!", "?", "(", ")", "/",
  strong("output"), quenya[,], quenya[.], quenya[-], quenya[—], quenya[!], quenya[?], quenya[(], quenya[)], quenya[/]
))

#v(paragraph-skip-b)

#h(-paragraph-indent) *Note:* Generally, parentheses in Quenya are denoted by the single symbol #quenya[/]—there is no distinction between opening and closing parentheses. 
We deviate from this convention by mapping the symbol ‘(’ to #quenya[(] and ‘)’ to #quenya[)]. 
The proper Tengwar parenthesis is mapped to ‘/’.

#v(paragraph-skip-b)

End-of-paragraph symbols can be obtained by combining commas and periods:

#v(paragraph-skip-b)

#tengwar-snippet("quenya[.-]") #h(1em)
#tengwar-snippet("quenya[.,]") #h(1em)
#tengwar-snippet("quenya[..]") #h(1em)
#tengwar-snippet("quenya[,.,]")

#v(paragraph-skip-b)

#h(-paragraph-indent) The decorations #h(0.5em)#quenya[»] and #quenya[«]#h(0.5em) are obtained using the French quotation marks ‘»’ and ‘«’:

#v(paragraph-skip-b)

#tengwar-snippet("quenya[»quenya«]", margin: 4pt)

#v(paragraph-skip-b)

#h(-paragraph-indent) The symbol ‘:’ can be used to prevent glyph combination: 

#v(paragraph-skip-b)

#tengwar-snippet("quenya[nn n:n]") #h(1em)
#tengwar-snippet("quenya[na n:a]")

=== Number system

Quenya uses a base-12 system, with 12 digits listed in the following table: 

#v(paragraph-skip-b)

#box(table(
  columns: (auto,) * 12,
  rows: (auto,) * 2,
  "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", 
  quenya[0], quenya[1], quenya[2], quenya[3], quenya[4], quenya[5],
  quenya[6], quenya[7], quenya[8], quenya[9], quenya[10], quenya[11],
))

#v(paragraph-skip-b)

#h(-paragraph-indent)In contrast with the usual system, multi-digit numbers are written (from left to right) from least to most significant digit. 

#v(paragraph-skip-b)

#h(-paragraph-indent)
*Examples:*

#v(paragraph-skip-b)

#tengwar-snippet("quenya[1]") #h(1em)
#tengwar-snippet("quenya[11]") #h(1em)
#tengwar-snippet("quenya[12]") #h(1em)
#tengwar-snippet("quenya[100]") #h(1em)
#tengwar-snippet("quenya[123]") #h(1em)
#tengwar-snippet("quenya[144]") #h(1em)
#tengwar-snippet("quenya[1000]") #h(1em)
#tengwar-snippet("quenya[10000]") #h(1em)
#tengwar-snippet("quenya[65537]") #h(1em)

#pagebreak()

=== Example: Namárië

One of the most famous texts in Quenya is the poem _Namárië_ (#quenya[Namárië]), originally written in Reference~@lotr #footnote[Book 2, ch. 8 "Farewell to Lórien"] and available for instance in Reference~@namarie.
Below we show the same text without (left) and with (right) the `#show: quenya` command.
We use a spacing between line of 0.7em to clearly separate them (some tengwar have a relatively large vertical extension).

#v(4*paragraph-skip-b)

#[
#show: rest => columns(2, rest)
#set par(
  justify: false,
  leading: 0.7em,
  first-line-indent: 0em)
#show par: it => it + v(0.5em)

#set text(size: 12pt)

#let txt = [

*Namárië*

Ai! laurië lantar lassi súrinen, \
yéni únótimë ve rámar aldaron! \
Yéni ve lintë yuldar avánier \
mi oromardi lisse-miruvóreva \
Andúnë pella, Vardo tellumar \
nu luini yassen tintilar i eleni \
ómaryo airetári-lírinen.

Sí man i yulma nin enquantuva?

An sí Tintallë Varda Oiolossëo \
ve fanyar máryat Elentári ortanë, \
ar ilyë tier undulávë lumbulë, \
ar sindanóriello caita mornië \
i falmalinnar imbë met, ar hísië \
untúpa Calaciryo míri oialë. \
Sí vanwa ná, Rómello vanwa, Valimar!

Namárië! Nai hiruvalyë Valimar. \
Nai elyë hiruva. Namárië!
]

#txt

#colbreak()

#set text(size: 11pt)
#show: quenya

#txt

]

#pagebreak()

// == Sindarin—Mode of Gondor
// 
// *Not yet implemented*
// 
// == Sindarin—Mode of Beleriand
// 
// *Not yet implemented*
// 
// == Black Speech
// 
// *Not yet implemented*
// 
// #pagebreak()

== The One Ring inscription

Although the Black Speech is not implemented yet, the One Ring inscription can be reproduced using the Quenya mode as follows:#footnote[This is obviously a bit of a hack, meant only to show how the limitations of having only one mode implemented can be circumvented. This example is not supposed to be stable and might render differently in a later version.]

#v(paragraph-skip-b)

#let ring-inscr-quenya = "
  _»Ka:nssangw:nd£rombta£lo£kwô, Ka:nssangw:ngwmbe­talo« 
  #linebreak()#v(0.7em) 
  Ka:nssangwth£rquata£lo£kwô, £Ngwa:mb£rossmokii:qu£rpe­talo_
"

#code-block("quenya[" + ring-inscr-quenya + "]")

#v(paragraph-skip-b)

Obviously, that's not quite how the ring inscription is supposed to sound.
One reason is simply that the Quenya and Black Speech modes have different relations between symbols and sounds: to obtain the same written result, one has to ‘transcribe’ the phonetic description to how it would be read in the Quenya mode. 
Another difference is that some of the tengwa forms used in the ring inscription are generally not used in Quenya; we thus use the symbol `£` to get variants. 
We also use `£` to switch between #quenya[r] and #quenya[£r].
Finally, words are separated with `:` to avoid repeated consonants being combined.
Here is the result, with a colour gradient in the background to mimic a golden surface and on the text to represent incandescence:

#v(paragraph-skip-b)

#let code-ring-inscription-quenya = "#set text(top-edge: \"ascender\", bottom-edge: \"descender\", 
          fill: gradient.linear(rgb(150,0,0), rgb(100,20,0), rgb(255,0,0), space: rgb, angle: 20deg))
#align(center, block(
  fill: gradient.linear(rgb(157,103,7), rgb(250,250,152), rgb(157,103,7), space: rgb, angle: 80deg),
  inset: (top: 1em, left: 1em, right: 1em, bottom: 1.5em),
  radius: 5pt,
  quenya(eval(ring-inscr-quenya, mode: \"markup\"))))"

#eval(code-ring-inscription-quenya, mode: "markup", scope: (quenya: quenya, ring-inscr-quenya: ring-inscr-quenya))

#v(paragraph-skip-b)

The full code for the above example is: 

#v(paragraph-skip-b)

#code-block("#let ring-inscr-quenya = \"" + ring-inscr-quenya + "\"\n" + code-ring-inscription-quenya)

#v(paragraph-skip-b)

#pagebreak()

= Math mode? 

Use of tengwar in math mode is not fully supported, although it should work in simple cases. 
In math mode, you'll need to apply the conversion function to each part of a formula you want to write in Tengwar, which can be made slightly less cumbersome by redefining it to a shorter command:

#show-code("#let q = quenya 
$
  #q[6] times #q[7] = #q[42]
$
#v(1em)
$
  integral_#q[0]^#q[2] #q[t]^#q[3] upright(d)#q[t]
  = [ #q[t]^#q[4] / #q[4] ]_#q[0]^#q[2]
  = #q[2]^#q[4] / #q[4]
  = #q[16] / #q[4]
  = #q[4]
$
#v(1em)
$
  #q[t] :
    mat(delim: \"(\",
      RR & -> RR ;
      #q[a] & |-> #q[a]^#q[123])
  => 
  (upright(d)#q[t]lr((#q[a]))) / (upright(d)#q[a]) = #q[123 a]^#q[122] 
$
")

Writing math-heavy content in tengwar would probably require a specific module, though, as well as a different tengwar font designed for this purpose (or a math font designed to work well with a tengwar font).

#pagebreak()

= How to contribute

Any kind of contribution is warmly welcome! Here are a few ways you can help: 

#v(text-list-sep)

- *Bug reports:* Some text rendering incorrectly in Tengwar? Unexpected formatting? Any other issue with the code or documentation? Please report it! This module was only tested on a very small corpus so far, and identifying any corner case where it does not work as intended is very useful!

- *References:* There is a lot of content available, both online and in printed books and magazines, about the languages invented by Tolkien, how they relate to his works, and their relevance in today's cultural fabric. I am unfortunately not very familiar with them; but if you know good references please let me know and I'll cite them.

- *Language help:* My knowledge of Tengwar and the languages invented by J. R. R. Tolkien is quite superficial, and I may well have missed or misunderstood some of the rules for writing in Tengwar. If you spot anything that looks wrong, please let me know!

- *Implementation:* The Typst code is likely not quite as efficient nor as clean as it could be. If you can see better ways to implement something, please feel free to let me now or to submit a pull request with an improved version!

- *Feature requests:* Any feature request is welcome. I can't promise I'll have the time and knowledge to implement everything that would be nice to have; but if you'd like to see something implemented please let me know—or submit a pull request if you've already implemented it!

#block(breakable: false, width: 100%, height: paragraph-skip-b + text-list-sep, align(right)[#quenya[Hantanyel!]])

#bibliography("manual_files/biblio.yml")
