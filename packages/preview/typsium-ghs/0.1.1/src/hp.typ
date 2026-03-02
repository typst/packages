#let get-language-index(lang)={
  if lang == "en"{1}
  else if lang == "de"{0}
  else if lang == "fr"{2}
  else if lang == "it"{3} 
  else{1}
}

#let database = state("hp-statements", csv("resources/hp-statements.tsv", delimiter: "\t", row-type: dictionary))

#let validate-string(statement, substitute)={
    if statement.contains(regex("p|P")){
      substitute = "P"
    } else if statement.contains(regex("h|H")){
      substitute = "H"
    }
    
  statement = statement.replace(regex("[A-Za-z ,-]"), "")
    statement = upper(statement)

    statement = statement.replace(regex("(\d+)"), x=> substitute + x.text)

    return statement
}

#let validate-statement(statement, substitute)={
  if type(statement) == int {
     substitute + str(statement)
    } else if type(statement) == str{
      validate-string(statement, substitute)
    } else if type(statement) == content{
      validate-string(statement.text(), substitute)
    }
}

#let get-statement(statement, variant, parameters, only-statement, as-hover,default: x=> "no statement found: " + repr(x))={
  let x = parameters.len()
  let parameterlen = if type(parameters) == str{
    "-1"
  }else {
    if parameters.len() > 0 {"-"+str(parameters.len())}else{""}
  }
  
  context {
    let lang-index = get-language-index(text.lang)
    let db = database.get().at(lang-index)
    let full-statement
    if variant != auto{
      let variant = "."+ str(variant)
      full-statement = db.at(statement + variant + parameterlen, default: db.at(statement + variant, default: db.at(statement, default: none)))
    }else{
      full-statement = db.at(statement + parameterlen, default: db.at(statement, default: none))
    }
    
    if full-statement == none {
      if statement.contains("+"){
        full-statement = statement.split("+").map(x=> db.at(x, default:"")+ " ").sum()
      }
    }
    
    if full-statement == none {
      full-statement = default(statement)
    }

    if type(full-statement) == str{
      if type(parameters) == str{
        full-statement = full-statement.replace("{1}", parameters)
      } else if type(parameters) == array{
        full-statement = full-statement.replace("{1}", parameters.at(0, default: "…"))
        .replace("{2}", parameters.at(1, default: "…"))
      }
    }

    if not only-statement{
      full-statement = statement +": "+ full-statement
    }

    if as-hover{
      return link(full-statement.replace(" ", "_"), statement)
    }
    return full-statement
  }
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
#let h-statement(statement, variant: auto, parameters: (), only-statement:false, as-hover:false, validate: true)={
  if validate{
   statement = validate-statement(statement, "H")
  }
  
  return get-statement(statement, variant, parameters, only-statement, as-hover)
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
#let p-statement(statement, variant: auto, parameters: (), only-statement:false,as-hover:false,  validate: true)={
  if validate{
   statement = validate-statement(statement, "P")
  }

  return get-statement(statement, variant, parameters, only-statement, as-hover)
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
#let hp(statement, variant: auto, parameters: (), only-statement:false,as-hover:false,  validate: true)= p-statement(statement, variant:variant, parameters:parameters, only-statement:only-statement, as-hover: as-hover, validate:validate)

#let split-statements(statements, validate: true)={
  statements = if type(statements) == str{
    statements.split(regex("[,\s\-]+")).filter(x=> x.len() != 0)
  } else if type(statements) == array{
    statements.map(x=> x.split(regex("[,\s\-]+"))).flatten().filter(x=> x.len() != 0)
  }
  if validate{
    statements.map(x=> validate-statement(x, "P"))
  }else{
    statements
  }
}

/// 
/// Displays multiple hazard and precautionary statements
/// - statements (str|array): a list of statement codes to display.
/// - only-statement (bool): should the code of the statement be displayed
/// - as-hover (bool): Will display statements only as their code, but provides the full statement inside a link so it is shown when hovering over it. May not work in all PDF viewers
/// - validate (bool): only change this if you are a plugin developer and know you can skip validation
/// -> content
#let display-statements(statements, only-statement:false, as-hover:false, validate: true)={
  statements = split-statements(statements, validate:validate)
  for value in statements {
    hp(value, only-statement:only-statement,as-hover:as-hover, validate:validate)
    linebreak()
  }
}
