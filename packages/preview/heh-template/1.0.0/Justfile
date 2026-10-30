demo_file := "manuel.typ"
demo_presentation_file := "demo_presentation.typ"

alias b := build-manuel
alias w := watch-manuel

alias bm := build-monochrome
alias wm := watch-monochrome

alias bp := build-presentation
alias wp := watch-presentation

alias bmp := build-monochrome-presentation
alias wmp := watch-monochrome-presentation

alias fmt := format

# Créer le PDF de démonstration (manuel)
build-manuel:
    typst compile {{ demo_file }}

# Compile le pdf de démonstration (manuel) à chaque changement
watch-manuel:
    typst watch {{ demo_file }}

# Créer le manuel PDF en monochrome
build-monochrome:
    typst compile --input monochrome=true {{ demo_file }}

# Compile le PDF monochrome a chaque changement
watch-monochrome:
    typst watch --input monochrome=true {{ demo_file }}

# Créer le PDF la présentation de démonstration
build-presentation:
    typst compile {{ demo_presentation_file }}

# Créer le PDF la présentation de démonstration à chaque changement
watch-presentation:
    typst watch {{ demo_presentation_file }}

# Créer le PDF la présentation de démonstration en monochrome
build-monochrome-presentation:
    typst compile --input monochrome=true {{ demo_presentation_file }}

# Créer le PDF la présentation de démonstration monochrome a chaque changement
watch-monochrome-presentation:
    typst watch --input monochrome=true {{ demo_presentation_file }}

# Formatte le code avec typstyle
format:
    typstyle -i .
