# ditto

Reusable components for guided worksheets in Typst. Built for my [math-work](https://github.com/ZaneH/math-work) repo.

```typ
#import "@preview/ditto:0.1.0": *
```

## Components

| Component | Purpose |
|---|---|
| `#kernelbox(title, body)` | Facts worth memorising — everything else is derived from these |
| `#stepbox(title, body)` | Worked derivation step. Use `[]` not `""` if the title contains math |
| `#appbox(title, body)` | Application or "in practice" example |
| `#definition(term, body)` | Vocabulary introduction |
| `#problem(hint, body)` | Auto-numbered practice problem |
| `#answer[...]` | Answer to the previously defined problem (optional) |
| `#workspace(lines, title)` | Ruled space for working by hand. Defaults: 5 lines, "Try it yourself:" |
| `#blanks(width)` | Inline fill-in-the-blank, e.g. `#blanks(2cm)` |
| `#nobreak[...]` | Ensure related content stays together |
| `#render-answers()` | Render the accumulated answers |

## Sample

- [Sample PDF](./examples/sample.pdf)

See [sample.typ](./examples/sample.typ) for a full working example. The sample file includes optional style rules
defined at the top. To compile the sample, run this in the package root:

```sh
$ typst compile --root . examples/sample.typ 
```

## Agentic Workflow

See [AGENTS.md](./AGENTS.md) for my system prompt and customize it to your liking. In the initial prompt, it is useful
to include the contents of [examples/sample.typ](./examples/sample.typ). I'm using Claude Projects to organize
everything.
