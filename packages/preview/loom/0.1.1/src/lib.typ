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
#import "public/factory.typ"
#import "public/core.typ"

// --- DATA MODEL ---
#import "public/frame.typ"
#import "public/path.typ"
#import "public/primitives.typ"

// --- UTILITIES ---
#import "public/query.typ"
#import "public/guards.typ"
#import "public/mutator.typ"
#import "public/matcher.typ"
#import "public/collection.typ"

/// The primary entry point for creating a Loom instance.
///
/// # Example
/// ```typ
/// #import "@preview/loom:0.1.1": construct-loom
/// #let loom = construct-loom(<my-project>)
/// ```
///
/// -> dictionary
#let construct-loom = factory.construct
