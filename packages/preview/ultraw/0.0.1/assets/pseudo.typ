#import "../export/main.typ": *
#import "@preview/ultraw:0.0.1": uraw-pseudo
#import "utils.typ": *

#show: format-doc

#show: uraw

#grid(
  columns: (auto, 1fr),
  column-gutter: 3mm,
  align: bottom,

  source(
    ```typ
    #show: uraw

    #figure(
      uraw-pseudo(header: [Greeting procedure])[
        #pseudo-info[*Procedure* greeting someone]
        + $n <-$ the person's name
        + *if* $n$ is a fake name *then*
          + stay alert
        + *else*
          + say "Hi"
        + *end if*
      ],
      caption: [Some greeting algorithm.],
    ) <greeting>

    A greeting procedure is described in @greeting.
    The "stay alert" of @greeting.3 gives a slightly paranoid version.
    ```,
  ),

  [
    #figure(
      uraw-pseudo(header: [Greeting procedure])[
        #pseudo-info[*Procedure* greeting someone]
        + $n <-$ the person's name
        + *if* $n$ is a fake name *then*
          + stay alert
        + *else*
          + say "Hi"
        + *end if*
      ],
      caption: [Some greeting algorithm.],
    ) <greeting>

    A greeting procedure is described in @greeting.
    The "stay alert" of @greeting.3 gives a slightly paranoid version.
  ],
)
