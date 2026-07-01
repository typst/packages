#import "./format.typ"
#import "./format.typ": panic-fmt

/// Checks if `obj` matches the `pattern`.
///
/// *Examples:*
///
/// ```typst
/// matches(Array(int), (3, 4, 5, "not an int")) // false
/// ```
///
/// ```typst
/// let fn-with-multiple-signatures(..args) = {
///     if matches(Arguments(Int), args) {
///         // ...
///     } else if matches(Arguments(Str), args) {
///         // ...
///     } else if matches(Arguments(Str, level: Int), args) {
///         // ...
///     } else {
///         // ...
///     }
/// }
/// ```
///
/// *Returns:*
///
/// Either `true` or `false`.
///
/// *Arguments:*
///
/// - pattern (Pattern): the pattern to check against, e.g. `Array(Dictionary(name: Str, email: Str))`. Note that the
///     underlying Typst types are not valid here. This because, for example, Typst does not have a way to indicate the
///     types of the elements of an `array`. In addition, `typsy.class`es can be used directly as patterns.
/// - obj (any): the object to check, e.g. `((name: "Tim", email: "tim@example.com"),)`.
#let matches(pattern, obj) = {
    if type(pattern) == function {
        panic-fmt(
            "Cannot pattern-match on a function. This usually occurs when writing e.g. `matches(Array, (1, none))` "
                + "rather than `matches(Array(Any), (1, none))`. Got pattern `{}`.",
            repr(pattern),
        )
    }
    if type(pattern) == type {
        panic-fmt(
            "Cannot pattern-match on a type. This usually occurs when writing e.g. `matches(int, 3)` instead of "
                + "`matches(Int, 3)`. Got pattern `{}`.",
            repr(pattern),
        )
    }
    if type(pattern) != dictionary {
        panic-fmt(
            "Cannot pattern-match on a pattern of type `{}`. Got pattern `{}`.",
            repr(type(pattern)),
            repr(pattern),
        )
    }
    (pattern.__kidger_sentinel_match.match)(obj)
}

/// Used with `match`.
///
/// *Arguments:*
///
/// - pattern (Pattern): any kind of pattern.
/// - fn (function): a function `()=>any`.
#let case(pattern, fn) = (pattern: pattern, fn: fn)
/// Pattern-matching. See also `enumeration` for where this feature really shines.
///
/// This is syntactic sugar around the lower-level `matches` function.
///
/// *Example:*
///
/// ```typst
/// #let foo = (3, 4)
/// #let bar = match(foo,
///     case(Array(Int), ()=>{
///         foo.at(0)
///     }),
///     case(Array(Int, Int), ()=>{
///         foo.at(0) + foo.at(1)
///     }),
/// )
/// ```
///
/// *Returns:*
///
/// The output of the first `case` statement that the argument matches.
///
/// *Arguments:*
///
/// - obj (any): the object to pattern-match.
/// - cases (arguments): any number of `case`s.
#let match(obj, ..cases) = {
    if cases.named().len() != 0 {
        panic-fmt("`match` does not accept any named arguments, received `{}`.", repr(cases.named().keys()))
    }
    for case in cases.pos() {
        if matches(case.pattern, obj) { return (case.fn)() }
    }
    panic-fmt("Did not match any case. Value was `{}`.", repr(obj))
}

#let _match(match) = (__kidger_sentinel_match: (match: match))
#let _match_type(typ) = _match(obj => type(obj) == typ)

//
// Basic types
//

#let Any = _match(obj => true)
#let Bool = _match_type(bool)
#let Bytes = _match_type(bytes)
#let Content = _match_type(content)
#let Counter = _match_type(counter)
#let Datetime = _match_type(datetime)
#let Decimal = _match_type(decimal)
#let Duration = _match_type(duration)
#let Float = _match_type(float)
#let Function = _match_type(function)  // Just a simple type as there is no way to verify its signature.
#let Int = _match_type(int)
#let Label = _match_type(label)
#let Location = _match_type(location)
#let Module = _match_type(module)
#let Never = _match(obj => false)  // Useful extra addition
#let None = _match(obj => obj == none)
#let Ratio = _match_type(ratio)
#let Regex = _match_type(regex)
#let Selector = _match_type(selector)
#let Str = _match_type(str)
#let Symbol = _match_type(symbol)
#let Type = _match_type(type)
#let Version = _match_type(version)

//
// Generic types
//

