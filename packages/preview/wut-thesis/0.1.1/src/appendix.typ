#import "@preview/linguify:0.4.2": *

// --- Appendices styling settings ---
// You probably shouldn't modify these settings unless you know what you are doing
#let appendix(lang, body) = [
  #let linguify-database = toml("lang.toml")
  #let appendix-text = linguify("appendix", from: linguify-database, lang: lang)
  #let appendices-text = linguify(
    "appendix-outline",
    from: linguify-database,
    lang: lang,
  )
  #show outline: set heading(outlined: true)
  #outline(title: appendices-text, target: selector(heading).after(
    <appendix_cutoff_label>,
  ))

  // Reset different counters
  //
  // DO NOT MODIFY/MOVE `appendix_cutoff_label`, as it is used to filter out appendices
  // from the main outline
  #counter(heading).update(0)<appendix_cutoff_label>
  #counter(figure.where(kind: table)).update(0)
  #counter(figure.where(kind: image)).update(0)
  #counter(figure.where(kind: raw)).update(0)

  // Set numberings
  #let figure-numbering(.., last) = "A." + str(last)
  #set figure(outlined: false, numbering: figure-numbering)
  #show heading: set heading(
    numbering: "A.1",
  )
  #show heading.where(level: 1): set heading(
    numbering: num => appendix-text + numbering(" A", num),
    supplement: appendix-text,
  )

  #body
]
