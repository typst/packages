# Typst package for the visualization of abstract automata

This package can be used to visualize abstract automata in [Typst](https://typst.app/docs/) using [fletcher](https://typst.app/universe/package/fletcher). It relies on the json format that [FLACI](https://flaci.com/autoedit) ([FLACI on github](https://github.com/gitmh/FLACI/tree/main)) saves to. This allows you to intuitively design your automata with FLACI and then import them into Typst without relying on raster graphics.

## Usage

- Create an automaton via [FLACI](https://flaci.com/autoedit) or one of their local clients and save it locally to json.
- Sadly, the exported json starts with a weird character that prevents us from directly importing it. You can remove that char for example with the following command line:
```bash
cat Automaton_MY_AUTOMAT.json | jq . > MY_AUTOMAT.json
```
- Now import this package into your typst file and use it:
```typst
#import "@preview/flautomat:0.1.0": flautomat

...

#flautomat(json("MY_AUTOMAT.json"), scaling-factor: 1)
```

## Supported Features

The following types of automata are supported:
- (non-) deterministic finite automaton
- Mealy-Machine
- Moore-Machine
- deterministic turing machine

For these Types, the following features are supported:
- start-, final and normal states in specific positions and with relative sizes
- transitions and where the appear if they go back to their origin state
- labels on states and transitions, potentially multiple ones on the latter
- input and output
- global scaling by a `scale_factor`

The following things are not supported:
- custom styling - for this, copy the code of this package and adjust it to your liking
- precise bending of transitions - we only check if a transition is curved or not
- colorization of states depending on whether the corresponding transitions are total or not
- exact replica of FLACI's style and layout
- avoiding overlaps of labels

As you can see, this package is rather narrow in scope and focuses just on being easy to use in combination with FLACI.
If you want something more powerful or don't want to use FLACI, check out [finite](https://typst.app/universe/package/finite), another typst package for rendering automata.
