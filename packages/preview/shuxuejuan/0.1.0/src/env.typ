#let env = state(
  "env",
  (
    qst-align-number: none,
    // Bug appears when modifying qst-number-level2 else where
    // qst-number-level2: none, // none for default(start from 1 every time after a level1 qst), auto for continuous level2 numbering
    ref-style: auto,
    equ-spacing: .1em,
    opt-columns-max: 4,
  ),
)
#let envChk(key) = {
  if not env.get().keys().contains(key) {
    panic("No '" + key + "' in env.")
  }
}
#let envGet(key, default: auto) = {
  envChk(key)
  return env.get().at(key, default: default)
}
#let envCopy(dict) = {
  let _dict = (:)
  for i in dict {
    _dict.insert(i.at(0), envGet(i.at(0)))
  }
  return _dict
}
#let _envUpd(key, val) = context {
  envChk(key)
  let newEnv = env.get()
  newEnv.at(key) = val
  env.update(newEnv)
}
#let envUpd(..dict) = {
  let _dict = dict.named()
  for i in _dict {
    _envUpd(i.at(0), i.at(1))
  }
}
#let withEnv(..dict, body) = context {
  let envOld = envCopy(dict.named())
  envUpd(..dict)
  body
  envUpd(..envOld)
}

#let idQuestion = counter("question-id")
#let counterQuestionL2 = counter("counter-question-level2")
