#let template-names = ("default", "mai-university-lab")

#let title-template-factory(template, arguments-function) = {
    return (..arguments) => template(..arguments-function(..arguments))
}

#let custom-title-template(module) = {
    title-template-factory(module.template, module.arguments)
}

#let templates = {
    let result = (:)
    for template in template-names {
        import "/src/title-templates/" + template + ".typ" as module
        result.insert(template, title-template-factory(module.template, module.arguments))
    }
    result
}