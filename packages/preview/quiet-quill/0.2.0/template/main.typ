// SPDX-License-Identifier: MIT-0
#import "@preview/quiet-quill:0.2.0": dissertation
#import "config.typ": config, abstract, acknowledgements, declaration, abbreviations, symbols, glossary

#show: dissertation.with(
  config: config,
  abstract: abstract,
  acknowledgements: acknowledgements,
  declaration: declaration,
  abbreviations: abbreviations,
  symbols: symbols,
  glossary: glossary,
  appendices: include "appendix.typ",
)

#include "chapters/introduction.typ"
#include "chapters/methodology.typ"
#include "chapters/conclusion.typ"
