#import "/lib.typ": *

#let myGlossary = (
  HTML: "Hypertext Markup Language",
  CSS: "Cascading Style Sheets",
  tps: (
    short: "TPS",
    long: "test procedure specification",
    description: "A document on how to run all the test procedures",
  ),
)

#show: init-glossary.with(myGlossary, show-term: body => [#emph(body)])

#set heading(numbering: "1.1")
#set page(numbering: "1")

= Hello, `glossy`!
In modern web development, languages like @HTML and @CSS are essential.

Now make sure I get your @tps:short reports by 2pm!

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

== Using conflicting modifiers (short, long, both)

These modifiers are semantically mutually exclusive. When multiple are used,
`glossy` throws an error to the compiler, explaining the problem.

#import "/src/gloss.typ": __default-format-term, __gls
#let manual-gls(key, mods) = __gls(
  key,
  modes-modifiers: mods,
  format-term: __default-format-term,
  show-term: body => [#strong(body)],
  term-links: false,
  display-text: none,
)
#assert-panic(manual-gls.with("tps", ("short", "long")))
#let msg-short-long = "panicked with: \"Cannot mix modes \", (\"short\", \"long\"), \", pick one.\""
#let msg-short-both = "panicked with: \"Cannot mix modes \", (\"short\", \"both\"), \", pick one.\""
#let msg-long-both = "panicked with: \"Cannot mix modes \", (\"long\", \"both\"), \", pick one.\""
#let msg-short-long-both = "panicked with: \"Cannot mix modes \", (\"short\", \"long\", \"both\"), \", pick one.\""

#table(
  columns: 2,
  table.header([*Input*], [*Error*]),

  [`@tps:short:long`     ],
  [#assert.eq(
      catch(manual-gls.with("tps", ("short", "long"))),
      msg-short-long,
    )#msg-short-long],

  [`@tps:short:both`     ],
  [#assert.eq(
      catch(manual-gls.with("tps", ("short", "both"))),
      msg-short-both,
    )#msg-short-both],

  [`@tps:long:both`      ],
  [#assert.eq(
      catch(manual-gls.with("tps", ("long", "both"))),
      msg-long-both,
    )#msg-long-both],

  [`@tps:short:long:both`],
  [#assert.eq(
      catch(manual-gls.with("tps", ("short", "long", "both"))),
      msg-short-long-both,
    )#msg-short-long-both],
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
        output, repeat([#h(0.25em) . #h(0.25em)]), entry.pages.join(", "),
      ),
    )
  },
)

#glossary(theme: my-theme)
