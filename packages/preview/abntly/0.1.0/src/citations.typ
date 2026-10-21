// The citations (NBR 10520:2023) and the list of references (NBR 6023:2025), over Typst's own `cite` and
// `bibliography` with the CSL of the package (csl/abnt-6023.csl). The author chooses the system of the calls in the
// main function, `citation-system`: "alf", author-date, "(Silva, 2020, p. 4)"; "num", numeric between parentheses,
// "(1, p. 30)"; "overcite", the number as a superscript; "ieee", the number between brackets, "[1, p. 30]". The
// system changes only the block `<citation>` of the CSL, swapped here as text; the list is the same, in alphabetical
// order (6023, 9.1) or in the order of the first call (9.2). The forms of `cite` the author writes: `@key` or
// `@key[p. 4]`, the call as it goes; `#cite(<key>, form: "prose")`, the author in the sentence, "Silva e Souza (2020,
// p. 4)" (10520, 6.1.4); `form: "author"`, the names alone; `form: "full"`, the reference. Typst writes the prose form
// from the same `<citation>` block as the normal call, so the prose and author forms are issued again as normal calls
// in a style of their own, between zero-width joiners (two calls in a row would be merged into one call in the style
// of the first). `apud` writes the citation of a citation (10520, 7.3): the original work as the author gives it,
// "apud" and the call of the source consulted, without its parentheses, in a style of its own too (the form "bare").
#import "spacing.typ": single-spacing

/// The systems of the calls, the values of `citation-system`.
#let citation-systems = ("alf", "num", "overcite", "ieee")

// the CSL of the package, as text, and one replacement in it: exactly one occurrence, or the file changed under us
#let base = read("csl/abnt-6023.csl")
#let swap(text, old, new) = {
  let n = text.matches(old).len()
  assert(n == 1, message: "abntly: the CSL has " + str(n) + " of " + repr(old) + ", expected one")
  text.replace(old, new)
}

// the block <citation> of each system and form. The author-date one is the file's (the names with "; ", in upper
// and lower case, 10520 6.1.1.1; the year; the page; the works in alphabetical order, 6.1.8; "(Barbosa, C., 1958)",
// 6.1.5; "2020a", 6.1.6). In the sentence, the names with ", " and "e" (`sentence-names`) and the year between
// parentheses (6.1.4); the numeric calls take the number of the work, with the page after a comma (6.2.4).
#let citation(system, form) = {
  let names = "<text macro=\"sentence-names\"/>"
  let year = "<text macro=\"issued-year\"/>"
  let locator = "<text macro=\"citation-locator\"/>"
  let number = "<text variable=\"citation-number\"/>"
  let disambiguation = ("disambiguate-add-year-suffix=\"true\" disambiguate-add-givenname=\"true\" "
    + "givenname-disambiguation-rule=\"by-cite\"")
  let in-sentence(call) = ("<citation " + disambiguation + "><layout delimiter=\"; \"><group delimiter=\" \">"
    + names + call + "</group></layout></citation>")
  let affixes = (num: "prefix=\"(\" suffix=\")\"", overcite: "vertical-align=\"sup\"", ieee: "prefix=\"[\" suffix=\"]\"")
  if system == "alf" {
    if form == "prose" {
      in-sentence("<group prefix=\"(\" suffix=\")\" delimiter=\", \">" + year + locator + "</group>")
    } else if form == "author" {
      "<citation " + disambiguation + "><layout delimiter=\"; \">" + names + "</layout></citation>"
    } else if form == "bare" {
      // the call of the file without its parentheses, for the second half of an `apud`: "Suassuna, 1995, p. 55"
      ("<citation " + disambiguation + "><layout delimiter=\"; \"><group delimiter=\", \">"
        + "<text macro=\"call-names\"/>" + year + locator + "</group></layout></citation>")
    } else { none }
  } else {
    // the works of one call inside one pair of affixes, "(5, 7)" (6.2.3), each with its page, "(1, p. 30)"
    let call = "<group delimiter=\", \">" + number + locator + "</group>"
    if form == "prose" {
      in-sentence("<group " + affixes.at(system) + ">" + call + "</group>")
    } else if form == "author" {
      "<citation><layout delimiter=\"; \">" + names + "</layout></citation>"
    } else if form == "bare" {
      // the number and the page alone, on the line of the text, in every numeric system: "apud 5, p. 55"
      "<citation><layout delimiter=\", \">" + call + "</layout></citation>"
    } else { "<citation><layout " + affixes.at(system) + " delimiter=\", \">" + call + "</layout></citation>" }
  }
}

