#import "./match.typ": case, match, matches, Pattern, Union
#import "./format.typ": panic-fmt
#import "./classes.typ": Class, Int, class

/// An enumeration over different classes.
///
/// *Example:*
///
/// ```typst
/// #let Shape = enumeration(
///     Rectangle: class(fields: (height: Int, width: Int)),
///     Circle: class(fields: (radius: Int)),
/// )
///
/// #let area(x) = {
///     match(x,
///         case(Shape.Rectangle, ()=>{
///             x.height * x.width
///         }),
///         case(Shape.Circle, ()=>{
///             calc.pi * calc.pow(x.radius, 2)
///         }),
///     )
/// }
///
/// #let circ = (Shape.Circle.new)(radius: 3)
/// #let area_circ = area(circ)
/// ```
///
/// **Returns:**
///
/// A new enumeration (which is basically just a namespace of classes).
///
/// **Arguments:**
///
/// - items (arguments): any number of named classes.
#let enumeration(..items) = {
    if items.pos().len() != 0 {
        panic-fmt("`enumeration` should not be called with positional arguments. Got {}.", repr(items.pos().len()))
    }
    for (key, value) in items.named().pairs() {
        if not matches(Class, value) {
            panic-fmt("Every value in an `enumeration` must be a `class`.")
        }
    }
    if items.named().values().dedup().len() != items.named().len() {
        panic(
            "Got duplicate entries in the enumeration. Consider adding tags: `class(..., tag: ()=>{})`. This "
                + "exploits a trick in which all anonymous functions are distinct from each other, so it offers a way "
                + "to distinguish structurally-identical classes.",
        )
    }
    // Adding on `Union` (=merging dictionaries) makes enums valid as patterns, and in particular valid as field types
    // for `class`es.
    items.named() + Union(..items.named().values())
}

#let test-pattern-match() = {
    let Shape = enumeration(
        Rectangle: class(fields: (height: Int, width: Int)),
        Circle: class(fields: (radius: Int)),
    )
    let area(x) = {
        match(
            x,
            case(Shape.Rectangle, () => {
                x.height * x.width
            }),
            case(Shape.Circle, () => {
                // Good approximation to pi. :D
                // (Better for testing correctness below.)
                3 * calc.pow(x.radius, 2)
            }),
        )
    }
    assert.eq(area((Shape.Rectangle.new)(height: 3, width: 2)), 6)
    assert.eq(area((Shape.Circle.new)(radius: 4)), 48)
}

#let panic-on-not-class() = {
    enumeration(foo: 3)
}

#let panic-on-equal-classes() = {
    enumeration(foo: class(), bar: class())
}

#let test-no-panic-on-tagged-classes() = {
    enumeration(foo: class(tag: () => {}), bar: class(tag: () => {}))
}

#let test-enum-is-pattern() = {
    let MyEnum = enumeration(
        Foo: class(name: "Foo"),
        Bar: class(name: "Bar"),
    )
    assert(matches(Pattern, MyEnum))
    assert(matches(Pattern, MyEnum.Foo))
    assert(matches(Pattern, MyEnum.Bar))
}

#let test-enum-is-valid-annotation() = {
    let MyEnum = enumeration(
        Foo: class(name: "Foo"),
        Bar: class(name: "Bar"),
    )
    let Bar = class(fields: (foo: MyEnum))
    let bar = (Bar.new)(foo: (MyEnum.Foo.new)())
}

#let panic-on-invalid-arg-with-enum-annotation1() = {
    let MyEnum = enumeration(
        Foo: class(name: "Foo"),
        Bar: class(name: "Bar"),
    )
    let Bar = class(fields: (foo: MyEnum))
    let bar = (Bar.new)(foo: 3)
}

#let panic-on-invalid-arg-with-enum-annotation2() = {
    let MyEnum = enumeration(
        Foo: class(name: "Foo"),
        Bar: class(name: "Bar"),
    )
    let Bar = class(fields: (foo: MyEnum))
    let bar = (Bar.new)(foo: MyEnum)
}
