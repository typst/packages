// Web entrypoint: typst compile --features bundle,html --format bundle site.typ out
#import ".zettypst/lib.typ": evaluate, export-html, load

#let project = load()
#assert.eq(project.issues, ())
#let result = evaluate(project)
#export-html(project, result)
