#import "./classes.typ": class
#import "./format.typ": fmt, panic-fmt
#import "./match.typ": Arguments, Counter, Function, Int, Literal, Str, Union, matches
#import "./safe-counters.typ": safe-counter
#import "./typecheck.typ": typecheck

#let _check_update(value) = {
    let error_msg = "`The `value` in `(counter.update)(value)` must either be an `int`, or a function `int -> int`."
    if not (int, function).contains(type(value)) {panic-fmt(error_msg)}
    if type(value) == function {value = typecheck(Arguments(Int), Int, value, invalid-return: (_, _) => error_msg)}
    value
}

#let TreeCounter = class(
    name: "TreeCounter",
    fields: (
        display: function, /*self->str*/
        get: function, /*self->array<int>*/
        step: function, /*self->content*/
        update: function, /*(self, union<int, function<int -> int>>)->content*/
    ),
    methods: (
        subcounter: (self, symbol /*function*/, numbering: ".1") => /*Counter*/ {
            let get_raw_counter() = {
                let parent_index = (self.get)().map(str).join(".")
                // This is a sneaky undocumented (but tested) usage of `safe-counter`.
                safe-counter((parent_index, symbol))
            }
            let display(_) = {
                (self.display)() + get_raw_counter().display(numbering)
            }
            let get(_) = (self.get)() + get_raw_counter().get()
            // `step` needs `context` as it needs to resolve its parent counter via `parent.get()`.
            let step(_) = context get_raw_counter().step()
            let update(_, value) = get_raw_counter().update(_check_update(value))
            (self.meta.cls.new)(display: display, get: get, step: step, update: update)
        },
        take: self => /*content*/ {
            (self.step)()
            context (self.display)()
        },
    ),
)

/// - raw_counter (counter):
/// - level (int):
/// - get_numbering (function): ()->union(str,function)
#let _tree-counter(raw_counter, level, get_numbering) = {
    let display = self => numbering(get_numbering(), ..(self.get)())
    let get(self) = {
        let raw_get = raw_counter.get()
        let diff = level - raw_get.len()
        if diff <= 0 {
            raw_get.slice(0, level)
        } else {
            raw_get + (0,) * diff
        }
    }
    let step = self => raw_counter.step(level: level)
    let update(self, value) = {
        raw_counter.update(_check_update(value))
    }
    (TreeCounter.new)(display: display, get: get, step: step, update: update)
}

#let _default-numbering = "1.1"

