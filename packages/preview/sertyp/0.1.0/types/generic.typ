#import "../utils.typ" as utils

/// Serializes content using its string representation.
#let str_serializer(s) = {
    return utils.in_quotes(str(s));
}

/// Serializes content using its repr representation.
#let repr_serializer(s) = {
    return utils.in_quotes(repr(s));
}

/// Serializes content raw.
#let raw_serializer(s) = {
    return str(s);
}

/// Serializes a value with a unit, e.g., "12.5kg" into (value: 12.5, unit: "kg").
/// Args:
/// s (string): The string representation of the value with unit.
/// 
/// Returns:
/// (dict[str, float|str]): A dictionary with keys "value" and "unit".
#let value_unit_serializer(s) = {
    import "float.typ" as float_;
    let value = s.find(regex("[0-9.+-]+"));
    let unit = s.slice(value.len());
    return (
        value: float_.serializer(float(value)), 
        unit: str_serializer(unit)
    );
}

/// Deserializes a plain type value.
/// Args:
/// ty (type): The expected type of the value.
/// v (any): The value to deserialize.
/// 
/// Returns:
/// (ty): The deserialized value.
#let plain_type_deserializer(ty) = (v) =>{
    utils.assert_type(v, ty);
    return v;
}

/// Evaluates a string representation into its value.
/// Args:
/// s (str): The string representation to evaluate.
/// 
/// Returns:
/// (any): The evaluated value. 
#let eval_deserializer(s) = {
    utils.assert_type(s, str);
    return eval(s);
}

/// Deserializes a value with a unit from a dictionary.
/// Args:
/// l (dict[str, float|str]): A dictionary with keys "value" and "unit".
/// 
/// Returns:
/// (any): The deserialized value with unit.
#let value_unit_deserializer(l) = {
    utils.assert_type(l, dictionary);

    import "float.typ" as float_;
    let value = float_.deserializer(l.at("value"));
    let unit = l.at("unit");
    return eval(str(value) + unit);
}

/// combines already serialized parts of one dictionary into one string representation.
/// Args:
/// d (dict[str, str]): The dictionary to serialize.
/// 
/// Returns:
/// (str): The string combined representation of the dictionary.
/// 
/// Example:
/// ```typst
/// let d = ( "a": "test", "b": "2" );
/// assert(str_dict_serializer(d) == "(a: test, b: 2)")
/// ```
#let str_dict_serializer(d) = {
    let body = "";
    for (key, value) in d.pairs() {
        body += key + ":" + value + ",";
    }
    return "(" + body + ")";
}

/// Panic serializer for unsupported types.
#let panic_serializer = (s) => {
    panic("No serializer defined for type " + str(type(s)));
}

/// Imports the module for a given type.
/// Each module contains a serializer, deserializer and test methods for that type.
/// 
/// Args:
/// t (type): The type to get the module for.
/// 
/// Returns:
/// (module): The imported module for the type.
#let type_mod(t) = {
    import utils.type_str(t) + ".typ" as mod
    return mod;
}

/// Extracts optional fields in form of `v.field()` from an object if they are present.
/// Args:
/// v: The object to extract fields from.
/// fields (list[str]): The list of field names to extract.
/// 
/// Returns:
/// (dict[str, str]): A dictionary with the extracted fields.
/// 
/// Example:
/// ```typst
/// let fields = at_optional(datetime(year: 2024, month: 6), ("year", "month", "day"));
/// assert(fields == ( "year": 2024, "month": 6 ));
/// ```
#let at_optional(v, fields) = {
    let dict = utils.str_dict();
    for field in fields {
        let value = eval(
            "v."+field+"()",
            scope: (v: v)
        );
        if value == none {
            continue;
        }
        dict.insert(field, value);
    }
    return dict;
}

#let BASIC = (
    "boolean",
    "integer",
    // "float",
    "string",
    "none",
    "auto",
    "array",
);

/// Serializes any content recursively into a dictionary with type and value.
/// Args:
/// content (any): The content to serialize.
/// 
/// Returns:
/// (str): The serialized representation of the content.
#let serialize(content) = {
    import "type.typ" as type_;

    let ty = type(content);
    let value = type_mod(ty).serializer(content);

    if utils.type_str(ty) in BASIC {
        return value;
    }

    return str_dict_serializer((
        type: type_.serializer(type(content)),
        value: value
    ));
}

/// Deserializes content from its serialized representation.
///
/// Args:
/// content: The serialized content.
/// 
/// Returns:
/// (any): The deserialized content.
#let deserialize(content) = {
    import "type.typ" as type_;

    let ty = type(content);
    if ty != dictionary {
        return type_mod(ty).deserializer(content);
    }

    let ty = type_.deserializer(content.at("type"));
    return type_mod(ty).deserializer(content.at("value"));
}

/// Tests for correct serialization and deserialization of a value.
/// The value is serialized and then deserialized again. The results value and type are compared to the original value. 
/// Args:
/// v (any): The value to test.
#let test(v) = {
    let vd = deserialize(eval(serialize(v)));
    utils.assert(
        vd,
        v
    );
    utils.assert(
        type(vd),
        type(v)
    );
}

/// Tests for correct serialization and deserialization of a value using repr.
/// The value is serialized and then deserialized again. The results value's repr and type are compared to the original value's repr and type. 
/// Args:
/// v (any): The value to test. 
#let test_repr(v) = {
     let vd = deserialize(eval(serialize(v)));
    utils.assert(
        repr(vd),
        repr(v)
    );
    utils.assert(
        type(vd),
        type(v)
    );
}