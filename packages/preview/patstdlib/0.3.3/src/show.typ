/// Defines, but does not activate, a '#show: fn'.
#let show-rule(fn) = {
    (fn: fn)
}
/// Defines, but does not activate, a '#show selector: fn'.
#let show-fn-rule(selector, fn) = {
    (selector: selector, fn: fn)
}
/// Defines, but does not activate, a '#show selector: set fn(..args)'.
#let show-set-rule(selector, fn, ..args) = {
    (selector: selector, fn: fn, args: args)
}
/// Given a collection of show rules defined using `show-rule`, `show-fn-rule` and `show-set-rule`, activates all of
/// them.
/// The advantage of this over a normal `#show: ...` rule is that it allows for activating a variable/dynamically-sized
/// number of rules.
///
/// *Example Usage:*
///
/// ```typst
/// #let rules = (
///   show-set-rule(heading.where(level: 1), text, size: 5em),
///   show-fn-rule(heading.where(level: 2), it => [asdf]),
///   show-rule(it => it + it)
/// )
/// #show: activate-show-rules.with(rules)
/// 
/// = hi
/// 
/// == bye
/// ```
#let activate-show-rules(shows, doc) = {
    shows.fold(doc, (body, showrule) => {
        if "selector" not in showrule.keys() {
            show: showrule.fn
            body
        } else if "args" not in showrule.keys() {
            show showrule.selector: showrule.fn
            body
        } else {
            show showrule.selector: set showrule.fn(..showrule.args)
            body
        }
    })
}
