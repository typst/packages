#import "state.typ": available-langs, current-lang-stack, default-lang, is-strict-mode-enabled, stored-translations

// CORE FUNCTIONS

#let configure-translations = (
  translations,
  namespace: "default",
  strict: false,
  default: none,
) => {
  stored-translations.update(t => (..t, (namespace): translations))
  default-lang.update(d => (..d, (namespace): default))
  is-strict-mode-enabled.update(s => if strict == none or type(strict) != bool { return s } else { return strict })
  available-langs.update(l => (..l, (namespace): translations.keys()))
  current-lang-stack.update(c => {
    if c == none {
      (default)
    } else {
      c
    }
  })
}

#let push-lang = lang => {
  context {
    current-lang-stack.update(c => {
      (
        lang,
        ..c,
      )
    })
  }
}

#let pop-lang = () => {
  context {
    assert(current-lang-stack.get().len() > 0, message: "There was no language left to pop.")

    current-lang-stack.update(c => {
      c.slice(1)
    })
  }
}

// ALIASES

#let set-lang = push-lang
#let select-lang = push-lang
#let push-language = push-lang
#let set-language = push-lang
#let select-language = push-lang

#let restore-lang = pop-lang
#let pop-language = pop-lang
#let restore-language = pop-lang
