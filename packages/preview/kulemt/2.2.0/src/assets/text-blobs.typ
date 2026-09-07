// Front-page wording.
//
// Everything here is FIXED text that is the same for every student: the
// designations from kulemt-cfg.dtx (the \l_kulemt_cfg_prop defaults), the
// copyright notice, and the faculty name and address.
//
// Programme names and options are NOT here. There is deliberately no copy of
// kulemt.ini and no reader for it: the student types their own programme and
// option, copied from the faculty page. One less thing to keep in sync, and
// nothing here can go stale when a programme is renamed.
//
// kulemt applies "ucfirst" to the designations, so they are stored already
// capitalised. Which language is used is decided by the MASTER'S PROGRAMME
// language (`english-master`), not the language the thesis is written in --
// that is what kulemt does, see \kulemt_selectlanguage:V
// \l_kulemt_master_language_tl in kulemt-front.dtx.

#let strings = (
  en: (
    title-pre: "Thesis submitted for the degree of",
    acyear-pre: "Academic year",
    conjunction: "and",
    promoter: ("Supervisor", "Supervisors"),
    assessor: ("Assessor", "Assessors"),
    assistant: ("Assistant-supervisor", "Assistant-supervisors"),
    publisher-pre: "Published by",
  ),
  nl: (
    title-pre: "Thesis voorgedragen tot het behalen van de graad van",
    acyear-pre: "Academiejaar",
    conjunction: "en",
    promoter: ("Promotor", "Promotoren"),
    assessor: ("Evaluator", "Evaluatoren"),
    assistant: ("Begeleider", "Begeleiders"),
    publisher-pre: "Uitgegeven in eigen beheer door",
  ),
)

// text.copyright.* as shipped in kulemt.ini. Fixed text, identical for every
// programme.
#let copyright-text = (
  en: [
    All rights reserved. No part of the publication may be reproduced in any
    form by print, photoprint, microfilm, electronic or any other means
    without written permission from the publisher. This publication contains
    the study work of a student in the context of the academic training and
    assessment. After this assessment no correction of the study work took
    place.
  ],
  nl: [
    Alle rechten voorbehouden. Niets uit deze uitgave mag worden
    vermenigvuldigd en/of openbaar gemaakt worden door middel van druk,
    fotokopie, microfilm, elektronisch of op welke andere wijze ook zonder
    voorafgaande schriftelijke toestemming van de uitgever. Deze uitgave
    bevat het studiewerk van een student in het kader van de academische
    opleiding en examenbeoordeling. Na deze beoordeling vond geen correctie
    plaats van het studiewerk.
  ],
)

// The [defaults] section of kulemt.ini: the faculty, and the address used when
// a programme defines none of its own. Students override `address` with their
// own department.
#let faculty-default = (
  en: "Faculty of Engineering Science",
  nl: "Faculteit Ingenieurswetenschappen",
)

#let address-default = (
  en: "Faculty of Engineering Science, Kasteelpark Arenberg 1 bus 2200, B-3001 Leuven",
  nl: "Faculteit Ingenieurswetenschappen, Kasteelpark Arenberg 1 bus 2200, B-3001 Leuven",
)

/// Strings for the master's programme language.
/// -> dictionary
#let master-strings(english-master) = strings.at(
  if english-master { "en" } else { "nl" },
)

/// Join names the way kulemt does (\seq_use:Nnnn, kulemt-front.dtx).
///
///   one    -> "A"
///   two    -> "A and B"     / "A en B"
///   three+ -> "A, B, and C" / "A, B en C"   (no Oxford comma in Dutch)
/// -> str
#let join-names(names, lang: "en") = {
  let conj = strings.at(lang).conjunction
  if names.len() == 0 {
    ""
  } else if names.len() == 1 {
    names.at(0)
  } else if names.len() == 2 {
    names.at(0) + " " + conj + " " + names.at(1)
  } else {
    let oxford = if lang == "nl" { " " } else { ", " }
    names.slice(0, -1).join(", ") + oxford + conj + " " + names.last()
  }
}

/// The degree line on the cover and title page:
///   <title.pre> <programme name>[, <option> and <option>]
/// -> content
#let submission-text(name, options, english-master: false) = {
  let s = master-strings(english-master)
  let lang = if english-master { "en" } else { "nl" }
  [#s.title-pre #name]
  if options.len() > 0 {
    [, #join-names(options, lang: lang)]
  }
}

/// Normalise the `degree` argument. Free text -- nothing is looked up and
/// nothing is validated. `options` may be a single string or an array.
/// -> dictionary
#let normalise-degree(degree) = {
  let name = degree.at("name", default: none)
  if name == none {
    panic(
      "degree needs a `name`: the full official programme name, copied from "
        + "https://eng.kuleuven.be/docs/kulemt -- e.g. "
        + "\"Master of Science in Electrical Engineering\".",
    )
  }
  let opts = degree.at("options", default: degree.at("option", default: ()))
  if type(opts) == str { opts = (opts,) }
  (name: name, options: opts)
}