// the CSL of a system and a form, as `bibliography` and `cite` take it: the numeric systems also sort the list by
// the number of the first call and open each entry with it, "1 CRETELLA JÚNIOR, José." (6023, 9.2, no brackets)
#let style-of(system, form) = {
  let text = base
  let block = citation(system, form)
  if block != none { text = swap(text, regex("<citation[\\s\\S]*?</citation>"), block) }
  if system != "alf" {
    text = swap(text, "<key macro=\"sort-names\"/>\n      <key variable=\"issued\"/>", "<key variable=\"citation-number\"/>")
    text = swap(text, "    <layout>\n      <choose>\n        <if type=\"article-journal",
      "    <layout>\n      <text variable=\"citation-number\" suffix=\" \"/>\n      <choose>\n        <if type=\"article-journal")
  }
  bytes(text)
}

// --- a work without an author ---------------------------------------------------------------------------------------
// The call and the entry of a work without an author are its title (10520, 6.1.1.4; 6023, 8.1.4): the CSL writes
// the title between two private-use marks (a plain `<text>` with affixes: inside a `<choose>` hayagriva drops them),
// and the rules below write it as the norms ask. In a call, the first word and "[...]", or the article or
// monosyllable that opens the title and the next word ("Anteprojeto [...]", "A flor [...]", "Nos canaviais [...]"),
// unless the .bib gives a `shorttitle`, which goes as the author wrote it. In the list, the first word in capitals,
// with the article or monosyllable before it (6023, 6.7 and 8.2.1: "OS GRANDES clássicos"), and without the
// highlight of a title (6.7).
#let call-marks = ("\u{E004}", "\u{E005}")
#let entry-marks = ("\u{E009}", "\u{E00A}")

// the words that open a title with the next one: the articles and the monosyllables of 10520, 6.1.1.4 c and d, and
// of 6023, 6.7 ("artigo (definido ou indefinido) e palavra monossilábica iniciais"), read as the function words of
// the languages of the package (a one-syllable name such as "John" stays alone: 6023's example "JOHN Mayall")
#let openers = ("o", "a", "os", "as", "um", "uma", "uns", "umas", "ao", "aos", "à", "às", "no", "na", "nos", "nas",
  "do", "da", "dos", "das", "de", "em", "por", "com", "sem", "sob", "se", "que", "e", "ou", "the", "an", "of", "in",
  "on", "at", "to", "by", "el", "la", "los", "las", "un", "una", "del", "al", "en", "le", "les", "des", "du", "der",
  "die", "das", "ein", "eine")

// how many words open the title: two after an article or a monosyllable, one otherwise
#let lead(words) = {
  let head = lower(words.first()).trim(regex("[.,;:!?]"), at: end)
  if words.len() > 1 and head in openers { 2 } else { 1 }
}

// the title in a call: its opening words and "[...]"; the subtitle is not part of it. A `shorttitle` of the .bib
// comes here too (the CSL prints the short form, or the title without one): one that the author already cut
// ("Pequena [...]") goes as it is
#let title-call(title) = {
  if title.contains("[...]") { return title }
  let words = title.trim().split(":").first().trim().split(regex("\\s+")).filter(w => w != "")
  if words.len() == 0 { return title }
  let n = lead(words)
  let kept = words.slice(0, n).join(" ").trim(regex("[.,;!?]"), at: end)
  if n >= words.len() { kept } else { kept + " [...]" }
}

// the title that opens an entry: its opening words in capitals
#let title-entry(title) = {
  let words = title.split(" ")
  let n = calc.min(lead(words), words.len())
  (words.slice(0, n).map(upper) + words.slice(n)).join(" ")
}

// the highlight of a title ends at its subtitle (6023, 8.2): the .bib gives "Título: subtítulo" in one field,
// because hayagriva drops `subtitle`, and the CSL highlights the whole field
#let title-split(it) = {
  let t = if it.body.has("text") { it.body.text } else { none }
  if t == none or not t.contains(": ") { return it }
  let (title, subtitle) = (t.slice(0, t.position(": ")), t.slice(t.position(": ")))
  it.func()(title) + subtitle
}

