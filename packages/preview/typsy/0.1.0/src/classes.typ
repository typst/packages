#import "./format.typ": panic-fmt
#import "./match.typ": Any, Dictionary, Literal, matches

/// - name (str):
/// - value (any):
/// - expected (type):
#let _checktype(name, value, expected) = {
    if type(value) != expected {
        panic-fmt(
            "For `{}`, expected type `{}`, received type `{}`.",
            name,
            repr(expected),
            repr(type(value)),
        )
    }
}

/// - fn (function): str->any
/// - names (array<str>):
/// -> dictionary str=>any
#let _fn2dict(fn, names) = {
    let out = (:)
    for name in names {
        out.insert(name, fn(name))
    }
    out
}

#let _make_cls(new, name, fields, methods, tag) = {
    let out = (new: new, name: name, fields: fields, methods: methods, tag: tag, __kidger_sentinel_is_class: true)
    // Make it possible to use classes in pattern-matching.
    // We inspect specifically the `new` field as that should be enough to get uniqueness; in particular it closes over
    // `tag`.
    out + Dictionary(meta: Dictionary(cls: Dictionary(new: Literal(new), ..Any), ..Any), ..Any)
}
// Used for pattern-matching class objects themselves.
#let Class = Dictionary(__kidger_sentinel_is_class: Literal(true), ..Any)

#let _class_or_namespace(name: none, fields: none, methods: none, tag: none, call_on_dict: none) = {
    if name != none {
        _checktype("name", name, str)
    }
    _checktype("fields", fields, dictionary)
    _checktype("methods", methods, dictionary)
    let methods_keys = methods.keys()
    let reserved_fields = ("meta",)
    for (argname, kind) in fields.pairs() {
        _checktype(argname, argname, str)
        _checktype(argname, kind, type)
        if kind == auto {
            panic-fmt("For argname {}: `auto` is not a valid type annotation", argname)
        }
        if methods_keys.contains(argname) {
            panic-fmt("`{}` is present in both `fields` and `methods`", argname)
        }
        if reserved_fields.contains(argname) {
            panic-fmt("`{}` is reserved and cannot be used in `fields`.", argname)
        }
    }
    for (methodname, method) in methods.pairs() {
        _checktype(methodname, methodname, str)
        _checktype(methodname, method, function)
        if reserved_fields.contains(methodname) {
            panic-fmt("`{}` is reserved and cannot be used in `methods`.", methodname)
        }
    }
    let new(..init_args) = {
        if init_args.pos().len() != 0 {
            panic-fmt("Do not call type constructors with positional arguments. Got `{}`", repr(init_args.pos()))
        }

        let self_dict = (:)
        for (initname, value) in init_args.named().pairs() {
            let expected = fields.at(initname, default: auto)
            if expected == auto {
                panic-fmt("Got unexpected init argument `{}`.", initname)
            }
            _checktype(initname, value, expected)
            self_dict.insert(initname, value)
        }
        for (initname, method) in methods.pairs() {
            self_dict.insert(initname, method)
        }
        let repr_pieces = ()
        if name != none {
            repr_pieces.push(name)
        }
        repr_pieces.push(repr(self_dict))
        let meta = (
            // Provide `cls` to allow easy self-recursion.
            // Mutual recursion should be handled by using a `namespace`.
            cls: _make_cls(new, name, fields, methods, tag),
            repr: repr_pieces.join(""),
        )
        self_dict.insert("meta", meta)
        call_on_dict(self_dict)
    }
    _make_cls(new, name, fields, methods, tag)
}

#let _call_on_dict(self_dict) = {
    // This is a sneaky trick. The only kind of recursive data structure in Typst seems to be self-recursive
    // functions. In particular this means that if were to have done e.g.
    // `self_dict.insert(name, (..args)=>method(self, ..args))`
    // above then this would not have worked! We would have captured the *old* version of `self`, which still
    // only has some methods filled in.
    let self_call(attrname) = {
        let value = self_dict.at(attrname)
        if type(value) == function {
            (..args) => value(_fn2dict(self_call, self_dict.keys()), ..args)
        } else {
            value
        }
    }
    _fn2dict(self_call, self_dict.keys())
}

/// Defines a class with attributes and methods. (Similar to Rust or Python.)
///
/// *Example*
///
/// ```typst
/// #{
/// let Adder = class(
///     fields: (x: int),
///     methods: (
///         add: (self, y) => {self.x + y}
///     )
/// )
/// let add_three = (Adder.new)(x: 3)
/// let five = (add_three.add)(2)
/// }
///
/// ```
///
/// *Notes:*
///
/// - Method lookup (but not field lookup) requires brackets around the access.
/// - To access the class object (`Adder` itself in the above example) from within a method, then use `self.meta.cls`.
///     For example, this means that a new instance of the class can be instantiated via `(self.meta.cls.new)(...)`.
///     _Simply using the name of the class object will not work, as it does not yet exist whilst the methods are being
///     defined. (In this way `self.meta.cls` handles the case of simple recursion. And if you need mutual recursion
///     between two different classes/functions/etc, then see `namespace`.)_
///
/// *Returns:*
///
/// The class object, which may later be instantiated via its `.new` method.
///
/// *Arguments:*
///
/// - name (none, str): an optional name for the class. Used in error messages.
/// - fields (dictionary): a mapping str=>type defining the types of the arguments that must be passed at initialisation.
/// - methods (dictionary): a mapping str=>function defining the methods available.
/// - tag (function): an optional place to add `class(..., tag: ()=>{})`. If not provided then all class objects with
///     the same fields and methods will compare equal. If provided then (as all anonymous functions are distinct), this
///     will make the class unique.
#let class(name: none, fields: (:), methods: (:), tag: none) = {
    _class_or_namespace(name: name, fields: fields, methods: methods, tag: tag, call_on_dict: _call_on_dict)
}

