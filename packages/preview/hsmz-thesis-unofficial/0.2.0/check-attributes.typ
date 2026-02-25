#let check-attributes(
  thesis-type,
  title,
  faculty,
  degree-program,
  submission-date,
  confidentiality-period,
  ai-declaration-option,
  language,
  acronyms,
  bibliography,
  appendix,
  author,
  company,
  supervisor,
  font,
  citation-style,
  print-only-used-acronyms,
  show-full-bibliography,
  show-restriction-notice,
) = {
  // check thesis-type
  if (thesis-type == none or thesis-type == "") {
    panic("Thesis type is missing")
  }

  // check title
  if (title == none or title == "") {
    panic("Title is missing")
  }

  // check faculty
  if (faculty == none or faculty == "") {
    panic("Faculty is missing")
  }

  // check degree program
  if (degree-program == none or degree-program == "") {
    panic("Degree program is missing")
  }

  // check submission date
  if (submission-date == none or submission-date == "") {
    panic("Submission date is missing")
  }

  // check confidentiality period
  if (confidentiality-period == none or confidentiality-period == "") {
    panic("Confidentiality period is missing")
  }

  // check ai declaration option
  if (
    ai-declaration-option == none
      or ai-declaration-option == ""
      or (ai-declaration-option != 1 and ai-declaration-option != 2 and ai-declaration-option != 3)
  ) {
    panic("AI declaration option is missing or out of bounds. Please provide 1, 2 or 3.")
  }

  // check language
  if (language == none or language == "") {
    panic("Language is missing")
  }

  if (language != "de" and language != "en") {
    panic("Invalid language. Please use 'de' for German or 'en' for English.")
  }

  // check acronyms
  if (acronyms == none or type(acronyms) != dictionary) {
    panic("Acronyms dictionary is missing or not a dictionary")
  }

  // check literature file
  if (bibliography == none or bibliography == "") {
    panic("Literature file is missing")
  }

  // check appendix
  if (appendix != none and type(appendix) != content) {
    panic("Appendix must be content or none")
  }

  // check author
  if (author == none or type(author) != dictionary) {
    panic("Author is missing or not a dictionary")
  }

  // check supervisor
  if (supervisor == none or supervisor == "") {
    panic("Supervisor is missing")
  }

  // check font
  if (font == none or font == "") {
    panic("Font is missing")
  }

  // check citation style
  if (citation-style == none or citation-style == "") {
    panic("Citation style is missing")
  }

  // Check, if settings are boolean
  if type(print-only-used-acronyms) != bool {
    panic("print-only-used-acronyms must be a boolean value")
  }

  if type(show-full-bibliography) != bool {
    panic("show-full-bibliography must be a boolean value")
  }

  if type(show-restriction-notice) != bool {
    panic("show-restriction-notice must be a boolean value")
  }
}
