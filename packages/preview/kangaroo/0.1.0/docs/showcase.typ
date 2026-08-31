#import "@local/kangaroo:0.1.0": *

#import "@preview/codly:1.3.0": *
#show: codly-init.with()

#set document(
  title: "Kangaroo Showcase",
  author: "Simone Ragusa",
  keywords: ("cryptography", "proof", "library", "hybrid"),
  date: datetime(year: 2026, month: 08, day: 30),
)

#set heading(numbering: "1.1")
#show heading: it => {
  let num = text(
    size: 0.9em,
    fill: luma(35%),
    number-width: "tabular",
    counter(heading).display() + h(0.45em),
  )
  move(dx: -measure(num).width, num + it.body)
}
#show heading: set text(font: "Libertinus Sans")
#show heading.where(level: 1): set text(size: 20pt)
#show heading.where(level: 2): set text(size: 14pt)

#let _text = read("showcase.typ")
#let _snips-start = _text.matches(regex("\n *//@snip-start-(.*)\n"))
#let _snips-end = _text.matches(regex("\n *//@snip-end\n"))
#assert(
  _snips-start.len() == _snips-end.len(),
  message: str(_snips-start.len()) + " != " + str(_snips-end.len()),
)

#let _dedent(s) = {
  let lines = s.split("\n")
  let common = none

  for line in lines {
    if line.trim() != "" {
      let indent = line.match(regex("^[ \t]*")).text.len()
      common = if common == none { indent } else { calc.min(common, indent) }
    }
  }

  if common == none { return s }

  lines.map(line => if line.trim() == "" { "" } else { line.slice(common) }).join("\n")
}

#let snip(name) = {
  let index = _snips-start.position(v => name in v.captures)
  let snippet = _text.slice(_snips-start.at(index).end, _snips-end.at(index).start)
  snippet = _dedent(snippet)

  codly(
    header: v(-0.6em),
    footer: v(-0.6em),
    radius: 0pt,
    inset: (x: 0.16em, y: 0.28em),
    fill: luma(250),
    zebra-fill: none,
    stroke: 0.75pt + luma(210),
    display-name: false,
    display-icon: false,
    number-format: (..nums) => if snippet.matches("\n").len() == 0 {
      none
    } else {
      text(fill: gray, h(0.2em) + numbering("1", ..nums) + h(0.2em))
    },
    number-align: right + horizon,
  )

  align(center, raw(snippet, block: true))
}

#let island(body, eos: false) = [
  #h(2.25pt)
  #box(
    fill: luma(250),
    stroke: 0.75pt + luma(210),
    outset: 2.25pt,
    body,
  )
  #if not eos { h(2.25pt) }
]

#let showcase(..things) = {
  grid(
    columns: (50%,) * 2,
    column-gutter: 1.2em,
    row-gutter: 0.65em,
    inset: (x, _) => if x == 0 { 1.5pt } else { 0pt },
    align: center + horizon,
    stroke: (x, _) => if x == 0 { 0.75pt + luma(210) } else { none },
    ..things,
  )
}

#[
  #set align(center)
  #set text(font: "Libertinus Sans", size: 22pt)
  #v(3.5em)
  #title[Kangaroo]
  #v(-0.5em)
  Showcase

  #v(2.5em)

  #set text(size: 14pt)
  #library(title: lib(subject: $Sigma$)[ots-left])[
    - #proc(subr[ots.enc], args: $M_L, M_R$)
      - $K <<- Sigma\.cal(K)$
      - $C := Sigma\.algo("Enc")(K, #hl[$M_L$])$
      - return $C$
  ]

  #v(1.5em)

  #set text(size: 12pt)
  Cryptographic notation and game-hopping proofs \
  in the style of The Joy of Cryptography

  #set align(bottom)
  #set text(size: 16pt)
  Version 0.1.0
]
#pagebreak()

#set par(
  justify: true,
  justification-limits: (tracking: (min: -0.01em, max: 0.02em)),
)
#show link: set text(fill: rgb("#0000ff"))
#show ref: it => {
  let el = it.element
  if el == none { return it }
  link(el.location(), el.body)
}

= Notation

== Security parameter

The security parameter uses the lowercase lambda Greek letter.

#showcase(
  [
    //@snip-start-secpar
    $secpar$
    //@snip-end
  ],
  snip("secpar"),
  [
    //@snip-start-secpar-unary
    $#secpar-unary$
    //@snip-end
  ],
  snip("secpar-unary"),
)

