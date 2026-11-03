/// State containing theorem environment data, as an array of `thm` dictionaries.
/// -> state
#let thm-stored = state("thm-stored", ())


/// Displays all theorem environments, can be filtered.
///
/// Every call to @thm appends a `thm` dictionary to @thm-stored.
/// A `thm` dictionary contains complete information about a theorem
/// environment; its keys are as described in @thm.fmt.
/// This lets theorems be restated, filtered, and otherwise manipulated
/// elsewhere in a document.
///
/// #example(```
/// >>> #show: thm-rules
/// >>> #set heading(numbering: "1.1")
/// #let theorem = thm.with(supplement: "Theorem")
/// #let lemma = thm.with(
///   supplement: "Lemma",
///   counter: "Theorem",
/// )
/// #let definition = thm.with(
///   supplement: "Definition",
///   body-fmt: x => x
/// )
///
/// = Heading <h1>
///
/// #theorem("Name")[#lorem(7)]
/// #proof[
///   #lorem(7)
/// ]
///
/// = New heading <h2>
///
/// #lemma[#lorem(8)]
/// #definition("Thing")[#lorem(2)]
/// #lemma[#lorem(4)]
///
/// = Display all
///
/// #thm-display()
/// ```,
/// mode: "markup",
/// scope: (thm-rules: thm-rules-1, thm-display: thm-display-1)
/// )
///
/// -> content
#let thm-display(
  /// Filtering functions. Each `f` in `filters` is a function ```typc thm => bool```.
  /// A theorem environment is displayed if it passes _any_ of the filters.
  /// #example(```
  /// >>> #show: thm-rules
  /// >>> #set heading(numbering: "1.1")
  /// = Display only theorems/proofs
  ///
  /// #thm-display(
  ///   thm => thm.supplement == "Theorem",
  ///   thm => thm.supplement == "Proof",
  /// )
  ///
  /// = Display if `name` is present
  ///
  /// #thm-display(
  ///   thm => thm.name != none
  /// )
  /// ```,
  /// mode: "markup",
  /// scope: (thm-rules: thm-rules-2, thm-display: thm-display-1)
  /// )
  /// -> function
  ..filters,
  /// Formatting function, with the same form as @thm.fmt.
  /// The default ```typc auto``` uses the originally supplied formatting function @thm.fmt.
  /// #example(```
  /// >>> #show: thm-rules
  /// >>> #set heading(numbering: "1.1")
  /// #thm-display(
  ///   thm => thm.supplement != "Proof",
  ///   final: true,
  ///   fmt: thm => {
  ///     let head = [*#thm.supplement~#thm.number*]
  ///     if thm.name != none {
  ///       head = head + [~(#thm.name)]
  ///     }
  ///     let page = link(thm.loc, [#thm.loc.position().page])
  ///     [#head~#box(width: 1fr, repeat[.])~#page\ ]
  ///   }
  /// )
  /// ```,
  /// mode: "markup",
  /// scope: (thm-rules: thm-rules-2, thm-display: (..args) => thm-display-1(..args, ..args.named(), final: false))
  /// )
  /// Setting ```typc final: true``` ensures that even if this @thm-display call is
  /// placed at the beginning of the document, all theorem environments
  /// are listed.
  /// -> function | auto
  fmt: auto,
  /// Location up to which theorem environments will be displayed.
  /// The default ```typc auto``` uses the location where @thm-display was called.
  /// #example(```
  /// >>> #show: thm-rules
  /// >>> #set heading(numbering: "1.1")
  /// = Display up to `<h2>`
  ///
  /// #thm-display(at: <h2>)
  /// ```,
  /// mode: "markup",
  /// scope: (thm-rules: thm-rules-2, thm-display: thm-display-1)
  /// )
  /// -> label | selector | location | function | auto
  at: auto,
  /// If ```typc true```, display all theorem environments up to the end of the document.
  /// Useful for creating lists of theorems in the beginning of documents,
  /// before they've been stated.
  /// Overrides @thm-display.at.
  /// -> bool
  final: false
) = {
  context {
    let thms = thm-stored.get()
    if at != auto {
      thms = thm-stored.at(at)
    }
    if final {
      thms = thm-stored.final()
    }
    if filters.pos().len() > 0 {
      // Use arg_1 or ... or arg_n style filter
      thms = thms.filter(thm =>
        filters.pos().any(x => x(thm))
      )
    }

    for thm in thms {
      if fmt == auto {
        (thm.fmt)(thm)
      } else {
        fmt(thm)
      }
    }
  }
}


