#import "../utils.typ" as utils

/// Serializes content using its string representation.
#let str_serializer(ty) = (v) => {
    utils.assert_type(v, ty);
    import "string.typ" as string_;
    return string_.serializer(str(v));
}

/// Serializes content using its repr representation.
#let repr_serializer(ty) = (v) => {
    utils.assert_type(v, ty);
    import "string.typ" as string_;
    return string_.serializer(repr(v));
}

/// Serializes content raw.
#let raw_serializer(ty) = (v) => {
    utils.assert_type(v, ty);
    return v;
}

/// Serializes a value with a unit, e.g., "12.5kg" into (value: 12.5, unit: "kg").
/// Args:
/// s (string): The string representation of the value with unit.
/// 
/// Returns:
/// (dict[str, float|str]): A dictionary with keys "value" and "unit".
#let value_unit_serializer(s) = {
    import "float.typ" as float_;
    import "string.typ" as string_;
    let value = s.find(regex("[0-9.+-]+"));
    let unit = s.slice(value.len());
    return raw_serializer(dictionary)((
        value: float_.serializer(float(value)), 
        unit: string_.serializer(unit)
    ));
}

/// Panic serializer for unsupported types.
#let panic_serializer = (s) => {
    panic("No serializer defined for type " + str(type(s)));
}


/// Deserializes a plain type value.
/// Args:
/// ty (type): The expected type of the value.
/// v (any): The value to deserialize.
/// 
/// Returns:
/// (ty): The deserialized value.
#let raw_deserializer(ty) = (v) =>{
    utils.assert_type(v, ty);
    return v;
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

#let PRIMITIVE = (
    "boolean",
    "integer",
    "string",
    "array",
    "bytes",
);

#let no_value() = {};

/// Serializes any content recursively into a dictionary with type and value.
/// Args:
/// content (any): The content to serialize.
/// 
/// Returns:
/// (str): The serialized representation of the content.
#let serializer(content) = {
    import "type.typ" as type_;

    let ty = type(content);
    let value = type_mod(ty).serializer(content);

    if utils.type_str(ty) in PRIMITIVE {
        return value;
    }
    let ty = type_.serializer(type(content));
    if value == no_value {
        return (
            type: ty,
        );
    }
    return (
        type: ty,
        value: value
    );
}

/// Deserializes content from its serialized representation.
///
/// Args:
/// content: The serialized content.
/// 
/// Returns:
/// (any): The deserialized content.
#let deserializer(content) = {
    import "type.typ" as type_;

    let ty = type(content);
    if ty != dictionary {
        return type_mod(ty).deserializer(content);
    }

    if "type" not in content {
        let a = content
    }

    let ty = type_.deserializer(content.at("type"));
    let deserializer = type_mod(ty).deserializer;
    if "value" not in content {
        return deserializer();
    }
    return deserializer(content.at("value"));
}