/// Creates the root node of a tree-of-counters. Subcounters are then created using its `.subcounter` method.
///
/// *Example:*
///
/// ```typst
/// #let heading-counter = tree-counter(heading, level: 1)
/// #let theorem-counter = (heading-counter.subcounter)(()=>{}, numbering: ".A")
/// #(heading-counter.step)()
/// #(theorem-counter.step)()
/// #(theorem-counter.step)()
/// #context assert.eq((theorem-counter.display)(), "1.B")
/// ```
///
/// *Constructors:*
///
/// This can be called in a few distinct ways, corresponding to the following call signatures:
///
/// 1. To create a brand-new counter: `tree-counter(()=>{})`
///     - with non-default numbering: `tree-counter(()=>{}, numbering: "A.")`.
/// 2. Track an existing counter at some level: `tree-counter(some-counter, level: )`
///     - with non-default numbering: `tree-counter(some-counter, level: , numbering: "A.")`.
/// 3. To track the `heading` counter at some level: `tree-counter(heading, level: )`.
/// 4. To track the `page` counter: `tree-counter(page)`.
///
/// Notes:
///
/// - When creating a brand-new counter, then the first argument should be specifically the anonymous function
///     `()=>{}`. Like with `safe-counter`, we use the distinctness of all anonymous functions to assign a unique
///     identity to our counter.
/// - Wrapping an existing counter, or the `heading` counter, requires `level` as a mandatory keyword argument. This is
///     because tree-counters do not have a notion of `level`. Just create subcounters instead! Correspondingly when
///     wrapping an existing counter, then we must provide the level of that counter that we wish to track. (This does
///     not apply to the `page` counter, which seems to be special and is always a level-1 counter.)
/// - The `numbering` arguments should be a `str` or `function`, as per what can be passed to the builtin
///     `numbering(...)` function. This is provided at initialisation time, rather than `display` time, so that child
///     counters are not required to specify how all their parents should be `display`ed. (And we respect the existing
///     `heading.numbering` or `page.numbering` if tracking those counters.)
///
/// Examples:
///
/// 1. `tree-counter(()=>{})` to create a brand new counter.
/// 2. `tree-counter(counter("foo"), level: 1)` to track an existing counter.
/// 3. `tree-counter(heading, level: 2)` to track the heading counter (at level 2).
///
/// *Methods:*
///
/// It provides the following of the usual `counter` methods. In every case note that they must be surrounded with an
/// extra pair of brackets, due to Typst limitations.
///
/// - `(self.display)()`: as the usual `counter.display`.
///     Note that this does not take a `numbering` argument: provide this at initialisation time instead. (This is so
///     that each node in the tree can specify how it should be displayed without requiring all children to do so.)
/// - `(self.get)()`: as the usual `counter.get`.
/// - `(self.step)()`: as the usual `counter.step`.
///     Note that this does not take a `level` argument. Create a `.subcounter` instead.
/// - `(self.subcounter)(()=>{}, numbering: ".1")`: the star of the show! This creates a subcounter. The first
///     argument should be specifically `()=>{}`, in the same way as described for the main constructor. The numbering
///     is optional and used when `.display`ing the subcouter.
/// - `(self.take)()`: this is a useful shorthand for `(self.step)()` followed by `(self.display)()`.
/// - `(self.update)(value)`: as the usual `counter.update`.
///
/// We intentionally do not provide `.at` or `.final` methods, as these are very difficult to reason about when using
/// trees of counters.
///
/// *Returns:*
///
/// A `TreeCounter` object.
///
/// *Arguments:*
///
/// As described in "Constructors' above.
#let tree-counter(..args) = {
    let pos = args.pos()
    let named = args.named()
    if matches(Arguments(Literal(heading), level: Int), args) or matches(Arguments(Literal(heading)), args) {
        // Track heading counter
        let get_numbering = () => if heading.numbering == none { _default-numbering } else { heading.numbering }
        _tree-counter(counter(heading), named.at("level", default: 1), get_numbering)
    } else if matches(Arguments(Literal(page)), args) {
        // Track page counter
        let get_numbering = () => if page.numbering == none { _default-numbering } else { page.numbering }
        _tree-counter(counter(page), 1, get_numbering)
    } else if matches(Arguments(Function), args) or matches(Arguments(Function, numbering: Union(Str, Function)), args) {
        // New counter
        let (symbol,) = pos
        let some-numbering = named.at("numbering", default: "1.1")
        _tree-counter(safe-counter(symbol), 1, () => some-numbering)
    } else if (
        matches(Arguments(Counter, level: Int), args)
            or matches(Arguments(Counter, level: Int, numbering: Union(Str, Function)), args)
    ) {
        // Track existing counter
        let (count,) = pos
        let some-numbering = named.at("numbering", default: "1.1")
        _tree-counter(count, named.at("level"), () => some-numbering)
    } else {
        panic-fmt(
            "Received invalid arguments `{}` that did not match any call signature for `tree-counter`.",
            repr(args),
        )
    }
}

