/// Allows hiding or showing full resume dynamically using global variable. This can
/// be helpful for creating a single document that can be rendered differently depending on
/// the desired output, for cases where you'd like to simultaneously render both a full copy
/// and a single-page instance of only the most important or vital information.
/// -> content
#let hide(
  /// Whether or not to hide the content. -> bool
  should-hide,
  /// Content to be hidden -> content
  content,
) = {
  if not should-hide {
    content
  }
}


/// Create an entry documenting a research project.
/// Styled after the Goldwater CV entries, which record:
/// - Manner of access
/// - Project significance
/// - Skills obtained
/// -> content
#let proj(
  /// Title of the project. -> str | content | none
  title: "",
  /// Advisors, such as faculty or graduate students, who mentored you on the project.
  /// -> array
  advisors: (),
  /// Institution where the project took place.
  institution: "",
  /// Start date of the project. -> datetime | str | none
  start: "",
  /// End date of the project. -> datetime | str | none
  end: "",
  /// End date of the project. -> datetime | str | none
  time: "",
  /// Manner of access to the project. -> content | str | none
  access: [],
  /// Significance of the project. -> content | str | none
  significance: [],
  /// Skills learned through the project. -> content | str | none
  skills: [],
) = {
  pagebreak()

  heading(title)
  grid(columns: (1fr, auto))

  strong[Access.]
  [#access]

  strong[Significance.]
  [#significance]

  strong[Skills.]
  [#skills]
}
