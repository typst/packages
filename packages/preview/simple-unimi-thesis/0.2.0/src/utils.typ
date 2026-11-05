/// LaTeX sizes to match original templates (https://tex.stackexchange.com/questions/24599/what-point-pt-font-size-are-large-etc)
/// -> dict
#let _sizes = (
  tiny: 0.5em,
  scriptsize: 0.7em,
  footnotesize: 0.8em,
  small: 0.9em,
  normalsize: 1em,
  large: 1.2em,
  Large: 1.44em,
  LARGE: 1.728em,
  huge: 2.074em,
  Huge: 2.488em,
)

/// The current document section e.g. title page, mainmatter...).
/// -> state
#let _document-state = state("document-state", "TITLE_PAGE")

/// Localization dictionary.
/// -> dict
#let _localization = yaml("resources/locale.yaml")

/// Get the lvl. 1 heading in the current page. Returns an empty array if none are found.
/// -> array
#let _h1-current-page() = query(selector(heading.where(level: 1))).filter(h1 => (
  here().page() == h1.location().page()
))

/// Get the prefix based on document state.
/// -> string
#let _get-prefix() = context {
  return if _document-state.get() == "APPENDIX" {
    _localization.at(text.lang).appendix
  } else {
    _localization.at(text.lang).chapter
  }
}

/// Custom numbering with prefix included. Used in headers, chapter numbers.
/// -> string
#let _custom-numbering(numbering, args) = context {
  if (args.pos().len() != 0) {
    return _get-prefix() + " " + std.numbering(numbering, args.pos().first())
  }
}

/// Helper function to handle (co)supervisor(s).
/// -> content
#let _show-starvisor(
  /// (Co)Supervisor(s) of the thesis.
  /// -> str | array
  starvisor,
  /// The key to look for in the locale dictionary
  /// -> "supervisor" | "cosupervisor"
  locale-key,
  /// How to seperate the key from the content.
  /// -> string | content
  separator: ": ",
  /// How to separate multiple starvisors.
  /// -> string | content
  join-separator: ", ",
  /// Function that will be applied to the key.
  /// -> function
  key: x => x,
  /// Function that will be applied to the content.
  /// -> function
  out: x => x,
) = {
  if (starvisor == none or starvisor == ()) { return }
  context {
    if type(starvisor) == str {
      key(_localization.at(text.lang).at(locale-key)) + separator + out(starvisor)
    } else if type(starvisor) == array and starvisor.len() == 1 {
      key(_localization.at(text.lang).at(locale-key)) + separator + out(starvisor).map(out).join(join-separator)
    } else if type(starvisor) == array and starvisor.len() > 1 {
      key(_localization.at(text.lang).at(locale-key + "s")) + separator + starvisor.map(out).join(join-separator)
    } else {
      panic("(Co)supervisor(s) must be passed as string or as array.")
    }
    linebreak()
  }
}
