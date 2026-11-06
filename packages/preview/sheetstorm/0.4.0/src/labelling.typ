#import "i18n.typ"

#let impromptu-label(lbl, kind: auto, supplement: none) = {
  assert(type(lbl) == str, message: "Label must be of type string")
  place[#figure(kind: kind, supplement: supplement)[]#label(lbl)]
}

/// Attach a label to a subtask.
///
/// *Example*
/// ```typst
/// #task[
///   + This is the first subtask. #subtask-label("subtask-a", display: "a)")
///   + This is the second subtask, see @subtask-a.
/// ]
/// ```
///
/// The correct display value does not get inherited from the enum context.
/// You must set it manually.
///
/// -> content
#let subtask-label(
  /// The label identifier. -> str
  lbl,
  /// How the subtask is displayed in references.
  ///
  /// If set to #auto, it is set to the same value as `lbl`.
  ///
  /// -> content | str | auto
  display: auto,
) = {
  assert(type(lbl) == str, message: "Label must be of type string")
  if display == auto {
    display = lbl
  }

  let supplement = [#context i18n.translate("Subtask") #display]
  impromptu-label(lbl, kind: "sheetstorm-subtask-label", supplement: supplement)
}
