

#import "html.typ": *
#import "@preview/shiroa:0.3.1": plain-text, templates
#import templates: get-label-disambiguator, label-disambiguator, make-unique-label, static-heading-link

#let has-toc = true;
#let search-enabled = true;
// todo
#let search-js = false;
#let is-debug = false

#let dyn-svg-support = dyn-svg-support.with(is-debug: is-debug)
#let shiroa-asset-file = shiroa-asset-file.with(is-debug: is-debug)
