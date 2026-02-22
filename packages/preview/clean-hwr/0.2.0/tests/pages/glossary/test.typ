#import "@preview/glossarium:0.5.10": make-glossary, register-glossary

#import "/pages/glossary.typ": _render-glossary

#include "/tests/helper/set-l10n-db.typ"

#let glossary = (
  entries: (
    (
      key: "quantum_superposition",
      short: "Superposition",
      long: "Quantum Superposition",
      description: "A fundamental principle of quantum mechanics where a particle can exist in multiple states simultaneously.",
    ),
  ),
)

#show: make-glossary
#register-glossary(glossary.entries)

#_render-glossary(glossary: glossary)

#_render-glossary(glossary: (title: "Custom title glossary", ..glossary, disable-back-references: true))
