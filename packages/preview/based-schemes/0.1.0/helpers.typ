#let format_byte(number) = {
   assert(number >= 0, message:
    "Negative number passed to `format_byte`, only positive numbers are supported")
  assert(number <= 255, message:
    "Expected number smaller than 255 in `format_byte`.")
  if number < 16 { return "0" + upper(str(number, base: 16))
  } else { return upper(str(number, base: 16))}
}

#let copy_or_else(from, f_key, target, _else: none, c_apply: it => it, e_apply: it => it) = {
  if f_key not in from.keys() {
    target.insert(f_key, e_apply(_else))
  } else {
    target.insert(f_key, c_apply(from.at(f_key)))
  }
  return target
}

// quick lil thingy to convert from base16 style hex to a structured object
#let to_struct = (raw) => (
        hex: (
          no_hash: raw,
          hash: "#" + raw,
          r: raw.slice(0,2),
          g: raw.slice(2,4),
          b: raw.slice(4,6),
        ),
        rgb: (
          full: color.rgb(
            int(raw.slice(0,2), base: 16),
            int(raw.slice(2,4), base: 16),
            int(raw.slice(4,6), base: 16),
          ),
          r: int(raw.slice(0,2), base: 16),
          g: int(raw.slice(2,4), base: 16),
          b: int(raw.slice(4,6), base: 16),
        ),
        dec: (
          r: int(raw.slice(0,2), base: 16) / 255,
          g: int(raw.slice(2,4), base: 16) / 255,
          b: int(raw.slice(4,6), base: 16) / 255,
        )
      )