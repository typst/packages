// =====================================================
// TEMPLATER - Main entry point for all templates
// =====================================================
// This file re-exports everything from each module's mod.typ.
// Each mod.typ resolves theming from the document configuration
// state (set by #show: noteworthy.with(...) - see core/init.typ).

#import "core/setup.typ": *
#import "core/scheme.typ": *
#import "core/init.typ": noteworthy
#import "core/book.typ": *

// =====================================================
// MODULE IMPORTS
// =====================================================
#import "core/imports.typ": *
