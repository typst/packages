#import "./classes.typ": _class_or_namespace, class
#import "./format.typ": panic-fmt

#let _call_on_dict(self_dict) = {
    let self_call(attrname) = {
        let value = self_dict.at(attrname)
        assert.eq(type(value), function)
        value(self_call)
    }
    self_call
}

/// Builds a namespace of objects that may be mutually-referential.
///
/// This ability to be mutually-referential is what distinguishes this object (and is the reason it exists) as compared
/// to just normal Typst code.
///
/// *Example:*
///
/// ```typst
/// #let ns = namespace(
///     foo: ns => {
///         let foo(x) = if x == 0 {"FOO"} else {ns("bar")(x - 1)}
///         foo
///     },
///     bar: ns => {
///         let bar(x) = if x == 0 {"BAR"} else {ns("foo")(x - 1)}
///         bar
///     },
/// )
/// #let foo = ns("foo")
/// #assert.eq(foo(3), "BAR")
/// #assert.eq(foo(4), "FOO")
/// ```
///
/// *Returns:*
///
/// The namespace object.
///
/// *Arguments:*
///
/// - objs (arguments): a collection of objects in the namespace.
#let namespace(..objs) = {
    if objs.pos().len() != 0 {
        panic-fmt("Cannot pass positional arguments to a namespace.")
    }
    (
        _class_or_namespace(
            name: "namespace",
            fields: (:),
            methods: objs.named(),
            tag: none,
            call_on_dict: _call_on_dict,
        ).new
    )()
}

#let test-ns() = {
    let ns_test = namespace(
        Foo: ns => class(
            fields: (x: int),
            methods: (
                to_bar: self => ns("foo_to_bar")(self),
            ),
        ),
        Bar: ns => class(
            fields: (y: int),
            methods: (
                to_foo: self => (ns("Foo").new)(x: self.y),
            ),
        ),
        foo_to_bar: ns => foo => { (ns("Bar").new)(y: foo.x) },
    )
    let foo = (ns_test("Foo").new)(x: 3)
    assert.eq(foo.meta.repr, "(x: 3, to_bar: (..) => ..)")
    assert.eq((foo.to_bar)().meta.repr, "(y: 3, to_foo: (..) => ..)")

    let bar = (ns_test("Bar").new)(y: 2)
    assert.eq(bar.meta.repr, "(y: 2, to_foo: (..) => ..)")
    assert.eq((bar.to_foo)().meta.repr, "(x: 2, to_bar: (..) => ..)")
}

#let test-doc() = {
    let ns = namespace(
        foo: ns => {
            let foo(x) = if x == 0 { "FOO" } else { ns("bar")(x - 1) }
            foo
        },
        bar: ns => {
            let bar(x) = if x == 0 { "BAR" } else { ns("foo")(x - 1) }
            bar
        },
    )
    let foo = ns("foo")
    assert.eq(foo(3), "BAR")
    assert.eq(foo(4), "FOO")
}
