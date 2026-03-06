#let strings = (
  swedish: (
    supervisor: "Handledare",
    examiner: "Examinator",
    external-supervisor: "Extern handledare",
    abstract-title: "Sammanfattning",
    acknowledgments-title: "Författarens tack",
    toc-title: "Innehåll",
    bibliography-title: "Litteratur",
    copyright-title-sv: "Upphovsrätt",
    copyright-title-en: "Copyright",
    university: "Linköpings universitet",
    swedish-summary-title: "POPULÄRVETENSKAPLIG SAMMANFATTNING",
    thesis-label: level => {
      let level-name = if level == "msc" { "avancerad nivå" } else { "grundnivå" }
      let credits = if level == "msc" { "30" } else { "16" }
      "Examensarbete på " + level-name + ", " + credits + "hp"
    },
  ),
  english: (
    supervisor: "Supervisor",
    examiner: "Examiner",
    external-supervisor: "External supervisor",
    abstract-title: "Abstract",
    acknowledgments-title: "Acknowledgments",
    toc-title: "Contents",
    bibliography-title: "Bibliography",
    copyright-title-sv: "Upphovsrätt",
    copyright-title-en: "Copyright",
    university: "Linköping University",
    swedish-summary-title: "POPULÄRVETENSKAPLIG SAMMANFATTNING",
    thesis-label: level => {
      let level-name = if level == "msc" { "Master's" } else { "Bachelor's" }
      let credits = if level == "msc" { "30" } else { "16" }
      level-name + " thesis, " + credits + " ECTS"
    },
  ),
)

#let get-string(language, key) = {
  strings.at(language).at(key)
}
