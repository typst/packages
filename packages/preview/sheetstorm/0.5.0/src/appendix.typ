#import "i18n.typ"

/// Setup an appendix layout.
///
/// Use this function to turn the rest of the document into an appendix.
///
/// *Example*
/// ```typst
/// #show: appendix
///
/// = Blablabla
/// Now everything is displayed as appendix.
/// ```
/// -> content
#let appendix(
  /// The title of the whole appendix. -> content | str | none
  title: context i18n.translate("Appendix"),
  /// The text size of the appendix title. -> length
  title-size: 1.6em,
  /// The supplement of the appendix sections. -> content | str | function | none
  supplement: context i18n.translate("Appendix"),
  /// The numbering pattern for the appendix sections. -> str | none
  numbering: "A.1.",
  /// The appendix body itself. -> content
  body,
) = [
  #if title != none {
    text(title-size, strong(title))
  }

  #set heading(numbering: numbering, supplement: supplement)

  #counter(heading).update(0)

  #body
]
