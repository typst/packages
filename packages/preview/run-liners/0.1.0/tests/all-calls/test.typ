
// exhaustive-test.typ
// =============================================================================
// EXHAUSTIVE TESTS for your run-in library
// =============================================================================
// This file demonstrates almost every combination of named/positional arguments 
// for run-in-enum, run-in-list, run-in-terms, run-in-verse, and run-in-join, 
// including zero items, single item, multiple items, bracketed commas, etc.
//
// Adjust import path to your library as needed:
//
//    #import "/lib.typ": *    // or whatever your actual path is
//
// Then compile. 
// =============================================================================

#import "/lib.typ": *

#set page(height: auto, width: 6in, margin: 1em)

// A small helper for easy labeling:
#let heading = (text) => {
  [#strong(text) "\n"]
}
#let subheading = (text) => {
  [#emph(text) "\n"]
}

// =============================================================================
// 1) run-in-enum TESTS
// =============================================================================
#heading("1) run-in-enum Tests")

// 1A. NO NAMED ARGUMENTS (uses defaults: separator=auto, coordinator=and, etc.)
#subheading("1A: No named arguments")
#text("Zero items => Should produce nothing:")
#run-in-enum()


#text("Single item => Should just produce \"(1) <item>\":")
#run-in-enum([Single item here])


#text("Two items => Typically comma, then \"and\":")
#run-in-enum([First], [Second])


#text("Three items => Commas, then \"and\" before last:")
#run-in-enum([Apple], [Banana], [Cherry])


#text("Three items w/ bracketed comma => triggers semicolons:")
#run-in-enum([Item1], [[test, bracketed]], [Item3])


// 1B. ALL NAMED ARGUMENTS
#subheading("1B: All named arguments")
#text("separator=', ', coordinator='or', numbering-pattern='(A)', custom numbering-formatter => bold:")
#run-in-enum(
  separator: ", ",
  coordinator: "or",
  numbering-pattern: "(A)",
  numbering-formatter: (val) => [#strong(val)],
  [Alpha],
  [Beta],
  [Gamma]
)


#text("separator='; ', coordinator=none, numbering-pattern='(i)', numbering-formatter=>italics, 4 items:")
#run-in-enum(
  separator: "; ",
  coordinator: none,
  numbering-pattern: "(i)",
  numbering-formatter: (val) => [#emph(val)],
  [Item A],
  [[Bracket, comma]],
  [Item C],
  [Item D]
)


// 1C. MIXED SCENARIOS
#subheading("1C: Mixed scenarios")
#text("Two items, coordinator='and/or':")
#run-in-enum(
  coordinator: "and/or",
  [Red],
  [Blue]
)


#text("Single item, custom numbering-pattern='(###)':")
#run-in-enum(
  numbering-pattern: "( -- 1 -- )",
  [JustOne]
)


// =============================================================================
// 2) run-in-list TESTS
// =============================================================================
#heading("2) run-in-list Tests (bulleted run-in)")

// 2A. NO NAMED ARGUMENTS (uses defaults: separator=auto, coordinator=and, marker=[•])
#subheading("2A: No named arguments")
#text("Zero items => Should produce nothing:")
#run-in-list()


#text("Single item => One bullet, no join needed:")
#run-in-list([Only me])


#text("Two items => bullet for each, comma by default, then 'and':")
#run-in-list([First], [Second])


#text("Three items => bracketed comma triggers semicolons, plus 'and':")
#run-in-list([One], [[Two, bracketed]], [Three])


// 2B. ALL NAMED ARGUMENTS
#subheading("2B: All named arguments")
#text("separator='; ', coordinator='or', marker=[-> ]:")
#run-in-list(
  separator: "; ",
  coordinator: "or",
  marker: [-> ],
  [Apple],
  [Banana],
  [Cherry]
)


#text("separator=', ', coordinator=none, marker=[❖ ] (for instance):")
#run-in-list(
  separator: ", ",
  coordinator: none,
  marker: [❖ ],
  [ListOne],
  [ListTwo],
  [ListThree]
)


// 2C. MIXED SCENARIOS
#subheading("2C: Mixed scenarios")
#text("Single item with custom marker [✓ ]:")
#run-in-list(
  marker: [✓ ],
  [One item only]
)


#text("Three items, coordinator='and/or':")
#run-in-list(
  coordinator: "and/or",
  [ItemA],
  [ItemB],
  [ItemC]
)


