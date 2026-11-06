#import "record.typ": impl_record, record
#import "uid.typ": namespaces, uid

// Just prevent user from using names used in this library is ok....

#let _ns_state = uid(namespaces.oid, "70c5f11c-7b79-4e76-b581-b78cb430c26c")
#let _state_uid(name) = uid(_ns_state, name)

#let _state = record(
  sym: str,
)

#let _mkstate(sym, init) = {
  let sym = _state_uid(sym)

  let _s = state(sym, init)

  let s_state = impl_record(
    _state,
    get: self => {
      _s.get()
    },
    at: (self, lab) => {
      _s.at(lab)
    },
    final: self => {
      _s.final()
    },
    update: (self, var) => {
      _s.update(
        var,
      )
    },
  )

  (s_state.new)(sym: sym)
}
