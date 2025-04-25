//! The `shiroa` package has three parts.
//!
//! 1. Metadata variables and functions.
//!   - `target`
//!   - `page-width`
//!   - `is-web-target`
//!   - `is-pdf-target`
//!   - `book-sys`
//!
//! 2. Components to read or write book.typ
//!   - `book`
//!   - `book-meta`
//!   - `build-meta`
//!   - `chapter`
//!   - `prefix-chapter`
//!   - `suffix-chapter`
//!   - `divider`
//!   - `external-book`
//!
//! 3. Typst Supports
//!   - `cross-link`
//!   - `plain-text`
//!   - `media`

// Part I: Metadata variables and functions
#import "meta-and-state.typ": *

// Part II: Components to read or write book.typ
#import "summary.typ": *

// Part III: Supports
#import "supports-link.typ" as link-support: cross-link
#import "supports-text.typ" as text-support: plain-text
#import "media.typ"
#import "utils.typ": get-book-meta, get-build-meta

// Part IV: Templates, todo: move me to a new package
#import "templates.typ"
