
/// recursion helper for to-string
#let to-string-rec(it) = {
  if it == none {
    "none"
  } else if type(it) == str {
    it
  } else if type(it) != content {
    str(it)
  } else if it.has("text") {
    it.text
  } else if it.has("children") {
    it.children.map(to-string-rec).join()
  } else if it.has("body") {
    to-string-rec(it.body)
  } else if it == [ ] {
    " "
  }
}

/// Converts anything (inculding content) into string.
///
/// - it (any): content to convert to string
/// -> str, none
#let to-string(it) = {
  if it == none {
    return none
  }
  let out = to-string-rec(it)

  // max recursion depth can be exceeded, just iterate
  // if not yet string.
  while type(out) != str {
    out = to-string-rec(out)
  }

  out
}

///
///
/// - id (str): unique ID
/// - human-readable (str):
/// - level (int):
/// - location (location): Location of element
/// - label (str, none): Label name, if any.
/// ->
#let new-heading-node(id, human-readable, level, location, label) = {
  (
    type: "heading",
    id: id,
    human-readable: human-readable,
    level: level,
    pos: location.position(),
    label: label
  )
}

///
///
/// - id (str): unique ID
/// - human-readable (str):
/// - kind (str, none):
/// - supplement (str, none):
/// - caption (str, none):
/// - location (location): Location of element
/// - label (str, none): Label name, if any.
/// ->
#let new-figure-node(id, human-readable, kind, supplement, caption, location, label) = {
  (
    type: "figure",
    id: id,
    human-readable: human-readable,
    kind: kind,
    supplement: supplement,
    caption: caption,
    pos: location.position(),
    label: label
  )
}

///
///
/// - id (str):
/// - human-readable (str):
/// - location (location): Location of element
/// - label (str, none): Label name, if any.
/// ->
#let new-question-node(id, human-readable, location, label) = {
  (
    type: "question",
    id: id,
    human-readable: human-readable,
    pos: location.position(),
    label: label
  )
}

///
/// - id (str):
/// - location (location): Location of element
/// - label (str, none): Label name, if any.
/// ->
#let new-other-node(id, location, label) = {
  (
    type: "other",
    id: id,
    pos: location.position(),
    label: label
  )
}

/// Apply this show rule for adding <graph-gen-thm-end> labels to mark
/// the end of figure nodes. This is required to support nested figures.
#let figure-end-rule(it, thm-kinds: ("thm-group",)) = {

  show figure: it => if (it.caption != none or it.has("label")) and it.kind in (table, raw, image) + thm-kinds {
    [
      #it

      #metadata(none) <graph-gen-thm-end>
    ]
  } else {
    it
  }

  it
}


