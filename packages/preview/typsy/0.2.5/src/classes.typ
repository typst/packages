#import "./format.typ": fmt, panic-fmt
#import "./match.typ": (
    Any, Array, Class, Dictionary, Function, Int, Literal, Pattern, Str, matches, pattern-alias, pattern-repr,
)

#let _checktype(name, value, pattern) = {
    if not matches(pattern, value) {
        panic-fmt(
            "For `{}`, expected `{}`, received `{}` of type `{}`.",
            name,
            pattern-repr(pattern),
            repr(value),
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

#let _make_cls(new, name, fields, methods, classmethods, tag) = {
    let out = (
        new: new,
        name: name,
        fields: fields,
        methods: methods,
        classmethods: classmethods,
        tag: tag,
        __typsy_sentinel_is_class: true,
    )
    for (classmethodname, classmethod) in classmethods.pairs() {
        let wrapped-classmethod(..args) = classmethod(
            _make_cls(new, name, fields, methods, classmethods, tag),
            ..args,
        )
        out.insert(classmethodname, wrapped-classmethod)
    }
    // Make it possible to use classes in pattern-matching.
    // We inspect specifically the `new` field as that should be enough to get uniqueness; in particular it closes over
    // `tag`.
    let pattern = Dictionary(meta: Dictionary(cls: Dictionary(new: Literal(new), ..Any), ..Any), ..Any)
    let pattern = if name != none {
        pattern-alias(pattern, name)
    } else {
        pattern
    }
    let cls = out + pattern
    for (key, value) in cls.pairs() {
        if key != "__typsy_sentinel_match" {
            assert(not matches(Pattern, value), message: fmt("Internal error: class key `{}` must not be a Pattern.", key))
        }
    }
    cls
}

#let _reserved = ("meta",) + _make_cls(() => none, none, (:), (:), (:), none).keys()

#let _class_or_namespace(
    name: none,
    fields: none,
    methods: none,
    classmethods: (:),
    tag: none,
    call_on_dict: none,
    unit_is_self: false,
) = {
    if name != none {
        _checktype("name", name, Str)
    }
    _checktype("fields", fields, Dictionary(..Any))
    _checktype("methods", methods, Dictionary(..Any))
    _checktype("classmethods", classmethods, Dictionary(..Any))
    let unit_is_self = unit_is_self and fields.len() == 0
    let fields_keys = fields.keys()
    let methods_keys = methods.keys()
    for (argname, pattern) in fields.pairs() {
        _checktype(argname, argname, Str)
        if type(pattern) == type {
            panic-fmt(
                "For `{}`, received a type annotation `{}`, but expected a pattern. For example, you should write `class(fields: (x: Int))` rather than `class(fields: (x: int))`. This was a breaking change between typsy:0.1.0 and typsy:0.2.0",
                argname,
                repr(pattern),
            )
        }
        _checktype(argname, pattern, Pattern)
        if methods_keys.contains(argname) {
            panic-fmt("`{}` is present in both `fields` and `methods`", argname)
        }
        if _reserved.contains(argname) {
            panic-fmt("`{}` is reserved and cannot be used in `fields`.", argname)
        }
    }
    for (methodname, method) in methods.pairs() {
        _checktype(methodname, methodname, Str)
        _checktype(methodname, method, Function)
        if _reserved.contains(methodname) {
            panic-fmt("`{}` is reserved and cannot be used in `methods`.", methodname)
        }
    }
    for (classmethodname, fn) in classmethods.pairs() {
        _checktype(classmethodname, classmethodname, Str)
        _checktype(classmethodname, fn, Function)
        if methods_keys.contains(classmethodname) {
            panic-fmt("`{}` is present in both `methods` and `classmethods`", classmethodname)
        }
        if fields_keys.contains(classmethodname) {
            panic-fmt("`{}` is present in both `fields` and `classmethods`", classmethodname)
        }
        if _reserved.contains(classmethodname) {
            panic-fmt("`{}` is reserved and cannot be used in `classmethods`.", classmethodname)
        }
    }
    let new(..init_args) = {
        if init_args.pos().len() != 0 {
            panic-fmt("Do not call type constructors with positional arguments. Got `{}`", repr(init_args.pos()))
        }

        let self_dict = (:)
        let missing_fields = fields
        for (initname, value) in init_args.named().pairs() {
            let expected = fields.at(initname, default: auto)
            if expected == auto {
                panic-fmt("Got unexpected init argument `{}`.", initname)
            }
            _checktype(initname, value, expected)
            self_dict.insert(initname, value)
            missing_fields.remove(initname)
        }
        if missing_fields.len() != 0 {
            panic-fmt("Missing fields at initialization: {}", repr(missing_fields.keys()))
        }
        for (initname, method) in methods.pairs() {
            self_dict.insert(initname, method)
        }
        let repr_pieces = ()
        if name != none {
            repr_pieces.push(name)
        }
        repr_pieces.push(repr(self_dict))
        let cls = _make_cls(new, name, fields, methods, classmethods, tag)
        let meta = (
            // Provide `cls` to allow easy self-recursion.
            // Mutual recursion should be handled by using a `namespace`.
            cls: cls,
            repr: repr_pieces.join(""),
        )
        self_dict.insert("meta", meta)
        let instance = call_on_dict(self_dict)
        if unit_is_self {
            // Unit class: the class is its own instance.
            instance + cls
        } else {
            instance
        }
    }
    let cls = _make_cls(new, name, fields, methods, classmethods, tag)
    if unit_is_self {
        // Unit class: the class is its own instance.
        (cls.new)()
    } else {
        cls
    }
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
///     fields: (x: Int),
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
/// - classmethods (dictionary): a mapping str=>function defining functions available on the class object. Each function
///     receives the class object as its first argument.
/// - tag (function): an optional place to add `class(..., tag: ()=>{})`. If not provided then all class objects with
///     the same fields and methods will compare equal. If provided then (as all anonymous functions are distinct), this
///     will make the class unique.
#let class(name: none, fields: (:), methods: (:), classmethods: (:), tag: none) = {
    _class_or_namespace(
        name: name,
        fields: fields,
        methods: methods,
        classmethods: classmethods,
        tag: tag,
        call_on_dict: _call_on_dict,
        unit_is_self: true,
    )
}

