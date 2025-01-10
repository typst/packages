#import "../src/lib.typ" as flow: *

#show: note.with(
  title: "flow manual",
  aliases: "how to procastinate",
  author: "MultisampledNight",
  cw: "\"you\"",
)

#let normal = text.with(font: "IBM Plex Sans")

#show raw.where(lang: "example"): it => {
  let code = it.text
  let label(body) = emph(fade(normal(body + v(-0.5em))))
  grid(
    columns: (1fr, 1fr),
    align: (top + left, left),
    gutter: 1em,
    label[Typst code:]
      + raw(lang: "typ", block: true, code),
    label[Rendered result:]
      + block(
        stroke: fg,
        radius: 0.5em,
        inset: 0.5em,
        width: 100%,
        normal(eval(
          mode: "markup",
          scope: dictionary(flow),
          code,
        ))
      ),
  )
}


= Introduction

Hi there!
This document serves as a long-form manual for the use of flow.
Flow is the template I use as basis
for my own
#fxfirst("Personal Knowledge Management")
system.

It has the batteries of
countless Typst documents written and
hacks done included.
This can make it quite overwhelming,
but don't worry!
You don't need to know everything about it
in order to start using it.

This manual assumes you already know
#link("https://typst.app")[Typst] a bit —
if you don't, that's absolutely no problem!
Just head on over to the excellent
#link("https://typst.app/docs/tutorial/")[Typst tutorial],
I can guarantee you it is worthy of your time.

#hint[
  While you can use flow mostly
  without worrying about the internals,
  chances are that this template
  is actually overkill for your specific needs and desires!

  Hence, consider using flow as inspiration to consider,
  not as the ultimate goal to strive for.
  Feel free to take what you think is useful.
  Ideally, even introspect and improve on it.
  
  Learning is highly individual, and
  so are PKMs.
  Find a solution that fits *you*. :3
]

= How do I get started?

+ Use the the following boilerplate in your note:

  ```typ
  #import "@preview/flow:0.1.1": *
  #show: note.with(
    title: "Super cool note title!",
  )
  ```

+ Start typing the actual note like any other typst document! uwu


= Reference


== Template

The `#show: note` you usually put at the top of your file
is already functional without any further configuration.
However, sometimes one _does_ want further configuration.

Behind the scenes,
`note` is actually a shorthand for `template.note`.
There are other useful templates in `template`,
but notably they all use `template.generic` at their core.

=== Arguments <arguments>

All of these are named arguments.
In effect, if you choose to use any of them,
most likely you want to transform your `#show: note`
into a
#link("https://typst.app/docs/reference/foundations/function/#definitions-with")[`function.with`]
call, for example:

```typst
#show: note.with(
  title: "meow!",
  keywords: ("cat", "catnip"),
)
```

Since `template.generic` is the actual processor of these arguments,
you can use them with any other template in the `template` module as well!

==== `title`

A string.
It is encoded into the resulting PDF
as the document title you usually see
in the window title of the PDF viewer.
A template might also display this somewhere,
but this is not required.

If it is not specified or `none` is passed,
the filename passed via `--input filename=...`
on the CLI
has its extension trimmed and is used instead.
Otherwise,
if `--input filename=...` has not been passed,
`"Untitled"` is used as a last-resort default.

Given that it is usually the first thing the reader sees,
it should try to very concisely relay what the document is about.

==== `keywords`

Either an array of strings or
a dictionary from strings to functions/colors/labels, where
each function takes exactly one positional argument.

Which words to highlight specially in the document.
Think of it as a short-hand for show rules, but
for individual words,
handling
capitalization,
plurals,
verbification and
word boundaries for you.

The function is the content with the word given to
and it is supposed to return what should be displayed in-place.
If it's an array, all items become keys
with the `strong` function
as value.

None are highlighted by default.
It is not included in the metadata table.

=== Kinds

All of them are available under the `template` module and
intended to be used via show rules.
For example, for using the `latex-esque` template,
you'd use something akin to this in your code:

```typst
#show: template.latex-esque
```

==== `generic`

The core driver behind all templates.
Specifically, it sets up the following:

- Basic styling according to the chosen theme
- Page numbering
- Processing of
  - Checkboxes
  - Keywords
  - Metadata

Note that the styling does include colors and
a few layout hints, but
does notably *not* set the font or font size.

