#import "utils.typ": merge

#let locale-presets = (
  lv: (
    abstract: (
      primary: (
        title: "Anotācija",
        keywords_title: "Atslēgvārdi",
      ),
      secondary: (
        title: "Abstract",
        keywords_title: "Keywords",
      ),
    ),
    bibliography: (
      title: "Izmantotā literatūra un avoti",
    ),
    supplement: (
      appendix: "pielikums",
      figure: "att",
      table: "tabula",
    ),
    thesis: (
      label: (
        bachelor: "Bakalaura darbs",
        master: "Maģistra darbs",
        course: "Kursa darbs",
        qualification: "Kvalifikācijas darbs",
      ),
    ),
    title: (
      page: (
        authors: (
          singular: "Autors:",
          plural: "Autori:",
        ),
        student_id: (
          prefix: (
            singular: "Studenta",
            plural: "Studentu",
          ),
          label: "apliecības Nr.",
        ),
        advisors: (
          prefix: "Darba",
          singular: "vadītājs:",
          plural: "vadītāji:",
        ),
      ),
    ),
    documentary: (
      page: (
        title: "Dokumentārā lapa",
        submitted_line: "Darbs iesniegts Datorikas nodaļā",
        authorized_person: (
          label: "Pilnvarotā persona:",
          title: "vecākā metodiķe",
          name: "Ārija Sproģe",
        ),
        defense_line: (
          bachelor: "Darbs aizstāvēts bakalaura gala pārbaudījuma komisijas sēdē",
          master: "Darbs aizstāvēts maģistra gala pārbaudījuma komisijas sēdē",
        ),
        protocol_label: "prot. Nr.",
        committee_secretary_label: "Komisijas sekretārs(-e):",
        footer: (
          course: "Kursa darbu pārbaudīja komisijas sekretārs (elektronisks paraksts)",
          qualification: "Kvalifikācijas darbu pārbaudījumu komisijas sekretārs (elektronisks paraksts)",
        ),
        authors: (
          singular: "Autors",
          plural: "Autori",
        ),
        advisors: (
          singular: "Vadītājs",
          plural: "Vadītāji",
        ),
        developed_at: "izstrādāts",
        faculty_name: "Latvijas Universitātes Eksakto zinātņu un tehnoloģiju fakultātē",
        declaration: "Ar savu parakstu apliecinu, ka darbs izstrādāts patstāvīgi, izmantoti tikai tajā norādītie informācijas avoti un iesniegtā darba elektroniskā kopija atbilst izdrukai",
        intro_suffix: (
          bachelor: "",
          master: "",
          course: "",
          qualification: " un/vai recenzentam uzrādītajai darba versijai",
        ),
        recommendation: [Rekomendēju/nerekomendēju darbu aizstāvēšanai _(nederīgo svītro vadītājs)_],
        reviewer_label: "Recenzents",
      ),
    ),
  ),
  en: (
    abstract: (
      primary: (
        title: "Abstract",
        keywords_title: "Keywords",
      ),
      secondary: (
        title: "Summary",
        keywords_title: "Keywords",
      ),
    ),
    bibliography: (
      title: "References",
    ),
    supplement: (
      appendix: "appendix",
      figure: "fig.",
      table: "table",
    ),
    thesis: (
      label: (
        bachelor: "Bachelor's Thesis",
        master: "Master's Thesis",
        course: "Course Paper",
        qualification: "Qualification Thesis",
      ),
    ),
    title: (
      page: (
        authors: (
          singular: "Author:",
          plural: "Authors:",
        ),
        student_id: (
          prefix: (
            singular: "Student",
            plural: "Students",
          ),
          label: "ID No.",
        ),
        advisors: (
          prefix: "Thesis",
          singular: "advisor:",
          plural: "advisors:",
        ),
      ),
    ),
    documentary: (
      page: (
        title: "Documentary Page",
        submitted_line: "Submitted to the Department of Computer Science on",
        authorized_person: (
          label: "Authorized officer:",
          title: "",
          name: "",
        ),
        defense_line: (
          bachelor: "Defended before the bachelor's final examination committee on",
          master: "Defended before the master's final examination committee on",
        ),
        protocol_label: "protocol No.",
        committee_secretary_label: "Committee secretary:",
        footer: (
          course: "The course paper was checked by the committee secretary (electronic signature)",
          qualification: "The qualification examination committee secretary verified the thesis (electronic signature)",
        ),
        authors: (
          singular: "Author",
          plural: "Authors",
        ),
        advisors: (
          singular: "Advisor",
          plural: "Advisors",
        ),
        developed_at: "developed at",
        faculty_name: "the Faculty of Exact Sciences and Technology, University of Latvia",
        declaration: "By signing, I confirm that the thesis was developed independently, only the cited sources were used, and the submitted electronic copy matches the printed version",
        intro_suffix: (
          bachelor: "",
          master: "",
          course: "",
          qualification: " and/or the version shown to the reviewer",
        ),
        recommendation: [I recommend/do not recommend the thesis for defense _(strike out as appropriate)_],
        reviewer_label: "Reviewer",
      ),
    ),
  ),
)

#let resolve-labels(locale, labels) = {
  let base = locale-presets.at(locale, default: locale-presets.lv)
  merge(base, labels)
}
