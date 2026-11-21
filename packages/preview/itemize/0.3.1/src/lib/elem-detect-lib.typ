#import "../util/func-type.typ": *
#import "../util/identifier.typ": same-line-next-elem-ID, same-line-next-term-ID
#import "../util/basic-tool.typ": get-elem-label, rebuild-label
#import "../foundation/export-lib.typ": ElemType



/// Defines the different inline element types used for layout processing.
///
/// Each entry maps a semantic type to a sentinel value that is compared in
/// `detect-body-type` to decide how an element is handled:
/// - `list`: a nested `enum`/`list` item that should be laid out inline
/// - `blank`: blank content (spacing, breaks, etc.) that is skipped
/// - `unknown`: an unsupported element that is kept as-is
/// - `description`: a `terms` item (description list)
#let InlineType = (
  "list": none,
  "blank": auto,
  "unknown": false,
  "description": true,
)

/// Wraps the list's label value in a `metadata` marker so that a following
/// list item can be recognized as a "same-line" continuation during layout.
#let same-line-next-list-meta(label-value) = metadata(label-value)

/// Detect the inline type of `e` and return the rewritten body accordingly.
///
/// - e (content): The element (or content sequence) to inspect.
/// - checklist-check (bool): Whether to detect checklist markers (`[x]`).
/// - symbol-func (function): Called with the marker text to resolve a
///   checklist symbol; returns `none` if the text is not a valid marker.
/// - label-value (any): The current list's label value, re-attached to nested
///   items so they stay on the same line.
/// - elem (str): Which elements to process (`ElemType.all`, `ElemType.list`,
///   or `ElemType.enum`).
/// -> dictionary with `body` (content), `inline` (InlineType), and optionally
///    `desc` (the detected terms item) and `checklist` (checklist info).
#let detect-body-type(
  e,
  checklist-check: false,
  symbol-func: _ => none,
  label-value: none,
  elem: "all",
) = {
  // Blank content (spacing, breaks, metadata, etc.) is left untouched and
  // marked as `blank` so callers can skip it.
  if is_blank-elem(e) {
    return (body: e, inline: InlineType.blank)
  }
  let func = e.func()
  let _label = get-elem-label(e)

  // Recursive call, preserving `label-value` and `elem` for nested elements.
  let detect-body-type = detect-body-type.with(label-value: label-value, elem: elem) // override

  // A content sequence: walk its children to find the first non-blank element
  // and use that element's inline type for the whole sequence.
  if func == func-seq {
    let children = e.children
    let checklist-info = (:)
    if checklist-check {
      // A checklist item has at least 4 children: `[`, marker, `]`, content
      if children.len() >= 3 and (children.at(0) == [#"["] and children.at(2) == [#"]"]) {
        let marker-text = children.at(1)
        let marker-info = symbol-func(marker-text)
        if marker-info != none {
          checklist-info.insert("checklist", marker-info)
          // delete the checklist from body
          children = children.slice(3)
        }
      }
    }

    for (index, child) in children.enumerate() {
      let (inline, body, ..other) = detect-body-type(child)
      if inline == InlineType.blank {
        continue
      }
      children.at(index) = body
      return (
        body: rebuild-label(func-seq(children), _label),
        inline: inline,
        ..other,
        ..checklist-info,
      )
    }
    // blank
    return (
      body: if checklist-check { rebuild-label(func-seq(children), _label) } else { e },
      inline: InlineType.blank,
      ..checklist-info,
    )
  } else if func in (list.item, enum.item) {
    // A list/enum item: only keep it inline if it matches the requested `elem`
    // type; otherwise treat it as unsupported.
    let flag = (
      { func == list.item and elem in (ElemType.all, ElemType.list) }
        or { func == enum.item and elem in (ElemType.all, ElemType.enum) }
    )
    let _label = get-elem-label(e)
    if flag {
      if _label != none {
        return (
          body: [#func({
              e.body
              same-line-next-list-meta(label-value)
            })#_label],
          inline: InlineType.list,
        )
      } else {
        return (body: [#e#label-value], inline: InlineType.list)
      }
    } else {
      return (body: e, inline: InlineType.unknown)
    }
  } else if func in (list, enum) {
    // A bare list/enum element
    let _field = e.fields()
    let _body = _field.remove("children")
    let _label = _field.remove("label", default: none)
    if _body != () {
      let flag = (
        { func == list and elem in (ElemType.all, ElemType.list) }
          or { func == enum and elem in (ElemType.all, ElemType.enum) }
      )
      if flag {
        if _label != none {
          return (body: [#func(.._body, .._field)#label-value], inline: InlineType.list)
        } else {
          return (body: [#e#label-value], inline: InlineType.list)
        }
      } else {
        return (body: e, inline: InlineType.unknown)
      }
    } else {
      return (body: e, inline: InlineType.unknown)
    }
  } else if func == terms.item {
    // A description/terms item: keep it inline and expose the original element
    // via `desc` for downstream processing.
    return (
      body: [#e#same-line-next-term-ID],
      inline: InlineType.description,
      desc: e,
    )
  } else {
    // Unwrap transparent wrappers (style, text-style, align, hide, place) and
    // recurse into their content, preserving any label on the wrapper.
    if is_styled(e) {
      let field = e.fields()
      let _body = field.remove("child")
      let _label = field.remove("label", default: none)
      let (inline, body, ..desc) = detect-body-type(
        _body,
        checklist-check: checklist-check,
        symbol-func: symbol-func,
      ) 
      return (body: rebuild-label(e.func()(body, e.styles), _label), inline: inline, ..desc)
    } else if is_text-styled(e) {
      let field = e.fields()
      let _body = field.remove("body")
      let _label = field.remove("label", default: none)
      let (inline, body, ..desc) = detect-body-type(_body)
      return (body: rebuild-label(e.func()(body, ..field), _label), inline: inline, ..desc)
    } else if func == align {
      let field = e.fields()
      let _body = field.remove("body")
      let _label = field.remove("label", default: none)
      let alignment = field.remove("alignment", default: align.alignment)
      let (inline, body, ..desc) = detect-body-type(_body)
      return (body: rebuild-label(align(body, alignment), _label), inline: inline, ..desc)
    } else if func == hide {
      let (inline, body, ..desc) = detect-body-type(e.body)
      let _label = get-elem-label(e)
      return (body: rebuild-label(hide(body), _label), inline: inline, ..desc)
    } else if func == place and { if e.has("float") { not e.float } else { not place.float } } {
      // A non-floating `place` is treated as blank (it does not affect line flow).
      return (body: e, inline: InlineType.blank)
    }
    // Do not support for like `+ block-elem[+ content]`
    return (body: e, inline: InlineType.unknown)
  }
}
