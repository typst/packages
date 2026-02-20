#import "stackframe.typ"
#import "operators.typ" as ops

/// Automatically reinterprets builtin types/values to operators.
/// #property-priv()
/// -> pattern
#let auto-cast(
  /// Pattern to interpret.
  /// - #typ.t.function: native
  /// - #typ.t.string: cast through @cmd:prelude:str
  /// - #typ.t.label: cast through @cmd:prelude:label
  /// - #typ.t.array: cast through @cmd:prelude:seq
  /// - ```typc $$```: shorthand for @cmd:prelude:commit
  /// - #typ.raw: cast through @cmd:prelude:regex
  /// -> any
  pat
) = {
  if type(pat) == function {
    pat
  } else if type(pat) == label {
    ops.label(str(pat))
  } else if type(pat) == str {
    ops.str(pat)
  } else if type(pat) == array {
    ops.seq(..pat)
  } else if pat == $$ {
    ops.commit()
  } else if type(pat) == content and pat.func() == std.raw {
    ops.regex(pat.text)
  } else {
    panic("Cannot interpret an object of type " + str(type(pat)) + " as a parser")
  }
}

// Manages the mutual recursion between operators
// and tracks the current state of the rule stack.
#let _subparse(rules, stack) = (id, input) => {
  let stack = stack
  if type(id) == label {
    stack.push(id)
    let rule = rules.at(str(id))
    let select = rule.pat
    while type(select) != dictionary {
      select = auto-cast(select)
    }
    let call = select.remove("call")
    stackframe.tailcall(call(..select))(_subparse(rules, stack), stack, input)
  } else {
    while type(id) != dictionary {
      id = auto-cast(id)
    }
    let call = id.remove("call")
    stackframe.tailcall(call(..id))(_subparse(rules, stack), stack, input)
  }
}

#let subparse(..args) = stackframe.run(_subparse(..args))

/// Initiate parsing.
/// Returns a boolean and a result.
/// The boolean indicates if the parsing is successful.
/// It also determines the type of the result:
/// - whatever type is returned by the last rewriting function in the case of a success,
/// - content that can be directly displayed for an error message in the case of a failure.
/// -> (bool, result)
#let parse(
  /// Typically constructed by @cmd:kleene:grammar.
  /// -> grammar
  rules,
  /// Indicates the entry point for the parsing.
  /// -> label
  pat,
  /// Input data to parse.
  /// -> str
  input,
) = {
  let ans = subparse(rules, ())(pat, input)
  if not ans.ok {
    import "ui.typ"
    (false, ui.error(input, pat, ans))
  } else if ans.rest != "" {
    import "ui.typ"
    (false, ui.incomplete(input, pat, ans))
     } else {
    (true, ans.at("val", default: none))
  }
}