#let test-new-counter() = {
    let root = tree-counter(() => {})
    context assert.eq((root.get)(), (0,))
    context assert.eq((root.display)(), "0")
    (root.step)()
    context assert.eq((root.get)(), (1,))
    context assert.eq((root.display)(), "1")
    (root.step)()
    context assert.eq((root.get)(), (2,))
    context assert.eq((root.display)(), "2")

    let subcounter1 = (root.subcounter)(() => {})
    context assert.eq((subcounter1.get)(), (2, 0))
    context assert.eq((subcounter1.display)(), "2.0")
    (subcounter1.step)()
    context assert.eq((subcounter1.get)(), (2, 1))
    context assert.eq((subcounter1.display)(), "2.1")
    (root.step)()
    context assert.eq((subcounter1.get)(), (3, 0))
    context assert.eq((subcounter1.display)(), "3.0")

    let subcounter2 = (root.subcounter)(() => {}, numbering: ".A")
    context assert.eq((subcounter2.get)(), (3, 0))
    context assert.eq((subcounter2.display)(), "3.-")
    (subcounter2.step)()
    context assert.eq((subcounter2.get)(), (3, 1))
    context assert.eq((subcounter2.display)(), "3.A")
    (root.step)()
    context assert.eq((subcounter2.get)(), (4, 0))
    context assert.eq((subcounter2.display)(), "4.-")

    (root.update)(9)
    context assert.eq((root.get)(), (9,))
    context assert.eq((subcounter2.get)(), (9, 0))
    context (subcounter2.update)(4)
    context assert.eq((subcounter2.get)(), (9, 4))
    (root.update)(x=>x+10)
    context assert.eq((root.get)(), (19,))
    context assert.eq((subcounter2.get)(), (19, 0))
    context (subcounter2.update)(x=>x+10)
    context assert.eq((subcounter2.get)(), (19, 10))
}

#let test-new-counter-with-numbering() = {
    let root = tree-counter(() => {}, numbering: "A.")
    context assert.eq((root.display)(), "-.")
    (root.step)()
    context assert.eq((root.get)(), (1,))
    context assert.eq((root.display)(), "A.")
    (root.step)()
    context assert.eq((root.get)(), (2,))
    context assert.eq((root.display)(), "B.")

    let subcounter1 = (root.subcounter)(() => {})
    context assert.eq((subcounter1.get)(), (2, 0))
    context assert.eq((subcounter1.display)(), "B..0")
    (subcounter1.step)()
    context assert.eq((subcounter1.get)(), (2, 1))
    context assert.eq((subcounter1.display)(), "B..1")
    (root.step)()
    context assert.eq((subcounter1.get)(), (3, 0))
    context assert.eq((subcounter1.display)(), "C..0")

    let subcounter2 = (root.subcounter)(() => {}, numbering: "A")
    context assert.eq((subcounter2.get)(), (3, 0))
    context assert.eq((subcounter2.display)(), "C.-")
    (subcounter2.step)()
    context assert.eq((subcounter2.get)(), (3, 1))
    context assert.eq((subcounter2.display)(), "C.A")
    (root.step)()
    context assert.eq((subcounter2.get)(), (4, 0))
    context assert.eq((subcounter2.display)(), "D.-")

    (root.update)(9)
    context assert.eq((root.get)(), (9,))
    context assert.eq((subcounter2.get)(), (9, 0))
    context (subcounter2.update)(4)
    context assert.eq((subcounter2.get)(), (9, 4))
    (root.update)(x=>x+10)
    context assert.eq((root.get)(), (19,))
    context assert.eq((subcounter2.get)(), (19, 0))
    context (subcounter2.update)(x=>x+10)
    context assert.eq((subcounter2.get)(), (19, 10))
}

