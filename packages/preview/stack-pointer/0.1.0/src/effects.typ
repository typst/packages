/// Sequence item with type `"call"`: adds a stack frame for calling the named function.
///
/// - name (string): the function name to associate with the stack frame
/// -> array
#let call(name) = ((type: "call", name: name),)

/// Sequence item with type `"push"`: adds a variable to the current stack frame.
///
/// - name (string): the new local variable being introduced
/// - value (any): the value of the variable
/// -> array
#let push(name, value) = ((type: "push", name: name, value: value),)

/// Sequence item with type `"assign"`: assigns an already existing variable of the current stack
/// frame.
///
/// - name (string): the existing local variable being assigned
/// - value (any): the value of the variable
/// -> array
#let assign(name, value) = ((type: "assign", name: name, value: value),)

/// Sequence item with type `"return"`: pops the current stack frame.
///
/// -> array
#let ret() = ((type: "return"),)
