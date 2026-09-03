#import "@preview/palimpsest:0.1.0": *

#reviewer(1)[

  #exchange(<r1-1>)[
    The authors should clarify how immortal time bias is handled in the
    emulation.
  ][
    We thank the reviewer for this important point. The overlap of
    propensity scores has now been assessed graphically (see the method
    in the manuscript). #pinpoint(<r1-1>)
  ]

  #exchange(<r1-2>)[
    The positivity assumption is not discussed.
  ][
    The positivity assumption is now assessed graphically.

    #pinpoint(<r1-2>, excerpt: true)
  ]

  #exchange(<r1-3>)[
    Please double-check the wording of the discussion section.
  ][
    We have kept this wording, which we believe remains appropriate at
    this stage. #pinpoint(<r1-3>)
  ]

]

#reviewer(2)[

  #exchange(<r2-1>)[
    A sensitivity analysis would strengthen the results.
  ][
    A truncation-based sensitivity analysis has been added, as suggested
    by @jones2021. #pinpoint(<r2-1>)
  ]

]

For reference, the propensity score figure is #xref(<fig-positivity>).

#letter-bibliography("/examples/pilot/responses.bib")
