
// This is code from Wordometer 0.1.4 at https://typst.app/universe/package/wordometer.
// (c) Joseph Wilson (Jollywatt) 2014, under an MIT License.


/// Simplify an array of content by concatenating adjacent text elements.
///
/// Doesn't preserve content exactly; `smartquote`s are replaced with `'` or
/// `"`. This is used on `sequence` elements because it improves word counts for
/// cases like "Digby's", which should count as one word.
///
/// For example, the content #rect[Qu'est-ce *que* c'est !?] is structured as:
///
/// #[Qu'est-ce *que* c'est !?].children
///
/// This function simplifies this to:
///
/// #wordometer.concat-adjacent-text([Qu'est-ce *que* c'est !?].children)
///
/// - children (array): Array of content to simplify.
#let concat-adjacent-text(children) = {
  if children.len() == 0 { return () }
  let squashed = (children.at(0),)

  let as-text(el) = {
    let fn = repr(el.func())
    if fn == "text" { el.text }
    else if fn == "space" { " " }
    else if fn in "linebreak" { "\n" }
    else if fn in "parbreak" { "\n\n" }
    else if fn in "pagebreak" { "\n\n\n\n" }
    else if fn == "smartquote" {
      if el.double { "\"" } else { "'" }
    }
  }

  let last-text = as-text(squashed.at(-1))
  for child in children.slice(1) {

    // don't squash labelled sequences. the label should be
    // preserved because it might be used to exclude elements
    let has-label = child.at("label", default: none) != none
    if has-label {
      squashed.push(child)
      last-text = none
      continue
    }

    let this-text = as-text(child)
    let merge-with-last = last-text != none and this-text != none

    if merge-with-last {
      // squash into last element
      last-text = last-text + this-text
      squashed.at(-1) = text(last-text)
    } else {
      // add new element
      last-text = this-text
      squashed.push(child)
    }
  }

  squashed
}

#let IGNORED_ELEMENTS = (
  "bibliography",
  "cite",
  "display",
  "equation",
  "h",
  "hide",
  "image",
  "line",
  "linebreak",
  "locate",
  "metadata",
  "pagebreak",
  "parbreak",
  "path",
  "polygon",
  "ref",
  "repeat",
  "smartquote",
  "space",
  "style",
  "update",
  "v",
)

#let parse-basic-where-selector(selector) = {
  let match = repr(selector).match(regex("^([\w]+)\.where(.*)$"))
  if match == none {
    panic("Only `element.where(key: value, ..)` selectors are supported.")
  }
  let (element-fn, fields) = match.captures
  (element-fn: element-fn, fields: eval(fields))
}

#let interpret-exclude-patterns(exclude) = {
  exclude.map(element-fn => {
    if type(element-fn) in (str, label, dictionary) { element-fn }
    else if type(element-fn) == function { repr(element-fn) }
    else if type(element-fn) == selector {
      parse-basic-where-selector(element-fn)
    } else {
      panic("Exclude patterns must be element functions, strings, or labels; got:", element-fn)
    }
  })
}


/// Traverse a content tree and apply a function to textual leaf nodes.
///
/// Descends into elements until reaching a textual element (`text` or `raw`)
/// and calls `f` on the contained text, returning a (nested) array of all the
/// return values.
///
/// - f (function): Unary function to pass text to.
/// - content (content): Content element to traverse.
/// - exclude (array): Content to skip while traversing the tree, specified by:
///   - name, e.g., `"heading"`
///   - function, e.g., `heading`
///   - selector, e.g., `heading.where(level: 1)` (only basic `where` selectors
///     are supported)
///   - label, e.g., `<no-wc>`
///  Default value includes equations and elements without child content or
///  text:
///  #wordometer.IGNORED_ELEMENTS.sorted().map(repr).map(raw).join([, ],
///  last: [, and ]).
///
///  To exclude figures, but include figure captions, pass the name
///  `"figure-body"` (which is not a real element). To include figure bodies,
///  but exclude their captions, pass the name `"caption"`.
#let map-tree(f, content, exclude: IGNORED_ELEMENTS) = {
  if content == none { return none }
  if type(content) == str { return content }

  let exclude = interpret-exclude-patterns(exclude)
  let map-subtree = map-tree.with(f, exclude: exclude)

  let fn = repr(content.func())
  let fields = content.fields().keys()

  let exclude-selectors = exclude.filter(e => type(e) == dictionary and "element-fn" in e)
  for (element-fn, fields) in exclude-selectors {
    // panic(exclude-selectors, content)
    if fn == element-fn {
      // If all fields in the selector match the element, exclude it
      if not fields.pairs().any(((key, value)) => content.at(key, default: value) != value) {
        return none
      }
    }
  }

  if fn in exclude {
    none

  // check if element has a label that is excluded
  } else if content.at("label", default: none) in exclude {
    none

  } else if fn in ("text", "raw") {
    f(content.text)

  } else if "children" in fields {
    let children = content.children

    if fn == "sequence" {
      // don't do this for, e.g., grid or stack elements
      children = concat-adjacent-text(children)
    }

    children
      .map(map-subtree)
      .filter(x => x != none)

  } else if fn == "figure" {
    (
      if "figure-body" not in exclude { map-subtree(content.body) },
      if "caption" in content.fields() { map-subtree(content.caption) },
    )
      .filter(x => x != none)

  } else if fn == "styled" {
    map-subtree(content.child)

  } else if "body" in fields {
    map-subtree(content.body)

  } else {
    none

  }

}

#let content-to-string(cnt) = {
  if cnt == none {
    none
  } else if cnt == "" {
    ""
  } else {
    let result = map-tree(x => x, cnt)
    
    if result == none {
      none
    } else if type(result) == str {
      return result
    } else {
      // [#type(result)]
      // [#type(result): #result]
      return result.flatten().join()
    }
  }
}


// English punctuation: ".,?!;:"