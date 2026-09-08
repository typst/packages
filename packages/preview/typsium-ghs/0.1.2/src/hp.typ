#let get-language-index(lang) = {
  if lang == "en" { 1 } else if lang == "de" { 0 } else if lang == "fr" { 2 } else if lang == "it" { 3 } else { 1 }
}

#let database = state("hp-statements", csv("resources/hp-statements.tsv", delimiter: "\t", row-type: dictionary))

#let validate-string(statement, substitute) = {
  if statement.contains(regex("p|P")) {
    substitute = "P"
  } else if statement.contains(regex("h|H")) {
    substitute = "H"
  }

  statement = statement.replace(regex("[A-Za-z ,-]"), "")
  statement = upper(statement)

  statement = statement.replace(regex("(\d+)"), x => substitute + x.text)

  return statement
}

#let validate-statement(statement, substitute) = {
  if type(statement) == int {
    substitute + str(statement)
  } else if type(statement) == str {
    validate-string(statement, substitute)
  } else if type(statement) == content {
    validate-string(statement.text(), substitute)
  }
}

#let get-statement(
  statement,
  variant,
  parameters,
  only-statement,
  as-hover,
  hide-parameter-directions: true,
  default: x => "no statement found: " + repr(x),
) = {
  let x = parameters.len()
  let parameterlen = if type(parameters) == str {
    "-1"
  } else {
    if parameters.len() > 0 or hide-parameter-directions { "-" + str(parameters.len()) } else { "" }
  }

  let lang-index = get-language-index(text.lang)
  let db = database.get().at(lang-index)
  let full-statement
  if variant != auto {
    let variant = "." + str(variant)
    full-statement = db.at(statement + variant + parameterlen, default: db.at(statement + variant, default: db.at(
      statement,
      default: none,
    )))
  } else {
    full-statement = db.at(statement + parameterlen, default: db.at(statement, default: none))
  }

  if full-statement == none and statement.contains("+") {
    let statements = statement.split("+")
    full-statement = statements
      .map(x => get-statement(
        x,
        variant,
        parameters,
        true,
        false,
        hide-parameter-directions: hide-parameter-directions,
      ))
      .join(" ")
  }

  if full-statement == none {
    full-statement = default(statement)
  }

  if type(full-statement) == str {
    if type(parameters) == str {
      full-statement = full-statement.replace("{1}", parameters)
    } else if type(parameters) == array {
      full-statement = full-statement
        .replace("{1}", parameters.at(0, default: "…"))
        .replace("{2}", parameters.at(1, default: "…"))
    }
  }

  if not only-statement {
    full-statement = statement + ": " + full-statement
  }

  if as-hover {
    return link(full-statement.replace(" ", "_").replace("…", "..."), statement)
  }
  return full-statement
}

///
/// Displays a hazard statement.
/// - statement (): the code of the statement to display
/// - variant (): selects which variant to display. only applicable for some statements
/// - parameters (): additional parameters can manually be added and are filled into the hp-statements based on the order they appear in
/// - only-statement (bool): should the code of the statement be displayed
/// - as-hover (bool): Will display statements only as their code, but provides the full statement inside a link so it is shown when hovering over it. May not work in all PDF viewers
/// - validate (): only change this if you are a plugin developer and know you can skip validation
/// -> content
#let h-statement(
  statement,
  variant: auto,
  parameters: (),
  only-statement: false,
  as-hover: false,
  hide-parameter-directions: true,
  validate: true,
) = {
  if validate {
    statement = validate-statement(statement, "H")
  }

  return context {
    get-statement(
      statement,
      variant,
      parameters,
      only-statement,
      as-hover,
      hide-parameter-directions: hide-parameter-directions,
    )
  }
}

