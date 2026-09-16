#import "@preview/algorithmic:1.0.7"
#import algorithmic: algorithm-figure, style-algorithm

= Experiments and Results

#show: style-algorithm

#algorithm-figure(
  "Explore Cats",
  {
    import algorithmic: *

    Line[*Input:* Some input]
    Line[*Output:* Some output]
    Line[*Result:* Final output]
    LineBreak

    For([condition], {
      Line[dosomething]
    })

    If([condition], {
      Line[dosomething]
    })
    Else({
      Line[dosomething]
    })

    IfElseChain(
      [condition],
      {
        Line[pos dosomething]
      },
      // else
      Line[neg dosomething],
    )

    For([each condition], {
      Line[dosomething]
    })

    While([condition], {
      Line[dosomething]
    })

    Comment[tcc annotation]
    Comment[tcp annotation]
  },
)
