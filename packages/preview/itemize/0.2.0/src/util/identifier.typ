/// Unique identifier
#let enum-label-ID = "__cdl_enum-label-ID__"
#let enum-resume-ID = "__cdl_enum-resume-ID__"
#let list-ID = "__cdl-list-ID__"
#let auto-label-ID = "__cdl_auto-label-end__"

#let Unique-CDL-Meta = "__Unique-CDL-Meta__"

#let global-setting-ID-auto-label-width = "__cdl_global-setting-ID-auto-label-width__"
#let global-setting-ID-auto-resuming = "__cdl_global-setting-ID-auto-resuming__"



/// for label
#let label-number-ID-label = label("___cdl-label-number-ID-label___")

/// for body
#let style-body-format-label = label("__cdl-style-body-format-label__")

/// for native format body
#let style-body-native-format-label = label("__cdl-style-body-native-format-label__")

/// Mark the last element in the array for cyclic usage. I.e., for `array` parameters, if the last element of the array is `LOOP`, then the values in the array will be used cyclically.
#let LOOP = _ => none
