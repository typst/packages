#import "../util/parse-args.typ": *

#let parse-auto-resume(
  rel-level,
  auto-resuming,
  ..args,
) = {
  if auto-resuming != auto {
    let _auto-resuming = parse-args-with-level(auto-resuming, rel-level, ..args)
    assert(
      type(_auto-resuming) == bool,
      message: "`auto-resuming` should be a bool if it is not `auto` or `none`."
        + "\nBut found: "
        + repr(_auto-resuming),
    )
    _auto-resuming
  } else { none }
}

#let parse-auto-resume-form(
  form,
  rel-level,
  ..args,
) = {
  let auto-resuming = parse-args-with-level(form, rel-level, ..args)
  if auto-resuming != none {
    assert(
      type(auto-resuming) == bool,
      message: "`auto-resuming` should be a bool if it is not `none`." + "\nBut found: " + repr(auto-resuming),
    )
  }
  auto-resuming
}

#let get-target-enum(key-label) = {
  if key-label != none {
    let sel = metadata.where(value: enum-resume-ID, label: key-label)
    let keys = query(sel)
    if keys.len() == 0 {
      panic("Can't find the enum with key `" + str(key-label) + "`.")
    } else if keys.len() > 1 {
      panic("The enum with labelled key `" + str(key-label) + "` occurs multiple times.")
    } else {
      // if query(sel.after(here())).len() > 0 {
      //   // 暂时不支持引用后面列表的序号, 否则会造成“layout did not converge with 5 attempts.”
      //   panic("Resuming an enum before `" + str(key-label) + "` is not supported.")
      // }
      sel
    }
  } else { none }
}
