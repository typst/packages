#import "@preview/satz:0.2.0": nwo-proposal, nwo-text, nwo-key-output

#show: nwo-proposal.with(
  scheme: "veni",
  domain: sys.inputs.at("domain", default: "science"),
  stage: "pre",
  year: 2026,
)

#include "pre-body.typ"