#let test-wrap-counter() = {
    let root = tree-counter(safe-counter(() => {}), level: 2)
    context assert.eq((root.get)(), (0, 0))
    context assert.eq((root.display)(), "0.0")
    (root.step)()
    context assert.eq((root.get)(), (0, 1))
    context assert.eq((root.display)(), "0.1")
    (root.step)()
    context assert.eq((root.get)(), (0, 2))
    context assert.eq((root.display)(), "0.2")

    let subcounter1 = (root.subcounter)(() => {})
    context assert.eq((subcounter1.get)(), (0, 2, 0))
    context assert.eq((subcounter1.display)(), "0.2.0")
    (subcounter1.step)()
    context assert.eq((subcounter1.get)(), (0, 2, 1))
    context assert.eq((subcounter1.display)(), "0.2.1")
    (root.step)()
    context assert.eq((subcounter1.get)(), (0, 3, 0))
    context assert.eq((subcounter1.display)(), "0.3.0")

    let subcounter2 = (root.subcounter)(() => {}, numbering: ".A")
    context assert.eq((subcounter2.get)(), (0, 3, 0))
    context assert.eq((subcounter2.display)(), "0.3.-")
    (subcounter2.step)()
    context assert.eq((subcounter2.get)(), (0, 3, 1))
    context assert.eq((subcounter2.display)(), "0.3.A")
    (root.step)()
    context assert.eq((subcounter2.get)(), (0, 4, 0))
    context assert.eq((subcounter2.display)(), "0.4.-")

    (root.update)(9)
    context assert.eq((root.get)(), (9, 0))
    context assert.eq((subcounter2.get)(), (9, 0, 0))
    context (subcounter2.update)(4)
    context assert.eq((subcounter2.get)(), (9, 0, 4))
    (root.update)(x=>x+10)
    context assert.eq((root.get)(), (19, 0))
    context assert.eq((subcounter2.get)(), (19, 0, 0))
    context (subcounter2.update)(x=>x+10)
    context assert.eq((subcounter2.get)(), (19, 0, 10))
}

#let test-wrap-counter-with-numbering() = {
    let root = tree-counter(safe-counter(() => {}), numbering: "1.", level: 2)
    context assert.eq((root.get)(), (0, 0))
    context assert.eq((root.display)(), "0.0.")
    (root.step)()
    context assert.eq((root.get)(), (0, 1))
    context assert.eq((root.display)(), "0.1.")
    (root.step)()
    context assert.eq((root.get)(), (0, 2))
    context assert.eq((root.display)(), "0.2.")

    let subcounter1 = (root.subcounter)(() => {})
    context assert.eq((subcounter1.get)(), (0, 2, 0))
    context assert.eq((subcounter1.display)(), "0.2..0")
    (subcounter1.step)()
    context assert.eq((subcounter1.get)(), (0, 2, 1))
    context assert.eq((subcounter1.display)(), "0.2..1")
    (root.step)()
    context assert.eq((subcounter1.get)(), (0, 3, 0))
    context assert.eq((subcounter1.display)(), "0.3..0")

    let subcounter2 = (root.subcounter)(() => {}, numbering: "A")
    context assert.eq((subcounter2.get)(), (0, 3, 0))
    context assert.eq((subcounter2.display)(), "0.3.-")
    (subcounter2.step)()
    context assert.eq((subcounter2.get)(), (0, 3, 1))
    context assert.eq((subcounter2.display)(), "0.3.A")
    (root.step)()
    context assert.eq((subcounter2.get)(), (0, 4, 0))
    context assert.eq((subcounter2.display)(), "0.4.-")

    (root.update)(9)
    context assert.eq((root.get)(), (9, 0))
    context assert.eq((subcounter2.get)(), (9, 0, 0))
    context (subcounter2.update)(4)
    context assert.eq((subcounter2.get)(), (9, 0, 4))
    (root.update)(x=>x+10)
    context assert.eq((root.get)(), (19, 0))
    context assert.eq((subcounter2.get)(), (19, 0, 0))
    context (subcounter2.update)(x=>x+10)
    context assert.eq((subcounter2.get)(), (19, 0, 10))
}

