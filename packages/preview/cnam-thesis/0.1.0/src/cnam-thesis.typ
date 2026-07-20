#import "cnam-theme.typ": *
#import "cnam-helper.typ": *

#let cnam-thesis(
    title: "Titre de la thèse",
    author: "Nom de l'auteur",
    thesis-info: thesis-info-default,
    lang: "fr",
    open-right: true,
    body
) = context {
    // Merge the default thesis info with the provided thesis info
    let cnam-thesis-info = thesis-info-default + thesis-info
     if cnam-thesis-info.logo != none {
        cnam-states.logo.update(cnam-thesis-info.logo)
    }
    cnam-states.lang.update(lang)
    cnam-states.note-counter.step()

    set bibliography(style: "./resources/IEEEtran-francais.csl")

    bookly(
        title: title,
        author: author,
        fonts: cnam-fonts,
        theme: cnam,
        colors: cnam-colors,
        lang: lang,
        title-page: cnam-titlepage(cnam-thesis-info),
        config-options: (
            open-right: open-right,
            par-indent: true
        ),
        body
    )
}
