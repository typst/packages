#import plugin("/rust_tools/rust_tools.wasm"): get_reference_number
#import "/src/utils/call-wasm.typ": call-wasm

/// Removes leading zeros after check digits and spaces
///
/// -> str
#let preprocess(
  reference-number,
) = {
  let reference-number = reference-number.replace(" ", "")
  let prefix = reference-number.slice(0, 4)
  let digits = str(int(reference-number.slice(4)))

  prefix + digits
}

/// -> str
#let get-reference-number(data) = {
  let reference-number = call-wasm(get_reference_number, data)

  preprocess(reference-number)
    .split("")
    .slice(1, -1)
    .chunks(4)
    .map(x => x.join(""))
    .join(" ")
}