#let test-doc() = {
    let Adder = class(
        fields: (x: Int),
        methods: (
            add: (self, y) => { self.x + y },
        ),
    )
    let add_three = (Adder.new)(x: 3)
    let five = (add_three.add)(2)
    assert.eq(five, 5)
}

#let test-basic() = {
    let ArgTest = class(fields: (x: Int))
    let foo = (ArgTest.new)(x: 3)
    assert.eq(foo.x, 3)
}

#let test-classmethod() = {
    let Foo = class(
        fields: (baz: Int),
        classmethods: (from-bar: (cls, bar) => (cls.new)(baz: bar.baz)),
    )
    let foo = (Foo.from-bar)((baz: 3))
    assert.eq(foo.baz, 3)
    assert(matches(Foo, foo))
}

#let test-unit-class-classmethod() = {
    let Foo = class(classmethods: (foo: cls => 3))
    assert.eq((Foo.foo)(), 3)
    assert.eq(((Foo.new)().foo)(), 3)
}

#let panic-on-classmethod-not-function() = {
    class(classmethods: (foo: 3))
}

#let panic-on-classmethod-collides-with-field() = {
    class(fields: (foo: Int), classmethods: (foo: cls => none))
}

#let panic-on-classmethod-collides-with-method() = {
    class(methods: (foo: self => none), classmethods: (foo: cls => none))
}

#let panic-on-classmethod-is-reserved() = {
    class(classmethods: (new: cls => none))
}

#let panic-on-basic() = {
    let ArgTest = class(fields: (x: Int))
    let foo = (ArgTest.new)(x: "not an int")
}

#let panic-on-missing-field1() = {
    let MyClass = class(fields: (x: Int))
    let _ = (MyClass.new)()
}

#let panic-on-missing-field2() = {
    let MyClass = class(fields: (x: Int, y: Int))
    let _ = (MyClass.new)(x: 3)
}

