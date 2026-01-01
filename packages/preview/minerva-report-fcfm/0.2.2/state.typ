/// Es `true` si la compilación partió desde el archivo con la
/// show rule `minerva.report`
/// Es `false` si la compilación partió desde un archivo secundario.
#let is-main = state("minerva.is-main", false)