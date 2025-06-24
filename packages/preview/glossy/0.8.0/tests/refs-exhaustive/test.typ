// Brutal test for `glossy` functionality
//
// This file tries to exercise every known feature of `glossy` based on the demo.
// The goal is to cover all possible term definitions, modifiers, and reference forms.
//
// - Test terms with all combinations of fields: short, long, description, group, article, longarticle
// - Terms with missing fields
// - Terms with vowel/consonant starting for testing articles
// - Terms with conflicting modifiers (short/long/both), capitalization (cap), plural (pl), article (a/an), desc, def
// - Terms that appear and terms that are never referenced
// - Multiple glossaries with different themes and groups
// - Custom show-term callbacks
//
// This is not a narrative; it's a comprehensive brute-force test.
//
// Assumptions/Features Inferred:
// - @key references a glossary term by its key
// - Modifiers: short, long, both, cap, pl, a, an, def, desc
// - a/an modifiers can appear before or after the key
// - Terms can have custom 'article' or 'longarticle' fields to override default articles
// - Terms not referenced should not appear in a glossary unless forced
// - Conflicting modifiers: short/long/both - only one displays, in priority: both > long > short?
// - desc and def presumably show description or definition fields inline
// - The `show-term` callback in `init-glossary` modifies how inline references are displayed
// - `#glossary` can be called multiple times with different filters and themes
// - Terms can be grouped, and `#glossary` can be limited to certain groups
// - Terms with unusual keys or missing fields
// - Terms starting with vowels to test articles (e.g., 'an' vs 'a')
// - Terms that define custom `article` or `longarticle` fields
//
// We attempt to create a large dictionary with diverse entries.

#import "/lib.typ": *

#let exhaustiveGlossary = (
  html: (
    short: "HTML",
    long: "Hypertext Markup Language",
    description: "A standard language for creating web pages",
    group: "Web"
  ),

  css: (
    short: "CSS",
    long: "Cascading Style Sheets",
    description: "A language used for describing the presentation of documents",
    group: "Web"
  ),

  // Term with no description
  js: (
    short: "JS",
    long: "JavaScript",
    group: "Web"
  ),

  // Term with only a short field
  tcp: (
    short: "TCP",
    group: "Networking"
  ),

  // Term with only a long field
  // should panic!
  //udp: (
  //  long: "User Datagram Protocol",
  //  group: "Networking"
  //),

  // Term with short and description, but no long
  ip: (
    short: "IP",
    description: "A unique identifier for a host or network interface",
    group: "Networking"
  ),

  // Term with custom articles and everything defined
  api: (
    short: "API",
    long: "Application Programming Interface",
    description: "A set of protocols and tools for building software",
    article: "an",      // custom article for short form
    longarticle: "an",   // custom article for long form
    group: "Software"
  ),

  // Term starting with a vowel, no custom article, to test default a/an logic
  xml: (
    short: "XML",
    long: "Extensible Markup Language",
    description: "A markup language defining rules for encoding documents",
    group: "Data"
  ),

  // Term starting with a consonant, no custom article
  cpu: (
    short: "CPU",
    long: "Central Processing Unit",
    description: "The primary component of a computer that performs calculations",
    group: "Hardware"
  ),

  // Term without any fields (just a string), should be handled gracefully
  bare: "A bare term with no fields",

  // Term with only description
  // should panic!
  //desconly: (
  //  description: "Just a description, no short or long",
  //  group: "Misc"
  //),

  // Term with article fields but missing short and long (should test fallback)
  // should panic!
  //articonly: (
  //  article: "an",
  //  longarticle: "a",
  //  description: "Has only articles and a description",
  //  group: "Misc"
  //),

  // Term with uppercase key
  SSL: (
    short: "SSL",
    long: "Secure Sockets Layer",
    description: "A protocol for encrypting information over the internet",
    group: "Security"
  ),

  // Term that will not be referenced
  unusedterm: (
    short: "UNUSED",
    long: "Unused Term",
    description: "Should not appear since it's never referenced"
  ),

  // Term that tests pluralization with custom fields maybe
  doc: (
    short: "doc",
    long: "document",
    description: "A single piece of written matter",
    group: "Misc"
  ),

  // Terms that might require checking conflicting modifiers
  tps: (
    short: "TPS",
    long: "test procedure specification",
    description: "A document describing test procedures",
    group: "Testing"
  ),

  // Term that might appear multiple times
  http: (
    short: "HTTP",
    long: "Hypertext Transfer Protocol",
    description: "A protocol for distributed, collaborative, hypermedia information systems",
    group: "Web"
  )
)

// Initialize the glossary with a custom show-term callback
#show: init-glossary.with(
  exhaustiveGlossary,
  show-term: (body) => [#strong(body)]
)

#set heading(numbering: "1.1")
#set page(height: 9.5in, width: 7in, margin: 1em, numbering: "1")

= Brutal `glossy` Test

This document tries all reference forms and modifiers on a large set of terms.

== Basic references without modifiers

- @html
- @css
- @js
- @tcp
//- @udp // should panic!
- @ip
- @api
- @xml
- @cpu
- @bare
//- @desconly // should panic!
//- @articonly // should panic!
- @SSL
- @doc
- @tps
- @http

== Using plural modifier (pl)

