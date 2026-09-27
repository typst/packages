/// Creates and returns an empty string-keyed dictionary.
/// By default typst cannot infere the key-type correctly.
/// 
/// Returns:
/// (dict[str, str]): A string-keyed empty dictionary.
#let str_dict() = {
    let dict = ("": "");
    dict.remove("");
    return dict;
}

/// Escapes a string in 
/// Args:
/// s (str): The string to escape.
/// 
/// Returns:
/// (str): The escaped string.
#let escape(s) = {
    for (f, t) in (
        "\\": "\\",
        "\"": "\"",
        "\n": "n",
        "\r": "r",
        "\t": "t",
        "\b": "b",
        "\f": "f",
        "\v": "v"
    ).pairs() {
        s = s.replace(f, "\\" +t);
    }
    return s;
}

/// Escapes and wraps a string in quotes.
/// Args:
/// s (str): The string to wrap.
/// 
/// Returns:
/// (str): The quoted string.
/// 
/// Example:
/// ```typst
/// assert(in_quotes("Hello \"World\"!") == "\"Hello \\\"World\\\"!\"")
/// ```
#let in_quotes(s) = {
    return "\"" + escape(str(s)) + "\"";
}

/// Asserts that a value is of a certain type.
/// Args:
/// s: The value to check.
/// ty: The expected type.
/// 
/// Panics if the type does not match.
#let assert_type(s, ty) = {
    if type(s) != ty {
        panic("Expected type " + str(ty) + " found " + str(type(s)));
    }
}

/// Asserts that two values are equal.
/// Args:
/// a: The first value.
/// b: The second value.
/// 
/// Panics if the values are not equal.
#let assert(a, b) = {
    if a != b {
        panic("Assertion failed: " + repr(a) + " != " + repr(b));
    }
}

/// Returns a string representation of a type according to the commonly used repr and constructor names.
/// Args:
/// t: The type to convert.
/// 
/// Returns:
/// (str): The string representation of the type.
#let type_str(t) = {
    let T = (
        "relative length": "relative",
    );
    let ty_str = str(t);
    return T.at(ty_str, default: ty_str);
}