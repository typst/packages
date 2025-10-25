#let env = state(
  "env",
  (
    qst-align-number: none,
    ref-style: auto,
    equ-spacing: .1em,
    opt-columns-max: 4,
  ),
)
#let env-check(key) = {
  if not env.get().keys().contains(key) {
    panic("No '" + key + "' in env.")
  }
}
#let env-get(key, default: auto) = {
  env-check(key)
  return env.get().at(key, default: default)
}
#let env-copy(dict) = {
  return dict.keys().map(k => (k, env-get(k))).to-dict()
}
#let _env-upd(key, val) = {
  env-check(key)
  let env-new = env.get()
  env-new.at(key) = val
  env.update(env-new)
}
#let env-upd(..dict) = {
  let _dict = dict.named()
  for i in _dict {
    _env-upd(i.at(0), i.at(1))
  }
}
#let with-env(..dict, body) = context {
  let env-old = env-copy(dict.named())
  env-upd(..dict)
  body
  env-upd(..env-old)
}

#let id-question = counter("question-id")
#let counter-question-l2 = counter("counter-question-level2")
