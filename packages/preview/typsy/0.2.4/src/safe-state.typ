#import "./classes.typ": class
#import "./match.typ": Any, Function

#let _underlying-safe-state = state("--typsy-sentinel-very-secret-state-string", ())
#let _at(self, iterator) = {
    // Yay, O(n) lookup! Oh well, I don't see a way around around this. Fortunate that Typst has ubiquitous caching.
    for (key, val) in iterator {
        if key == self.symbol {
            return val
        }
    }
    self.default
}
#let _state-cls = class(
    fields: (symbol: Function, default: Any),
    methods: (
        at: (self, loc) => {
            _at(self, _underlying-safe-state.at(loc))
        },
        final: self => {
            _at(self, _underlying-safe-state.final())
        },
        get: self => {
            _at(self, _underlying-safe-state.get())
        },
        update: (self, value) => context {
            let new = ()
            let found = false
            for (key, val) in _underlying-safe-state.at(here()) {
                if key == self.symbol {
                    new.push((key, value))
                    found = true
                } else {
                    new.push((key, val))
                }
            }
            if not found {
                new.push((self.symbol, value))
            }
            _underlying-safe-state.update(new)
        },
    ),
)

/// Like the built-in `state`, but without risk of using the same string twice.
///
/// Usage is
/// ```typst
/// #let state1 = safe-state(()=>{}, "some default value")
/// #let state2 = safe-state(()=>{}, "another default value")
/// // ...
/// ```
/// This relies on the fact that every anonymous function is a unique object, and we can use this to build a unique key
/// for creating the state. Note that you cannot wrap this into a `let safe-state2() = {safe-state(()=>{})}` because
/// we need it to be a *different* anonymous function each time.
///
/// *Methods:*
///
/// It provides the following of the usual `state` methods. In every case note that they must be surrounded with an
/// extra pair of brackets, due to Typst limitations.
///
/// - `(self.at)(loc)`: as the usual `state.at`.
/// - `(self.final)()`: as the usual `state.final`.
/// - `(self.get)()`: as the usual `state.get`.
/// - `(self.update)(value)`: as the usual `state.update`.
///
/// *Returns:*
///
/// A `state(...)`.
///
/// *Arguments:*
///
/// - symbol (function): this should be a `()=>{}`.
/// - default (any): the default value of the state.
#let safe-state(symbol, default) = { (_state-cls.new)(symbol: symbol, default: default) }


#let test-safe-state() = context {
    let x = safe-state(()=>{}, 1)
    let y = safe-state(()=>{}, "hello")
    let loc = here()
    context {
        assert.eq((x.final)(), 9)
        assert.eq((y.final)(), selector(heading))
        assert.eq((x.get)(), 1)
        assert.eq((y.get)(), "hello")
    }

    (x.update)("foo")
    context {
        assert.eq((x.get)(), "foo")
        assert.eq((y.get)(), "hello")
    }
    (y.update)(none)
    context {
        assert.eq((x.get)(), "foo")
        assert.eq((y.get)(), none)
    }

    (x.update)(9)
    context {
        assert.eq((x.get)(), 9)
        assert.eq((y.get)(), none)
    }
    (y.update)(selector(heading))
    context {
        assert.eq((x.at)(loc), 1)
        assert.eq((y.at)(loc), "hello")
        assert.eq((x.get)(), 9)
        assert.eq((y.get)(), selector(heading))
    }
}
#test-safe-state()


#let test-regular-state-for-comparison() = context {
    let x = state("--typsy-test-sentinel-string1", 1)
    let y = state("--typsy-test-sentinel-string2", "hello")
    let loc = here()
    context {
        assert.eq(x.final(), 9)
        assert.eq(y.final(), selector(heading))
        assert.eq(x.get(), 1)
        assert.eq(y.get(), "hello")
    }

    x.update("foo")
    context {
        assert.eq(x.get(), "foo")
        assert.eq(y.get(), "hello")
    }
    y.update(none)
    context {
        assert.eq(x.get(), "foo")
        assert.eq(y.get(), none)
    }

    x.update(9)
    context {
        assert.eq(x.get(), 9)
        assert.eq(y.get(), none)
    }
    y.update(selector(heading))
    context {
        assert.eq(x.at(loc), 1)
        assert.eq(y.at(loc), "hello")
        assert.eq(x.get(), 9)
        assert.eq(y.get(), selector(heading))
    }
}
#test-regular-state-for-comparison()
