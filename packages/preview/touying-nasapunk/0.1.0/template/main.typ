#import "@preview/touying-nasapunk:0.1.0": *

#show: nasapunk-theme.with(
  aspect-ratio: "16-9",
  mission: [SYSTEMS RESEARCH / TECHNICAL BRIEFING],
  mission-code: [MSN-01],
  config-info(
    title: [Efficient Inference],
    subtitle: [Mission briefing template],
    author: [Your Name],
    institution: [Your Lab],
    date: datetime.today(),
  ),
)

#set heading(numbering: "1.1")

#title-slide()
#outline-slide(depth: 1)

= Research objective
== Problem and constraints
#slide[
  #cols(gutter: 24pt)[
    === Research question
    Can predicted activations reduce the real cost of a feed-forward layer?

    - Preserve output quality
    - Keep the predictor cheap
    - Use hardware-friendly groups
  ][
    === Operating constraints
    #hint[
      *End-to-end latency*

      Sparsity is an intermediate metric; wall-clock speedup is the goal.
    ]
    #v(8pt)
    Budget includes prediction, selection, and sparse execution.
  ]
]

= Method & evaluation
== Predictor pipeline
#slide[
  #grid(columns: (1fr, auto, 1fr, auto, 1fr), gutter: 10pt, align: horizon,
    block(fill: palette.panel, inset: 16pt, width: 100%)[*Input* \ Hidden state $x$],
    [→],
    block(fill: palette.panel, inset: 16pt, width: 100%)[*Predictor* \ Low-rank model],
    [→],
    block(fill: palette.panel, inset: 16pt, width: 100%)[*Execution* \ Selected groups],
  )
  #v(16pt)
  $ hat(s) = V sigma(U x), quad y = (s dot.o m) W_"down" $
  #pause
  #hint[Prediction and selection must cost less than the time sparse execution saves.]
]

== Evaluation protocol
#slide[
  #table(
    columns: (1.1fr, 1.6fr, 1.8fr),
    table.header([*Track*], [*Measurement*], [*Decision*]),
    [Quality], [Task accuracy], [Acceptable quality loss?],
    ..table-highlight([Runtime], [*End-to-end latency*], [Net speedup after overhead?]),
    [Hardware], [Memory / bandwidth], [Efficient grouped execution?],
  )
  #v(12pt)
  #hint[Establish dense and oracle baselines before comparing real predictors.]
]

== Implementation notes
#slide[
  #cols(gutter: 24pt)[
    ```python
    def sparse_ffn(x):
        mask = predictor(x)
        return grouped_ffn(x, mask)
    ```
  ][
    - Sweep group size and predictor rank
    - Profile `predictor` independently
    - Record the complete runtime path
  ]
]

== Emphasis & status panels
#slide[
  #set text(16pt)
  *Bold marks the key result.* _Italic marks an interpretation._

  #cols(gutter: 18pt)[
    #callout(kind: "info")[Report _prediction overhead_ separately.]
    #callout(kind: "warning")[Check predictor cost before claiming a net speedup.]
    #callout(kind: "success")[Quality and latency checks passed.]
  ][
    #callout(kind: "danger")[Quality is below threshold; stop this configuration.]
    #callout(kind: "note", title: [CUSTOM TITLE])[Any title can be supplied.]
    #todo[Add group-size and end-to-end latency experiments.]
  ]
]

#focus-slide[*Measure the whole system.* \ _Validate the design end to end._]
