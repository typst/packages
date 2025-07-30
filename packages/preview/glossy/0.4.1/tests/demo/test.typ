// a minimal example, also listed in the README

#import "/lib.typ": *

#let myGlossary = (
  html: (
    short: "HTML",
    long: "Hypertext Markup Language",
    description: "A standard language for creating web pages",
    group: "Web"),
  css: (
    short: "CSS",
    long: "Cascading Style Sheets",
    description: "A language used for describing the presentation of a document",
    group: "Web"),
  tps: (
    short: "TPS",
    long: "test procedure specification",
    description: "A document on how to run all the test procedures"),
   unused: "Unused term, which shouldn't print in the glossary."
)

#show: init-glossary.with(myGlossary, show-term: (body) => [#emph(body)])

#set heading(numbering: "1.1")
#set page(height: auto, width: 6.5in, margin: 1em, numbering: "1")

= Hello, `glossy`!
In modern web development, languages like @html and @css are essential.

Now make sure I get @tps:a:SHORT report by 2pm! @an:tps:cap is very important!!!

@tps:cap is defined as: @tps:def.

= Examples with modifiers

#table(
  columns: 2,
  table.header([*Input*], [*Output*]),

  [`@tps:short`      ], [@tps:short],
  [`@tps:long`       ], [@tps:long],
  [`@tps:both`       ], [@tps:both],
  [`@tps:long:cap`   ], [@tps:long:cap],
  [`@tps:long:pl`    ], [@tps:long:pl],
  [`@tps:short:pl`   ], [@tps:short:pl],
  [`@tps:both:pl:cap`], [@tps:both:pl:cap],
  [`@tps:def`        ], [@tps:def],
  [`@tps:desc`       ], [@tps:desc],
)

== Adding articles via `a`/`an` modifiers

You can add an article to your term by adding the `a` or `an` modifiers (they're
equivalent, just both available as a convenience). These modifiers are special
in that they can precede the term's key, like `@a:key`, or follow the key like
the other modifiers.

Default English modifiers are chosen unless the `article` and/or `longarticle`
keys are defined for the given entry.

Articles are incompatible with the `pl` (plural) modifier.

#table(
  columns: 2,
  table.header([*Input*], [*Output*]),

  [`@a:tps:short`    ], [@a:tps:short],
  [`@a:tps:long`     ], [@a:tps:long],
  [`@an:tps:both`    ], [@an:tps:both],
  [`@an:tps:long:cap`], [@an:tps:long:cap],
  [`@tps:a:long`     ], [@tps:a:long],
  [`@tps:a:short`    ], [@tps:a:short],
  [`@tps:an:both:cap`], [@tps:an:both:cap],
)

== Using conflicting modifiers (short, long, both)

These modifiers are semantically mutually exclusive, by they can be combined
syntactically. When multiple are used, `glossy` tries to make a smart choice on
which one to display.

#table(
  columns: 2,
  table.header([*Input*], [*Output*]),

  [`@tps:short:long`     ], [@tps:short:long],
  [`@tps:short:both`     ], [@tps:short:both],
  [`@tps:long:both`      ], [@tps:long:both],
  [`@tps:short:long:both`], [@tps:short:long:both],
)

#let my-theme = (
  section: (title, body) => {
    heading(level: 1, title)
    body
  },
  group: (name, i, n, body) => {
    if name != "" and n > 1 {
      heading(level: 2, name)
    }
    body
  },
  entry: (entry, i, n) => {
    // i is the entry's index, n is total number of entries
    let output = [#entry.short]
    if entry.long != none {
      output = [#output -- #entry.long]
    }
    if entry.description != none {
      output = [#output: #entry.description]
    }
    block(
      grid(
        columns: (auto, 1fr, auto),
        output,
        repeat([#h(0.25em) . #h(0.25em)]),
        entry.pages,
      )
    )
  }
)

#glossary(theme: my-theme)
#glossary(title: "Glossary with just empty group", groups: ("",), theme: theme-basic)
#glossary(title: "Glossary with just Web group", groups: ("Web",), theme: theme-compact)
