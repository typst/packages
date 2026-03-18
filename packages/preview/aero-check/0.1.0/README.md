# aero-check

This template is meant to create checklists with a style inspired by aviation checklists.

It includes 2 different styles!

## Usage

Start your checklist with the following code:

```typst
#import "@preview/aero-check:0.1.0": *

#show: checklist.with(
  title: "Title",
  // disclaimer: "",
  // 0 or 1
  // style: 0,
)
```

You can then add items to your checklist with the following code:

```typst
#topic("Topic")[
  #section("Section")[
    #step("Step", "Check")
    #step("Step", "Check")
    #step("Step", "Check")
    #step("Step", "Check")
  ]
#section("Section")[
    #step("Step", "Check")
    #step("Step", "Check")
    #step("Step", "Check")
    #step("Step", "Check")
  ]
]
```

And you can use `#colbreak()` to add a column break.
