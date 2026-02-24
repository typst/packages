#let get-language-index(lang)={
  if lang == "en"{1}
  else if lang == "de"{0}
  else if lang == "fr"{2}
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

#let get-statement(statement, variant, parameters, default: x=> "no statement found: " + repr(x))={
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
    
    return full-statement
  }
}

#let h-statement(statement, variant: auto, parameters: (), only-statement:false, validate: true)={
  if validate{
   statement = validate-statement(statement, "H")
  }
  
  let full-statement = get-statement(statement, variant, parameters)

  if only-statement{
    return full-statement
  }else{
    return statement +": "+ full-statement
  }
}

#let p-statement(statement, variant: auto, parameters: (), only-statement:false, validate: true)={
  if validate{
   statement = validate-statement(statement, "P")
  }
  
  let full-statement = get-statement(statement, variant, parameters)

  if only-statement{
    return full-statement
  }else{
    return statement +": "+ full-statement
  }
}

#let hp(statement, variant: auto, parameters: (), only-statement:false, validate: true)= p-statement(statement, variant:variant, parameters:parameters, only-statement:only-statement, validate:validate)

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

#let display-statements(statements, only-statement:false, validate: true)={
  statements = split-statements(statements, validate:validate)
  for value in statements {
    hp(value, only-statement:only-statement, validate:validate)
    linebreak()
  }
}