#let _unpack(fn) = x => fn(..x)

/// *Usage:*
///
/// - `Array(Int)` is a pattern that would accept `(3,)` but not `(3, 4)`.
/// - `Array(Int, Int)` is a pattern that would accept `(3, 4)` but not `(3,)`.
/// - `Array(Int, Str)` is a pattern that would accept `(3, "hi")`.
/// - `Array(..Int)` is a pattern that would accept `(3,)` and `(3, 4)` and `(3, 4, 5)`.
/// - `Array(Bool, Str, ..Int)` is a pattern that would accept `(true, "hello")` and `(true, "hello", 3, 4, 5)`
///
/// So positional arguments correspond to the types of the first elements on an array, and `..` unpacking corresponds to
/// the types of the tail.
#let Array(..eltypes) = {
    let pos = eltypes.pos()
    let named = eltypes.named()
    if named.len() == 0 {
        _match(obj => type(obj) == array and pos.len() == obj.len() and pos.zip(obj).all(_unpack(matches)))
    } else {
        if named.keys() == ("__kidger_sentinel_match",) {
            if pos.len() == 0 and named == Any {
                _match_type(array) // Fastpath
            } else {
                _match(obj => (
                    type(obj) == array
                        and pos.len() <= obj.len()
                        and pos.zip(obj.slice(0, pos.len()), exact: true).all(_unpack(matches))
                        and obj.slice(pos.len()).all(matches.with(named))
                ))
            }
        } else {
            panic-fmt(
                "`Array` should either be called with positional arguments e.g. `Array(Int, Str)`, or with a variadic "
                    + "argument e.g. `Array(..Int)`, or both e.g. `Array(Int, Str, ..Int)`. However received keywords "
                    + "`{}` instead.",
                repr(named.keys()),
            )
        }
    }
}
/// *Usage:*
///
/// - `Dictionary(..Int)` is a pattern that would accept `(foo: 3)` and `(foo: 3, bar: 4)` but not `(foo: 3, bar: "x")`.
/// - `Dictionary(bar: Str, ..Int)` is a pattern that would accept `(foo: 3, bar: "x")` but not `(foo: 3)`
///      or `(foo: 3, bar: 4)`.
///
/// So the named arguments correspond to type of the value in key-value pairs with that specific key, and `..` unpacking
/// corresponds to the the type of the value for all other keys. (And recall that Typst only allows for string-typed
/// keys, so we do not need to annotate those.)
#let Dictionary(..valtypes) = {
    if valtypes.pos().len() != 0 {
        panic-fmt(
            "`Dictionary` should either be called with zero positional arguments. Got {} positional arguments instead.",
            repr(valtypes.pos().len()),
        )
    }
    let named = valtypes.named()
    let valtype = (
        __kidger_sentinel_match: named.remove("__kidger_sentinel_match", default: Never.__kidger_sentinel_match),
    )
    if valtype == Any and named.len() == 0 { return _match_type(dictionary) } // Fastpath
    if valtype == Any and named.len() == 1 { // Fastpath for a particularly common case.
        let ((key, pat),) = named.pairs()
        return _match(obj => type(obj) == dictionary and obj.keys().contains(key) and matches(pat, obj.at(key)))
    }
    _match(obj => (
        type(obj) == dictionary
            and obj.pairs().all(kv => matches(named.at(kv.at(0), default: valtype), kv.at(1)))
            and named.keys().all(n => obj.keys().contains(n))
    ))
}
/// For use with `Arguments`.
#let Pos(eltype) = (__kidger_sentinel_pos: eltype)
/// For use with `Arguments`.
#let Named(valtype) = (__kidger_sentinel_named: valtype)
/// *Usage:*
///
/// - `Arguments(Str, Bool)` is a pattern that would match the `arguments` to `some-fn("foo", true)`.
/// - `Arguments(Str, level: Int)` is a pattern that would match the `arguments` to `some-fn("foo", level: 1)`.
/// - `Arguments(level: Int, sep: Str)` is a pattern that would match the `arguments` to `some-fn(level: 1, sep: ",")`.
/// - `Arguments(..Any)` is a pattern that would match all `arguments` to any function.
/// - `Arguments(..Int)` is a pattern that would match the `arguments` to `some-fn(3, 4, foo: 5, bar: 6)`.
/// - `Arguments(..Pos(Int))` is a pattern that would match the `arguments` to `some-fn(3, 4)`.
/// - `Arguments(..Named(Int))` is a pattern that would match the `arguments` to `some-fn(foo: 5, bar: 6)`.
///
/// That is, we can specify both positional and named arguments straightforwardly. We can specify variadic positional
/// arguments using `..Pos(Foo)` and variadic named arguments using `..Named(Foo)`, and variadic positional+named
/// arguments via `..Foo`.
#let Arguments(..args) = {
    let named = args.named()

    let var = named.remove("__kidger_sentinel_match", default: auto)
    let varpos = named.remove("__kidger_sentinel_pos", default: auto)
    let varnamed = named.remove("__kidger_sentinel_named", default: auto)
    let pos = if var == auto {
        if varpos == auto {
            Array(..args.pos())
        } else {
            Array(..args.pos(), ..varpos)
        }
    } else {
        if varpos == auto {
            Array(..args.pos(), __kidger_sentinel_match: var)
        } else {
            panic-fmt(
                "`Arguments` called with both variadic and variadic-positional arguments, e.g. "
                    + "`Arguments(..Foo, ..Pos(Bar))`",
            )
        }
    }
    let named = if var == auto {
        if varnamed == auto {
            Dictionary(..named)
        } else {
            Dictionary(..named, ..varnamed)
        }
    } else {
        if varnamed == auto {
            Dictionary(..named, __kidger_sentinel_match: var)
        } else {
            panic-fmt(
                "`Arguments` called with both variadic and variadic-named arguments, e.g. "
                    + "`Arguments(..Foo, ..Named(Bar))`",
            )
        }
    }

    _match(obj => type(obj) == arguments and matches(pos, obj.pos()) and matches(named, obj.named()))
}
/// *Usage:*
///
/// - `State(Int)` would match `state("foo", 4)`
///
/// That is, the pattern specifies the value of the state.
#let State(statetype) = _match(obj => type(obj) == state and matches(statetype, obj.get()))

