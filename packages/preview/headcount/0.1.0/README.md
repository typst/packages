# `headcount`

This package allows you to make **counters depend on the current chapter/section number**.

This works for **figures, theorems, and any other counters**.

The advantage compared to [rich-counters](https://typst.app/universe/package/rich-counters/) is that you stick with native `counter`s and you can influence e.g. the `figure` counter directly without writing a new `show` rule with a custom counter or so.

## Showcase

In the following example, we demonstrate how you can inherit 1 level of the heading counter for figures and 2 levels for theorems.

```typ
#import "@preview/headcount:0.1.0": *
#import "@preview/great-theorems:0.1.0": *

#show: great-theorems-init

#set heading(numbering: "1.1")

// contruct theorem environment with counter that inherits 2 levels from heading
#let thmcounter = counter("hello")
#let theorem = mathblock(
  blocktitle: [Theorem],
  counter: thmcounter,
  numbering: dependent-numbering("1.1", levels: 2)
)
#show heading: reset-counter(thmcounter, levels: 2)

// set figure counter so that it inherits 1 level from heading
#set figure(numbering: dependent-numbering("1.1"))
#show heading: reset-counter(counter(figure.where(kind: image)))

= First heading

The theorems inherit 2 levels from the headings and the figures inherit 1 level from the headings.

#theorem[Some theorem.]
#theorem[Some theorem.]
#figure([SOME FIGURE], caption: [some figure])
#figure([SOME FIGURE], caption: [some figure])

== Subheading

#theorem[Some theorem.]
#figure([SOME FIGURE], caption: [some figure])
#figure([SOME FIGURE], caption: [some figure])

= Second heading

#theorem[Some theorem.]
#figure([SOME FIGURE], caption: [some figure])
#theorem[Some theorem.]
```
![](example.png)

## Usage

To make another `counter` inherit from the heading counter, you have to do **two** things.

1. For the numbering of your counter, you have to use `dependent-numbering(...)`.
   
   - `dependent-numbering(style, level: 1)` (needs `context`)

     Is a replacement for the `numbering` function, with the difference that it precedes any counter value with `level` many values of the heading counter.

   ```typ
   #import "@preview/headcount:0.1.0": *
   
   #set heading(numbering: "1.1")
   
   #let mycounter = counter("hello")
   
   = First heading
   
   #context mycounter.step()
   #context mycounter.display(dependent-numbering("1.1"))
   
   = Second heading
   
   #context mycounter.step()
   #context mycounter.display(dependent-numbering("1.1"))
   
   #context mycounter.step()
   #context mycounter.display(dependent-numbering("1.1"))
   ```

   This displays the desired amount of levels of the heading counter in front of the actual counter.
   However, as you can see in the code above, our actual counter does not yet reset in each section.

2. For resetting the counter at the appropriate places, you need to equip `heading` with the `show` rule that `reset-counter(...)` returns.

   - `reset-counter(counter, level: 1)` (needs `context`)

     Returns a function that should be used as a `show` rule for `heading`. It will reset `counter` if the level of the heading is less than or equal to `level`.

   **Important:** This `show` rule should be placed as the _last_ `show` rule for `heading`, or at least after `show` rules for `heading` that employ a custom design, see [here](https://forum.typst.app/t/i-figured-broken-with-custom-template/1730/10?u=jbirnick) for an explanation.

   ```typ
   #import "@preview/headcount:0.1.0": *
   
   #set heading(numbering: "1.1")
   #show heading: reset-counter(mycounter, levels: 1)
   
   #let mycounter = counter("hello")
   
   = First heading
   
   #context mycounter.step()
   #context mycounter.display(dependent-numbering("1.1"))
   
   = Second heading
   
   #context mycounter.step()
   #context mycounter.display(dependent-numbering("1.1"))
   
   #context mycounter.step()
   #context mycounter.display(dependent-numbering("1.1"))
   ```

**Note:** The `level` that you pass to `dependent-numbering(...)` and the `level` that you pass to `reset-counter(...)` must be the _same_.

## Limitations

Due to current Typst limitations, there is no way to detect manual updates or steps of the heading counter, like `counter(heading).update(...)` or `counter(heading).step(...)`.
Only occurrences of actual `heading`s can be detected.
So make sure that after you call e.g. `counter(heading).update(...)`, you place a heading directly after it, before you use any counters that depend on the heading counter.
