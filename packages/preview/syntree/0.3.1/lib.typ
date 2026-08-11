#let tree(tag, ..children, child-spacing: 1em, layer-spacing: 2.3em, roof: false, stroke: 0.75pt) = {
  let tag-text = text(tag)
  context {
    let child-widths = children.pos().map(c => measure(c).width)
    let child-xs = ()
    let acc = 0pt
    for width in child-widths {
      child-xs.push(acc)
      acc += width + child-spacing
    }

    let children-width = acc - child-spacing

    let child-nodes = children.pos().enumerate().map(t => {
      let (i, child) = t
      let child-width = measure(child).width
      let x0 = child-xs.at(i) + child-width / 2
      let hi = -layer-spacing + 0.3em
      let lo = -0.3em
      if roof {
        place(polygon(stroke: stroke, (0pt + child-width/2, hi), (children-width - x0 + child-width/2, lo), (-x0+ child-width/2, lo)))
      } else {
        place(line(stroke: stroke, start: (0pt+ child-width/2, lo), end: (children-width / 2 - x0+ child-width/2, hi)))
      }
      child
    })

    let child-stack = stack(dir: ltr, spacing: child-spacing, ..child-nodes)
    let layer-stack = stack(dir: ttb, spacing: layer-spacing, tag-text, child-stack)
    block(align(center, layer-stack))
  }
}

#let syntree(
  /// Text styles to apply to terminal nodes of the syntax tree (nodes with no children).
  terminal: (:),
  /// Text styles to apply to nonterminal nodes of the syntax tree (nodes with children).
  nonterminal: (:),
  /// How much horizontal space to have between nodes.
  child-spacing: 1em,
  /// How much vertical space to have between nodes.
  layer-spacing: 2.3em,
it) = {
  let style-text(styles, x) = [#set text(..styles); #x]
  let tree = tree.with(child-spacing: child-spacing, layer-spacing: layer-spacing)
  let whitespace = ([], [ ], parbreak())

  // Don't error out on an empty body.
  if it in whitespace {
    return none
  }
  assert(it.has("children"), message: "must be provided a tree")

  /// The stack is a stack of nodes of form (head: content, children: content, roof: bool).
  /// The first node on the stack doesn't need a tag or a roof, though.
  let stack = ((children: ()),)
  for token in it.children.filter(x => x not in whitespace) {
    if token.at("text", default: false) == "[" {
      // If the current token is `[`, we're entering a new subtree.
      // Push a new, empty node to the stack.
      stack.push((head: none, children: (), roof: false))
    } else if token.at("text", default: false) == "]" {
      // If the current token is `]`, we're exiting a subtree.
      // Pop the last node from the stack, and render it into a child tree.
      assert(stack.len() > 0, message: "extra closing `]`")
      let (head, children, roof) = stack.pop()
      // Any node head is a nonterminal, so we style them here.
      let subtree = tree(style-text(nonterminal, head), ..children, roof: roof)
      stack.last().children.push(subtree)
    } else {
      // Otherwise, we need to check if we're at the head of the current subtree.
      // If so, we'll need to check for a roof marker.
      let (head, children, roof) = stack.last()
      if token.has("text") and head == none and children == () and roof == false {
        // Check if the tag starts with the roof marker.
        let splits = token.text.split(" ")
        let (tag, body) = (splits.first(), splits.slice(1).join(" "))
        if tag.starts-with("^") {
          stack.last().roof = true
          // Guard against setting the tag to an empty string.
          // This can occur when there could be complex content following, ex. [^$N P$ a wug].
          if tag == "^" {
            tag = none
          } else {
            tag = tag.slice(1)
          }
        }
        stack.last().head = tag
        if body != none {
          stack.last().children = (style-text(terminal, body),)
        }
      } else if not token.has("text") and head == none and children == () {
        // If the current token isn't plain text, so it can't be a roof marker.
        // Check if the previous token was `[` or `^`, i.e., this is the tag of the current subtree
        stack.last().head = token
      } else {
        // Otherwise, this is a child of the current subtree
        stack.last().children.push(style-text(terminal, token))
      }
    }
  }
  assert(stack.len() == 1, message: "extra opening `[`")
  // Render all trees in a syntree block.
  for root in stack.last().children {
    root
  }
}

#let listtree(
  /// Text styles to apply to terminal nodes of the syntax tree (nodes with no children).
  terminal: (:),
  /// Text styles to apply to nonterminal nodes of the syntax tree (nodes with children).
  nonterminal: (:),
  /// How much horizontal space to have between nodes.
  child-spacing: 1em,
  /// How much vertical space to have between nodes.
  layer-spacing: 2.3em,
it) = {
  let tree = tree.with(child-spacing: child-spacing, layer-spacing: layer-spacing)
  let whitespace = ([], [ ], parbreak())
  let is-list-item(item) = type(item) == std.content and item.func() == std.list.item

  // Providing a default lets us support calls like `#listtree[- S]`.
  // Not that this is common, exactly...
  let roots = it.at("children", default: (content,)).filter(x => x not in whitespace)

  // Splits a list into two sublists, where the first contains up to (but not including)
  // the first element that returns `false` when `pred` is called, and the second is the remainder.
  let splitf(lst, pred) = {
    let (first, rest) = ((), ())
    let flag = false
    for item in lst {
      if not flag and pred(item) {
        flag = true
      }
      if not flag {
        first.push(item)
      } else {
        rest.push(item)
      }
    }
    (first, rest)
  }

  let build-tree(item) = {
    // Check whether the current item is a list item block.
    if is-list-item(item) {
      let head = item.body
      let children = ()

      // Typst's item blocks are a little irregular at an AST level.
      // So we have to check for children explictly.
      if item.body.has("children") and item.body.children.len() > 1 {
        // All children up to the first std.list.item block should be considered part of the head.
        let (first, rest) = splitf(item.body.children, is-list-item)
        head = first.join()
        children = rest.filter(x => x not in whitespace)
      }

      // Check for a roof ^ at the start of a line.
      let roof = false
      if head.has("text") and head.text.starts-with("^") {
        // A head can be a single content block, in which case we must inspect it directly.
        roof = true
        head = head.text.slice(1)
      } else if head.has("children") and head.children.len() > 1 {
        // A head can also be a sequence of content blocks, in which case we must inspect the first node.
        let first = head.children.first()
        if first.has("text") and first.text.starts-with("^") {
          roof = true
          head = first.text.slice(1) + head.children.slice(1).join()
        }
      }

      // We apply the terminal (no children) and nonterminal (has children) styling to heads here.
      if children.len() == 0 {
        head = [#set text(..terminal); #head]
      } else {
        head = [#set text(..nonterminal); #head]
      }
      tree(head, ..children.map(build-tree), roof: roof)
    } else {
      // Otherwise, return the content directly with no changes.
      // This allows for composition with `#tree` and `#syntree`.
      [#set text(..terminal); #item]
    }
  }

  // Render all trees in a listtree block.
  for root in roots {
    build-tree(root)
  }
}
