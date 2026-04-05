// SPDX-License-Identifier: GPL-3.0-or-later
#import "types.typ" as testyfy_types

/// Assert that a collection is not empty.
///
/// ==== Panics
///
/// - If `value` is not a supported collection type
/// - If `value` is empty
///
/// -> none
#let nonempty(
    /// A collection of some sort.
    ///
    /// -> array | dictionary | str
    value,

    /// The human-readable name (i.e. variable name or similar) that _value_ has in the code/API.
    /// Useful to hint users towards what exactly they did wrong. If not present, a generic error
    /// message is generated.
    ///
    /// -> str
    value-name: ""
) = {
    testyfy_types.type-one-of(value, (array, dictionary, str), value-name: "value")
    testyfy_types.typeof(value-name, str, value-name: "value-name")

    if value.len() <= 0 {
        let message = "collection "
        if value-name.len() > 0 {
            message += "'" + value-name + "' "
        }
        message += "must contain at least one item"
        panic(message)
    }

    none
}

/// Assert that a collection contains a specific element.
///
/// For `dictionary` types, the _needle_ is searched for in both *keys* and *values*. To restrict
/// the assertion to either, pass `keys()` or `values()` as input to this function.
///
/// -> none
#let contains(
    /// A collection of some sort.
    ///
    /// -> array | dictionary
    value,

    /// An element to look for in _value_.
    ///
    /// -> any
    needle,

    /// The human-readable name (i.e. variable name or similar) that _value_ has in the code/API.
    /// Useful to hint users towards what exactly they did wrong. If not present, a generic error
    /// message is generated.
    ///
    /// -> str
    value-name: ""
) = {
    testyfy_types.type-one-of(value, (array, dictionary), value-name: "value")
    testyfy_types.typeof(value-name, str, value-name: "value-name")

    let message = "collection "
    if value-name.len() > 0 {
        message += "'" + value-name + "' "
    }
    message += "of type " + str(type(value)) + " must contain element '" + repr(needle) + "'"

    if type(value) == array {
        if not value.contains(needle) {
            panic(message)
        }
    } else if type(value) == dictionary {
        if not value.pairs().flatten().contains(needle) {
            panic(message)
        }
    } else {
        panic("unreachable")
    }

    none
}

/// Assert that the elements of an `array` have the expected `type`.
///
/// To assert the `type` of scalar values, see #ref.fn.with("types", "typeof")().
#let eltype(
    /// The `array` whose elements are to be checked.
    ///
    /// -> array
    value,

    /// One or more expected `type`s. If an `array` of `type`s is given, refer to the _allequal_
    /// parameter for additional checks.
    ///
    /// -> type | array
    expected-type,

    /// Whether all the `array` elements must be of the same `type`. This parameter only has an
    /// effect when _expected\_type_ is an `array` of `type`s.
    ///
    /// *If _allequal_ is false* each element of the input `array` _value_ is checked individually
    /// and must be one of the `type`s mentioned in _expected\_type_.
    ///
    /// ```typst
    /// #let x = (1, "2", (3,))
    /// #testyfy.eltype(x, (int, str, array), allequal: false)
    /// ```
    ///
    /// *If _allequal_ is true*, all elements of the input `array` _value_ must have the same
    /// `type`, which must be one of the `type`s mentioned in _expected\_type_.
    ///
    /// ```typst
    /// #let x = (1, 2, 3)
    /// #testyfy.eltype(x, (int, str), allequal: true)
    ///
    /// #let y = ("a", "bc", "def")
    /// #testyfy.eltype(y, (int, str), allequal: true)
    /// ```
    ///
    /// -> bool
    allequal: false,

    /// The human-readable name (i.e. variable name or similar) that _value_ has in the code/API.
    /// Useful to hint users towards what exactly they did wrong. If not present, a generic error
    /// message is generated.
    ///
    /// -> str
    value-name: ""
) = {
    testyfy_types.typeof(value, array, value-name: "value")
    testyfy_types.type-one-of(expected-type, (type, array), value-name: "expected-type")
    if value.len() == 0 {
        // No need to check an empty array, arrays themselves aren't typed
        return none
    }

    testyfy_types.typeof(value-name, str, value-name: "value-name")
    let value_eltypes = value.map(type).dedup()
    nonempty(value_eltypes, value-name: "elements of input array")

    let err_msg = "array "
    if value-name.len() > 0 {
        err_msg += "'" + value-name + "' "
    }

    if (type(expected-type) == array) {
        // Ensure all elements of 'expected-type' are actually types
        let invalid_expected-type_elements = expected-type
            .map(type)
            .enumerate()
            .filter(((idx, eltype)) => eltype != type)
        if invalid_expected-type_elements.len() > 1 {
            panic(
                "input 'expected-type'" +
                "must be an array consisting only of types, found invalid elements: " +
                invalid_expected-type_elements
                    .map(((idx, eltype)) => "'" + str(eltype) + "' at index " + str(idx))
                    .join(", ", last: " and ")
            )
        }

        if allequal {
            // Eltypes may be one of the input types, but they must all be the same one.
            if value_eltypes.len() == 1 {
                let value_eltype = value_eltypes.at(0)
                if value_eltype in expected-type {
                    // Ok
                    none
                } else {
                    panic(
                        err_msg +
                        "only has elements of type '" +
                        str(value_eltype) +
                        "' but expected one of '" +
                        expected-type.map(str).join("', '", last: "' or '") +
                        "'"
                    )
                }
            } else {
                panic(
                    err_msg +
                    "has elements of type '" +
                    value_eltypes.map(str).join("', '", last: "' and '") +
                    "' but expected all elements to be of the same type"
                )
            }
        } else {
            let invalid_elements = value
                .map(type)
                .enumerate()
                .filter(((idx, eltype)) => eltype not in expected-type)
            if invalid_elements.len() > 0 {
                panic(
                    err_msg +
                    "has invalid element types, expected one of '" +
                    expected-type.map(str).join("', '", last: "' or '") +
                    "' but found: " +
                    invalid_elements
                        .map(((idx, eltype)) => "'" + str(eltype) + "' at index " + str(idx))
                        .join(", ", last: " and ")
                )
            }
        }
    } else if (type(expected-type) == type) {
        if value_eltypes == (expected-type,) {
            // Ok
            none
        } else {
            let invalid_elements = value
                .map(type)
                .enumerate()
                .filter(((idx, eltype)) => eltype != expected-type)
            if invalid_elements.len() > 0 {
                panic(
                    err_msg +
                    "has invalid element types, expected '" +
                    str(expected-type) +
                    "' but found: " +
                    invalid_elements
                        .map(((idx, eltype)) => "'" + str(eltype) + "' at index " + str(idx))
                        .join(", ", last: " and ")
                )
            }
        }
    } else {
        panic("unreachable")
    }

    none
}