//
// Miscellaneous
//

/// *Usage:*
///
/// - `Literal(3)` is a pattern that would accept `3` but not `4`.
/// - `Literal(3, 4, "hi")` is a pattern that would accept `3` and `"hi"` but not `"bye"`.
///
/// That is, this is a collection of values, at least one of which we must be equal to.
#let Literal(..values) = {
    let named = values.named()
    if named.len() != 0 {
        panic-fmt("`Literal` should only be called with positional arguments. Got keywords `{}`.", repr(named.keys()))
    }
    _match(obj => values.pos().contains(obj))
}
/// *Usage:*
///
/// - `Union(Int, Str)` is a pattern that would accept `3` and `"hi"` but not `(foo: 4)`.
///
/// That is, this is a collection of patterns, at least one of which we must match.
#let Union(..values) = {
    let named = values.named()
    if named.len() != 0 {
        panic-fmt("`Union` should only be called with positional arguments. Got keywords `{}`.", repr(named.keys()))
    }
    _match(obj => values.pos().any(v => matches(v, obj)))
}
/// Takes a pattern, and additionally requires that a function must return `true` in order for values to satisfy the
/// pattern.
///
/// *Examples:*
///
/// ```typst
/// #let Email = Refine(Str, x=>x.contains("@"))
/// #matches(Email, "hello@example.com") // true
/// #matches(Email, "hello world") // false
/// ```
///
/// This can also be used to create brand-new patterns by refining `Any`, e.g. we could reimplement `Literal` via
/// ```typst
/// #let MyLiteral(..values) = Refine(Any, x=>values.pos().contains(x))
/// #matches(MyLiteral(3), 3) // true
/// #matches(MyLiteral(3), 4) // false
/// ```
///
/// **Returns:**
///
/// A new pattern.
///
/// **Arguments:**
///
/// - pattern (Pattern): an existing pattern.
/// - predicate (function): a function `<satisfies pattern> -> bool`. It will only be called on items that already
///     match `pattern`.
#let Refine(pattern, predicate) = {
    _match(obj => matches(pattern, obj) and predicate(obj))
}

#let panic-on-type() = {
    matches(int, 3)
}

#let panic-on-function() = {
    matches(Array, (3,))
}

