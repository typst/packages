#import "./match.typ": Arguments, Int, matches
#import "./format.typ": fmt

/// Wraps a function with runtime typechecking.
///
/// *Example:*
///
/// ```typst
/// #let add_integers = typecheck(Arguments(Int, Int), Int, (x, y) => x + y)
/// #let five = add_integers(2, 3)
/// #let will_panic = add_integers("hello ", "world")
/// ```
///
/// *Returns:*
///
/// A wrapped version of `fn`, that consumes the same arguments and returns the same output, but which will panic if the
/// arguments do not match `args-type` or if the return value does not match `return-type`.
///
/// *Arguments:*
///
/// - args-type (Pattern): typically an `Arguments(...)` object specifying the expected arguments. Can in general be any
///     pattern, e.g. `Any` to accept anything, `Union(Arguments(...), Arguments(...))` to accept multiple arguments,
///     etc.
/// - return-type (Pattern): the pattern to check the return value of `fn` against.
/// - fn (function): the function to wrap.
/// - invalid-args (function): a function `args -> str` formatting the error message for invalid arguments.
/// - invalid-return (function): a function `(args, returnval) -> str` formatting the error message for an invalid
///     return value.
#let typecheck(
    args-type,
    return-type,
    fn,
    invalid-args: args => fmt("Arguments `{}` do not match type annotation.", repr(args)),
    invalid-return: (args, returnval) => fmt("Return value `{}` does not match type annotation.", repr(returnval)),
) = {
    (..args) => {
        if not matches(args-type, args) {
            panic(invalid-args(args))
        }
        let returnval = fn(..args)
        if not matches(return-type, returnval) {
            panic(invalid-return(args, returnval))
        }
        returnval
    }
}


#let _add_integers = typecheck(Arguments(Int, Int), Int, (x, y) => x + y)
#let test-typecheck() = {
    let five = _add_integers(2, 3)
    assert.eq(five, 5)
}

#let panic-on-typecheck-args() = {
    _add_integers("hello ", "world")
}

#let _add_integers_buggy = typecheck(Arguments(Int, Int), Int, (x, y) => repr(x + y))
#let panic-on-typecheck-return() = {
    _add_integers_buggy(2, 3)
}