/// Displays theorem environments which have been marked to be restated or
/// deferred (by setting @thm.restate, @thm.defer), can be filtered.
/// Useful for pushing content to the appendix.
///
/// #example(```
/// >>> #show: thm-rules
/// >>> #set heading(numbering: "1.1")
/// #let theorem = thm.with(supplement: "Theorem")
/// #let lemma = thm.with(
///   supplement: "Lemma",
///   counter: "Theorem",
/// )
/// #let definition = thm.with(
///   supplement: "Definition",
///   body-fmt: x => x
/// )
///
/// = Heading
///
/// #definition[#lorem(2)]
/// #lemma[#lorem(8)]
///
/// #theorem("Name", restate: true)[#lorem(7)]
/// #proof(defer: true)[
///   #lorem(7)
/// ]
///
/// #lemma[#lorem(4)]
///
/// = Appendix
///
/// #thm-restate()
/// ```,
/// mode: "markup",
/// scope: (thm-rules: thm-rules-1, thm-display: thm-display-1)
/// )
///
/// -> content
#let thm-restate(
  /// String/content keys, array of keys, or functions used to filter theorem environments.
  /// A theorem environment is displayed if it passes _any_ of the filters.
  ///
  /// If `k` in `keys` is a `string`/`content`, theorem environments containing `k` in its array of `restate-keys` will be matched.
  /// #example(```
  /// >>> #show: thm-rules
  /// >>> #set heading(numbering: "1.1")
  /// #let theorem = thm.with(supplement: "Theorem")
  /// #let lemma = thm.with(
  ///   supplement: "Lemma",
  ///   counter: "Theorem",
  /// )
  ///
  /// = Heading
  ///
  /// #theorem(restate: true)[#lorem(6)]
  /// #lemma(restate: true)[#lorem(4)]
  /// #proof(defer: true)[#lorem(7)]
  /// #lemma(restate: true)[#lorem(3)]
  ///
  /// = Restate lemmas/proofs
  /// #thm-restate("Lemma", "Proof")
  /// ```,
  /// mode: "markup",
  /// scope: (thm-rules: thm-rules-1),
  /// )
  ///
  /// If `k` in `keys` is an array of `string`s/`content`, theorem environments containing _all_ keys from `k` in its array of `restate-keys` will be matched.
  /// #example(```
  /// >>> #show: thm-rules
  /// >>> #set heading(numbering: "1.1")
  /// >>> #let theorem = thm.with(supplement: "Theorem")
  /// >>> #let lemma = thm.with(supplement: "Lemma", counter: "Theorem")
  /// = Heading
  ///
  /// #theorem(
  ///   "Result A",
  ///   restate: true,
  ///   restate-keys: ("Theorem", "Result A")
  /// )[#lorem(6)]
  /// #proof(
  ///   defer: true,
  ///   restate-keys: ("Proof", "Result A")
  /// )[#lorem(7)]
  /// #theorem(restate: true)[#lorem(6)]
  /// #theorem(
  ///   "Result B",
  ///   restate: true,
  ///   restate-keys: ("Theorem", "Result B")
  /// )[#lorem(6)]
  /// #proof(
  ///   defer: true,
  ///   restate-keys: ("Proof", "Result B")
  /// )[#lorem(7)]
  ///
  /// = Restate Result A
  /// #thm-restate("Result A")
  ///
  /// = Restate theorems tagged Result B
  /// #thm-restate(("Theorem", "Result B"))
  /// ```,
  /// mode: "markup",
  /// scope: (thm-rules: thm-rules-2)
  /// )
  ///
  /// If `k` in `keys` is a `function`, it must be of the form `restate-keys -> bool`.
  /// #example(```
  /// >>> #show: thm-rules
  /// >>> #set heading(numbering: "1.1")
  /// >>> #let theorem = thm.with(supplement: "Theorem")
  /// >>> #let lemma = thm.with(supplement: "Lemma", counter: "Theorem")
  /// = Heading
  ///
  /// #theorem(
  ///   restate: true,
  ///   restate-keys: (
  ///     "Theorem", "Unproven claim"
  ///   )
  /// )[#lorem(6)]
  /// #theorem(restate: true)[#lorem(6)]
  /// #lemma(
  ///   "Claim D",
  ///   restate: true,
  ///   restate-keys: ("Lemma", "Claim D")
  /// )[#lorem(6)]
  ///
  /// = Restate claims
  /// #thm-restate(
  ///   keys => keys.any(
  ///     k => lower(k).contains("claim")
  ///   )
  /// )
  /// ```,
  /// mode: "markup",
  /// scope: (thm-rules: thm-rules-2)
  /// )
  /// -> str | content | array | function
  ..keys,
  /// Formatting function, with the same form as @thm.fmt.
  /// The default ```typc auto``` uses the originally supplied formatting function @thm.fmt.
  /// See @thm-display.fmt.
  /// -> function | auto
  fmt: auto,
  /// Location up to which theorem environments will be displayed.
  /// The default ```typc auto``` uses the location where @thm-restate was called.
  /// See @thm-display.at.
  /// -> label | selector | location | function | auto
  at: auto,
  /// If ```typc true```, display environments up to the end of the document.
  /// Overrides @thm-restate.at.
  /// See @thm-display.final.
  /// -> bool
  final: false,
  /// If ```typc true```, ignores the `thm`'s `restate` or `defer` state (see @thm.restate, @thm.defer).
  /// Calling ```typc thm-restate(all: true)``` is equivalent to
  /// ```typc thm-display()```.
  /// -> bool
  all: false
) = {
  context {
    let thms = thm-stored.get()
    if at != auto {
      thms = thm-stored.at(at)
    }
    if final {
      thms = thm-stored.final()
    }
    if not all {
      thms = thms.filter(thm => (thm.restate or thm.defer))
    }
    if keys.pos().len() > 0 {
      // Use arg_1 or ... or arg_n style filter
      thms = thms.filter(thm =>
        keys.pos().any(x => {
          if type(x) == array {
            // keys contain x_1 and ... and x_n
            return x.all(key => thm.restate-keys.contains(key))
          } else if type(x) == function {
            // keys passes filter x
            return x(thm.restate-keys)
          } else {
            // keys contains x
            return thm.restate-keys.contains(x)
          }
        })
      )
    }

    for thm in thms {
      if fmt == auto {
        (thm.fmt)(thm)
      } else {
        fmt(thm)
      }
    }
  }
}

