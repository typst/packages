# typst-voting

Use different voting mechanisms in your document. Powered by Rust WASM.

You can analyze a vote turnout by calling `vote(ballots, method, ties_method)` which returns the raw JSON results
of your ballots or `vote-report(ballots, method, ties_method)` for a more detailled report on the vote.

## Implemented


### Methods

- Plurality
- SVT (Single candidate: Instant-Runoff Voting)

### Tie Breakers

- All
- Random
- Count

### Minimum Number of Candidates

Currently only single (or tie bound multiple) candidates are returned. Multiple voting rounds for more than one candidate are to be implemented in the future.
