# Usage

## Basic

To start off, create a `.typ` file that will hold your vault.
Let's call it `vault.typ`.

```typ
#import "@preview/basalt-lib:1.0.0": new-vault, xlink, as-branch

#let vault = new-vault(
  note-paths: (),
  include-from-vault: path => include path,
)
```

Due to current limitations in the way Typst handles paths and includes,
we must manually specify the path for every note in our vault,
as well as provide a function that Basalt can use to `include` files from the vault.

Now, we can create a note file.
Let's call it `note1.typ`.
Also, add the file's path to `vault.typ`.

```typ
#import "vault.typ": *
#show: vault.new-note.with(
  name: "note1",
)

Insightful note content...
```

```typ
#import "@preview/basalt-lib:1.0.0": new-vault, xlink, as-branch

#let vault = new-vault(
  note-paths: (
    "note1.typ",
  ),
  include-from-vault: path => include path,
)
```

Note that the `name: "note1"` argument to `new-note`.
`name` is completely arbitrary, but this is how you attach metadata to a note which Basalt can see.
You could choose to attach any metadata you want: `creation-date`, `category`, `uuid`, etc.

You can compile and view `note.typ` now, and it will look about as expected.
All we've really done so far is write a bunch of extra code to display one file.

## Linking

Let's add a second note,
call it `note2.typ`.
Remember to add it to `vault.typ`, but I'll omit that for brevity.

```typ
#import "vault.typ": *
#show: vault.new-note.with(
  name: "note2",
)

Here I can #xlink(name: "note1")[link] to other notes.
```

Compiling this note gives you a clickable link to the pdf of `note1`.
In this way, you can have single notes that can link to each other based on their defined metadata,
rather than their paths which may change.

## Outsourcing note-paths

To make it easier to track your notes,
you may want to change how the `note-paths` are added to your vault.

```typ
#import "@preview/basalt-lib:1.0.0": new-vault, xlink, as-branch

#let vault = new-vault(
  note-paths: csv("note-paths.csv").flatten(),
  include-from-vault: path => include path,
)
```

and in `note-paths.csv`...

```csv
note1.typ
note2.typ
```

This csv is much easier to generate or manage automatically with external tools or scripts.

## Formatting

Rather than applying formatting rules to each note individually,
creating tons of redundancy and reducing composability,
you can define vault-wide formatters.

```typ
#import "@preview/basalt-lib:1.0.0": new-vault, xlink, as-branch

#let vault = new-vault(
  note-paths: csv("note-paths.csv").flatten(),
  include-from-vault: path => include path,
  formatters: (
    (body, ..sink) => {
      set text(12pt)
      body
    },
  ),
)
```

These formatters are passed in 3 arguments:
+ `body` contains the note content.
+ `meta` contains the arguments given to new-note.
+ `root` is a boolean that indicates whether the note being formatted right now is the top-level note (the root), or whether it is being included in another note (as a branch).

You can use `meta` and `root` to determine what formatting rules are appropriate for a given note.
For example, you likely won't want to affect document layout if the current note is a branch being included in another note.

```typ
#import "@preview/basalt-lib:1.0.0": new-vault, xlink, as-branch

#let vault = new-vault(
  note-paths: csv("note-paths.csv").flatten(),
  include-from-vault: path => include path,
  formatters: (
    (body, ..rest) => {
      set text(12pt)
      body
    },
    (body, root: true, ..rest) => {
      if not root {
        return body
      }

      set page("us-letter")
      body
    },
    (body, meta: (kind: "split"), ..rest) => {
      if not meta.keys().contains("kind") {
        return body
      }
      if meta.kind != "split" {
        return body
      }

      set page(flipped: true, columns: 2)
      body
    },
  ),
)
```

These formatters will automatically be applied to your notes,
but remember to recompile to see the effects.

## Including other notes

Sometimes you may want to include a note inline.
However, doing this directly with `include` could cause problems as the included note will be formatted as a root note.
To solve this, just convert the included note to a branch.
Branches are formatted with `root=false`.

```typ
#import "vault.typ": *
#show: vault.new-note.with(
  name: "compilation",
)

= Compilation

#pagebreak()
#as-branch(include "note1.typ")
#pagebreak()
#as-branch(include "note2.typ")
```

Note also that any `xlink`s to notes included in the current document will automatically become in-document links rather than cross-document links!
This means that you can click on them and be taken to the start of the included note rather than opening its separate pdf file.