#let test-basic-types() = {
    assert(matches(Any, "hi"))
    assert(matches(Any, 1))
    assert(matches(Any, [some content]))

    assert(matches(Bool, true))
    assert(not matches(Bool, "not a bool"))

    assert(matches(Bytes, bytes("hello")))
    assert(not matches(Bytes, "hello"))

    assert(matches(Content, [hello there]))
    assert(not matches(Content, "hello there"))

    assert(matches(Datetime, datetime(year: 1, month: 1, day: 1)))
    assert(matches(Datetime, datetime(hour: 1, minute: 1, second: 1)))
    assert(not matches(Datetime, "hello"))

    assert(matches(Decimal, decimal("3.0")))
    assert(not matches(Decimal, 3.0))

    assert(matches(Duration, duration(hours: 1)))
    assert(not matches(Duration, "duration"))

    assert(matches(Float, 3.0))
    assert(not matches(Float, 3))

    assert(matches(Function, () => {}))
    assert(not matches(Function, ()))

    assert(matches(Int, 3))
    assert(not matches(Int, 3.0))
    assert(not matches(Int, decimal("3")))

    assert(matches(Label, <hi>))
    assert(not matches(Label, "hi"))

    assert(matches(Module, format))
    assert(not matches(Module, "format"))

    assert(not matches(Never, 3))
    assert(not matches(Never, "3"))

    assert(matches(None, none))
    assert(not matches(None, "none"))

    assert(matches(Ratio, 150%))
    assert(not matches(Ratio, 1 / 2))

    assert(matches(Regex, regex("foo")))
    assert(not matches(Regex, "foo"))

    assert(matches(Selector, heading.where(level: 1)))
    assert(not matches(Selector, heading))

    assert(matches(Str, "hi"))
    assert(not matches(Str, bytes("hi")))

    assert(matches(Symbol, symbol("x")))
    assert(not matches(Symbol, "x"))

    assert(matches(Type, int))
    assert(matches(Type, str))
    assert(matches(Type, function))
    assert(not matches(Type, Int))
    assert(not matches(Type, Str))
    assert(not matches(Type, Function))

    assert(matches(Version, version(0, 1, 2)))
    assert(not matches(Version, (0, 1, 2)))
}

#let test-location() = {
    context assert(matches(Location, here()))
    assert(not matches(Location, "here"))
}
#test-location()

#let test-arguments() = {
    let id(..args) = args
    assert(not matches(Arguments(..Any), 3))

    assert(matches(Arguments(Int), id(3)))
    assert(not matches(Arguments(Int), id(3, 4)))
    assert(not matches(Arguments(Int), id(3, foo: 4)))
    assert(not matches(Arguments(Int), id(foo: 4)))
    assert(not matches(Arguments(Int), id(3.0)))
    assert(matches(Arguments(Int, Str, Int), id(3, "hi", 4)))
    assert(not matches(Arguments(Int, Str, Int), id(3, "hi", 4, 5)))
    assert(not matches(Arguments(Int, Str, Int), id(3, 4, "hi", 5)))

    assert(matches(Arguments(Int, Str, foo: Int), id(3, "hi", foo: 4)))
    assert(not matches(Arguments(Int, Str, foo: Int), id(3, "hi", foo: "hi")))
    assert(not matches(Arguments(Int, Str, foo: Int, bar: Array(Int)), id(3, "hi", foo: "hi")))
    assert(matches(Arguments(Int, Str, foo: Str, bar: Array(Int)), id(3, "hi", foo: "hi", bar: (3,))))
    assert(not matches(Arguments(Int, Str, foo: Int, bar: Array(Int)), id(3, "hi", foo: "hi", bar: (3.0,))))

    assert(matches(Arguments(..Any), id(3)))
    assert(matches(Arguments(..Any), id(3, 4)))
    assert(matches(Arguments(..Any), id(3, 4, foo: "hi")))
    assert(matches(Arguments(..Any), id(3, 4, foo: "hi", bar: id(5))))

    assert(matches(Arguments(..Int), id()))
    assert(matches(Arguments(..Int), id(3)))
    assert(matches(Arguments(..Int), id(3, 4)))
    assert(not matches(Arguments(..Int), id(3, 4, foo: "hi")))
    assert(not matches(Arguments(..Int), id(3, "hi", foo: 4)))
    assert(matches(Arguments(..Int), id(3, 4, foo: 4)))

    assert(matches(Arguments(..Pos(Int)), id()))
    assert(matches(Arguments(..Pos(Int)), id(3)))
    assert(matches(Arguments(..Pos(Int)), id(3, 4)))
    assert(not matches(Arguments(..Pos(Int)), id(3, "4")))
    assert(not matches(Arguments(..Pos(Int)), id(3, 4, foo: 5)))

    assert(matches(Arguments(..Named(Int)), id()))
    assert(matches(Arguments(..Named(Int)), id(foo: 3)))
    assert(matches(Arguments(..Named(Int)), id(foo: 3, bar: 4)))
    assert(not matches(Arguments(..Named(Int)), id(foo: 3, bar: "4")))
    assert(not matches(Arguments(..Named(Int)), id(3, 4, foo: 5)))

    assert(matches(Arguments(..Pos(Int), ..Named(Str)), id()))
    assert(matches(Arguments(..Pos(Int), ..Named(Str)), id(3)))
    assert(matches(Arguments(..Pos(Int), ..Named(Str)), id(3, foo: "hi")))
    assert(not matches(Arguments(..Pos(Int), ..Named(Str)), id(3, foo: 3)))
    assert(not matches(Arguments(..Pos(Int), ..Named(Str)), id("hi", foo: 3)))
    assert(matches(Arguments(Str, foo: Int, ..Pos(Int), ..Named(Str)), id("hi", foo: 3)))
    assert(matches(Arguments(..Pos(Int), foo: Int, ..Named(Str)), id(3, foo: 3)))

    let def = Arguments(Str, Int, Float, foo: Int, ..Pos(Int), ..Named(Str))
    assert(matches(def, id("hi", 3, 3.0, 2, 5, foo: 3, bar: "bye")))
    assert(not matches(def, id(3, 3, 3.0, 2, 5, foo: 3, bar: "bye")))
    assert(not matches(def, id("hi", "3", 3.0, 2, 5, foo: 3, bar: "bye")))
    assert(not matches(def, id("hi", 3, "3.0", 2, 5, foo: 3, bar: "bye")))
    assert(not matches(def, id("hi", 3, 3.0, 2, 5, foo: "3", bar: "bye")))
    assert(not matches(def, id("hi", 3, 3.0, "2", 5, foo: 3, bar: 5)))
    assert(not matches(def, id("hi", 3, 3.0, 2, 5, foo: 3, bar: 5)))
}


