#set page(width: auto, height: auto)
#import "@local/lingotree:1.0.0": *


#render(
  tree(
    tree(
      [every],
      tree(
        [Russian],
        [novel],
      )
    ),
    tree(
      [I],
      tree(
        [read],
        tree(
          [every],
          tree(
            [Russian],
            [novel],
          ),
          // Here we set default parameters for "every Russian novel"
          defaults: (
            // Note: the color parameter affects the color of branches and also the color of nodes
            color: gray, 
            branch-stroke: stroke(dash: "dotted", thickness: 0.5pt)
          )
        ),
      )
    ),
    layer-spacing: 1em,
  )
)