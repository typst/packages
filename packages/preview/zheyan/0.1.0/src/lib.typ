#let _mask(str: "", m: "*") = {
  let result = "";
  for _i in str {
    result += m;
  }
  result
}

#let _mask_flag = if "mask" in sys.inputs { sys.inputs.at("mask") == "true" } else { false }

#let mask-str(str: "", m: "*") = if _mask_flag { _mask(str: str, m: m) } else { str }