// =============================================================================
// 3) run-in-terms TESTS
// =============================================================================
#heading("3) run-in-terms Tests (term => definition)")

// 3A. NO NAMED ARGUMENTS (defaults: separator=auto, coordinator=and, term-formatter=(it)=>[#strong(it)])
#subheading("3A: No named arguments")
#text("Zero terms => produce nothing:")
// #run-in-terms([]) // appropriately panics :)


#text("Single term => no join needed:")
#run-in-terms(
  ([OnlyTerm], [ItsDefinition]),
)


#text("Two terms => comma then 'and':")
#run-in-terms(
  ([FirstTerm], [DefinitionOne]),
  ([SecondTerm], [DefinitionTwo])
)


#text("Three terms => bracketed comma triggers semicolons + 'and':")
#run-in-terms(
  ([Term1], [Definition1]),
  ([Term2], [Def, bracketed]),
  ([Term3], [Definition3])
)


// 3B. ALL NAMED ARGUMENTS
#subheading("3B: All named arguments")
#text("separator='; ', coordinator='none', custom term-formatter => italic, 3 terms:")
#run-in-terms(
  separator: "; ",
  coordinator: none,
  term-formatter: (txt) => [#emph(txt)],
  ([Goal], [Summarize prior research]),
  ([Methods], [Outline approach]),
  ([Outcome], [Analyze results])
)


#text("separator=', ', coordinator='or', custom term-formatter => underline, 2 terms:")
#run-in-terms(
  separator: ", ",
  coordinator: "or",
  term-formatter: (txt) => [#underline(txt)],
  ([Key], [Value 1]),
  ([Secondary], [Value 2])
)


// 3C. MIXED SCENARIOS
#subheading("3C: Mixed scenarios")
#text("Single term, coordinator='and/or' => no effect because only one term:")
#run-in-terms(
  coordinator: "and/or",
  ([OneTerm], [OneDefinition],)
)


// =============================================================================
// 4) run-in-verse TESTS
// =============================================================================
#heading("4) run-in-verse Tests")

// By default: separator=[ /~], coordinator=none, ..verses

// 4A. Testing zero, single, multiple verses
#subheading("4A: No named arguments")
#text("Zero verses => nothing:")
#run-in-verse()


#text("Single verse => no joins needed:")
#run-in-verse([Alone in the verse])


#text("Two verses => joined with ' / ':")
#run-in-verse([Line one], [Line two])


#text("Three verses => bracketed commas don't matter here, but let's try anyway:")
#run-in-verse([LineA], [[Line, with comma]], [LineC])


// 4B. Overriding the default separator (rare but possible)
#subheading("4B: Custom separator")
#text("Using separator=', ' while coordinator=none:")
#run-in-verse(
  separator: ", ",
  [VerseOne],
  [VerseTwo],
  [VerseThree]
)


// =============================================================================
// 5) DIRECT run-in-join TESTS
// =============================================================================
#heading("5) Direct run-in-join Tests")

// We’ll systematically test zero, single, multiple items,
// with or without named arguments.

#subheading("5A: Minimal usage => no named args, zero items => nothing.")
#run-in-join()


#text("Single item, no named args => no join needed:")
#run-in-join([Solo])


#text("Two items, no named args => comma + 'and':")
#run-in-join([Item A], [Item B])


#text("Three items, bracketed comma => semicolons + 'and':")
#run-in-join([A1], [[B, bracketed]], [C1])


#subheading("5B: All named args")
#text("separator='; ', coordinator='or', 3 items => semicolons and \"or\"")
#run-in-join(
  separator: "; ",
  coordinator: "or",
  [Alpha],
  [Beta],
  [Gamma]
)


#text("separator=[ /~], coordinator='and/or', 4 items => ' / ' as base sep + 'and/or' before last:")
#run-in-join(
  separator: [ /~],
  coordinator: "and/or",
  [One],
  [Two],
  [Three],
  [Four]
)


#subheading("5C: Edge combos")
#text("Two items, coordinator=none => just a single separator between them.")
#run-in-join(
  coordinator: none,
  [X],
  [Y]
)


#text("Three items, separator=', ', coordinator=none => no 'and':")
#run-in-join(
  separator: ", ",
  coordinator: none,
  [X2],
  [Y2],
  [Z2]
)


#text("Single item, bracketed comma => no effect since there's no join anyway.")
#run-in-join([[Has, bracketed]])


#text("Done with direct run-in-join tests.")

