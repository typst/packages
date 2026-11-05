// Normalize English field names into the existing German template records.

/// Select one spelling of a paired German/English argument.
///
/// Fails if both names are supplied. If neither is supplied, returns the
/// fallback value.
///
/// - primary (any, none): value from the canonical field
/// - alias (any, none): value from its compatibility alias
/// - primary-name (str): canonical field name used in conflict errors
/// - alias-name (str): alias field name used in conflict errors
/// - fallback (any): value returned when both fields are absent
/// -> any: selected field value
#let select-alias(primary, alias, primary-name, alias-name, fallback) = {
  assert(primary == none or alias == none,
    message: "Conflicting fields: provide either `" + primary-name + "` or `" + alias-name + "`, not both.")
  if primary != none { primary } else if alias != none { alias } else { fallback }
}

/// Normalize an English or German record to the template's German field names.
///
/// At most one whole record may be provided. Keys in the English record are
/// translated using aliases; unlisted keys retain their spelling. Supplying
/// two names that map to the same normalized key fails. Missing keys are filled
/// from defaults, while explicitly provided values (including none) are kept.
///
/// - primary (dictionary, none): German record
/// - english (dictionary, none): English record
/// - aliases (dictionary): mapping from English keys to normalized keys
/// - defaults (dictionary): values inserted for keys absent from the input
/// - label (str): record name used in validation messages
/// -> dictionary: normalized record
#let normalize-record(primary, english, aliases, defaults, label) = {
  assert(primary == none or english == none,
    message: "Conflicting " + label + " records: provide either the German record or the English record, not both.")
  assert(primary == none or type(primary) == dictionary,
    message: label + " must be a dictionary.")
  assert(english == none or type(english) == dictionary,
    message: "English " + label + " must be a dictionary.")

  let result = (:)
  let supplied = (:)
  if primary != none {
    for (key, value) in primary {
      result.insert(key, value)
      supplied.insert(key, true)
    }
  }
  if english != none {
    for (key, value) in english {
      let target = aliases.at(key, default: key)
      assert(not (target in supplied),
        message: "Conflicting " + label + " fields: provide either `" + target + "` or `" + key + "`, not both.")
      result.insert(target, value)
      supplied.insert(target, true)
    }
  }
  for (key, value) in defaults {
    if not (key in result) { result.insert(key, value) }
  }
  result
}

/// Validate and normalize invoice line items to three-value tuples.
///
/// Each item may be a record with description, quantity, and unit-price, or an
/// array containing those three values in that order. Descriptions must be
/// strings or content, quantities positive numbers, and unit prices
/// nonnegative numbers. The helper does not calculate totals or round prices.
///
/// - items (array): invoice item records or three-value arrays
/// -> array: validated (description, quantity, unit-price) tuples
#let normalize-invoice-items(items) = {
  assert(type(items) == array, message: "Invoice items must be an array.")
  let result = ()
  for (index, item) in items.enumerate() {
    if type(item) == dictionary {
      for field in ("description", "quantity", "unit-price") {
        assert(field in item,
          message: "Invoice item " + str(index + 1) + " is missing `" + field + "`.")
      }
      let normalized = (item.at("description"), item.at("quantity"), item.at("unit-price"))
      assert(type(normalized.first()) == str or type(normalized.first()) == content,
        message: "Invoice item " + str(index + 1) + " `description` must be a string or content.")
      assert((type(normalized.at(1)) == int or type(normalized.at(1)) == float) and normalized.at(1) > 0,
        message: "Invoice item " + str(index + 1) + " `quantity` must be a positive number.")
      assert((type(normalized.at(2)) == int or type(normalized.at(2)) == float) and normalized.at(2) >= 0,
        message: "Invoice item " + str(index + 1) + " `unit-price` must be a nonnegative number.")
      result.push(normalized)
    } else {
      assert(type(item) == array and item.len() == 3,
        message: "Invoice item " + str(index + 1) + " must be a three-value tuple or a description/quantity/unit-price record.")
      assert(type(item.first()) == str or type(item.first()) == content,
        message: "Invoice item " + str(index + 1) + " description must be a string or content.")
      assert((type(item.at(1)) == int or type(item.at(1)) == float) and item.at(1) > 0,
        message: "Invoice item " + str(index + 1) + " quantity must be a positive number.")
      assert((type(item.at(2)) == int or type(item.at(2)) == float) and item.at(2) >= 0,
        message: "Invoice item " + str(index + 1) + " unit price must be a nonnegative number.")
      result.push(item)
    }
  }
  result
}

/// Validate the field types in a normalized postal-template record.
///
/// All keys named by the field lists must exist in record. Required text
/// fields must be strings. Nullable text fields may be strings or none, and
/// content fields may be Typst content or none. This helper checks types only;
/// it does not check formatting, address validity, or completeness beyond the
/// listed fields.
///
/// - record (dictionary): normalized record to validate
/// - label (str): record name used in validation errors
/// - text-fields (array of str): required string field names
/// - nullable-fields (array of str): optional string field names; defaults to
///   an empty array
/// - content-fields (array of str): optional content field names; defaults to
///   an empty array
/// -> none: returns no value; invalid input raises an assertion
#let validate-postal-record(record, label, text-fields, nullable-fields: (), content-fields: ()) = {
  for key in text-fields {
    assert(type(record.at(key)) == str,
      message: label + " field `" + key + "` must be a string.")
  }
  for key in nullable-fields {
    let value = record.at(key)
    assert(value == none or type(value) == str,
      message: label + " field `" + key + "` must be a string or none.")
  }
  for key in content-fields {
    let value = record.at(key)
    assert(value == none or type(value) == content,
      message: label + " field `" + key + "` must be content or none.")
  }
}
