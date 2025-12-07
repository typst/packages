

#import "html.typ": *
#import "@preview/shiroa:0.3.1": plain-text, templates
#import templates: get-label-disambiguator, label-disambiguator, make-unique-label, static-heading-link

#let has-toc = true;

#let replace-raw(it, vars: (:)) = {
  raw(
    lang: it.lang,
    {
      let body = it.text

      for (key, value) in vars.pairs() {
        body = body.replace("{{ " + key + " }}", value)
      }

      body
    },
  )
}