#let test-doc() = {
    let Adder = class(
        fields: (x: int),
        methods: (
            add: (self, y) => { self.x + y },
        ),
    )
    let add_three = (Adder.new)(x: 3)
    let five = (add_three.add)(2)
    assert.eq(five, 5)
}

#let test-basic() = {
    let ArgTest = class(fields: (x: int))
    let foo = (ArgTest.new)(x: 3)
    assert.eq(foo.x, 3)
}

#let panic-on-basic() = {
    let ArgTest = class(fields: (x: int))
    let foo = (ArgTest.new)(x: "not an int")
}

#let test-self-recursive() = {
    let self_recursive_construct_test = class(
        fields: (x: int),
        methods: (
            add_one: self => {
                (self.meta.cls.new)(x: self.x + 1)
            },
        ),
    )
    assert.eq(((self_recursive_construct_test.new)(x: 3).add_one)().x, 4)
}

#let test-mutually-recursive-methods() = {
    let mutally_recursive_methods_test = class(
        fields: (x: int),
        methods: (
            baz: (self, x) => {
                (self.bar)(x)
            },
            bar: (self, x) => {
                if x == 0 {
                    5
                } else {
                    (self.baz)(x - 1)
                }
            },
        ),
    )
    assert.eq(((mutally_recursive_methods_test.new)(x: 3).baz)(4), 5)
}

#let test-tag() = {
    let Foo1 = class()
    let Foo2 = class()
    let Foo3 = class(tag: () => {})
    let Foo4 = class(tag: () => {})
    assert.eq(Foo1, Foo2)
    assert.ne(Foo3, Foo4)

    let foo1 = (Foo1.new)()
    let foo2 = (Foo2.new)()
    let foo3 = (Foo3.new)()
    let foo4 = (Foo4.new)()
    assert.eq(foo1, foo2)
    assert.ne(foo3, foo4)
}

#let test-unsugared-ns() = {
    let basic_ns_test = class(
        methods: (
            Foo: ns => class(
                name: "Foo",
                fields: (x: int),
                methods: (
                    to_bar: self => ((ns.Bar)().new)(y: self.x),
                ),
            ),
            Bar: ns => class(
                name: "Bar",
                fields: (y: int),
                methods: (
                    to_foo: self => ((ns.Foo)().new)(x: self.y),
                ),
            ),
        ),
    )
    let foo = (((basic_ns_test.new)().Foo)().new)(x: 3)
    assert.eq(foo.meta.repr, "Foo(x: 3, to_bar: (..) => ..)")
    assert.eq((foo.to_bar)().meta.repr, "Bar(y: 3, to_foo: (..) => ..)")

    let bar = (((basic_ns_test.new)().Bar)().new)(y: 2)
    assert.eq(bar.meta.repr, "Bar(y: 2, to_foo: (..) => ..)")
    assert.eq((bar.to_foo)().meta.repr, "Foo(x: 2, to_bar: (..) => ..)")
}

#let test-pattern-match-instances() = {
    let Foo = class(fields: (x: int))
    let Bar1 = class(fields: (y: int), tag: () => {})
    let Bar2 = class(fields: (y: int), tag: () => {})
    let Bar3 = class(fields: (y: int))

    let x = (Foo.new)(x: 3)
    let y1 = (Bar1.new)(y: 4)
    let y2 = (Bar2.new)(y: 4)
    let y3 = (Bar3.new)(y: 4)

    assert(matches(Foo, x))
    assert(not matches(Bar1, x))
    assert(not matches(Bar2, x))
    assert(not matches(Bar3, x))

    assert(not matches(Foo, y1))
    assert(matches(Bar1, y1))
    assert(not matches(Bar2, y1))
    assert(not matches(Bar3, y1))

    assert(not matches(Foo, y2))
    assert(not matches(Bar1, y2))
    assert(matches(Bar2, y2))
    assert(not matches(Bar3, y2))

    assert(not matches(Foo, y3))
    assert(not matches(Bar1, y3))
    assert(not matches(Bar2, y3))
    assert(matches(Bar3, y3))

    // Identical classes
    let bar4 = class(fields: (y: int))
    assert(matches(bar4, y3))
}

#let test-pattern-match-class-object() = {
    assert(matches(Class, class()))
    assert(matches(Class, class(name: "hi")))
    assert(matches(Class, class(fields: (x: int))))
    assert(not matches(Class, 4.0))
    assert(not matches(Class, (name: "hi")))
}