#let test-array() = {
    assert(not matches(Array(Any), 3))
    assert(not matches(Array(Any), (hi: 3)))

    assert(matches(Array(), ()))
    assert(not matches(Array(), (3,)))
    assert(not matches(Array(), (3, 4)))
    assert(matches(Array(Any), (3,)))
    assert(matches(Array(Int), (3,)))
    assert(not matches(Array(Int), ()))
    assert(not matches(Array(Int), (3, 4)))
    assert(matches(Array(Any, Any), (1, none)))
    assert(matches(Array(Any, Any), (1, "hi")))
    assert(not matches(Array(Any, Any), ()))
    assert(not matches(Array(Any, Any), (3,)))
    assert(not matches(Array(Int, Any), (3,)))
    assert(not matches(Array(Int, Int), (3,)))

    assert(matches(Array(Int, Str), (3, "hi")))
    assert(not matches(Array(Int, Str), ("hi", 3)))

    assert(matches(Array(Array(Int), Str), ((3,), "hi")))
    assert(not matches(Array(Array(Int), Str), ((3, 4), "hi")))

    assert(matches(Array(..Int), ()))
    assert(matches(Array(..Int), (3,)))
    assert(matches(Array(..Int), (3, 4)))
    assert(matches(Array(..Int), (3, 4, 5)))
    assert(matches(Array(..Any), ()))
    assert(matches(Array(..Any), (3, "4", none)))
    assert(matches(Array(..Never), ()))
    assert(not matches(Array(..Never), (3,)))
    assert(matches(Array(..Array(Int)), ((3,), (4,), (5,))))
    assert(not matches(Array(..Array(Int)), ((3,), (4,), (5, 6))))

    assert(not matches(Array(Int, Str, ..Int), ()))
    assert(not matches(Array(Int, Str, ..Int), (3,)))
    assert(matches(Array(Int, Str, ..Int), (3, "hi")))
    assert(matches(Array(Int, Str, ..Int), (3, "hi", 4)))
    assert(matches(Array(Int, Str, ..Int), (3, "hi", 4, 5)))
    assert(not matches(Array(Int, Str, ..Int), (3, "hi", 4, 5, "hi")))

    assert(matches(Array(Int, Str, ..Any), (3, "hi", 4, 5)))
    assert(matches(Array(Int, Str, ..Any), (3, "hi", 4, 5, "hi")))
}

