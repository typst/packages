#set enum(numbering: "a)")

= ISO/IEC 14977 : 1996(E)

== Foreword

ISO (the International Organization for Standardization) and IEC (the International Electrotechnical Commission) form the specialized system for worldwide standardization. National bodies that are members of ISO or IEC participate in the development of International Standards through technical committees established by the respective organization to deal with particular fields of technical activity. ISO and IEC technical committees collaborate in fields of mutual interest. Other international organizations, governmental and non-governmental, in liaison with ISO and IEC, also take part in the work.

In the field of information technology, ISO and IEC have established a joint technical committee ISO/IEC JTC 1. Draft International Standards adopted by the joint technical committee are circulated to national bodies for voting. Publication as an International Standard requires approval by at least 75% of the national bodies casting a vote.

International Standard ISO/IEC 14977 was prepared by BSI (as BS 6154) and was adopted, under a special “fast-track procedure”, by Joint Technical Committee ISO/IEC JTC 1, Information technology, in parallel with its approval by national bodies of ISO and IEC.

Annexes A and B of this International Standard are for information only.

== Introduction

A syntactic metalanguage is an important tool of computer science. The concepts are well known, but many slightly different notations are in use. As a result syntactic metalanguages are still not widely used and understood, and the advantages of rigorous notations are unappreciated by many people.

Extended BNF brings some order to the formal definition of a syntax and will be useful not just for the definition of programming languages, but for many other formal definitions.

Since the definition of the programming language Algol 60 (Naur, 1960) the custom has been to define the syntax of a programming language formally. Algol 60 was defined with a notation now known as BNF or Backus-Naur Form. This notation has proved a suitable basis for subsequent languages but has frequently been extended or slightly altered. The many different notations are confusing and have prevented the advantages of formal unambiguous definitions from being widely appreciated. The syntactic metalanguage Extended BNF described in this standard is based on Backus-Naur Form and includes the most widely adopted extensions.

=== Syntactic metalanguages

A syntactic metalanguage is a notation for defining the syntax of a language by use of a number of rules. Each rule names part of the language (called a non-terminal symbol of the language) and then defines its possible forms. A terminal symbol of the language is an atom that cannot be split into smaller components of the language. A syntactic metalanguage is useful whenever a clear formal description and definition is required, e.g. the format for references in papers submitted to a journal, or the instructions for performing a complicated task.

A formal syntax definition has three distinct uses:

+ it names the various syntactic parts (i.e. non-terminal symbols) of the language;
+ it shows which sequences of symbols are valid sentences of the language;
+ it shows the syntactic structure of any sentence of the language.

=== The need for a standard syntactic metalanguage

Without a standard syntactic metalanguage every programming language definition starts by specifying the metalanguage used to define its syntax. This causes various problems:

Many different notations --- It is unusual for two different programming languages to use the same metalanguage. Thus human readers are handicapped by having to learn a new metalanguage before they can study a new language.

Concepts not widely understood --- The lack of a standard notation hinders the use of rigorous unambiguous definitions.

Imperfect notations --- Because a metalanguage needs to be defined for every programming language, almost inevitably, the metalanguage contains defects. For example errors occurred in the drafting of RTL/2 (BS5904) and CORAL 66 (BS5905) because the metalanguages could not be typed easily.

Special purpose notations --- A metalanguage defined for a particular programming language is often simplified by taking advantage of special features in the language to be defined. However, the metalanguage is then unsuitable for other programming languages.

Few general syntax processors --- The multiplicity of syntactic metalanguages has limited the availability of computer programs to analyse and process syntaxes, e.g. to list a syntax neatly, to make an index of the symbols used in the syntax, to produce a syntax-checker for programs written in the language.

In practice experienced readers have little difficulty in picking up and learning a new notation, but even so the differences obscure mutual understanding and hinder communication. A standard metalanguage enables more people to crystallize vague ideas into an unambiguous definition. It is also useful because other people needing to provide formal definitions no longer need to reinvent similar concepts.

=== The objectives to be satisfied

It is desirable that a standard syntactic metalanguage should be:

+ concise, so that languages can be defined briefly and thus be more easily understood;
+ precise, so that the rules are unambiguous;
+ formal, so that the rules can be parsed, or otherwise processed, by a computer when required;
+ natural, so that the notation and format are relatively simple to learn and understand, even for those who are not themselves language designers; (The meaning of a symbol should not be surprising. It should also be possible to define the syntax of a language in a way that helps to indicate the meaning of the constructions.)
+ general, so that the notation is suitable for many purposes including the description of many different languages;
+ simple in its character set and with a notation that avoids, as far as is practicable, using characters that are not generally available on standard keyboards (both typewriters and computer terminals) so that the rules can be typed and can be processed by computer programs;
+ self describing, so that the notation is able to describe itself;
+ linear, so that the syntax can be expressed as a single stream of characters. (This simplifies printing a syntax. Computer processing of a syntax is also simpler.)

