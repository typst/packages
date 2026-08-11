// 14/02/2026
// https://github.com/TheGiddyLimit/5etools-utils/blob/master/schema/site/bestiary/bestiary.json
// Possible `alignment` data entries are as follows:
//
// array:
//    > alignmentEnum
//    > dict
//        > `alignment`: array: alignmentEnum - required
//        > `chance`: int
//        > `note`: string
//    > dict
//        > `special`: string - required

// Possible `alignmentEnum` data entries are:
// alignmentEnum

#import "../../external.typ": transl

/// Translation is thought so that it looks up to the form of `Alignment` in the specified language.

#let render-alignment(self, body) = {
  if not body.keys().contains("alignment") { return }
  if body.alignment == none { return }

  // check for any-good alignment
  // so we can just check if it has all of them
  let alignment = []

  // alignmentPrefix (e.g. Typically) "alignmentPrefix": "Typically ",
  // Any is defined by: having "L", "NX", "C", "NY", and the type (evil or good) "E"
  if "L" in body.alignment and "NX" in body.alignment and "C" in body.alignment and "NY" in body.alignment {
    if "E" in body.alignment {
      alignment = transl("LNXCNYE")
    } else if "G" in body.alignment {
      alignment = transl("LNXCNYG")
    } else {
      panic("any alignment can be set to either `Any good alignment` or `And non-good Alignment`")
    }
  } else if body.alignment.len() == 2 {
    alignment = [#transl(body.alignment.at(0)) #transl(body.alignment.at(1))]
  } else if body.alignment.len() == 1 {
    alignment = [#transl(body.alignment.at(0))]
  } else {
    panic("Alignment not supported yet!")
  }

  if body.keys().contains("alignmentPrefix") {
    return [#body.alignmentPrefix #alignment]
  }

  return alignment
}
