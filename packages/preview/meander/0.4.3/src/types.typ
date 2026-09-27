/// Option marker
/// - `pre`: options that come before the layout
/// - `post`: options that come after the layout
#let opt = {
  let pre() = {}
  let post() = {}
  let dyn() = {}
  (pre: pre, dyn: dyn, post: post)
}

/// Flowing content
/// - `content`: text
/// - `colbreak`: break text to the next container
/// - `colfill`: break text to the next container and fill the current one
#let flow = {
  let content() = {}
  let colbreak() = {}
  let colfill() = {}
  (content: content, colbreak: colbreak, colfill: colfill)
}

/// Layout elements
/// - `placed`: obstacles
/// - `container`: containers
/// - `pagebreak`: break layout to next page
#let elt = {
  let placed() = {}
  let container() = {}
  let pagebreak() = {}
  let callback() = {}
  (placed: placed, container: container, pagebreak: pagebreak, callback: callback)
}

/// Standalone type of queries
#let query() = {}