#let panic-on-array-keywords() = {
    Array(hi: 3)
}

#let test-dictionary() = {
    assert(not matches(Dictionary(), 3))
    assert(not matches(Dictionary(), (3,)))

    assert(matches(Dictionary(), (:)))
    assert(matches(Dictionary(..Any), (:)))
    assert(matches(Dictionary(..Int), (:)))
    assert(matches(Dictionary(..Str), (:)))

    assert(matches(Dictionary(..Int), (hi: 3, bye: 3)))
    assert(matches(Dictionary(..Any), (hi: 3, bye: 3)))
    assert(matches(Dictionary(..Any), (hi: 3, bye: "foo")))
    assert(matches(Dictionary(..Union(Int, Str)), (hi: 3, bye: "foo")))
    assert(not matches(Dictionary(..Union(Int, Bytes)), (hi: 3, bye: "foo")))
    assert(not matches(Dictionary(..Union(Int, Str)), (hi: 3, bye: "foo", baz: 3.0)))

    assert(matches(Dictionary(hi: Int, bye: Int), (hi: 3, bye: 3)))
    assert(not matches(Dictionary(hi: Int, bye: Int), (hi: 3, bye: "foo")))
    assert(matches(Dictionary(hi: Int, bye: Str), (hi: 3, bye: "foo")))
    assert(matches(Dictionary(hi: Int, bye: Str), (hi: 3, bye: "foo")))

    assert(matches(Dictionary(hi: Int, bye: Str, ..Str), (hi: 3, bye: "foo", baz: "boom")))
    assert(not matches(Dictionary(hi: Int, bye: Str, ..Str), (hi: 3, bye: "foo", baz: 3)))
    assert(matches(Dictionary(hi: Int, bye: Str, ..Any), (hi: 3, bye: "foo", baz: "boom")))
    assert(not matches(Dictionary(hi: Int, bye: Int, ..Any), (hi: 3, bye: "foo")))
    assert(not matches(Dictionary(hi: Int, bye: Int, ..Str), (hi: 3, bye: "foo")))
}

#let test-dictionary-incomplete() = {
    assert(not matches(Dictionary(foo: Int, ..Any), (:)))
}

#let test-dictionary-fastpath-single-element() = {
    let pat = Dictionary(hi: Int, ..Any)
    assert(matches(pat, (hi: 3)))
    assert(matches(pat, (hi: 3, bye: 3)))
    assert(matches(pat, (hi: 3, bye: "foo")))
    assert(not matches(pat, (:)))
    assert(not matches(pat, (hi: "foo")))
    assert(not matches(pat, (bye: "foo")))
    assert(not matches(pat, (bye: 3)))
}

#let panic-on-dictionary-args1() = {
    Dictionary(Int)
}

#let panic-on-dictionary-args2() = {
    Dictionary(Int, Str)
}

#let test-state() = {
    let foo = state("kidger-match-test-state", 3)
    context assert(matches(State(Any), foo))
    context assert(matches(State(Int), foo))
    context assert(not matches(State(Str), foo))
}
#test-state()

#let test-literal() = {
    assert(matches(Literal(heading), heading))
    assert(matches(Literal(heading, page), heading))
    assert(not matches(Literal(page), heading))
    assert(matches(Literal(int), int))
    assert(not matches(Literal(int), str))
}

#let test-union() = {
    assert(matches(Union(Int, Str), 3))
    assert(matches(Union(Int, Int), 3))
    assert(not matches(Union(Bytes, Str), 3))
    assert(matches(Union(Array(..Int), Array(..Str)), (3,)))
    assert(not matches(Union(Array(..Int), Array(..Str)), (3.0,)))
    assert(matches(Union(Array(..Union(Int, Float)), Array(..Str)), (3.0,)))
}

#let test-refine() = {
    let Email = Refine(Str, x => x.contains("@"))
    assert(matches(Email, "hello@example.com"))
    assert(not matches(Email, "hello world"))
    let MyLiteral(..values) = Refine(Any, x => values.pos().contains(x))
    assert(matches(MyLiteral(3), 3))
    assert(not matches(MyLiteral(3), 4))
}

#let test-pattern-match() = {
    assert.eq(match(3, case(Int, () => 4), case(Str, () => 5)), 4)
}

#let panic-on-no-pattern-match() = {
    match(3, case(Float, () => 4), case(Str, () => 5))
}