== Adversary

The adversary is identified by an uppercase calligraphic A.

#showcase(
  [
    //@snip-start-adv
    #adv
    //@snip-end
  ],
  snip("adv"),
)

Other adversaries may be indicated using grouped primes.

#showcase(
  [
    //@snip-start-adv-alt
    $adv', adv'', adv''', ...$
    //@snip-end
  ],
  snip("adv-alt"),
)

== Distinguishing advantage

An advantage term is characterized by a security notion, a subject attempting
to achieve that notion, and the adversary attacking said notion.

#showcase(
  [
    //@snip-start-advantage
    #advantage("IND-CPA", $Sigma$)
    //@snip-end
  ],
  snip("advantage"),
  [
    //@snip-start-advantage-b
    #advantage("PRF", $F$, adversary: $adv'$)
    //@snip-end
  ],
  snip("advantage-b"),
)

== Asymptotics

Negligible and polynomial functions of the security parameter (or a custom parameter).

#showcase(
  [
    //@snip-start-negl
    #negl(), #negl(param: $n$)
    //@snip-end
  ],
  snip("negl"),
  [
    //@snip-start-poly
    #poly(), #poly(param: $n$)
    //@snip-end
  ],
  snip("poly"),
)

== Bad event

Consider a library that includes a boolean variable named #bad, and
assume that after #bad is set to `true` it remains `true` forever.

The bad event is triggered if the library ever sets #bad to `true`.

#showcase(
  [
    //@snip-start-bad
    $bad := #`true`$
    //@snip-end
  ],
  snip("bad"),
)

== Library names

Libraries are identified by an uppercase calligraphic L and must have a name.
Optionally, they may include a subject (e.g., a cryptographic construction, an
algebraic structure).

#showcase(
  [
    //@snip-start-lib
    #lib[test]
    //@snip-end
  ],
  snip("lib"),
  [
    //@snip-start-lib-sigma
    #lib(subject: $Sigma$)[cpa-real]
    //@snip-end
  ],
  snip("lib-sigma"),
  [
    //@snip-start-lib-gg
    #lib(subject: $GG$)[ddh-rand]
    //@snip-end
  ],
  snip("lib-gg"),
)

== Linking and chaining

A small diamond symbol denotes linking of libraries and calling
programs (i.e., adversaries).

#showcase(
  [
    //@snip-start-linked
    #linked
    //@snip-end
  ],
  snip("linked"),
  [
    //@snip-start-linked-libs
    $adv linked lib("1")$
    //@snip-end
  ],
  snip("linked-libs"),
)

Arbitrary elements can be chained together horizontally, including
boxes (see @sec:examples).

#showcase(
  [
    //@snip-start-chain
    #chain(adv, linked, lib[1], $=>$, `true`)
    //@snip-end
  ],
  snip("chain"),
)

== Interchangeability and indistinguishability

Libraries can be shown to be interchangeable (i.e., zero advantage for every
calling program) or indistinguishable (i.e., negligible positive advantage
for every polynomial-time calling program).

#showcase(
  [
    //@snip-start-interc
    #interc.is, #interc.not
    //@snip-end
  ],
  snip("interc"),
  [
    // #chain(lib[1], interc.is, lib[2])
    //@snip-start-interc-libs
    $lib("left") interc.is lib("right")$
    //@snip-end
  ],
  snip("interc-libs"),
)

#showcase(
  [
    //@snip-start-indist
    #indist.is, #indist.not
    //@snip-end
  ],
  snip("indist"),
  [
    //@snip-start-indist-libs
    $lib("left") indist.is lib("right")$
    //@snip-end
  ],
  snip("indist-libs"),
)

== Bits and literals

Bit strings and literals are typeset in monospace using a shade of red
automatically adjusted with the text color. Alternatively, the color can
be set manually.