#let test-heading-counter() = {
    counter(heading).update(0)
    // Test that we match the default numbering (when `heading.numbering = none`).
    context assert.eq(counter(heading).display(), "0")
    counter(heading).step(level: 2)
    context assert.eq(counter(heading).display(), "0.1")
    let root = tree-counter(heading, level: 3)
    context assert.eq((root.get)(), (0, 1, 0))
    context assert.eq((root.display)(), "0.1.0")
    (root.step)()
    context assert.eq((root.get)(), (0, 1, 1))
    context assert.eq((root.display)(), "0.1.1")
    (root.step)()
    // Test that we track any changes to `heading.numbering`.
    set heading(numbering: "1.A.")
    context assert.eq((root.get)(), (0, 1, 2))
    context assert.eq((root.display)(), "0.A.B.")
    // Test that we track exogeneous changes to the counter.
    counter(heading).step(level: 1)
    context assert.eq((root.get)(), (1, 0, 0))
    context assert.eq((root.display)(), "1.-.-.")

    let subcounter1 = (root.subcounter)(() => {})
    context assert.eq((subcounter1.get)(), (1, 0, 0, 0))
    context assert.eq((subcounter1.display)(), "1.-.-..0")
    (subcounter1.step)()
    context assert.eq((subcounter1.get)(), (1, 0, 0, 1))
    context assert.eq((subcounter1.display)(), "1.-.-..1")
    (root.step)()
    context assert.eq((subcounter1.get)(), (1, 0, 1, 0))
    context assert.eq((subcounter1.display)(), "1.-.A..0")

    let subcounter2 = (root.subcounter)(() => {}, numbering: ".A")
    context assert.eq((subcounter2.get)(), (1, 0, 1, 0))
    context assert.eq((subcounter2.display)(), "1.-.A..-")
    (subcounter2.step)()
    context assert.eq((subcounter2.get)(), (1, 0, 1, 1))
    context assert.eq((subcounter2.display)(), "1.-.A..A")
    (root.step)()
    context assert.eq((subcounter2.get)(), (1, 0, 2, 0))
    context assert.eq((subcounter2.display)(), "1.-.B..-")

    // Test that we track any changes to `heading.numbering`.
    set heading(numbering: "1.1")
    context assert.eq((subcounter2.display)(), "1.0.2.-")

    // Test that we track exogeneous changes to the counter.
    counter(heading).step(level: 1)
    context assert.eq((subcounter2.display)(), "2.0.0.-")

    (root.update)(9)
    context assert.eq((root.get)(), (9, 0, 0))
    context assert.eq((subcounter2.get)(), (9, 0, 0, 0))
    context (subcounter2.update)(4)
    context assert.eq((subcounter2.get)(), (9, 0, 0, 4))
    (root.update)(x=>x+10)
    context assert.eq((root.get)(), (19, 0, 0))
    context assert.eq((subcounter2.get)(), (19, 0, 0, 0))
    context (subcounter2.update)(x=>x+10)
    context assert.eq((subcounter2.get)(), (19, 0, 0, 10))
}

#let test-heading-counter-without-level() = {
    counter(heading).update(0)
    let root = tree-counter(heading)
    context assert.eq((root.get)(), (0, 1, 0))
    context assert.eq((root.display)(), "0.1.0")
    (root.step)()
    context assert.eq((root.get)(), (0, 1, 1))
    context assert.eq((root.display)(), "0.1.1")
    (root.step)()

    (root.update)(9)
    context assert.eq((root.get)(), (9,))
    (root.update)(x=>x+10)
    context assert.eq((root.get)(), (19,))
}