#hint[
Feel free to use this as base for your own templates!
Chances are you want to forward passed arguments
that aren't handled directly by your template to the `generic` driver,
so something to the following show rule:

```typc
show: generic.with(..args)
```

The same idea works for all other templates listed here, too.
]

==== `modern`

- Extends: `generic`

`generic` but with nice, modern font choices.

==== `note`

- Extends: `modern`

Usable for notes,
short reports,
quick sketchups and
the works.

Sets up a nice boilerplate
showing
the document title,
metadata and
an outline.

==== `latex-esque`

- Extends: `generic`

Usable for faking something was made in LaTeX
when it actually wasn't.
Only does so superficially,
functionally nothing is changed and
the icons will still look modern-ish.

==== `slides`

- Extends: `generic`

Splits the document into slides by
using the headings.
See the dedicated section about slides,
@slides,
for details.

Has a large, readable font size and
a progress bar at the bottom of every slide,
so viewers know much longer the presentation will go.

#hint[
The core idea of what `slides` is doing,
namely re-traversing the entire content tree
and rendering it entirely differently,
is very interesting to me
for displaying information easier to other audiences.

I'm considering at the moment to abstract this into a `transform` driver
or the works.
Then one could also create a mindmap template
collecting all proofs, theorems and the works in a document...
but this is all future music.
]

=== Metadata

/ Metadata: Data about data.

Sometimes it might be useful to denote information
_about_ the document you're writing
which doesn't quite belong into the document itself.
Quite often this is also information
you might wish to programmatically search for.

An example of this are aliases of what you're writing about.
Sometimes they are just like the title,
but you can have only one title,
so they need to be put somewhere else.
Metadata is _perfect_ for this.

You can specify metadata
by passing any additional named arguments
that are not named under @arguments
to your chosen template (as long as it is from flow, that is).

==== Checking

Theoretically, metadata can be literally anything.
Practically though a few commonly used
metadata fields and their types
crystallize out, and
if one notices that afterwards
it takes quite a while to get everything into order again.

For this reason,
the metadata you specify is checked against a schema.
The schema is lax —
if you specify fields it doesn't know of,
it will allow them anyway.

The schema currently is:

#raw(block: true, tyck.fmt(info._schema))

It's checked via the `tyck` module,
which you can also use to construct your own schemas and validating them.

==== Querying

In order to actually get the metadata out of one document,
you can use the `typst query` command in a script.
Specifically, querying for the `<info>` label
yields all metadata you've specified.

For getting to the actual metadata,
you probably want to pass `--one --field value`,
which results in the JSON of what you've specified
(plus some normalization).

===== Accelerating

If you've tried to `typst query` on a flow document
without anything else,
you've probably noticed that it is quite slow.
That is mostly because Typst just compiles the whole document
like it would when actually rendering it to a PDF
and just queries for what you've specified afterwards.

Hence, here are a few tips to speed things up significantly:

- Pass `--input render=false`.
  Flow will use this to avoid large imports,
  not render diagrams,
  layout everything in a "whatever" way as well as
  do several smaller things.
- Restrict what paths Typst should search fonts in.
  For example, you could try running Typst under a fake root
  to make sure it does not enumerate all system fonts
  (which it would do otherwise).

== Task

/ Task: Checkbox at the very beginning of a list item or enumeration item.
/ Checkbox: Opening bracket, one fill character or space, closing bracket.

Task lists allow you to gain a quick overview
regarding where you are right now,
what is actionable,
what to next and
what you can't do right now.

They are useful as an *anchor point*,
a single source of truth for yourself to check what you are doing right now.
For longer-form tasks and projects,
you might want to consider using more specialized software
like the ones emulating e.g. Kanban boards.

=== Using them

Just type a list or enum like you're used to (using e.g. `-` or `+`),
then put the desired checkbox right afterwards and pad it with spaces.
That's it!

```example
- [ ] We didn't even start this yet
- [!] Needs to be done soon
- [>] Doing that currently...
- [:] Can already build on something
- [x] Yay, finished this!
- [/] Can't do this anymore
- [-] Out of my control
- [?] Should find out more about it
```

=== Fill semantics

The variable $p in [0, 1] union RR$ represents the hypothetical current progress
of that task, where $0$ is no progress done yet and $1$ is fully finished.
This is a model: In reality, progress is rarely well quantifiable.
Hence, see these semantics merely as a suggestion.

