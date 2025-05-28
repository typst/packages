#let value(en: "", de: "") = {
  context {
    if text.lang == "en" {
      return en
    }

    if text.lang == "de" {
      return de
    }

    return "Unknown language"
  }
}

#let translations = (
  bachelor-thesis: value(
    en: "Bachelor thesis",
    de: "Bachelor-Arbeit",
  ),
  bachelor-thesis-to-get-bsc: value(
    en: "for achieving the acedemic degree Bachelor of Science - B.Sc.",
    de: "zur Erlangung des akademischen Grades Bachelor of Science - B.Sc.",
  ),
  master-thesis: value(
    en: "Master thesis",
    de: "Masterarbeit",
  ),
  faculty-of: value(
    en: "Faculty of",
    de: "Fachbereich",
  ),
  department-of: value(
    en: "Department of",
    de: "Studiengang",
  ),
  bachelor-thesis-submitted-for-examination-in-bachelors-degree: value(
    en: "Bachelor thesis submitted for examination in Bachelor's degree",
    de: "Bachelorarbeit eingereicht im Rahmen der Bachelorprüfung",
  ),
  master-thesis-submitted-for-examination-in-masters-degree: value(
    en: "Master thesis submitted for examination in Master's degree",
    de: "Masterarbeit eingereicht im Rahmen der Masterprüfung",
  ),
  study-course: value(
    en: "study course",
    de: "Studiengang",
  ),
  in-the-study-course: value(
    en: "in the study course",
    de: "im Studiengang",
  ),
  at-the-department: value(
    en: "at the Department",
    de: "am Department",
  ),
  at-the-faculty-of: value(
    en: "at the Faculty of",
    de: "der Fakultät",
  ),
  at-university-of-applied-science-wiesbaden: value(
    en: "at University of Applied Science Wiesbaden",
    de: "der Hochschule für Angewandte Wissenschaften Wiesbaden",
  ),
  supervising-examiner: value(
    en: "Supervising examiner",
    de: "Betreuender Prüfer",
  ),
  second-examiner: value(
    en: "Second examiner",
    de: "Zweitgutachter",
  ),
  external-supervisor: value(
    en: "External superviser",
    de: "Externer Betreuer",
  ),
  submitted: value(
    en: "Submitted",
    de: "Eingereicht am",
  ),
  list-of-figures: value(
    en: "List of Figures",
    de: "Abbildungsverzeichnis",
  ),
  list-of-tables: value(
    en: "List of Tables",
    de: "Tabellenverzeichnis",
  ),
  listings: value(
    en: "Listings",
    de: "Listings",
  ),
  declaration-of-independent-processing: value(
    en: "Declaration of Independent Processing",
    de: "Eigenständigkeitserklärung",
  ),
  declaration-of-independent-processing-content: value(
    en: "I confirm that I have written this thesis independently and have not used any sources or aids other than those specified.

I am responsible for the quality of the content, which I have substantiated or supported with suitable scientific sources. I have clearly labelled the texts, ideas, concepts, graphics, technical content and the like taken directly or indirectly from external sources in my explanations and have provided complete references to the respective source. All other contents of this work (text sections, illustrations, tables, etc.) without corresponding references are mine in the sense of copyright law.

I am aware that AI-generated content may be incorrect. I therefore affirm that I have only used AI tools as an aid and that my creative influence predominates in this work. I am responsible for the adoption of any AI-generated content
AI-generated content used by me. 

This thesis has not been submitted in the same or a similar form to any other examination authority in Germany or abroad. I am aware that a violation of the above points may be considered an attempt to cheat and may have consequences under examination law. In particular, it may result in the examination being failed and, in the event of multiple or serious attempts at cheating, exmatriculation may be threatened.",

    de: "Ich versichere, dass ich die vorliegende Arbeit selbstständig verfasst und keine anderen als die angegebenen Quellen und Hilfsmittel benutzt habe.

Ich bin verantwortlich für die Qualität des Inhalts, den ich mit geeigneten wissenschaftlichen Quellen belegt bzw. gestützt habe. Die aus fremden Quellen direkt oder indirekt übernommenen Texte, Gedankengänge, Konzepte, Grafiken, technischen Inhalte und ähnliches in meinen Ausführungen habe ich eindeutig gekennzeichnet und mit vollständigen Verweisen auf die jeweilige Quelle versehen. Alle weiteren Inhalte dieser Arbeit (Textteile,Abbildungen, Tabellen etc.) ohne entsprechende Verweise stammen im urheberrechtlichen Sinn von mir.

Ich bin mir bewusst, dass KI-generierte Inhalte falsch sein können. Ich versichere daher, dass ich KI-Tools lediglich als Hilfsmittel verwendet habe und in der vorliegenden Arbeit mein gestalterischer Einfluss überwiegt. Ich verantworte die Übernahme jeglicher von mir
verwendeter KI-generierter Inhalte vollumfänglich selbst. 

Die vorliegende Arbeit wurde bisher weder im In- noch im Ausland in gleicher oder ähnlicher Form einer anderen Prüfungsbehörde vorgelegt. Mir ist bekannt, dass ein Verstoß gegen die genannten Punkte als Täuschungsversuch gelten und prüfungsrechtliche Konsequenzen haben kann. Insbesondere kann es dazu führen, dass die Leistung nicht bestanden ist und dass bei mehrfachem oder schwerwiegendem Täuschungsversuch eine Exmatrikulation droht.",
  ),
  place: value(
    en: "Place",
    de: "Ort",
  ),
  date: value(
    en: "Date",
    de: "Datum",
  ),
  signature: value(
    en: "Original Signature",
    de: "Unterschrift im Original",
  ),
  glossary: value(
    en: "Glossary",
    de: "Glossar",
  ),
  bibliography: value(
    en: "Bibliography",
    de: "Bibliographie"
  )
)
