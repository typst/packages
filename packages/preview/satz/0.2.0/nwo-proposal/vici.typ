#import "../lib.typ": nwo-proposal, nwo-text, nwo-key-output

#show: nwo-proposal.with(
  scheme: "vici",
  domain: sys.inputs.at("domain", default: "science"),
  stage: "pre",
  year: 2026,
)

#include "pre-body.typ"