#showcase(
  [
    //@snip-start-bitstr
    #bit[10011101]
    //@snip-end
  ],
  snip("bitstr"),
  [
    //@snip-start-zeros-ones
    $bit("0")^n$, $bit("1")^n$
    //@snip-end
  ],
  snip("zeros-ones"),
  [
    //@snip-start-hex
    #bit[9d] #bit[54] #bit[2e]
    //@snip-end
  ],
  snip("hex"),
  [
    //@snip-start-lit-str
    #bit[YELLOW SUBMARINE]
    //@snip-end
  ],
  snip("lit-str"),
  [
    //@snip-start-lit-domain
    #bit(fill: rgb("#2f6430"))[example.com]
    //@snip-end
  ],
  snip("lit-domain"),
  [
    //@snip-start-lit-ipv4
    #bit(fill: rgb("#4f5084"))[127.0.0.1]
    //@snip-end
  ],
  snip("lit-ipv4"),
)

The set of bits can be used to sample binary strings.

#showcase(
  [
    //@snip-start-bits
    #bits
    //@snip-end
  ],
  snip("bits"),
  [
    //@snip-start-bits-pairs
    $bits^2 = {bit("00"), bit("01"),
      bit("10"), bit("11")}$
    //@snip-end
  ],
  snip("bits-pairs"),
  [
    //@snip-start-bits-usage
    $K <<- bits^secpar$
    //@snip-end
  ],
  snip("bits-usage"),
)

#pagebreak()
= Pseudocode

== Algorithm names

An algorithm of a cryptographic construction is written in sans-serif style.

#showcase(
  [
    //@snip-start-algo
    #algo[KeyGen]
    //@snip-end
  ],
  snip("algo"),
  [
    //@snip-start-algo-call
    $Sigma\.algo("Enc")(K, M)$
    //@snip-end
  ],
  snip("algo-call"),
)

== Subroutine names

The name of a subroutine is stylized in small capitals. The special #end-of-time
subroutine executes just as the calling program terminates, and can be used to
simplify the analysis of a bad event.

#showcase(
  [
    //@snip-start-subr
    #subr[otp.enc]
    //@snip-end
  ],
  snip("subr"),
  [
    //@snip-start-subr-eot
    #end-of-time
    //@snip-end
  ],
  snip("subr-eot"),
)

== Procedures

Algorithm and subroutine definitions in pseudocode have their names underlined,
always followed by a pair of parentheses and a colon. Arguments, if present, are
enclosed in parentheses.

#showcase(
  [
    //@snip-start-proc
    #proc(algo[KeyGen])
    //@snip-end
  ],
  snip("proc"),
  [
    //@snip-start-proc-args
    #proc(subr[otp.enc], args: $M$)
    //@snip-end
  ],
  snip("proc-args"),
)

The #end-of-time subroutine is the only exception.

#showcase(
  [
    //@snip-start-proc-eot
    #proc(end-of-time)
    //@snip-end
  ],
  snip("proc-eot"),
)

== Comments

Code comments are typeset in italics. The default gray color can be changed.

#showcase(
  [
    //@snip-start-comment
    #comment[samples uniformly at random]
    //@snip-end
  ],
  snip("comment"),
  [
    //@snip-start-comment-black
    #comment(fill: black)[fair dice roll]
    //@snip-end
  ],
  snip("comment-black"),
)

== Codes and libraries

A code contains lists of pseudocode lines. Both #list and #enum can be
used; switching between the two is useful for avoiding the automatic
#island[`tight: true`] setting when inserting a blank line.

Code indentation is handled automatically, following the indentation of list items.

#showcase(
  [
    //@snip-start-code-dh
    #code[
      - $a <<- ZZ_n$
      - $A := g^a$
    ]
    //@snip-end
  ],
  snip("code-dh"),
  [
    //@snip-start-code-otp
    #code[
      - #proc(algo[Enc], args: $K,M$)
        - $C := K xor M$
        - return $C$
    ]
    //@snip-end
  ],
  snip("code-otp"),
)

A library is similar to a code, except that it can have an optional
header containing a title, and its box has a solid border.

#showcase(
  [
    //@snip-start-library
    #library[
      - #proc(subr[sample])
        - $R <<- bits^n$
        - return $R$
    ]
    //@snip-end
  ],
  snip("library"),
  [
    //@snip-start-library-title
    #library(title: lib[otp-real])[
      - #proc(subr[otp.enc], args: $M$)
        - $K <<- bits^(|M|)$
        - $C := K xor M$
        - return $C$
    ]
    //@snip-end
  ],
  snip("library-title"),
)

The background color of both codes and libraries can be changed. The `fill` parameter
of #library can be set to either a single color to set the background of its code area
or to a pair of colors to set the header and code backgrounds, respectively.