- @html:pl
- @css:pl
- @js:pl
- @tcp:pl
//- @udp:pl // should panic!
- @ip:pl
- @api:pl
- @xml:pl
- @cpu:pl
- @bare:pl
//- @desconly:pl // should panic!
//- @articonly:pl // should panic!
- @SSL:pl
- @doc:pl
- @tps:pl
- @http:pl

== Using capitalization modifier (cap)

- @html:cap
- @css:cap
- @js:cap
- @tcp:cap
//- @udp:cap // should panic!
- @ip:cap
- @api:cap
- @xml:cap
- @cpu:cap
- @bare:cap
//- @desconly:cap // should panic!
//- @articonly:cap // should panic!
- @SSL:cap
- @doc:cap
- @tps:cap
- @http:cap

== Using articles (a/an) before the key

- @a:html (consonant start)
- @a:css
- @an:ip (starts with vowel sound?)
- @an:api (has custom article 'an')
- @a:cpu (consonant)
- @an:xml (starts with vowel)
//- @an:articonly (has custom article fields) // should panic!
- @an:SSL (S pronounced 'es')
- @a:doc

== Using articles after the key

- @html:a
- @css:an
- @ip:a
- @api:a (custom article should still apply)
- @cpu:an (might not make sense since CPU starts with C sound - test behavior)
- @xml:a
//- @articonly:an // should panic!
- @SSL:a
- @doc:an

== Using def and desc modifiers

- @html:def (show definition/long?)
- @css:desc (show description)
//- @js:def // should panic!
- @ip:desc
- @api:def
- @xml:desc
- @cpu:def
//- @desconly:def (no short/long, just desc) // should panic!
//- @articonly:desc // should panic!
- @tps:def
- @tps:desc
- @http:def
- @http:desc

== Using short, long, both modifiers

- @html:short
- @html:long
- @html:both
- @css:short
- @css:long
- @css:both
//- @udp:long (only has long) // should panic!
- @tcp:short (only has short)
- @ip:short
- @ip:long (no long defined, fallback?)
- @api:long
- @xml:both
- @cpu:both
- @doc:short
- @doc:long
- @doc:both
- @tps:short
- @tps:long
- @tps:both

== Conflicting multiple modifiers combined (short, long, both together)

- @tps:short:long
- @tps:short:both
- @tps:long:both
- @tps:short:long:both
- @html:both:long:short
- @doc:long:short
- @cpu:both:long:short
- @api:short:long:both

== Combining capitalization and plural with short/long/both

- @html:long:pl:cap
- @css:both:cap:pl
- @doc:short:pl:cap
- @api:both:pl:cap
- @ip:long:pl:cap (no long, see what happens)
- @bare:long:pl:cap (no fields)
//- @desconly:both:pl:cap (no short/long) // should panic!
//- @articonly:short:cap:pl (no short defined) // should panic!
- @SSL:both:pl:cap
- @tps:long:pl:cap
- @http:both:pl:cap

== Combining articles with other modifiers

- @a:html:long
- @an:ip:long
- @api:a:long (custom article)
//- @xml:an:both:pl (articles + plural? Should fail or ignore?) // should panic!
- @cpu:an:both:cap
- @SSL:a:short:cap
//- @doc:an:long:pl // should panic!

(We know articles + pl is not compatible, checking behavior.)

//== Attempt referencing nonexistent keys
//
//- @nonexistent (Should show something like ?? or error?) // should panic!
//- @nonexistent:long:pl:cap:a:def (extreme) // should panic!

== Create a big table testing all fields of one term

#table(
  columns: 3,
  table.header([*Input*],[*Output*],[*Comment*]),
  [`@api`         ], [@api],         ["default"],
  [`@api:short`   ], [@api:short],   ["short only"],
  [`@api:long`    ], [@api:long],    ["long only"],
  [`@api:both`    ], [@api:both],    ["both"],
  [`@api:def`     ], [@api:def],     ["definition (long)"],
  [`@api:desc`    ], [@api:desc],    ["description"],
  [`@a:api`       ], [@a:api],       ["article before key"],
  [`@api:a`        ], [@api:a],       ["article after key"],
  [`@api:cap`     ], [@api:cap],     ["capitalize"],
  [`@api:pl`      ], [@api:pl],      ["plural"],
  [`@api:long:cap`], [@api:long:cap],["long + cap"],
  [`@api:both:pl` ], [@api:both:pl], ["both + pl"]
)

== Multiple glossaries with themes and group filtering

= Glossaries

== Full Glossary (all terms)

#glossary(title: "Full Glossary", theme: theme-chicago-index)

== Web Only

#glossary(title: "Web Terms", groups: ("Web",), theme: theme-compact)

== Networking Only

#glossary(title: "Networking Terms", groups: ("Networking",), theme: theme-basic)

== Misc and Data

#glossary(title: "Misc & Data", groups: ("Misc","Data"), theme: theme-basic)

== Just Testing terms

#glossary(title: "Testing Terms", groups: ("Testing",), theme: theme-chicago-index)

== Hardware group

#glossary(title: "Hardware Terms", groups: ("Hardware",), theme: theme-chicago-index)

== Unreferenced entries

#glossary(title: "Unreferenced (Should Contain Unused?)", groups: ("Security",), theme: theme-chicago-index)

== Empty group glossary
#glossary(title: "Empty Group Glossary", groups: (""), theme: theme-basic)

= End of Brutal Test