// --- the citation of a citation ---------------------------------------------------------------------------------------
// the system of the calls of the work, which the main function sets: `apud` writes the call of the source consulted
// in it, wherever the author calls it
#let chosen = state("abntly-citation-system", "alf")

// 10520, 7.3: "autoria ou a primeira palavra do título; data; página do documento original, se houver; a expressão
// apud; autoria ou a primeira palavra do título; data; página da fonte consultada, se houver", and only the source
// consulted in the list. The norm sets "apud" in italics in its examples. The original work is not in the `.bib`,
// so its author and its date are the author's own words; the source consulted is a call of `cite` without its
// parentheses (the form "bare"), which puts it in the list.
/// Creates a citation of a citation (NBR 10520:2023, section 7.3): the original work, which was not consulted,
/// followed by the expression "apud" and by the call of the source consulted, as in "(Cagliari, 1986, p. 104 apud
/// Suassuna, 1995, p. 55)". Only the source consulted is in the `.bib` file and goes to the list of references; the
/// author and the date of the original work are written in the call.
///
/// ```typ
/// #apud([Cagliari], 1986, <suassuna1995>, page: [p. 104], supplement: [p. 55])
/// #apud([Freire], 1994, <streck2017>, form: "prose")
/// ```
///
/// In the numeric citation systems, the source consulted is given by its number, as in "(Cagliari, 1986 apud 5)".
///
/// - author (str, content): Author of the original work, as it is written in the call: the surname, or the first
///   word of the title.
/// - date (int, str, content): Date of the original work.
/// - key (label): Key of the source consulted in the `.bib` file.
/// - page (none, str, content): Page of the original work, as in `[p. 104]`.
/// - supplement (none, content): Page of the source consulted, as in `[p. 55]`.
/// - form (str): Form of the call: `"normal"`, for the whole call between parentheses, or `"prose"`, for the author
///   in the sentence, as in "Freire (1994 apud Streck, 2017)".
/// -> content
#let apud(author, date, key, page: none, supplement: none, form: "normal") = {
  assert(type(key) == label, message: "apud: the source consulted is a key of the .bib, like <silva2020>; got "
    + repr(key))
  assert(form in ("normal", "prose"), message: "apud: form is \"normal\" or \"prose\"; got " + repr(form))
  let original = [#date] + if page != none [, #page]
  let zwj = "\u{200D}"
  let consulted = context zwj + cite(key, supplement: supplement, style: style-of(chosen.get(), "bare")) + zwj
  if form == "prose" [#author (#original #emph[apud] #consulted)] else [(#author, #original #emph[apud] #consulted)]
}

/// The rules of the calls and of the list for a system (applied by the main function): the style of `bibliography`
/// and `cite`; the prose and author forms in their own style; the list as NBR 6023 (6.3) and NBR 14724 (5.2) ask,
/// in single spacing, aligned to the left and with one blank single line between the references; the highlight only
/// on the title; the work without an author by its title.
///
/// - body (content): the work.
/// - system (str): "alf", "num", "overcite" or "ieee".
/// -> content
#let citations(body, system: "alf") = {
  chosen.update(system)
  let (normal, prose, author) = ("normal", "prose", "author").map(form => style-of(system, form))
  set bibliography(style: normal)
  set cite(style: normal)
  let zwj = "\u{200D}"
  show cite.where(form: "prose"): it => zwj + cite(it.key, supplement: it.supplement, style: prose) + zwj
  show cite.where(form: "author"): it => zwj + cite(it.key, style: author) + zwj
  // the title between the marks, as the text element the regex rule gives. The rule of the calls is set once, over
  // the whole work, not inside a `show cite`: the marks occur nowhere else, and a show rule created inside every
  // call costs several times more than one scan of the text
  let marked(marks, write) = it => write(it.text.trim(marks.at(0), at: start).trim(marks.at(1), at: end))
  show regex(call-marks.join("[^" + call-marks.at(1) + "]*")): marked(call-marks, title-call)
  let entries(it) = {
    show strong: title-split
    show emph: title-split
    show regex(entry-marks.join("[^" + entry-marks.at(1) + "]*")): marked(entry-marks, title-entry)
    it
  }
  show bibliography: set par(leading: single-spacing - 1em, spacing: 2 * single-spacing - 1em, first-line-indent: 0pt,
    justify: false)
  show bibliography: entries
  show cite.where(form: "full"): entries
  body
}
