/// Like the built-in `counter`, but without risk of using the same string twice.
///
/// Usage is
/// ```typst
/// #let counter1 = safecounter(()=>{})
/// #let counter2 = safecounter(()=>{})
/// // ...
/// ```
/// This relies on the fact that every anonymous function is a unique object, and we can use this to build a unique key
/// for creating the counter. Note that you cannot wrap this into a `let safecounter2() = {safecounter(()=>{})}` because
/// we need it to be a *different* anonymous function each time.
///
/// *Returns:*
///
/// A `counter(...)`.
///
/// *Arguments:*
///
/// - symbol (function): this should be a `()=>{}`.
#let safe-counter(symbol) = {
    counter(heading.where(level: symbol))
}

#let test-basic() = {
    let c1 = safe-counter(() => {})
    let c2 = safe-counter(() => {})
    context {
        assert.eq(c1.get().at(0), 0)
        assert.eq(c2.get().at(0), 0)
    }
    c1.step()
    context {
        assert.eq(c1.get().at(0), 1)
        assert.eq(c2.get().at(0), 0)
    }
    c2.step()
    context {
        assert.eq(c1.get().at(0), 1)
        assert.eq(c2.get().at(0), 1)
    }
}

// This trick is used in `tree-counters`.
#let test-undocumented-sneaky-trick() = {
    let symbol = ()=>{}
    let c1 = safe-counter((1, symbol))
    let c2 = safe-counter((2, symbol))
    let c1-again = safe-counter((1, symbol))
    context {
        assert.eq(c1.get().at(0), 0)
        assert.eq(c2.get().at(0), 0)
        assert.eq(c1-again.get().at(0), 0)
    }
    c1.step()
    context {
        assert.eq(c1.get().at(0), 1)
        assert.eq(c2.get().at(0), 0)
        assert.eq(c1-again.get().at(0), 1)
    }
    c2.step()
    context {
        assert.eq(c1.get().at(0), 1)
        assert.eq(c2.get().at(0), 1)
        assert.eq(c1-again.get().at(0), 1)
    }
}

#test-basic()
#test-undocumented-sneaky-trick()
