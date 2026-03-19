#import "eggs.typ": *
#import "@local/aliases:1.0.0": *
#import abbreviations: pst, def, nom

#show: eggs.with(
)
// #show ref: shortcite

#set page(margin: 1in)
#set text(font: "Nimbus Roman", size: 12pt)
#set par(spacing: 0.65em, first-line-indent: 1em, justify: true)

#show heading: set text(size: 12pt, weight: "bold")
#show heading.where(level: 2): it => it.body + [. ]

= Kind-level composition as concept composition

// This work explores a range of phenomena known as kind-level modification, namely: classificatory adjectives (@cladj); nominal juxtaposition (@juxt); (pseudo-)incorporation (@pinc) and weak definites (@wd). Although seemingly distant, they share a number of common properties.

#grid(
  columns: 2,
  ex[
    #ex-label(<cladj>)
    + black tea
    + generative syntax
  ],

  ex[
    #ex-label(<juxt>)
    + advertisement sign
    + eagle nest
  ],
  
)

#grid(
  columns: 2,
  ex[
    #ex-label(<pinc>)
    - Ali  kitap  oku-du
    - Ali  book   read-#pst
    'Ali read a book.'#h(2em)
  ],
  ex[
    #ex-label(<wd>)
    + Anne took the train to Paris.
    + Jerry called the doctor.
  ]
)

@wd:b

// == Limited composition
// Structurally, kind-level composition always happens before any other (individual-level). That is (a) a kind-level modifier cannot be separated from the head by an individual-level modifier #nextx; and (b) a kind-level modifier can itself be modified only by kind-level modifiers #anextx.

// #ex[
//   + dark sweet cherries / \#sweet dark cherries
//   + - Ali  (yavaş)   kitap  (\*yavaş)   oku-du
//     - Ali   slowly   book     slowly  read-#pst
//     'Ali slowly read a book.'#h(1fr) @sag2022baresingularssingularity
// ]

// #ex[
//   + [golden eagle] / \*[large eagle] nest
//   + - Ali  dini       /  \*eski  kitap  oku-du
//     - Ali  religious  /    old   book   read
//     'Ali read a religious / \*old book.'
//   + Jerry called the eye / \*good doctor.#h(1fr) @sag2022baresingularssingularity
// ]

// == Lexicalization
// Although kind-level modification is mostly productive, kind-level expressions show properties of lexicalized structures. The meaning that results from kind-level modification is often either non-compositionally enriched or non-compositional at all. (@cladj:a) is non-compositional: black tea need not be black-colored. (@wd:b) is enriched: the VP means roughly 'call a doctor to consult about health', and the sentence is illicit if Jerry called some doctor to chat @aguilarguevara2010weakdefinitesreference. Another property, noted e.g. by @mithun1984evolutionnounincorporation[p:] for incorporation, is that kinds-level expressions tend to require name-worthiness (well-establishedness in @krifka1995genericityintroduction[p:]).

// == Non-referentiality
// noun phrases used as kind-level modifiers are characterized by their non-referentiality. First, they are normally number-neutral: (@wd:a) can mean Anne traveled by multiple trains, despite _train_ being in Singular, and similarly with (@pinc); an advertisement sign can contain any number of ads, and an eagle nest is normally inhabited by multiple birds. Second, reference to the corresponding individuals is either impossible #nextx or complicated #anextx.

// #ex[
//   #ex-label(<ref>)
//   + \* Victor looked at an advertisement#sub[_i_] sign. It#sub[_i_] was about another hair loss treatment.
//   + ? Sheila took the shuttle-bus#sub[_i_] to the airport. It#sub[_i_] was a huge gaudy Hummer.\
//     #h(1fr)@scholten2010assessingdiscoursereferential
// ]

