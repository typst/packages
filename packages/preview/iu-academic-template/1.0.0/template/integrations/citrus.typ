/*
 * ============================================================
 * CITRUS INTEGRATION
 * ============================================================
 *
 * Central adapter for the Citrus citation engine.
 *
 * Uses the locally vendored Citrus 0.2.1 implementation
 * with the CSL-JSON issue/article-number fix (PR #10).
 *
 * All template modules should import Citrus through
 * this adapter instead of accessing the vendor directory.
 *
 * Uses a locally patched Citrus implementation.
 * See vendor/citrus/UPSTREAM.md for details.
 * ============================================================
 */

// ------------------------------------------------------------
// External dependency
// ------------------------------------------------------------

#import "../../vendor/citrus/lib.typ" as citrus


// ------------------------------------------------------------
// Initialization
// ------------------------------------------------------------

#let init-csl = citrus.init-csl
#let init-csl-json = citrus.init-csl-json


// ------------------------------------------------------------
// Bibliography
// ------------------------------------------------------------

#let csl-bibliography = citrus.csl-bibliography
#let get-cited-entries = citrus.get-cited-entries


// ------------------------------------------------------------
// Citations
// ------------------------------------------------------------

#let locator = citrus.locator
#let multicite = citrus.multicite
#let nocite = citrus.nocite
