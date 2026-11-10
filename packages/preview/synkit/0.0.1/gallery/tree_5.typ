#import "@preview/synkit:0.0.1": *
#show: eg-rules
#set page(height: 3cm, width: 10cm, margin: (bottom: 1em, top: 1em, x: 1em))

In-line movement coupled with a numbered example.

#eg(labels: (<s-plain>, <s-move>))[
  - Who do you think saw Mary?
  - #move(
      "[CP Who do you think [(CP)[TP<who>saw Mary]]]",
      arrows: ((from: "who2", to: "who1", dash: "solid", color: black),),
    )
] <eg-wh>
