#import "@preview/cross-circle:1.0.0" as cross-circle


#set page(paper: "a5", margin: 5mm, flipped: true, background: {
  rect(width: 100%, height: 100%, fill: orange.lighten(80%))
  place(center+horizon,rect(width: 100%-5mm, fill: white, height: 100%-5mm, stroke: (paint:orange, dash: "dotted"),radius: 5pt))
})

#set text(lang: "en", region: "GB")
#set enum(numbering: (x)=> strong[Step #x:])

#show heading.where(level:2): it => [
  #block(width: 100%, stroke: (bottom: (paint: orange.lighten(40%), dash: "dashed")),inset: (bottom: 0.4em), [#text(sym.diamond.filled, 0.7em, baseline: -1.5pt, orange) #it.body])
]


#show raw.where(block: true): block.with(width: 100%, inset: 0.5em, stroke: (paint: gray, thickness: 0.5pt), radius: 3pt)

#show link: set text(blue)

#grid(columns: (1fr,1fr), stroke: (bottom: orange), inset: (bottom: 0.5em), align: (left+top,bottom+right),[
  = Cross'n'Circles #text(0.6em, weight: "regular")[v1.0.0]
  #text(0.7em)[A short guide on how to use this debate resolving toolbox]
],[
  #set text(0.9em)
  created by Joel\
  #link("https://codeberg.org/joelvonrotz/typst-cross-circle")[Source Code],
  #link("https://typst.app/universe/package/cross-circle")[Typst Universe]
])


#set text(lang: "en", region: "GB",0.9em)
#columns(3, gutter: 5mm)[
  

== Preparations

1. Import the package

```typ
#import "@preview/cross-circle:1.0.0": cross-circle
```


== How to Play

1. Start a game

```typst
#let game = cross-circle[]
```

2. Draw the field (centering optional)

```typst
#align(center, game.field)
```

3. State current player and winner

```typst
#if game.winner != none {
  [Player #game.winner won!]
} else {
  [Player #game.current's turn]
}
```





4. Play the game -- each *valid* entry changes the current player to the other!

```typ
#let game = cross-circle[124123]
```

#block(stroke: orange+0.5pt, inset: 0.3em, radius: 3pt )[
  #show: par.with(hanging-indent: 1em)
  #text(orange)[*Note!*] -- Basic filtering such as duplicate purging is done automatically!\
  So `111221332` will end up as `(1,2,3)` and for players `(1,2,1)` respectively.
]

The example (Steps 1-4) applied, results in:

#block(width: 100%, above: 0.5em, below: 1.5em, inset: 0.4em, stroke: gray+0.5pt, radius: 0.24em)[
  #let game = cross-circle.cross-circle[124123]
  #align(center,game.field)
  #if game.winner != none {
    [Player #game.winner won!]
  } else {
    [Player #game.current's turn]
  }
]

And in case of a winner `[12437]`:

#block(width: 100%, above: 0.5em, below: 0.5em, inset: 0.4em, stroke: gray+0.5pt, radius: 0.24em)[
  #let game = cross-circle.cross-circle[12437]
  #align(center,game.field)
  #if game.winner != none {
    [Player #game.winner won!]
  } else {
    [Player #game.current's turn]
  }
]



#colbreak()

== Customization

=== Change Width and height

/ `width`: The width of the whole game field\ _default_: #raw(`3cm`.text,lang: "typc")
/ `height`: The height of the whole game field \ _default_: #raw(`3cm`.text,lang: "typc")

```typst
#cross-circle.cross-circle(
  width: 6cm,
  height: 2cm
)[].field
```

#cross-circle.cross-circle(width: 5cm, height: 2cm)[].field

=== Change Player Icons


/ `icons`: The respective player's icons given as an 2-element array of (main) type #box(inset: (x:1pt),outset:(y:2pt), stroke: gray+0.5pt, radius: 2pt)[`content`]. First position is player 1's icon, the second player 2's icon.
_default_: #raw(`(
  emoji.crossmark, emoji.circle.green
)`.text,lang: "typm")

#text(gray)[next page for example!]
#colbreak()

```typst
#cross-circle.cross-circle(icons: (
    emoji.cat, emoji.dog
  )
)[..].field
```

#cross-circle.cross-circle(icons: (
    emoji.cat, emoji.dog
  )
)[1234578].field

=== Change Player Color

/ `color`: color of the winners and draw condition.

_default_: #raw(`(
  player1: rgb("#dd2e44"),
  player2: rgb("#78b159"),
  draw: orange
)`.text,lang: "typc")

```typst
#cross-circle.cross-circle(
  color: (
    player1: purple,
    player2: blue,
    draw: aqua
  )
)[..].field
```

#columns(2)[
  
  #cross-circle.cross-circle(color: (
      player1: purple,
      player2: blue
    )
  )[12457].field
  #colbreak()
  #cross-circle.cross-circle(color: (
      player1: purple,
      player2: blue
    )
  )[132597].field
  
]
#align(center,[
  
#cross-circle.cross-circle(color: (
    player1: purple,
    player2: blue,
    draw: aqua
  )
)[215374986].field
])

=== Disable Raster Helper

/ `helper`: draws field numbers into empty fields for easier play.#h(1fr)_default_: #raw(`true`.text,lang:"typc")

```typst
#cross-circle.cross-circle(
  helper: false
)[..].field
```

#columns(2)[
`helper: true`
#cross-circle.cross-circle(helper: true)[167829].field  

#colbreak()

`helper: false`
#cross-circle.cross-circle(helper: false)[167829].field
]

== What `cross-circle()[]` returns

The function #raw(lang: "typc","cross-circle[]()") returns three parameters all the time:

/ `field`: the current playing field in a #raw(`#box(..)`.text,lang:"typst") environment. Gets updated automatically to the current state. Only the steps up until a winner is determined are rendered. After that helper numbers are removed and the game is essentially locked.
/ `winner`: once the game is complete, the #underline[winner player's icon] is returned *or* #underline[in case of a draw #raw(`"draw"`.text, lang: "typc")] is returned. In other cases, #raw(`none`.text,lang: "typc") is returned.
/ `current`: the current player's turn. The respective icon is returned.

This should be enough to for example build _Ultimate cross-circle_.


#v(1fr)
#h(1fr)
Have fun using it #emoji.face.wink
]