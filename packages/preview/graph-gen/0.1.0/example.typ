#import "@preview/graph-gen:0.1.0": *
#import "@preview/lemmify:0.1.8": default-theorems, new-theorems, thm-numbering-linear
#import "@preview/showybox:2.0.4": *

// Using lemmify which wraps theorem-type content in a figure with kind: "thm-group" as specified by
// the first param of default-theorems.

#let (
  theorem, lemma, corollary,
  remark, proposition, example, definition,
  proof, rules: thm-rules
) = default-theorems(
  "thm-group",
  lang: "en",
  thm-numbering: thm-numbering-linear)
#show: thm-rules

#let (note, rules) = new-theorems("note", ("note": text(red)[Note]))
#show: rules

#let question(body) = {
  figure(
    kind: "qn",
    supplement: "Question",

    // To name question nodes with its title, use the <question-title> label (or whatever
    // qn-title-label is set to in graph-gen-rules below).
    //
    // Context should wrap the entire title including label, otherwise question numbers will not
    // appear on node names.
    showybox(title: context [
      #[Question #counter(figure.where(kind: "qn")).display("1")]<question-title>
    ], body)
  )
}

#show: graph-gen-rules.with(
  // figure.where(kind: "thm-group") or (kind: "note") will register as theorems/definitions/etc...
  thm-kinds: ("thm-group", "note"),

  // figure.where(kind: "qn") will register as questions
  qn-kind: "qn",

  // This typst label should be used on the title of the question which determines the question
  // node's name in the graph.
  //
  // If no label is found, it uses figure.caption if any, otherwise, the question's node will be
  // named with its typst <label>.
  qn-title-label: <question-title>,

  // Turning on debug mode prints generated nodes and edges at the bottom of the document
  debug: true
)

#show selector(link).or(ref): it => underline(it)

= 1. Heading

#definition(name: [Defined in heading 1])[]

== Sub-heading A

#lemma(name: [Lemma in 1.A.])[]<lemma-1A>

== Sub-heading B

#theorem(name: [Theorem in 1.B.])[
  By @lemma-1A, this is true.
]

#question[
  This is a question, it requires knowing the definition of thing:

  #definition(name: [Thing])[
    We have to know *thing* to solve @q1.
  ]<thing>

  Since this question is labelled, this becomes a node we can refer to.
]<q1>

#question[
  This is another question. It is unlabelled and has no caption so it will not appear as a node.
]