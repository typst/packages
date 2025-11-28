#import "../ebnf.typ": *

#set page(width: auto, height: auto, margin: .5cm, fill: white)

// ISO/IEC 14977:1996 - EBNF defined in EBNF (Section 8.2)
// This is the meta-grammar that defines Extended BNF itself
#syntax(
  mono-font: "JetBrains Mono",

  // Top-level structure
  syntax-rule(meta-identifier[syntax], {
    definitions-list[#meta-identifier[syntax-rule] #repeated-sequence[#meta-identifier[syntax-rule]]][complete grammar]
  }),

  syntax-rule(meta-identifier[syntax-rule], {
    definitions-list[#meta-identifier[meta-identifier] #terminal-string[=] #meta-identifier[definitions-list] #terminal-string[;]][production rule]
  }),

  // Definitions and alternatives
  syntax-rule(meta-identifier[definitions-list], {
    definitions-list[#meta-identifier[single-definition] #repeated-sequence[#terminal-string[\|] #meta-identifier[single-definition]]][alternatives]
  }),

  syntax-rule(meta-identifier[single-definition], {
    definitions-list[#meta-identifier[term] #repeated-sequence[#terminal-string[,] #meta-identifier[term]]][concatenation]
  }),

  // Terms and factors
  syntax-rule(meta-identifier[term], {
    definitions-list[#meta-identifier[factor] #optional-sequence[#terminal-string[-] #meta-identifier[exception]]][with optional exception]
  }),

  syntax-rule(meta-identifier[exception], {
    definitions-list[#meta-identifier[factor]][excluded element]
  }),

  syntax-rule(meta-identifier[factor], {
    definitions-list[#optional-sequence[#meta-identifier[integer] #terminal-string[\*]] #meta-identifier[primary]][with optional repetition count]
  }),

  // Primary elements
  syntax-rule(meta-identifier[primary], {
    definitions-list[#meta-identifier[optional-sequence]][optional]
    definitions-list[#meta-identifier[repeated-sequence]][repetition]
    definitions-list[#meta-identifier[grouped-sequence]][grouping]
    definitions-list[#meta-identifier[meta-identifier]][nonterminal reference]
    definitions-list[#meta-identifier[terminal-string]][terminal]
    definitions-list[#meta-identifier[special-sequence]][special]
    definitions-list[#meta-identifier[empty-sequence]][empty]
  }),

  // Sequence types
  syntax-rule(meta-identifier[optional-sequence], {
    definitions-list[#terminal-string[\[] #meta-identifier[definitions-list] #terminal-string[\]]][zero or one]
  }),

  syntax-rule(meta-identifier[repeated-sequence], {
    definitions-list[#terminal-string[\{] #meta-identifier[definitions-list] #terminal-string[\}]][zero or more]
  }),

  syntax-rule(meta-identifier[grouped-sequence], {
    definitions-list[#terminal-string[\(] #meta-identifier[definitions-list] #terminal-string[\)]][explicit grouping]
  }),

  // Lexical elements
  syntax-rule(meta-identifier[terminal-string], {
    definitions-list[#terminal-string[\'] #meta-identifier[character] #repeated-sequence[#meta-identifier[character]] #terminal-string[\']]["single-quoted"]
    definitions-list[#terminal-string[\"] #meta-identifier[character] #repeated-sequence[#meta-identifier[character]] #terminal-string[\"]][double-quoted]
  }),

  syntax-rule(meta-identifier[meta-identifier], {
    definitions-list[#meta-identifier[letter] #repeated-sequence[#meta-identifier[letter] | #meta-identifier[digit]]][nonterminal name]
  }),

  syntax-rule(meta-identifier[integer], {
    definitions-list[#meta-identifier[digit] #repeated-sequence[#meta-identifier[digit]]][repetition count]
  }),

  syntax-rule(meta-identifier[special-sequence], {
    definitions-list[#terminal-string[?] #repeated-sequence[#meta-identifier[character]] #terminal-string[?]][implementation-defined]
  }),

  syntax-rule(meta-identifier[empty-sequence], {
    definitions-list[#empty-sequence][epsilon production]
  }),

  // Character classes
  syntax-rule(meta-identifier[letter], {
    definitions-list[#terminal-string[a] | #terminal-string[b] | #terminal-string[...] | #terminal-string[z] | #terminal-string[A] | #terminal-string[...] | #terminal-string[Z]][alphabetic]
  }),

  syntax-rule(meta-identifier[digit], {
    definitions-list[#terminal-string[0] | #terminal-string[1] | #terminal-string[...] | #terminal-string[9]][numeric]
  }),

  syntax-rule(meta-identifier[character], {
    definitions-list[#meta-identifier[letter] | #meta-identifier[digit] | #special-sequence[any printable character]][any character]
  }),
)