#let test-page-counter() = {
    counter(page).update(1)
    // Test that we match the default numbering (when `page.numbering = none`).
    context assert.eq(counter(page).display(), "1")
    counter(page).step()
    context assert.eq(counter(page).display(), "2")
    let root = tree-counter(page)
    context assert.eq((root.get)(), (2,))
    context assert.eq((root.display)(), "2")
    (root.step)()
    context assert.eq((root.get)(), (3,))
    context assert.eq((root.display)(), "3")
    (root.step)()
    // Test that we track any changes to `page.numbering`.
    set page(numbering: "A.")
    context assert.eq((root.get)(), (4,))
    context assert.eq((root.display)(), "D.")

    let subcounter1 = (root.subcounter)(() => {})
    context assert.eq((subcounter1.get)(), (4, 0))
    context assert.eq((subcounter1.display)(), "D..0")
    (subcounter1.step)()
    context assert.eq((subcounter1.get)(), (4, 1))
    context assert.eq((subcounter1.display)(), "D..1")
    (root.step)()
    context assert.eq((subcounter1.get)(), (5, 0))
    context assert.eq((subcounter1.display)(), "E..0")

    let subcounter2 = (root.subcounter)(() => {}, numbering: "A")
    context assert.eq((subcounter2.get)(), (5, 0))
    context assert.eq((subcounter2.display)(), "E.-")
    (subcounter2.step)()
    context assert.eq((subcounter2.get)(), (5, 1))
    context assert.eq((subcounter2.display)(), "E.A")
    (root.step)()
    context assert.eq((subcounter2.get)(), (6, 0))
    context assert.eq((subcounter2.display)(), "F.-")

    // Test that we track any changes to `heading.numbering`.
    set page(numbering: "1")
    context assert.eq((subcounter2.display)(), "6-")

    (root.update)(9)
    context assert.eq((root.get)(), (9,))
    context assert.eq((subcounter2.get)(), (9, 0))
    context (subcounter2.update)(4)
    context assert.eq((subcounter2.get)(), (9, 4))
    (root.update)(x=>x+10)
    context assert.eq((root.get)(), (19,))
    context assert.eq((subcounter2.get)(), (19, 0))
    context (subcounter2.update)(x=>x+10)
    context assert.eq((subcounter2.get)(), (19, 10))
}

#let test-sub-subcounter() = {
    let root = tree-counter(() => {})
    let sub1 = (root.subcounter)(() => {})
    let sub2 = (sub1.subcounter)(() => {})
    context assert.eq((sub2.get)(), (0, 0, 0))
    context assert.eq((sub2.display)(), "0.0.0")
    (root.step)()
    context assert.eq((sub2.display)(), "1.0.0")
    (sub2.step)()
    context assert.eq((sub2.display)(), "1.0.1")
    (sub1.step)()
    context assert.eq((sub2.display)(), "1.1.0")

    (root.update)(9)
    context assert.eq((root.get)(), (9,))
    context assert.eq((sub2.get)(), (9, 0, 0))
    context (sub2.update)(4)
    context assert.eq((sub2.get)(), (9, 0, 4))
    (root.update)(x=>x+10)
    context assert.eq((root.get)(), (19,))
    context assert.eq((sub2.get)(), (19, 0, 0))
    context (sub2.update)(x=>x+10)
    context assert.eq((sub2.get)(), (19, 0, 10))
}

#let test-doc() = {
    counter(heading).update(0)
    let heading-counter = tree-counter(heading, level: 1)
    let theorem-counter = (heading-counter.subcounter)(() => {}, numbering: ".A")
    (heading-counter.step)()
    (theorem-counter.step)()
    (theorem-counter.step)()
    context assert.eq((theorem-counter.display)(), "1.B")
}

#let panic-on-bad-new-counter() = {
    tree-counter(3)
}

#let panic-on-bad-new-counter-with-numbering() = {
    tree-counter(3, numbering: "A.")
}

#let panic-on-bad-wrap-counter() = {
    tree-counter(3, level: 1)
}

#let panic-on-bad-wrap-counter-with-numbering() = {
    tree-counter(3, level: 1, numbering: "A.")
}

#let panic-on-bad-keywords() = {
    tree-counter(() => {}, foo: 3)
}

// Need to include these as they include `context` asserts: https://github.com/Myriad-Dreamin/tinymist/issues/2128
#test-new-counter()
#test-new-counter-with-numbering()
#test-wrap-counter()
#test-wrap-counter-with-numbering()
#test-heading-counter()
#test-page-counter()
#test-sub-subcounter()
#test-doc()