// == Kind-level definiteness
// In kind-level composition, both the parts and the result often license definiteness marking, even if it is unexpected as no definite individual is present that can satisfy the presupposition. (@wd:b) is acceptable with the definite article out of the blue (see @aguilarguevara2010weakdefinitesreference[b:] @schwarz2014howweakhow[b:] for further evidence from scope). Similarly, in languages with adjectival definiteness, like Latvian #nextx, classificatory adjectives are always definite even if the referent is not @holvoet2012semanticmapdefinite.

// #ex[
//   #grid(
//     columns: 3,
//     [
//       + - balt-s  suns
//         - white-#nom  dog
//         'a white dog'
//     ],
//     [
//       + - balt-ai-s  suns
//         - white-#def\-#nom  dog
//         'the white dog'
//     ],
//     [
//       + - balt-\*(ai)-s  lācis
//         - white-#def\-#nom  bear
//         'a/the polar bear'
//     ]
//   )
// ]

// == Previous work
// It is much of a consensus in the literature @gunkel2009classifyingmodifierscommon @aguilarguevara2010weakdefinitesreference @sag2022baresingularssingularity that the aforementioned phenomena are examples of modification on the level of kinds. Under this view, verbs and nouns are (or can be) predicates over kinds (entity- or event-kinds) initially. After composition, a singular kind is retrieved from the predicate and is turned into an individual-level predicate by an operator such as @carlson1977referencekindsenglish[ps:] $R$.

// This approach is independently supported. @saha2023referencekindsperspective[p:] shows that in Bangla, $R$ is overt. When $R$ is not present, what results is singular kind reference as in _the mammoth is extinct_.

// The kind-level account explains non-referentiality: since all the constituents are kind-referring, no individuals are introduced. Similarly, definiteness is licensed by unique kinds such as the #sc[doctor]-kind.

// Still, some things remain unexplained. First, what _are_ kinds? Why is it the case that kind-level modification is strictly prior to individual-level modification with no way to get a kind (that is available for modification) from an individual-level predicate? This is functionally unexpected provided that individual reference is significantly more common and conceptually simpler. Second, what drives idiomaticity in a way that is not present in individual-level modification?

// == Proposal
// I follow the line of Carlson (@carlson1977referencekindsenglish[y:], @carlson2009genericsconcepts[y:]) in understanding kinds as abstract concepts. Lexicalization reflects the idea that concepts are the denotations of the lexical items @murphy2004bigbookconcepts. I propose that kind-level modification is a conceptual-level operation, with $R$ deriving a referential expression from a concept.

// I employ the Dual Content theory @weiskopf2009atomismpluralismconceptual @delpinal2015dualcontentsemantics. It states that the denotation of an expression consists of two layers: extensional structure (E-structure) and conceptual structure (C-structure). The former defines the reference of an expression; the latter includes connotations and emerging prototypes. The two structures are only loosely related, depending on the speaker's world knowledge. I propose that expressions in question enter the derivation as pure concepts, with their E-structure empty, and that kind-level composition involves modifications to the C-structure.

// Conceptual composition differs from extensional composition in employing special cognitive processes and word knowledge. @prinz2012regainingcomposuredefence[ps:] RCA model postulates 3 stages in concept composition: (1) trying to Retrieve a conceptual structure from the memory, (2) combining the concepts Compositionally (if Retrieval failed), and (3) using background information to Analyze: fill gaps, explain relations, and resolve conflicts. Retrieval accounts for non-compositional modification, and Analysis --- for enrichment.

// When $R$ is applied, the conceptual structure is used to determine the extension, so it may turn out Retrieved or enriched. Thus, the content that constitutes mere connotations of #nextx, where _call_ and _doctor_ are combined at the extensional level, become the extension of (@wd:b).

// #ex[
//   Jerry called a doctor.
// ]

// The account explains both the primacy of kinds to individuals and the effects of non-compositionality. Paired with a very simple ontology (compared e.g. to @heyer1985genericdescriptionsdefault), it helps accounting for singular kind reference. It also offers a formalization of @carlson2009genericsconcepts[ps:] insights on genericity.

#pagebreak()