#showcase(
  grid.cell(fill: black)[
    //@snip-start-code-dh-black
    #set text(fill: white)
    #code(fill: black)[
      - $a <<- ZZ_n$
      - $A := g^a$
    ]
    //@snip-end
  ],
  snip("code-dh-black"),
  grid.cell(fill: black)[
    //@snip-start-library-black
    #set text(fill: white)
    #library(fill: black)[
      - #proc(subr[sample])
        - $R <<- bits^n$
        - return $R$
    ]
    //@snip-end
  ],
  snip("library-black"),
  grid.cell(fill: black)[
    //@snip-start-library-title-black
    #set text(fill: white)
    #library(
      title: lib[otp-real],
      fill: (luma(120), black),
    )[
      - #proc(subr[otp.enc], args: $M$)
        - $K <<- bits^(|M|)$
        - $C := K xor M$
        - return $C$
    ]
    //@snip-end
  ],
  snip("library-title-black"),
)

== Highlighting

Highlighting can be used to indicate changes in a sequence of hybrid games
or to emphasize specific terms in prose.

#showcase(
  [
    //@snip-start-hl
    #hl[code changes]
    //@snip-end
  ],
  snip("hl"),
  [
    //@snip-start-hl-math
    #hl[$beta <<- ZZ_n$]
    //@snip-end
  ],
  snip("hl-math"),
  [
    //@snip-start-hl-mixed
    #library[
      - #proc(subr[sample])
        - #hl(comment[$R <<- bits^n$])
        - $R #hl[$:= #bit("0x04")$]$
        - return $R$
    ]
    //@snip-end
  ],
  snip("hl-mixed"),
  [
    //@snip-start-hl-library
    #hl(library(title: lib[otp-rand])[
      - #proc(subr[otp.enc], args: $M$)
        - $R <<- bits^(|M|)$
        - return $R$
    ])
    //@snip-end
  ],
  snip("hl-library"),
)

#pagebreak()
= Full examples <sec:examples>

== Hybrid sequence (partial)

#block(width: 100%, inset: (y: 0.4em))[
  //@snip-start-prf-enc
  #let cpa-real = library(title: lib(subject: $Sigma$)[cpa-real])[
    - #hl[$K <<- bits^secpar$]

    - #proc(subr[cpa.enc], args: $M$)
      - #comment[$R||S <<- algo("Enc")(K, M)$]
      - $R <<- bits^lambda$
      - $Y := #hl[$F(K, R)$]$
      - $S := Y xor M$
      - return $R||S$
  ]

  #let prf-real = library(title: lib(subject: $F$)[prf-real])[
    - $K <<- bits^secpar$

    - #proc(subr[prf.query], args: $X$)
      - return $F(K, X)$
  ]

  #let hyb-1 = chain(
    library[
      - #proc(subr[cpa.enc], args: $M$)
        - $R <<- bits^lambda$
        - $Y := #hl[$subr("prf.query")(R)$]$
        - $S := Y xor M$
        - return $R||S$
    ],
    linked,
    prf-real,
  )

  #align(center, chain(cpa-real, interc.is, hyb-1))
  //@snip-end
]

#snip("prf-enc")

#pagebreak()
== Security definition

#block(width: 100%, inset: (y: 0.4em))[
  //@snip-start-ke
  #let ke-real = library(title: lib[ke-real])[
    - $(T, K_1, K_2) := (P_1 harpoons.rtlb P_2)$

    - #proc(subr[ke.eavesdrop])
      - return $(T, K_1)$
  ]

  #let ke-rand = library(title: lib[ke-rand])[
    + $(T, K_1, K_2) := (P_1 harpoons.rtlb P_2)$
    + #hl[$K' <<- cal(K)$]

    - #proc(subr[ke.eavesdrop])
      - return $(T, #hl[$K'$])$
  ]

  #align(center, chain(ke-real, indist.is, ke-rand))
  //@snip-end
]

#snip("ke")

== Distinguishing advantage

#block(width: 100%, inset: (y: 0.4em))[
  //@snip-start-advantage-full
  $
    advantage("IND-CPA", Sigma) = lr(
      |Pr[adv linked #lib(subject: $Sigma$)[cpa-real] => #`true`]
      - Pr[adv linked #lib(subject: $Sigma$)[cpa-rand] => #`true`]|,
      size: #150%
    ) <= negl()
  $
  //@snip-end
]

#snip("advantage-full")
