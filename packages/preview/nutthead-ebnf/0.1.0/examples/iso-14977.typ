#import "@preview/nutthead-ebnf:0.1.0": *

#set page(width: auto, height: auto, margin: .5cm, fill: white)

// ISO/IEC 14977:1996 - EBNF defined in EBNF (Section 8.2)
// This is the meta-grammar that defines Extended BNF itself
#ebnf(
  mono-font: "JetBrains Mono",

  // Top-level structure
  prod(n[syntax], {
    alt[#n[syntax-rule] #rep[#n[syntax-rule]]][complete grammar]
  }),

  prod(n[syntax-rule], {
    alt[#n[meta-identifier] #t[=] #n[definitions-list] #t[;]][production rule]
  }),

  // Definitions and alternatives
  prod(n[definitions-list], {
    alt[#n[single-definition] #rep[#t[\|] #n[single-definition]]][alternatives]
  }),

  prod(n[single-definition], {
    alt[#n[term] #rep[#t[,] #n[term]]][concatenation]
  }),

  // Terms and factors
  prod(n[term], {
    alt[#n[factor] #opt[#t[-] #n[exception]]][with optional exception]
  }),

  prod(n[exception], {
    alt[#n[factor]][excluded element]
  }),

  prod(n[factor], {
    alt[#opt[#n[integer] #t[\*]] #n[primary]][with optional repetition count]
  }),

  // Primary elements
  prod(n[primary], {
    alt[#n[optional-sequence]][optional]
    alt[#n[repeated-sequence]][repetition]
    alt[#n[grouped-sequence]][grouping]
    alt[#n[meta-identifier]][nonterminal reference]
    alt[#n[terminal-string]][terminal]
    alt[#n[special-sequence]][special]
    alt[#n[empty-sequence]][empty]
  }),

  // Sequence types
  prod(n[optional-sequence], {
    alt[#t[\[] #n[definitions-list] #t[\]]][zero or one]
  }),

  prod(n[repeated-sequence], {
    alt[#t[\{] #n[definitions-list] #t[\}]][zero or more]
  }),

  prod(n[grouped-sequence], {
    alt[#t[\(] #n[definitions-list] #t[\)]][explicit grouping]
  }),

  // Lexical elements
  prod(n[terminal-string], {
    alt[#t[\'] #n[character] #rep[#n[character]] #t[\']]["single-quoted"]
    alt[#t[\"] #n[character] #rep[#n[character]] #t[\"]][double-quoted]
  }),

  prod(n[meta-identifier], {
    alt[#n[letter] #rep[#n[letter] | #n[digit]]][nonterminal name]
  }),

  prod(n[integer], {
    alt[#n[digit] #rep[#n[digit]]][repetition count]
  }),

  prod(n[special-sequence], {
    alt[#t[?] #rep[#n[character]] #t[?]][implementation-defined]
  }),

  prod(n[empty-sequence], {
    alt[#empty][epsilon production]
  }),

  // Character classes
  prod(n[letter], {
    alt[#t[a] | #t[b] | #t[...] | #t[z] | #t[A] | #t[...] | #t[Z]][alphabetic]
  }),

  prod(n[digit], {
    alt[#t[0] | #t[1] | #t[...] | #t[9]][numeric]
  }),

  prod(n[character], {
    alt[#n[letter] | #n[digit] | #special[any printable character]][any character]
  }),
)
