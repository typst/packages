// xmlit: Generate XML documents using Typst syntax.
//
// This file only re-exports the package's public API. Implementations live in
// per-feature modules:
//
//   * elem/elem.typ                    — author XML trees with Typst syntax:
//                                        tag functions (`make-tag`, `make-tags`,
//                                        `elem`) usable positionally, in code
//                                        blocks, and in markup bodies; the
//                                        content walker (`content-to-children`,
//                                        `convert`) with its configurable
//                                        `default-handlers` table.
//   * xml-to-string/xml-to-string.typ — serialize node trees to an XML string:
//                                        authored trees as well as faithful
//                                        re-serialization of the output of
//                                        Typst's built-in `xml()` reader.
//   * xml-to-string/make-tag.typ       — `to-xml`, a minimal serializer for
//                                        plain node dictionaries.
//   * relaxng/relaxng.typ              — `create-from-relaxng`: derive tag
//                                        functions from a RELAX NG grammar
//                                        (compact syntax) and validate the
//                                        composed document via a WASM plugin.

#import "elem/elem.typ": default-handlers, convert, content-to-children, make-tag, make-tags, elem
#import "relaxng/relaxng.typ": create-from-relaxng
#import "xml-to-string/xml-to-string.typ": esc-text, esc-attr, xml-to-string
#import "xml-to-string/make-tag.typ": xml-escape, to-xml
