# Arborly

A library for producing beautiful syntax tree graphs.

## Usage

This package requires typst 0.13

To use this package, add the following code:

```typ
#tree[
  // Tree goes here
]
```

Example:

```typ
#import "@preview/arborly:0.3.2": tree

#tree[TP
  [NP
    [N [this]]
  ]
  [VP
    [V [is]]
    [NP
      [D [a]]
      [N [wug]]
    ]
  ]
]
```
![example](https://raw.githubusercontent.com/pearcebasmanm/arborly/main/docs/example.png)

For more details and examples, see `docs/manual.pdf` in the github repository.

## Feedback

I'm neither a linguist nor a graphics programmer, so if you see room for improvement please make an issue.
