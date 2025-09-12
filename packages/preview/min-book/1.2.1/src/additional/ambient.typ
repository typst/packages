/**
== Appendices Command

:appendices:

Creates an special ambient to write or include multiple appendices. An
appendix is any important additional data left out of the main document for
some reason, but directly referenced or needed by it. Inside this ambient,
all level 1 heading is a new appendix.
**/
#let appendices(
  type: "appendix",
  title: auto, /// <- array of strings | auto
    /** `(singular, plural)`
    Appendix singular and plural names — if not set, fallback to "Appendix" and
    "Appendices" in book language. |**/
  numbering: ( /// <- array of strings | string
    "",
    "{2:A}.\n",
    "{2:A}.{3:1}. ",
    "{2:A}.{3:1}.{4:1}. ",
    "{2:A}.{3:1}.{4:1}.{5:1}. ",
    "{2:A}.{3:1}.{4:1}.{5:1}.{6:a}. ",
  ),
    /** Custom appendices numbering — a standard numbering or a #univ("numbly")
    numbering. |**/
  body /// <- content
    /// The appendices content. |
) = context {
  import "../utils.typ"
  import "@preview/transl:0.1.0": transl
  
  let singular-title = transl(type, args: (number: "sing"), mode: str)
  let plural-title = transl(type, args: (number: "plur"), mode: str)
  let break-to = utils.storage(get: "break-to")
  
  set heading(
    offset: 1,
    numbering: utils.numbering(
        patterns: (numbering,),
        scope: (
          h1: "",
          h2: singular-title,
          n: 1
        )
      ),
    supplement: singular-title
  )
  
  show heading.where(level: 2): it => {
    pagebreak(to: break-to)
    it
  }
  
  
  pagebreak(weak: true, to: break-to)
  
  // Main title (plural)
  heading(
    plural-title,
    level: 1,
    numbering: none
  )
  
  counter(heading).update(0)
  
  body
}


/** 
== Annexes Command

:annexes:

Creates an special ambient to write or include multiple annexes. An annex is
any important third-party data directly cited or referenced in the main
document. Inside this ambient, all level 1 heading is a new annex.
**/
#let annexes(
  type: "annex",
  title: auto, /// <- auto | array
    /** Annex singular and plural names — if not set, fallback to "Annex" and
    "Annexes" in book language. |**/
  numbering: ( /// <- array of strings | string
    "",
    "{2:A}.\n",
    "{2:A}.{3:1}. ",
    "{2:A}.{3:1}.{4:1}. ",
    "{2:A}.{3:1}.{4:1}.{5:1}. ",
    "{2:A}.{3:1}.{4:1}.{5:1}.{6:a}. ",
  ),
    /** Custom annexes numbering — a standard numbering, or a #univ("numbly")
    numbering. |**/
  body /// <- contents
    /// The annexes content. |
) = appendices(
  type: type,
  title: title,
  numbering: numbering,
  body
)
