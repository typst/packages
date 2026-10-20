// src/utils.typ - CSV Data Processing & Field Utilities for Typst Mail Merge

/// Normalizes a field key by converting to lowercase and removing spaces, underscores, and hyphens.
/// - k (str): The field key name.
/// -> str
#let normalize-key(k) = {
  lower(str(k)).clusters().filter(c => c != " " and c != "_" and c != "-").join("")
}

/// Reads CSV data from a file path, array of dictionaries, or array of arrays.
/// Normalizes strings, handles header mapping, and cleans up empty values.
/// - data (str | array): CSV file path or raw array data.
/// - trim (bool): Whether to trim leading/trailing whitespace from string fields.
/// - default-value (str): Default fallback value for missing or empty fields.
/// -> array of dictionary
#let read-csv-data(data, trim: true, default-value: "") = {
  let raw-records = ()

  if type(data) == str {
    raw-records = csv(data, row-type: dictionary)
  } else if type(data) == array {
    if data.len() == 0 {
      return ()
    }
    if type(data.at(0)) == dictionary {
      raw-records = data
    } else if type(data.at(0)) == array {
      let headers = data.at(0)
      let rows = data.slice(1)
      raw-records = rows.map(row => {
        let d = (:)
        for (i, h) in headers.enumerate() {
          d.insert(str(h).trim(), row.at(i, default: ""))
        }
        d
      })
    } else {
      panic("data array elements must be dictionaries or row arrays")
    }
  } else {
    panic("data argument must be a CSV file path (str) or an array of records")
  }

  // Clean values, keys, and handle defaults
  raw-records.map(rec => {
    let clean-rec = (:)
    for (k, v) in rec.pairs() {
      let key-str = str(k).trim()
      let clean-v = ""
      if v == none {
        clean-v = default-value
      } else if type(v) == content {
        clean-v = v
      } else if type(v) == str {
        clean-v = if trim { v.trim() } else { v }
        if clean-v == "" {
          clean-v = default-value
        }
      } else {
        clean-v = str(v)
        if trim {
          clean-v = clean-v.trim()
        }
        if clean-v == "" {
          clean-v = default-value
        }
      }
      clean-rec.insert(key-str, clean-v)
    }
    clean-rec
  })
}

/// Retrieves and optionally formats a field value from a record with fallback and smart key lookup.
/// Supports candidate key arrays (e.g., ("First Name", "FirstName", "Name")), flexible key normalization, and formatting.
/// - record (dictionary): The record dictionary.
/// - key (str | array): Field key or array of candidate keys to search for.
/// - fmt (none | str | function): Formatting option ("upper", "lower", "title", "currency", or custom function `val => content`).
/// - default (any): Fallback value if field is not found or empty.
/// -> any
#let field(record, key, fmt: none, default: "") = {
  if type(record) != dictionary {
    return default
  }

  let val = default
  let candidate-keys = if type(key) == array { key } else { (key,) }

  let extract-val(raw-v) = {
    if raw-v == none {
      none
    } else if type(raw-v) == content {
      raw-v
    } else if type(raw-v) == str {
      let v = raw-v.trim()
      if v != "" { v } else { none }
    } else {
      let v = str(raw-v).trim()
      if v != "" { v } else { none }
    }
  }

  // 1. Direct match check
  for k in candidate-keys {
    let k-str = str(k)
    if k-str in record {
      let res = extract-val(record.at(k-str))
      if res != none {
        val = res
        break
      }
    }
  }

  if val == default {
    // 2. Normalized key match check (ignores case, spaces, underscores, hyphens)
    let normalized-map = (:)
    for (k, v) in record.pairs() {
      normalized-map.insert(normalize-key(k), v)
    }

    for k in candidate-keys {
      let nk = normalize-key(k)
      if nk in normalized-map {
        let res = extract-val(normalized-map.at(nk))
        if res != none {
          val = res
          break
        }
      }
    }
  }

  if val == default or val == "" {
    return default
  }

  if fmt == none {
    return val
  } else if type(fmt) == function {
    return fmt(val)
  } else if type(val) == content {
    return val
  } else {
    let val-str = str(val)
    if fmt == "upper" {
      return upper(val-str)
    } else if fmt == "lower" {
      return lower(val-str)
    } else if fmt == "title" {
      return val-str.split(" ").map(word => {
        let clusters = word.clusters()
        if clusters.len() > 0 {
          upper(clusters.at(0)) + lower(clusters.slice(1).join(""))
        } else {
          ""
        }
      }).join(" ")
    } else if fmt == "currency" {
      if val-str.starts-with("$") {
        return val-str
      }
      return "$" + val-str
    }
  }

  return val
}

/// Formats a field value using built-in format presets or a custom function.
/// - record (dictionary): The record dictionary.
/// - key (str | array): Field key name.
/// - fmt (none | str | function): Formatting option ("upper", "lower", "title", "currency", or custom function `val => content`).
/// - default (any): Default fallback if value is missing.
/// -> content | str
#let fmt-field(record, key, fmt: none, default: "") = {
  field(record, key, fmt: fmt, default: default)
}

/// Binds a record to the field getter for concise `#f("Field Name")` template syntax.
/// - record (dictionary): The record dictionary.
/// -> function `(key, fmt: none, default: "") => ...`
#let bind-field(record) = field.with(record)

/// Joins multiple non-empty field values with a separator (ideal for address lines).
/// - record (dictionary): The record dictionary.
/// - keys (array): Array of field keys to inspect.
/// - separator (str | content): Separator inserted between non-empty fields.
/// - default (any): Fallback value if all specified fields are empty.
/// -> str | content
#let join-fields(record, keys, separator: ", ", default: "") = {
  let non-empty-vals = ()
  for k in keys {
    let val = field(record, k, default: "")
    if val != "" {
      non-empty-vals.push(val)
    }
  }

  if non-empty-vals.len() > 0 {
    non-empty-vals.join(separator)
  } else {
    default
  }
}

/// Conditionally renders content based on whether a field is non-empty.
/// - record (dictionary): The record dictionary.
/// - key (str | array): Field key to test.
/// - then-content (content | function): Content or function `val => content` to display if field is present and non-empty.
/// - else-content (content): Fallback content if field is empty (default `[]`).
/// -> content
#let if-field(record, key, then-content, else-content: []) = {
  let val = field(record, key, default: "")
  if val != "" {
    if type(then-content) == function {
      then-content(val)
    } else {
      then-content
    }
  } else {
    else-content
  }
}

/// Returns true if field is empty or missing.
#let is-empty(record, key) = {
  field(record, key, default: "") == ""
}

/// Returns true if field is non-empty.
#let is-non-empty(record, key) = {
  field(record, key, default: "") != ""
}

/// Helper to extract 1-based index of current record.
#let record-index(record) = {
  record.at("_index", default: 1)
}

/// Helper to extract total records count in the current merge.
#let record-total(record) = {
  record.at("_total", default: 1)
}

/// Helper to check if current record is the first in the merged dataset.
#let is-first-record(record) = {
  record.at("_is-first", default: true)
}

/// Helper to check if current record is the last in the merged dataset.
#let is-last-record(record) = {
  record.at("_is-last", default: true)
}
