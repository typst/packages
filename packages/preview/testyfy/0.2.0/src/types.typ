// SPDX-License-Identifier: GPL-3.0-or-later

/// Assert that the argument has the expected `type`.
///
/// See also #ref.fn.with("types", "type-one-of")() when _value_ can be one of multiple `type`s.
///
/// ==== Panics
///
/// - If `value` is not of type `expected-type`
/// - If `expected-type` is not a type
///
/// ==== Examples
///
/// ```example
/// #testyfy.typeof(5, int)
/// This is indeed an integer.
///
/// #testyfy.typeof("hello", str)
/// And this is a string.
/// ```
#let typeof(
    /// The value whose `type` is to be checked.
    ///
    /// -> any
    value,

    /// The `type` that _value_ should have.
    ///
    /// -> type
    expected-type,

    /// The human-readable name (i.e. variable name or similar) that _value_ has in the code/API.
    /// Useful to hint users towards what exactly they did wrong. If not present, a generic error
    /// message is generated.
    ///
    /// -> str
    value-name: ""
) = {
    assert(
        type(expected-type) == type,
        message: "input 'expected-type' must be an actual data type, found '" +
            str(type(expected-type)) + "'"
    )
    assert(
        type(value-name) == str,
        message: "input 'value-name' must be of type 'str', found '" + str(type(value-name)) + "'"
    )

    if type(value) != expected-type {
        let message = "input "
        if value-name.len() > 0 {
            message += "'" + value-name + "' "
        }
        message += "must be of type '" + str(expected-type) + "', found '" + str(type(value)) + "'"
        panic(message)
    }

    none
}

/// Assert that the argument has one of the expected `type`s.
///
/// See also #ref.fn.with("types", "typeof")() when _value_ must have a specific `type`.
///
/// ```example
/// #testyfy.type-one-of(5, (int, float))
/// This is fine.
///
/// #testyfy.type-one-of((1, 2, 3), (array, regex, label))
/// So is this!
/// ```
#let type-one-of(
    /// The value whose `type` is to be checked.
    ///
    /// -> any
    value,

    /// An `array` of `type`s that _value_ is allowed have.
    ///
    /// -> array
    expected-types,

    /// The human-readable name (i.e. variable name or similar) that _value_ has in the code/API.
    /// Useful to hint users towards what exactly they did wrong. If not present, a generic error
    /// message is generated.
    ///
    /// -> str
    value-name: ""
) = {
    let testyfy_typeof = typeof

    testyfy_typeof(expected-types, array, value-name: "expected-types")
    // NOTE: This duplicates a little code from 'testyfy.eltype' but it keeps the module structure
    // intact.
    {
        let invalid_types = expected-types
            .map(type)
            .enumerate()
            .filter(((_, x)) => x != type)
        if invalid_types.len() > 0 {
            panic(
                "argument 'expected-types' must contain only types, found invalid elements: '" +
                invalid_types
                    .map(((idx, dtype)) => str(dtype) + " at index " + str(idx))
                    .join("', '", last: "' and '")
            )
        }
    }
    testyfy_typeof(value-name, str, value-name: "value-name")

    if expected-types.len() == 0 {
        return none
    } else if expected-types.len() == 1 {
        return testyfy_typeof(value, expected-types.first())
    }

    for allowed_type in expected-types {
        if type(value) == allowed_type {
            return none
        }
    }

    // We only get here if nothing matched
    let message = "value "
    if value-name.len() > 0 {
        message += "'" + value-name + "' "
    }
    message += "must be of type '" + expected-types.map(str).join("', '", last: "' or '")
    message += "', found '" + str(type(value)) + "'"
    panic(message)
}