=== Some common syntactic metalanguages

Unfortunately none of the existing syntactic metalanguages was suitable for adoption as the standard, for example:

+ COBOL (ISO 1989:1985) lists alternatives vertically and uses brackets spreading over many lines. This is inconvenient for computer processing and cannot be prepared on typewriters.
+ Backus-Naur Form (used in ALGOL 60) has problems if the metasymbols `<` `>` `|` `::=` occur in the language being defined. Some common forms of construction (e.g. comments) cannot be expressed naturally, other constructions (e.g. repetition) are long-winded.
+ The obsolete FORTRAN 77 (ISO 1539:1980) had 'railroad tracks'. These are easy to understand but difficult to prepare and to process on a computer or typewriter. The current version, FORTRAN 90 (ISO/IEC 1539:1991), no longer uses this notation.

Most other languages use a variant of one of these metalanguages. Most of them cannot be candidates for standardization because they use characters not in the language being defined as metasymbols of the metalanguage. This simplifies the metalanguage but prevents it from being used generally.

POSIX (ISO/IEC 9945-2:1993) includes two complementary facilities which both assume an ISO/IEC 646:1991 character set is applicable: LEX permits the definition and lexical analysis of regular expressions, but is inadequate for the description of an arbitrary context-free grammar, and YACC (Yet Another Compiler Compiler) is a parser generator for an LALR(1) grammar.

=== The standard metalanguage Extended BNF

_Extended BNF_, the metalanguage defined in this International Standard, is based on a suggestion by Niklaus Wirth (Wirth, 1977) that is based on Backus-Naur Form and that contains the most common extensions, i.e.:

+ Terminal symbols of the language are quoted so that any character, including one used in Extended BNF, can be defined as a terminal symbol of the language being defined.
+ `[` and `]` indicate optional symbols.
+ `{` and `}` indicate repetition.
+ Each rule has an explicit final character so that there is never any ambiguity about where a rule ends.
+ Brackets group items together. It is an obvious convenience to use `(` and `)` in their ordinary mathematical sense.

The main differences in _Extended BNF_ are further features that experience has shown are often required when providing a formal definition:

+ Defining an explicit number of items. Fortran contains a rule that a label field contains exactly five characters; an identifier in PL/I or COBOL has up to 32 characters: rules such as these can be expressed only with difficulty in Backus-Naur Form. In practice, such definitions are often left incomplete and the rules qualified informally in English.
+ Defining something by specifying the few exceptional cases. An Algol end-comment ends at the first end, else or semicolon. A rule like this cannot be expressed concisely or clearly in Backus-Naur Form and is also usually specified informally in English.
+ Including comments. Programming languages and other structures with a complicated syntax need many rules to define them. The syntax will be clearer if explanations and cross-references can be provided; accordingly Extended BNF contains a comment facility so that ordinary text can be added to a syntax for the benefit of a human reader without affecting the formal meaning of the syntax.
+ Meta-identifier. A meta-identifier (the name of a non-terminal symbol in the language) need not be a single word or enclosed in brackets because there is an explicit concatenate symbol. This also ensures that the layout of a syntax (except in a terminal symbol) does not affect the language being defined.
+ Extensions. A user may wish to extend _Extended BNF_. A special-sequence is provided for this purpose, the format and meaning of which are not defined in the standard except to ensure that the start and end of an extension can always be seen easily. Various possible extensions are outlined in the following paragraphs.

=== Limitations and extensions

The main limitation of _Extended BNF_ is that the language being defined needs to be linear, i.e. the symbols in a sentence of the language can be placed in an ordered sequence. For example knitting patterns and recipes in cooking are linear languages, but electric circuit diagrams are not.

A further limitation is that _Extended BNF_ is inadequate for defining more complex forms of grammars. Such facilities were not provided because it was thought the main need was to define a notation sufficient for the simpler and commoner requirements.

Instead _Extended BNF_ has been designed so that various extensions can be made in a natural way. There are two simple ways of extending the standard metalanguage. Firstly, the special-sequence concept provides a basic framework for any extension, the format between the special-sequence-characters being almost completely arbitrary. This method would be suitable for an action grammar, i.e. one specifying actions that are to take place as a sentence is parsed. Secondly, a meta-identifier can never be followed immediately by a left
parenthesis in the standard metalanguage; thus another method of extending the metalanguage is to define the syntax and meaning of a meta-identifier followed by a sequence of parameters enclosed in parentheses. This would be reasonable in an attribute grammar where the rules ensure consistency between different parts of a sentence in the language being defined.

More complicated extensions are also possible. Annex A suggests how _Extended BNF_ might be extended to define a two-level grammar.

= Information technology --- Syntactic metalanguage --- Extended BNF

sss