#table(
  columns: 5,
  align: left,
  inset: 0.5em,
  table.header(
    [Name], [Fill], [$p in ...$], [Assigned to?], [Actionable by you?],
  ),
  ..(
    ([Not started], " ", [${ 0    }$], [Nobody yet], [Yes]),
    ([Urgent],      "!", [$[ 0, 1 )$], [You],        [Yes]),
    ([In progress], ">", [$[ 0, 1 )$], [You],        [Yes]),
    ([Paused],      ":", [$( 0, 1 )$], [You],        [Yes]),
    ([Completed],   "x", [${    1 }$], [Nobody],     [No]),
    ([Cancelled],   "/", [$[ 0, 1 )$], [Nobody],     [No]),
    ([Blocked],     "-", [$[ 0, 1 )$], [Not you],    [No]),
    ([Unknown],     "?", [$[ 0, 1 ]$], [Maybe you],  [Maybe]),
  )
  .map(((name, fill, ..args)) => (
    name,
    raw("[" + fill + "]"),
    ..args,
  )).join()
)

==== Not started <not-started>

- No progress done yet
- May be started by anyone, possibly you

==== Urgent <urgent>

- Should be prioritized when selecting next tasks to put in progress
- Consider putting tasks currently in progress on pause for this instead
- Requires time-sensitive action
- Otherwise like not started

==== In progress <in-progress>

- Not finished yet, but being worked on
- The point you look for when you try to remember what you were doing again
- Ideally keep the count of those as low as possible, if not even just 1

==== Paused <paused>

- Some progress already done
- Can be continued anytime
- Probably some notes flying around already

==== Completed <completed>

- Was fully fulfilled
- Nothing needs to be done anymore

==== Cancelled <cancelled>

- Doesn't need or can't be fulfilled anymore
- Can be just ignored

==== Blocked <blocked>

- Cannot be continued by you for the moment
- Maybe just some time has to pass, maybe somebody else is working on it
- Either way, not your responsibility for the moment

==== Unknown <unknown>

- Maybe some progress is already done, maybe none, maybe it's actually complete
- Maybe it is your responsibility, maybe someone else's
- Need to acquire more information to put it into a "proper" category
- Try to have as few of these as possible as they make planning quite difficult
  - And you might miss things that were your job

=== More examples of tasks

```example
-   [ ] you    _can_ be   extra spacious
- [?] this is long: #lorem(20)

+ [ ] Task lists can also be ordered!
+ [x] And advance as normal!

- [>] This is a large parent task!
  + [x] Which can have subtasks!
  + [>] With even more nesting!
    + [ ] Like here!
    + [ ] And here!

- [ ]No space between checkbox and description necessary!
```

=== Examples of non-tasks

They are still completely fine text!
Their checkboxes are just not rendered.

```example
- Still just a normal list entry
- [Bracketized, but fill must be 1 char]
  - [[Well, 1 grapheme cluster :3]]
- [] Fill must not be empty
- [ [ The brackets must be opposite
-[ ] Space must be before checkbox qwq
```


== Callout

Callouts compress important statements and
highlight them according to their semantic content.

Documents are usually not read linearly,
these callouts will stand out and
let the reader pay more attention.
They can also serve as visual anchors
for navigation in a document
for already read parts.
Hence, use them wisely:
If everything is highlighted, nothing is highlighted.

=== General

```example
#question[
  Still to be examined. \
  Very useful for involving the reader.
]
#remark[
  Key takeaways from a section. \
  Should be easy to remember.
]
#hint[
  How to do something more easily. \
  Or something that can be used
  to remember this better.
]
#caution[
  Tries to warn the reader of
  something important or dangerous.
]
```

=== Maths

```example
#axiom[
  Taken as granted.
]
#define[
  Newly set here using existing ideas.
]
#theorem[
  Can be proven.
]
#propose[
  Less important theorem.
]
#lemma[
  Part of a larger proof.
]
#corollary[
  Follows from something.
]
```

== Effect

Can highlight that some text is really important.

=== Invert

```example
What if I told you a story about
visiting a very #invert[spooky] place?
```

For when you need to add #invert[extra importance] to some text.

Note that #invert[it should always fit on one line though,
otherwise it'll go out of page like this one.]

#v(2.5em, weak: true)

#invert[
  (Or if you really want to use a manual line break, \
  well, the one parallelopiped goes over the whole body. \
  Is that what you wanted?)
]

#v(2.5em, weak: true)

Hence it is best fit for #invert[a few words.]

