#let data = plugin("plugin.wasm")

/// Reads a 32-bit unsigned integer from bytes and returns the remaining bytes
/// as well.
#let read-u32(data) = {
  let value = int.from-bytes(data.slice(0, count: 4))
  (value, data.slice(4))
}

/// Reads a string from bytes and returns the remaining bytes as well.
#let read-string(data) = {
  let (length, remainder) = read-u32(data)
  (
    str(remainder.slice(0, length)),
    remainder.slice(length),
  )
}

/// Reads an optional non-empty string from bytes and returns the remaining
/// bytes as well.
///
/// If the string turns out to be empty, the read value is `none`
/// instead of the empty string.
#let read-optional-string(data) = {
  let (value, remainder) = read-string(data)
  if value.len() == 0 {
    (none, remainder)
  } else {
    (value, remainder)
  }
}

/// Reads a vector of items from bytes and returns the remaining bytes as well.
///
/// Items are read using the provided reader function.
#let read-vec(item-reader, data) = {
  let (length, data) = read-u32(data)
  let elements = ()
  for i in range(length) {
    let (element, remainder) = item-reader(data)
    elements.push(element)
    data = remainder
  }
  (elements, data)
}

/// Reads a tupe of values from bytes and returns the remaining bytes as well.
///
/// Each value is read using its corresponding reader function.
#let read-tuple(..readers, data) = {
  assert.eq(readers.named(), (:))
  let readers = readers.pos()
  let values = ()
  for reader in readers {
    let (value, remainder) = reader(data)
    values.push(value)
    data = remainder
  }
  (values, data)
}

/// Reads a tupe of values from bytes.
///
/// Each value is read using its corresponding reader function. Expects that
/// there are no remaining bytes after reading all values of the tuple.
#let read-closed-tuple(..readers, data) = {
  let (values, remainder) = read-tuple(..readers, data)
  assert.eq(remainder, bytes(()))
  values
}

/// Reads a tupe of values from bytes and add the image of the remaining bytes
/// through `last`.
///
/// Each value is read using its corresponding reader function.
#let read-open-ended-tuple(..readers, last, data) = {
  let (values, remainder) = read-tuple(..readers, data)
  values.push(last(remainder))
  values
}

#let get-data(codepoint) = {
  let encoded-codepoint = codepoint.to-bytes(size: 4)
  let raw-block-data = data.get_block_data(encoded-codepoint)
  let raw-codepoint-data = data.get_codepoint_data(encoded-codepoint)
  let raw-alias-data = data.get_alias_data(encoded-codepoint)

  (
    if raw-block-data.len() != 0 {
      read-open-ended-tuple(
        read-u32,
        read-u32,
        str,
        raw-block-data,
      )
    },

    if raw-codepoint-data.len() != 0 {
      read-closed-tuple(
        read-string,
        read-string,
        read-string,
        read-optional-string,
        raw-codepoint-data,
      )
    } else {
      (none, none, none, none)
    },

    read-closed-tuple(
      read-vec.with(read-string),
      read-vec.with(read-string),
      read-vec.with(read-string),
      read-vec.with(read-string),
      read-vec.with(read-string),
      read-vec.with(read-string),
      raw-alias-data,
    )
  )
}
