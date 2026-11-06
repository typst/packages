#let parse-yaml-entries(content) = {
  let entries = ()
  let lines = content.split("\n")
  
  let current-term = none
  let current-definition = none
  
  for line in lines {
    let trimmed = line.trim()
    
    // Ignorar linhas vazias e comentários
    if trimmed == "" or trimmed.starts-with("#") {
      continue
    }
    
    // Processar entrada de termo
    if trimmed.starts-with("- term:") {
      // Se já temos um termo anterior, guardar
      if current-term != none and current-definition != none {
        entries.push((term: current-term, definition: current-definition))
      }
      
      // Extrair novo termo
      current-term = trimmed.slice(7).trim()
      current-definition = none
    }
    // Processar definição
    else if trimmed.starts-with("definition:") {
      current-definition = trimmed.slice(11).trim()
    }
  }
  
  // Adicionar último termo se existir
  if current-term != none and current-definition != none {
    entries.push((term: current-term, definition: current-definition))
  }
  
  return entries
}

#let render-entries(entries) = {
  for entry in entries {
    [*#entry.term* -- #entry.definition]
    parbreak()
  }
}

#let load-and-render-yaml(filepath) = {
  let content = read(filepath)
  let entries = parse-yaml-entries(content)
  render-entries(entries)
}

