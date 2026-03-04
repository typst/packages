#import "@preview/bidi-flow:0.1.0": *
#import "@preview/booktabs:0.0.4": *
#show: bidi-flow
#set par(justify: true)
#set page(margin: 1.25in)
#show heading: it => [
  #v(.45em)
  #it
  #v(.25em)
]
#[
  #set align(center)
  #set text(size: 1.75em)
  #v(20pt)
  #r Bidi--Flow (כיוון אוטומטי)
  #v(20pt)
]

This Package removes the need to maunaly set `text(lang: "ar")` / `set text(dir:rtl)` whenver changing languages from RTL to LTR lang. It works by Detecting Direction using the First Character, similalry to _MS Words_, _Apple Notes_, _Obsidian_, _Notion_ etc..

== Show Case
הפסקה הזו מתחילה בעברית, לכן תסומן כ-`RTL`.

This one is english, so would be `LTR`.

== Tables  and Lists

- עבור רשימות
- The first Item decides For Lists.
\
+ This one starts in english
+ אז הכל יהיה באנגלית


#table(columns: 2)[תא ראשון קובע][makes the table][The First Cel][Makes the deal]

#table(columns: 2)[This Table starts in enlighs][So it will be LTR][הטבלה מתחילה באנגלית][אז היא תהיה LTR]

= Using Invisble Chars to force direction
Sometimes, the default behaviour needs to be overdone. for that---the package supplies the `#r` and `#l` variables, which are insisible `ltr`/`rtl` chars.

#r This paragraph starts with english, but since it realy starts with `#r`,\ it will be RTL

== Maths dosnt count as char
Even though Maths is techincly _LTR_, it dosn't count as paragraphs may start with Math, but still be RTL.
