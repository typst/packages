#import "/src/operators.typ" as ops

#let combine(id, descr) = {
  let rule = (pat: (), yy: (), nn: ())
  let dangling-pats = ()
  if type(descr) != array {
    panic("Rule " + id + " is not valid")
  }
  for elt in descr {
    if type(elt) != dictionary {
      panic("Rule " + id + " is not valid")
    }
    if "pat" in elt {
      dangling-pats.push(elt.pat)
    } else if "rw" in elt {
      if dangling-pats == () {
        panic("This instance of 'rw' does not apply to any patterns")
      }
      rule.pat.push(ops.rewrite(elt.rw)(ops.auto-fork(..dangling-pats)))
      dangling-pats = ()
    } else if "yy" in elt {
      rule.yy.push(elt)
    } else if "nn" in elt {
      rule.nn.push(elt)
    } else {
      panic(elt) // TODO: improve error
    }
  }
  if dangling-pats != () {
    rule.pat.push(ops.auto-fork(..dangling-pats))
  }
  if rule.pat != () {
    rule.pat = ops.auto-fork(..rule.pat)
  }
  (""+id: rule)
}

/// Constructs a new grammar from its rules.
/// -> grammar
#let grammar(
  /// List of named rules, as constructed by @cmd:prelude:pat and its related functions.
  /// -> rule
  ..rules
) = {
  let rules = rules.named()
  if rules.len() == 0 {
    return (:)
  }
  for (id, descr) in rules {
    combine(id, descr)
  }
}

#let trim(
  grammar,
  roots: none,
) = {
  if roots == none {
    panic("Must specify at least one root for trim")
  }
  let explore-pat(pat) = {
    let reach = ()
    if type(pat) == label {
      reach.push(pat)
    } else if type(pat) == dictionary {
      if pat.call == ops.label {
        reach.push(label(pat.arg))
      } else if "pat" in pat {
        reach += explore-pat(pat.pat)
      } else if "pats" in pat {
        for sub in pat.pats {
          reach += explore-pat(sub)
        }
      } else {
        // this is a leaf
      }
    } else {
      // also a leaf
    }
    reach
  }
  let reach = ()
  let stack = (roots,).flatten()
  while stack.len() > 0 {
    let root = stack.pop()
    if str(root) not in grammar {
      panic(str(root) + " is not a declared rule: the grammar is not closed")
    }
    if root in reach {
      // noop: already explored
    } else {
      reach.push(root)
      let sub = explore-pat(grammar.at(str(root)).pat)
      for label in sub {
        if label not in reach {
          stack.push(label)
        }
      }
    }
  }
  for (id, _) in grammar {
    if label(id) not in reach {
      let _ = grammar.remove(id)
    }
  }
  grammar
}

/// Edits a grammar by adding new rules and new cases to existing rules.
///
/// See: @sec-extend.
/// -> grammar
#let extend(
  /// Base grammar, takes precedence on rules that are defined by both.
  /// -> grammar
  base,
  /// New rules and cases.
  /// -> grammar
  ..ext,
) = {
  let g = base
  for g2 in ext.pos() {
    for (k, v2) in g2 {
      if k in g {
        let v = g.remove(k)
        v.pat += v2.pat
        v.yy += v2.yy
        v.nn += v2.nn
        g.insert(k, v)
      } else {
        g.insert(k, v2)
      }
    }
  }
  g
}

/// Edits a grammar by substituting old rules for new ones.
///
/// See: @sec-patch.
/// -> grammar
#let patch(
  /// Base grammar.
  /// -> grammar
  base,
  /// Patch, replaces rules already defined by `base`.
  /// -> grammar
  ..ext,
) = {
  let g = base
  for g2 in ext.pos() {
    for (k, v2) in g2 {
      if k in g {
        let v = g.remove(k)
        if v2.pat != () {
          v = v2
        } else {
          v.yy = v2.yy
          v.nn = v2.nn
        }
        g.insert(k, v)
      } else {
        g.insert(k, v2)
      }
    }
  }
  g
}

/// Removes unit tests from a grammar.
/// Particularly useful when patching a grammar to remove those that would
/// no longer pass.
/// -> grammar
#let strip(
  /// Base grammar.
  /// -> grammar
  base,
  /// Whether to remove positive tests.
  /// -> bool
  yy: true,
  /// Whether to remove negative tests.
  /// -> bool
  nn: true,
) = {
  let g = (:)
  for (k, v) in base {
    if yy {
      v.yy = ()
    }
    if nn {
      v.nn = ()
    }
    g.insert(k, v)
  }
  g
}

/// Adds a prefix to some rules of a grammar.
/// Useful before @cmd:kleene:patch or @cmd:kleene:extend to avoid collisions.
/// -> grammar
#let freshen(
  /// Base grammar.
  /// -> grammar
  grammar,
  /// This prefix will be added to all rules.
  /// -> str
  prefix: "_",
  /// Rules that match this selector will not receive the prefix.
  /// What this means depends on the type of `exclude`:
  /// - #typ.t.label: the exact rule specified,
  /// - #typ.t.function: rules whose label returns #typ.v.true via this function,
  /// - #typ.t.array: union of all the individual interpretations.
  /// -> label | array | function
  exclude: (),
) = {
  let is-excluded(exclude, lab) = {
    if type(exclude) == label {
      lab == exclude
    } else if type(exclude) == function {
      exclude(lab)
    } else if type(exclude) == array {
      exclude.any(ex => is-excluded(ex, lab))
    } else {
      panic("Object of type '" + str(type(exclude)) + "' is not a valid rule filter")
    }
  }
  let is-excluded = is-excluded.with(exclude)
  let freshen-pat(pat) = {
    if type(pat) == label {
      if is-excluded(pat) or (str(pat) not in grammar) {
        pat
      } else {
        label(prefix + str(pat))
      }
    } else if type(pat) == dictionary {
      if pat.call == ops.label {
        if not (is-excluded(label(pat.arg)) or (pat.arg not in grammar)) {
          pat.arg = prefix + pat.arg
        }
        pat
      } else {
        if "pat" in pat {
          pat.pat = freshen-pat(pat.pat)
        } else if "pats" in pat {
          pat.pats = pat.pats.map(freshen-pat)
        } else {
          // this is a leaf, there's nothing to freshen
        }
      }
      pat
    } else {
      pat
    }
  }
  let freshen-rule(rule) = {
    rule.pat = freshen-pat(rule.pat)
    rule
  }
  let out = (:)
  for (id, rule) in grammar {
    let rule = freshen-rule(rule)
    let id = if is-excluded(label(id)) {
      id
    } else {
      prefix + id
    }
    out.insert(id, rule)
  }
  out
}