///
/// Displays a precautionary statement.
/// - statement (): the code of the statement to display
/// - variant (): selects which variant to display. only applicable for some statements
/// - parameters (): additional parameters can manually be added and are filled into the hp-statements based on the order they appear in
/// - only-statement (bool): should the code of the statement be displayed
/// - as-hover (bool): Will display statements only as their code, but provides the full statement inside a link so it is shown when hovering over it. May not work in all PDF viewers
/// - validate (): only change this if you are a plugin developer and know you can skip validation
/// -> content
#let p-statement(
  statement,
  variant: auto,
  parameters: (),
  only-statement: false,
  as-hover: false,
  hide-parameter-directions: true,
  validate: true,
) = {
  if validate {
    statement = validate-statement(statement, "P")
  }

  return context {
    get-statement(
      statement,
      variant,
      parameters,
      only-statement,
      as-hover,
      hide-parameter-directions: hide-parameter-directions,
    )
  }
}
///
/// Displays a hazard or precautionary statement. The type is inferred from if the code contains an H or a P. if integers are provided it defaults to precautionary statements
/// - statement (): the code of the statement to display
/// - variant (): selects which variant to display. only applicable for some statements
/// - parameters (): additional parameters can manually be added and are filled into the hp-statements based on the order they appear in
/// - only-statement (bool): should the code of the statement be displayed
/// - as-hover (bool): Will display statements only as their code, but provides the full statement inside a link so it is shown when hovering over it. May not work in all PDF viewers
/// - validate (): only change this if you are a plugin developer and know you can skip validation
/// -> content
#let hp(
  statement,
  variant: auto,
  parameters: (),
  only-statement: false,
  as-hover: false,
  hide-parameter-directions: true,
  validate: true,
) = p-statement(
  statement,
  variant: variant,
  parameters: parameters,
  only-statement: only-statement,
  as-hover: as-hover,
  validate: validate,
  hide-parameter-directions: hide-parameter-directions,
)

#let ph-regex = regex("\b([hHpP]?[0-9]{3})(?:\s*\+\s*([hHpP]?[0-9]{3}))*\b")
#let ph-regex-no-whitespace = regex("\b([hHpP][0-9]{3})(?:\s*\+\s*([hHpP][0-9]{3}))*\b")

#let split-statements(statements, h: auto, p: auto, validate: true) = {
  statements = if type(statements) == str {
    statements.matches(ph-regex).map(x => x.text)
  } else if type(statements) == array {
    statements.map(x => x.matches(ph-regex).map(x => x.text)).flatten()
  }
  if h != auto {
    if type(h) == str {
      statements += h.matches(ph-regex).map(x => validate-statement(x.text, "H"))
    } else if type(h) == array {
      statements += h.map(x => x.matches(ph-regex).map(x => validate-statement(x.text, "H"))).flatten()
    }
  }
  if p != auto {
    if type(p) == str {
      statements += p.matches(ph-regex).map(x => validate-statement(x.text, "P"))
    } else if type(p) == array {
      statements += p.map(x => x.matches(ph-regex).map(x => validate-statement(x.text, "P"))).flatten()
    }
  }
  statements
  if validate {
    return statements.map(x => validate-statement(x, "P"))
  } else {
    return statements
  }
}

///
/// Displays multiple hazard and precautionary statements
/// - statements (str|array): a list of statement codes to display.
/// - only-statement (bool): should the code of the statement be displayed
/// - as-hover (bool): Will display statements only as their code, but provides the full statement inside a link so it is shown when hovering over it. May not work in all PDF viewers
/// - validate (bool): only change this if you are a plugin developer and know you can skip validation
/// -> content
#let display-statements(
  statements,
  h: auto,
  p: auto,
  only-statement: false,
  as-hover: false,
  hide-parameter-directions: true,

  validate: true,
) = {
  statements = split-statements(statements, h: h, p: p, validate: validate)
  for value in statements {
    hp(
      value,
      only-statement: only-statement,
      as-hover: as-hover,
      validate: validate,
      hide-parameter-directions: hide-parameter-directions,
    )
    linebreak()
  }
}

#let show-hp(
  body,
  only-statement: true,
  as-hover: true,
  hide-parameter-directions: true,
) = {
  show ph-regex-no-whitespace: it => hp(
    it.text,
    only-statement: only-statement,
    as-hover: as-hover,
    hide-parameter-directions: hide-parameter-directions,
  )
  body
}
