#import "@preview/ilm:1.0.0": *

#show: ilm.with(
  title: [The Beauty of\ Sharing Knowledge],
  author: "Max Mustermann",
  date: datetime(year: 2024, month: 03, day: 19),
  abstract: [
    'Ilm (Urdu: #text(lang: "ur", font: "Noto Naskh Arabic")[عِلْم]) is the Urdu term for knowledge. In its general usage, 'ilm may refer to knowledge of any specific thing or proposition or any form of "learning". Subsequently, the term came to be used to refer to various categories of "sciences", especially when used in its plural form ('ulum).
  ],
  preface: [
    #align(center + horizon)[
      This template is made possible by Matthew Butterick's\ excellent #link("https://practicaltypography.com")[_Practical Typography_] book.

      Thank you Mr. Butterick!
    ]
  ],
  bibliography: bibliography("refs.bib"),
  figure-index: (enabled: true),
  table-index: (enabled: true),
  listing-index: (enabled: true)
)

= Text
== External links
'Ilm adds a small maroon circle to external (outgoing) links #link("https://github.com/talal/ilm")[like so].

This acts as a hint for the reader so that they know that a specific text is a hyperlink. This is far better than #underline[underling a hyperlink] or making it a #text(fill: blue)[different color]. Don't you agree?

#let wiki-url(stub) = {
  return link("https://en.wikipedia.org/wiki/"+stub, stub)
}

== Blockquotes
'Ilm also exports a `blockquote` function which can be used to create blockquotes. The function has one argument: `body` of the type content and can be used like so:

```typst
#blockquote[
  A wizard is never late, Frodo Baggins. Nor is he early. He arrives precisely when he means to.
]
```

the above code will render the following:

#blockquote[A wizard is never late, Frodo Baggins. Nor is he early. He arrives precisely when he means to. -- Gandalf @wikipedia_gandalf]

== Small- and all caps
'Ilm also exports functions for styling text in small caps and uppercase, namely: `smallcaps` and `upper` respectively.

These functions will overwrite the standard #link("https://typst.app/docs/reference/text/smallcaps/")[`smallcaps`] and #link("https://typst.app/docs/reference/text/upper/")[`upper`] functions that Typst itself provides. This behavior is intentional as the functions that 'Ilm exports fit in better with the rest of the template's styling.

Here is how Typst's own #std-smallcaps[smallcaps] and #std-upper[upper] look compared to the 'Ilm's variants:\
#hide[Here is how Typst's own ] #smallcaps[smallcaps] and #upper[upper]

They both look similar, the only difference is that 'Ilm uses more spacing between individual characters.

If you prefer Typst's default spacing then you can still use it by prefixing `std-` to the functions: ```typst #std-smallcaps()``` and ```typst #std-upper()```.

== Footer
If a page does not begin with a chapter then we display the chapter's name, to which the current section belongs to, in the footer. #link(<demo>)[Click here] to go to @demo down below and see the footer in action.

= Figures
The template also displays an index of figures (images), tables, and listings (code blocks) at the end of the document, if you set the respective options to `true`:

```typst
#show: ilm.with(
  figure-index: true,
  table-index: true,
  listing-index: true
)
```

== Tables
In order to increase the focus on table's content, we minimize the table's borders by using thin gray lines instead of thick black ones. Additionally, we use small caps for the header row. Take a look at the table below:

#let unit(u) = math.display(math.upright(u))
#let si-table = table(
  columns: 3,
  table.header[Quantity][Symbol][Unit],
  [length], [$l$], [#unit("m")],
  [mass], [$m$], [#unit("kg")],
  [time], [$t$], [#unit("s")],
  [electric current], [$I$], [#unit("A")],
  [temperature], [$T$], [#unit("K")],
  [amount of substance], [$n$], [#unit("mol")],
  [luminous intensity], [$I_v$], [#unit("cd")],
)

#figure(caption: ['Ilm's styling], si-table)

For comparison, this is how the same table would look with Typst's default styling:

#[
  #set table(inset: 5pt, stroke: 1pt + black)
  #show table.cell.where(y: 0): it => {
    v(0.5em)
    h(0.5em) + it.body.text + h(0.5em)
    v(0.5em)
  }
  #figure(caption: [Typst's default styling], si-table)
]

= Code
== Custom font
'Ilm uses the #link("https://typeof.net/Iosevka/")[_Iosevka_] font for raw text instead of the default _Fira Mono_. If Iosevka is not installed then the template will fall back to Fira Mono.

#let snip(cap) = figure(caption: cap)[
```rust
fn main() {
    let user = ("Adrian", 38);
    println!("User {} is {} years old", user.0, user.1);

    // tuples within tuples
    let employee = (("Adrian", 38), "die Mobiliar");
    println!("User {} is {} years old and works for {}", employee.0.1, employee.0.1, employee.1);
}
```
]

#show raw: set text(font: "Fira Mono")
For comparison, here is what `code` in Fira Mono looks like:
#snip("Code snippet typeset in Fira Mono font")

#show raw: set text(font: ("Iosevka", "Fira Mono"))
and here is how the same `code` looks in Iosevka:
#snip("Code snippet typeset in Iosevka font")

In the case that both code snippets look the same then it means that Iosevka is not installed on your computer.

= Footer Demo
== Subheading
#lorem(120)

#lorem(55)

#lorem(120)

#pagebreak()
== Subheading Two <demo>
#lorem(55)
