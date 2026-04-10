#import "../util/func-type.typ": *
#import "../util/identifier.typ": *
#import "../util/basic-tool.typ": *




/// Prevents label conflicts in text styles by checking and rebuilding labels.
///
/// - elem (function): The element to check.
/// - doc (content): The document content.
/// -> content
#let privent-label-text-style(elem, doc) = {
  // maximum show rule depth exceeded\nHint: check whether the show rule matches its own output
  show elem: it => {
    if (
      it.has("label") and it.label in (style-body-format-label, label-number-ID-label, style-body-native-format-label)
    ) {
      return it
    }
    if it.body.has("label") {
      if it.body.label in (style-body-format-label, label-number-ID-label, style-body-native-format-label) {
        return it
      }
    }
    let fields = it.fields()
    let _ = fields.remove("body")
    let _label = fields.remove("label", default: none)

    show style-body-format-label: e => [#rebuild-label(elem(e, ..fields), _label)]

    it.body
  }
  show style-body-native-format-label: it => {
    show elem: e => {
      if (
        e.has("label") and e.label in (style-body-format-label, label-number-ID-label, style-body-native-format-label)
      ) {
        return e
      }
      if (
        e.body.has("label")
          and e.body.label in (style-body-format-label, label-number-ID-label, style-body-native-format-label)
      ) {
        return e
      }
      [#e#style-body-native-format-label]
    }
    it
  }
  doc
}

/// Internal function to apply a delimiter to text styles.
///
/// - doc (content): The document content.
/// - delimiter (label): The delimiter to apply.
/// -> content
#let _text-style-delimiter(doc, delimiter) = {
  let f1 = it => it
  for elem in text-style-func {
    let f-next = doc => {
      show elem: it => {
        if it.has("label") {
          if it.label == delimiter {
            return it
          }
          // have other labels? do not change (might have mutil-labels)
          return it
        }
        // if it.body.has("label") {
        //   if it.body.label == delimiter {
        //     return it
        //   }
        //   // have other labels? do not change (might have mutil-labels)
        //   return it
        // }
        [#it#delimiter]
      }
      doc
    }
    f1 = doc => f1(f-next(doc))
  }
  f1(doc)
}

#let show-label-text-style(doc) = _text-style-delimiter(doc, label-number-ID-label)


/// Applies label conflict prevention to all text styles.
///
/// - doc (content): The document content.
/// -> content
#let privent-label-text-style-all(doc) = {
  let f1 = it => it
  for elem in text-style-func {
    let f-next = doc => privent-label-text-style(elem, doc)
    f1 = doc => f1(f-next(doc))
  }
  f1(doc)
}


/// Prevents label conflicts in layout styles.
///
/// - doc (content): The document content.
/// -> content
// #let prevent-label-layout-style(doc) = {
//   // TODO
// }

/// Ensures content is not affected by item-format styles.
///
/// - body (content): The content to process.
/// -> content
#let native-content(body) = {
  let _label = get_elem_label(body)
  if _label == style-body-native-format-label {
    return [#body]
  }
  // may happen `body` is nothing, so "label `<__cdl-style-body-native-format-label__>` is not attached to anything"
  [#body#style-body-native-format-label]
}
