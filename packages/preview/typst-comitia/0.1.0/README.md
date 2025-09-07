# comitia

Use different voting mechanisms in your document. Powered by Rust WASM.

You can analyze a vote turnout by calling `vote(ballots, method, ties_method)` which returns the raw JSON results
of your ballots or `vote-report(ballots, method, ties_method)` for a more detailled report on the vote.

## Example

First you must import the library and define an *input* for our vote method. This input must be a list
with each element of the list containing the ranked choice(s) for an individual:

```typst
#import "@preview/comitia:0.1.0": *
#let input = (
    ("Alice", "Charlie"),
    ("Bob", "Charlie", "Alice"),
    ("Charlie", "Alice", "Bob"),
    ("Alice", "Charlie", "Bob"),
    ("Bob", "Alice", "Charlie"),
    ("Tim",)
)
```

In our example the first person prefered Alice over Charlie and the last person
only voted for Tim. Please note that an Element that contains only one element
must end with a comma, as shown in `#("Tim",)`.

Then you can either analyze the raw output using the function:

```typst
#vote(input, method: "STV", ties_method: "Random")
```

Or you can have a more sophisticated report on each step performed:

```typst
#vote-report(input, method: "STV", ties_method: "Random")
```

## Implemented

### Methods

- Plurality
- STV (Single Transferable Vote - for one candidate: Instant-Runoff Voting)

### Tie Breakers

- All
- Random
- Count

### Minimum Number of Candidates

Currently only single (or tie bound multiple) candidates are returned. Multiple voting rounds for more than one candidate are to be implemented in the future.