=== Affect first

Highlights the first character of each word in the given string.
Useful for introducing specific terms and
highlighting what their abbreviation is.

```example
#fxfirst("Personal Knowledge Management") systems
facilitate surviving in an age of overload.

When reading,
#fxfirst(
  "they felt quite woozy,",
  fx: text.with(1.5em),
)
after having found out about the
#fxfirst(
  "numerous effects possible.",
  fx: emph,
)
```


== Diagram

/ Diagram: Visually explains a certain concept in a canvas,
  usually in the context of accompanying text.
/ State: Frozen state of certain properties.
  Usually represented by a node.
/ Transition: Properties changing from one state to another.
  Usually represented by an edge.
/ Canvas: Set of elements drawn into a confined `content`.

Some minds like to build graphical representations
of thought models in addition to having them just described in text.
Diagrams fill this role.

They are useful as a second line for conveying concepts.
They do not replace a text description though:
Since Typst doesn't support PDF accessibility yet,
it is highly recommended that they don't add any new information
that isn't in the text already.

Ultimately though your documents are your documents,
so use them as you see fit.

=== Using them

For drawing, manipulating and connecting shapes,
the `gfx` module is your friend,
which re-exports
#link("https://typst.app/universe/package/cetz")[cetz]
and adds neat helpers.
Assumed you've glob-imported all out of `flow`,
the usual boilerplate for a diagram looks like this:

```example
A typical rock-paper-scissors game
consists of all players deciding for one of
*rock*, *paper* or *scissors*,
where:

#let rock = oklch(60%, 0.2, 60deg)
#let paper = rock.rotate(120deg)
#let scissors = paper.rotate(120deg)

+ #text(rock)[*Rock*]
  loses to #text(paper)[*paper*]
+ #text(paper)[*Paper*]
  loses to #text(scissors)[*scissors*]
+ #text(scissors)[*Scissors*]
  loses to #text(rock)[*rock*]

#import gfx.draw: *
#let beats(it) = tag(
  it,
  tag: emph(text(0.8em)[beats]),
  anchor: "south",
  angle: it,
  padding: 0.1,
)
#gfx.diagram(
  nodes: (
    rock: (
      pos: (angle: -150deg, radius: 1),
      accent: rock,
    ),
    paper: (
      pos: (angle: -30deg, radius: 1),
      accent: paper,
    ),
    scissors: (
      pos: (angle: 90deg, radius: 1),
      accent: scissors,
    ),
  ),
  edges: (
    paper: beats("rock"),
    scissors: beats("paper"),
    rock: beats("scissors"),
  ),
  length: 4em,
)
```

== Slides <slides>

#caution[
  help write docs about the cursedness
]

== Icons

For labeling things concisely and memorably.
They are all accessible via `gfx.markers`, which is a dictionary
with the single-character identifier as value and this dictionary as key:

- `accent` is the color the marker is typically used with.
- `icon` is a function that renders to a `content` if needed.
- `long` is the long-form name.

For actually displaying it, just calling `icon` usually suffices.
It already uses the accent of the marker.
It can be customized using keyword arguments
such as `invert`, `radius`, `accent` and the works,
see `src/gfx/util.typ` where they're all commented.

Here's an overview over them all:

#table(
  columns: 4,
  align: (right, left, left, left),
  table.header([Icon], [Short], [Long], [Accent]),
  ..gfx.markers
    .pairs()
    .map(((short, (accent, icon, long))) => (
      icon(invert: false),
      raw(short),
      long,
      [#accent],
    ))
    .join()
)

They can also be put into a cetz canvas
by setting `contentize: false` on the icon
and setting the position of the lower left corner
via `at`:

```example
#import gfx.draw: *
#gfx.canvas({
  let (empty, unknown) = (" ", "?")
    .map(short =>
      gfx.markers.at(short).icon)
    .map(icon =>
      icon.with(contentize: false))

  line((0, 0), (5, 0), stroke: duality.green)
  empty(at: (0.75, 2), accent: duality.blue)
  unknown(at: (2, 2))
  empty(at: (3.25, 2))
})
```

== Utils

There's a few utilities defined for typing e.g. linear algebra.
You can import them into your document
via e.g. `#import linalg: *`
(if you've glob-imported flow).

Since those are mostly very short,
listing them here would be quite inefficient:
Consider checking out e.g. `src/util/linalg.typ` in flow's source code instead.