/// Add this as a show rule to main typst document to generate content graph data.
///
/// Data is queryable using the `<graph-gen-nodes>` and `<graph-gen-edges>` metadata.
///
/// E.g.: add this to top of document
///
/// ```typst
/// show: graph-gen.with(thm-kind: ..., qn-kind: ...)
/// ```
///
/// then query in CLI with
///
/// ```sh
/// typst query path/to/doc.typ "<graph-gen-nodes>" --field value --one
/// typst query path/to/doc.typ "<graph-gen-edges>" --field value --one
/// ```
///
/// - body (content): Content of document to generate graph for.
/// - thm-kind (str, array): `kind` attribute for figures containing theorem-type content. If multiple `kind`s, specify an array of strings.
/// - qn-kind (str): `kind` attribute for figure of questions using assignment template. NOTE: Only labelled questions or questions with `figure.caption` will appear as nodes.
/// - qn-title-label (label, none): Label for querying question title, if any. If `none` or no label found, question nodes will be labelled in the graph using `figure.caption`, if any, or `label`.
/// - debug (bool): If `true`, prints graph debug info at the end of the document.
/// -> content
#let graph-gen-rules(body, thm-kinds: "thm-group", qn-kind: "question", qn-title-label: <question-title>, debug: false) = {

  /*
    STRATEGY: export a string which shows all the directed edges of a content summary graph.

    "theorem" refers to any figure with kind: thm-kind, e.g., definition, proposition, lemma, ...

    "figure" includes questions, theorems, and other figures.

    EDGES: (different classes of edges)
    - content: From (sub)header to subheader
    - content: From (sub)header to figure
    - content: From figure to figure (nested)
    - ref: From reference target to reference origin.

    IDENTIFYING ELEMENTS:

    - Theorems: figure.where(kind: thm-kind)
    - Questions: figure.where(kind: qn-kind)
    - Figures: figure
    - Headings: heading.where(level: ___)

    Get target label of ref (use str(...) to convert to str):
    - query(ref).last().target

    Check if heading has label:
    - query(heading).first().has("label")

    Get label of heading/content:
    - query(heading).last().label

    Get content attached to label:
    - query(<label>)

    Get content being referenced by ref:
    - query(query(ref).last().target)
  */

  if type(thm-kinds) == str {
    thm-kinds = (thm-kinds,)
  }

  // NOTE: This selector selects all figures, filter out the figure kind
  // later.
  let nodes-selector = figure.where().or(heading)
      .or(<graph-gen-thm-end>)
      .or(ref)

  show: figure-end-rule.with(thm-kinds: thm-kinds)

  [
    #body

    // #pagebreak()

    // *GRAPH GEN:*

    #context {
      let que = query(nodes-selector)
      /// Current heading stack
      /// index i = id of heading.where(level: i+1)
      let curr-heading-ids = ()
      let curr-heading-id = ""

      /// Map of heading labels to heading IDs for headings that were given labels.
      ///
      /// Note: heading IDs always include the full curr-heading-ids stack whether or not a unique label was
      /// given.
      let heading-label-id-map = (:)

      /// Stack of theorem ids
      ///
      /// Every new theorem id is pushed on to this stack.
      ///
      /// Pop once when encountered <graph-gen-thm-end>
      let thms-stack = ()

      /// List of unique node ids.
      let node-ids = ()
      let nodes = ()
      /// List of (from-id, to-id, is-ref) tuples
      /// `is-ref` is true if the edge is created by an explicit @reference. Otherwise false for implicit edges created from being contained within a heading/figure.
      let edges = ()

      for element in que {
        let loc = element.location()
        if element.func() == heading {
          // Heading

          let lab = none
          let id = if element.has("label") {
            lab = to-string(element.label)
            lab
          } else {
            to-string(element)
          }
          if element.level > curr-heading-ids.len() {
            curr-heading-ids += (none,) * (element.level - curr-heading-ids.len() - 1) + (id,)
          } else {
            curr-heading-ids = curr-heading-ids.slice(0, element.level - 1) + (id,)
          }
          curr-heading-id = curr-heading-ids.join(".")

          let parent-heading-idx = curr-heading-ids.len() - 2

          while parent-heading-idx >= 0 and curr-heading-ids.at(parent-heading-idx) == none {
            parent-heading-idx -= 1
          }

          if curr-heading-id in node-ids {
            panic(curr-heading-id + " is not unique ID!")
          }
          node-ids.push(curr-heading-id)
          nodes.push(new-heading-node(curr-heading-id, to-string(element), element.level, loc, lab))

          if element.has("label") {
            heading-label-id-map.insert(id, curr-heading-id)
          }

          if parent-heading-idx >= 0 {
            let parent-heading-id = curr-heading-ids.slice(0, parent-heading-idx + 1).join(".")
            edges.push((parent-heading-id, curr-heading-id, false))
          }
        } else if element.func() == figure {
          let kind = element.kind

          if kind == qn-kind {
            // Questions

            // Do not make a new node unless the question is labelled.

            if element.has("label") or element.caption != none {
              let qn-title-query = query(selector(qn-title-label).after(element.location()))

              let qn-title = if qn-title-query.len() > 0 {
                qn-title-query.first()
              } else if element.caption != none {
                element.caption
              } else {
                element.label
              }
              qn-title = to-string(qn-title)

              let id = to-string(element.label)

              if id in node-ids {
                panic(id + " is not unique ID!")
              }
              node-ids.push(id)

              nodes.push(new-question-node(id, curr-heading-id + "." + qn-title, loc, to-string(element.label)))

              edges.push((curr-heading-id, id, false))
            }
          } else if kind in (table, raw, image) + thm-kinds {
            // Theorems (definition/lemma/etc...), or any other figure.

            let supplement = to-string(element.supplement)
            let caption = to-string(element.caption)

            // [Sup: #supplement, cap: #caption. #h(1em)]

            let human-readable = if caption != none {
              caption
            } else if supplement != none {
              supplement
            } else {
              element.kind
            }

            let lab = none
            let id = if element.has("label") {
              lab = to-string(element.label)
              lab
            } else {
              curr-heading-id + "." + human-readable
            }

            if caption != none or element.has("label") {
              // Exclude unlabelled thms/proofs without name/caption

              if id in node-ids {
                panic(id + " is not unique ID! Kind: " + kind)
              }
              node-ids.push(id)

              nodes.push(new-figure-node(
                id, human-readable, kind, supplement, caption, loc, lab
              ))

              let parent-id = if thms-stack != () {
                thms-stack.last()
              } else {
                curr-heading-id
              }

              edges.push((parent-id, id, false))

              thms-stack.push(id)
            } else {
              // [Excluded element: #repr(element)]
            }
          }
        } else if element.func() == ref {
          // Reference

          // Note: for headings with labels, we have to convert the heading label into
          // heading ID after all IDs of headings with labels are populated
          let ref-target-id = to-string(element.target)

          let ref-from-id = if thms-stack != () {
            thms-stack.last()
          } else {
            curr-heading-id
          }

          edges.push((ref-from-id, ref-target-id, true))
        } else if element.has("label") and element.label == <graph-gen-thm-end> {
          // Pop end of
          let _ = thms-stack.pop()
        }
      }

      let new-edges = ()

      for e in edges { // (from, to)

        if e.at(1) in heading-label-id-map {
          // Labelled headings have different internal node id, but edges referencing heading labels
          // need to reference the internal heading id instead.
          // [
          //   Replaced heading label #e.at(1) with ID #heading-label-id-map.at(e.at(1))
          //   #linebreak()
          // ]
          e.at(1) = heading-label-id-map.at(e.at(1))
        }

        if e.at(1) not in node-ids {
          node-ids.push(e.at(1))
          let loc = locate(label(e.at(1)))
          nodes.push(new-other-node(e.at(1), loc, e.at(1)))
        }

        new-edges.push(e)
      }

      edges = new-edges

      // Obtain graph as JSON with CLI
      // `typst query document.typ "<graph-gen-nodes/edges>" --field value --one`
      [
        #metadata(nodes) <graph-gen-nodes>
        #metadata(edges) <graph-gen-edges>
      ]

      if not debug {
        return
      }

      [
        = GRAPH GEN DEBUG

        Leftover `thms-stack`: #thms-stack.

        If this was not an empty list, there is a mismatch: more `thm-kinds` figures than `<graph-gen-thm-end>` labels.

        == NODES:

        #nodes.filter(x => true)

        == EDGES `(from, to, is-ref)`

        #edges.filter(((from, to, is-ref)) => true)
      ]
    }
  ]
}