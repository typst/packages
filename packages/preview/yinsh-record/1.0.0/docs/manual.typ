#set table(
stroke: none,
gutter: 0.2em,
fill: (x, y) =>
  if y == 0 { gray }, 
inset: (right: 1.5em),
)

#show table.cell: it => {
if it.y == 0 {
  set text(white)
  strong(it)
} 
else if it.body == [] {
  pad(..it.inset)[_None_]
} 
else {
  it
}
}

#table(
columns: 4,
[Command], [Prarameter 1], [Prarameter 2], [Description],

[`P`], [ `<coordinate>`], [], [Place a ring],

[`S`], [`<coordinate>`], [], [Select a ring and place the stone (marker)],

[`M`], [`<coordinate>`], [], [Move a ring],

[`X`], [`<coordinate>`], [], [Remove a ring],

[`R`], [`<first-coordinate>`], [`<last-coordinate>`], [Remove a row that have five stones],
)
== note
- *Coordinate's form looks like `a1`, `k11`, etc. The origin is `b2`. The first coordinate component can only range from `a` to `k`, and the second ranges from `1` to `11`. `k` and `11` are included in the range.*
- By default, the starting player plays "white". This feature differs from _Go_. 
- The marker will be called _stone_. It has two colors.
- *This package will check the validity of every round. In order to play or record the commands, users may understand how to play yinsh. See #link("https://www.gipf.com/yinsh/rules/rules.html",text(fill: blue)[_rules_]).*

== example

```
#import "yinsh.typ": play, record

// the page must be large enough
// If you want to `record` the commands, don't use auto height!
#set page(width: auto, height: 29cm) 

#let commands = ("
p f6
p b7
p d4
p e10
p g9
p g11
p c6
p a5
p a2
p d6
s c6
m c8
")

// show only the current situation
#play(commands)

// change from "white first" to "black-first" 
#play(commands, black-first: true)

// show the game records step by step
#record(commands, black-first: true) 

// show the second step
#record(commands, step: 2) // (step 0 refers to epmty board.)
```
