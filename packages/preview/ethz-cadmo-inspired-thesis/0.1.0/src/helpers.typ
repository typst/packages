// Create a "TODO" box for work-in-progress notes. The `inline` option controls whether the box is inline with text or a block.
#import "colours.typ": *

#let todo(body, inline: false) = if inline [
  #box(fill: custom.light-gray, outset: (x: 1pt, y: 2pt))[
    *TODO:* #body
  ] <TODO>
] else [
  #block(fill: custom.light-gray, inset: 0.6em, radius: 2pt, width: 100%)[
    *TODO:* #body
  ] <TODO>
]

// Inserts sym.zws (zero-width space) after `-`, `_`, `:` so long identifiers can break across lines.
#let breakable-id(n) = (
  n.replace("-", "-" + str(sym.zws)).replace("_", "_" + str(sym.zws)).replace(":", ":" + str(sym.zws))
)

/// Takes a GitHub or GitLab Pull Requests and creates a compact link for displaying it.
#let display-pr(url) = {
  // Regex to match GitHub PRs
  // Captures: 1: owner/repo, 2: PR number
  let github-pattern = regex("github\.com/([^/]+/[^/]+)/pull/(\d+)")

  // Regex to match GitLab MRs
  // Captures: 1: owner/repo (can include nested subgroups), 2: MR number
  let gitlab-pattern = regex("gitlab\.com/([^/]+(?:/[^/]+)+)/-/(?:merge_requests|pulls)/(\d+)")

  let gh-match = url.match(github-pattern)
  let gl-match = url.match(gitlab-pattern)

  if gh-match != none {
    let repo = gh-match.captures.at(0)
    let pr-num = gh-match.captures.at(1)
    link(url, "github:" + repo + "#" + pr-num)
  } else if gl-match != none {
    let repo = gl-match.captures.at(0)
    let mr-num = gl-match.captures.at(1)
    link(url, "gitlab:" + repo + "!" + mr-num)
  } else {
    // Fallback: If it doesn't match either, just render the raw link
    link(url)
  }
}

// Link to a labeled heading, rendered as "Supplement N: Heading text"
// (e.g. "Section 3.2: LLVM"). Inspired by LaTeX's `\nameref` from the
// hyperref package, extended with the heading's number and supplement.
// Falls back to just the body for unnumbered headings.
#let nameref(label) = context {
  let el = query(label).first()
  if el.numbering == none {
    link(label, el.body)
  } else {
    let num = numbering(el.numbering, ..counter(heading).at(el.location()))
    link(label, [#el.supplement #num: #el.body])
  }
}
