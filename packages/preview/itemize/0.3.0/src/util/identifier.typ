#import "version.typ": package-version

/// Unique identifier
#let enum-label-ID = "__cdl_enum-label-ID__" + package-version
// #let tag-label-ID = "__cdl_tag-label-ID__" + package-version
#let enum-resume-ID = "__cdl_enum-resume-ID__" + package-version
#let item-label-ID = "__cdl-item-label-ID__" + package-version
#let auto-label-ID = "__cdl_auto-label-end__" + package-version

#let global-auto-label-ID = "__cdl_global-auto-label-end__" + package-version // ver0.3.0

// #let Unique-CDL-Meta = "__Unique-CDL-Meta__" + package-version

/// Mark the last element in the array for cyclic usage. I.e., for `array` parameters, if the last element of the array is `LOOP`, then the values in the array will be used cyclically.
#let LOOP = _ => none


// ver0.3.0

#let el-baseline-label = label("__cdl-baseline-label__" + package-version)

/// Prevent recursion flag
#let prevent-recursion-ID = "__cdl_prevent-recursion-ID__" + package-version
#let prevent-recursion-meta = metadata(prevent-recursion-ID)

/// Prevent recursion label
///
/// Add this label to `enum` or `list` to prevent `itemize` to process.
///
/// - Usage:
///   ```
///   #enum(
///     enum.item([#lorem(2)]),
///     // other items
///   )#el.itemize-prevent-label
///   ```
#let prevent-recursion-label = label("__cdl_itemize_prevent-label__")

/// label for term (on the same line)
#let same-line-next-term-ID = label("__cdl_same-line-next-term-ID__" + package-version)

/// label for enum or list (on the same line)
#let same-line-next-elem-ID(elem) = label("__cdl_same-line-next" + elem + "-ID-for-inline__" + package-version)

/// for tight mode
#let paragraph-ID = label("__cdl-is-paragraph-ID__" + package-version)
