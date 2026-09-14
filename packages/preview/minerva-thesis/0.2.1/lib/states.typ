#let thesis-authors = state("thesis.authors", none)
#let thesis-title = state("thesis.title", none)
#let thesis-description = state("thesis.description", none)
#let thesis-keywords = state("thesis.keywords", none)
#let thesis-faculty = state("thesis.faculty", none)
#let thesis-language = state("thesis.language", "EN")
#let thesis-supervisors = state("thesis.supervisors", none)
#let thesis-multiple-supervisors = state("thesis.multiple-supervisors", true)
#let thesis-counsellors = state("thesis.counsellors", none)
#let thesis-multiple-counsellors = state("thesis.multiple-counsellors", true)
#let thesis-date = state("thesis.date", none)

#let store = state("store","m")
#let filled-outline=state("filled-outline", false)

#let show-heading = state("show-heading", false)
#let part-heading = state("part-heading", false)

#let figure-settings = state("figure-settings", (:))

#let content-switch = state("content.switch", false)
#let show-page-number = state("show-page-number", true)
#let page-number-shown = state("page-number-shown", false)
#let page-number-on-page = state("page-number-on-page", true)
#let page-number-width = state("page-number-width", 2em)



