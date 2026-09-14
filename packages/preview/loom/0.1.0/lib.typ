/*
 * ----------------------------------------------------------------------------
 * Project: Loom
 * File:    lib.typ
 * Author:  Leonie Juna Ziechmann
 * Created: 2026-01-04
 * License: MIT
 * ----------------------------------------------------------------------------
 * Copyright (c) 2026 Leonie Juna Ziechmann. All rights reserved.
 * ----------------------------------------------------------------------------
 * Description:
 * The public entry point for the Loom package.
 * Exports the constructor and utility modules for building and managing
 * component trees.
 * ----------------------------------------------------------------------------
 */

// --- CORE ENGINE ---
#import "src/public/factory.typ"
#import "src/public/core.typ"

// --- DATA MODEL ---
#import "src/public/frame.typ"
#import "src/public/path.typ"
#import "src/public/primitives.typ"

// --- UTILITIES ---
#import "src/public/query.typ"
#import "src/public/guards.typ"
#import "src/public/mutator.typ"
#import "src/public/matcher.typ"
#import "src/public/collection.typ"

/// The primary entry point for creating a Loom instance.
///
/// # Example
/// ```typ
/// #import "@preview/loom:0.1.0": construct-loom
/// #let loom = construct-loom(<my-project>)
/// ```
///
/// -> dictionary
#let construct-loom = factory.construct
