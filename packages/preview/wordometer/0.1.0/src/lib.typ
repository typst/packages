#let dictionary-sum(a, b) = {
  let c = (:)
  for k in a.keys() + b.keys() {
    c.insert(k, a.at(k, default: 0) + b.at(k, default: 0))
  }
  c
}

/// Get a basic word count from a string. 
///
/// Returns a dictionary with keys:
/// - `characters`: Number of non-whitespace characters.
/// - `words`: Number of words, defined by `regex("\b[\w'’]+\b")`.
/// - `sentences`: Number of sentences, defined by `regex("\w+\s*[.?!]")`.
///
/// - string (string): 
/// -> dictionary
#let string-word-count(string) = (
  characters: string.replace(regex("\s+"), "").len(),
  words: string.matches(regex("\b[\w'’.,\-]+\b")).len(),
  sentences: string.matches(regex("\w+\s*[.?!]")).len(),
)

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
    if last-text == none {
        squashed.push(child)
        last-text = as-text(child)

    } else {
      let this-text = as-text(child)
      if this-text == none {
        squashed.push(child)
        last-text = as-text(child)
      } else {
        last-text = last-text + this-text
        squashed.at(-1) = text(last-text)
      }
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
///   - selector, e.g., `heading.where(level: 1)` (only basic `where`
///    selectors are supported)
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
  let exclude = interpret-exclude-patterns(exclude)
  let map-subtree = map-tree.with(f, exclude: exclude)
  
  let fn = repr(content.func())
  let fields = content.fields().keys()

  let exclude-selectors = exclude.filter(e => type(e) == dictionary and "element-fn" in e)
  for (element-fn, fields) in exclude-selectors {
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

/// Extract plain text from content
///
/// This is a quick-and-dirty conversion which does not preserve styling or
/// layout and which may introduces superfluous spaces.
/// - content (content): Content to extract plain text from.
/// - ..options ( ): Additional named arguments:
///   - `exclude`: Content to exclude (see `map-tree()`). Can be an array of
///    element functions, element function names, or labels.
#let extract-text(content, ..options) = {
  (map-tree(x => x, content, ..options),).flatten().join(" ")
}

/// Get word count statistics of a content element.
///
/// Returns a results dictionary, not the content passed to it. (See
/// `string-word-count()`).
///
/// - content (content):
/// -> dictionary
/// - exclude (array): Content to exclude from word count (see `map-tree()`).
///  Can be an array of element functions, element function names, or labels.
/// - counter (fn): A function that accepts a string and returns a dictionary of
///  counts.
///
///  For example, to count vowels, you might do:
///
///  ```typ
///  #word-count-of([ABCDEFG], counter: s => (
///      vowels: lower(s).matches(regex("[aeiou]")).len(),
///  ))
///  ```
/// - method (string): The algorithm to use. Can be:
///  - `"stringify"`: Convert the content into one big string, then perform the
///   word count.
///  - `"bubble"`: Traverse the content tree performing word counts at each
///   textual leaf node, then "bubble" the results back up (i.e., sum them).
///  Performance and results may vary by method!
#let word-count-of(
  content,
  exclude: (),
  counter: string-word-count,
  method: "stringify",
) = {
  let exclude = IGNORED_ELEMENTS + (exclude,).flatten()

  if method == "bubble" {
    (map-tree(counter, content, exclude: exclude),)
      .filter(x => x != none)
      .flatten()
      .fold(counter(""), dictionary-sum)

  } else if method == "stringify" {
    counter(extract-text(content, exclude: exclude))

  } else {
    panic("Unknown choice", method)
  }
}

/// Simultaneously take a word count of some content and insert it into that
/// content.
/// 
/// It works by first passing in some dummy results to `fn`, performing a word
/// count on the content returned, and finally returning the result of passing
/// the word count retults to `fn`. This happens once --- it doesn't keep
/// looping until convergence or anything!
///
/// For example:
/// ```typst
/// #word-count-callback(stats => [There are #stats.words words])
/// ```
///
/// - fn (function): A function accepting a dictionary and returning content to
///  perform the word count on.
/// - ..options ( ): Additional named arguments:
///   - `exclude`: Content to exclude from word count (see `map-tree()`). Can be
///    an array of element functions, element function names, or labels.
///   - `method`: Content traversal method to use (see `word-count-of()`).
/// -> content
#let word-count-callback(fn, ..options) = {
  let preview-content = [#fn(string-word-count(""))]
  let stats = word-count-of(preview-content, ..options)
  fn(stats)
}

#let total-words = locate(loc => state("total-words").final(loc))
#let total-characters = locate(loc => state("total-characters").final(loc))

/// Get word count statistics of the given content and store the results in
/// global state. Should only be used once in the document.
///
/// #set raw(lang: "typ")
///
/// The results are accessible anywhere in the document with `#total-words` and
/// `#total-characters`, which are shortcuts for the final values of states of
/// the same name (e.g., `#locate(loc => state("total-words").final(loc))`)
///
/// - content (content):
///   Content to word count.
/// - ..options ( ): Additional named arguments:
///   - `exclude`: Content to exclude from word count (see `map-tree()`). Can be
///    an array of element functions, element function names, or labels.
///   - `method`: Content traversal method to use (see `word-count-of()`).
/// -> content
#let word-count-global(content, ..options) = {
  let stats = word-count-of(content, ..options)
  state("total-words").update(stats.words)
  state("total-characters").update(stats.characters)
  content
}

/// Perform a word count on content.
/// 
/// Master function which accepts content (calling `word-count-global()`) or a
/// callback function (calling `word-count-callback()`).
/// 
/// - arg (content, fn):
///   Can be:
///   #set raw(lang: "typ")
///   - `content`: A word count is performed for the content and the results are
///    accessible through `#total-words` and `#total-characters`. This uses a
///    global state, so should only be used once in a document (e.g., via a
///    document show rule: `#show: word-count`).
///   - `function`: A callback function accepting a dictionary of word count
///    results and returning content to be word counted. For example:
///    ```typ
///    #word-count(total => [This sentence contains #total.characters letters.])
///    ```
/// - ..options ( ): Additional named arguments:
///   - `exclude`: Content to exclude from word count (see `map-tree()`). Can be
///    an array of element functions, element function names, or labels.
///   - `method`: Content traversal method to use (see `word-count-of()`).
///
/// -> dictionary
#let word-count(arg, ..options) = {
  if type(arg) == function {
    word-count-callback(arg, ..options)
  } else {
    word-count-global(arg, ..options)
  }
}
