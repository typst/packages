#let literals = (
  en: (
    university: "Slovak Technical University in Bratislava",
    faculty: "Faculty of Informatics and Information Technologies",
    title-page: (
      fields: (
        program: "Programme",
        field: "Study field",
        department: "Department",
        supervisor: "Supervisor",
      ),
      values: (
        month: (
          may: "May",
        ),
        thesis: (
          bp2: "Bachelor thesis",
          dp3: "Diploma thesis",
          bp1: "Interim report on BP1",
          dp1: "Interim report on DP1",
          dp2: "Interim report on DP2",
        ),
        program: (
          informatics: "Informatics",
        ),
        field: (
          informatics: "Informatics",
        ),
        department: (
          upai: "Institute of Computer Engineering and Applied Informatics",
          iise: "Institute of Informatics, Information Systems and Software Engineering",
        ),
      ),
    ),
    annotation: (
      title: "Annotation",
      author: "Author",
    ),
    acknowledgment: "Acknowledgment",
    contents: (
      title: "Contents",
      tables: "List of tables",
      figures: "List of figures",
      abbreviations: "List of abbreviations",
    ),
    chapter: (
      title: "Chapter",
    ),
    figures: (
      raw: "Listing",
      table: "Table",
      figure: "Figure",
    ),
    appendix: "Appendix",
    legacy-appendix: "Appendix",
    bibliography: "Bibliography",
  ),
  sk: (
    university: "Slovenská technická univerzita v Bratislave",
    faculty: "Fakulta informatiky a informačných technológií",
    title-page: (
      fields: (
        program: "Študijný program",
        field: "Študijný odbor",
        department: "Miesto vypracovania",
        supervisor: "Vedúci práce",
      ),
      values: (
        month: (
          may: "Máj",
        ),
        thesis: (
          bp2: "Bakalárska práca",
          dp3: "Diplomová práca",
          bp1: "Priebežná správa o riešení BP1",
          dp1: "Priebežná správa o riešení DP1",
          dp2: "Priebežná správa o riešení DP2",
        ),
        program: (
          informatics: "Informatika",
        ),
        field: (
          informatics: "Informatika",
        ),
        department: (
          upai: "Ústav informatiky, informačných systémov a softvérového inžinierstva",
          iise: "Ústav počítačového inžinierstva a aplikovanej informatiky",
        ),
      ),
    ),
    annotation: (
      title: "Anotácia",
      author: "Autor",
    ),
    acknowledgment: "Poďakovanie",
    contents: (
      title: "Obsah",
      tables: "Zoznam tabuliek",
      figures: "Zoznam obrázkov",
      abbreviations: "Zoznam použitých skratiek",
    ),
    chapter: (
      title: "Kapitola",
    ),
    figures: (
      raw: "Výpis",
      table: "Tabuľka",
      figure: "Obrázok",
    ),
    appendix: "Príloha",
    legacy-appendix: "Dodatok",
    bibliography: "Literatúra",
  ),
)

#let localization(lang: "sk") = {
  assert(
    lang == "en" or lang == "sk",
    message: "please select a valid language for localization to work",
  )
  return literals.at(lang)
}
