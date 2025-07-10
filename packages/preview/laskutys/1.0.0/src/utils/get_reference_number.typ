#import plugin("/rust_tools/rust_tools.wasm"): (
  get_reference_number as _get_reference_number,
)
#import "/src/utils/call_wasm.typ": call_wasm

/// Removes leading zeros after check digits and spaces
///
/// -> str
#let preprocess(
  reference_number,
) = {
  let reference_number = reference_number.replace(" ", "")
  let prefix = reference_number.slice(0, 4)
  let digits = str(int(reference_number.slice(4)))

  prefix + digits
}

/// -> str
#let get_reference_number(data) = {
  let reference_number = call_wasm(_get_reference_number, data)

  preprocess(reference_number)
    .split("")
    .slice(1, -1)
    .chunks(4)
    .map(x => x.join(""))
    .join(" ")
}
