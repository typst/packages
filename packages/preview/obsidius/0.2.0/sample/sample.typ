#import "@preview/obsidius:0.2.0": *

#show: notes.with("Template summary");

= Overview

Here is a simple step-by-step guide on how to use this template:

+ Create a new document `mynotes.typ` with the following content:
  ```typst
  #import "lib.typ": *

  #show: notes.with("Your fancy title");
  ```
+ Write your normal typst notes
+ Use additional feature such as callouts
+ Have fun #emoji.party

== Standard functionality <default>

/ Template: a preset format for a document or file.

With this template, you can write notes with a modern style.
It features sans-serif fonts and *callouts* for quotes and definitions.
Colors are based on the tailwind color scheme.
The style is heavily inspired by Obsidian #footnote[https://obsidian.md/]. The callout feature is also borrowed from them.
You can also add #highlight[callouts] to your document, instructions are below @custom.

#quote(attribution: "The author, 2025")[
I use this template to summarize my lectures at university. It is so great.
]

Tables feature a custom style as well:

#figure(caption: "Feature overview",
table(columns: (auto, auto, auto),
  table.header([Feature], [Default], [This template]),
  [Modern style], [#emoji.crossmark], [#emoji.checkmark.box],
  [Colorful boxes], [#emoji.crossmark], [#emoji.checkmark.box],
))

== Additional functions

In addition to the default functions @default, you also get additional callouts for _warnings_, _solutions_ and more! @callouts

#warning[
  Once you started using this template, you can never stop!
]

#solution[
  Attend the lectures to use it even more often!
]

You can also include questions to help learn the lecture content:

#questions[
  + How do I use the notes template?
  + What additional functions does the notes template provide?
]

You can compare two things:

#compare[A][B][
- more features
- more complicated
][
- not all features in there
- simpler to use
]

You can also write pseudo code including math content:

#code(params: (
  input: [side lengths a and b as float],
  output: [area as float]
))[Get area][
+ #lorem(5)
+ return $A = a times b$
]

== Custom callouts <custom>

Feel free to add your own custom callouts to your document if you need more.
To keep the colors consistent, I recommend using colors from the Tailwind color scheme #footnote[https://tailwindcss.com/docs/colors].
For example, you could add a todo callout and use it together with the _cheq_ package #footnote[https://typst.app/universe/package/cheq]:

```typst
#import "@preview/cheq:0.2.2": checklist

#show: checklist.with(stroke: rgb("#6F05E7"))

#let todo(content) = {
  callout("checklist", "ToDo", content,
    (rgb("#6F05E7"), rgb("#EDE8FD"), rgb("#C4B3FF")))  // hint: use tailwind colors 700, 100, 300
}

#todo[
  - [x] show how to create custom color boxes
  - [ ] create more functions
]
```

Which would look like this:

#import "@preview/cheq:0.4.0": checklist

#show: checklist.with(stroke: rgb("#6F05E7"))

#let todo(content) = {
    callout("checklist", "ToDo", content,
        (rgb("#6F05E7"), rgb("#EDE8FD"), rgb("#C4B3FF")))
}
#todo[
  - [x] #lorem(5)
  - [ ] #lorem(7)
]

= List of all available callouts <callouts>

#let text = lorem(20)

#note(text)

#summary(text)

#fact(text)

#solution(text)

#idea(text)

#question(text)

#warning(text)

#problem(text)

#example(text)