#let test-self-recursive() = {
    let self_recursive_construct_test = class(
        fields: (x: Int),
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
        fields: (x: Int),
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
                fields: (x: Int),
                methods: (
                    to_bar: self => ((ns.Bar)().new)(y: self.x),
                ),
            ),
            Bar: ns => class(
                name: "Bar",
                fields: (y: Int),
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
    let Foo = class(fields: (x: Int))
    let Bar1 = class(fields: (y: Int), tag: () => {})
    let Bar2 = class(fields: (y: Int), tag: () => {})
    let Bar3 = class(fields: (y: Int))

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
    let bar4 = class(fields: (y: Int))
    assert(matches(bar4, y3))
}

#let test-pattern-match-class-object() = {
    assert(matches(Class, class()))
    assert(matches(Class, class(name: "hi")))
    assert(matches(Class, class(fields: (x: Int))))
    assert(not matches(Class, 4.0))
    assert(not matches(Class, (name: "hi")))
}

#let test-pattern-match-class-doc() = {
    let Adder = class(fields: (x: Int), methods: (foo: (self, y) => self.x + y))
    assert(matches(Class, Adder))
    let adder = (Adder.new)(x: 3)
    assert(matches(Adder, adder))
}

#let test-class-spreads-into-container-patterns() = {
    let Foo = class(name: "Foo", fields: (x: Int))
    let foo1 = (Foo.new)(x: 1)
    let foo2 = (Foo.new)(x: 1)
    assert(matches(Pattern, Array(..Foo)))
    assert(matches(Pattern, Dictionary(..Foo)))
    assert(matches(Array(..Foo), (foo1, foo2)))
    assert(matches(Dictionary(..Foo), ("one": foo1, "two": foo2)))
    assert(not matches(Array(..Foo), (foo1, foo2, 4)))
    assert(not matches(Dictionary(..Foo), ("one": foo1, "two": foo2, "three": 3)))
}

#let test-unnamed-class-is-pattern() = {
    let Foo = class()
    assert(matches(Pattern, Foo))
}

#let test-named-class-is-pattern() = {
    let Foo = class(name: "hello")
    assert(matches(Pattern, Foo))
}

#let test-class-is-valid-annotation() = {
    let Foo = class()
    let Bar = class(fields: (foo: Foo))
    let bar = (Bar.new)(foo: (Foo.new)())
}

#let panic-on-invalid-arg-with-class-annotation() = {
    let Foo = class()
    let Bar = class(fields: (foo: Foo))
    let bar = (Bar.new)(foo: 3)
}

#let test-unit-class-is-self-instance() = {
    let MyClass = class(name: "MyClass")
    let instance = (MyClass.new)()

    // The class is its own instance.
    assert.eq(instance, MyClass)

    // Pattern-matching requirements.
    assert(matches(Pattern, MyClass))
    assert(matches(Class, MyClass))
    assert(matches(MyClass, instance))
    assert(matches(MyClass, MyClass))
}

#let test-unit-class-tagged() = {
    let A = class(tag: () => {})
    let B = class(tag: () => {})
    assert.ne(A, B)
    assert(matches(A, (A.new)()))
    assert(not matches(A, (B.new)()))
    assert(not matches(B, (A.new)()))
    assert(matches(B, (B.new)()))
}

#let panic-on-unit-class-method-collides-with-class-key() = {
    class(methods: (new: (self) => "oops"))
}

#let test-unit-class-with-methods() = {
    let Greeter = class(
        name: "Greeter",
        methods: (greet: (self) => "hello"),
    )
    let g = (Greeter.new)()
    assert(matches(Pattern, Greeter))
    assert(matches(Class, Greeter))
    assert(matches(Greeter, g))
    assert(matches(Greeter, Greeter))
}

#let test-unit-class-new-is-idempotent() = {
    // Calling `new` on a unit class always returns the same thing, so
    // generic code that calls `(some_class.new)()` works with unit classes.
    let Foo = class(name: "Foo", tag: () => {})
    assert.eq(Foo, (Foo.new)())
    assert.eq(Foo, (Foo.new)())
    assert.eq((Foo.new)(), (Foo.new)())

    // Remains a valid class: `new` is still callable, fields/methods accessible.
    assert.eq(Foo.name, "Foo")
    assert.eq(Foo.fields, (:))
    assert(matches(Class, (Foo.new)()))
    assert(matches(Pattern, (Foo.new)()))
}
