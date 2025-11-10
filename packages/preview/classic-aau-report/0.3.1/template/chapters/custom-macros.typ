#import "../setup/macros.typ": *

= Custom Macros

== Listings

Typst has bulitin support for raw code blocks with syntax-highlighting.

These can be placed as is:

```typ
This is `typst` source code.

This means that *bold* is _highlighted_, and
#show: block
are also highlighted as expected
```
#bob(side: left)[I'm manually placed on the left]
#alice[Notice the blank line in the raw code block.]

Or inside a figure:

#figure(
  // it is also possible to load an external file and syntax higlight it.
  // raw(read("main.rs"), lang: "rust")
  ```rust
  fn main() {
    println!("Hello, World!");
  }
  ```,
  caption: [A piece of Rust code.],
)


== Revisioning

In the `setup/macros.typ` file you'll find macros to control revisions.
Use them if you want, or delete / ignore them.
The revision can be set in `main.typ` using ```typ #set-revision(n)```.

#rmv(1)[This is removed content for this revision and is highlighted as such.]
#add(1)[This is added content, highlighted for clarity.]
Doing both at once is also easy.
How #change(1)[is this great][great is this]!

#rmv(
  2,
)[Removed content in a future revision is not shown as removed yet.] // does show up
#rmv(
  0,
)[And removed content in an old revision is completely gone!] // does not show up
#add(2)[Likewise with added content, I am not shown yet] // does not show up
#add(
  0,
)[I was added in a previous iteration, and show up normally.] // does show up

These macros can be wrapped in pretty much anything, including chapters, figures and tables.
#alice[Does not flow well, rewrite later.]
#bob[I disagree]
== Acronyms

In `main.typ` you can initialize the acronyms / glossary.

Invoke an acronym via the label syntax, "```typ @LTS```": @LTS. Subsequent uses are then short: @LTS, unless used with the `:long` or `:both` suffix.

To pluralize an acronym, use the `:pl` suffix (can be combined with the previous).
This is show in @tab:acronyms-usage.

#figure(
  table(
    columns: 2,
    align: (_, y) => if y == 0 { center } else { left },
    [*Suffix*], [*Result*],
    [`:pl`], [@LTS:pl],
    [`:long`], [@LTS:long],
    [`:both`], [@LTS:both],
    [`:long:pl`], [@LTS:long:pl],
    [`:both:pl`], [@LTS:both:pl],
  ),
  caption: [Basic syntax of invoking acronyms.],
) <tab:acronyms-usage>

The @web acronym is explicitly defined to not have its key as the shorthand.
@PBL is just another acronym.

== Subfiling / Scoping

It is possible to sub-file the report any way you so desire (a file per chapter / section), but please note that the online app is limited to 100 files per project (free tier) as of writing.
Also note that the `setup/macros.typ` file must be imported everywhere you wish to use a macro.

Furthermore, set and show rules are limited to their current scope, which includes files (setting a show rule in a parent file _will_ apply to the child, but not vice versa).

To scope a set or show rule within a file, use the ```typst #{}``` or ```typst #[]``` notation.

#v(1em) // add vertical spacing manually

#[
  #alice[I am scoped]
  #show "foo": underline
  foobar foo foo bar
]
#alice(side: right)[End of scope]
foo bar foo


== A note on `todonotes`

The todo macros attempts to mimic the `todonotes` package for LaTeX.
It is not perfect, but it works in most scenarios.

Please note that 4 or more notes in a row will give a compiler warning (if they overlap), as the Typst compiler iteratively tries to move the notes and eventually gives up.
You can either ignore the warning (at some point the notes will just be placed immediately and overlap), or move the notes around using the `side: (left | right | auto)` argument.
