#import "@preview/mantys:0.1.1": *
#import "@preview/tidy:0.2.0": *

#show: mantys.with(
  name: "Link-Style Manual",
  version: "0.1.0",
  authors: ("Lennart Schuster",),
  examples-scope: none,
  license: "MIT",
  description: "This packages provides helpers for styling link.",
  repository: "https://github.com/indicatelovelace/link-style",
  title: "Link-Style",
  subtitle: "Manual",
  date: datetime.today(),
  abstract: [
    Link Style solves the problem of styling different types of links which are not directly selectable as subelements. This includes Phone Numbers, Mail Addresses and URLs.
  ],
  examples: none,
)

== About

A common use case for this package is styling emails, phone addresses, document links and internet links differently. Another one is styling different websites differenty. This is particular useful for replacing links to common platforms with icons (Github, LinkedIn, etc.).

== Usage
To use this package, first you have to put
#codesnippet[```typ
#show: make-ref
	...
```]
in your document.
You can add styling rules:
#codesnippet(```typ
// Shows strict mails strong
#update-link-style(key: mailto-strict, value: strong)

// Replace mails with emoji
#update-link-style(key: mailto, value: it => [#emoji.mail])
```)
Styling rules consist of a key and a value. The key is a regex or a string to match an expression. You can find helpers for common link formats in @h2:api. The value is a function that takes and returns content, just like you would use a closure in a common show rule. \
Care that the order of the rules is of importance. This is the order in which the matchers are applied. Therefor in the above example, valid mail addresses would be styled bold. Other ```typ mailto:``` links would be shown as #emoji.mail. Inserting the same regex again will replace the rule. \
In order to effectively use the order of the rules, you can also insert before or after an element. Care that you need to match the key:
#codesnippet(```typ
// Shows strict mails strong
#update-link-style(key: l-url(base: "typst.org", value: strong)
#update-link-style(key: l-url(base: "typst.org/docs", before: l-url(base: "typst.org"), value: emph)
```)
Now the docs page will be emph, instead of strong.

You can also remove a rule:
#codesnippet(```typ
#remove-link-style(key: mailto-strict)
```)
Now for every mail, that was matched by `mailto-strict` before would now be matched my `mailto`.

#pagebreak(weak: true)
== API reference <h2:api>

#let show-module(name, scope: (:), outlined: true) = tidy-module(read(name), name: name, show-outline: outlined, include-examples-scope: false, extract-headings: 0, tidy: none)
#show-module("../bib.typ")